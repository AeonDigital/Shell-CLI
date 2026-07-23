#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/10_assoc.sh
# DESCRIPTION: declares whether the flag parameter operates as an associative 
#   map. Accepts a global variable name pointer or an inline JSON object 
#   sequence.
# ==============================================================================

declare -gA METAFLAG_assoc=()
METAFLAG_assoc["long"]="assoc"
METAFLAG_assoc["short"]=""
METAFLAG_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_assoc["tipinput"]=""
METAFLAG_assoc["type"]="bool"
METAFLAG_assoc["enum"]=""

METAFLAG_assoc["required"]=false
METAFLAG_assoc["default"]="0"

METAFLAG_assoc["array"]=false
METAFLAG_assoc["assoc"]=false
METAFLAG_assoc["assoc_keys"]=""

METAFLAG_assoc["normalize"]=""
METAFLAG_assoc["validate"]=""
METAFLAG_assoc["transform"]=""
METAFLAG_assoc["regex"]=""

METAFLAG_assoc["min"]=""
METAFLAG_assoc["max"]=""
METAFLAG_assoc["min_array"]=""
METAFLAG_assoc["max_array"]=""



# shell_cli_metaflag_property_validate_assoc metaflag 'assoc'.
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
shell_cli_metaflag_property_validate_assoc() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _array="${__assoc["array"]}"

  if [ "$fval" = "1" ] && [ "$_array" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'assoc=true' and 'array=true' simultaneously."
    return 1
  fi

  return 0
}
