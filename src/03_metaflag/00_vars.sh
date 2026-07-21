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


# Global Associative array mapping the normalization and validation 
# method to be used for flag values ​​of type 'string'.
#
# Standardization code:
#
# - CODE_CTRL : targets all control chars except \r, \t, and \n
# - TEXT_CTRL : targets all text chars like \r, \t, and \n
# -      TRIM : performa a trim [ used only for normalization step ]
#
#
# Usage options:
#
# - code_text_trim : CODE_CTRL + TEXT_CTRL + TRIM
# -      code_text : CODE_CTRL + TEXT_CTRL
# -      code_trim : CODE_CTRL + TRIM
# -           code : CODE_CTRL
# -           trim : TRIM
# -           none : 
#
# Usage example:
#
# - For single value field (most common use) : 'code_text_trim'
# - For single value that's accept empty spaces before and/or after 
#   the main value : 'code_text'
# - For multiline texts and/or when the field value have to mantain 
#   identation with spaces or tabs : 'code_trim'
# - For fields that's receive code controls.
declare -gA SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE=()
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["long"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["short"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["type"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["array"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["assoc"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["required"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["default"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["enum"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["assoc_keys"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["min"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["max"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["min_array"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["max_array"]="code_text_trim"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["regex"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["description"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["tipinput"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["validate"]="code_text"
SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["transform"]="code_text"
