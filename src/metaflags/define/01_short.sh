#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/01_short.sh
# DESCRIPTION: defines the short alphanumeric alias for a command-line flag.
#   It acts as a single-dash alternative (e.g., -s) and must not exceed 3 
#   characters
# ==============================================================================

declare -gA METAFLAG_short=()
METAFLAG_short["short"]=""
METAFLAG_short["long"]="short"
METAFLAG_short["type"]="string"
METAFLAG_short["array"]="0"
METAFLAG_short["assoc"]="0"
METAFLAG_short["required"]="0"
METAFLAG_short["default"]=""
METAFLAG_short["enum"]=""
METAFLAG_short["assoc_keys"]=""
METAFLAG_short["min"]="1"
METAFLAG_short["max"]="3"
METAFLAG_short["min_array"]=""
METAFLAG_short["max_array"]=""
METAFLAG_short["regex"]="^[a-zA-Z0-9]+$"
METAFLAG_short["description"]="Short alphanumeric character alias for the flag (1 to 3 chars)."
METAFLAG_short["tipinput"]=""
METAFLAG_short["validate"]=""
METAFLAG_short["transform"]=""
