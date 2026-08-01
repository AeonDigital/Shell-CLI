#!/usr/bin/env bash

declare -gA METAFLAG_type=()
METAFLAG_type["long"]="type"
METAFLAG_type["short"]=""
METAFLAG_type["type"]="string"
METAFLAG_type["accept_values"]="SHELL_CLI_TYPE"

METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""

METAFLAG_type["default"]=""
METAFLAG_type["required"]=true

METAFLAG_type["normalize"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""

METAFLAG_type["is_array"]=false
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""

METAFLAG_type["is_assoc"]=false
METAFLAG_type["required_keys"]=""





# shell_cli_metaflag_property_validate_type - validate metaflag 'type'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the type assigned to a flag is valid and supported.
# - Rejects empty values (since 'type' is required).
# - Checks if the provided type exists in the global registry 'SHELL_CLI_TYPE'.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value is a supported type).
# - 1: validation failure (value is empty or not in SHELL_CLI_TYPE).
shell_cli_metaflag_property_validate_type() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_type - check input for metaflag 'type'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Behavior:
# - This function is a placeholder only; the 'type' metaflag does not accept
#   user input at runtime.
# - If invoked, it always fails with an error message indicating that
#   validation is inapplicable.
# - Stores the error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - Stores a sentinel value "!ERR" in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 1: always invalid (inapplicable check).
shell_cli_metaflag_check_input_type() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'type'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}