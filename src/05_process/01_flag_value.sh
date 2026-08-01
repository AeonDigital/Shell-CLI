#!/usr/bin/env bash

# shell_cli_process_flag_value - Orchestrate runtime validation, normalization, and structural assembly of flag inputs.
#
# Arguments
# - flagVarName: Name of the associative array definition scheme holding the rules.
# - rawInputValue: Target input payload string or pointer reference name to process.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Captures compilation breakdowns or downstream runtime validation faults.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER: Stores the sequenced key tracking array discovered during associative object parsing.
#
# Notes
# - Triggers pre-flight compilation check over the target definition schema rules before initiating any processing.
# - Pipeline Phase 1 (Hydration Constraints): Enforces baseline evaluation checks for 'required' and 'default' properties.
# - Pipeline Phase 2 (Collection Matrix): Detects and expands payload types. Splits elements into discrete flat tracking stacks 
#   for scalar string values, dynamic indexed arrays, or associative dictionary mappings.
# - Pipeline Phase 3 (Atomic Evaluation): Loops and pipes each detached element through 'shell_cli_process_flag_single_value'.
# - Pipeline Phase 4 (Reconstruction): Re-assembles all post-processed elements into their final scalar or vector structure formats.
# - Clean State: Destructively resets all internal global lifecycle variables to empty states upon final successful execution.
#
# Returns
# - 0: Success (flag payload structurally verified, normalized, and correctly updated in-memory).
# - 1+: Failure (rule violation breach, downstream compilation breakdown, or type constraint fault).
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
