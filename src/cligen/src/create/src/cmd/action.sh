#!/usr/bin/env bash



declare -g SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET="0"
declare -ga SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD=()



# shell_cli_cmd_cligen_create_cmd_presets — presets that must be available for the
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
shell_cli_cmd_cligen_create_cmd_presets() {
  if [ "${SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET}" = "1" ]; then
    return 0
  fi

  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -lt 2 ]; then
    echo "[ x ] To perform this action, you must select a target package command."
    echo ""
    echo "      Run"
    echo "      > 'set-env --path=\"...\" --pkg=\"...\"'"
    echo "      or"
    echo "      > 'set-env --path=\"...\" --pkg=\"...\"' --cmd=\"...\""
    return 1
  fi


  shell_cli_cmd_cligen_utils_template_check_files
  if [ $? -ne 0 ]; then
    return 1
  fi


  # 
  # Retrieves the array value from a definition in a previous session.
  SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD=(${XSHELL_CLI_CMD_CLIGEN_ENV_CMD})
  SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD+=("${SHELL_CLI_CMD_INPUT["name"]}")
  shell_cli_cmd_cligen_cmd_unset

  shell_cli_cmd_cligen_cmd_set "SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD"
  shell_cli_cmd_cligen_placeholder_set_assoc


  SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET="1"
  return 0
}




# shell_cli_cmd_cligen_create_cmd_validate — Custom post-parameter-receipt validation
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
shell_cli_cmd_cligen_create_cmd_validate() {
  shell_cli_cmd_cligen_create_cmd_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  return 0
}



# shell_cli_cmd_cligen_create_cmd_action — Core business logic handler orchestrating
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
shell_cli_cmd_cligen_create_cmd_action() {
  shell_cli_cmd_cligen_create_cmd_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi


  shell_cli_cmd_cligen_utils_clear_non_empty_directory "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi


  echo "================================================================================"
  echo "[RUN] Creating CLI PKG CMD structure..."
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
  echo ""


  shell_cli_cmd_cligen_create_cmd_action_step_01
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  shell_cli_cmd_cligen_create_cmd_action_step_02
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  shell_cli_cmd_cligen_create_cmd_action_step_03
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi


  echo "[OKK] A new structure for the CLI PKG Command was successfully generated."
  return 0
}





shell_cli_cmd_cligen_create_cmd_action_step_01() {
  local ok="1"
  local dir=""
  local -a arr_newdir=(
    "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
  )

  echo "[ . ] Generating directory structure..."

  for dir in "${arr_newdir[@]}"; do
    if ! mkdir -p "${dir}" 2>/dev/null; then
      echo "[ x ] Could not create the directory"
      echo "      '${dir}'"
      ok="0"
    fi
    echo "[ v ] Directory '${dir}' successfully created."
  done

  if [ "${ok}" = "0" ]; then
    echo "[ERR] :: Check your user permissions and try again."
    echo ""
    return 1
  fi

  echo "[ v ] Directory structure successfully generated."
  return 0
}

shell_cli_cmd_cligen_create_cmd_action_step_02() {
  local -a arr_templatefiles=(
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_action.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_cmd.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_flags.tmpl"
  )
  local -a arr_projectfiles=(
    "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/action.sh"
    "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
    "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/flags.sh"
  )



  local i=""
  local ok="1"
  local tfile=""
  local pfile""

  echo ""
  echo "[ . ] Installing initial files for the new CLI PKG CMD..."
  echo "[ . ] Copying template files..."

  for i in "${!arr_templatefiles[@]}"; do
    tfile="${arr_templatefiles["${i}"]}"
    pfile="${arr_projectfiles["${i}"]}"

    shell_cli_utils_string_replace_placeholder "${tfile}" "SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER"
    if [ $? -ne 0 ]; then
      echo "[ x ] Failed to create file content from template"
      echo "      '${tfile}' to '${pfile}'"
      ok="0"
    else
      echo "${SHELL_CLI_FN_RETURN}" > "${pfile}"
      if [ $? -ne 0 ]; then
        echo "[ x ] Failed to deploy file"
        echo "      '${tfile}' to '${pfile}'"
        ok="0"
      fi
    fi
    echo "[ v ] File '${pfile}' successfully created."
  done

  if [ "${ok}" = "0" ]; then
    echo "[ERR] :: Check your user permissions and try again."
    echo ""
    return 1
  fi

  echo ""
  echo "[ v ] Files successfully installed."
  return 0
}

shell_cli_cmd_cligen_create_cmd_action_step_03() {
  if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}" ]; then
    echo "[ x ] Parent command script not found."
    echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
    return 1
  fi

  local content=$(< "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}")
  if [ "${content}" = "" ]; then
    echo "[ x ] Parent command script is empty."
    echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
    return 1
  fi

  local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE% *}"
  target_parent_tree="${target_parent_tree^^}"
  target_parent_tree="${target_parent_tree// /_}"

  local target_array_name="SHELL_CLI_CMD_"
  target_array_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
  target_array_name+="${target_parent_tree}_"
  target_array_name+="ACTION_ORDER"

  local tgt_anchor="# {{REGISTER ACTION PLACEHOLDER}}"
  if [[ ! "${content}" == *"${tgt_anchor}"* ]]; then
    echo "[ x ] Could not find the editing anchor for new action registrations "
    echo "      in the main script command."
    echo ""
    echo "      Missing markup:"
    echo "      \`\`\`"
    echo "      ${tgt_anchor}"
    echo "      \`\`\`"
    echo ""
    echo ""
    echo "      Please insert it after the last record of type '${target_array_name}'"
    echo "      according to the template below and try again."
    echo ""
    echo "      \`\`\` ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
    echo "      declare -ga ${target_array_name}=()"
    echo "      ${target_array_name}+=(\"first\")"
    echo "      ${target_array_name}+=(\"second\")"
    echo "      ${target_array_name}+=(\"last\")"
    echo "      ${tgt_anchor}"
    echo "      \`\`\`"
    return 1
  fi


  local new_registry="${target_array_name}+=(\"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}\")"
  if [[ "${content}" == *"${new_registry}"* ]]; then
    echo "[ ! ] A record for this command already exists."
    echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
    return 0
  fi

  local use_anchor="\# \{\{REGISTER ACTION PLACEHOLDER\}\}"
  local use_registry="${new_registry}${codeNL}${tgt_anchor}"

  content="${content/${use_anchor}/${use_registry}}"
  echo "${content}" > "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
  if [ $? -ne 0 ]; then
    echo "[ x ] Unable to update the script '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'."
    echo "[ERR] :: Check your user permissions and try again."
    return 1
  fi

  return 0
}
