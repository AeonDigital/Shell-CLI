#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/18_transform.sh
# DESCRIPTION: captures a JSON array of downstream transformation function 
#   names. Invoked only after validation succeeds and before the final parsed 
#   value is stored.
# ==============================================================================

declare -gA METAFLAG_transform=()
METAFLAG_transform["short"]=""
METAFLAG_transform["long"]="transform"
METAFLAG_transform["type"]="function"
METAFLAG_transform["array"]="1"
METAFLAG_transform["assoc"]="0"
METAFLAG_transform["required"]="0"
METAFLAG_transform["default"]=""
METAFLAG_transform["enum"]=""
METAFLAG_transform["assoc_keys"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""
