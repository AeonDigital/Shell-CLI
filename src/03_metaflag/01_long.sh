#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/01_long.sh
# DESCRIPTION: defines the canonical long name identifier for a command-line 
#   flag. It acts as a double-dash option (e.g., --scope) and maps directly to 
#   parsed storage keys.
# ==============================================================================

declare -gA METAFLAG_long=()
METAFLAG_long["long"]="long"
METAFLAG_long["short"]=""
METAFLAG_long["type"]="string"
METAFLAG_long["array"]="0"
METAFLAG_long["assoc"]="0"
METAFLAG_long["required"]="1"
METAFLAG_long["default"]=""
METAFLAG_long["enum"]=""
METAFLAG_long["assoc_keys"]=""
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="32"
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""



# shell_cli_metaflag_validate_long metaflag 'long'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Note:
# If validation is successful, it adds a '__cross_min_max' key indicating that 
# this validation has already been performed.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_validate_long() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  if [[ "$fval" =~ ^(help|interactive)$ ]]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="names 'help' and 'interactive' are reserved."
    return 1
  fi

  return 0
}