#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/11_max.sh
# DESCRIPTION: enforces the maximum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_max=()
METAFLAG_max["short"]=""
METAFLAG_max["long"]="max"
METAFLAG_max["type"]="string"
METAFLAG_max["array"]="0"
METAFLAG_max["assoc"]="0"
METAFLAG_max["required"]="0"
METAFLAG_max["default"]=""
METAFLAG_max["enum"]=""
METAFLAG_max["assoc_keys"]=""
METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""
METAFLAG_max["regex"]=""
METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""
