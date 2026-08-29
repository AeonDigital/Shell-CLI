#!/usr/bin/env bash



declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET="0"
declare -ga TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE=""
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER=""
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC=""



# shell_cli_cmd_cligen_create_flag_presets — presets that must be available for the
# validation and/or execution stage of this command.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Optionally and explicitly invoked within the 'validation' function and/or the
#   'action' of this command.
# - It plays a centralizing role for actions necessary for the overall performance
#   of this command—or even others to be executed subsequently via the shared environment.
# 
# Returns
# - 0: Success (context satisfies all domain-level guard rails, permitting business
#   actions to proceed).
# - 1+: Failure (domain violation detected; short-circuits execution and reports
#   the custom message).
shell_cli_cmd_cligen_create_flag_presets() {
  if [ "${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET}" = "1" ]; then
    return 0
  fi

  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -lt 3 ]; then
    echo "[ x ] To perform this action, you must select a target package command."
    echo ""
    echo "      Run"
    echo "      > 'set-env --path=\"...\" --pkg=\"...\"' --cmd=\"...\""
    return 1
  fi


  shell_cli_cmd_cligen_utils_template_check_files
  if [ $? -ne 0 ]; then
    return 1
  fi


  # 
  # Retrieves the array value from a definition in a previous session.
  TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD=(${XSHELL_CLI_CMD_CLIGEN_ENV_CMD})
  shell_cli_cmd_cligen_cmd_unset

  shell_cli_cmd_cligen_cmd_set "TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD"
  shell_cli_cmd_cligen_placeholder_set_assoc


  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET="1"
  return 0
}




# shell_cli_cmd_cligen_create_flag_validate — Custom post-parameter-receipt validation
# for high-level checks.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Invoked automatically by the core framework after input collection (CLI/Interactive)
#   but before business actions run.
# - Designed to evaluate multi-flag balance constraints, environmental states, and
#   safety policies.
# 
# Returns
# - 0: Success (context satisfies all domain-level guard rails, permitting business
#   actions to proceed).
# - 1+: Failure (domain violation detected; short-circuits execution and reports
#   the custom message).
shell_cli_cmd_cligen_create_flag_validate() {
  shell_cli_cmd_cligen_create_flag_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  return 0
}





# shell_cli_cmd_cligen_create_flag_action — Core business logic handler orchestrating
# the main operations of the command path.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Acts as the final execution block in the framework lifecycle pipeline for a successfully
#   matched command route node.
# - Dispatches primary operational workloads (e.g., orchestration, file manipulation,
#   automation, or task sequences).
# 
# Returns
# - 0: Success (all internal operations completed their processing loops smoothly
#   with zero errors).
# - 1+: Failure (runtime exception, storage fault, or downstream processing barrier
#   encountered).
shell_cli_cmd_cligen_create_flag_action() {
  shell_cli_cmd_cligen_create_flag_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi



  echo "================================================================================"
  echo "[RUN] Creating New Command Flag ..."
  echo ""
  echo "    Workspace : ${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
  echo ""
  echo "      Package : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
  echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
  echo ""
  echo "   Parent CMD : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME}"
  echo "   Entrypoint : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
  echo ""
  echo "      Command : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
  echo "         Tree : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
  echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
  echo "         Flag : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"
  echo ""



  shell_cli_cmd_cligen_create_flag_action_step_01
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  shell_cli_cmd_cligen_create_flag_action_step_02
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  echo "[OKK] A new structure for the CLI PKG Command was successfully generated."
  return 0
}





shell_cli_cmd_cligen_create_flag_action_step_01() {
  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE=""
  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER=""
  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC=""

  local fname="${SHELL_CLI_CMD_INPUT["long"]}"

  local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
  target_parent_tree="${target_parent_tree^^}"
  target_parent_tree="${target_parent_tree// /_}"

  local target_base_name="SHELL_CLI_CMD_"
  target_base_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
  target_base_name+="${target_parent_tree}_"
  target_base_name+="FLAG"


  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER="${target_base_name}_ORDER+=(\"${fname}\")"
  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC="declare -gA ${target_base_name}_${fname}=()"


  local code=""
  code+="# ${codeNL}"
  code+="# FLAG ${fname}${codeNL}"
  code+="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}${codeNL}"
  code+="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}${codeNL}"

  local f=""
  local v=""
  local assoc_flag="${target_base_name}_${fname}"
  for f in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    v="${SHELL_CLI_CMD_INPUT["${f}"]}"
    if [ "${v}" != "" ]; then
      code+="${assoc_flag}[\"${f}\"]="

      case "${f}" in
        required|is_array|is_assoc)
          if [ "${v}" = "0" ]; then
            v="false"
          elif [ "${v}" = "1" ]; then
            v="true"
          fi
          ;;
      esac

      if [ "${v}" = "true" ] || [ "${v}" = "false" ]; then
        code+="${v}"
      else
        code+="\"${v}\""
      fi

      code+="${codeNL}"
    fi
  done

  SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE="${code}"
}

shell_cli_cmd_cligen_create_flag_action_step_02() {
  if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}" ]; then
    echo "[ x ] Parent flag script not found."
    echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
    return 1
  fi

  local content=$(< "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}")
  if [ "${content}" = "" ]; then
    echo "[ x ] Parent command flag is empty."
    echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
    return 1
  fi

  local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE% *}"
  target_parent_tree="${target_parent_tree^^}"
  target_parent_tree="${target_parent_tree// /_}"

  local target_array_name="SHELL_CLI_CMD_"
  target_array_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
  target_array_name+="${target_parent_tree}_"
  target_array_name+="ACTION_ORDER"

  local tgt_anchor="# {{REGISTER FLAG PLACEHOLDER}}"
  if [[ ! "${content}" == *"${tgt_anchor}"* ]]; then
    echo "[ x ] Could not find the editing anchor for new flag registrations "
    echo "      in the main script command."
    echo ""
    echo "      Missing markup:"
    echo "      \`\`\`"
    echo "      ${tgt_anchor}"
    echo "      \`\`\`"
    echo ""
    echo ""
    echo "      Please insert this after the last flag entry in the flags script"
    echo "      and try again."
    return 1
  fi


  if [[ "${content}" == *"${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}"* ]]; then
    echo "[ ! ] A record for this flag already exists."
    echo "      Find code line:"
    echo "      > ${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}"
    echo "      in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
    echo ""
    echo "      Remove it to proceed"
    return 1
  fi

  if [[ "${content}" == *"${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}"* ]]; then
    echo "[ ! ] A record for this flag already exists."
    echo "      Find code line:"
    echo "      > ${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}"
    echo "      in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
    echo ""
    echo "      Remove it to proceed"
    return 1
  fi


  local use_anchor="\# \{\{REGISTER FLAG PLACEHOLDER\}\}"
  local use_registry="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE}${codeNL}${tgt_anchor}"

  content="${content/${use_anchor}/${use_registry}}"
  echo "${content}" > "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"
  if [ $? -ne 0 ]; then
    echo "[ x ] Unable to update the script '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'."
    echo "[ERR] :: Check your user permissions and try again."
    return 1
  fi

  return 0
}
