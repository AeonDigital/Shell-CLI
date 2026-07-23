#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/12_normalize.sh
# DESCRIPTION: registers the normalization method for the input value by 
#   pointing to a normalization function.
# ==============================================================================

declare -gA METAFLAG_normalize=()
METAFLAG_normalize["long"]="normalize"
METAFLAG_normalize["short"]=""
METAFLAG_normalize["description"]="Specifies a function responsible for normalizing the value before validation."
METAFLAG_normalize["tipinput"]=""
METAFLAG_normalize["type"]="function"
METAFLAG_normalize["enum"]=""

METAFLAG_normalize["required"]=false
METAFLAG_normalize["default"]=""

METAFLAG_normalize["array"]=false
METAFLAG_normalize["assoc"]=false
METAFLAG_normalize["assoc_keys"]=""

METAFLAG_normalize["normalize"]=""
METAFLAG_normalize["validate"]=""
METAFLAG_normalize["transform"]=""
METAFLAG_normalize["regex"]=""

METAFLAG_normalize["min"]=""
METAFLAG_normalize["max"]=""
METAFLAG_normalize["min_array"]=""
METAFLAG_normalize["max_array"]=""



# shell_cli_metaflag_property_validate_normalize metaflag 'normalize'.
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
shell_cli_metaflag_property_validate_normalize() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  if ! declare -f "$fval" >/dev/null; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="normalize function does not exist ( fn='${fval}' )."
    return 1
  fi

  return 0
}
