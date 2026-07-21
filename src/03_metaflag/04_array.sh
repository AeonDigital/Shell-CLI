#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shelmetaflags/define/04_array.sh
# DESCRIPTION: declares whether the flag parameter accepts a structured 
#   collection. If active (1), the engine parses the payload as a JSON array 
#   and validates every item.
# ==============================================================================

declare -gA METAFLAG_array=()
METAFLAG_array["short"]=""
METAFLAG_array["long"]="array"
METAFLAG_array["type"]="bool"
METAFLAG_array["array"]="0"
METAFLAG_array["assoc"]="0"
METAFLAG_array["required"]="0"
METAFLAG_array["default"]="0"
METAFLAG_array["enum"]=""
METAFLAG_array["assoc_keys"]=""
METAFLAG_array["min"]=""
METAFLAG_array["max"]=""
METAFLAG_array["min_array"]=""
METAFLAG_array["max_array"]=""
METAFLAG_array["regex"]=""
METAFLAG_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_array["tipinput"]=""
METAFLAG_array["validate"]=""
METAFLAG_array["transform"]=""



# shell_cli_metaflag_validate_array metaflag 'array'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
shell_cli_metaflag_validate_array() {
  local fval="$1"
  local fassoc="$2"

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["assoc"]}"

  if [ "$fval" = "1" ] && [ "$_assoc" = "1" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot declare 'array=true' and 'assoc=true' simultaneously."
    return 1
  fi

  return 0
}
