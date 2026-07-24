#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/05_type.sh
# DESCRIPTION: defines the primitive, structured, or system classification of 
#   the flag data. It instructs the core engine which specialized native 
#   validation routine to trigger.
# ==============================================================================

declare -gA METAFLAG_type=()
METAFLAG_type["long"]="type"
METAFLAG_type["short"]=""
METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""
METAFLAG_type["type"]="enum"
METAFLAG_type["enum"]="SHELL_CLI_TYPE"

METAFLAG_type["required"]=true
METAFLAG_type["default"]=""

METAFLAG_type["array"]=false
METAFLAG_type["assoc"]=false
METAFLAG_type["assoc_keys"]=""

METAFLAG_type["normalize"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""
METAFLAG_type["regex"]=""

METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""



# shell_cli_metaflag_property_validate_type metaflag 'type'.
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
shell_cli_metaflag_property_validate_type() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  if [ "${SHELL_CLI_TYPE["$fval"]}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="invalid definition ( type='$fval' )."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_type checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed.
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
shell_cli_metaflag_check_input_type() {
  # This check should never be performed.
  # It is included here solely as a placeholder.
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'type'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}