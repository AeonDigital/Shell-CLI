#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/07_default.sh
# DESCRIPTION: defines the fallback value automatically assigned if the user 
#   omits the flag. Core compiler rules reject schemas where required is true 
#   (1) and a default is simultaneously set.
# ==============================================================================

declare -gA METAFLAG_default=()
METAFLAG_default["short"]=""
METAFLAG_default["long"]="default"
METAFLAG_default["type"]="string"
METAFLAG_default["array"]="0"
METAFLAG_default["assoc"]="0"
METAFLAG_default["required"]="0"
METAFLAG_default["default"]=""
METAFLAG_default["enum"]=""
METAFLAG_default["assoc_keys"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""
