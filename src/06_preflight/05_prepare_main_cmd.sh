#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_prepare_main_cmd — validate and prepare command execution context.
#
# Arguments:
# - mainCmdRootPath: base directory where command sources are located.
# - mainCmdName: normalized name of the main command (entrypoint).
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
shell_cli_preflight_prepare_main_cmd() {
  #
  # 1. If shell cli not initializated by 'shell_cli_preflight_load_core_engine'
  if [ "${SHELL_CLI_CORE_LOAD}" != "1" ]; then
    echo "[ERR] :: Shell CLI not found or not load."
    return 1
  fi

  shell_cli_preflight_reset

  local errTitle="[ERR] :: Invalid command definition."
  local errIndent="         "

  local mainCmdRootPath="${1}"; shift
  local mainCmdName=$(shell_cli_type_normalize_string "${1,,}"); shift
  local mainCmdRegistry="SHELL_CLI_CMD_${mainCmdName^^}"
  local mainCmdRegistryResourceOrder="${mainCmdRegistry}_RESOURCE_ORDER"



  #
  # 2. Check if the main command name is omitted.
  if [ "${mainCmdName}" = "" ]; then
    echo "[ERR] :: Missing operational main command name context."
    return 1
  fi

  #
  # 3. Checks if 'mainCmdRootPath' exists
  if [ ! -d "${mainCmdRootPath}" ]; then
    echo "${errTitle}"
    echo "${errIndent}> '${mainCmdName}'"
    echo "${errIndent}Command Root Path '${mainCmdRootPath}' does not exists."
    return 1
  fi

  #
  # 4. Checks if the command entrypoint file exists.
  if [ ! -f "${mainCmdRootPath}/${mainCmdName}.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Command entrypoint '${mainCmdName}' does not exists."
    echo "${errIndent}Missing file '${mainCmdRootPath}/${mainCmdName}.sh'."
    return 1
  fi

  #
  # 5. Checks if the command main registry file exists.
  if [ ! -f "${mainCmdRootPath}/cmd.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Command registry 'cmd.sh' does not exists."
    echo "${errIndent}Missing file '${mainCmdRootPath}/cmd.sh'."
    return 1
  fi
  . "${mainCmdRootPath}/cmd.sh"



  #
  # 6. Source and validates the registration of the main command
  shell_cli_preflight_check_command_registry "${mainCmdRegistry}"
  local s="$?"
  if [ "${s}" = "1" ]; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${mainCmdRegistry}' associative array (declare -A)."
    return 1
  elif [ "${s}" = "2" ]; then
    echo "${errTitle}"
    echo "${errIndent}Assoc '${mainCmdRegistry}' missing one or more mandatory keys."
    echo "${errIndent}Expected 'cmd', 'summary', and 'description' to exist and be populated."
    return 1
  fi



  #
  # 7. validates the existence of the sub-command register array
  if ! shell_cli_utils_array_is_indexed "${mainCmdRegistryResourceOrder}"; then
    echo "${errTitle}"
    echo "${errIndent}Resource register array '${mainCmdRegistryResourceOrder}' not found."
    return 1
  fi



  #
  # 8. Loads all global asset scripts.
  if [ -d "${mainCmdRootPath}/globals" ]; then
    local file=""
    local tgtGlobalFiles=($(find "${mainCmdRootPath}/globals" -type f -name "*.sh" | sort))
    
    for file in "${tgtGlobalFiles[@]}"; do
      if [[ "${file}" == *_test.sh ]]; then
        continue
      fi
      . "${file}"
    done
  fi


  #
  # 9. Compiles engine Shell CLI metaflags
  if ! shell_cli_compile_flag_family "METAFLAG" "SHELL_CLI_METAFLAG_DEFAULT_ORDER"; then
    local errPrefix="\[ERR\] :: "
    echo "${errTitle}"
    echo "${errIndent}${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE/${errPrefix}/}"
    return 1
  fi



  #
  # Define the context command global variables
  SHELL_CLI_MAIN_CMD_ROOT_PATH="${mainCmdRootPath}"
  SHELL_CLI_MAIN_CMD_NAME="${mainCmdName}"
  SHELL_CLI_MAIN_CMD_REGISTRY="${mainCmdRegistry}"
  SHELL_CLI_MAIN_CMD_REGISTRY_ORDER="${mainCmdRegistryResourceOrder}"

  return 0
}
