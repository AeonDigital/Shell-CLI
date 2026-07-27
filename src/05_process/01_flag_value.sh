#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 05_process/01_flag_value.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_process_flag_value — process and validate a flag's input value.
#
# Arguments:
# - $1: name of the associative array defining the flag.
# - $2: raw input value for the flag.
#
# Behavior:
# - Compiles the flag definition to ensure consistency.
# - Initializes global variables for type, value, error prefix, and assoc order.
# - Validates against 'required' and 'default' properties.
# - If flag is array:
#   * Validates 'is_array', 'min_array', 'max_array'.
#   * Iterates over the array elements, collecting keys and values.
# - If flag is assoc:
#   * Validates 'is_assoc' and 'required_keys'.
#   * Populates SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER with the order of keys
#     as parsed.
#   * Iterates over this order to collect keys and values consistently.
# - If flag is single value:
#   * Stores a placeholder key "-" and the raw value.
# - Each collected value is validated atomically against all remaining
#   properties of the flag using shell_cli_process_flag_single_value.
#   * On failure, the error message is composed with the proper prefix and
#     returned immediately.
#   * On success, the normalized value replaces the original in flagValues.
# - After atomic validation, the normalized values are remounted into
#   SHELL_CLI_PROCESS_FLAG_VALUE:
#   * For single values, replaced directly.
#   * For arrays, elements updated in the array variable.
#   * For assoc, key/value pairs updated in the assoc variable.
# - Finally, resets all global process variables to ensure clean state.
#
# Returns:
# - 0: success (flag value normalized and validated).
# - 1+: failure (error message stored in SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE).
shell_cli_process_flag_value() {
  #
  # Check flag rules consistency
  shell_cli_compile_flag "${1}"
  local compileFlagStatus="$?"
  if [ "${compileFlagStatus}" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return "${compileFlagStatus}"
  fi

  local -a flagKeys=()
  local -a flagValues=()
  local typeOfValue="single"
  local arrayKeyType=""

  declare -gn flagAssocDefinition="${1}"
  SHELL_CLI_PROCESS_FLAG_TYPE="${flagAssocDefinition["type"]}"
  SHELL_CLI_PROCESS_FLAG_VALUE="${2}"
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX="[ x ][ --${flagAssocDefinition["long"]} ]"
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""
  SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()


  #
  # Check Required
  shell_cli_process_flag_value_against_prop_required "${flagAssocDefinition["required"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi
  #
  # Check Default
  shell_cli_process_flag_value_against_prop_default "${flagAssocDefinition["default"]}"
  if [ "$?" != "0" ]; then
    return 1
  fi




  #
  # Check Is Array
  if [ "${flagAssocDefinition["is_array"]}" = "1" ]; then
    typeOfValue="array"
    arrayKeyType="idx"

    shell_cli_process_flag_value_against_prop_is_array "${flagAssocDefinition["min_array"]}" "${flagAssocDefinition["max_array"]}"
    if [ "$?" != "0" ]; then
      return 1
    fi

    local i=""
    local v=""
    local -n tmpArray="${SHELL_CLI_PROCESS_FLAG_VALUE}"
    for i in "${!tmpArray[@]}"; do
      v="${tmpArray[${i}]}"
      flagKeys+=("${i}")
      flagValues+=("${v}")
    done
    unset -n tmpArray
  fi

  #
  # Check Is Assoc
  if [ "${flagAssocDefinition["is_assoc"]}" = "1" ]; then
    typeOfValue="assoc"
    arrayKeyType="key"

    shell_cli_process_flag_value_against_prop_is_assoc "${flagAssocDefinition["required_keys"]}"
    if [ "$?" != "0" ]; then
      return 1
    fi

    local k=""
    local v=""
    local -n tmpAssoc="${SHELL_CLI_PROCESS_FLAG_VALUE}"
    for k in "${!SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER[@]}"; do
      v="${tmpAssoc[${k}]}"
      flagKeys+=("${k}")
      flagValues+=("${v}")
    done
    unset -n tmpAssoc
  fi


  #
  # If is an single value
  if [ "${typeOfValue}" = "single" ]; then
    flagKeys+=("-")
    flagValues+=("${SHELL_CLI_PROCESS_FLAG_VALUE}")
  fi


  #
  # Check each value atomically
  local i=""
  local k=""
  local v=""
  for i in "${!flagKeys[@]}"; do
    k="${flagKeys[${i}]}"
    v="${flagValues[${i}]}"

    shell_cli_process_flag_single_value "${v}"
    if [ "$?" != 0 ]; then
      if [ "${singleValue}" = "0" ]; then
        errPrefix+="[ ${arrayKeyType}: ${k} ]"
      fi
      SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
      return 1
    fi

    flagValues["${i}"]="${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}"
  done





  #
  # remount value
  case "${typeOfValue}" in
    single)
      SHELL_CLI_PROCESS_FLAG_VALUE="${flagValues[0]}"
      ;;

    array)
      local i=""
      local -n tmpArray="${SHELL_CLI_PROCESS_FLAG_VALUE}"
      for i in "${!flagValues[@]}"; do
        tmpArray["${i}"]="${flagValues["${i}"]}"
      done
      unset -n tmpArray
      ;;

    assoc)
      local i=""
      local k=""
      local v=""
      local -n tmpAssoc="${SHELL_CLI_PROCESS_FLAG_VALUE}"
      for i in "${!flagValues[@]}"; do
        k="${flagKeys["${i}"]}"
        v="${flagValues["${i}"]}"

        tmpAssoc["${k}"]="${v}"
      done
      unset -n tmpAssoc
      ;;
  esac


  SHELL_CLI_PROCESS_FLAG_TYPE=""
  SHELL_CLI_PROCESS_FLAG_VALUE=""
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX=""
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""
  SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()

  return 0
}
