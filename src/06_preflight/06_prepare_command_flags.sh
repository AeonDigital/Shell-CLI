#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# shell_cli_preflight_prepare_command_flags — validate and compile command flag 
# definitions.
#
# Arguments:
# - None (uses global variables populated during command preparation).
#
# Behavior:
# - Aborts if no root path is defined, or if the command tree is the default "_".
# - Defines global variables for the flag family, flag ordering array, and
#   canonical names of the action/validation functions.
# - Enforces conventions:
#   · Each command must declare an associative array named
#     <CMD_MAIN_REGISTRY>_FLAG containing 'cmd', 'summary', and 'description'.
#   · Each command must declare an indexed array named
#     <CMD_MAIN_REGISTRY>_FLAG_ORDER listing all flags in order.
#   · Each flag listed must have a corresponding associative array definition
#     with at least 'long' and 'short' keys.
# - Builds lookup maps:
#   · SHELL_CLI_COMMAND_FLAG_LONGNAME maps long flag names to their definitions.
#   · SHELL_CLI_COMMAND_FLAG_SHORTNAME maps short flag names to their long form.
# - Validates that the main action function exists, and optionally sets the
#   validation function if present.
# - Compiles both the Shell-CLI metaflags and the command-specific flags using
#   'shell_cli_compile_flag_family'.
#
# Returns:
# - 0: success (flags validated and compiled).
# - 1: failure (missing arrays, invalid flag definitions, or missing functions).
shell_cli_preflight_prepare_command_flags() {
  if [ "${SHELL_CLI_ROOT_PATH}" = "" ]; then
    return 1
  fi

  if [ "${SHELL_CLI_COMMAND_TREE}" = "_" ]; then
    return 0
  fi


  #
  # Define the context command global variables
  SHELL_CLI_COMMAND_FLAG_FAMILY="${SHELL_CLI_CMD_MAIN_REGISTRY}_FLAG"
  SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER="${SHELL_CLI_CMD_MAIN_REGISTRY}_FLAG_ORDER"

  SHELL_CLI_COMMAND_FN_ACTION="${SHELL_CLI_CMD_MAIN_REGISTRY,,}_action"
  SHELL_CLI_COMMAND_FN_VALIDATE="${SHELL_CLI_CMD_MAIN_REGISTRY,,}_validate"


  #
  # 1. checks if the command returns the record defined in the scope
  if ! shell_cli_utils_array_is_assoc "${SHELL_CLI_COMMAND_FLAG_FAMILY}"; then
    echo "[ERR] Command layout definition is missing."
    echo "      expected an associative array (declare -A) with the name '${SHELL_CLI_COMMAND_FLAG_FAMILY}'."
    echo "      containing 'cmd', 'summary' and 'description' keys."
    return 1
  fi


  #
  # 2. Checks if the flag ordenador array exists for the command being prepared.
  if ! shell_cli_utils_array_is_indexed "${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"; then
    echo "[ERR] The flag-ordering array was not defined."
    echo "      expected an indexed array (declare -a) with the name '${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}'."
    return 1
  fi


  #
  # 3. checks whether the flags defined in the ordenador array have their respective definitions
  local -n flagNameOrder="${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"
  if [ "${#flagNameOrder[@]}" -gt "0" ]; then
    local flagName=""
    local flagAssocName=""
    local flagLong=""
    local flagShort=""
    
    for flagName in "${flagNameOrder[@]}"; do
      flagAssocName="${SHELL_CLI_COMMAND_FLAG_FAMILY}_${flagName}"
      if shell_cli_utils_array_is_assoc "${flagAssocName}"; then
        echo "[ERR] The flag '${flagName}' does not have its corresponding definition."
        echo "      expected an associative array (declare -A) with the name '${flagAssocName}'."
        return 1
      fi

      local -n flagAssocDefinition="${flagAssocName}"
      flagLong="${flagAssocDefinition["long"]}"
      flagShort="${flagAssocDefinition["short"]}"
      SHELL_CLI_COMMAND_FLAG_LONGNAME["${flagLong}"]="${flagAssoc}"
      SHELL_CLI_COMMAND_FLAG_SHORTNAME["${flagShort}"]="${flagLong}"
      unset -n flagAssocDefinition
    done
  fi
  unset -n flagNameOrder


  #
  # 4. Checks if the command's main function actually exists.
  if ! declare -f "${SHELL_CLI_COMMAND_FN_ACTION}" >/dev/null; then
    echo "[ERR] Main action function '${SHELL_CLI_COMMAND_FN_ACTION}' is missing."
    return 1
  fi


  #
  # 5. Check if the command's special validation function is present.
  if ! declare -f "${SHELL_CLI_COMMAND_FN_VALIDATE}" >/dev/null; then
    SHELL_CLI_COMMAND_FN_VALIDATE=""
  fi


  #
  # 6. compiles engine Shell CLI metaflags
  if ! shell_cli_compile_flag_family "METAGFLAG" "SHELL_CLI_METAFLAG_DEFAULT_ORDER"; then
    echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return 1
  fi


  #
  # 7. compiles the command flags
  if ! shell_cli_compile_flag_family "${SHELL_CLI_COMMAND_FLAG_FAMILY}" "${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"; then
    echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return 1
  fi

  return 0
}
