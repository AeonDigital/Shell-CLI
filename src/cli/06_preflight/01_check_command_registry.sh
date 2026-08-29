#!/usr/bin/env bash

# shell_cli_preflight_check_command_registry — Validate the structural existence
# and baseline integrity of a command registry schema.
# 
# Arguments
# - assocCmdName: Name of the associative array representing the targeted command
#   registry.
# 
# Notes
# - Skips evaluation and returns 0 immediately if the registry has already been cached
#   with '__checked=1'.
# - Enforces strict presence checks for mandatory schema descriptor keys: 'cmd' and
#   'summary'.
# - Treats the 'description' property as an optional metadata field.
# - Mutates the target associative array by injecting the success token '__checked=1'
#   upon valid verification.
# 
# Returns
# - 0: Success (registry exists, satisfies all structural compliance checks, or was
#   previously cached).
# - 1: Structure Fault (target variable reference does not exist or is not a valid
#   associative array).
# - 2: Schema Fault (target array exists but violates compliance by missing mandatory
#   keys or values).
shell_cli_preflight_check_command_registry() {
  local assocCmdName="${1}"

  if ! shell_cli_utils_array_is_assoc "${assocCmdName}"; then
    return 1
  fi

  local -n assocCmdRegistry="${assocCmdName}"
  if [ "${assocCmdRegistry["__checked"]}" = "1" ]; then
    return 0
  fi

  local requiredKeys=("cmd" "summary")
  local k=""
  for k in "${requiredKeys[@]}"; do
    if [ "${assocCmdRegistry["${k}"]}" = "" ]; then
      return 2
    fi
  done

  assocCmdRegistry["__checked"]="1"
  return 0
}
