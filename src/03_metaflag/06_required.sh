#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/06_required.sh
# DESCRIPTION: declares whether the flag must be explicitly supplied by the 
#   user. If active (1), the framework automatically mandates a non-empty 
#   presence check.
# ==============================================================================

declare -gA METAFLAG_required=()
METAFLAG_required["long"]="required"
METAFLAG_required["short"]=""
METAFLAG_required["type"]="bool"
METAFLAG_required["array"]="0"
METAFLAG_required["assoc"]="0"
METAFLAG_required["required"]="0"
METAFLAG_required["default"]="0"
METAFLAG_required["enum"]=""
METAFLAG_required["assoc_keys"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""



# shell_cli_metaflag_validate_required metaflag 'required'.
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
shell_cli_metaflag_validate_required() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}
