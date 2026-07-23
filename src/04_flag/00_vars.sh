#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the name of each flag family that has been fully validated.
declare -A SHELL_CLI_FLAG_CHECKED_FAMILY=()


# Stores the last error message generated from the last 
# execution of 'shell_cli_flag_check_rules' function.
declare -g SHELL_CLI_FLAG_CHECK_RULE_ERR_MESSAGE=""


# Stores the last error message generated from the last 
# execution of 'shell_cli_flag_check_value' function.
declare -g SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE=""
