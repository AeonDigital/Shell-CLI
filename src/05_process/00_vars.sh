#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# - Global variable storing the current single value of the flag being processed.
# - Updated at each validation step with the normalized value.
declare -g SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE=""



# - Global variable storing the type of the current flag being processed.
# - Set from the flag definition before validation begins.
declare -g SHELL_CLI_PROCESS_FLAG_TYPE=""

# - Global variable storing the current value of the flag being processed.
# - Updated at each validation step with the normalized value.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE=""

# - Global variable storing the prefix used in error messages for the current flag.
# - Includes the flag's long name for clarity.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX=""

# - Global variable storing the last error message generated during flag value processing.
# - Cleared at the start of each process attempt.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""

# - Global indexed array storing the declaration order of keys for the current
#   associative flag value being processed.
#
# - Populated during 'is_assoc' validation, using the order provided by the
#   parser (SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER).
# - Reset at the start of each flag value processing.
# - Ensures that keys and values are iterated in the same order they were
#   originally declared, preserving semantic consistency.
declare -ga SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()
