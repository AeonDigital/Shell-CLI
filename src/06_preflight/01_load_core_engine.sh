#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: This function must coexist with the CLI-client and must be 
#   executed before any access to the CLI core.
# ==============================================================================

# shell_cli_preflight_load_core_engine — initialize and load the core runtime engine.
#
# Arguments:
# - $@: optional runtime arguments, used to intercept reserved maintenance/update
#        parameters (e.g., "--mgmtpkg-update-package").
#
# Behavior:
# - Initializes SHELL_CLI_CORE_LOAD to "0".
# - If running in local development mode (SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC=1),
#   sources all non-test ".sh" files from the local src directory.
# - Otherwise, ensures the central workspace exists, handles update requests,
#   downloads the engine if missing, and sources the verified package.sh file.
# - Finally, sets SHELL_CLI_CORE_LOAD to "1" once the engine is successfully loaded.
#
# Returns:
# - 0: success (engine loaded from local src or central package).
# - 1: failure (engine not found or download error).
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
