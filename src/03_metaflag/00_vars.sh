#!/usr/bin/env bash

# SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE - Error message store for static metaflag schema property validations.
#
# - Stores the specific structural violation string when a 'shell_cli_metaflag_property_validate_*' function fails.
# - Overwritten on every structural property execution check.
declare -g SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

# SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE - Error message store for runtime input evaluations.
#
# - Stores the user-facing input violation string when a 'shell_cli_metaflag_check_input_*' function fails.
# - Overwritten on every runtime evaluation iteration.
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""

# SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE - Output store for scalar runtime normalized/transformed input.
#
# - Populated with the post-processed counterpart of user input via 'shell_cli_metaflag_check_input_*'.
# - Contains the failure token string "!ERR" if validation fails.
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

# SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY - Temporary store for runtime parsed and deserialized indexed arrays.
#
# - Populated with discrete elements whenever 'shell_cli_metaflag_check_input_array' executes.
# - Cleared and rebuilt dynamically per array-type input evaluation.
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()

# SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC - Temporary store for runtime parsed and deserialized associative arrays.
#
# - Populated with key-value pairs whenever 'shell_cli_metaflag_check_input_assoc' executes.
# - Cleared and rebuilt dynamically per object-type input evaluation.
declare -gA SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()

# SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER - Runtime index tracker for associative array input sequence.
#
# - Guarantees insertion order verification only when deserializing from an input JSON string format.
# - Unreliable if the original validation source was an native Bash associative array due to internal indexing.
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()




# SHELL_CLI_METAFLAG_DEFAULT - Framework metadata schema key mappings and fallback default values.
#
# - Maps all mandatory and optional metadata property keys required by the CLI system.
# - Provides baseline fallback initialization values during compilation cycles.
declare -gA SHELL_CLI_METAFLAG_DEFAULT=()
SHELL_CLI_METAFLAG_DEFAULT["long"]=""
SHELL_CLI_METAFLAG_DEFAULT["short"]=""
SHELL_CLI_METAFLAG_DEFAULT["type"]=""
SHELL_CLI_METAFLAG_DEFAULT["accept_values"]=""

SHELL_CLI_METAFLAG_DEFAULT["description"]=""
SHELL_CLI_METAFLAG_DEFAULT["tipinput"]=""

SHELL_CLI_METAFLAG_DEFAULT["default"]=""
SHELL_CLI_METAFLAG_DEFAULT["required"]=false

SHELL_CLI_METAFLAG_DEFAULT["normalize"]=""
SHELL_CLI_METAFLAG_DEFAULT["min"]=""
SHELL_CLI_METAFLAG_DEFAULT["max"]=""
SHELL_CLI_METAFLAG_DEFAULT["regex"]=""
SHELL_CLI_METAFLAG_DEFAULT["validate"]=""
SHELL_CLI_METAFLAG_DEFAULT["transform"]=""

SHELL_CLI_METAFLAG_DEFAULT["is_array"]=false
SHELL_CLI_METAFLAG_DEFAULT["min_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["max_array"]=""

SHELL_CLI_METAFLAG_DEFAULT["is_assoc"]=false
SHELL_CLI_METAFLAG_DEFAULT["required_keys"]=""





# SHELL_CLI_METAFLAG_DEFAULT_ORDER - Execution sequence tracker for metadata configuration evaluation.
#
# - Defines the strict chronological order for running rule evaluations.
# - Utilized by framework pre-flight compilation loops to prevent dependency failures.
declare -ga SHELL_CLI_METAFLAG_DEFAULT_ORDER=()
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("long")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("short")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("type")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("accept_values")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("description")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("tipinput")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("default")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("normalize")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("regex")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("validate")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("transform")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("is_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max_array")

SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("is_assoc")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required_keys")
