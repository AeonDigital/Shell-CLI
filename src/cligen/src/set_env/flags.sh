#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER  
# Coordinator of flag population in interactive mode and during the internal validation
# period.
declare -ga SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER=()




# 
# FLAG path
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("path")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["long"]="path"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["type"]="dirpath"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["required"]=true
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["description"]="Path to the root of the CLI Project architecture."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["tipinput"]="Enter the CLI project's root directory."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["validate"]='["shell_cli_utils_fs_dir_path_exists"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["transform"]='["shell_cli_utils_fs_to_absolute_dir_path"]'

# 
# FLAG pkg
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("pkg")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["long"]="pkg"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["type"]="string"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["required"]=false
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["min"]="3"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["max"]="16"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["description"]="CLI Project main package name"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["tipinput"]="Enter the CLI Project main package name"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["transform"]='["shell_cli_utils_to_lowercase"]'

# 
# FLAG cmd
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("cmd")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["long"]="cmd"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["type"]="string"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["required"]=false
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["min"]="3"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["max"]="16"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["description"]="Collection of commands chained hierarchically up to the item currently in focus."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["tipinput"]="Enter the name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["transform"]='["shell_cli_utils_to_lowercase"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["is_array"]=true

# {{REGISTER FLAG PLACEHOLDER}}
