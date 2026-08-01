#!/usr/bin/env bash

declare -gA METAFLAG_description=()
METAFLAG_description["long"]="description"
METAFLAG_description["short"]=""
METAFLAG_description["type"]="text"
METAFLAG_description["accept_values"]=""

METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""

METAFLAG_description["default"]=""
METAFLAG_description["required"]=true

METAFLAG_description["normalize"]=""
METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["regex"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""

METAFLAG_description["is_array"]=false
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""

METAFLAG_description["is_assoc"]=false
METAFLAG_description["required_keys"]=""





# shell_cli_metaflag_property_validate_description - validate metaflag 'description'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'description' property is properly defined.
# - Rejects empty values (since 'description' is required).
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value can be used as description).
# - 1: validation failure (value is empty).
shell_cli_metaflag_property_validate_description() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_description - check input for metaflag 'description'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Behavior:
# - This function is a placeholder only; the 'description' metaflag does not
#   accept user input at runtime.
# - If invoked, it always fails with an error message indicating that
#   validation is inapplicable.
# - Stores the error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - Stores a sentinel value "!ERR" in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 1: always invalid (inapplicable check).
shell_cli_metaflag_check_input_description() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'description'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}