#!/usr/bin/env bash

# shell_cli_preflight_prepare_target_resource_flags - Compile configuration schemas and build runtime lookup maps for command flags.
#
# Arguments
# - None.
#
# Notes
# - Fast-Track Fallback: Short-circuits and returns 0 immediately if 'SHELL_CLI_RESOURCE_TREE' points to the root execution context (".").
# - Phase 1 (Compilation): Invokes 'shell_cli_compile_flag_family' to run strict hydration and validation cycles over the active flag family matrix.
# - Phase 2 (Lookup Indexing): Iterates sequentially through the validated flag ordering array to resolve dynamic reference pointers.
# - Mapping Matrix: Populates 'SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME' with canonical pointers and 'SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME' with aliases.
# - Diagnostic Stream: Intercepts downstream validation breaks to strip prefixes and echo clean diagnostic errors to standard output upon failure.
#
# Returns
# - 0: Success (target flag schemas successfully compiled, structured, and indexed in lookup tables).
# - 1: Failure (validation breach or structure fault detected during flag family compilation).
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
