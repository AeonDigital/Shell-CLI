#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/12_min_array.sh
# DESCRIPTION: defines the minimum number of elements required inside a 
#   collection. This evaluation is optional and operates exclusively when the 
#   array attribute is active (1).
# ==============================================================================

declare -gA METAFLAG_min_array=()
METAFLAG_min_array["short"]=""
METAFLAG_min_array["long"]="min_array"
METAFLAG_min_array["type"]="int"
METAFLAG_min_array["array"]="0"
METAFLAG_min_array["assoc"]="0"
METAFLAG_min_array["required"]="0"
METAFLAG_min_array["default"]=""
METAFLAG_min_array["enum"]=""
METAFLAG_min_array["assoc_keys"]=""
METAFLAG_min_array["min"]=""
METAFLAG_min_array["max"]=""
METAFLAG_min_array["min_array"]=""
METAFLAG_min_array["max_array"]=""
METAFLAG_min_array["regex"]=""
METAFLAG_min_array["description"]="Minimum allowable element count within a validated array collection."
METAFLAG_min_array["tipinput"]=""
METAFLAG_min_array["validate"]=""
METAFLAG_min_array["transform"]=""
