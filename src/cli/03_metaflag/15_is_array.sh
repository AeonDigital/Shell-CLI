#!/usr/bin/env bash

# 
# METAFLAG 'is_array'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_is_array=()
METAFLAG_is_array["long"]="is_array"
METAFLAG_is_array["short"]=""
METAFLAG_is_array["type"]="bool"
METAFLAG_is_array["accept_values"]=""

METAFLAG_is_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_is_array["tipinput"]=""

METAFLAG_is_array["default"]="0"
METAFLAG_is_array["required"]=false

METAFLAG_is_array["normalize"]=""
METAFLAG_is_array["min"]=""
METAFLAG_is_array["max"]=""
METAFLAG_is_array["regex"]=""
METAFLAG_is_array["validate"]=""
METAFLAG_is_array["transform"]=""

METAFLAG_is_array["is_array"]=false
METAFLAG_is_array["min_array"]=""
METAFLAG_is_array["max_array"]=""

METAFLAG_is_array["is_assoc"]=false
METAFLAG_is_array["required_keys"]=""





# shell_cli_metaflag_property_validate_is_array — validate structural integrity of
# this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_is_array() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["is_assoc"]}"

  if [ "${fval}" = "1" ] && [ "${_assoc}" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'is_array=true' and 'is_assoc=true' simultaneously."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_is_array — runtime input check placeholder for this
# metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_is_array() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()

  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  if shell_cli_utils_array_is_indexed "${inputVal}"; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  shell_cli_parse_sarray_to_array "${inputVal}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE}"
    return 1
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="SHELL_CLI_PARSE_SARRAY_TO_ARRAY"
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=("${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[@]}")
  fi

  return 0
}
