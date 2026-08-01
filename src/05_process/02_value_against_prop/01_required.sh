#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_required - validate flag value against 'required' property.
#
# Arguments:
# - $1: current value of the 'required' property (boolean indicator).
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_required to verify whether the flag
#   value is mandatory and has been provided.
# - If validation fails:
#   * Stores a descriptive error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE,
#     including the flag's error prefix and the parser's message.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_VALUE with the normalized value returned
#     by the check function.
#
# Returns:
# - 0: success (required property satisfied).
# - 1: failure (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
shell_cli_process_flag_value_against_prop_required() {
  shell_cli_metaflag_check_input_required "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
