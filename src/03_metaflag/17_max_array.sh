#!/usr/bin/env bash

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





# shell_cli_metaflag_property_validate_max_array - validate metaflag 'max_array'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'max_array' property is only defined when 'is_array=true'.
# - If 'is_array=false' and 'max_array' is set, validation fails.
# - Delegates consistency check to 'shell_cli_metaflag_property_cross_validate_min_array_max_array',
#   which ensures that min_array ≤ max_array.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (property consistent with is_array and min_array).
# - 1: validation failure (defined for non-array flag or inconsistent with min_array).
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



# shell_cli_metaflag_check_input_max_array - check input for metaflag 'max_array'.
#
# Arguments:
# - inputVal: array name containing values provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (maximum number of elements).
#
# Behavior:
# - Validates whether the input array respects the maximum element count.
# - If input is empty or 'ruleVal=0', no validation is applied.
# - Otherwise, dereferences the array name and counts its elements.
# - If the number of elements > max_array, validation fails:
#   * Stores an error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
#   * Returns error code 1.
# - On success, the input array is accepted unchanged.
#
# Returns:
# - 0: validation success (array within maximum size or rule not enforced).
# - 1: validation failure (array exceeds maximum size).
shell_cli_metaflag_check_input_max_array() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""


  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    return 0
  fi

  local -n inputArrayValues="${inputVal}"
  if [ "${#inputArrayValues[@]}" -gt "${ruleVal}" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="collection violates maximum item count; ( max_array: '${ruleVal}' )"
    return 1
  fi

  return 0
}
