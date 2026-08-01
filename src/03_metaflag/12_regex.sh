#!/usr/bin/env bash

#
# METAFLAG 'regex'
# Canonical definition scheme for this flag.
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





# shell_cli_metaflag_property_validate_regex - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
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



# shell_cli_metaflag_check_input_regex - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
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