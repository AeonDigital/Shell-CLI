#!/usr/bin/env bash

# shell_cli_preflight_prepare_target_resource_flags - validate and compile command flag 
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
#   · SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME maps long flag names to their definitions.
#   · SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME maps short flag names to their long form.
# - Validates that the main action function exists, and optionally sets the
#   validation function if present.
# - Compiles both the Shell-CLI metaflags and the command-specific flags using
#   'shell_cli_compile_flag_family'.
#
# Returns:
# - 0: success (flags validated and compiled).
# - 1: failure (missing arrays, invalid flag definitions, or missing functions).
shell_cli_preflight_prepare_target_resource_flags() {
  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    return 0
  fi


  #
  # 1. Compiles resource flags
  if ! shell_cli_compile_flag_family "${SHELL_CLI_RESOURCE_FLAG_FAMILY}" "${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"; then
    local errTitle="[ERR] :: Invalid resource flag definition."
    local errIndent="         "
    local errPrefix="\[ERR\] :: "

    echo "${errTitle}"
    echo "${errIndent}${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE/${errPrefix}/}"
    return 1
  fi


  #
  # 2. checks whether the flags defined in the ordenador array have their respective definitions
  local -n arrayResourceRegistryOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
  if [ "${#arrayResourceRegistryOrder[@]}" -gt "0" ]; then
    local flagName=""
    local flagLong=""
    local flagShort=""
    local flagAssocName=""
    
    for flagName in "${arrayResourceRegistryOrder[@]}"; do
      flagAssocName="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName,,}"
      local -n flagAssocDefinition="${flagAssocName}"

      flagLong="${flagAssocDefinition["long"]}"
      flagShort="${flagAssocDefinition["short"]}"

      SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${flagLong}"]="${flagAssocName}"
      if [ "${flagShort}" != "" ]; then
        SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${flagShort}"]="${flagLong}"
      fi

      unset -n flagAssocDefinition
    done
  fi
  unset -n arrayResourceRegistryOrder


  return 0
}
