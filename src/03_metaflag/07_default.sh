#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/07_default.sh
# DESCRIPTION: defines the fallback value automatically assigned if the user 
#   omits the flag. Core compiler rules reject schemas where required is true 
#   (1) and a default is simultaneously set.
# ==============================================================================

declare -gA METAFLAG_default=()
METAFLAG_default["short"]=""
METAFLAG_default["long"]="default"
METAFLAG_default["type"]="string"
METAFLAG_default["array"]="0"
METAFLAG_default["assoc"]="0"
METAFLAG_default["required"]="0"
METAFLAG_default["default"]=""
METAFLAG_default["enum"]=""
METAFLAG_default["assoc_keys"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""



# shell_cli_metaflag_validate_default metaflag 'default'.
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
shell_cli_metaflag_validate_default() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  local -n __assoc="${fassoc}"
  local _required="${__assoc["required"]}"

  if [ "$fval" != "" ] && [ "$_required" = "1" ]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi

  return 0
}
