#!/usr/bin/env bash

declare -g SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS="100"
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR="="
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR=""




shell_cli_handler_interactive() {
  if [ ! -t 0 ]; then
    echo "[ERR] Interactive mode (-itr) cannot be executed in a non-TTY environment (e.g., CI/CD pipelines, cron jobs)." >&2
    exit 1
  fi

  if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
    echo "[ERR] :: Interactive mode not available for the main command."
    return 1
  fi

  local useCmdFlagOrder="#${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}[@]"
  if [ "${!useCmdFlagOrder}" -eq "0" ]; then
    echo "[ERR] :: No flag found; Interactive mode not available for this command."
    return 1
  fi

  local currentCols="${COLUMNS:-80}"
  if [ "${currentCols}" -lt "${SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS}" ] && [ "${currentCols}" -gt 20 ]; then
    SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS="${currentCols}"
  fi

  for ((i=0; i<SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS; i++)); do
    SHELL_CLI_HANDLER_HELP_SEPARATOR+="${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR}"
  done


  _shell_cli_handler_interactive_loop
  return "$?"
}





_shell_cli_handler_interactive_loop() {
  # Standardize the print layout: convert underscore structures back into command spacing
  local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
  local subCmdName="> ${SHELL_CLI_RESOURCE_TREE/ / > }"


  # Render a unique macro-lifecycle header separator marking the form initiation
  echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
  echo "[RUN] ${cmdName}${subCmdName} - Input in interactive mode"
  echo "[ ! ] Note: Type ':q!' at any prompt to abort execution safely."


  local useCmdFlagOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
  local -n arrayCmdFlagOrder="${useCmdFlagOrder}"

  local flagName=""
  local flagAssocName=""
  for flagName in "${arrayCmdFlagOrder[@]}"; do
    flagAssocName="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName}"
    local -n assocFlagRules="${flagAssocName}"
    local flaglong="${assocFlagRules["long"]}"
    local flagTipInput="${assocFlagRules["tipinput"]}"

    if [ "$flagTipInput" = "" ]; then
      flagTipInput="Enter value"
    fi

    # Infinite single-line prompt loop until data satisfies the criteria
    while true; do
      local flagRawInput=""
      
      echo ""
      echo -e "[ > ][ flag: --${flaglong} ] ${flagTipInput}: "
      echo -n "     "
      read -r flagRawInput

      # INTERCEPT ESCAPE TOKEN: Check if the user wants an immediate graceful shutdown
      if [ "${flagRawInput}" = ":q!" ]; then
        echo ""
        echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
        echo "[END] Aborted by user."
        echo ""
        return 10
      fi

      # Execute instant atomic data validation on input capture
      if ! shell_cli_process_flag_value "${flagAssocName}" "$flagRawInput"; then
        local removeFlag="\[ --${flaglong} \]"
        echo "${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE/removeFlag/}"
        continue
      fi

      # Lock the successfully verified value into the runtime sandbox cache
      SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${flaglong}"]="${SHELL_CLI_PROCESS_FLAG_VALUE}"
      SHELL_CLI_INPUT_RAW_FLAG_ORDER+=("${flaglong}")
      SHELL_CLI_INPUT_RAW_FLAG+=("--${flaglong}='${SHELL_CLI_PROCESS_FLAG_VALUE}'")
      break
    done
  done


  echo ""
  echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
  echo "[ . ] End interactive mode. Proceeding... "
  echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"


  return 0
}
