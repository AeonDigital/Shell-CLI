#!/usr/bin/env bash

# shell_cli_compile_flag_family — Compile and validate a collection of flag definitions
# belonging to a specific family.
# 
# Arguments
# - flagFamily: Prefix name defining the target flag family group.
# - flagOrderArray: Name of the indexed array specifying the execution sequence for
#   validation.
# 
# Global outputs
# - SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE: Stores descriptive compilation, missing reference,
#   or structure error messages.
# - SHELL_CLI_FLAG_COMPILED_FAMILY: Associative tracking matrix updated with a success
#   flag ('1') upon family completion.
# 
# Notes
# - Skips execution and returns 0 if the target family is already marked as compiled
#   in 'SHELL_CLI_FLAG_COMPILED_FAMILY'.
# - Enforces strict pre-flight validation on arguments (non-empty family, existing
#   and populated indexed order array).
# - Resolves dynamic symbols by mapping family prefixes to explicit flag associative
#   arrays, verifying their existence.
# - Processes compilation sequentially; any single flag compilation failure breaks
#   the loop and halts the family lifecycle.
# 
# Returns
# - 0: Success (all flags in the family compiled, cached, and validated).
# - 1+: Failure (invalid parameters, empty sequencing, missing sub-flag definition,
#   or downstream compilation error).
shell_cli_compile_flag_family() {
  local flagFamily="${1}"
  local flagOrderArray="${2}"

  # Reset global variables
  SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""

  local flagName=""
  local checkStatus=0
  local -a flagAssocNames=()

  if [ "${SHELL_CLI_FLAG_COMPILED_FAMILY["$flagFamily"]}" = "1" ]; then
    return 0
  fi

  if [ "${flagFamily}" = "" ]; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Flag family name is required."
    return 1
  fi

  if [ "${flagOrderArray}" = "" ]; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Default order array is required."
    return 1
  fi

  if ! shell_cli_utils_array_is_indexed "${flagOrderArray}"; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid default order array '${flagOrderArray}'. Expected indexed array (declare -a)."
    return 1
  fi

  # Loads the flag's associative array and checks if it has already been validated
  local -n arrayOrder="${flagOrderArray}"
  if [ "${#arrayOrder[@]}" = "0" ]; then
    SHELL_CLI_FLAG_COMPILED_FAMILY["${flagFamily}"]="1"
    return 0
  fi

  # Get entire assoc flag definition for this family and check if all exists
  for flagName in "${arrayOrder[@]}"; do
    flagName="${flagFamily}_${flagName}"

    if ! shell_cli_utils_array_is_assoc "${flagName}"; then
      SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid or undefined assoc flag '${flagName}'. Expected associative array (declare -A)."
      return 1
    fi

    flagAssocNames+=("${flagName}")
  done

  # Check all flags sequentially
  for flagName in "${flagAssocNames[@]}"; do
    shell_cli_compile_flag "${flagName}"
    checkStatus=$?

    if [ "${checkStatus}" != "0" ]; then
      return "${checkStatus}"
    fi
  done

  # Assign global variables
  SHELL_CLI_FLAG_COMPILED_FAMILY["${flagFamily}"]="1"

  return 0
}
