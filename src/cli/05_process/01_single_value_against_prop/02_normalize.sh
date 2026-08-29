#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_normalize — Process the active
# single value against normalization rules.
# 
# Arguments
# - ruleVal: Configured normalization strategy schema (e.g., case folding, trimming,
#   mapping).
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Updated with the runtime normalized/transformed
#   counterpart value upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Leverages 'shell_cli_metaflag_check_input_normalize' internally to apply text
#   formatting transformations.
# - Combines the generic framework error token and the specific validator message
#   into the global error store.
# 
# Returns
# - 0: Success (value successfully formatted or no normalization required).
# - 1: Failure (value processing failed or broke a formatting rule boundary).
shell_cli_process_flag_single_value_against_prop_normalize() {
  shell_cli_metaflag_check_input_normalize "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
