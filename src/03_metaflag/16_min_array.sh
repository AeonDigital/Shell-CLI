#!/usr/bin/env bash

declare -gA METAFLAG_min_array=()
METAFLAG_min_array["long"]="min_array"
METAFLAG_min_array["short"]=""
METAFLAG_min_array["type"]="int"
METAFLAG_min_array["accept_values"]=""

METAFLAG_min_array["description"]="Minimum allowable element count within a validated array collection."
METAFLAG_min_array["tipinput"]=""

METAFLAG_min_array["default"]=""
METAFLAG_min_array["required"]=false

METAFLAG_min_array["normalize"]=""
METAFLAG_min_array["min"]=""
METAFLAG_min_array["max"]=""
METAFLAG_min_array["regex"]=""
METAFLAG_min_array["validate"]=""
METAFLAG_min_array["transform"]=""

METAFLAG_min_array["is_array"]=false
METAFLAG_min_array["min_array"]=""
METAFLAG_min_array["max_array"]=""

METAFLAG_min_array["is_assoc"]=false
METAFLAG_min_array["required_keys"]=""





# shell_cli_metaflag_property_validate_min_array - validate metaflag 'min_array'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'min_array' property is only defined when 'is_array=true'.
# - If 'is_array=false' and 'min_array' is set, validation fails.
# - Delegates consistency check to 'shell_cli_metaflag_property_cross_validate_min_array_max_array',
#   which ensures that min_array ≤ max_array.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (property consistent with is_array and max_array).
# - 1: validation failure (defined for non-array flag or inconsistent with max_array).
shell_cli_metaflag_property_validate_min_array() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _array="${__assoc["is_array"]}"

  if [ "${_array}" = "0" ] &&  [ "${fval}" != "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'min_array' for a 'is_array=false' flag."
    return 1
  fi

  if ! shell_cli_metaflag_property_cross_validate_min_array_max_array "${fval}" "${fassoc}"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_min_array - check input for metaflag 'min_array'.
#
# Arguments:
# - inputVal: array name containing values provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (minimum number of elements).
#
# Behavior:
# - Validates whether the input array meets the minimum element count.
# - If input is empty or 'ruleVal=0', no validation is applied.
# - Otherwise, dereferences the array name and counts its elements.
# - If the number of elements < min_array, validation fails:
#   * Stores an error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
#   * Returns error code 1.
# - On success, the input array is accepted unchanged.
#
# Returns:
# - 0: validation success (array meets minimum size or rule not enforced).
# - 1: validation failure (array has fewer elements than min_array).
shell_cli_metaflag_check_input_min_array() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""


  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    return 0
  fi

  local -n inputArrayValues="${inputVal}"
  if [ "${#inputArrayValues[@]}" -lt "${ruleVal}" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="collection violates minimum item count; ( min_array: '${ruleVal}' )"
    return 1
  fi

  return 0
}
