#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_required - Evaluate the active payload value against mandatory presence rules.
#
# Arguments
# - ruleVal: Configured boolean indicator ('true'/'false' or '1'/'0') specifying if the flag is mandatory.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE: Updated with the runtime normalized/transformed counterpart payload upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework violation string upon failure.
#
# Notes
# - Leverages 'shell_cli_metaflag_check_input_required' internally to detect missing or empty structural arguments.
# - Combines the generic flag context error prefix and the specific validator message into the global error store.
#
# Returns
# - 0: Success (value presence matches the mandatory schema rule requirements).
# - 1: Failure (required flag payload is missing or empty).
shell_cli_process_flag_value_against_prop_required() {
  shell_cli_metaflag_check_input_required "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
