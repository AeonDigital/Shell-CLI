#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: main.sh
# DESCRIPTION: 
# ==============================================================================

# global variable indicating the load state of the Shell-CLI core.
# - Initialized to "-1" if not yet defined.
# - Updated by 'shell_cli_get_core_package' and 'shell_cli_preflight_load_core_engine'.
# - Used to determine whether the runtime engine is already active in the session.
if [ "${SHELL_CLI_CORE_LOAD}" = "" ]; then
  declare -g SHELL_CLI_CORE_LOAD="-1"
fi

# global variable controlling local development mode.
# - When set to "1", forces loading of source files directly from the local "src" directory.
# - Used primarily during development and testing to bypass central package download.
declare -g SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC="1"



# shell_cli_execute_command — orchestrate command execution.
#
# Arguments:
# - $@: user-provided CLI arguments (command name and context).
#
# Behavior:
# - Ensures the core package is available by invoking 'shell_cli_get_core_package'.
# - Loads the runtime engine with 'shell_cli_preflight_load_core_engine'.
# - Resolves the root path of the current script.
# - Prepares the command context with 'shell_cli_preflight_prepare_command'.
# - Terminates execution with exit code 1 if preparation fails.
#
# Returns:
# - 0: success (command prepared).
# - 1: failure (invalid context or missing assets).
shell_cli_execute_command() {
  shell_cli_client_start_engine "$@"

  local rootPath="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"

  #
  # Executes the CLI and, upon completion, unlocks the current process.
  # Important: never use 'exit' in your scripts, otherwise the process might get stuck.
  shell_cli_run "${rootPath}" "$@"
  return $?
}


shell_cli_client_start_engine() {
  if [ "${SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC}" = "1" ]; then
    local pathtoMainPkgSRC="$(cd "$(dirname "${BASH_SOURCE}")/../src" && pwd)"
    local arrMainPkgSRCFiles=($(find "${pathtoMainPkgSRC}" -type f -name "*.sh" | sort))

    for file in "${arrMainPkgSRCFiles[@]}"; do
      if [[ "${file}" == *_test.sh ]]; then
        continue
      fi
      . "${file}"
    done

    SHELL_CLI_CORE_LOAD="1"
    return 0
  fi

  shell_cli_client_load_core_engine
  shell_cli_preflight_load_core_engine "$@"
}



# shell_cli_client_load_core_engine — ensure Shell-CLI package availability.
#
# Arguments:
# - None (uses global state and environment variables).
#
# Behavior:
# - Checks if SHELL_CLI_CORE_LOAD indicates the engine is already loaded.
# - Resolves the central workspace directory under XDG_DATA_HOME or HOME.
# - Verifies presence of the engine package (package.sh).
# - If missing, provisions the workspace and attempts download via curl or wget.
# - On failure, emits error signage and terminates execution.
# - On success, sources the engine package and sets SHELL_CLI_CORE_LOAD to "0".
#
# Returns:
# - 0: success (engine package verified and loaded).
# - 1: failure (download error or missing package).
shell_cli_client_load_core_engine() {
  if [ "${SHELL_CLI_CORE_LOAD}" -ge "0" ]; then
    return 0
  fi

  SHELL_CLI_CORE_LOAD="-1"

  local xdgDataHome="${XDG_DATA_HOME:-${HOME}/.local/share}"
  local shellCLIDir="${xdgDataHome}/shell-cli"
  local shellCLIEnginePackage="${shellCLIDir}/package.sh"
  local shellCLIURLDownload="https://raw.githubusercontent.com/AeonDigital/Shell-CLI/refs/heads/main/package.sh"

  if [ ! -f "${shellCLIEnginePackage}" ]; then
    echo "================================================================================"
    echo "[RUN] Provisioning Shell-CLI"
    echo "================================================================================"
    echo "[ . ] Provisioning isolated shell-cli workspace environment..."
    mkdir -p "${shellCLIDir}"
    
    if command -v curl &>/dev/null; then
      curl -sSL "${shellCLIURLDownload}" -o "${shellCLIEnginePackage}"
    elif command -v wget &>/dev/null; then
      wget -qO "${shellCLIEnginePackage}" "${shellCLIURLDownload}"
    fi

    if [ ! -f "${shellCLIEnginePackage}" ]; then
      echo "[ x ] Download '${shellCLIURLDownload}' fail!"
      echo "================================================================================"
      echo "[ERR] Shell-CLI cannot start."
      echo "================================================================================"
      exit 1
    fi
    echo "================================================================================"
    echo "[OKK] Shell-CLI package is loaded to '${shellCLIEnginePackage}'."
    echo "================================================================================"
    echo ""
  fi

  # Boot up internal execution systems directly from the verified central path
  . "${shellCLIEnginePackage}"
  SHELL_CLI_CORE_LOAD="0"
}



# Starts execution of the command.
shell_cli_execute_command "$@"