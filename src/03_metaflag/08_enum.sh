#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/08_enum.sh
# DESCRIPTION: specifies a JSON array with the accepted values or aliases.
#   Mandatory if type is set to 'enum'. Rejects definitions that fail alias 
#   syntax rules.
# ==============================================================================

declare -gA METAFLAG_enum=()
METAFLAG_enum["short"]=""
METAFLAG_enum["long"]="enum"
METAFLAG_enum["type"]="string"
METAFLAG_enum["array"]="1"
METAFLAG_enum["assoc"]="0"
METAFLAG_enum["required"]="0"
METAFLAG_enum["default"]=""
METAFLAG_enum["enum"]=""
METAFLAG_enum["assoc_keys"]=""
METAFLAG_enum["min"]=""
METAFLAG_enum["max"]=""
METAFLAG_enum["min_array"]=""
METAFLAG_enum["max_array"]=""
METAFLAG_enum["regex"]=""
METAFLAG_enum["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_enum["tipinput"]=""
METAFLAG_enum["validate"]=""
METAFLAG_enum["transform"]=""



# shell_cli_metaflag_validate_enum metaflag 'enum'.
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
shell_cli_metaflag_validate_enum() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _type="${__assoc["type"]}"

  if [ "$_type" != "enum" ]; then
    if [ "$fval" != "" ]; then
      SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="cannot define 'enum' for a non 'type=$_type' flag."
      return 1
    fi
  else
    if [ "$fval" = "" ]; then
      SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="flags with 'type=enum' must declare 'enum' property."
      return 1
    fi

    local str_declare=$(declare -p "$fval" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an associative array (declare -A)."
      return 1
    fi
  fi

  return 0
}
