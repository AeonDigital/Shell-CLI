#!/usr/bin/env bash

# SHELL_CLI_HANDLER_HELP_COLUMNS - Target terminal layout width threshold for help documentation.
#
# - Defines the standard baseline horizontal character width limit (default "100") for printing help menus.
# - Dynamically scales down at runtime to match the active terminal context if '${COLUMNS}' is smaller.
declare -g SHELL_CLI_HANDLER_HELP_COLUMNS="100"

# SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR - Baseline literal string character unit for visual canvas layout dividers.
#
# - Specifies the individual text character used to dynamically draw structural line breaks.
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR="="

# SHELL_CLI_HANDLER_HELP_SEPARATOR - Dynamic horizontal layout boundary string filled by the engine.
#
# - Automatically compiled on demand by repeating the separator character until reaching the column threshold.
# - Used across downstream renderers to separate informational layout blocks with consistent line dividers.
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR=""





# shell_cli_handler_help - Intercept the execution pipeline to render structural command manuals and usage layouts.
#
# Arguments
# - None.
#
# Global outputs
# - SHELL_CLI_HANDLER_HELP_COLUMNS: Scaled and adjusted to fit terminal boundaries if the active session is narrow.
# - SHELL_CLI_HANDLER_HELP_SEPARATOR: Dynamically populated with compiled line break strings.
#
# Notes
# - Consumes compiled 'SHELL_CLI_TRIGGER_HELP' state layers and isolated command tree registries directly from the active shell scope.
# - Dynamically evaluates and adapts canvas layout sizing loops by auditing environment column boundaries on the fly.
# - Cascades sequentially into a series of underlying specialized rendering hooks to print headers, usages, subcommands, and flags.
#
# Returns
# - 0: Success (the help layout manual context was intercepted, generated, and rendered successfully to standard output).
# - 1: Passthrough (the help condition trigger was inactive, allowing core command loop processors to proceed).
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





# _shell_cli_handler_help_render_header - Format and print the header layout including command summaries and descriptions.
#
# Arguments
# - None.
#
# Notes
# - Dynamically resolves the active layout namespace registry pointer based on the current depth of the resource command tree.
# - Leverages 'shell_cli_utils_string_wrap' internally to guarantee clean line folding based on the calculated terminal column width.
# - Outputs formatted visualization streams directly to standard output channel.
#
# Returns
# - 0: Always success.
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



# _shell_cli_handler_help_render_usage - Format and display the correct application entrypoint usage syntax patterns.
#
# Arguments
# - None.
#
# Notes
# - Evaluates command positionals and hierarchy nodes to present dynamic syntax blocks based on root vs subcommand execution contexts.
# - Outputs explicit layout strings directly to standard output channel.
#
# Returns
# - 0: Always success.
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



# _shell_cli_handler_help_render_global_flags - Render the core built-in framework utility flags documentation block.
#
# Arguments
# - None.
#
# Notes
# - Prints standardized hardcoded instruction templates for the global help ('-h'/'--help') and interactive wizard ('-itr'/'--interactive') tokens.
# - Outputs explicit layout strings directly to standard output channel.
#
# Returns
# - 0: Always success.
_shell_cli_handler_help_render_global_flags() {
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"

  echo ""
  echo "## Global System Flags:"
  echo "   -h, --help            Display documentation and metadata definitions."
  echo "   -itr, --interactive   Starts user interaction prompt mode."
}



# _shell_cli_handler_help_render_subcmd_options - Resolve, introspect, and render the collection of available subcommands or actions.
#
# Arguments
# - None.
#
# Notes
# - Dynamically switches context labels between 'Resources' (root-level sub-routes) and 'Actions' (leaf-level commands).
# - Performs on-the-fly source loading over discovered 'cmd.sh' layouts to extract sub-resource summaries.
# - Automates layout space sizing by calculating string lengths to produce clean tabular column paddings.
# - Outputs descriptive failure messages in-place within the list if target metadata registries are missing or broken.
#
# Returns
# - 0: Always success.
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



# _shell_cli_handler_help_render_flags - Compile and render detailed documentation matrix for command-specific parameter options.
#
# Arguments
# - None.
#
# Notes
# - Fast-Track Fallback: Short-circuits immediately if evaluated under the base root project execution context (".").
# - Iterates option sequence vectors to map metadata fields: notation notations (-s, --long), types, limits, and defaults.
# - Resolves collection parameters by appending explicit dynamic data brackets based on vector maps ('array' or 'map').
# - Leverages 'shell_cli_utils_string_wrap' cascading loops to calculate column alignment blocks for stdout streaming.
#
# Returns
# - 0: Always success.
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
