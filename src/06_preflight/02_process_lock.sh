#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# SHELL_CLI_PROCESS_LOCK_PID - global variable storing the process identifier (PID).
#
# - Updated when a process lock is activated.
# - Used to detect nested executions sharing the same memory stack frame.
declare -g SHELL_CLI_PROCESS_LOCK_PID=""


# SHELL_CLI_PROCESS_LOCK_ACTIVE — global variable acting as a boolean flag.
#
# - "1" indicates that a process lock is active for the current pipeline.
# - "0" indicates no active lock.
declare -g SHELL_CLI_PROCESS_LOCK_ACTIVE="0"





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



# shell_cli_preflight_process_unlock — release process sandboxing lock.
#
# Arguments:
# - None.
#
# Behavior:
# - Clears the process lock by resetting SHELL_CLI_PROCESS_LOCK_PID and
#   SHELL_CLI_PROCESS_LOCK_ACTIVE to default values.
#
# Returns:
# - 0: always succeeds (lock released).
shell_cli_preflight_process_unlock() {
  SHELL_CLI_PROCESS_LOCK_PID=""
  SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
}
