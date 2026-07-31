#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================


declare -g SHELL_CLI_HANDLER_HELP_COLUMNS="100"
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR="="
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR=""




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
  local currentCols="${COLUMNS:-80}"
  if [ "${currentCols}" -lt "${SHELL_CLI_HANDLER_HELP_COLUMNS}" ] && [ "${currentCols}" -gt 20 ]; then
    SHELL_CLI_HANDLER_HELP_COLUMNS="${currentCols}"
  fi

  for ((i=0; i<SHELL_CLI_HANDLER_HELP_COLUMNS; i++)); do
    SHELL_CLI_HANDLER_HELP_SEPARATOR+="${SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR}"
  done


  _shell_cli_handler_help_render_header
  _shell_cli_handler_help_render_usage
  _shell_cli_handler_help_render_global_flags
  _shell_cli_handler_help_render_subcmd_options
  _shell_cli_handler_help_render_flags

  return 0
}





_shell_cli_handler_help_render_header() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
  local subCmdName="> ${SHELL_CLI_RESOURCE_TREE/ / > }"
  local useCmdRegistry="${SHELL_CLI_RESOURCE_REGISTRY}"
  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    useCmdRegistry="${SHELL_CLI_MAIN_CMD_REGISTRY}"
    subCmdName=""
  fi

  local -n assocCmdRegistry="${useCmdRegistry}"
  
  local cmdSummary="${assocCmdRegistry["summary"]}"
  local cmdDescription="${assocCmdRegistry["description"]}"

  #echo ""
  echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
  echo "# Shell CLI > Help > ${cmdName} ${subCmdName}"
  echo ""
  shell_cli_utils_string_wrap "${cmdSummary}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "2" "2"
  echo ""
  if [ "${cmdDescription}" != "" ]; then
    shell_cli_utils_string_wrap "${cmdDescription}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "2" "2"
  fi
}


_shell_cli_handler_help_render_usage() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"

  echo ""
  echo "## Usage:"
  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    echo "   ./${cmdName}.sh <action> [flags]"
    echo "   ./${cmdName}.sh <resource> [<action>] [flags]"
  else
    echo "   ./${cmdName}.sh ${SHELL_CLI_RESOURCE_TREE} [<action>] [flags]"
  fi
}


_shell_cli_handler_help_render_global_flags() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"

  echo ""
  echo "## Global System Flags:"
  echo "   -h, --help            Display documentation and metadata definitions."
  echo "   -itr, --interactive   Starts user interaction prompt mode."
}


