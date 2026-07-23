#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/11_assoc_keys.sh
# DESCRIPTION: specifies a list of keys that MUST be present in the passed 
#   value, provided it is not an empty associative array
#   Operates exclusively when assoc is active (1) to enforce field presence.
# ==============================================================================

declare -gA METAFLAG_assoc_keys=()
METAFLAG_assoc_keys["long"]="assoc_keys"
METAFLAG_assoc_keys["short"]=""
METAFLAG_assoc_keys["description"]="Pointer to array or a JSON-array string with the required 'keys'."
METAFLAG_assoc_keys["tipinput"]=""
METAFLAG_assoc_keys["type"]="text"
METAFLAG_assoc_keys["enum"]=""

METAFLAG_assoc_keys["required"]=false
METAFLAG_assoc_keys["default"]=""

METAFLAG_assoc_keys["array"]=true
METAFLAG_assoc_keys["assoc"]=false
METAFLAG_assoc_keys["assoc_keys"]=""

METAFLAG_assoc_keys["normalize"]=""
METAFLAG_assoc_keys["validate"]=""
METAFLAG_assoc_keys["transform"]=""
METAFLAG_assoc_keys["regex"]=""

METAFLAG_assoc_keys["min"]=""
METAFLAG_assoc_keys["max"]=""
METAFLAG_assoc_keys["min_array"]=""
METAFLAG_assoc_keys["max_array"]=""



# shell_cli_metaflag_property_validate_assoc_keys metaflag 'assoc_keys'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_property_validate_assoc_keys() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["assoc"]}"

  if [ "$_assoc" = "0" ]; then
    if [ "$fval" != "" ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'assoc_keys' for a 'assoc=false' flag."
      return 1
    fi
  else
    if [ "$fval" != "" ]; then
      local str_declare=$(declare -p "$fval" 2>/dev/null)
      if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
        SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an indexed array (declare -a)."
        return 1
      fi
    fi
  fi

  return 0
}

