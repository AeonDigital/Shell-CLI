#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_accept_values - validate single value against 'accept_values' property.
#
# Arguments:
# - $1: list of accepted values for this flag.
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_accept_values to ensure the single value
#   matches one of the allowed options.
# - On failure:
#   * Stores a descriptive error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE,
#     including the flag's error prefix and parser message.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the normalized accepted value.
#
# Returns:
# - 0: success (value is among accepted options).
# - 1: failure (error message stored).
shell_cli_process_flag_single_value_against_prop_accept_values() {
  shell_cli_metaflag_check_input_accept_values "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
