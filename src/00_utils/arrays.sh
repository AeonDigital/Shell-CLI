#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/arrays.sh
# DESCRIPTION: General-purpose functions for arrays.
# ==============================================================================

# shell_cli_utils_array_is_indexed checks if it is a indexed array.
#
# Arguments:
# - arrName: name of the array to check
#
# Returns:
# - 0: if is indexed array (declare -a).
# - 1: if is not a indexed array.
shell_cli_utils_array_is_indexed() {
  local str_declare=$(declare -p "$1" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -a" ]]; then
    return 0
  fi
  return 1
}

# shell_cli_utils_array_is_assoc checks if it is a associative array.
#
# Arguments:
# - arrName: name of the array to check
#
# Returns:
# - 0: if is associative array (declare -A).
# - 1: if is not a associative array.
shell_cli_utils_array_is_assoc() {
  local str_declare=$(declare -p "$1" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -A" ]]; then
    return 0
  fi
  return 1
}
