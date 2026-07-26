#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/14_transform.sh
# DESCRIPTION: It allows for the configuration of a series of transformation 
#   functions to be applied to the received value after its validation.
# ==============================================================================

declare -gA METAFLAG_transform=()
METAFLAG_transform["long"]="transform"
METAFLAG_transform["short"]=""
METAFLAG_transform["type"]="function"
METAFLAG_transform["accept_values"]=""

METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""

METAFLAG_transform["default"]=""
METAFLAG_transform["required"]=false

METAFLAG_transform["normalize"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""

METAFLAG_transform["is_array"]=true
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""

METAFLAG_transform["is_assoc"]=false
METAFLAG_transform["required_keys"]=""





# shell_cli_metaflag_property_validate_transform — validate metaflag 'transform'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'transform' property points to a valid indexed array of functions.
# - Accepts empty values (since 'transform' is optional).
# - Uses 'shell_cli_utils_array_is_indexed' to confirm that the pointer refers to
#   an indexed array (declare -a).
# - Iterates through the array and checks that each listed function is declared
#   in the current shell environment.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (array exists and all functions are declared).
# - 1: validation failure (not an indexed array or function missing).
shell_cli_metaflag_property_validate_transform() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if ! shell_cli_utils_array_is_indexed "${fval}"; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
    return 1
  fi

  local -n ref_transform="${fval}"
  local fn_transform=""
  for fn_transform in "${ref_transform[@]}"; do
    if ! declare -f "$fn_transform" >/dev/null; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="transform function does not exist ( fn='${fn_transform}' )."
      return 1
    fi
  done

  return 0
}



# shell_cli_metaflag_check_input_transform — check input for metaflag 'transform'.
#
# Arguments:
# - inputVal: value provided by user input (already validated).
# - typeVal: type of value.
# - ruleVal: current value of this property (pointer to indexed array of functions).
#
# Behavior:
# - Executes each transformation function listed in the 'transform' array sequentially.
# - Each function is called with the current value as its sole argument.
# - Captures the function's printed output as the new transformed value.
# - Checks the function's exit code:
#   * 0: success → updates the value and continues to the next function.
#   * 1: failure → stops immediately, stores an error message in
#     'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE', and returns error code 1.
# - If all functions succeed, stores the final transformed value in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 0: transformation success (all functions applied).
# - 1: transformation failure (at least one function failed).
shell_cli_metaflag_check_input_transform() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local currentVal="${inputVal}"
  local -n ref_transform="${ruleVal}"
  local fn_transform=""
  for fn_transform in "${ref_transform[@]}"; do
    local newVal="$("${fn_transform}" "${currentVal}")"
    local exitCode=$?

    if [ ${exitCode} -ne 0 ]; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="transformation failed in function '${fn_transform}' ( value='${currentVal}' )."
      return 1
    fi

    currentVal="${newVal}"
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${currentVal}"
  return 0
}
