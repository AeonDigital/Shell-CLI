#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_check_command_registry — validate existence and integrity of a command registry.
#
# Arguments:
# - assocCmdName: name of the associative array that defines the command registry.
#
# Behavior:
# - Verifies that the given array exists and is associative.
# - If the array has already been checked (special key '__checked' set to "1"),
#   returns success immediately to avoid redundant validation.
# - Ensures that the required keys 'cmd' and 'summary' exist
#   and are populated with non-empty values.
# - The 'description' key is optional.
# - Marks the array as validated by setting '__checked' to "1".
#
# Returns:
# - 0: success (array exists, required keys are present and populated).
# - 1: failure (array does not exist or is not associative).
# - 2: failure (array exists but required keys are missing or empty).
shell_cli_preflight_check_command_registry() {
  local assocCmdName="${1}"

  if ! shell_cli_utils_array_is_assoc "${assocCmdName}"; then
    return 1
  fi

  local checkedRef="${assocCmdName}[__checked]"
  if [ "${!checkedRef}" = "1" ]; then
    return 0
  fi

  local requiredKeys=("cmd" "summary")
  local k=""
  local kRef=""
  local kVal=""

  for k in "${requiredKeys[@]}"; do
    kRef="${assocCmdName}["${k}"]"
    kVal=$(shell_cli_type_normalize_string "${!kRef}")
    if [ "${!kVal}" = "" ]; then
      return 2
    fi
  done

  eval "${assocCmdName}[__checked]=1"
  return 0
}
