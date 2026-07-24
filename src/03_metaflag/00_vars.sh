#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the last error message generated from the last 
# execution of 'shell_cli_metaflag_property_validate_<flag_property>' function.
declare -g SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""


# Stores the last error message generated from the last 
# execution of 'shell_cli_metaflag_check_input_<flag_property>' function.
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""

# Stores the new value to be used as the counterpart to the one received from 
# user input. Is always populated by the function 
# 'shell_cli_metaflag_check_input_<flag_property>'
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

# Stores the deserialized version of a received array. It is populated whenever 
# the function 'shell_cli_metaflag_check_input_array' is invoked; therefore, 
# its value is temporary.
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()

# Stores the deserialized version of a received assoc. It is populated whenever 
# the function 'shell_cli_metaflag_check_input_assoc' is invoked; therefore, 
# its value is temporary.
declare -gA SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()

# Holds the order of discovered keys.
# Note: This order is fully reliable only when parsing from a JSON string.
#       When input is an existing associative array, Bash does not preserve
#       insertion order, so this information is lost.
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()



# Global associative array mapping all mandatory and optional metadata schema keys
# to their framework-specified fallback default compilation values.
declare -gA SHELL_CLI_METAFLAG_DEFAULT=()
SHELL_CLI_METAFLAG_DEFAULT["long"]=""
SHELL_CLI_METAFLAG_DEFAULT["short"]=""
SHELL_CLI_METAFLAG_DEFAULT["description"]=""
SHELL_CLI_METAFLAG_DEFAULT["tipinput"]=""
SHELL_CLI_METAFLAG_DEFAULT["type"]=""
SHELL_CLI_METAFLAG_DEFAULT["enum"]=""

SHELL_CLI_METAFLAG_DEFAULT["required"]=false
SHELL_CLI_METAFLAG_DEFAULT["default"]=""

SHELL_CLI_METAFLAG_DEFAULT["array"]=false
SHELL_CLI_METAFLAG_DEFAULT["assoc"]=false
SHELL_CLI_METAFLAG_DEFAULT["assoc_keys"]=""

SHELL_CLI_METAFLAG_DEFAULT["normalize"]=""
SHELL_CLI_METAFLAG_DEFAULT["validate"]=""
SHELL_CLI_METAFLAG_DEFAULT["transform"]=""
SHELL_CLI_METAFLAG_DEFAULT["regex"]=""

SHELL_CLI_METAFLAG_DEFAULT["min"]=""
SHELL_CLI_METAFLAG_DEFAULT["max"]=""
SHELL_CLI_METAFLAG_DEFAULT["min_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["max_array"]=""



# Global indexed array defining the strict execution sequence order for evaluating
# metadata schema configuration rules during framework pre-flight compilation loops.
declare -ga SHELL_CLI_METAFLAG_DEFAULT_ORDER=()
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("long")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("short")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("description")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("tipinput")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("type")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("enum")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("default")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("assoc")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("assoc_keys")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("normalize")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("validate")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("transform")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("regex")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max_array")
