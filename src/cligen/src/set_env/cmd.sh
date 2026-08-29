#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_SET_ENV
# 
# Basic definition of the 'set-env' command.
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV=()
SHELL_CLI_CMD_CLIGEN_SET_ENV["cmd"]="set-env"
SHELL_CLI_CMD_CLIGEN_SET_ENV["summary"]="Sets the working environment."
SHELL_CLI_CMD_CLIGEN_SET_ENV["description"]="Sets the working environment for the other commands of this CLI as the working directory, pkg, cmd, and/or flag."



# SHELL_CLI_CMD_CLIGEN_SET_ENV_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_SET_ENV_ACTION_ORDER=()
# {{REGISTER ACTION PLACEHOLDER}}
