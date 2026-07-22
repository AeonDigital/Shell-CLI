#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/03_description.sh
# DESCRIPTION: maps the essential human documentation text used to render help 
#   modules. Mandatory framework constraint ensuring zero undocumented features 
#   bypass compiler loops.
# ==============================================================================

declare -gA METAFLAG_description=()
METAFLAG_description["long"]="description"
METAFLAG_description["short"]=""
METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""
METAFLAG_description["type"]="text"
METAFLAG_description["enum"]=""

METAFLAG_description["required"]=true
METAFLAG_description["default"]=""

METAFLAG_description["array"]=false
METAFLAG_description["assoc"]=false
METAFLAG_description["assoc_keys"]=""

METAFLAG_description["normalize"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""
METAFLAG_description["regex"]=""

METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""



# shell_cli_metaflag_validate_description metaflag 'description'.
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
shell_cli_metaflag_validate_description() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}
