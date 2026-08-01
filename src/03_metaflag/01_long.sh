#!/usr/bin/env bash

#
# METAFLAG 'long'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_long=()
METAFLAG_long["long"]="long"
METAFLAG_long["short"]=""
METAFLAG_long["type"]="string"
METAFLAG_long["accept_values"]=""

METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""

METAFLAG_long["default"]=""
METAFLAG_long["required"]=true

METAFLAG_long["normalize"]=""
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="16"
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""

METAFLAG_long["is_array"]=false
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""

METAFLAG_long["is_assoc"]=false
METAFLAG_long["required_keys"]=""





# shell_cli_metaflag_property_validate_long - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_long() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  if [[ "${fval}" =~ ^(help|interactive)$ ]]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'help' and 'interactive' are reserved."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_long - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_long() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'long'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}