#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_compile/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the name of each flag family that has already been compiled..
declare -A SHELL_CLI_FLAG_COMPILED_FAMILY=()


# Stores the last error message generated from the last 
# execution of 'shell_cli_compile_flag' function.
declare -g SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""
