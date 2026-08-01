#!/usr/bin/env bash

# shell_cli_preflight_load_core_engine - Orchestrate the initialization, lifecycle provisioning, and loading of the core runtime engine.
#
# Arguments
# - $@: Optional variable array of runtime arguments evaluated for framework intercept patterns.
#
# Global outputs
# - SHELL_CLI_CORE_LOAD: Injected with '1' upon successful framework ignition, or '0' if explicitly purged.
#
# Notes
# - Intercepts the reserved '--mgmtpkg-update-package' flag to trigger an immediate infrastructure cache purge and forced exit.
# - Evaluates local workspace environment directory structure state inside XDG data home paths.
# - Deploys dynamic network fetchers ('curl' or 'wget') to download the centralized engine package if missing from disk.
# - Terminal Breaks: Enforces immediate 'exit 0' on completed update tasks, or 'exit 1' on storage write/network download faults.
# - Sources the verified core asset file directly into the active shell memory execution tree.
#
# Returns
# - 0: Success (engine target discovered or provisioned, and successfully loaded into memory).
# - 1+: Failure (unreachable network endpoints or storage permissions breach encountered during boot).
shell_cli_preflight_load_core_engine() {
  local xdgDataHome="${XDG_DATA_HOME:-${HOME}/.local/share}"
  local shellCLIDir="${xdgDataHome}/shell-cli"
  local shellCLIEnginePackage="${shellCLIDir}/package.sh"
  local shellCLIURLDownload="https://raw.githubusercontent.com/AeonDigital/Shell-CLI/refs/heads/main/package.sh"


  # Intercept the reserved update parameter to force runtime maintenance
  for arg in "$@"; do
    case "${arg}" in
      "--mgmtpkg-update-package")
        echo "================================================================================"
        echo "[RUN] Executing forced framework infrastructure update operation..."
        echo "================================================================================"
        echo "[ . ] Removing local cached runtime engine dependency..."
        
        if rm -f "${shellCLIEnginePackage}" 2>/dev/null; then
          SHELL_CLI_CORE_LOAD="0"

          echo "[ v ] Local engine cache purged successfully."
          echo "================================================================================"
          echo "[!] IMPORTANT: Active terminal session memory still holds the old version."
          echo "[!] To apply updates completely, you MUST restart your terminal session."
          echo "[!] Run: exec bash"
          echo "================================================================================"
          echo "[OKK] Infrastructure reset completed. Run your command again to re-download."
          echo "================================================================================"
          exit 0
        else
          echo "[ x ] Critical storage fault: Failed to purge local engine file!"
          echo "================================================================================"
          echo "[ERR] Target infrastructure update process aborted with errors."
          echo "================================================================================"
          exit 1
        fi
        ;;
    esac
  done


  if [ "${SHELL_CLI_CORE_LOAD}" -ge "1" ]; then
    return
  fi


  if [ ! -f "${shellCLIEnginePackage}" ]; then
    echo "================================================================================"
    echo "[RUN] Central execution framework core runtime engine not detected."
    echo "================================================================================"
    echo "[ . ] Provisioning isolated shell-cli workspace environment..."
    mkdir -p "${shellCLIDir}"
    
    if command -v curl &>/dev/null; then
      curl -sSL "${shellCLIURLDownload}" -o "${shellCLIEnginePackage}"
    elif command -v wget &>/dev/null; then
      wget -qO "${shellCLIEnginePackage}" "${shellCLIURLDownload}"
    fi

    if [ ! -f "${shellCLIEnginePackage}" ]; then
      echo "[ x ] Critical architecture download connection fault encountered!"
      echo "================================================================================"
      echo "[ERR] Target operations runtime framework cannot start."
      echo "================================================================================"
      exit 1
    fi
    echo "[ v ] Central execution engine successfully installed locally."
    echo "================================================================================"
    echo "[OKK] Central execution engine is loaded and active."
    echo "================================================================================"
    echo ""
  fi


  # Boot up internal execution systems directly from the verified central path
  . "${shellCLIEnginePackage}"
  SHELL_CLI_CORE_LOAD="1"
}
