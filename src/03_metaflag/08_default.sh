#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/08_default.sh
# DESCRIPTION: defines the fallback value automatically assigned if the user 
#   omits the flag. Core compiler rules reject schemas where required is true 
#   (1) and a default is simultaneously set.
# ==============================================================================

declare -gA METAFLAG_default=()
METAFLAG_default["long"]="default"
METAFLAG_default["short"]=""
METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""
METAFLAG_default["type"]="code"
METAFLAG_default["enum"]=""

METAFLAG_default["required"]=false
METAFLAG_default["default"]=""

METAFLAG_default["array"]=false
METAFLAG_default["assoc"]=false
METAFLAG_default["assoc_keys"]=""

METAFLAG_default["normalize"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""
METAFLAG_default["regex"]=""

METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""



# shell_cli_metaflag_property_validate_default metaflag 'default'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_property_validate_default() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  local -n __assoc="${fassoc}"
  local _required="${__assoc["required"]}"

  if [ "$fval" != "" ] && [ "$_required" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_default checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed (normalizated and validate by type).
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      The new value after check will be stored in
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_default() {
  local inputVal="$1"
  local ruleVal="$2"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "$inputVal" = "" ] && [ "$ruleVal" != "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="$ruleVal"
  fi

  return 0
}
