#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/01_flag_single_value.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_process_flag_single_value — process and validate a single flag value atomically.
#
# Arguments:
# - $1: raw single value to be validated.
#
# Behavior:
# - Initializes SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE with the raw input.
# - Clears any previous error message.
# - If value is not empty:
#   * Normalizes the value according to the flag type using shell_cli_type_normalize_*.
#   * Validates the normalized value using shell_cli_type_validate_*.
#   * On failure, stores a descriptive error message in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE
#     and returns the validation status code (including special handling for control characters).
# - Sequentially validates the value against all remaining flag properties:
#   * accept_values
#   * normalize
#   * min
#   * max
#   * regex
#   * validate
#   * transform
# - Each property is checked via its dedicated function. On failure, stores a descriptive
#   error message and halts immediately.
#
# Returns:
# - 0: success (single value normalized and validated against all properties).
# - 1: failure in property validation (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
# - 10: failure in type validation (e.g., 10 for control characters).
shell_cli_process_flag_single_value() {
  local rawSingleValue="${1}"
  local SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${1}"
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""



  #
  # Only normalize and validate by type if raw value is not empty
  if [ "${rawSingleValue}" != "" ]; then
    local normalizeByTypeFN="shell_cli_type_normalize_${SHELL_CLI_PROCESS_FLAG_TYPE}"
    SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE=$("${normalizeByTypeFN}" "${rawSingleValue}")


    local validateStatus="0"
    local validateByTypeFN="shell_cli_type_validate_${SHELL_CLI_PROCESS_FLAG_TYPE}"
    "${validateByTypeFN}" "$SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE"
    validateStatus=$?

    if [ "${validateStatus}" != 0 ]; then
      SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="not a valid '${SHELL_CLI_PROCESS_FLAG_TYPE}' type; ( value: '${rawSingleValue}' )"
      
      if [ "${validateStatus}" = "10" ]; then
        SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE+=" (remove control characters)"
      fi

      return "${validateStatus}"
    fi
  fi


  #
  # Check Accept Values
  shell_cli_process_flag_single_value_against_prop_accept_values "${flagAssocDefinition["accept_values"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Accept Values
  shell_cli_process_flag_single_value_against_prop_normalize "${flagAssocDefinition["normalize"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Min
  shell_cli_process_flag_single_value_against_prop_min "${flagAssocDefinition["min"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Max
  shell_cli_process_flag_single_value_against_prop_max "${flagAssocDefinition["max"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Regex
  shell_cli_process_flag_single_value_against_prop_regex "${flagAssocDefinition["regex"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Validate
  shell_cli_process_flag_single_value_against_prop_validate "${flagAssocDefinition["validate"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Transform
  shell_cli_process_flag_single_value_against_prop_transform "${flagAssocDefinition["transform"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi

  return 0
}
