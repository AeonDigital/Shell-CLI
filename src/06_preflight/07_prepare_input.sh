#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_prepare_input — parse and validate raw CLI input flags.
#
# Arguments:
# - $@: user-provided CLI arguments (flags and values).
#
# Behavior:
# - Detects reserved modes ("help" and "interactive") and sets triggers accordingly.
# - Collects raw flags into SHELL_CLI_COMMAND_POSIT_FLAG_RAW_INPUT.
# - Splits flags into key-value pairs, treating flags without values as booleans.
# - Normalizes short flags into their long equivalents using
#   SHELL_CLI_COMMAND_FLAG_SHORTNAME.
# - Validates that each flag exists in SHELL_CLI_COMMAND_FLAG_LONGNAME.
# - Prevents duplicate flags by checking against the associative input array.
# - Populates SHELL_CLI_COMMAND_ASSOC_FLAG_RAW_INPUT and
#   SHELL_CLI_COMMAND_ARRAY_FLAG_RAW_INPUT_ORDER with validated flags.
#
# Returns:
# - 0: success (flags parsed and globals populated).
# - 1: failure (syntax error, unknown flag, or duplicate flag).
shell_cli_preflight_prepare_input() {
  #
  # 1. Extracts each flag passed via the CLI based on its absolute position and 
  #    identifies the invocation of modes such as 'help' or 'interactive'.
  local arg=""
  local readingFlags=0
  local flagKey=""

  for arg in "$@"; do
    if [ "${readingFlags}" -eq 0 ] && [ "${arg}" = "help" ]; then
      SHELL_CLI_COMMAND_TRIGGER_HELP="1"
      SHELL_CLI_COMMAND_TRIGGER_INTERACTIVE="0"
      return 0
    fi

    # Identifies reserved flags:
    #   --help, -h
    #   --interactive, -itr
    if [ "${arg:0:1}" = "-" ]; then
      readingFlags="1"
      SHELL_CLI_COMMAND_POSIT_FLAG_RAW_INPUT+=("${arg}")

      flagKey="${arg%%=*}"
      if [[ "${flagKey}" =~ ^(--help|-h)$ ]]; then
        SHELL_CLI_COMMAND_TRIGGER_HELP="1"
        SHELL_CLI_COMMAND_TRIGGER_INTERACTIVE="0"
        return 0
      elif [[ "${flagKey}" =~ ^(--interactive|-itr)$ ]]; then
        SHELL_CLI_COMMAND_TRIGGER_INTERACTIVE="1"
      fi

    # If it doesn't start with '-' but the flag stream had 
    # already begun, we have a syntax error.
    elif [ "${readingFlags}" -eq "1" ]; then
      echo "[ x ] Syntax Error :: Command '${arg}' discovered after flags stream initialization."
      return 1
    fi
  done

  if [ "${SHELL_CLI_COMMAND_TRIGGER_INTERACTIVE}" = "1" ]; then
    return 0
  fi



  #
  # 2. Processes each identified flag and extracts its name and value.
  local currentFlagRaw=""
  local currentFlagK=""
  local currentFlagKey=""
  local currentFlagValue=""
  for currentFlagRaw in "${SHELL_CLI_COMMAND_POSIT_FLAG_RAW_INPUT[@]}"; do
    
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
    if [ "${SHELL_CLI_COMMAND_FLAG_SHORTNAME["${currentFlagKey}"]}" != "" ]; then
      currentFlagKey=${SHELL_CLI_COMMAND_FLAG_SHORTNAME["${currentFlagKey}"]}
    fi

    #
    # Checks if the flag really exists
    if [ "${SHELL_CLI_COMMAND_FLAG_LONGNAME["${currentFlagKey}"]}" = "" ]; then
      echo "[ x ] Parameter Error :: Unknown flag '${currentFlagK}' provided."
      return 1
    fi

    #
    # Checks for duplicate flags.
    if [ -n "${SHELL_CLI_COMMAND_ASSOC_FLAG_RAW_INPUT["${currentFlagKey}"]+exists}" ]; then
      echo "[ x ] Duplicated Error :: Parameter '${currentFlagK}' was provided multiple times."
      return 1
    fi

    SHELL_CLI_COMMAND_ASSOC_FLAG_RAW_INPUT["${currentFlagKey}"]="${currentFlagValue}"
    SHELL_CLI_COMMAND_ARRAY_FLAG_RAW_INPUT_ORDER=("${currentFlagKey}")
  done

  return 0
}
