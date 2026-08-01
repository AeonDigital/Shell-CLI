#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_max - Process the active single value against the maximum boundary constraint.
#
# Arguments
# - ruleVal: Configured maximum threshold allowed (e.g., maximum value, length, or chronological baseline).
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework violation string upon failure.
#
# Notes
# - Leverages 'shell_cli_metaflag_check_input_max' internally to evaluate data-type ceiling boundaries.
# - Combines the generic framework error token and the specific validator message into the global error store.
#
# Returns
# - 0: Success (value stays within or below the maximum schema threshold constraint).
# - 1: Failure (value exceeds the configured ceiling limit restriction).
shell_cli_process_flag_single_value_against_prop_max() {
  shell_cli_metaflag_check_input_max "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
