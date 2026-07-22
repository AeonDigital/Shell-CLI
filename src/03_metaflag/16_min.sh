#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/16_min.sh
# DESCRIPTION: enforces the minimum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_min=()
METAFLAG_min["long"]="min"
METAFLAG_min["short"]=""
METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""
METAFLAG_min["type"]="string"
METAFLAG_min["enum"]=""

METAFLAG_min["required"]=false
METAFLAG_min["default"]=""

METAFLAG_min["array"]=false
METAFLAG_min["assoc"]=false
METAFLAG_min["assoc_keys"]=""

METAFLAG_min["normalize"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""
METAFLAG_min["regex"]=""

METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""



# shell_cli_metaflag_validate_min metaflag 'min'.
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
shell_cli_metaflag_validate_min() {
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""
  
  if ! shell_cli_metaflag_property_cross_validate_min_max "$1" "$2"; then
    return 1
  fi

  return 0
}
