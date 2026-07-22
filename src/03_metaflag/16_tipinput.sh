#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/16_tipinput.sh
# DESCRIPTION: specifies the custom interactive question or behavioral guide 
#    displayed to the user when the framework operates under strict interactive 
#    modes.
# ==============================================================================

declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["type"]="string"
METAFLAG_tipinput["array"]=false
METAFLAG_tipinput["assoc"]=false
METAFLAG_tipinput["required"]=false
METAFLAG_tipinput["default"]=""
METAFLAG_tipinput["enum"]=""
METAFLAG_tipinput["assoc_keys"]=""
METAFLAG_tipinput["min"]="4"
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""
METAFLAG_tipinput["regex"]=""
METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""



# shell_cli_metaflag_validate_tipinput metaflag 'tipinput'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_validate_tipinput() {
  SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""
  return 0
}
