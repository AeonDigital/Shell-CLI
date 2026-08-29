#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_regex — Process the active single
# value against a regular expression pattern.
# 
# Arguments
# - ruleVal: Configured POSIX or Extended Regular Expression pattern schema string.
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed
#   counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Leverages 'shell_cli_metaflag_check_input_regex' internally to evaluate pattern
#   conformity.
# - Combines the generic framework error token and the specific validator message
#   into the global error store.
# 
# Returns
# - 0: Success (value satisfies the configured regular expression pattern constraint).
# - 1: Failure (value breaks format rules or fails to match the regular expression
#   pattern).
shell_cli_process_flag_single_value_against_prop_regex() {
  shell_cli_metaflag_check_input_regex "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
