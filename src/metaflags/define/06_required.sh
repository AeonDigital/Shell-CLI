#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/06_required.sh
# DESCRIPTION: declares whether the flag must be explicitly supplied by the 
#   user. If active (1), the framework automatically mandates a non-empty 
#   presence check.
# ==============================================================================

declare -gA METAFLAG_required=()
METAFLAG_required["short"]=""
METAFLAG_required["long"]="required"
METAFLAG_required["type"]="bool"
METAFLAG_required["array"]="0"
METAFLAG_required["assoc"]="0"
METAFLAG_required["required"]="0"
METAFLAG_required["default"]="0"
METAFLAG_required["enum"]=""
METAFLAG_required["assoc_keys"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""
