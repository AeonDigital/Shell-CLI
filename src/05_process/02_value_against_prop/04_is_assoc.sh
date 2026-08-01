#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_is_assoc - validate against 'is_assoc' property.
#
# Arguments:
# - $1: required keys configuration for this assoc flag.
#
# Behavior:
# - Validates the input value as an associative map using
#   shell_cli_metaflag_check_input_is_assoc.
# - On success:
#   * Updates SHELL_CLI_PROCESS_FLAG_VALUE with the normalized assoc reference.
#   * Updates SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER with the order of keys
#     as parsed.
# - Validates that all required keys are present using
#   shell_cli_metaflag_check_input_required_keys.
# - On failure at any step, stores message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE
#   and halts.
#
# Returns:
# - 0: success (assoc value normalized and required keys validated).
# - 1: failure (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
shell_cli_process_flag_value_against_prop_is_assoc() {
  #
  # Validate input value
  shell_cli_metaflag_check_input_is_assoc "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi
  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=(${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER[@]})


  #
  # Validate required keys
  shell_cli_metaflag_check_input_required_keys "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  return 0
}
