#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE
# 
# Basic definition of the 'update-template' command.
declare -gA SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE=()
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["cmd"]="update-template"
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["summary"]="Updates the templates"
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["description"]="Updates the templates for generating commands, flags, and other CLI features."



# SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE_ACTION_ORDER=()
# {{REGISTER ACTION PLACEHOLDER}}
