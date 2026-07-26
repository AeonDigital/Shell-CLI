#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/arrays.sh
# DESCRIPTION: General-purpose functions for arrays.
# ==============================================================================

# shell_cli_utils_array_is_indexed — checks if it is an indexed array.
#
# Arguments:
# - arrName: name of the array to check
#
# Returns:
# - 0: if is indexed array (declare -a).
# - 1: if is not an indexed array, is empty or does not exist.
shell_cli_utils_array_is_indexed() {
  local str_declare=$(declare -p "${1}" 2>/dev/null)
  if [[ "${str_declare}" =~ ^"declare -a" ]]; then
    return 0
  fi
  return 1
}

# shell_cli_utils_array_is_assoc — checks if it is an associative array.
#
# Arguments:
# - arrName: name of the array to check
#
# Returns:
# - 0: if is associative array (declare -A).
# - 1: if is not an associative array, is empty, or does not exist.
shell_cli_utils_array_is_assoc() {
  local str_declare=$(declare -p "${1}" 2>/dev/null)
  if [[ "${str_declare}" =~ ^"declare -A" ]]; then
    return 0
  fi
  return 1
}

# shell_cli_utils_array_indexed_clone — clones the specified indexed 
# array into a new indexed array with the provided name.
#
# Arguments:
# - originalArray: name of the original indexed array to copy
# - cloneArrayName: name of the destination array to be created
#
# Returns:
# - 0: if the array was successfully cloned.
# - 1: if originalArray is not an indexed array, or arguments are missing.
#
# Side-Effects:
# - Creates or overwrites the cloneArrayName as a global indexed array (-g).
shell_cli_utils_array_indexed_clone() {
  local originalArray="${1}"
  local cloneArrayName="${2}"

  if ! shell_cli_utils_array_is_indexed "${originalArray}"; then
    return 1
  fi

  eval "declare -ga ${cloneArrayName}=()"
  local -n objArray="${originalArray}"
  local -n tmpClone="${cloneArrayName}"
  
  local v=""
  for v in "${objArray[@]}"; do
    tmpClone+=("${v}")
  done

  return 0
}

# shell_cli_utils_array_assoc_clone — clones the specified associative 
# array into a new associative array with the provided name.
#
# Arguments:
# - originalAssoc: name of the original associative array
# - cloneAssocName: name of the new associative array.
#
# Returns:
# - 0: if the associative array was successfully cloned.
# - 1: if originalAssoc is not an associative array, or arguments are missing.
#
# Side-Effects:
# - Creates or overwrites the cloneAssocName as a global associative array (-g).
shell_cli_utils_array_assoc_clone() {
  local originalAssoc="${1}"
  local cloneAssocName="${2}"

  if ! shell_cli_utils_array_is_assoc "${originalAssoc}"; then
    return 1
  fi

  eval "declare -gA ${cloneAssocName}=()"
  local -n objAssoc="${originalAssoc}"
  local -n tmpClone="${cloneAssocName}"
  
  local k=""
  local v=""
  for k in "${!objAssoc[@]}"; do
    v="${objAssoc[${k}]}"
    tmpClone["${k}"]="${v}"
  done

  return 0
}