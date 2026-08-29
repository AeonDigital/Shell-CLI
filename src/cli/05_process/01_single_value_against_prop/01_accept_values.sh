#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_accept_values — Validate the active
# single value against the allowed options checklist.
# 
# Arguments
# - ruleVal: Configured value or list defining the acceptable options schema.
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed
#   counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Leverages 'shell_cli_metaflag_check_input_accept_values' internally to cross-reference
#   constraints.
# - Combines the generic framework error token and the specific validator message
#   into the global error store.
# 
# Returns
# - 0: Success (value matches an entry inside the allowed options schema).
# - 1: Failure (value is rejected or falls outside the allowed boundary).
shell_cli_process_flag_single_value_against_prop_accept_values() {
  shell_cli_metaflag_check_input_accept_values "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
