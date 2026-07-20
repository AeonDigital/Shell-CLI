#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/08_enum.sh
# DESCRIPTION: specifies a JSON array with the accepted values or aliases.
#   Mandatory if type is set to 'enum'. Rejects definitions that fail alias 
#   syntax rules.
# ==============================================================================

declare -gA METAFLAG_enum=()
METAFLAG_enum["short"]=""
METAFLAG_enum["long"]="enum"
METAFLAG_enum["type"]="string"
METAFLAG_enum["array"]="1"
METAFLAG_enum["assoc"]="0"
METAFLAG_enum["required"]="0"
METAFLAG_enum["default"]=""
METAFLAG_enum["enum"]=""
METAFLAG_enum["assoc_keys"]=""
METAFLAG_enum["min"]=""
METAFLAG_enum["max"]=""
METAFLAG_enum["min_array"]=""
METAFLAG_enum["max_array"]=""
METAFLAG_enum["regex"]=""
METAFLAG_enum["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_enum["tipinput"]=""
METAFLAG_enum["validate"]=""
METAFLAG_enum["transform"]=""
