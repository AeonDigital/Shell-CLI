#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_transform - Process the active single value against a mutation or transformation hook.
#
# Arguments
# - ruleVal: Configured transformation command string, function pointer, or mutation expression.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework violation string upon failure.
#
# Notes
# - Leverages 'shell_cli_metaflag_check_input_transform' internally to apply external mutations (e.g., substitution, structural formatting).
# - Combines the generic framework error token and the specific validator message into the global error store.
#
# Returns
# - 0: Success (value successfully converted or mapped by the transformation logic).
# - 1: Failure (value transformation pipeline failed or was rejected by the hook extension).
shell_cli_process_flag_single_value_against_prop_transform() {
  shell_cli_metaflag_check_input_transform "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
