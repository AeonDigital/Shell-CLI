#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

#
# Register the meta orchestration metadata for the newcmd command tree
declare -gA SHELL_CLI_CMD_GEN_NEWCMD=()
SHELL_CLI_CMD_GEN_NEWCMD["cmd"]="newcmd"
SHELL_CLI_CMD_GEN_NEWCMD["summary"]="Generates a standard bootstrap structure for a new CLI project"
SHELL_CLI_CMD_GEN_NEWCMD["description"]="Creates directories, README, and core execution entry points aligned with Shell-CLI specs."

# registers the subcommands available for use and their order of presentation in 
# the documentation/help
declare -ga SHELL_CLI_CMD_GEN_NEWCMD_ACTION_ORDER=()
