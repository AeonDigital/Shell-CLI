#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_default - validate flag value against 'default' property.
#
# Arguments:
# - $1: current value of the 'default' property (default value to apply if input is empty).
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_default to determine whether a default
#   value should be applied to the flag.
# - If validation fails:
#   * Stores a descriptive error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE,
#     including the flag's error prefix and the parser's message.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_VALUE with the normalized value returned
#     by the check function (either the original input or the applied default).
#
# Returns:
# - 0: success (default applied or input accepted).
# - 1: failure (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
shell_cli_process_flag_value_against_prop_default() {
  shell_cli_metaflag_check_input_default "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
