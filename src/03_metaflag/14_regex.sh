#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/14_regex.sh
# DESCRIPTION: provisions an optional regular expression verification 
#   constraint pattern. Evaluates whether incoming values perfectly satisfy 
#   native Bash or grep pattern criteria.
# ==============================================================================

declare -gA METAFLAG_regex=()
METAFLAG_regex["long"]="regex"
METAFLAG_regex["short"]=""
METAFLAG_regex["type"]="string"
METAFLAG_regex["array"]=false
METAFLAG_regex["assoc"]=false
METAFLAG_regex["required"]=false
METAFLAG_regex["default"]=""
METAFLAG_regex["enum"]=""
METAFLAG_regex["assoc_keys"]=""
METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""
METAFLAG_regex["regex"]=""
METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""



# shell_cli_metaflag_validate_regex metaflag 'regex'.
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
shell_cli_metaflag_validate_regex() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" != "" ]; then
    ( [[ "" =~ $fval ]] ) 2>/dev/null
    local exit_status=$?

    if [ $exit_status -eq 2 ]; then
      SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="invalid regular expression ( regex='$fval' )."
      return 1
    fi
  fi

  return 0
}
