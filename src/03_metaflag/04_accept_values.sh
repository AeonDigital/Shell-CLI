#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/04_accept_values.sh
# DESCRIPTION: specifies a JSON array with the accepted values (keys) or it 
#   aliases (values).
# ==============================================================================

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





# shell_cli_metaflag_property_validate_accept_values metaflag 'accept_values'.
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
shell_cli_metaflag_property_validate_accept_values() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  if ! shell_cli_utils_array_is_assoc "$fval"; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an associative array (declare -A)."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_accept_values checks whether the input flag 
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
shell_cli_metaflag_check_input_accept_values() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    return 0
  fi

  local -n flagEnum="${ruleVal}"
  local k=""
  local v=""
  for k in "${!flagEnum[@]}"; do
    v="${flagEnum[$k]}"

    if [ "$inputVal" = "$k" ] || [ "$inputVal" = "$v" ]; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="$k"
      return 0
    fi
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="expected one of '$ruleVal' collection member; ( value: '$inputVal' )"
  return 1
}