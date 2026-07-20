#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/metaflags/define/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Global indexed array defining the strict execution sequence order for evaluating
# metadata schema configuration rules during framework pre-flight compilation loops.
declare -ga CORE_METAFLAG_DEFAULTS_ORDER=()
CORE_METAFLAG_DEFAULTS_ORDER+=("short")
CORE_METAFLAG_DEFAULTS_ORDER+=("long")
CORE_METAFLAG_DEFAULTS_ORDER+=("type")
CORE_METAFLAG_DEFAULTS_ORDER+=("array")
CORE_METAFLAG_DEFAULTS_ORDER+=("assoc")
CORE_METAFLAG_DEFAULTS_ORDER+=("required")
CORE_METAFLAG_DEFAULTS_ORDER+=("default")
CORE_METAFLAG_DEFAULTS_ORDER+=("enum")
CORE_METAFLAG_DEFAULTS_ORDER+=("assoc_keys")
CORE_METAFLAG_DEFAULTS_ORDER+=("min")
CORE_METAFLAG_DEFAULTS_ORDER+=("max")
CORE_METAFLAG_DEFAULTS_ORDER+=("min_array")
CORE_METAFLAG_DEFAULTS_ORDER+=("max_array")
CORE_METAFLAG_DEFAULTS_ORDER+=("regex")
CORE_METAFLAG_DEFAULTS_ORDER+=("description")
CORE_METAFLAG_DEFAULTS_ORDER+=("tipinput")
CORE_METAFLAG_DEFAULTS_ORDER+=("validate")
CORE_METAFLAG_DEFAULTS_ORDER+=("transform")


# Global associative array mapping all mandatory and optional metadata schema keys
# to their framework-specified fallback default compilation values.
declare -gA CORE_METAFLAG_DEFAULTS=()
CORE_METAFLAG_DEFAULTS["short"]=""
CORE_METAFLAG_DEFAULTS["long"]=""
CORE_METAFLAG_DEFAULTS["type"]=""
CORE_METAFLAG_DEFAULTS["array"]="0"
CORE_METAFLAG_DEFAULTS["assoc"]="0"
CORE_METAFLAG_DEFAULTS["required"]="0"
CORE_METAFLAG_DEFAULTS["default"]=""
CORE_METAFLAG_DEFAULTS["enum"]=""
CORE_METAFLAG_DEFAULTS["assoc_keys"]=""
CORE_METAFLAG_DEFAULTS["min"]=""
CORE_METAFLAG_DEFAULTS["max"]=""
CORE_METAFLAG_DEFAULTS["min_array"]=""
CORE_METAFLAG_DEFAULTS["max_array"]=""
CORE_METAFLAG_DEFAULTS["regex"]=""
CORE_METAFLAG_DEFAULTS["description"]=""
CORE_METAFLAG_DEFAULTS["tipinput"]=""
CORE_METAFLAG_DEFAULTS["validate"]=""
CORE_METAFLAG_DEFAULTS["transform"]=""
