#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/13_max_array.sh
# DESCRIPTION: defines the maximum number of elements allowed inside a 
#   collection. This evaluation is optional and operates exclusively when the 
#   array attribute is active (1).
# ==============================================================================

declare -gA METAFLAG_max_array=()
METAFLAG_max_array["short"]=""
METAFLAG_max_array["long"]="max_array"
METAFLAG_max_array["type"]="int"
METAFLAG_max_array["array"]="0"
METAFLAG_max_array["assoc"]="0"
METAFLAG_max_array["required"]="0"
METAFLAG_max_array["default"]=""
METAFLAG_max_array["enum"]=""
METAFLAG_max_array["assoc_keys"]=""
METAFLAG_max_array["min"]=""
METAFLAG_max_array["max"]=""
METAFLAG_max_array["min_array"]=""
METAFLAG_max_array["max_array"]=""
METAFLAG_max_array["regex"]=""
METAFLAG_max_array["description"]="Maximum allowable element count within a validated array collection."
METAFLAG_max_array["tipinput"]=""
METAFLAG_max_array["validate"]=""
METAFLAG_max_array["transform"]=""
