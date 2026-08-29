#!/usr/bin/env bash

# 
# METAFLAG 'max_array'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_max_array=()
METAFLAG_max_array["long"]="max_array"
METAFLAG_max_array["short"]=""
METAFLAG_max_array["type"]="int"
METAFLAG_max_array["accept_values"]=""

METAFLAG_max_array["description"]="Maximum allowable element count within a validated array collection."
METAFLAG_max_array["tipinput"]=""

METAFLAG_max_array["default"]=""
METAFLAG_max_array["required"]=false

METAFLAG_max_array["normalize"]=""
METAFLAG_max_array["min"]=""
METAFLAG_max_array["max"]=""
METAFLAG_max_array["validate"]=""
METAFLAG_max_array["transform"]=""
METAFLAG_max_array["regex"]=""

METAFLAG_max_array["is_array"]=false
METAFLAG_max_array["min_array"]=""
METAFLAG_max_array["max_array"]=""

METAFLAG_max_array["is_assoc"]=false
METAFLAG_max_array["required_keys"]=""





# shell_cli_metaflag_property_validate_max_array — validate structural integrity
# of this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_max_array() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _array="${__assoc["is_array"]}"

  if [ "${_array}" = "0" ] &&  [ "${fval}" != "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'max_array' for a 'is_array=false' flag."
    return 1
  fi

  if ! shell_cli_metaflag_property_cross_validate_min_array_max_array "${fval}" "${fassoc}"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_max_array — runtime input check placeholder for
# this metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_max_array() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""


  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local -n inputArrayValues="${inputVal}"
  if [ "${#inputArrayValues[@]}" -gt "${ruleVal}" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="collection violates maximum item count; ( max_array: '${ruleVal}' )"
    return 1
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
