#!/usr/bin/env bash

# shell_cli_preflight_process_lock — Enforce strict single-process sandboxing to
# prevent memory stack collision.
# 
# Arguments
# - None.
# 
# Global outputs
# - SHELL_CLI_PROCESS_LOCK_PID: Updated with the current 'BASHPID' to anchor the
#   active execution context.
# - SHELL_CLI_PROCESS_LOCK_ACTIVE: Toggled to '1' to signal an active and locked
#   pipeline state.
# 
# Notes
# - Detects and blocks concurrent downstream calls attempting to share the same active
#   memory stack frame.
# - Evaluates state synchronization by cross-referencing the current 'BASHPID' against
#   existing global locks.
# - Emits explicit structural error logs to stderr with architectural remediation
#   steps when a violation occurs.
# 
# Returns
# - 0: Success (process lock successfully acquired and registered).
# - 1: Architecture Panic (nested inline execution detected within the same stack
#   context).
shell_cli_preflight_process_lock() {
  if [ "${SHELL_CLI_PROCESS_LOCK_ACTIVE}" = "1" ] && [ "${SHELL_CLI_PROCESS_LOCK_PID}" = "${BASHPID}" ]; then
    echo "[ERR] Critical Architecture Panic :: Inline nested command invocation detected!"
    echo "[ERR] Context: Concurrent execution sharing the same active memory stack frame is strictly prohibited."
    echo "[ERR] Resolution: Wrap your programmatic downstream calls using standard isolated sub-shell tokens: ( shell_cli ... )"
    return 1
  fi

  # Activate the process locks for the current pipeline instance context
  SHELL_CLI_PROCESS_LOCK_PID="${BASHPID}"
  SHELL_CLI_PROCESS_LOCK_ACTIVE="1"
}
