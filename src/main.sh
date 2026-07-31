#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/main.sh
# DESCRIPTION: Framework root lifecycle controller driving auto-sourcing, 
#              pre-flight parsing, and deterministic execution pipelines.
# ==============================================================================

shell_cli_run() {
  local mainCmdRootPath="${1}"; shift
  local commandName=$(basename "${mainCmdRootPath}" ".sh")


  #
  # 1. Avoid nested shell CLI processes; use a subshell if necessary.
  if ! shell_cli_preflight_process_lock; then
    return 1
  fi

  #
  # 2. Prepare main command.
  if ! shell_cli_preflight_prepare_main_cmd "${mainCmdRootPath}" "${commandName}" "$@"; then
    shell_cli_preflight_process_unlock
    return 1
  fi

  #
  # 3. Prepare target resource.
  if ! shell_cli_preflight_prepare_target_resource "$@"; then
    shell_cli_preflight_process_unlock
    return 1
  fi

  #
  # 4. Prepare and compile flags for the current sub-command
  if ! shell_cli_preflight_prepare_target_resource_flags; then
    shell_cli_preflight_process_unlock
    return 1
  fi

  #
  # 5. Extracts the flags and their values ​​entered by the user.
  if ! shell_cli_preflight_prepare_input "$@"; then
    shell_cli_preflight_process_unlock
    return 1
  fi

  #
  # 6. If help triggers are pulled, render it
  if [ "${SHELL_CLI_TRIGGER_HELP}" = "1" ]; then
    shell_cli_handler_help
    shell_cli_preflight_process_unlock
    return 0
  fi

  #
  # 7. If interactive triggers, starts it handler
  if [ "${SHELL_CLI_TRIGGER_INTERACTIVE}" = "1" ]; then
    if [ ! shell_cli_handler_interactive ]; then
      shell_cli_preflight_process_unlock
      return "$s"
    fi
  fi





  #
  # By this point, all flag data has been properly validated and processed. 
  # We move it into the 'SHELL_CLI_CMD_INPUT' associative array so that it is 
  # easily accessible to the CLI client.
  local k=""
  local v=""
  for k in "${!SHELL_CLI_INPUT_RAW_FLAG_ASSOC[@]}"; do
    v="${SHELL_CLI_CMD_INPUT["${k}"]}"
    SHELL_CLI_CMD_INPUT["${k}"]="${v}"
  done
  #
  # replicates the flag acquisition order for the 'SHELL_CLI_CMD_INPUT_ORDER' array
  SHELL_CLI_CMD_INPUT_ORDER=("${SHELL_CLI_INPUT_RAW_FLAG_ORDER[@]}")


  #
  # performs context validation of the client command
  if [ "${SHELL_CLI_RESOURCE_FUNCTION_VALIDATE}" != "" ]; then
    if ! "${SHELL_CLI_RUNTIME_FN_VALIDATE}"; then
      local validateStatus="$?"
      local validatePrefix=""
      case "${validateStatus}" in
        1)
          # input error
          validatePrefix="[ x ]"
          ;;
        2)
          # input warning
          validatePrefix="[ w ]"
          ;;
        10)
          # input critical error
          validatePrefix="[ERR]"
          ;;
      esac
      echo "${validatePrefix} :: ${SHELL_CLI_CMD_VALIDATE_ERR}"

      shell_cli_runtime_reset
      return "${validateStatus}"
    fi
  fi


  #
  # executes the selected action command
  "${SHELL_CLI_RESOURCE_FUNCTION_ACTION}"
  local actionStatus="$?"


  #
  # clears the execution environment and releases the process
  shell_cli_preflight_reset
  shell_cli_preflight_process_unlock
  return "${actionStatus}"
}