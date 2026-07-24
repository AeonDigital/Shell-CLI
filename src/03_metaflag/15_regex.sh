#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/15_regex.sh
# DESCRIPTION: provisions an optional regular expression verification 
#   constraint pattern. Evaluates whether incoming values perfectly satisfy 
#   native Bash or grep pattern criteria.
# ==============================================================================

declare -gA METAFLAG_regex=()
METAFLAG_regex["long"]="regex"
METAFLAG_regex["short"]=""
METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""
METAFLAG_regex["type"]="text"
METAFLAG_regex["enum"]=""

METAFLAG_regex["required"]=false
METAFLAG_regex["default"]=""

METAFLAG_regex["array"]=false
METAFLAG_regex["assoc"]=false
METAFLAG_regex["assoc_keys"]=""

METAFLAG_regex["normalize"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""
METAFLAG_regex["regex"]=""

METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""



# shell_cli_metaflag_property_validate_regex metaflag 'regex'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_property_validate_regex() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" != "" ]; then
    ( [[ "" =~ $fval ]] ) 2>/dev/null
    local exit_status=$?

    if [ $exit_status -eq 2 ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="invalid regular expression ( regex='$fval' )."
      return 1
    fi
  fi

  return 0
}



# shell_cli_metaflag_check_input_regex checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed (normalizated and validate by type).
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      The new value after check will be stored in
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_regex() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
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