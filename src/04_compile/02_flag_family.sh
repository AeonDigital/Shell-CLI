#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/01_check_rules.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_compile_flag_family normalizes, validates, and asserts all flag specifications
# for the entire specified family.
#
# Arguments:
# - flagFamily: name (prefix) of the flag definitions to be checked.
# - flagOrderArray: name of the indexed array that orders this family flag.
#
# Returns:
# - 0: if all flag properties of the entire family are valid.
# - 1: if any flag property are invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE'
shell_cli_compile_flag_family() {
  local flagFamily="$1"
  local flagOrderArray="$2"


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

  if ! shell_cli_utils_array_is_indexed "$flagOrderArray"; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid default order array '$flagOrderArray'. Expected indexed array (declare -a)."
    return 1
  fi


  #
  # Loads the flag's associative array and checks if it has already been validated.
  local -n arrayOrder="${flagOrderArray}"
  if [ "${#arrayOrder[@]}" = "0" ]; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: invalid order definition '$flagOrderArray'; empty array."
    return 1
  fi

  #
  # Get entire assoc flag definition for this family and chek if all exists
  local -a flagAssocNames=()
  local flagName=""
  for flagName in "${arrayOrder[@]}"; do
    flagName="${flagFamily}_${flagName}"

    if ! shell_cli_utils_array_is_assoc "$flagName"; then
      SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid or undefined assoc flag '$flagName'. Expected associative array (declare -A)."
      return 1
    fi

    flagAssocNames+=("${flagName}")
  done



  #
  # check all flags
  local checkStatus="0"
  for flagName in "${flagAssocNames[@]}"; do
    shell_cli_compile_flag "${flagName}"
    checkStatus=$?

    if [ "$checkStatus" != "0" ]; then
      return $checkStatus
    fi
  done


  SHELL_CLI_FLAG_COMPILED_FAMILY["$flagFamily"]="1"
  return 0
}