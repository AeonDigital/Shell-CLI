#!/usr/bin/env bash

# SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER - Chronological sequence matrix tracking target subcommand option parameter keys.
#
# - Establishes the strict sequentially prioritized validation flow for runtime parameter evaluations.
# - Preserves the exact listing and rendering layout sequence used when generating help manuals and documentation blocks.
declare -ga SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER=()



#
# FLAG path
# Canonical definition scheme for this flag.
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER+=("path")
declare -gA SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path["long"]="path"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path["type"]="dirpath"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path["required"]=true
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path["description"]="Target file system directory where the new CLI project architecture will be initialized"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_path["tipinput"]="Enter the target directory path for the new CLI project"



#
# FLAG pkg
# Canonical definition scheme for this flag.
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER+=("pkg")
declare -gA SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["long"]="pkg"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["type"]="string"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["required"]=true
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["min"]="3"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["max"]="16"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["description"]="Global corporate uppercase package identifier designation name (e.g., CLIENTCLI)"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["tipinput"]="Enter the global package name (it will be automatically converted to UPPERCASE)"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_pkg["transform"]='["shell_cli_transform_uppercase"]'



#
# FLAG cmd
# Canonical definition scheme for this flag.
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER+=("cmd")
declare -gA SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["long"]="cmd"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["type"]="string"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["required"]=true
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["min"]="3"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["max"]="16"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["description"]="Initial structural command tree action name to create inside the workspace"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_cmd["tipinput"]="Enter the initial command tree action name"



#
# FLAG summary
# Canonical definition scheme for this flag.
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER+=("summary")

declare -gA SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["long"]="summary"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["type"]="string"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["required"]=true
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["min"]="1"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["max"]="256"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["description"]="Brief single-line summary description of the generated command purpose for global help"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_summary["tipinput"]="Enter a short, single-line summary of what this initial command does"



#
# FLAG description
# Canonical definition scheme for this flag.
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_ORDER+=("description")
declare -gA SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["long"]="description"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["type"]="string"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["required"]=true
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["min"]="1"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["max"]="2048"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["description"]="Full detailed architectural and operational explanation of the generated command"
SHELL_CLI_CMD_GEN_NEWCMD_FLAG_description["tipinput"]="Enter a full, detailed operational explanation for this command"
