#!/usr/bin/env bash

# SHELL_CLI_CMD_GEN_NEWCMD - Client-defined metadata registration schema for the nested subcommand node.
#
# - Configuration matrix exposing descriptive properties for the specific subcommand path hierarchy.
# - Mandatory keys: 
#   - 'cmd' (invocation token)
#   - 'summary' (brief description)
#   - 'description' (extended detail)
declare -gA SHELL_CLI_CMD_GEN_NEWCMD=()
SHELL_CLI_CMD_GEN_NEWCMD["cmd"]="newcmd"
SHELL_CLI_CMD_GEN_NEWCMD["summary"]="Generates a standard bootstrap structure for a new CLI project"
SHELL_CLI_CMD_GEN_NEWCMD["description"]="Creates directories, README, and core execution entry points aligned with Shell-CLI specs."



# SHELL_CLI_CMD_GEN_NEWCMD_ACTION_ORDER - Chronological sequence matrix tracking executable sub-actions.
#
# - Defines the execution sequence pattern for operational actions assigned under this specific node context.
# - Enforced by preflight loop components to determine the presentation layout order in documentation and help menus.
declare -ga SHELL_CLI_CMD_GEN_NEWCMD_ACTION_ORDER=()
