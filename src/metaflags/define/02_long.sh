#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/02_long.sh
# DESCRIPTION: defines the canonical long name identifier for a command-line 
#   flag. It acts as a double-dash option (e.g., --scope) and maps directly to 
#   parsed storage keys.
# ==============================================================================

declare -gA METAFLAG_long=()
METAFLAG_long["short"]=""
METAFLAG_long["long"]="long"
METAFLAG_long["type"]="string"
METAFLAG_long["array"]="0"
METAFLAG_long["assoc"]="0"
METAFLAG_long["required"]="1"
METAFLAG_long["default"]=""
METAFLAG_long["enum"]=""
METAFLAG_long["assoc_keys"]=""
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="32"
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""
