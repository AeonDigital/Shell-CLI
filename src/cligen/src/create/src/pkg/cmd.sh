#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE_PKG
# 
# Basic definition of the 'pkg' command.
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_PKG=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["cmd"]="pkg"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["summary"]="Starts a new CLI PKG Project"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["description"]="A CLI Project is a Package that enables the execution of one or more tasks—grouped by commands—within a rigidly defined hierarchical structure."



# SHELL_CLI_CMD_CLIGEN_CREATE_PKG_ACTION_ORDER
# 
# Listing and ordering of available actions/subcommands.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_PKG_ACTION_ORDER=()
# {{REGISTER ACTION PLACEHOLDER}}
