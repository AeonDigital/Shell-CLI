#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: flags.sh
# DESCRIPTION: Defines configuration schemas and flags validation structures 
#              for the 'gen newcmd' scaffolding command ecosystem.
# ==============================================================================

# Import global enterprise flags configuration definitions before local overrides
if [ -f "../../globals/flags.sh" ]; then
  . "../../globals/flags.sh"
fi

#
# Register the meta orchestration metadata for the newcmd command tree
declare -gA CMD_GEN_ORES_newcmd
CMD_GEN_ORES_newcmd["cmd"]="newcmd"
CMD_GEN_ORES_newcmd["summary"]="Generates a standard bootstrap structure for a new CLI project"
CMD_GEN_ORES_newcmd["description"]="Creates directories, README, and core execution entry points aligned with Shell-CLI specs."

#
# Enforce strict sequentially prioritized validation flow for runtime flags
declare -ga CMD_GEN_ORES_newcmd_FLAG_ORDER



#
# Define validation schema and descriptive metadata for the --path flag
CMD_GEN_ORES_newcmd_FLAG_ORDER+=("path")

declare -gA CMD_GEN_ORES_newcmd_FLAG_path
CMD_GEN_ORES_newcmd_FLAG_path["long"]="path"
CMD_GEN_ORES_newcmd_FLAG_path["type"]="dirpath"
CMD_GEN_ORES_newcmd_FLAG_path["required"]=true
CMD_GEN_ORES_newcmd_FLAG_path["description"]="Target file system directory where the new CLI project architecture will be initialized"
CMD_GEN_ORES_newcmd_FLAG_path["tipinput"]="Enter the target directory path for the new CLI project"



#
# Define validation schema and descriptive metadata for the --pkg flag
CMD_GEN_ORES_newcmd_FLAG_ORDER+=("pkg")

declare -gA CMD_GEN_ORES_newcmd_FLAG_pkg
CMD_GEN_ORES_newcmd_FLAG_pkg["long"]="pkg"
CMD_GEN_ORES_newcmd_FLAG_pkg["type"]="string"
CMD_GEN_ORES_newcmd_FLAG_pkg["required"]=true
CMD_GEN_ORES_newcmd_FLAG_pkg["min"]="3"
CMD_GEN_ORES_newcmd_FLAG_pkg["max"]="16"
CMD_GEN_ORES_newcmd_FLAG_pkg["description"]="Global corporate uppercase package identifier designation name (e.g., CLIENTCLI)"
CMD_GEN_ORES_newcmd_FLAG_pkg["tipinput"]="Enter the global package name (it will be automatically converted to UPPERCASE)"
CMD_GEN_ORES_newcmd_FLAG_pkg["transform"]='["shell_cli_transform_uppercase"]'



#
# Define validation schema and descriptive metadata for the --cmd flag
CMD_GEN_ORES_newcmd_FLAG_ORDER+=("cmd")

declare -gA CMD_GEN_ORES_newcmd_FLAG_cmd
CMD_GEN_ORES_newcmd_FLAG_cmd["long"]="cmd"
CMD_GEN_ORES_newcmd_FLAG_cmd["type"]="string"
CMD_GEN_ORES_newcmd_FLAG_cmd["required"]=true
CMD_GEN_ORES_newcmd_FLAG_cmd["min"]="3"
CMD_GEN_ORES_newcmd_FLAG_cmd["max"]="16"
CMD_GEN_ORES_newcmd_FLAG_cmd["description"]="Initial structural command tree action name to create inside the workspace"
CMD_GEN_ORES_newcmd_FLAG_cmd["tipinput"]="Enter the initial command tree action name"



#
# Define validation schema and descriptive metadata for the --summary flag
CMD_GEN_ORES_newcmd_FLAG_ORDER+=("summary")

declare -gA CMD_GEN_ORES_newcmd_FLAG_summary
CMD_GEN_ORES_newcmd_FLAG_summary["long"]="summary"
CMD_GEN_ORES_newcmd_FLAG_summary["type"]="string"
CMD_GEN_ORES_newcmd_FLAG_summary["required"]=true
CMD_GEN_ORES_newcmd_FLAG_summary["min"]="1"
CMD_GEN_ORES_newcmd_FLAG_summary["max"]="256"
CMD_GEN_ORES_newcmd_FLAG_summary["description"]="Brief single-line summary description of the generated command purpose for global help"
CMD_GEN_ORES_newcmd_FLAG_summary["tipinput"]="Enter a short, single-line summary of what this initial command does"



#
# Define validation schema and descriptive metadata for the --description flag
CMD_GEN_ORES_newcmd_FLAG_ORDER+=("description")

declare -gA CMD_GEN_ORES_newcmd_FLAG_description
CMD_GEN_ORES_newcmd_FLAG_description["long"]="description"
CMD_GEN_ORES_newcmd_FLAG_description["type"]="string"
CMD_GEN_ORES_newcmd_FLAG_description["required"]=true
CMD_GEN_ORES_newcmd_FLAG_description["min"]="1"
CMD_GEN_ORES_newcmd_FLAG_description["max"]="2048"
CMD_GEN_ORES_newcmd_FLAG_description["description"]="Full detailed architectural and operational explanation of the generated command"
CMD_GEN_ORES_newcmd_FLAG_description["tipinput"]="Enter a full, detailed operational explanation for this command"
