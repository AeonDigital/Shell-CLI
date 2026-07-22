#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/03_type.sh
# DESCRIPTION: defines the primitive, structured, or system classification of 
#   the flag data. It instructs the core engine which specialized native 
#   validation routine to trigger.
# ==============================================================================

declare -gA METAFLAG_type=()
METAFLAG_type["long"]="type"
METAFLAG_type["short"]=""
METAFLAG_type["type"]="enum"
METAFLAG_type["array"]=false
METAFLAG_type["assoc"]=false
METAFLAG_type["required"]=true
METAFLAG_type["default"]=""
METAFLAG_type["enum"]="SHELL_CLI_TYPE"
METAFLAG_type["assoc_keys"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""



# shell_cli_metaflag_validate_type metaflag 'type'.
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
shell_cli_metaflag_validate_type() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  if [ "${SHELL_CLI_TYPE["$fval"]}" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="invalid definition ( type='$fval' )."
    return 1
  fi

  return 0
}