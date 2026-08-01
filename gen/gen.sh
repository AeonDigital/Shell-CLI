#!/usr/bin/env bash

# SHELL_CLI_CORE_LOAD - Lifecycle state tracker monitoring the framework core engine ignition level.
#
# - Initialized to a baseline fallback token string of "-1" to indicate an unbooted framework environment.
# - Updated in-place to "0" when the distribution pack is cached, and to "1" upon full memory tree injection.
# - Evaluated dynamically across bootloader layers to short-circuit redundant package provisioning tasks.
if [ "${SHELL_CLI_CORE_LOAD}" = "" ]; then
  declare -g SHELL_CLI_CORE_LOAD="-1"
fi

# SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC - Operational environment bypass toggle for local sandbox development.
#
# - Hardcoded to "1" to force the client application to source files directly from a local development tree.
# - Used to suppress automated remote network updates, enabling offline debugging and structural hacking cycles.
declare -g SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC="1"





# shell_cli_execute_command - Entrypoint lifecycle coordinator orquestrating application bootstrap and loop invocation.
#
# Arguments
# - $@: Variable array of raw strings containing user-provided command-line arguments and flags.
#
# Notes
# - Triggers 'shell_cli_client_start_engine' to assert framework presence before initializing any business path.
# - Resolves the runtime caller absolute directory root context safely using standard BASH_SOURCE symbol folding.
# - Dispatches full control to 'shell_cli_run' to execute parsing, validation, interceptors, and final action loops.
#
# Returns
# - 0: Success (application pipeline completed its execution cycle smoothly).
# - 1+: Failure (framework bootstrap breakdown, missing resource pathways, or client action exceptions).
shell_cli_execute_command() {
  shell_cli_client_start_engine "$@"

  local rootPath="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"

  #
  # Executes the CLI and, upon completion, unlocks the current process.
  # Important: never use 'exit' in your scripts, otherwise the process might get stuck.
  shell_cli_run "${rootPath}" "$@"
  return $?
}





# shell_cli_client_start_engine - Core engine bootloader routing asset injection through local paths or central fetchers.
#
# Arguments
# - $@: Variable array of operational command-line tokens forwarded to downstream preflight loaders.
#
# Notes
# - Sandbox Branch: Traverses relative paths to loop-source disk assets recursively from 'src/' if local mode is engaged.
# - Production Branch: Defers lifecycle routing to remote downloaders and standard centralized preflight engines.
# - Explicitly updates 'SHELL_CLI_CORE_LOAD' to lock the environment state once loading hooks complete.
#
# Returns
# - 0: Success (framework source files or centralized asset layouts are successfully linked in memory).
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





# shell_cli_client_load_core_engine - Infrastructure distribution provisioner safeguarding engine deployment from remote endpoints.
#
# Arguments
# - None.
#
# Notes
# - Audits central user workspace environment path metrics inside XDG or baseline home directories.
# - Deploys fallback dynamic command utilities ('curl' or 'wget') to fetch the central core engine asset if absent from disk.
# - Terminal Breaks: Aborts and forces a destructive 'exit 1' pipeline break if network connection or storage faults happen.
# - Sources the fetched central distribution pack directly into the active terminal instance workspace tree.
#
# Returns
# - 0: Success (target engine distribution package discovered, cached, and prepared for preflight initialization).
# - 1: Structure Fault (unreachable remote endpoints or execution environment setup breaches).
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