#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/18_is_assoc.sh
# DESCRIPTION: declares whether the flag parameter operates as an associative 
#   map. 
# ==============================================================================

declare -gA METAFLAG_is_assoc=()
METAFLAG_is_assoc["long"]="is_assoc"
METAFLAG_is_assoc["short"]=""
METAFLAG_is_assoc["type"]="bool"
METAFLAG_is_assoc["accept_values"]=""

METAFLAG_is_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_is_assoc["tipinput"]=""

METAFLAG_is_assoc["default"]="0"
METAFLAG_is_assoc["required"]=false

METAFLAG_is_assoc["normalize"]=""
METAFLAG_is_assoc["min"]=""
METAFLAG_is_assoc["max"]=""
METAFLAG_is_assoc["regex"]=""
METAFLAG_is_assoc["validate"]=""
METAFLAG_is_assoc["transform"]=""

METAFLAG_is_assoc["is_array"]=false
METAFLAG_is_assoc["min_array"]=""
METAFLAG_is_assoc["max_array"]=""

METAFLAG_is_assoc["is_assoc"]=false
METAFLAG_is_assoc["required_keys"]=""





# shell_cli_metaflag_property_validate_is_assoc metaflag 'is_assoc'.
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
shell_cli_metaflag_property_validate_is_assoc() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _array="${__assoc["is_array"]}"

  if [ "$fval" = "1" ] && [ "$_array" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'is_assoc=true' and 'is_array=true' simultaneously."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_is_assoc checks whether the input flag 
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
shell_cli_metaflag_check_input_is_assoc() {
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

  if shell_cli_utils_array_is_assoc "$inputVal"; then
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
