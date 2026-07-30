#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_prepare_target_resource — validate and prepare command execution context.
#
# Arguments:
# - mainCmdRootPath: base directory where command sources are located.
# - mainCmdName: normalized name of the main command (entrypoint).
# - $@: remaining arguments representing the command tree (subcommands).
#
# Behavior:
# - Resets all global variables to ensure a clean state before preparation.
# - Confirms that the Shell-CLI core engine is initialized.
# - Validates the existence of:
#   · The root path directory.
#   · The entrypoint script for the main command (<mainCmdName>.sh).
#   · The main registry file (cmd.sh).
# - Enforces conventions:
#   · The client must declare an associative array named SHELL_CLI_CMD_<CMDNAME>
#     containing 'cmd', 'summary', and 'description' keys.
#   · The client must declare an indexed array named
#     SHELL_CLI_CMD_<CMDNAME>_RESOURCE_ORDER listing all available subcommands.
# - Builds the command tree from user arguments, defaulting to "_" if no subcommand
#   is provided.
# - Validates that the command directory exists for the assembled tree.
# - Loads global asset scripts (from "globals") and command-specific scripts
#   (from the resolved command directory), excluding test files.
# - Updates global variables with the validated execution context:
#   · SHELL_CLI_MAIN_CMD_ROOT_PATH, SHELL_CLI_MAIN_CMD_NAME, SHELL_CLI_RESOURCE_PATH,
#     SHELL_CLI_RESOURCE_TREE.
#   · SHELL_CLI_RESOURCE_REGISTRY and SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER,
#     pointing to the client-defined arrays for main command metadata and
#     subcommand ordering.
#
# Returns:
# - 0: success (command context prepared and globals set).
# - 1: failure (missing engine, invalid arguments, nonexistent files or arrays).
shell_cli_preflight_prepare_target_resource() {

  #
  # 1. If no resource is defined, evoque the main command
  local resourceName=$(shell_cli_type_normalize_string "${1,,}"); shift
  if [ "${resourceName}" == "" ]; then
    SHELL_CLI_RESOURCE_TREE="."
    return 0
  fi
  if [ "${resourceName}" == "help" ]; then
    SHELL_CLI_RESOURCE_TREE="."

    SHELL_CLI_TRIGGER_HELP="1"
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
    return 0
  fi

  local errTitle="[ERR] :: Invalid resource definition."
  local errIndent="         "
  
  local triggerHelp="0"


  local mainCmdName="${SHELL_CLI_MAIN_CMD_NAME}"
  local resourcePath="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/src/${resourceName}"
  local resourceCmdTree="${resourceName}"
  local resourceRegistry="SHELL_CLI_CMD_${SHELL_CLI_MAIN_CMD_NAME^^}_${resourceName^^}"
  
  local resourceRegistryFlagOrder=""
  local resourceFunctionAction=""
  local resourceFunctionValidate=""
  local resourceFlagFamily=""
  local resourceFlagFamilyOrder=""



  #
  # 2. Assembles the command tree to be executed.
  local arg=""
  for arg in "$@"; do
    arg=$(shell_cli_type_normalize_string "${arg,,}")
    if [ "${arg}" != "" ]; then
      if [ "${arg:0:1}" = "-" ]; then
        break
      fi
      if [ "${arg}" = "help" ]; then
        triggerHelp="1"
        break
      fi

      resourcePath+="/${arg}"
      resourceCmdTree+=" ${arg}"
      resourceRegistry+="_${arg^^}"
    fi
  done
  resourceRegistryFlagOrder="${resourceRegistry}_FLAG_ORDER"
  resourceFunctionAction="${resourceRegistry,,}_action"
  resourceFunctionValidate="${resourceRegistry,,}_validate"
  resourceFlagFamily="${resourceRegistry}_FLAG"
  resourceFlagFamilyOrder="${resourceRegistry}_FLAG_ORDER"


  #
  # 2. Checks if the path to the selected resource exists.
  if [ ! -d "${resourcePath}" ]; then
    echo "${errTitle}"
    echo "${errIndent}Source code not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing directory '${resourcePath}'."
    return 1
  fi

  #
  # 3. checks for the existence of the 'flags.sh' file for the selected resource..
  if [ ! -f "${resourcePath}/flags.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Definition flags not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing file '${resourcePath}/flags.sh'."
    return 1
  fi
  . "${resourcePath}/flags.sh"



  #
  # 4. Source and validates the registration of the main command
  shell_cli_preflight_check_command_registry "${resourceRegistry}"
  local s="$?"
  if [ "${s}" = "1" ]; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${resourceRegistry}' associative array (declare -A)."
    return 1
  elif [ "${s}" = "2" ]; then
    echo "${errTitle}"
    echo "${errIndent}Assoc '${resourceRegistry}' missing one or more mandatory keys."
    echo "${errIndent}Expected 'cmd', 'summary', and 'description' to exist and be populated."
    return 1
  fi



  #
  # 5. validates the existence of the sub-command register array
  if ! shell_cli_utils_array_is_indexed "${resourceRegistryFlagOrder}"; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${resourceRegistryFlagOrder}' indexed array (declare -a)."
    return 1
  fi



  #
  # 6. checks whether the flags defined in the ordenador array have their respective definitions
  local -n arrayResourceRegistryOrder="${resourceRegistryFlagOrder}"
  if [ "${#arrayResourceRegistryOrder[@]}" -gt "0" ]; then
    local flagName=""
    local flagAssocName=""
    
    for flagName in "${arrayResourceRegistryOrder[@]}"; do
      flagAssocName="${resourceRegistry}_FLAG_${flagName,,}"
      if ! shell_cli_utils_array_is_assoc "${flagAssocName}"; then
        echo "${errTitle}"
        echo "${errIndent}The flag '${flagName}' does not have its corresponding definition..."
        echo "${errIndent}expected an associative array (declare -A) with the name '${flagAssocName}'."
        return 1
      fi
    done
  fi
  unset -n arrayResourceRegistryOrder



  #
  # 7. checks for the existence of the 'action.sh' file for the selected resource..
  if [ ! -f "${resourcePath}/action.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Entrypoint not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing file '${resourcePath}/action.sh'."
    return 1
  fi
  . "${resourcePath}/action.sh"



  #
  # 8. Checks if the command's main function actually exists.
  if ! declare -f "${resourceFunctionAction}" >/dev/null; then
    echo "${errTitle}"
    echo "${errIndent}Main function '${resourceFunctionAction}' is missing."
    return 1
  fi

  #
  # 9. Check if the command's special validation function is present.
  if ! declare -f "${resourceFunctionValidate}" >/dev/null; then
    resourceFunctionValidate=""
  fi


  #
  # Define the resource global variables
  SHELL_CLI_RESOURCE_PATH="${resourcePath}"
  SHELL_CLI_RESOURCE_NAME="${resourceName}"
  SHELL_CLI_RESOURCE_TREE="${resourceCmdTree}"
  SHELL_CLI_RESOURCE_REGISTRY="${resourceRegistry}"
  SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER="${resourceRegistryFlagOrder}"
  SHELL_CLI_RESOURCE_FUNCTION_ACTION="${resourceFunctionAction}"
  SHELL_CLI_RESOURCE_FUNCTION_VALIDATE="${resourceFunctionValidate}"
  SHELL_CLI_RESOURCE_FLAG_FAMILY="${resourceFlagFamily}"
  SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER="${resourceFlagFamilyOrder}"

  if [ "${triggerHelp}" == "1" ]; then
    SHELL_CLI_TRIGGER_HELP="1"
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
  fi

  return 0
}
