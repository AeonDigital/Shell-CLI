#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/03_type.sh
# DESCRIPTION: defines the primitive, structured, or system classification of 
#   the flag data. It instructs the core engine which specialized native 
#   validation routine to trigger.
# ==============================================================================

declare -gA METAFLAG_type=()
METAFLAG_type["short"]=""
METAFLAG_type["long"]="type"
METAFLAG_type["type"]="enum"
METAFLAG_type["array"]="0"
METAFLAG_type["assoc"]="0"
METAFLAG_type["required"]="1"
METAFLAG_type["default"]=""
METAFLAG_type["enum"]="SHELL_CLI_METAFLAG_TYPES"
METAFLAG_type["assoc_keys"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""
