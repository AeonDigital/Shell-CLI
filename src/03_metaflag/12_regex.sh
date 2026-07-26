#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/12_regex.sh
# DESCRIPTION: provisions an optional regular expression verification 
#   constraint pattern. 
# ==============================================================================

declare -gA METAFLAG_regex=()
METAFLAG_regex["long"]="regex"
METAFLAG_regex["short"]=""
METAFLAG_regex["type"]="text"
METAFLAG_regex["accept_values"]=""

METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""

METAFLAG_regex["default"]=""
METAFLAG_regex["required"]=false

METAFLAG_regex["normalize"]=""
METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["regex"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""

METAFLAG_regex["is_array"]=false
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""

METAFLAG_regex["is_assoc"]=false
METAFLAG_regex["required_keys"]=""





# shell_cli_metaflag_property_validate_regex — validate metaflag 'regex'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'regex' property, if defined, is a valid regular expression.
# - Accepts empty values (since 'regex' is optional).
# - Performs a test match against an empty string to verify regex syntax.
# - If the regex is invalid, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (regex is empty or valid).
# - 1: validation failure (regex syntax invalid).
shell_cli_metaflag_property_validate_regex() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" != "" ]; then
    ( [[ "" =~ ${fval} ]] ) 2>/dev/null
    local exit_status=$?

    if [ ${exit_status} -eq 2 ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="invalid regular expression ( regex='${fval}' )."
      return 1
    fi
  fi

  return 0
}



# shell_cli_metaflag_check_input_regex — check input for metaflag 'regex'.
#
# Arguments:
# - inputVal: value provided by user input (normalized and validated by type).
# - typeVal: type of value.
# - ruleVal: current value of this property (regex pattern).
#
# Behavior:
# - Validates whether the user-provided input matches the regex pattern.
# - If 'ruleVal' is empty, no validation is applied.
# - If input does not match the regex, stores an error message in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - On success, stores the validated input in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 0: validation success (input matches regex or regex not defined).
# - 1: validation failure (input does not match regex).
shell_cli_metaflag_check_input_regex() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    return 0
  fi

  if [[ ! ${inputVal} =~ "${ruleVal}" ]]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="does not match with regular expression; ( regex: '${ruleVal}' )"
    return 1
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}