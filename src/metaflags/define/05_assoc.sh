#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/05_assoc.sh
# DESCRIPTION: declares whether the flag parameter operates as an associative 
#   map. Accepts a global variable name pointer or an inline JSON object 
#   sequence.
# ==============================================================================

declare -gA METAFLAG_assoc=()
METAFLAG_assoc["short"]=""
METAFLAG_assoc["long"]="assoc"
METAFLAG_assoc["type"]="bool"
METAFLAG_assoc["array"]="0"
METAFLAG_assoc["assoc"]="0"
METAFLAG_assoc["required"]="0"
METAFLAG_assoc["default"]="0"
METAFLAG_assoc["enum"]=""
METAFLAG_assoc["assoc_keys"]=""
METAFLAG_assoc["min"]=""
METAFLAG_assoc["max"]=""
METAFLAG_assoc["min_array"]=""
METAFLAG_assoc["max_array"]=""
METAFLAG_assoc["regex"]=""
METAFLAG_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_assoc["tipinput"]=""
METAFLAG_assoc["validate"]=""
METAFLAG_assoc["transform"]=""
