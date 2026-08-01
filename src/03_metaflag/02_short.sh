#!/usr/bin/env bash

declare -gA METAFLAG_short=()
METAFLAG_short["long"]="short"
METAFLAG_short["short"]=""
METAFLAG_short["type"]="string"
METAFLAG_short["accept_values"]=""

METAFLAG_short["description"]="Short alphanumeric character alias for the flag (1 to 3 chars)."
METAFLAG_short["tipinput"]=""

METAFLAG_short["default"]=""
METAFLAG_short["required"]=false

METAFLAG_short["normalize"]=""
METAFLAG_short["min"]="1"
METAFLAG_short["max"]="3"
METAFLAG_short["regex"]="^[a-zA-Z0-9]+$"
METAFLAG_short["validate"]=""
METAFLAG_short["transform"]=""

METAFLAG_short["is_array"]=false
METAFLAG_short["min_array"]=""
METAFLAG_short["max_array"]=""

METAFLAG_short["is_assoc"]=false
METAFLAG_short["required_keys"]=""





# shell_cli_metaflag_property_validate_short - validate metaflag 'short'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the short alias for a flag is structurally valid.
# - Accepts empty values (since 'short' is optional).
# - Rejects reserved names: "h" and "itr".
# - Rejects values that are identical to the 'long' name of the same flag.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value can be used as short flag alias).
# - 1: validation failure (value cannot be used).
shell_cli_metaflag_property_validate_short() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if [[ "${fval}" =~ ^(h|itr)$ ]]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'h' and 'itr' are reserved."
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _long="${__assoc["long"]}"

  if [ "${fval}" = "${_long}" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be the same as 'long' ( short='${fval}' )."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_short - check input for metaflag 'short'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Behavior:
# - This function is a placeholder only; the 'short' metaflag does not accept
#   user input at runtime.
# - If invoked, it always fails with an error message indicating that
#   validation is inapplicable.
# - Stores the error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - Stores a sentinel value "!ERR" in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 1: always invalid (inapplicable check).
shell_cli_metaflag_check_input_short() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'short'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}