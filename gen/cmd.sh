#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

#
# Register the main command
declare -gA SHELL_CLI_CMD_GEN=()
SHELL_CLI_CMD_GEN["cmd"]="gen"
SHELL_CLI_CMD_GEN["summary"]="Shell CLI implementation generator."
SHELL_CLI_CMD_GEN["descriptione"]="Allows creating and editing projects implemented with the Shell-CLI."


# registers the subcommands available for use and their order of presentation in 
# the documentation/help
declare -ga SHELL_CLI_CMD_GEN_RESOURCE_ORDER=()
SHELL_CLI_CMD_GEN_RESOURCE_ORDER+=("newcmd")
