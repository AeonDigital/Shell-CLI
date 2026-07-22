#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/11_max.sh
# DESCRIPTION: enforces the maximum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_max=()
METAFLAG_max["long"]="max"
METAFLAG_max["short"]=""
METAFLAG_max["type"]="string"
METAFLAG_max["array"]=false
METAFLAG_max["assoc"]=false
METAFLAG_max["required"]=false
METAFLAG_max["default"]=""
METAFLAG_max["enum"]=""
METAFLAG_max["assoc_keys"]=""
METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""
METAFLAG_max["regex"]=""
METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""



# shell_cli_metaflag_validate_max metaflag 'max'.
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
shell_cli_metaflag_validate_max() {
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if ! shell_cli_metaflag_property_cross_validate_min_max "$1" "$2"; then
    return 1
  fi

  return 0
}
