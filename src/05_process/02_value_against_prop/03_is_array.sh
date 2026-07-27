#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/02_value_against_prop/03_is_array.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_process_flag_value_against_prop_is_array — validate flag value against 'is_array' property.
#
# Arguments:
# - $1: minimum number of elements allowed (min_array).
# - $2: maximum number of elements allowed (max_array).
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_is_array to ensure the flag value
#   is treated as an indexed array.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_VALUE with the normalized array reference.
# - Validates array length constraints:
#   * Calls shell_cli_metaflag_check_input_min_array to enforce minimum size.
#   * Calls shell_cli_metaflag_check_input_max_array to enforce maximum size.
# - If any validation fails:
#   * Stores a descriptive error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE,
#     including the flag's error prefix and the parser's message.
#   * Returns failure immediately.
#
# Returns:
# - 0: success (array value normalized and size constraints satisfied).
# - 1: failure (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
shell_cli_process_flag_value_against_prop_is_array() {
  #
  # Validate input value
  shell_cli_metaflag_check_input_is_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi
  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"


  #
  # Validate min array
  shell_cli_metaflag_check_input_min_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi
  #
  # Validate max array
  shell_cli_metaflag_check_input_max_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${2}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  return 0
}
