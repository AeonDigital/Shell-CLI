#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/01_long.sh
# DESCRIPTION: defines the canonical long name identifier for a command-line 
#   flag. It acts as a double-dash option (e.g., --scope).
# ==============================================================================

declare -gA METAFLAG_long=()
METAFLAG_long["long"]="long"
METAFLAG_long["short"]=""
METAFLAG_long["type"]="string"
METAFLAG_long["accept_values"]=""

METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""

METAFLAG_long["default"]=""
METAFLAG_long["required"]=true

METAFLAG_long["normalize"]=""
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="32"
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""

METAFLAG_long["is_array"]=false
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""

METAFLAG_long["is_assoc"]=false
METAFLAG_long["required_keys"]=""





# shell_cli_metaflag_property_validate_long — validate metaflag 'long'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the canonical long name of a flag is structurally valid.
# - Rejects empty values.
# - Rejects reserved names: "help" and "interactive".
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value can be used as long flag name).
# - 1: validation failure (value cannot be used).
shell_cli_metaflag_property_validate_long() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  if [[ "${fval}" =~ ^(help|interactive)$ ]]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'help' and 'interactive' are reserved."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_long — check input for metaflag 'long'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Behavior:
# - This function is a placeholder only; the 'long' metaflag does not accept
#   user input at runtime.
# - If invoked, it always fails with an error message indicating that
#   validation is inapplicable.
# - Stores the error message in 'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - Stores a sentinel value "!ERR" in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 1: always invalid (inapplicable check).
shell_cli_metaflag_check_input_long() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'long'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}