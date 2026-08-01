#!/usr/bin/env bash

#
# METAFLAG 'description'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_description=()
METAFLAG_description["long"]="description"
METAFLAG_description["short"]=""
METAFLAG_description["type"]="text"
METAFLAG_description["accept_values"]=""

METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""

METAFLAG_description["default"]=""
METAFLAG_description["required"]=true

METAFLAG_description["normalize"]=""
METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["regex"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""

METAFLAG_description["is_array"]=false
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""

METAFLAG_description["is_assoc"]=false
METAFLAG_description["required_keys"]=""





# shell_cli_metaflag_property_validate_description - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_description() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_description - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_description() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'description'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}