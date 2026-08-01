#!/usr/bin/env bash

# SHELL_CLI_CMD_GEN - Client-defined metadata registration schema for the primary root command.
#
# - Configuration matrix exposed to the framework compilation engine during early bootstrap passes.
# - Mandatory keys: 
#   - 'cmd' (invocation token)
#   - 'summary' (brief description)
#   - 'description' (extended detail)
declare -gA SHELL_CLI_CMD_GEN=()
SHELL_CLI_CMD_GEN["cmd"]="gen"
SHELL_CLI_CMD_GEN["summary"]="Shell CLI implementation generator."
SHELL_CLI_CMD_GEN["description"]="Allows creating and editing projects implemented with the Shell-CLI."



# SHELL_CLI_CMD_GEN_RESOURCE_ORDER - Chronological sequence matrix tracking available root subcommands.
#
# - Defines the strict discovery and presentation order used during manual help menu generation loops.
# - Must map exactly to downstream file system directory nodes located inside the resource source package.
declare -ga SHELL_CLI_CMD_GEN_RESOURCE_ORDER=()
SHELL_CLI_CMD_GEN_RESOURCE_ORDER+=("newcmd")
