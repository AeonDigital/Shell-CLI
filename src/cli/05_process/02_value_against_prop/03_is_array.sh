#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_is_array — Validate indexed array presence
# and enforce structural collection boundaries.
# 
# Arguments
# - minArray: Configured minimum number of elements allowed in the array collection
#   schema.
# - maxArray: Configured maximum number of elements allowed in the array collection
#   schema.
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE: Updated with the runtime validated/normalized array
#   reference pointer upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework
#   violation string upon failure.
# 
# Notes
# - Phase 1 (Type Compliance): Runs 'shell_cli_metaflag_check_input_is_array' to
#   verify structure and normalize the target object.
# - Phase 2 (Size Boundaries): Sequentially executes length evaluations against the
#   provided 'minArray' and 'maxArray' constraints.
# - Combines the generic flag context error prefix and the respective internal validator
#   messages into the global error store.
# - Short-circuits execution immediately upon encountering any type or boundary rule
#   breach.
# 
# Returns
# - 0: Success (payload is a valid indexed array and its length stays within the
#   configured threshold limits).
# - 1: Failure (value is not an array, or its element count violates size constraints).
shell_cli_process_flag_value_against_prop_is_array() {
  # 
  # Validate input value
  shell_cli_metaflag_check_input_is_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi
  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"


  # 
  # Validate min array
  shell_cli_metaflag_check_input_min_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  # 
  # Validate max array
  shell_cli_metaflag_check_input_max_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${2}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi


  return 0
}
