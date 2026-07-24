#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/10_assoc.sh
# DESCRIPTION: declares whether the flag parameter operates as an associative 
#   map. Accepts a global variable name pointer or an inline JSON object 
#   sequence.
# ==============================================================================

declare -gA METAFLAG_assoc=()
METAFLAG_assoc["long"]="assoc"
METAFLAG_assoc["short"]=""
METAFLAG_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_assoc["tipinput"]=""
METAFLAG_assoc["type"]="bool"
METAFLAG_assoc["enum"]=""

METAFLAG_assoc["required"]=false
METAFLAG_assoc["default"]="0"

METAFLAG_assoc["array"]=false
METAFLAG_assoc["assoc"]=false
METAFLAG_assoc["assoc_keys"]=""

METAFLAG_assoc["normalize"]=""
METAFLAG_assoc["validate"]=""
METAFLAG_assoc["transform"]=""
METAFLAG_assoc["regex"]=""

METAFLAG_assoc["min"]=""
METAFLAG_assoc["max"]=""
METAFLAG_assoc["min_array"]=""
METAFLAG_assoc["max_array"]=""



# shell_cli_metaflag_property_validate_assoc metaflag 'assoc'.
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
shell_cli_metaflag_property_validate_assoc() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _array="${__assoc["array"]}"

  if [ "$fval" = "1" ] && [ "$_array" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'assoc=true' and 'array=true' simultaneously."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_assoc checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed.
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      If the provided value is a string compatible with the assoc type, it 
#      will be deserialized and stored in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC'; 
#      at the same time, its re-serialized value will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'. Furthermore, the declaration 
#      order of the associative array keys will be preserved in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER'.
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_assoc() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()

  if [ "$inputVal" = "" ] || [ "$ruleVal" = "" ]; then
    return 0
  fi

  local str_declare=$(declare -p "$inputVal" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -A" ]]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="$inputVal"
    return 0
  fi

  shell_cli_parse_sjson_to_assoc "$inputVal"
  if [ "$?" != "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[0]}"
    return 1
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING}"

    local k=""
    local v=""
    for k in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC[@]}"; do
      v="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[$k]}"
      SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC["$k"]="$v"
    done

    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=("${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[@]}")
  fi

  return 0
}
