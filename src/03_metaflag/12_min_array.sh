#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/12_min_array.sh
# DESCRIPTION: defines the minimum number of elements required inside a 
#   collection. This evaluation is optional and operates exclusively when the 
#   array attribute is active (1).
# ==============================================================================

declare -gA METAFLAG_min_array=()
METAFLAG_min_array["long"]="min_array"
METAFLAG_min_array["short"]=""
METAFLAG_min_array["type"]="int"
METAFLAG_min_array["array"]=false
METAFLAG_min_array["assoc"]=false
METAFLAG_min_array["required"]=false
METAFLAG_min_array["default"]=""
METAFLAG_min_array["enum"]=""
METAFLAG_min_array["assoc_keys"]=""
METAFLAG_min_array["min"]=""
METAFLAG_min_array["max"]=""
METAFLAG_min_array["min_array"]=""
METAFLAG_min_array["max_array"]=""
METAFLAG_min_array["regex"]=""
METAFLAG_min_array["description"]="Minimum allowable element count within a validated array collection."
METAFLAG_min_array["tipinput"]=""
METAFLAG_min_array["validate"]=""
METAFLAG_min_array["transform"]=""



# shell_cli_metaflag_validate_min_array metaflag 'min_array'.
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
shell_cli_metaflag_validate_min_array() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _array="${__assoc["array"]}"

  if [ "$_array" = "0" ] &&  [ "$fval" != "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot define 'min_array' for a 'array=false' flag."
    return 1
  fi

  if ! shell_cli_metaflag_cross_validate_min_array_max_array "$fval" "$fassoc"; then
    return 1
  fi

  return 0
}
