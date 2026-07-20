#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/17_validate.sh
# DESCRIPTION: captures a JSON array of downstream investigator function names.
#   Invoked at the absolute tail of validation loops to compute complex domain-
#   specific rules.
# ==============================================================================

declare -gA METAFLAG_validate=()
METAFLAG_validate["short"]=""
METAFLAG_validate["long"]="validate"
METAFLAG_validate["type"]="function"
METAFLAG_validate["array"]="1"
METAFLAG_validate["assoc"]="0"
METAFLAG_validate["required"]="0"
METAFLAG_validate["default"]=""
METAFLAG_validate["enum"]=""
METAFLAG_validate["assoc_keys"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["description"]="Pointer to indexed array with all validate functions to call for this value."
METAFLAG_validate["tipinput"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""
