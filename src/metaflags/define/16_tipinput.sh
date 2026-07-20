#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/16_tipinput.sh
# DESCRIPTION: specifies the custom interactive question or behavioral guide 
#    displayed to the user when the framework operates under strict interactive 
#    modes.
# ==============================================================================

declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["type"]="string"
METAFLAG_tipinput["array"]="0"
METAFLAG_tipinput["assoc"]="0"
METAFLAG_tipinput["required"]="0"
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
