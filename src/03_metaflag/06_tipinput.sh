#!/usr/bin/env bash

#
# METAFLAG 'tipinput'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["type"]="text"
METAFLAG_tipinput["accept_values"]=""

METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""

METAFLAG_tipinput["default"]=""
METAFLAG_tipinput["required"]=false

METAFLAG_tipinput["normalize"]=""
METAFLAG_tipinput["min"]="4"
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["regex"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""

METAFLAG_tipinput["is_array"]=false
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""

METAFLAG_tipinput["is_array"]=false
METAFLAG_tipinput["required_keys"]=""





# shell_cli_metaflag_property_validate_tipinput - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_tipinput() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
  return 0
}



# shell_cli_metaflag_check_input_tipinput - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_tipinput() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'tipinput'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}