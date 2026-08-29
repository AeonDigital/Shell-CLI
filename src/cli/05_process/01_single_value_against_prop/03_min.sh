#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_min — Process the active single
# value against the minimum boundary constraint.
# 
# Arguments
# - ruleVal: Configured minimum threshold allowed (e.g., minimum value, length, or
#   chronological baseline).
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed
#   counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Leverages 'shell_cli_metaflag_check_input_min' internally to evaluate data-type
#   floor boundaries.
# - Combines the generic framework error token and the specific validator message
#   into the global error store.
# 
# Returns
# - 0: Success (value meets or exceeds the minimum schema threshold constraint).
# - 1: Failure (value falls below the configured floor limit restriction).
shell_cli_process_flag_single_value_against_prop_min() {
  shell_cli_metaflag_check_input_min "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
