#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/02_short.sh
# DESCRIPTION: defines the short alphanumeric alias for a command-line flag.
#   It acts as a single-dash alternative (e.g., -s) and must not exceed 3 
#   characters
# ==============================================================================

declare -gA METAFLAG_short=()
METAFLAG_short["long"]="short"
METAFLAG_short["short"]=""
METAFLAG_short["description"]="Short alphanumeric character alias for the flag (1 to 3 chars)."
METAFLAG_short["tipinput"]=""
METAFLAG_short["type"]="string"
METAFLAG_short["enum"]=""

METAFLAG_short["required"]=false
METAFLAG_short["default"]=""

METAFLAG_short["array"]=false
METAFLAG_short["assoc"]=false
METAFLAG_short["assoc_keys"]=""

METAFLAG_short["normalize"]=""
METAFLAG_short["validate"]=""
METAFLAG_short["transform"]=""
METAFLAG_short["regex"]="^[a-zA-Z0-9]+$"

METAFLAG_short["min"]="1"
METAFLAG_short["max"]="3"
METAFLAG_short["min_array"]=""
METAFLAG_short["max_array"]=""



# shell_cli_metaflag_property_validate_short metaflag 'short'.
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
shell_cli_metaflag_property_validate_short() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  if [[ "$fval" =~ ^(h|itr)$ ]]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'h' and 'itr' are reserved."
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _long="${__assoc["long"]}"

  if [ "$fval" = "$_long" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be the same as 'long' ( short='$fval' )."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_short checks whether the input flag 
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
shell_cli_metaflag_check_input_short() {
  # This check should never be performed.
  # It is included here solely as a placeholder.
  local inputVal="$1"
  local ruleVal="$2"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'short'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}