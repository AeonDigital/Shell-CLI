#!/usr/bin/env bash



declare -g SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET="0"


# shell_cli_cmd_cligen_create_pkg_presets — presets that must be available for the
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
shell_cli_cmd_cligen_create_pkg_presets() {
  if [ "${SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET}" = "1" ]; then
    return 0
  fi

  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -le 0 ]; then
    echo "[ x ] No Environment Set to perform this action."
    echo ""
    echo "      Run 'set-env' --path=\"...\" command first!"
    return 1
  fi


  shell_cli_cmd_cligen_utils_template_check_files
  if [ $? -ne 0 ]; then
    return 1
  fi


  shell_cli_cmd_cligen_pkg_set "${SHELL_CLI_CMD_INPUT["name"]}"
  shell_cli_cmd_cligen_placeholder_set_assoc


  SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET="1"
  return 0
}





# shell_cli_cmd_cligen_create_pkg_validate — Custom post-parameter-receipt validation
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
shell_cli_cmd_cligen_create_pkg_validate() {
  shell_cli_cmd_cligen_create_pkg_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  return 0
}



# shell_cli_cmd_cligen_create_pkg_action — Core business logic handler orchestrating
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
shell_cli_cmd_cligen_create_pkg_action() {
  shell_cli_cmd_cligen_create_pkg_presets
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi


  shell_cli_cmd_cligen_utils_clear_non_empty_directory "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
  if [ $? -ne 0 ]; then
    return 1
  fi


  echo "================================================================================"
  echo "[RUN] :: Creating CLI PKG structure..."
  echo ""
  echo "                    PKG : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
  echo "        Local Directory : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
  echo "    Templates Directory : ${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}"
  echo ""


  shell_cli_cmd_cligen_create_pkg_action_step_01
  if [ $? -ne 0 ]; then
    echo "      Action interrupted"
    echo ""
    return 1
  fi

  shell_cli_cmd_cligen_create_pkg_action_step_02
  if [ $? -ne 0 ]; then
    echo "      Action interrupted!"
    echo ""
    return 1
  fi

  shell_cli_cmd_cligen_create_pkg_action_step_03
  if [ $? -ne 0 ]; then
    echo "[END] The structure was generated, but errors occurred;"
    echo "      please check it before proceeding!"
  else
    echo "[OKK] A new structure for the CLI Project was successfully generated."
  fi

  echo "================================================================================"
  return 0
}





shell_cli_cmd_cligen_create_pkg_action_step_01() {
  local ok="1"
  local dir=""
  local -a arr_newdir=(
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals"
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/src"
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

shell_cli_cmd_cligen_create_pkg_action_step_02() {
  local -a arr_templatefiles=(
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_boot.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_cmd.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_entrypoint.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_readme.tmpl"

    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/global_flags.tmpl"
    "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/global_utils.tmpl"
  )
  local -a arr_projectfiles=(
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/boot.sh"
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/cmd.sh"
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}"
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/README.md"

    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals/flags.sh"
    "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals/utils.sh"
  )



  local i=""
  local ok="1"
  local tfile=""
  local pfile""

  echo ""
  echo "[ . ] Installing initial files for the new CLI PKG..."
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

shell_cli_cmd_cligen_create_pkg_action_step_03() {
  chmod +x "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}"
  if [ $? -ne 0 ]; then
    echo ""
    echo "[ ! ] - Operational execution flag assignment denied."
    echo "        Please grant runtime validation permissions explicitly:"
    echo "        > chmod +x '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}'"
    echo ""
    return 1
  fi

  echo ""
  echo "[ v ] Executable main.sh project driver layer armed."
  echo ""
  return 0
}
