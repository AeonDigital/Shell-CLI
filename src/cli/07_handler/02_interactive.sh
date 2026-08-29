#!/usr/bin/env bash

# SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS — Target terminal layout width threshold
# for interactive wizards.
# 
# - Defines the standard baseline horizontal character width limit (default "100")
#   for printing form prompts.
# - Dynamically scales down at runtime to match the active terminal context if '${COLUMNS}'
#   is smaller.
declare -g SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS="100"

# SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR — Baseline literal string character
# unit for wizard layout dividers.
# 
# - Specifies the individual text character used to dynamically draw structural line
#   breaks during prompt cycles.
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR="="

# SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR — Dynamic horizontal layout boundary string
# filled by the engine.
# 
# - Automatically compiled on demand by repeating the separator character until reaching
#   the column threshold.
# - Used across downstream prompt renderers to separate conversational form blocks
#   with consistent line dividers.
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR=""





# shell_cli_handler_interactive — Orquestrate env audits, boundary scalings, and
# security gates before initializing interactive wizards.
# 
# Arguments
# - None.
# 
# Global outputs
# - SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS: Scaled and adjusted to fit terminal boundaries
#   if the active session is narrow.
# - SHELL_CLI_HANDLER_HELP_SEPARATOR: Appended with dynamically compiled layout divider
#   strings.
# 
# Notes
# - Environment Guard: Aborts with a fatal exit immediately if executed outside a
#   valid interactive standard input stream channel (non-TTY contexts).
# - Command Guards: Rejects execution if active positionals point to root levels
#   or if the leaf node possesses no parameter options to compile.
# - Diverts control to the underlying sequential capture routine '_shell_cli_handler_interactive_loop'
#   to execute form rendering loops.
# 
# Returns
# - 0: Success (interactive inputs successfully collected, validated, and pushed
#   to active execution memory arrays).
# - 1: Rejection (wizard unavailable due to root invocation or empty command flag
#   schemas).
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





# _shell_cli_handler_interactive_loop — Execute the sequential prompt capture matrix
# and run in-place validation cycles.
# 
# Arguments
# - None.
# 
# Global outputs
# - SHELL_CLI_INPUT_RAW_FLAG_ASSOC: Injected with validated data values mapped to
#   their canonical option keys.
# - SHELL_CLI_INPUT_RAW_FLAG_ORDER: Appended with the sequential order strings of
#   successfully captured parameters.
# - SHELL_CLI_INPUT_RAW_FLAG: Hydrated with constructed notation payload strings
#   ready for down-stream processing loops.
# 
# Notes
# - Sequentially traverses flag vector parameters to present isolated dynamic user
#   prompts with fallback instruction placeholders.
# - Escape Interceptor: Evaluates inputs for the reserved framework token ':q!' to
#   immediately halt operational workflows gracefully.
# - Enforces instant atomic validation checks by piping captures through 'shell_cli_process_flag_value'
#   before shifting prompt indexes.
# - Loops infinitely per parameter entry field until input requirements are satisfied
#   or an explicit termination token fires.
# 
# Returns
# - 0: Success (form evaluation completely satisfied and matrix data structures mapped).
# - 10: Graceful Shutdown (operation intentionally halted and abandoned by explicit
#   user escape command invocation).
_shell_cli_handler_interactive_loop() {
  # Standardize the print layout: convert underscore structures back into command
  # spacing
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
