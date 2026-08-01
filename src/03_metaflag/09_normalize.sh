#!/usr/bin/env bash

declare -gA METAFLAG_normalize=()
METAFLAG_normalize["long"]="normalize"
METAFLAG_normalize["short"]=""
METAFLAG_normalize["type"]="function"
METAFLAG_normalize["accept_values"]=""

METAFLAG_normalize["description"]="Specifies a function responsible for normalizing the value before validation."
METAFLAG_normalize["tipinput"]=""

METAFLAG_normalize["default"]=""
METAFLAG_normalize["required"]=false

METAFLAG_normalize["normalize"]=""
METAFLAG_normalize["min"]=""
METAFLAG_normalize["max"]=""
METAFLAG_normalize["regex"]=""
METAFLAG_normalize["validate"]=""
METAFLAG_normalize["transform"]=""

METAFLAG_normalize["is_array"]=false
METAFLAG_normalize["min_array"]=""
METAFLAG_normalize["max_array"]=""

METAFLAG_normalize["is_assoc"]=false
METAFLAG_normalize["required_keys"]=""





# shell_cli_metaflag_property_validate_normalize - validate metaflag 'normalize'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'normalize' property points to a valid function name.
# - Accepts empty values (since 'normalize' is optional).
# - If a function name is provided, checks whether the function is declared
#   in the current shell environment.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value is empty or function exists).
# - 1: validation failure (function name provided but not found).
shell_cli_metaflag_property_validate_normalize() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if ! declare -f "${fval}" >/dev/null; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="normalize function does not exist ( fn='${fval}' )."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_normalize - check input for metaflag 'normalize'.
#
# Arguments:
# - inputVal: current value provided by user input.
# - typeVal: type of value (not used directly here).
# - ruleVal: name of the normalization function to invoke.
#
# Behavior:
# - If 'ruleVal' is empty, no normalization is applied and the input value is
#   passed through unchanged.
# - If 'ruleVal' points to a function:
#   * Calls the function with 'inputVal' as its sole argument.
#   * Captures the function's printed output as the normalized value.
#   * Checks the function's exit code:
#       - 0: success = stores the normalized value in
#         'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#       - 1: failure = stores the error message
#         "normalize function failed ( fn='ruleVal' )" in
#         'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
#
# Returns:
# - 0: normalization success (value updated).
# - 1: normalization failure (function returned error).
shell_cli_metaflag_check_input_normalize() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local newVal=$("${ruleVal}" "${inputVal}")
  local exitCode=$?

  if [ ${exitCode} = "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${newVal}"
    return 0
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="normalize function failed; ( fn='${ruleVal}'; value='${inputVal}' )"
    return 1
  fi
}
