#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================


declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR="================================================================================"





# shell_cli_handler_help intercepts execution to render manuals.
#
# Arguments:
#   None. Uses compiled SHELL_CLI_TRIGGER_HELP and command tree registers directly.
#
# Returns:
#   - 0: If the help context was triggered and rendered successfully.
#   - 1: If the help context was not triggered, allowing execution to proceed.
#
# Error & Panic Natures:
#   - Return Errors: None. Pure structural routing interceptor routine.
shell_cli_handler_help() {
  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ] || [ "${SHELL_CLI_RESOURCE_TREE}" = "${SHELL_CLI_MAIN_CMD_NAME}" ]; then
    shell_cli_handler_help_global
  else
    shell_cli_handler_help_contextual
  fi

  return 0
}



shell_cli_handler_help_render_header() {
  local -n assocCmdRegistry="${SHELL_CLI_RESOURCE_REGISTRY}"
  local cmdName="${assocCmdRegistry["cmd"]}"
  local cmdSummary="${assocCmdRegistry["summary"]}"
  local cmdDescription="${assocCmdRegistry["description"]}"

  local isMainCmd="${1:-0}"
  if [ "${2}" != "" ]; then
    cmdName="${2}"
  fi


  if [ "${isMainCmd}" = "1" ]; then
    echo "  ${cmdName} - ${cmdSummary}"
  else
    echo "COMMAND: ${cmdName}"
    echo "SUMMARY: ${cmdSummary}"
    if [ "${cmdDescription}" != "" ]; then
      echo "DESCRIPTION:"
      shell_cli_utils_string_wrap "${cmdDescription}" "120"
    fi
  fi
}


shell_cli_handler_help_render_subcmd() {
  local -n arrayMainRegistryOrder="${SHELL_CLI_MAIN_CMD_NAME}_RESOURCE_ORDER"
  if [ "${#arrayMainRegistryOrder[@]}" = "0" ]; then
    return 0
  fi

  echo "Available Operational Command Tree:"
  local subCmdName=""
  local subCmdRegistryPrefix="${SHELL_CLI_RESOURCE_REGISTRY}"
  for subCmdName in "${arrayMainRegistryOrder[@]}"; do
    local -n subCmdFlagAssoc="${subCmdRegistryPrefix}_${subCmdName}"
    printf "  %-20s %s\n" "${subCmdName}" "${subCmdFlagAssoc["summary"]}"
  done
}


shell_cli_handler_help_global() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"

  echo ""
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
  shell_cli_handler_help_render_header "1"
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"

  echo ""
  echo "Usage:"
  echo "  ./${cmdName}.sh <action> [flags]"
  echo "  ./${cmdName}.sh <resource> <action> [flags]"

  echo ""
  echo "Global System Flags:"
  echo "  -h, --help          Display documentation and metadata definitions."
  echo "  -itr, --interactive Starts user interaction prompt mode."

  echo ""
  shell_cli_handler_help_render_subcmd
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"

  return 0
}


shell_cli_handler_help_contextual() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
  local cmdTree="${SHELL_CLI_RESOURCE_TREE}"


  echo ""
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
  shell_cli_handler_help_render_header "0" "${cmdName} ${cmdTree}"
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"


  local -n arrayCmdFlagOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
  if [ "${#arrayCmdFlagOrder[@]}" = "0" ]; then
    echo ""
    echo "This operational command option does not register or mandate any parameter flags."
    echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
    return 0
  fi


  echo ""
  echo "Command Parameter Flags (Evaluated in strict checklist sequence):"
  echo ""

  local flagName=""
  for flagName in "${arrayCmdFlagOrder[@]}"; do
    local -n flagRules="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName}"
    local flagShort="${flagRules["short"]}"
    local flagLong="${flagRules["long"]}"
    local flagDescription="${flagRules["description"]}"
    local flagType="${flagRules["type"]}"
    
    local flagRequired="${flagRules["required"]}"
    local flagDefault="${flagRules["default"]}"

    local flagMin="${flagRules["min"]}"
    local flagMax="${flagRules["max"]}"

    local flagIsArray="${flagRules["is_array"]}"
    local flagIsAssoc="${flagRules["is_ssoc"]}"


    # Assemble flags
    local strShowFlags="    --${flagLong}"
    if [ "${flagShort}" != "" ]; then
      strShowFlags="-${flagShort}, --${flagLong}"
    fi

    # Build the parameter status indicators (Required vs Optional)
    local metaStatus="[optional]"
    if [ "${flagRequired}" = "1" ]; then
      metaStatus="[REQUIRED]"
    fi

    # Extract array and assoc structural identifiers for high-density typing info
    if [ "${flagIsArray}" = "1" ]; then
      flagType="array<${flagType}>"
    elif [ "${flagIsAssoc}" = "1" ]; then
      flagType="map<string,${flagType}>"
    fi

    # Render the primary compiled specification parameter line block
    printf "  %-25s %-18s %s\n" "${strShowFlags}" "${flagType}" "${metaStatus}"



    # Render the human-centric functional usage description text statement
    if [ "${flagDescription}" = "" ]; then
      echo -n "      Description: "
      shell_cli_utils_string_wrap "${flagDescription}" "100" | sed '2,$s/^/                   /'
    fi



    # Render optional default fallback mapping hints if configured in the matrix
    if [ "${flagRequired}" = "0" ] && [ "${flagDefault}" != "" ]; then
      echo "      Default: \"${flagDefault}\""
    fi



    # Render optional validation limits (min/max boundaries)
    if [ "${flagMin}" != "" ] || [ "${flagMax}" != "" ]; then
      local limits=""
      
      if [ "${flagMin}" != "" ]; then
        limits+="min: ${flagMin}, "
      fi
      if [ "${flagMax}" != "" ]; then
        limits+="max: ${flagMax}, "
      fi

      limits="${limits%, }"
      echo "      Constraints: [${limits}]"
    fi
  done
  
  echo ""
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
  return 0
}