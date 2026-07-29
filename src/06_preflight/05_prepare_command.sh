#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_prepare_command — validate and prepare command execution context.
#
# Arguments:
# - rootPath: base directory where command sources are located.
# - commandName: normalized name of the main command (entrypoint).
# - $@: remaining arguments representing the command tree (subcommands).
#
# Behavior:
# - Resets all global variables to ensure a clean state before preparation.
# - Confirms that the Shell-CLI core engine is initialized.
# - Validates the existence of:
#   · The root path directory.
#   · The entrypoint script for the main command (<commandName>.sh).
#   · The main registry file (cmd.sh).
# - Enforces conventions:
#   · The client must declare an associative array named SHELL_CLI_CMD_<CMDNAME>
#     containing 'cmd', 'summary', and 'description' keys.
#   · The client must declare an indexed array named
#     SHELL_CLI_CMD_<CMDNAME>_SUBCOMMAND_ORDER listing all available subcommands.
# - Builds the command tree from user arguments, defaulting to "_" if no subcommand
#   is provided.
# - Validates that the command directory exists for the assembled tree.
# - Loads global asset scripts (from "globals") and command-specific scripts
#   (from the resolved command directory), excluding test files.
# - Updates global variables with the validated execution context:
#   · SHELL_CLI_ROOT_PATH, SHELL_CLI_COMMAND_NAME, SHELL_CLI_COMMAND_DIR,
#     SHELL_CLI_COMMAND_PATH, SHELL_CLI_COMMAND_TREE.
#   · SHELL_CLI_CMD_MAIN_REGISTRY and SHELL_CLI_CMD_MAIN_REGISTRY_ORDER,
#     pointing to the client-defined arrays for main command metadata and
#     subcommand ordering.
#
# Returns:
# - 0: success (command context prepared and globals set).
# - 1: failure (missing engine, invalid arguments, nonexistent files or arrays).
shell_cli_preflight_prepare_command() {
  shell_cli_preflight_reset


  local rootPath="${1}"; shift
  local commandName=$(shell_cli_type_normalize_string "${2,,}"); shift

  local commandDir="${rootPath}/src"
  local commandPath=""
  local commandTree=""
  local commandObjPrefix="SHELL_CLI_CMD_${commandName}"



  #
  # 1. If shell cli not initializated by 'shell_cli_preflight_load_core_engine'
  if [ "${SHELL_CLI_CORE_LOAD}" != "1" ]; then
    echo "[ERR] Shell CLI not found or not load."
    return 1
  fi

  #
  # 2. Blocks execution if the main command name is omitted.
  if [ "${commandName}" = "" ]; then
    echo "[ERR] Missing operational main command name context."
    return 1
  fi

  #
  # 3. Checks if 'rootPath' exists
  if [ ! -d "${rootPath}" ]; then
    echo "[ERR] Command Root Path '${rootPath}' does not exists."
    return 1
  fi

  #
  # 4. Checks if the command entrypoint file exists.
  if [ ! -f "${rootPath}/${commandName}.sh" ]; then
    echo "[ERR] Command entrypoint '${commandName}' does not exists."
    echo "      Missing file '${rootPath}/${commandName}.sh'."
    return 1
  fi

  #
  # 5. Checks if the command main registry file exists.
  if [ ! -f "${rootPath}/cmd.sh" ]; then
    echo "[ERR] Command registry 'cmd.sh' does not exists."
    echo "      Missing file '${rootPath}/cmd.sh'."
    return 1
  fi

  #
  # 6. validates the registration of the main command
  shell_cli_preflight_check_command_registry "${commandObjPrefix}"
  local s="$?"
  if "${s}" = "1" ; then
    echo "[ERR] Command registry '${commandObjPrefix}' does not exists."
    echo "      Expected an associative array (declare -A) containing"
    echo "      'cmd', 'summary' and 'description' keys."
    return 1
  elif "${s}" = "2" ; then
    echo "[ERR] Command registry '${commandObjPrefix}' is corrupted."
    echo "      The keys 'cmd', 'summary', and 'description' are expected"
    echo "       to exist and be populated."
    return 1
  fi

  #
  # 7. validates the existence of the sub-command register array
  if ! shell_cli_utils_array_is_indexed "${commandObjPrefix}_SUBCOMMAND_ORDER"; then
    echo "[ERR] Sub-command register array '${commandObjPrefix}_SUBCOMMAND_ORDER' not found."
    return 1
  fi



  #
  # 8. Assembles the command tree to be executed.
  local arg=""
  for arg in "$@"; do
    arg=$(shell_cli_type_normalize_string "${arg,,}")
    if [ "${arg}" != "" ]; then
      if [ "${arg:0:1}" = "-" ]; then
        break
      fi

      commandDir+="/${arg}"
      commandPath+="${arg}/"
      commandTree+="${arg} "
      commandObjPrefix+="_${arg}"
    fi
  done

  commandPath="${commandPath%/}"
  commandTree="${commandTree% }"

  if [ "${commandTree}" = "" ]; then
    commandDir+="/_"
    commandPath="_"
    commandTree="_"
  fi



  #
  # 9. Checks if the path to the command directory exists.
  if [ ! -d "${commandDir}" ]; then
    echo "[ERR] Command tree context '${commandName} ${commandTree}' not found."
    echo "      Missing directory '${commandDir}'."
    return 1
  fi

  #
  # 10. Loads all global asset scripts.
  local file=""
  if [ -d "${rootPath}/globals" ]; then
    local tgtGlobalFiles=($(find "${rootPath}/globals" -type f -name "*.sh" | sort))
    
    for file in "${tgtGlobalFiles[@]}"; do
      if [[ "${file}" == *_test.sh ]]; then
        continue
      fi
      . "${file}"
    done
  fi

  #
  # 11. Loads all scripts specific to the command tree context.
  local tgtCommandFiles=($(find "${commandDir}" -type f -name "*.sh" | sort))
  for file in "${tgtCommandFiles[@]}"; do
    if [[ "${file}" == *_test.sh ]]; then
      continue
    fi
    . "${file}"
  done



  #
  # Define the context command global variables
  SHELL_CLI_ROOT_PATH="${rootPath}"
  SHELL_CLI_COMMAND_NAME="${commandName}"
  SHELL_CLI_COMMAND_DIR="${commandDir}"
  SHELL_CLI_COMMAND_PATH="${commandPath}"
  SHELL_CLI_COMMAND_TREE="${commandTree}"

  SHELL_CLI_CMD_MAIN_REGISTRY="${commandObjPrefix}"
  SHELL_CLI_CMD_MAIN_REGISTRY_ORDER="${commandObjPrefix}_SUBCOMMAND_ORDER"

  return 0
}
