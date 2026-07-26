#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/15_is_array.sh
# DESCRIPTION: declares whether the flag parameter accepts a structured 
#   collection. In this case, it must be a string in JSON array format.
# ==============================================================================

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





# shell_cli_metaflag_property_validate_is_array — validate metaflag 'is_array'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'is_array' property is explicitly defined (cannot be empty).
# - Checks consistency with 'is_assoc':
#   * If 'is_array=true' and 'is_assoc=true' simultaneously, validation fails.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value non-empty and consistent with 'is_assoc').
# - 1: validation failure (empty or conflicting configuration).
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



# shell_cli_metaflag_check_input_is_array — check input for metaflag 'is_array'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Behavior:
# - Validates whether the input should be treated as an array.
# - If 'ruleVal=0' (false) or input is empty, no validation is applied.
# - If input is already an indexed array, passes through unchanged.
# - Otherwise, attempts to parse the input string as a serialized array
#   (e.g., JSON-like format) using 'shell_cli_parse_sarray_to_array'.
# - On parse failure, stores the parser's error message in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - On success:
#   * Stores the re-serialized array string in
#     'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#   * Stores the deserialized array elements in
#     'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY'.
#
# Returns:
# - 0: validation success (input accepted as array).
# - 1: validation failure (input not compatible with array format).
shell_cli_metaflag_check_input_is_array() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()

  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    return 0
  fi

  if shell_cli_utils_array_is_indexed "${inputVal}"; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  shell_cli_parse_sarray_to_array "${inputVal}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[0]}"
    return 1
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING}"
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=("${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[@]}")
  fi

  return 0
}
