#!/usr/bin/env bash

# shell_cli_preflight_prepare_input - Parse, normalize, and validate raw command-line interface parameter flags.
#
# Arguments
# - $@: Variable array of raw strings containing user-provided command-line arguments.
#
# Global outputs
# - SHELL_CLI_INPUT_RAW_FLAG: Indexed array holding the isolated raw flag strings discovered.
# - SHELL_CLI_INPUT_RAW_FLAG_ORDER: Indexed array tracking the exact chronological order of parsed long flags.
# - SHELL_CLI_INPUT_RAW_FLAG_ASSOC: Associative matrix mapping normalized long names to their evaluated final values.
# - SHELL_CLI_TRIGGER_HELP: Intercept flag toggled to '1' if help keywords or flags are identified in the stream.
# - SHELL_CLI_TRIGGER_INTERACTIVE: Intercept flag toggled to '1' if interactive wizards are requested by the user.
#
# Notes
# - Fast-Track Fallback: Short-circuits and returns 0 immediately if 'SHELL_CLI_TRIGGER_HELP' is pre-flight active.
# - Phase 1 (Stream Interception): Scans parameters to separate positional structures from options, intercepting reserved framework triggers.
# - Phase 2 (Payload Expansion): Loops through discovered tokens to split key-value boundaries ('key=value'), falling back to '1' for booleans.
# - Phase 3 (Normalization & Aliasing): Strips notation prefixes and cross-references short names against known mapping matrix aliases.
# - Phase 4 (Constraint Checking): Rejects unknown parameters, blocks duplicated options, and pipes payloads into 'shell_cli_process_flag_value'.
# - Diagnostic Stream: Echoes descriptive syntax, parameter, or validation error traces directly to standard output upon execution failure.
#
# Returns
# - 0: Success (CLI arguments successfully parsed, normalized, and mapped into the application state matrix).
# - 1: Failure (syntax violation, unknown parameter, duplication error, or downstream value parsing breakdown).
shell_cli_preflight_prepare_input() {
  if [ "${SHELL_CLI_TRIGGER_HELP}" = "1" ]; then
    return 0
  fi


  #
  # 1. Extracts each flag passed via the CLI based on its absolute position and 
  #    identifies the invocation of modes such as 'help' or 'interactive'.
  local arg=""
  local readingFlags="0"
  local flagKey=""

  for arg in "$@"; do
    if [ "${readingFlags}" -eq "0" ] && [ "${arg}" = "help" ]; then
      SHELL_CLI_TRIGGER_HELP="1"
      SHELL_CLI_TRIGGER_INTERACTIVE="0"
      return 0
    fi

    if [ "${arg:0:1}" = "-" ]; then
      readingFlags="1"
      SHELL_CLI_INPUT_RAW_FLAG+=("${arg}")

      flagKey="${arg%%=*}"
      if [[ "${flagKey}" =~ ^(--help|-h)$ ]]; then
        SHELL_CLI_TRIGGER_HELP="1"
        SHELL_CLI_TRIGGER_INTERACTIVE="0"
        return 0
      elif [[ "${flagKey}" =~ ^(--interactive|-itr)$ ]]; then
        SHELL_CLI_TRIGGER_INTERACTIVE="1"
      fi
    else
      if [ "${readingFlags}" -eq "1" ]; then
        echo "[ x ] Syntax Error :: Command '${arg}' discovered after flags stream initialization."
        return 1
      fi
    fi
  done

  if [ "${SHELL_CLI_TRIGGER_INTERACTIVE}" = "1" ]; then
    return 0
  fi



  #
  # 2. Processes each identified flag and extracts its name and value.
  local currentFlagRaw=""
  local currentFlagK=""
  local currentFlagKey=""
  local currentFlagValue=""
  local currentFlagAssocName=""
  for currentFlagRaw in "${SHELL_CLI_INPUT_RAW_FLAG[@]}"; do
    
    # If the flag is defined with a value, it splits each item into a key-value pair; 
    # if it lacks a defined value, it is treated as a boolean flag whose presence 
    # is always defined as value=1.
    if [[ "$currentFlagRaw" == *=* ]]; then
      currentFlagK="${currentFlagRaw%%=*}"
      currentFlagValue="${currentFlagRaw#*=}"
    else
      currentFlagK="${currentFlagRaw}"
      currentFlagValue="1"
    fi

    #
    # Remove '--' or '-' from the flag name.
    currentFlagKey="${currentFlagK}"
    currentFlagKey="${currentFlagKey#--}"
    currentFlagKey="${currentFlagKey#-}"

    #
    # Get the long name of the flag from its short version
    if [ "${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${currentFlagKey}"]}" != "" ]; then
      currentFlagKey=${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${currentFlagKey}"]}
    fi

    #
    # Checks if the flag really exists
    if [ "${SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${currentFlagKey}"]}" = "" ]; then
      echo "[ x ] Parameter Error :: Unknown flag '${currentFlagK}'."
      return 1
    fi

    #
    # Checks for duplicate flags.
    currentFlagAssocName="${SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${currentFlagKey}"]}"
    if [ "${currentFlagAssocName}" = "" ]; then
      echo "[ x ] Duplicated Error :: Parameter '${currentFlagK}' was provided multiple times."
      return 1
    fi

    #
    # Validate flag value
    shell_cli_process_flag_value "${currentFlagAssocName}" "${currentFlagValue}"
    if [ "$?" != "0" ]; then
      echo "${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
      return 1
    fi

    SHELL_CLI_INPUT_RAW_FLAG_ORDER+=("${currentFlagKey}")
    SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${currentFlagKey}"]="${currentFlagValue}"
  done


  return 0
}
