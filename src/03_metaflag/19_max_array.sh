#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/19_max_array.sh
# DESCRIPTION: defines the maximum number of elements allowed inside a 
#   collection. This evaluation is optional and operates exclusively when the 
#   array attribute is active (1).
# ==============================================================================

declare -gA METAFLAG_max_array=()
METAFLAG_max_array["long"]="max_array"
METAFLAG_max_array["short"]=""
METAFLAG_max_array["description"]="Maximum allowable element count within a validated array collection."
METAFLAG_max_array["tipinput"]=""
METAFLAG_max_array["type"]="int"
METAFLAG_max_array["enum"]=""

METAFLAG_max_array["required"]=false
METAFLAG_max_array["default"]=""

METAFLAG_max_array["array"]=false
METAFLAG_max_array["assoc"]=false
METAFLAG_max_array["assoc_keys"]=""

METAFLAG_max_array["normalize"]=""
METAFLAG_max_array["validate"]=""
METAFLAG_max_array["transform"]=""
METAFLAG_max_array["regex"]=""

METAFLAG_max_array["min"]=""
METAFLAG_max_array["max"]=""
METAFLAG_max_array["min_array"]=""
METAFLAG_max_array["max_array"]=""



# shell_cli_metaflag_validate_max_array metaflag 'max_array'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_validate_max_array() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _array="${__assoc["array"]}"

  if [ "$_array" = "0" ] &&  [ "$fval" != "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot define 'max_array' for a 'array=false' flag."
    return 1
  fi

  if ! shell_cli_metaflag_property_cross_validate_min_array_max_array "$fval" "$fassoc"; then
    return 1
  fi

  return 0
}
