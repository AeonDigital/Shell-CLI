#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shelshell_cli/metaflags/define/04_array.sh
# DESCRIPTION: declares whether the flag parameter accepts a structured 
#   collection. If active (1), the engine parses the payload as a JSON array 
#   and validates every item.
# ==============================================================================

declare -gA METAFLAG_array=()
METAFLAG_array["short"]=""
METAFLAG_array["long"]="array"
METAFLAG_array["type"]="bool"
METAFLAG_array["array"]="0"
METAFLAG_array["assoc"]="0"
METAFLAG_array["required"]="0"
METAFLAG_array["default"]="0"
METAFLAG_array["enum"]=""
METAFLAG_array["assoc_keys"]=""
METAFLAG_array["min"]=""
METAFLAG_array["max"]=""
METAFLAG_array["min_array"]=""
METAFLAG_array["max_array"]=""
METAFLAG_array["regex"]=""
METAFLAG_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_array["tipinput"]=""
METAFLAG_array["validate"]=""
METAFLAG_array["transform"]=""