_shell_cli_handler_help_render_subcmd_options() {
  local useSubCmdType="Actions"
  local useCmdRegistry="${SHELL_CLI_RESOURCE_REGISTRY}"
  local useAssocCmdName="${SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER}"
  local useCmdResourcePath="${SHELL_CLI_RESOURCE_PATH}"

  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    local useSubCmdType="Resources"
    useCmdRegistry="${SHELL_CLI_MAIN_CMD_REGISTRY}"
    useAssocCmdName="${SHELL_CLI_MAIN_CMD_REGISTRY_ORDER}"
    useCmdResourcePath="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/src"
  fi

  local -n arraySubCmdOrder="${useAssocCmdName}"
  if [ "${#arraySubCmdOrder[@]}" = "0" ]; then
    return 0
  fi



  local -a arraySubCmdName=()
  local -a arraySubCmdSummary=()

  local subCmdName=""
  local subCmdSummary=""
  local subCmdPath=""
  local subCmdRegistry=""

  local maxSubCmdNameLength="0"
  for subCmdName in "${arraySubCmdOrder[@]}"; do
    arraySubCmdName+=("${subCmdName}")
    if [ "${#subCmdName}" -gt "${maxSubCmdNameLength}" ]; then
      maxSubCmdNameLength="${#subCmdName}"
    fi

    subCmdPath="${useCmdResourcePath}/${subCmdName}/cmd.sh"
    if [ ! -f "${subCmdPath}" ]; then
      local nl=$'\n'
      arraySubCmdSummary+=("Sub-Command definition not found.${nl}Missing file: '${subCmdPath}'.")
      continue
    fi


    . "${subCmdPath}"
    subCmdRegistry="${useCmdRegistry}_${subCmdName^^}"
    shell_cli_preflight_check_command_registry "${subCmdRegistry}"
    local s="$?"
    local ref=""
    if [ "${s}" = "1" ]; then
      arraySubCmdSummary+=("Not found '${subCmdRegistry}' associative array (declare -A) in '${subCmdPath}'.")
      continue
    elif [ "${s}" = "2" ]; then
      arraySubCmdSummary+=("Assoc '${subCmdRegistry}'  in '${subCmdPath}' missing one or more mandatory keys.")
      continue
    fi

    ref="${subCmdRegistry}[summary]"
    arraySubCmdSummary+=("${!ref}")
  done



  echo ""
  echo "## Available ${useSubCmdType}:"
  local i=""
  local txtSubCmdName=""
  local txtSubCmdInfo=""
  
  local txtSubCmdIndent="3"
  local txtSubCmdSeparator="3"
  local txtSubCmdSpace="0"
  (( txtSubCmdSpace = txtSubCmdIndent + maxSubCmdNameLength + txtSubCmdSeparator))

  local lastLineI="${#arraySubCmdOrder[@]}"
  (( lastLineI = lastLineI - 1 ))

  for i in "${!arraySubCmdOrder[@]}"; do
    subCmdName="${arraySubCmdOrder["${i}"]}"
    subCmdSummary="${arraySubCmdSummary["${i}"]}"

    txtSubCmdName=$(printf "%-${maxSubCmdNameLength}s" "${subCmdName}")
    txtSubCmdInfo="${txtSubCmdName}   ${subCmdSummary}"

    shell_cli_utils_string_wrap "${txtSubCmdInfo}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${txtSubCmdIndent}" "${txtSubCmdSpace}"
    if [ "${SHELL_CLI_UTILS_STRING_WRAP_LINES}" -ge "2" ] && [ "${i}" != "${lastLineI}" ]; then
      echo ""
    fi
  done
}


