#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_is_assoc — Validate associative array
# presence and enforce dictionary structural constraints.
# 
# Arguments
# - requiredKeys: Configured list or rule specifying keys that must exist within
#   the associative map.
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE: Updated with the runtime validated/normalized associative
#   array reference pointer upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER: Populated with the precise discovered
#   sequence array of keys parsed from the payload.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Phase 1 (Structural Integrity): Invokes 'shell_cli_metaflag_check_input_is_assoc'
#   to verify and ingest the dictionary map.
# - Phase 2 (Key Verification): Executes presence compliance checks over the collection
#   against the 'requiredKeys' rule.
# - Combines the generic flag context error prefix and the respective internal validator
#   messages into the global error store.
# - Short-circuits execution immediately upon encountering any structural or missing
#   key breach.
# 
# Returns
# - 0: Success (payload is a valid associative array and all mandatory schema keys
#   are present).
# - 1: Failure (value is not a dictionary map, or it lacks mandatory structural keys).
shell_cli_process_flag_value_against_prop_is_assoc() {
  # 
  # Validate input value
  shell_cli_metaflag_check_input_is_assoc "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi
  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=(${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER[@]})


  # 
  # Validate required keys
  shell_cli_metaflag_check_input_required_keys "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  return 0
}
