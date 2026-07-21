#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/05_assoc.sh
# DESCRIPTION: declares whether the flag parameter operates as an associative 
#   map. Accepts a global variable name pointer or an inline JSON object 
#   sequence.
# ==============================================================================

declare -gA METAFLAG_assoc=()
METAFLAG_assoc["short"]=""
METAFLAG_assoc["long"]="assoc"
METAFLAG_assoc["type"]="bool"
METAFLAG_assoc["array"]="0"
METAFLAG_assoc["assoc"]="0"
METAFLAG_assoc["required"]="0"
METAFLAG_assoc["default"]="0"
METAFLAG_assoc["enum"]=""
METAFLAG_assoc["assoc_keys"]=""
METAFLAG_assoc["min"]=""
METAFLAG_assoc["max"]=""
METAFLAG_assoc["min_array"]=""
METAFLAG_assoc["max_array"]=""
METAFLAG_assoc["regex"]=""
METAFLAG_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_assoc["tipinput"]=""
METAFLAG_assoc["validate"]=""
METAFLAG_assoc["transform"]=""



# shell_cli_metaflag_validate_assoc metaflag 'assoc'.
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
shell_cli_metaflag_validate_assoc() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _array="${__assoc["array"]}"

  if [ "$fval" = "1" ] && [ "$_array" = "1" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot declare 'assoc=true' and 'array=true' simultaneously."
    return 1
  fi

  return 0
}
