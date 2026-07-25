#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/08_required.sh
# DESCRIPTION: specifies whether the flag must be filled in, either by the user 
#   or via a default value.
# ==============================================================================

declare -gA METAFLAG_required=()
METAFLAG_required["long"]="required"
METAFLAG_required["short"]=""
METAFLAG_required["type"]="bool"
METAFLAG_required["accept_values"]=""

METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""

METAFLAG_required["default"]="0"
METAFLAG_required["required"]=false

METAFLAG_required["normalize"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""

METAFLAG_required["is_array"]=false
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""

METAFLAG_required["is_assoc"]=false
METAFLAG_required["required_keys"]=""





# shell_cli_metaflag_property_validate_required metaflag 'required'.
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
shell_cli_metaflag_property_validate_required() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_required checks whether the input flag 
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
shell_cli_metaflag_check_input_required() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "$inputVal" = "" ] && [ "$ruleVal" = "1" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="cannot be empty or omitted"
  fi

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="$inputVal"
  return 0
}
