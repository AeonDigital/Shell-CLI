#!/usr/bin/env bash

# shell_cli_process_flag_single_value_against_prop_transform - apply 'transform' property to single value.
#
# Arguments:
# - $1: transformation rule or function reference.
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_transform to apply transformation logic
#   (e.g., mapping, substitution, formatting).
# - On failure:
#   * Stores error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the transformed value.
#
# Returns:
# - 0: success (value transformed).
# - 1: failure (error message stored).
shell_cli_process_flag_single_value_against_prop_transform() {
  shell_cli_metaflag_check_input_transform "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
