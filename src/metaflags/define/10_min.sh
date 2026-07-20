#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/10_min.sh
# DESCRIPTION: enforces the minimum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_min=()
METAFLAG_min["short"]=""
METAFLAG_min["long"]="min"
METAFLAG_min["type"]="string"
METAFLAG_min["array"]="0"
METAFLAG_min["assoc"]="0"
METAFLAG_min["required"]="0"
METAFLAG_min["default"]=""
METAFLAG_min["enum"]=""
METAFLAG_min["assoc_keys"]=""
METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""
METAFLAG_min["regex"]=""
METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""
