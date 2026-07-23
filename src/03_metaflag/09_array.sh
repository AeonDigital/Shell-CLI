#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/09_array.sh
# DESCRIPTION: declares whether the flag parameter accepts a structured 
#   collection. If active (1), the engine parses the payload as a JSON array 
#   and validates every item.
# ==============================================================================

declare -gA METAFLAG_array=()
METAFLAG_array["long"]="array"
METAFLAG_array["short"]=""
METAFLAG_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_array["tipinput"]=""
METAFLAG_array["type"]="bool"
METAFLAG_array["enum"]=""

METAFLAG_array["required"]=false
METAFLAG_array["default"]="0"

METAFLAG_array["array"]=false
METAFLAG_array["assoc"]=false
METAFLAG_array["assoc_keys"]=""

METAFLAG_array["normalize"]=""
METAFLAG_array["validate"]=""
METAFLAG_array["transform"]=""
METAFLAG_array["regex"]=""

METAFLAG_array["min"]=""
METAFLAG_array["max"]=""
METAFLAG_array["min_array"]=""
METAFLAG_array["max_array"]=""



# shell_cli_metaflag_property_validate_array metaflag 'array'.
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
shell_cli_metaflag_property_validate_array() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["assoc"]}"

  if [ "$fval" = "1" ] && [ "$_assoc" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'array=true' and 'assoc=true' simultaneously."
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
