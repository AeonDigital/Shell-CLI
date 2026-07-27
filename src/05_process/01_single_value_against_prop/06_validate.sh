#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/01_single_value_against_prop/06_validate.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_process_flag_single_value_against_prop_validate — validate single value against custom 'validate' property.
#
# Arguments:
# - $1: custom validation rule or function reference.
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_validate to apply custom validation logic.
# - On failure:
#   * Stores error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the validated value.
#
# Returns:
# - 0: success (custom validation passed).
# - 1: failure (error message stored).
shell_cli_process_flag_single_value_against_prop_validate() {
  shell_cli_metaflag_check_input_validate "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
