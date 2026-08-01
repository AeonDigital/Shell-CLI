#!/usr/bin/env bash

declare -gA METAFLAG_required=()
METAFLAG_required["long"]="required"
METAFLAG_required["short"]=""
METAFLAG_required["type"]="bool"
METAFLAG_required["accept_values"]=""

METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""

METAFLAG_required["default"]="0"
METAFLAG_required["required"]=false

METAFLAG_required["normalize"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""

METAFLAG_required["is_array"]=false
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""

METAFLAG_required["is_assoc"]=false
METAFLAG_required["required_keys"]=""





# shell_cli_metaflag_property_validate_required - validate metaflag 'required'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'required' property is explicitly defined.
# - Rejects empty values (since 'required' must be either true/false).
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value is non-empty).
# - 1: validation failure (value is empty).
shell_cli_metaflag_property_validate_required() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_required - check input for metaflag 'required'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Behavior:
# - Validates whether a required flag has been provided.
# - If 'ruleVal' = "1" (true) and 'inputVal' is empty, validation fails:
#   * Stores the error message "cannot be empty or omitted" in
#     'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
#   * Returns error code 1.
# - If input is present or the flag is not required, stores the user-provided
#   value in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 0: validation success (input provided or flag not required).
# - 1: validation failure (flag marked as required but input omitted).
shell_cli_metaflag_check_input_required() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${inputVal}" = "" ] && [ "${ruleVal}" = "1" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="cannot be empty or omitted"
    return 1
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
