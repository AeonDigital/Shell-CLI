#!/usr/bin/env bash

# 
# METAFLAG 'default'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_default=()
METAFLAG_default["long"]="default"
METAFLAG_default["short"]=""
METAFLAG_default["type"]="code"
METAFLAG_default["accept_values"]=""

METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""

METAFLAG_default["default"]=""
METAFLAG_default["required"]=false

METAFLAG_default["normalize"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""

METAFLAG_default["is_array"]=false
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""

METAFLAG_default["is_assoc"]=false
METAFLAG_default["required_keys"]=""





# shell_cli_metaflag_property_validate_default — validate structural integrity of
# this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_default() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  local -n __assoc="${fassoc}"
  local _required="${__assoc["required"]}"

  if [ "${fval}" != "" ] && [ "${_required}" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_default — runtime input check placeholder for this
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
shell_cli_metaflag_check_input_default() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${inputVal}" = "" ] && [ "${ruleVal}" != "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${ruleVal}"
    return 0
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
