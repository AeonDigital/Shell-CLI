#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/14_regex.sh
# DESCRIPTION: provisions an optional regular expression verification 
#   constraint pattern. Evaluates whether incoming values perfectly satisfy 
#   native Bash or grep pattern criteria.
# ==============================================================================

declare -gA METAFLAG_regex=()
METAFLAG_regex["short"]=""
METAFLAG_regex["long"]="regex"
METAFLAG_regex["type"]="string"
METAFLAG_regex["array"]="0"
METAFLAG_regex["assoc"]="0"
METAFLAG_regex["required"]="0"
METAFLAG_regex["default"]=""
METAFLAG_regex["enum"]=""
METAFLAG_regex["assoc_keys"]=""
METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""
METAFLAG_regex["regex"]=""
METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""
