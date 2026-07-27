#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/01_single_value_against_prop/02_normalize.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_process_flag_single_value_against_prop_normalize — validate single value against 'normalize' property.
#
# Arguments:
# - $1: normalization configuration for this flag.
#
# Behavior:
# - Invokes shell_cli_metaflag_check_input_normalize to apply normalization rules
#   (e.g., case folding, trimming, mapping).
# - On failure:
#   * Stores error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE.
#   * Returns failure immediately.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the normalized value.
#
# Returns:
# - 0: success (value normalized).
# - 1: failure (error message stored).
shell_cli_process_flag_single_value_against_prop_normalize() {
  shell_cli_metaflag_check_input_normalize "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
