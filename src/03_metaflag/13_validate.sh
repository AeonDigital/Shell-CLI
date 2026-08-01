#!/usr/bin/env bash

declare -gA METAFLAG_validate=()
METAFLAG_validate["long"]="validate"
METAFLAG_validate["short"]=""
METAFLAG_validate["type"]="function"
METAFLAG_validate["accept_values"]=""

METAFLAG_validate["description"]="Pointer to indexed array with all validate functions to call for this value."
METAFLAG_validate["tipinput"]=""

METAFLAG_validate["default"]=""
METAFLAG_validate["required"]=false

METAFLAG_validate["normalize"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""

METAFLAG_validate["is_array"]=true
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""

METAFLAG_validate["is_assoc"]=false
METAFLAG_validate["required_keys"]=""





# shell_cli_metaflag_property_validate_validate - validate metaflag 'validate'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'validate' property points to a valid indexed array of functions.
# - Accepts empty values (since 'validate' is optional).
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
shell_cli_metaflag_property_validate_validate() {
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

  local -n ref_validate="${fval}"
  local fn_validate=""
  for fn_validate in "${ref_validate[@]}"; do
    if ! declare -f "${fn_validate}" >/dev/null; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="validation function does not exist ( fn='${fn_validate}' )."
      return 1
    fi
  done

  return 0
}



# shell_cli_metaflag_check_input_validate - check input for metaflag 'validate'.
#
# Arguments:
# - inputVal: value provided by user input (normalized and validated by type).
# - typeVal: type of value.
# - ruleVal: current value of this property (pointer to indexed array of functions).
#
# Behavior:
# - Executes each validator function listed in the 'validate' array against the input value.
# - Each function is called with 'inputVal' as its sole argument.
# - If any function returns 1 (failure), validation stops immediately:
#   * Stores an error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
#     indicating which function failed.
#   * Returns error code 1.
# - If all functions succeed (return 0), stores the original input in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 0: validation success (all functions passed).
# - 1: validation failure (at least one function failed).
shell_cli_metaflag_check_input_validate() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local -n ref_validate="${ruleVal}"
  local fn_validate=""
  for fn_validate in "${ref_validate[@]}"; do
    if ! "${fn_validate}" "${inputVal}"; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="validation failed in function '${fn_validate}' ( value='${inputVal}' )."
      return 1
    fi
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
