#!/usr/bin/env bash

# 
# METAFLAG 'accept_values'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_accept_values=()
METAFLAG_accept_values["long"]="accept_values"
METAFLAG_accept_values["short"]=""
METAFLAG_accept_values["type"]="text"
METAFLAG_accept_values["accept_values"]=""

METAFLAG_accept_values["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_accept_values["tipinput"]=""

METAFLAG_accept_values["default"]=""
METAFLAG_accept_values["required"]=false

METAFLAG_accept_values["normalize"]=""
METAFLAG_accept_values["min"]=""
METAFLAG_accept_values["max"]=""
METAFLAG_accept_values["regex"]=""
METAFLAG_accept_values["validate"]=""
METAFLAG_accept_values["transform"]=""

METAFLAG_accept_values["is_array"]=false
METAFLAG_accept_values["min_array"]=""
METAFLAG_accept_values["max_array"]=""

METAFLAG_accept_values["is_assoc"]=true
METAFLAG_accept_values["required_keys"]=""





# shell_cli_metaflag_property_validate_accept_values — validate structural integrity
# of this metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_accept_values() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if ! shell_cli_utils_array_is_assoc "${fval}"; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an associative array (declare -A)."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_accept_values — runtime input check placeholder
# for this metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_accept_values() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local -n flagEnum="${ruleVal}"
  local k=""
  local v=""
  for k in "${!flagEnum[@]}"; do
    v="${flagEnum[${k}]}"

    if [ "${inputVal}" = "${k}" ] || [ "${inputVal}" = "${v}" ]; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${k}"
      return 0
    fi
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="expected one of '${ruleVal}' collection member; ( value: '${inputVal}' )"
  return 1
}
