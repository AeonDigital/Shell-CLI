#!/usr/bin/env bash

# shell_cli_preflight_prepare_main_cmd — Bootstrap, validate, and orchestrate the
# execution context for a main command entrypoint.
# 
# Arguments
# - mainCmdRootPath: Base directory where command sources, registries, and asset
#   files are located.
# - mainCmdName: Raw string representing the name of the main target executable command.
# 
# Global outputs
# - SHELL_CLI_MAIN_CMD_ROOT_PATH: Assigned with the verified root path directory
#   string.
# - SHELL_CLI_MAIN_CMD_NAME: Assigned with the normalized lowercase identifier of
#   the main command.
# - SHELL_CLI_MAIN_CMD_REGISTRY: Pointer string reference targeting the user-defined
#   associative registry array.
# - SHELL_CLI_MAIN_CMD_REGISTRY_ORDER: Pointer string reference targeting the user-defined
#   indexed subcommands order array.
# 
# Notes
# - Pre-flight Guard: Aborts execution immediately if the core engine framework state
#   is not fully loaded ('SHELL_CLI_CORE_LOAD' != 1).
# - Phase 1 (Sanitization & Reset): Purges previous environment state by executing
#   'shell_cli_preflight_reset' and normalizes inputs.
# - Phase 2 (Disk Integrity): Verifies physical existence of the root path, entrypoint
#   script, and core 'cmd.sh' layout structure.
# - Phase 3 (Schema Compliance): Evaluates client-side conventions by sourcing arrays
#   and validating metadata completeness.
# - Phase 4 (Asset Ingestion): Automatically searches and sources global script files
#   located in the 'globals/' subdirectory, ignoring test files.
# - Phase 5 (Metaflag Compilation): Compiles the internal core configuration constraints
#   by triggering 'shell_cli_compile_flag_family'.
# - Echoes descriptive diagnostic error trace messages directly to stdout/stderr
#   upon encountering framework configuration blocks.
# 
# Returns
# - 0: Success (command architecture verified, global context injected, and framework
#   ready for execution loop).
# - 1: Failure (missing engine core, directory/file structure faults, or invalid
#   array convention declarations).
shell_cli_preflight_prepare_main_cmd() {
  # 
  # 1. If shell cli not initializated
  if [ "${SHELL_CLI_CORE_LOAD}" != "1" ]; then
    echo "[ERR] :: Shell CLI not found or not load."
    return 1
  fi

  shell_cli_preflight_reset

  local errTitle="[ERR] :: Invalid command definition."
  local errIndent="         "

  local mainCmdRootPath="${1}"; shift
  shell_cli_type_normalize_string "${1,,}"; shift
  local mainCmdName="${SHELL_CLI_FN_RETURN//-/_}"


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