_shell_cli_handler_help_render_flags() {
  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    echo ""
    return 0
  fi

  local useCmdFlagOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
  local -n arrayCmdFlagOrder="${useCmdFlagOrder}"


  echo ""
  echo "## Parameter Flags:"
  if [ "${#arrayCmdFlagOrder[@]}" = "0" ]; then
    echo "   This command has no flag options."
    echo ""
    echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
    echo ""
    return 0
  fi


  local arraySubCmdFlagNameMaxLength="0"
  local -a arraySubCmdFlagName=()

  local -a arraySubCmdFlagType=()
  local -a arraySubCmdFlagMode=()
  local -a arraySubCmdFlagDefault=()
  local -a arraySubCmdFlagDescription=()
  local -a arraySubCmdFlagConstraints=()

  local flagName=""
  for flagName in "${arrayCmdFlagOrder[@]}"; do
    local -n assocFlagRules="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName}"

    #
    # Get flags
    # long      = 2 + 16 = 18  chars
    # short     = 1 +  3 =  4  chars
    # separator = 2      =  2  chars ( ', ' )
    # max length         = 24  chars
    local flagLong="${assocFlagRules["long"]}"
    local flagShort="${assocFlagRules["short"]}"

    local strShowFlags="--${flagLong}"
    if [ "${flagShort}" != "" ]; then
      strShowFlags="-${flagShort}, --${flagLong}"
    fi
    arraySubCmdFlagName+=("${strShowFlags}")

    if [ "${#strShowFlags}" -gt "${arraySubCmdFlagNameMaxLength}" ]; then
      arraySubCmdFlagNameMaxLength="${#strShowFlags}"
    fi


    #
    # Get type
    # max type length       = 12 chars ( 'relativepath' )
    # lt; gt symbols        =  2 chars ( '<', '>' )
    #
    # max array type length = 25 chars ( 'map<string, relativepath>' )
    #
    # max length            = 25 chars
    local strShowType="${assocFlagRules["type"]}"
    local strShowArrayType=""
    if [ "${assocFlagRules["is_array"]}" = "1" ] || [ "${assocFlagRules["is_array"]}" = "true" ]; then
      strShowType="<${strShowType}>"
      strShowArrayType="array"
    elif [ "${assocFlagRules["is_ssoc"]}" = "1" ] || [ "${assocFlagRules["is_ssoc"]}" = "true" ]; then
      strShowType="<string, ${strShowType}>"
      strShowArrayType="map"
    else
      strShowType="<${strShowType}>"
    fi
    arraySubCmdFlagType+=("${strShowArrayType}${strShowType}")


    #
    # Get mode (10)
    # max type length = 10 chars ( '[REQUIRED]' )
    local strShowMode=""
    if [ "${assocFlagRules["required"]}" = "1" ] || [ "${assocFlagRules["required"]}" = "true" ]; then
      strShowMode="[REQUIRED]"
    fi
    arraySubCmdFlagMode+=("${strShowMode}")


    #
    # Get default
    arraySubCmdFlagDefault+=("${assocFlagRules["default"]}")

    #
    # Get description
    arraySubCmdFlagDescription+=("${assocFlagRules["description"]}")

    #
    # Get Min/Max Constraints
    local flagMin="${assocFlagRules["min"]}"
    local flagMax="${assocFlagRules["max"]}"
    local strShowConstraints=""
    if [ "${flagMin}" != "" ] || [ "${flagMax}" != "" ]; then
      local constraints=""
      
      if [ "${flagMin}" != "" ]; then
        constraints+="min: ${flagMin}, "
      fi
      if [ "${flagMax}" != "" ]; then
        constraints+="max: ${flagMax}, "
      fi
      strShowConstraints="${constraints%, }"

    fi
    arraySubCmdFlagConstraints+=("${strShowConstraints}")
  done



  local i=""
  local lastLineI="${#arrayCmdFlagOrder[@]}"
  (( lastLineI = lastLineI - 1 ))

  for i in "${!arrayCmdFlagOrder[@]}"; do
    local strFlagName=$(printf "%${arraySubCmdFlagNameMaxLength}s" "${arraySubCmdFlagName["${i}"]}")
    local strFlagType="${arraySubCmdFlagType["${i}"]}"
    local strFlagMode="${arraySubCmdFlagMode["${i}"]}"
    local strFlagDefault="${arraySubCmdFlagDefault["${i}"]}"
    local strFlagConstraints="${arraySubCmdFlagConstraints["${i}"]}"
    local strFlagDescription="${arraySubCmdFlagDescription["${i}"]}"

    local useIndent="${arraySubCmdFlagNameMaxLength}"
    (( useIndent = useIndent + 6))

    #
    # Mount flag title
    # Identation  =  3 chars
    #   Name      = 24 chars
    # Separator   =  3 chars
    #   Type      = 25 chars
    # Separator   =  2 chars
    #   Mode      = 10 chars
    # max length  = 67 chars
    local strFlagTitle="${strFlagName}   ${strFlagType}  ${strFlagMode}"
    shell_cli_utils_string_wrap "${strFlagTitle}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "3" "3"

    if [ "${strFlagDefault}" != "" ]; then
      shell_cli_utils_string_wrap "Default='${strFlagDefault}'" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
    fi

    if [ "${strFlagConstraints}" != "" ]; then
      shell_cli_utils_string_wrap "Constraints='${strFlagConstraints}'" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
    fi

    if [ "${strFlagDescription}" != "" ]; then
      shell_cli_utils_string_wrap "${strFlagDescription}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
      if [ "${i}" != "${lastLineI}" ]; then
        echo ""
      fi
    fi
    
  done


  echo ""
  return 
}
