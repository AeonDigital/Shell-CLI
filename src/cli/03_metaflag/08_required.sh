#!/usr/bin/env bash

# 
# METAFLAG 'required'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_required=()
METAFLAG_required["long"]="required"
METAFLAG_required["short"]=""
METAFLAG_required["type"]="bool"
METAFLAG_required["accept_values"]=""

METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""

METAFLAG_required["default"]="0"
METAFLAG_required["required"]=false

METAFLAG_required["normalize"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""

METAFLAG_required["is_array"]=false
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""

METAFLAG_required["is_assoc"]=false
METAFLAG_required["required_keys"]=""





# shell_cli_metaflag_property_validate_required — validate structural integrity of
# this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_required() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_required — runtime input check placeholder for this
# metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_required() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${inputVal}" = "" ] && [ "${ruleVal}" = "1" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="cannot be empty or omitted"
    return 1
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
