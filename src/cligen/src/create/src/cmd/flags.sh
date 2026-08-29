#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER
# 
# Coordinator of flag population in interactive mode and during the internal validation
# period.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER=()



# 
# FLAG name
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("name")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["long"]="name"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["min"]="3"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["max"]="16"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["description"]="Name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["tipinput"]="Enter the name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["transform"]='["shell_cli_utils_to_lowercase"]'

# 
# FLAG summary
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("summary")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["long"]="summary"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["max"]="256"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["description"]="Brief single-line summary description of the generated Command."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["tipinput"]="Enter a short, single-line summary of what this Command does"

# 
# FLAG description
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("description")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["long"]="description"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["max"]="2048"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["description"]="Full detailed architectural and operational explanation of the Command"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["tipinput"]="Enter a full, detailed operational explanation for this Command"

# {{REGISTER FLAG PLACEHOLDER}}
