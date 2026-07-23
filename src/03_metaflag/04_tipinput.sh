#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/04_tipinput.sh
# DESCRIPTION: specifies the custom interactive question or behavioral guide 
#    displayed to the user when the framework operates under strict interactive 
#    modes.
# ==============================================================================

declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""
METAFLAG_tipinput["type"]="text"
METAFLAG_tipinput["enum"]=""

METAFLAG_tipinput["required"]=false
METAFLAG_tipinput["default"]=""

METAFLAG_tipinput["array"]=false
METAFLAG_tipinput["assoc"]=false
METAFLAG_tipinput["assoc_keys"]=""

METAFLAG_tipinput["normalize"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""
METAFLAG_tipinput["regex"]=""

METAFLAG_tipinput["min"]="4"
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""



# shell_cli_metaflag_property_validate_tipinput metaflag 'tipinput'.
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
shell_cli_metaflag_property_validate_tipinput() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
  return 0
}



# shell_cli_metaflag_check_input_tipinput checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed (normalizated and validate by type).
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      The new value after check will be stored in
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_tipinput() {
  # This check should never be performed.
  # It is included here solely as a placeholder.
  local inputVal="$1"
  local ruleVal="$2"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'tipinput'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}