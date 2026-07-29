#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

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
  SHELL_CLI_PROCESS_LOCK_PID="-"
  SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
}
