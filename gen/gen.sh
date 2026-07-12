#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: main.sh
# DESCRIPTION: Main entrypoint executing core routing and compilation layers.
#              Package Context: GEN
# ==============================================================================

prepareCLIEnvironment() {
  local rootPath="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
  if [ ! -f "${rootPath}/globals/utils.sh" ]; then
    echo "[ERR] Critical Core Fault :: Corporate shared runtime utilities are missing at '${rootPath}/globals/utils.sh'."
    exit 1
  fi

  . "${rootPath}/globals/utils.sh"

  # ???
  local SHELL_CLI_LOCAL_LOAD_MAIN_PKG_SRC="1" # LOAD LOCAL CORE
  shell_cli_load_core_engine "$@"

  # ???
  if ! shell_cli_load_active_command "$1" "${rootPath}"; then
    exit 1
  fi
}
prepareCLIEnvironment "$1"


# Pass control directly to the central execution coordinator.
shell_cli_run "$@"
