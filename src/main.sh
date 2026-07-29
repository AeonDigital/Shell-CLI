#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/main.sh
# DESCRIPTION: Framework root lifecycle controller driving auto-sourcing, 
#              pre-flight parsing, and deterministic execution pipelines.
# ==============================================================================

shell_cli_run() {
  local rootPath="${1}"; shift

  # echo "${rootPath}"
  # echo "--- ARGUMENT DUMP (Total: $#) ---"
  # for arg in "$@"; do
  #   printf "  Arg [%d]: '%s'\n" "$i" "$arg"
  #   ((i++))
  # done
  # echo "--------------------------------"


  #
  # Avoid nested shell CLI processes; 
  # use a subshell if necessary.
  if ! shell_cli_preflight_process_lock; then
    return 1
  fi
  echo "exit"
  exit
  #
  # Loads the CLI shell engine and all dependencies for the command to be activated. 
  if ! shell_cli_preflight_prepare_command "${rootPath}" "$@"; then
    shell_cli_preflight_process_unlock
    return 1
  fi
  
  #
  # Prepare and compile flags for the current sub-command
  if ! shell_cli_preflight_prepare_command_flags; then
    shell_cli_preflight_process_unlock
    return 1
  fi

  #
  # Extracts the flags and their values ​​entered by the user.
  if ! shell_cli_preflight_prepare_input "$@"; then
    shell_cli_preflight_process_unlock
    return 1
  fi


  #
  # 1. If help triggers are pulled, render it
  if [ "${SHELL_CLI_COMMAND_TRIGGER_HELP}" = "1" ]; then
    shell_cli_handler_help
    shell_cli_preflight_process_unlock
    return 0
  fi

  #
  # 2. If interactive triggers, starts it handler
  if [ "${SHELL_CLI_COMMAND_TRIGGER_INTERACTIVE}" = "1" ]; then
    shell_cli_handler_interactive
    shell_cli_preflight_process_unlock
    return 0
  fi



  shell_cli_preflight_reset
  shell_cli_preflight_process_unlock
  return 0

  # # ----------------------------------------------------------------------------
  # # STEP 2.2: ORCHESTRATE INTERACTIVE RUNTIME STEP-BY-STEP QUESTIONNAIRE
  # # ----------------------------------------------------------------------------
  # # Catch the precise execution status return code from the interactive pipeline
  # local skip_inputs_validation=0
  # shell_cli_runtime_handle_interactive
  # local interactive_status=$?

  # if [ "$interactive_status" -eq 0 ]; then
  #   # Questionnaire passed perfectly, skip batch validations at Step 3
  #   skip_inputs_validation=1
  # elif [ "$interactive_status" -eq 2 ]; then
  #   # User requested a graceful termination. Clear memory, drop locks and exit.
  #   shell_cli_runtime_reset
  #   return 1
  # fi

  # # ----------------------------------------------------------------------------
  # # STEP 3: EXPLICIT RUNTIME VALUES COMPLIANCE VALIDATION
  # # ----------------------------------------------------------------------------
  # # Executed only if standard parameters were provided directly via terminal args
  # if [ "$skip_inputs_validation" -eq 0 ]; then
  #   if ! shell_cli_runtime_validate_inputs; then
  #     echo -e "$VALIDATION_ERROR_MSG"
  #     shell_cli_runtime_reset
  #     return 1
  #   fi
  # fi

  # # ----------------------------------------------------------------------------
  # # STEP 4: MATERIALIZE AND EXPORT PUBLIC INPUT CONTRACTS
  # # ----------------------------------------------------------------------------
  # # Clone validated inputs into the public dynamic CoC map 'CMD_<PKG>_<TREE>_INPUT'
  # shell_cli_runtime_export_inputs

  # # ----------------------------------------------------------------------------
  # # STEP 5: EXECUTE BUSINESS LIFE CYCLE ACTION HOOK PIPELINES
  # # ----------------------------------------------------------------------------
  # # If help system was triggered, we can handle it or pass directly to execution.
  # # First execute the optional cross-validation business rules hook
  # if declare -f "$SHELL_CLI_RUNTIME_FN_VALIDATE" >/dev/null; then
  #   if ! "$SHELL_CLI_RUNTIME_FN_VALIDATE"; then
  #     echo -e "$VALIDATION_ERROR_MSG"
  #     shell_cli_runtime_reset
  #     return 1
  #   fi
  # fi

  # # Finally trigger the mandatory core action logic block
  # "$SHELL_CLI_RUNTIME_FN_ACTION"
  # local action_exit_code=$?


  # # ----------------------------------------------------------------------------
  # # STEP 6: TERMINATION PURGE AND LOCK RELEASE
  # # ----------------------------------------------------------------------------
  # shell_cli_runtime_reset

  # return $action_exit_code
}