#!/usr/bin/env bash

# 
# METAFLAG 'normalize'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_normalize=()
METAFLAG_normalize["long"]="normalize"
METAFLAG_normalize["short"]=""
METAFLAG_normalize["type"]="function"
METAFLAG_normalize["accept_values"]=""

METAFLAG_normalize["description"]="Specifies a function responsible for normalizing the value before validation."
METAFLAG_normalize["tipinput"]=""

METAFLAG_normalize["default"]=""
METAFLAG_normalize["required"]=false

METAFLAG_normalize["normalize"]=""
METAFLAG_normalize["min"]=""
METAFLAG_normalize["max"]=""
METAFLAG_normalize["regex"]=""
METAFLAG_normalize["validate"]=""
METAFLAG_normalize["transform"]=""

METAFLAG_normalize["is_array"]=false
METAFLAG_normalize["min_array"]=""
METAFLAG_normalize["max_array"]=""

METAFLAG_normalize["is_assoc"]=false
METAFLAG_normalize["required_keys"]=""





# shell_cli_metaflag_property_validate_normalize — validate structural integrity
# of this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_normalize() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if ! declare -f "${fval}" >/dev/null; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="normalize function does not exist ( fn='${fval}' )."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_normalize — runtime input check placeholder for
# this metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_normalize() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local newVal=$("${ruleVal}" "${inputVal}")
  local exitCode=$?

  if [ ${exitCode} = "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${newVal}"
    return 0
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="normalize function failed; ( fn='${ruleVal}'; value='${inputVal}' )"
    return 1
  fi
}
