#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_process_lock — enforce process sandboxing.
#
# Arguments:
# - None.
#
# Behavior:
# - Checks if a process lock is already active with the same PID.
# - If so, blocks execution and emits error messages to prevent nested inline calls.
# - Otherwise, activates the lock by setting SHELL_CLI_PROCESS_LOCK_PID to BASHPID
#   and SHELL_CLI_PROCESS_LOCK_ACTIVE to "1".
#
# Returns:
# - 0: success (lock activated).
# - 1: failure (nested execution detected)..
shell_cli_preflight_process_lock() {
  if [ "${SHELL_CLI_PROCESS_LOCK_ACTIVE}" = "1" ] && [ "${SHELL_CLI_PROCESS_LOCK_PID}" = "${BASHPID}" ]; then
    echo "[ERR] Critical Architecture Panic :: Inline nested command invocation detected!"
    echo "[ERR] Context: Concurrent execution sharing the same active memory stack frame is strictly prohibited."
    echo "[ERR] Resolution: Wrap your programmatic downstream calls using standard isolated sub-shell tokens: ( shell_cli_run ... )"
    return 1
  fi

  # Activate the process locks for the current pipeline instance context
  SHELL_CLI_PROCESS_LOCK_PID="${BASHPID}"
  SHELL_CLI_PROCESS_LOCK_ACTIVE="1"
}
