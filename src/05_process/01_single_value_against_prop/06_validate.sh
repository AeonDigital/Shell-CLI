#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_validate - Process the active single value against a custom validation rule or hook.
#
# Arguments
# - ruleVal: Configured custom validation command string, function pointer, or rule expression.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework violation string upon failure.
#
# Notes
# - Leverages 'shell_cli_metaflag_check_input_validate' internally to evaluate arbitrary or extended rule compliance.
# - Combines the generic framework error token and the specific validator message into the global error store.
#
# Returns
# - 0: Success (value satisfies the custom validation function or logic constraints).
# - 1: Failure (value is rejected by the user-defined validation hook extension).
shell_cli_process_flag_single_value_against_prop_validate() {
  shell_cli_metaflag_check_input_validate "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
