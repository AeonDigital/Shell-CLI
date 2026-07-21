#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the last error message generated from the last 
# execution of 'shell_cli_metaflag_validate_<flag_property>' function.
declare -g SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE=""


# Global associative array mapping all mandatory and optional metadata schema keys
# to their framework-specified fallback default compilation values.
declare -gA SHELL_CLI_METAFLAG_DEFAULT=()
SHELL_CLI_METAFLAG_DEFAULT["long"]=""
SHELL_CLI_METAFLAG_DEFAULT["short"]=""
SHELL_CLI_METAFLAG_DEFAULT["type"]=""
SHELL_CLI_METAFLAG_DEFAULT["array"]="0"
SHELL_CLI_METAFLAG_DEFAULT["assoc"]="0"
SHELL_CLI_METAFLAG_DEFAULT["required"]="0"
SHELL_CLI_METAFLAG_DEFAULT["default"]=""
SHELL_CLI_METAFLAG_DEFAULT["enum"]=""
SHELL_CLI_METAFLAG_DEFAULT["assoc_keys"]=""
SHELL_CLI_METAFLAG_DEFAULT["min"]=""
SHELL_CLI_METAFLAG_DEFAULT["max"]=""
SHELL_CLI_METAFLAG_DEFAULT["min_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["max_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["regex"]=""
SHELL_CLI_METAFLAG_DEFAULT["description"]=""
SHELL_CLI_METAFLAG_DEFAULT["tipinput"]=""
SHELL_CLI_METAFLAG_DEFAULT["validate"]=""
SHELL_CLI_METAFLAG_DEFAULT["transform"]=""


# Global indexed array defining the strict execution sequence order for evaluating
# metadata schema configuration rules during framework pre-flight compilation loops.
declare -ga SHELL_CLI_METAFLAG_DEFAULT_ORDER=()
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("long")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("short")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("type")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("assoc")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("default")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("enum")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("assoc_keys")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("regex")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("description")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("tipinput")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("validate")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("transform")
