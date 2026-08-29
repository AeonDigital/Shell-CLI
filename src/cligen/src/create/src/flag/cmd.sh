#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE_FLAG
# 
# Basic definition of the 'flag' command.
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_FLAG=()
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["cmd"]="flag"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["summary"]="Adds a new flag to the selected command."
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["description"]="Configures the use of a new flag for the command, allowing each of its technical aspects to be edited."



# SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_ACTION_ORDER=()
# {{REGISTER ACTION PLACEHOLDER}}
