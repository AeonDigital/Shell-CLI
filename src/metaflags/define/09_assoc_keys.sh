#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/09_assoc_keys.sh
# DESCRIPTION: specifies a list of keys that MUST be present in the passed 
#   value, provided it is not an empty associative array
#   Operates exclusively when assoc is active (1) to enforce field presence.
# ==============================================================================

declare -gA METAFLAG_assoc_keys=()
METAFLAG_assoc_keys["short"]=""
METAFLAG_assoc_keys["long"]="assoc_keys"
METAFLAG_assoc_keys["type"]="string"
METAFLAG_assoc_keys["array"]="1"
METAFLAG_assoc_keys["assoc"]="0"
METAFLAG_assoc_keys["required"]="0"
METAFLAG_assoc_keys["default"]=""
METAFLAG_assoc_keys["enum"]=""
METAFLAG_assoc_keys["assoc_keys"]=""
METAFLAG_assoc_keys["min"]=""
METAFLAG_assoc_keys["max"]=""
METAFLAG_assoc_keys["min_array"]=""
METAFLAG_assoc_keys["max_array"]=""
METAFLAG_assoc_keys["regex"]=""
METAFLAG_assoc_keys["description"]="Pointer to array or a JSON-array string with the required 'keys'."
METAFLAG_assoc_keys["tipinput"]=""
METAFLAG_assoc_keys["validate"]=""
METAFLAG_assoc_keys["transform"]=""
