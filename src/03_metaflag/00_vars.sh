#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Global indexed array defining the strict execution sequence order for evaluating
# metadata schema configuration rules during framework pre-flight compilation loops.
declare -ga SHELL_CLI_METAFLAG_DEFAULTS_ORDER=()
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("long")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("short")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("type")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("array")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("assoc")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("required")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("default")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("enum")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("assoc_keys")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("min")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("max")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("min_array")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("max_array")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("regex")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("description")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("tipinput")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("validate")
SHELL_CLI_METAFLAG_DEFAULTS_ORDER+=("transform")


# Global associative array mapping all mandatory and optional metadata schema keys
# to their framework-specified fallback default compilation values.
declare -gA SHELL_CLI_METAFLAG_DEFAULTS=()
SHELL_CLI_METAFLAG_DEFAULTS["long"]=""
SHELL_CLI_METAFLAG_DEFAULTS["short"]=""
SHELL_CLI_METAFLAG_DEFAULTS["type"]=""
SHELL_CLI_METAFLAG_DEFAULTS["array"]="0"
SHELL_CLI_METAFLAG_DEFAULTS["assoc"]="0"
SHELL_CLI_METAFLAG_DEFAULTS["required"]="0"
SHELL_CLI_METAFLAG_DEFAULTS["default"]=""
SHELL_CLI_METAFLAG_DEFAULTS["enum"]=""
SHELL_CLI_METAFLAG_DEFAULTS["assoc_keys"]=""
SHELL_CLI_METAFLAG_DEFAULTS["min"]=""
SHELL_CLI_METAFLAG_DEFAULTS["max"]=""
SHELL_CLI_METAFLAG_DEFAULTS["min_array"]=""
SHELL_CLI_METAFLAG_DEFAULTS["max_array"]=""
SHELL_CLI_METAFLAG_DEFAULTS["regex"]=""
SHELL_CLI_METAFLAG_DEFAULTS["description"]=""
SHELL_CLI_METAFLAG_DEFAULTS["tipinput"]=""
SHELL_CLI_METAFLAG_DEFAULTS["validate"]=""
SHELL_CLI_METAFLAG_DEFAULTS["transform"]=""


# Stores the last error message from one of the flag rule validations
SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""
