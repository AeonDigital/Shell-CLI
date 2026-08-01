#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_regex - validate single value against 'regex' property.
#
# Arguments:
# - $1: regex pattern to match against.
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_regex to ensure the value matches
#   the specified pattern.
# - On failure:
#   * Stores error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the validated value.
#
# Returns:
# - 0: success (value matches regex).
# - 1: failure (error message stored).
shell_cli_process_flag_single_value_against_prop_regex() {
  shell_cli_metaflag_check_input_regex "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
