#!/usr/bin/env bash

# shell_cli_process_flag_value — Orchestrate runtime validation, normalization, and
# structural assembly of flag inputs.
# 
# Arguments
# - flagVarName: Name of the associative array definition scheme holding the rules.
# - rawInputValue: Target input payload string or pointer reference name to process.
# 
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Captures compilation breakdowns or
#   downstream runtime validation faults.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER: Stores the sequenced key tracking array
#   discovered during associative object parsing.
# 
# Notes
# - Triggers pre-flight compilation check over the target definition schema rules
#   before initiating any processing.
# - Pipeline Phase 1 (Hydration Constraints): Enforces baseline evaluation checks
#   for 'required' and 'default' properties.
# - Pipeline Phase 2 (Collection Matrix): Detects and expands payload types. Splits
#   elements into discrete flat tracking stacks for scalar string values, dynamic
#   indexed arrays, or associative dictionary mappings.
# - Pipeline Phase 3 (Atomic Evaluation): Loops and pipes each detached element through
#   'shell_cli_process_flag_single_value'.
# - Pipeline Phase 4 (Reconstruction): Re-assembles all post-processed elements into
#   their final scalar or vector structure formats.
# - Clean State: Destructively resets all internal global lifecycle variables to
#   empty states upon final successful execution.
# 
# Returns
# - 0: Success (flag payload structurally verified, normalized, and correctly updated
#   in-memory).
# - 1+: Failure (rule violation breach, downstream compilation breakdown, or type
#   constraint fault).
shell_cli_process_flag_value() {
  local flagVarName="${1}"
  local rawInputValue="${2}"

  # Reset global error state context before pre-flight checks
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""

  # Check flag rules consistency
  shell_cli_compile_flag "${flagVarName}"
  local compileFlagStatus="$?"
  if [ "${compileFlagStatus}" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return "${compileFlagStatus}"
  fi

  local -a flagKeys=()
  local -a flagValues=()
  local typeOfValue="single"
  local arrayKeyType=""
  local errPrefix=""
  local i=""
  local k=""
  local v=""

  declare -gn flagAssocDefinition="${flagVarName}"
  SHELL_CLI_PROCESS_FLAG_TYPE="${flagAssocDefinition["type"]}"
  SHELL_CLI_PROCESS_FLAG_VALUE="${rawInputValue}"
  SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX="[ x ][ --${flagAssocDefinition["long"]} ]"
  SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()

  # Check Required
  shell_cli_process_flag_value_against_prop_required "${flagAssocDefinition["required"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
    return 1
  fi

  # Check Default
  shell_cli_process_flag_value_against_prop_default "${flagAssocDefinition["default"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
    return 1
  fi

  # Check Is Array
  if [ "${flagAssocDefinition["is_array"]}" = "1" ]; then
    typeOfValue="array"
    arrayKeyType="idx"


    # Empty values ​​pass through, as the 'required' property should have been handled
    # before reaching this point.
    if [ "${rawInputValue}" = "" ]; then
      return 0
    fi


    shell_cli_process_flag_value_against_prop_is_array "${flagAssocDefinition["min_array"]}" "${flagAssocDefinition["max_array"]}"
    if [ "$?" != "0" ]; then
      SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
      return 1
    fi

    local -n tmpArray="${SHELL_CLI_PROCESS_FLAG_VALUE}"
    for i in "${!tmpArray[@]}"; do
      v="${tmpArray[${i}]}"
      flagKeys+=("${i}")
      flagValues+=("${v}")
    done
    unset -n tmpArray
  fi

  # Check Is Assoc
  if [ "${flagAssocDefinition["is_assoc"]}" = "1" ]; then
    typeOfValue="assoc"
    arrayKeyType="key"

    # Empty values ​​pass through, as the 'required' property should have been handled
    # before reaching this point.
    if [ "${rawInputValue}" = "" ]; then
      return 0
    fi

    shell_cli_process_flag_value_against_prop_is_assoc "${flagAssocDefinition["required_keys"]}"
    if [ "$?" != "0" ]; then
      SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
      return 1
    fi

    local -n tmpAssoc="${SHELL_CLI_PROCESS_FLAG_VALUE}"
    for k in "${!SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER[@]}"; do
      v="${tmpAssoc[${k}]}"
      flagKeys+=("${k}")
      flagValues+=("${v}")
    done
    unset -n tmpAssoc
  fi

  # If is a single value
  if [ "${typeOfValue}" = "single" ]; then
    flagKeys+=("-")
    flagValues+=("${SHELL_CLI_PROCESS_FLAG_VALUE}")
  fi

  # Check each value atomically
  for i in "${!flagKeys[@]}"; do
    k="${flagKeys[${i}]}"
    v="${flagValues[${i}]}"

    shell_cli_process_flag_single_value "${v}"
    if [ "$?" != 0 ]; then
      errPrefix="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX}"
      if [ "${typeOfValue}" != "single" ]; then
        errPrefix+="[ ${arrayKeyType}: ${k} ]"
      fi
      SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
      return 1
    fi

    flagValues["${i}"]="${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}"
  done


  # Remount architecture value structures
  case "${typeOfValue}" in
    single)
      SHELL_CLI_PROCESS_FLAG_VALUE="${flagValues[0]}"
      ;;

    array)
      local flagValueArrayName="${flagVarName,,}_array"
      eval "declare -ga ${flagValueArrayName}=()"

      local -n tmpArrayRef="${flagValueArrayName}"
      for i in "${!flagValues[@]}"; do
        tmpArrayRef["${i}"]="${flagValues["${i}"]}"
      done

      unset -n tmpArrayRef
      SHELL_CLI_PROCESS_FLAG_VALUE="${flagValueArrayName}"
      ;;

    assoc)
      local flagValueAssocName="${flagVarName,,}_assoc"
      eval "declare -gA ${flagValueAssocName}=()"

      local -n tmpAssocRef="${flagValueAssocName}"
      for i in "${!flagValues[@]}"; do
        k="${flagKeys["${i}"]}"
        v="${flagValues["${i}"]}"

        tmpAssocRef["${k}"]="${v}"
      done

      unset -n tmpAssocRef
      SHELL_CLI_PROCESS_FLAG_VALUE="${flagValueAssocName}"
      ;;
  esac

  return 0
}
