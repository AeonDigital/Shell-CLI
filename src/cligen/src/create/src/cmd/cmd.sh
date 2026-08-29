#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE_CMD
# 
# Basic definition of the 'cmd' command.
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["cmd"]="cmd"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["summary"]="Instantiates a new Command for selected CLI PKG."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["description"]="Generates the entire structure required to correspond to the newly specified command."



# SHELL_CLI_CMD_CLIGEN_CREATE_CMD_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_CMD_ACTION_ORDER=()
# {{REGISTER ACTION PLACEHOLDER}}
