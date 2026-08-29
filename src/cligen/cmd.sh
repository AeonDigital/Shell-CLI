#!/usr/bin/env bash

# 
# SHELL_CLI_CMD_CLIGEN — Main registry of the CLIGEN package.
declare -gA SHELL_CLI_CMD_CLIGEN=()
SHELL_CLI_CMD_CLIGEN["cmd"]="cligen"
SHELL_CLI_CMD_CLIGEN["summary"]="Shell CLI/PKG generator."
SHELL_CLI_CMD_CLIGEN["description"]="Allows creating and editing projects implemented with the Shell-CLI."



# 
# SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER  
# Listing and ordering of available flags.
declare -ga SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER=()
SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("update-template")
SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("set-env")

SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("create")
