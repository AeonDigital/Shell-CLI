#!/usr/bin/env bash



# shell_cli_cmd_cligen_set_env_presets — presets that must be available for the validation
# and/or execution stage of this command.
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
shell_cli_cmd_cligen_set_env_presets() {
  if [ "${SHELL_CLI_CMD_EXEC_MODE}" != "SOURCING" ]; then
    echo "[ERR] This command must be run using 'source' or the '.' operator."
    echo "      > . ${0}"
    return 1
  fi

  local path="${SHELL_CLI_CMD_INPUT["path"]}"
  SHELL_CLI_CMD_CLIGEN_ENV_PATH="${path}"
  SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="1"


  local pkg="${SHELL_CLI_CMD_INPUT["pkg"]}"
  if [ "${pkg}" != "" ]; then
    shell_cli_cmd_cligen_pkg_set "${pkg}"
    SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="2"
  fi


  local cmd="${SHELL_CLI_CMD_INPUT["cmd"]}"
  if [ "${pkg}" != "" ] && [ "${cmd}" != "" ]; then
    shell_cli_cmd_cligen_cmd_set "${cmd}"
    SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="3"
  fi

  return 0
}





# shell_cli_cmd_cligen_set_env_validate — Custom post-parameter-receipt validation
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
shell_cli_cmd_cligen_set_env_validate() {
  shell_cli_cmd_cligen_env_reset
  shell_cli_cmd_cligen_set_env_presets
  if [ $? -ne 0 ]; then
    shell_cli_cmd_cligen_env_reset
    return 1
  fi


  if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_PATH}" ]; then
    echo "[ x ] The given path for the CLI Project root directory does not exist."
    echo "      Looking in '${path}'"

    shell_cli_cmd_cligen_env_reset
    return 1
  fi


  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}" != "" ]; then
    if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}" ]; then
      echo "[ x ] The given Package Name does not correspond to an existing directory"
      echo "      within the CLI project root."
      echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}'"

      shell_cli_cmd_cligen_env_reset
      return 1
    fi

    if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}" ]; then
      echo "[ x ] The startup script for this package was not found at the expected location."
      echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}'"

      shell_cli_cmd_cligen_env_reset
      return 1
    fi
  fi


  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}" != "" ]; then
    if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}" ]; then
      echo "[ x ] The given Command Name does not correspond to an existing directory"
      echo "      within the CLI project root."
      echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}'"

      shell_cli_cmd_cligen_env_reset
      return 1
    fi

    if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}" ]; then
      echo "[ x ] The startup script for this command was not found at the expected location."
      echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}'"

      shell_cli_cmd_cligen_env_reset
      return 1
    fi

    if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}" ]; then
      echo "[ x ] The flags script for this command was not found at the expected location."
      echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"

      shell_cli_cmd_cligen_env_reset
      return 1
    fi
  fi

  return 0
}





# shell_cli_cmd_cligen_set_env_action — Core business logic handler orchestrating
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
shell_cli_cmd_cligen_set_env_action() {

  echo "================================================================================"
  echo "[RUN] Setting Environment"
  echo ""
  echo "    Workspace : ${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -ge "2" ]; then
  echo ""
  echo "      Package : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
  echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
  fi
  if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -ge "3" ]; then
  echo ""
  echo "      Command : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
  echo "         Tree : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
  echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
  fi
  echo ""
  echo "[OKK]"

  return 0
}
