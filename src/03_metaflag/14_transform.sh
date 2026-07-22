#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/14_transform.sh
# DESCRIPTION: captures a JSON array of downstream transformation function 
#   names. Invoked only after validation succeeds and before the final parsed 
#   value is stored.
# ==============================================================================

declare -gA METAFLAG_transform=()
METAFLAG_transform["long"]="transform"
METAFLAG_transform["short"]=""
METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""
METAFLAG_transform["type"]="function"
METAFLAG_transform["enum"]=""

METAFLAG_transform["required"]=false
METAFLAG_transform["default"]=""

METAFLAG_transform["array"]=true
METAFLAG_transform["assoc"]=false
METAFLAG_transform["assoc_keys"]=""

METAFLAG_transform["normalize"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""
METAFLAG_transform["regex"]=""

METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""



# shell_cli_metaflag_validate_transform metaflag 'transform'.
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
shell_cli_metaflag_validate_transform() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  local str_declare=$(declare -p "$fval" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
    SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an indexed array (declare -a)."
    return 1
  fi

  local -n ref_transform="$fval"
  for fn_transform in "${ref_transform[@]}"; do
    if ! declare -f "$fn_transform" >/dev/null; then
      SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE="transform function does not exist ( fn='${fn_transform}' )."
      return 1
    fi
  done

  return 0
}

