#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE
# 
# Basic definition of the 'create' command.
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE=()
SHELL_CLI_CMD_CLIGEN_CREATE["cmd"]="create"
SHELL_CLI_CMD_CLIGEN_CREATE["summary"]="Main resource for creating elements for a CLI project."
SHELL_CLI_CMD_CLIGEN_CREATE["description"]="The environment level defined by the 'set-env' command allows elements to be created within that context."



# SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER=()
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("pkg")
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("cmd")
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("flag")
# {{REGISTER ACTION PLACEHOLDER}}
