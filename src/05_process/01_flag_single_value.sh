#!/usr/bin/env bash

# shell_cli_process_flag_single_value - Process and validate a single flag value through the evaluation pipeline.
#
# Arguments
# - rawSingleValue: Target raw string value to be normalized and evaluated atomically.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE: Stores the final post-processed, normalized value state.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Captures specific descriptive violation strings on failure.
#
# Notes
# - Skips initial type normalization and type validation cycles if the input value is empty.
# - Sequentially enforces type compliance before running property-specific validation hooks.
# - Evaluates values against core metaflag constraints: accept_values, normalize, min, max, regex, validate, and transform.
# - Short-circuits execution and reports immediate failure upon encountering the first rule breach.
#
# Returns
# - 0: Success (value successfully parsed and passed all schema constraint properties).
# - 1: Failure (value violated a specific structural metaflag property schema rule).
# - 10: Type Breach (value failed baseline datatype checks, e.g., structural control characters present).
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
