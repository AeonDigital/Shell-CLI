#!/usr/bin/env bash

# shell_cli_preflight_prepare_target_resource — Resolve, validate, and build the
# runtime execution context for subcommands.
# 
# Arguments
# - $@: Variable array of terminal input arguments used to map and navigate the subcommand
#   hierarchy tree.
# 
# Global outputs
# - SHELL_CLI_RESOURCE_PATH: Assigned with the resolved target directory path containing
#   the resource source assets.
# - SHELL_CLI_RESOURCE_NAME: Assigned with the normalized lowercase base identifier
#   of the primary subcommand.
# - SHELL_CLI_RESOURCE_TREE: Assigned with the fully assembled chronological string
#   sequence representing the command tree path.
# - SHELL_CLI_RESOURCE_REGISTRY: Pointer string mapping to the target resource's
#   user-defined associative registry array.
# - SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER: Pointer string targeting the structural
#   indexed array defining action order sequences.
# - SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER: Pointer string targeting the structural
#   indexed array defining option processing sequences.
# - SHELL_CLI_RESOURCE_FUNCTION_ACTION: String identifier matching the dynamic executable
#   target function hook name.
# - SHELL_CLI_RESOURCE_FUNCTION_VALIDATE: String identifier matching the custom operational
#   data payload validator hook name.
# - SHELL_CLI_RESOURCE_FLAG_FAMILY: String prefix identifying the isolated variable
#   family containing all assigned metaflag matrix objects.
# - SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER: Pointer string linking to the strict sequence
#   array map of option parameters.
# - SHELL_CLI_TRIGGER_HELP: Intercept flag toggled to '1' if a fallback help condition
#   parameter is explicitly isolated.
# - SHELL_CLI_TRIGGER_INTERACTIVE: Intercept flag toggled to '0' to disable workflow
#   wizards when global help indicators fire.
# 
# Notes
# - Fast-Track Fallbacks: Short-circuits execution with 0 immediately when inputs
#   are empty or resolve to global framework help keywords.
# - Phase 1 (Tree Assembly): Iterates positionals to dynamically append path nodes
#   and symbol strings until it encounters flags or help triggers.
# - Phase 2 (Disk Verification): Validates file placement requirements for 'cmd.sh',
#   'flags.sh', and 'action.sh' structures at the target path.
# - Phase 3 (Schema Validation): Enforces data integrity checks over target command
#   registries, sequence vectors, and flag arrays.
# - Phase 4 (Functional Mapping): Assures explicit presence of the core execution
#   function block, assigning validation hooks optionally.
# - Diagnostic Stream: Emits verbose trace layouts directly to standard output upon
#   architecture configuration breaches.
# 
# Returns
# - 0: Success (target resource context mapped, dynamic components sourced, and parameters
#   ready for the core interpreter loop).
# - 1: Failure (broken route mappings, physical file omissions, missing function
#   hooks, or malformed schema arrays).
shell_cli_preflight_prepare_target_resource() {

  # 
  # 1. If no resource is defined, evoque the main command
  shell_cli_type_normalize_string "${1,,}"; shift
  local resourceName="${SHELL_CLI_FN_RETURN}"
  if [ "${resourceName}" == "" ]; then
    SHELL_CLI_RESOURCE_TREE="."
    return 0
  fi
  if [ "${resourceName}" == "help" ]; then
    SHELL_CLI_RESOURCE_TREE="."

    SHELL_CLI_TRIGGER_HELP="1"
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
    return 0
  fi

  local errTitle="[ERR] :: Invalid resource definition."
  local errIndent="         "

  local triggerHelp="0"


  local mainCmdName="${SHELL_CLI_MAIN_CMD_NAME}"
  local resourcePath="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/src/${resourceName//-/_}"
  local resourceCmdTree="${resourceName}"
  local resourceRegistry="SHELL_CLI_CMD_${SHELL_CLI_MAIN_CMD_NAME^^}_${resourceName^^}"
  resourceRegistry="${resourceRegistry//-/_}"

  local resourceRegistryActionOrder=""
  local resourceRegistryFlagOrder=""
  local resourceFunctionAction=""
  local resourceFunctionValidate=""
  local resourceFlagFamily=""
  local resourceFlagFamilyOrder=""



  # 
  # 2. Assembles the command tree to be executed.
  local arg=""
  for arg in "$@"; do
    shell_cli_type_normalize_string "${arg,,}"
    arg="${SHELL_CLI_FN_RETURN}"
    if [ "${arg}" != "" ]; then
      if [ "${arg:0:1}" = "-" ]; then
        break
      fi
      if [ "${arg}" = "help" ]; then
        triggerHelp="1"
        break
      fi

      resourcePath+="/src/${arg}"
      resourceCmdTree+=" ${arg}"
      resourceRegistry+="_${arg^^}"
    fi
  done
  resourceRegistryActionOrder="${resourceRegistry}_ACTION_ORDER"
  resourceRegistryFlagOrder="${resourceRegistry}_FLAG_ORDER"
  resourceFunctionAction="${resourceRegistry,,}_action"
  resourceFunctionValidate="${resourceRegistry,,}_validate"
  resourceFlagFamily="${resourceRegistry}_FLAG"
  resourceFlagFamilyOrder="${resourceRegistry}_FLAG_ORDER"


  # 
  # 2. Checks if the path to the selected resource exists.
  if [ ! -d "${resourcePath}" ]; then
    echo "${errTitle}"
    echo "${errIndent}Source code not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing directory '${resourcePath}'."
    return 1
  fi

  # 
  # 3. checks for the existence of the 'cmd.sh' file for the selected resource.
  if [ ! -f "${resourcePath}/cmd.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Definition resource not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing file '${resourcePath}/cmd.sh'."
    return 1
  fi
  . "${resourcePath}/cmd.sh"

  # 
  # 4. Source and validates the registration of the main command
  shell_cli_preflight_check_command_registry "${resourceRegistry}"
  local s="$?"
  if [ "${s}" = "1" ]; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${resourceRegistry}' associative array (declare -A)."
    return 1
  elif [ "${s}" = "2" ]; then
    echo "${errTitle}"
    echo "${errIndent}Assoc '${resourceRegistry}' missing one or more mandatory keys."
    echo "${errIndent}Expected 'cmd', 'summary', and 'description' to exist and be populated."
    return 1
  fi

  # 
  # 5. validates the existence of the sub-resource order register array
  if ! shell_cli_utils_array_is_indexed "${resourceRegistryActionOrder}"; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${resourceRegistryActionOrder}' indexed array (declare -a)."
    return 1
  fi





  # 
  # 6. checks for the existence of the 'flags.sh' file for the selected resource..
  if [ ! -f "${resourcePath}/flags.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Definition flags not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing file '${resourcePath}/flags.sh'."
    return 1
  fi
  . "${resourcePath}/flags.sh"

  # 
  # 7. validates the existence of the sub-command register array
  if ! shell_cli_utils_array_is_indexed "${resourceRegistryFlagOrder}"; then
    echo "${errTitle}"
    echo "${errIndent}Not found '${resourceRegistryFlagOrder}' indexed array (declare -a)."
    return 1
  fi

  # 
  # 8. checks whether the flags defined in the ordenador array have their respective
  #    definitions
  local -n arrayResourceRegistryOrder="${resourceRegistryFlagOrder}"
  if [ "${#arrayResourceRegistryOrder[@]}" -gt "0" ]; then
    local flagName=""
    local flagAssocName=""
    local flagRefAssocName=""

    for flagName in "${arrayResourceRegistryOrder[@]}"; do
      flagAssocName="${resourceRegistry}_FLAG_${flagName,,}"
      if ! shell_cli_utils_array_is_assoc "${flagAssocName}"; then
        flagRefAssocName="${!flagAssocName}"

        if shell_cli_utils_array_is_assoc "${flagRefAssocName}"; then
          shell_cli_utils_array_assoc_clone "${flagRefAssocName}" "${flagAssocName}"
          if [ $? -eq 0 ]; then
            if shell_cli_utils_array_is_assoc "${flagAssocName}_OVERRIDE"; then
              local -n assoc_flag="${flagAssocName}"
              local -n assoc_override="${flagAssocName}_OVERRIDE"
              local k=""
              for k in "${!assoc_override[@]}"; do
                assoc_flag["${k}"]="${assoc_override["${k}"]}"
              done
            fi
          fi
        fi
      fi

      if ! shell_cli_utils_array_is_assoc "${flagAssocName}"; then
        echo "${errTitle}"
        echo "${errIndent}The flag '${flagName}' does not have its corresponding definition..."
        echo "${errIndent}expected an associative array (declare -A) with the name '${flagAssocName}'."
        return 1
      fi
    done
  fi
  unset -n arrayResourceRegistryOrder

  # 
  # 9. checks for the existence of the 'action.sh' file for the selected resource..
  if [ ! -f "${resourcePath}/action.sh" ]; then
    echo "${errTitle}"
    echo "${errIndent}Entrypoint not found for > '${mainCmdName} ${resourceCmdTree}'."
    echo "${errIndent}Missing file '${resourcePath}/action.sh'."
    return 1
  fi
  . "${resourcePath}/action.sh"

  # 
  # 10. Checks if the command's main function actually exists.
  if ! declare -f "${resourceFunctionAction}" >/dev/null; then
    echo "${errTitle}"
    echo "${errIndent}Main function '${resourceFunctionAction}' is missing."
    return 1
  fi

  # 
  # 11. Check if the command's special validation function is present.
  if ! declare -f "${resourceFunctionValidate}" >/dev/null; then
    resourceFunctionValidate=""
  fi





  # 
  # Define the resource global variables
  SHELL_CLI_RESOURCE_PATH="${resourcePath}"
  SHELL_CLI_RESOURCE_NAME="${resourceName}"
  SHELL_CLI_RESOURCE_TREE="${resourceCmdTree}"
  SHELL_CLI_RESOURCE_REGISTRY="${resourceRegistry}"
  SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER="${resourceRegistryActionOrder}"
  SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER="${resourceRegistryFlagOrder}"
  SHELL_CLI_RESOURCE_FUNCTION_ACTION="${resourceFunctionAction}"
  SHELL_CLI_RESOURCE_FUNCTION_VALIDATE="${resourceFunctionValidate}"
  SHELL_CLI_RESOURCE_FLAG_FAMILY="${resourceFlagFamily}"
  SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER="${resourceFlagFamilyOrder}"

  if [ "${triggerHelp}" == "1" ]; then
    SHELL_CLI_TRIGGER_HELP="1"
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
  fi

  return 0
}
