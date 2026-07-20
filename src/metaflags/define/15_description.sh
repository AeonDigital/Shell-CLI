#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/15_description.sh
# DESCRIPTION: maps the essential human documentation text used to render help 
#   modules. Mandatory framework constraint ensuring zero undocumented features 
#   bypass compiler loops.
# ==============================================================================

declare -gA METAFLAG_description=()
METAFLAG_description["short"]=""
METAFLAG_description["long"]="description"
METAFLAG_description["type"]="string"
METAFLAG_description["array"]="0"
METAFLAG_description["assoc"]="0"
METAFLAG_description["required"]="1"
METAFLAG_description["default"]=""
METAFLAG_description["enum"]=""
METAFLAG_description["assoc_keys"]=""
METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""
METAFLAG_description["regex"]=""
METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""
