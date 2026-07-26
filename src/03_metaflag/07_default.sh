#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/07_default.sh
# DESCRIPTION: defines the fallback value automatically assigned if the user 
#   omits the flag.
# ==============================================================================

declare -gA METAFLAG_default=()
METAFLAG_default["long"]="default"
METAFLAG_default["short"]=""
METAFLAG_default["type"]="code"
METAFLAG_default["accept_values"]=""

METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""

METAFLAG_default["default"]=""
METAFLAG_default["required"]=false

METAFLAG_default["normalize"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""

METAFLAG_default["is_array"]=false
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""

METAFLAG_default["is_assoc"]=false
METAFLAG_default["required_keys"]=""





# shell_cli_metaflag_property_validate_default — validate metaflag 'default'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'default' property is consistent with other flag rules.
# - Accepts empty values (since 'default' is optional).
# - If a default value is provided while 'required=true', validation fails,
#   because a required flag cannot have a fallback.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value is empty or consistent with 'required').
# - 1: validation failure (default provided while required=true).
shell_cli_metaflag_property_validate_default() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  local -n __assoc="${fassoc}"
  local _required="${__assoc["required"]}"

  if [ "${fval}" != "" ] && [ "${_required}" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_default — check input for metaflag 'default'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (default assignment).
#
# Behavior:
# - Applies the default value if the user omitted the flag.
# - If 'inputVal' is empty and 'ruleVal' is non-empty, assigns 'ruleVal'
#   as the new value.
# - Stores the new value in 'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
# - Clears any previous error message.
#
# Returns:
# - 0: always valid (default applied if needed).
shell_cli_metaflag_check_input_default() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${inputVal}" = "" ] && [ "${ruleVal}" != "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${ruleVal}"
  fi

  return 0
}
