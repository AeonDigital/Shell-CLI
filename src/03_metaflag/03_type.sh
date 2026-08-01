#!/usr/bin/env bash

#
# METAFLAG 'type'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_type=()
METAFLAG_type["long"]="type"
METAFLAG_type["short"]=""
METAFLAG_type["type"]="string"
METAFLAG_type["accept_values"]="SHELL_CLI_TYPE"

METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""

METAFLAG_type["default"]=""
METAFLAG_type["required"]=true

METAFLAG_type["normalize"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""

METAFLAG_type["is_array"]=false
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""

METAFLAG_type["is_assoc"]=false
METAFLAG_type["required_keys"]=""





# shell_cli_metaflag_property_validate_type - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_type() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_type - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_type() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'type'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}