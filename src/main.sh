#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/main.sh
# DESCRIPTION: Framework root lifecycle controller driving auto-sourcing, 
#              pre-flight parsing, and deterministic execution pipelines.
# ==============================================================================

# shell_cli_runtime_compile builds the isolated sandbox execution context.
#
# Arguments:
#   - target_pkg: The uppercase canonical name of the active package.
#   - target_tree: The complete resolved command route path tree.
#
# Returns:
#   - 0: If the dynamic structures are successfully cloned and design rules pass.
#   - 1: If an invalid layout definition or structural configuration rule fails.
#
# Error & Panic Natures:
#   - Return Errors: Fails if the dynamic source array maps are missing, or if
#     any flag design layout constraint (e.g. min > max) is violated.
shell_cli_runtime_compile() {
  local target_pkg="$1"
  local target_tree="$2"

  # ----------------------------------------------------------------------------
  # PHASE 1: ISOLATED RUNTIME GARBAGE COLLECTION AND FLUSH
  # ----------------------------------------------------------------------------
  shell_cli_runtime_reset

  SHELL_CLI_RUNTIME_PKG="$target_pkg"
  SHELL_CLI_RUNTIME_COMMAND_TREE="$target_tree"

  local blueprint_prefix="CMD_${target_pkg}_${target_tree}"

  if ! declare -p "${blueprint_prefix}" &>/dev/null; then
    VALIDATION_ERROR_MSG="[ERR] Architecture Breakdown :: Master command layout definition '${blueprint_prefix}' is missing."
    return 1
  fi

  # ----------------------------------------------------------------------------
  # PHASE 2: COMMAND METADATA SCAFFOLDING CLONING
  # ----------------------------------------------------------------------------
  local src_cmd_key
  for src_cmd_key in "cmd" "summary" "description"; do
    local indirect_cmd_ref="${blueprint_prefix}[\"${src_cmd_key}\"]"
    SHELL_CLI_RUNTIME_CMD["$src_cmd_key"]="${!indirect_cmd_ref}"
  done

  # ----------------------------------------------------------------------------
  # PHASE 3: PARALLEL FLAG PRIORITY ORDER SEQUENCE INJECTION
  # ----------------------------------------------------------------------------
  local src_order_ref="${blueprint_prefix}_FLAG_ORDER[@]"
  SHELL_CLI_RUNTIME_FLAG_ORDER=("${!src_order_ref}")

  # ----------------------------------------------------------------------------
  # PHASE 4: DYNAMIC FLAG MATRICES REPLICATION & LIVE PRE-FLIGHT VALIDATION
  # ----------------------------------------------------------------------------
  local active_flag_token
  for active_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local src_flag_array_name="${blueprint_prefix}_FLAG_${active_flag_token}"
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${active_flag_token}"

    # Delegate dynamic layout cloning and structural assessments atomically
    if ! _shell_cli_runtime_compile_single_flag "$src_flag_array_name" "$runtime_flag_array_name"; then
      return 1
    fi


    local -n _idx_f="$runtime_flag_array_name"

    # Map the long name descriptor
    SHELL_CLI_RUNTIME_FLAG_LONGNAME["${_idx_f["long"]}"]="${active_flag_token}"
    # Map the short alias descriptor if it was explicitly provided by the dev
    if [ -n "${_idx_f["short"]}" ]; then
      SHELL_CLI_RUNTIME_FLAG_SHORTNAME["${_idx_f["short"]}"]="${_idx_f["long"]}"
    fi
  done

  # ----------------------------------------------------------------------------
  # PHASE 5: INGEST RAW TERMINAL INPUT STREAM TO RUNTIME CONTEXT
  # ----------------------------------------------------------------------------
  if ! shell_cli_runtime_ingest_raw_inputs "$@"; then
    return 1
  fi

  return 0
}

# _shell_cli_runtime_compile_single_flag isolates configuration injection and validation.
#
# Arguments:
#   - src_flag_array_name: The name string of the developer dynamic source map.
#   - runtime_flag_array_name: The target isolated runtime sandbox map name string.
#
# Returns:
#   - 0: Successful configuration replication and layout verification context.
#   - 1: Structural blueprint breach or validation design rule violation.
#
# Error & Panic Natures:
#   - Return Errors: Populates the global tracking layout message if the flag
#     specification breaks mandatory framework design restrictions.
_shell_cli_runtime_compile_single_flag() {
  local src_flag_array_name="$1"
  local runtime_flag_array_name="$2"

  # Enforce strict global associative instantiation for the target flag container
  declare -gA "${runtime_flag_array_name}"

  # Step A: Ingestion and Fallback Compilation (Inline Fill Paradigm)
  local current_meta_key
  for current_meta_key in "${SHELL_CLI_METAFLAG_DEFAULTS_ORDER[@]}"; do
    local indirect_flag_ref="${src_flag_array_name}[\"${current_meta_key}\"]"
    local source_value="${!indirect_flag_ref}"
    
    if [ -z "$source_value" ]; then
      local fallback_ref="SHELL_CLI_METAFLAG_DEFAULTS[\"${current_meta_key}\"]"
      source_value="${!fallback_ref}"
    fi

    local runtime_flag_assignment="${runtime_flag_array_name}[\"${current_meta_key}\"]"
    eval "${runtime_flag_assignment}=\"\${source_value}\""
  done

  # Step B: Inline Pre-Flight Architectural Design Validation
  local -n _c_flag="$runtime_flag_array_name"
  local f_label="[ flag_meta: ${runtime_flag_array_name} ]"

  if [ "${_c_flag["array"]}" = "1" ] && [ "${_c_flag["assoc"]}" = "1" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: structural conflict. A parameter cannot be declared as 'array' and 'assoc' simultaneously."
    return 1
  fi

  if [ "${_c_flag["required"]}" = "1" ] && [ -n "${_c_flag["default"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: logical breakdown. A mandatory 'required=1' flag cannot provision a fallback 'default' assignment."
  fi

  if [ "${_c_flag["type"]}" = "enum" ] && [ -z "${_c_flag["enum"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: configuration breakdown. Flags classifying as 'type=enum' must declare a target dynamic 'enum' pointer array name."
    return 1
  fi

  return 0
}

# shell_cli_runtime_ingest_raw_inputs processes and maps terminal tokens.
#
# Arguments:
#   - $@: The exact raw execution argument stream passed by the system user.
#
# Returns:
#   - 0: If terminal stream parsing and route matching succeed perfectly.
#   - 1: If dynamic route lookup breaks or arguments contain formatting syntax failures.
#
# Error & Panic Natures:
#   - Return Errors: Itemizes unrecognized commands, malformed parameters syntax,
#     and populates validation failure tracking outputs.
shell_cli_runtime_ingest_raw_inputs() {
  # Drop the first argument if it matches the already resolved active package name
  if [ "$1" = "$SHELL_CLI_RUNTIME_PKG" ]; then
    shift
  fi

  local -a positional_commands=()
  local -a flag_tokens=()
  local scanning_flags=0

  # ----------------------------------------------------------------------------
  # PHASE 1: TOKEN SEPARATION PIPELINE
  # ----------------------------------------------------------------------------
  while [ $# -gt 0 ]; do
    local current_token="$1"

    if [[ "$current_token" =~ ^- ]]; then
      scanning_flags=1
    fi

    if [ "$scanning_flags" -eq 0 ]; then
      if [ "$current_token" = "help" ]; then
        SHELL_CLI_TRIGGER_HELP="1"
      else
        positional_commands+=("$current_token")
      fi
    else
      if ! [[ "$current_token" =~ ^- ]]; then
        VALIDATION_ERROR_MSG="[ x ] Syntax Error :: Positional argument '${current_token}' discovered after flags stream initialization."
        return 1
      fi
      flag_tokens+=("$current_token")
    fi
    shift
  done

  # ----------------------------------------------------------------------------
  # PHASE 2: RESOLVE DYNAMIC COMMAND TREE TRAVERSAL
  # ----------------------------------------------------------------------------
  # If the user typed sub-actions, we reconstruct the tree (ex: ORES_sub1_sub2)
  local total_pos="${#positional_commands[@]}"
  if [ "$total_pos" -eq 0 ]; then
    SHELL_CLI_RUNTIME_COMMAND_TREE="ORES"
  else
    local tree_buffer="ORES"
    local i
    for ((i=0; i<total_pos; i++)); do
      tree_buffer+="_${positional_commands[$i]}"
    done
    SHELL_CLI_RUNTIME_COMMAND_TREE="$tree_buffer"
  fi

  # Programmatically compile canonical lifecycle function name routing patterns
  local lowercase_pkg="${SHELL_CLI_RUNTIME_PKG,,}"
  SHELL_CLI_RUNTIME_FN_VALIDATE="cmd_${lowercase_pkg}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_main_validate"
  SHELL_CLI_RUNTIME_FN_ACTION="cmd_${lowercase_pkg}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_action"

  # Enforce pre-flight structural design check over mandatory execution action hook
  if ! declare -f "$SHELL_CLI_RUNTIME_FN_ACTION" >/dev/null; then
    VALIDATION_ERROR_MSG="[ERR] Implementation Fail :: Mandatory execution action hook function '${SHELL_CLI_RUNTIME_FN_ACTION}' is missing."
    return 1
  fi

  # ----------------------------------------------------------------------------
  # PHASE 3: EVALUATE CORE RESERVED SYSTEM FLAGS AND TRIPPERS
  # ----------------------------------------------------------------------------
  local raw_flag
  for raw_flag in "${flag_tokens[@]}"; do
    local flag_key="${raw_flag%%=*}"

    if [[ "$flag_key" =~ ^(--help|-h)$ ]]; then
      SHELL_CLI_TRIGGER_HELP="1"
    fi

    if [[ "$flag_key" =~ ^(--interactive|-itr)$ ]]; then
      SHELL_CLI_TRIGGER_INTERACTIVE="1"
    fi
  done

  # Enforce strict framework help precedence rule over interactive states
  if [ "$SHELL_CLI_TRIGGER_HELP" = "1" ]; then
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
    return 0
  fi

  if [ "$SHELL_CLI_TRIGGER_INTERACTIVE" = "1" ]; then
    return 0
  fi

  # ----------------------------------------------------------------------------
  # PHASE 4: BUSINESS FLAGS KEY/VALUE EVALUATION AND TRANSLATION
  # ----------------------------------------------------------------------------
  local idx=0
  while [ $idx -lt "${#flag_tokens[@]}" ]; do
    local current_flag="${flag_tokens[$idx]}"
    local extracted_key=""
    local extracted_val=""

    if [[ "$current_flag" == *=* ]]; then
      extracted_key="${current_flag%%=*}"
      extracted_val="${current_flag#*=}"
    else
      extracted_key="$current_flag"
      extracted_val="1"
    fi

    local clean_key="${extracted_key#--}"
    clean_key="${clean_key#-}"

    if [ -n "${SHELL_CLI_RUNTIME_FLAG_SHORTNAME["$clean_key"]+exists}" ]; then
      clean_key="${SHELL_CLI_RUNTIME_FLAG_SHORTNAME["$clean_key"]}"
    fi

    if [ -z "${SHELL_CLI_RUNTIME_FLAG_LONGNAME["$clean_key"]+exists}" ]; then
      VALIDATION_ERROR_MSG="[ x ] Parameter Error :: Unknown or unregistered flag token '${extracted_key}' provided."
      return 1
    fi

    if [ -n "${SHELL_CLI_RUNTIME_RAW_INPUTS["$clean_key"]+exists}" ]; then
      VALIDATION_ERROR_MSG="[ x ] Duplicated Error :: Parameter '${extracted_key}' was provided multiple times."
      return 1
    fi

    SHELL_CLI_RUNTIME_RAW_INPUTS["$clean_key"]="$extracted_val"
    idx=$((idx + 1))
  done

  return 0
}

# shell_cli_runtime_validate_inputs asserts runtime inputs against compiled contracts.
#
# Arguments:
#   None.
#
# Returns:
#   - 0: If all provided arguments perfectly satisfy types, boundaries, and rules.
#   - 1: If any mandatory argument is missing or value constraint validation fails.
#
# Error & Panic Natures:
#   - Return Errors: Itemizes specific parameter validation failures into the 
#     global error message register if validation chains break.
shell_cli_runtime_validate_inputs() {
  # If the help or interactive subsystem context was triggered, bypass standard inputs validation
  if [ "$SHELL_CLI_TRIGGER_HELP" = "1" ] || [ "$SHELL_CLI_TRIGGER_INTERACTIVE" = "1" ]; then
    return 0
  fi

  local current_flag_token
  for current_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${current_flag_token}"
    local -n _v_flag="$runtime_flag_array_name"
    
    local long_name="${_v_flag["long"]}"
    
    # Extract the user raw value directly from our runtime inputs sandbox
    # If the flag wasn't typed, it defaults to an empty string to trigger fallback checks inside the engine
    local user_raw_value=""
    if [ -n "${SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]+exists}" ]; then
      user_raw_value="${SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]}"
    fi

    # Delegate atomic scalar, array, or JSON validations directly using the runtime array name
    if ! shell_cli_type_validate_value "$user_raw_value" "$runtime_flag_array_name"; then
      return 1
    fi

    # Synchronize the parsed, normalized, or transformed value back into the inputs sandbox
    SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]="$SHELL_CLI_VALIDATED_VALUE"
  done

  return 0
}

# shell_cli_runtime_export_inputs instantiates the public developer input map.
#
# Arguments:
#   None.
#
# Returns:
#   - 0: Always returns successful after completing the dynamic mirror assignment.
#
# Error & Panic Natures:
#   - Return Errors: None. Linear memory cloning pipeline operation.
shell_cli_runtime_export_inputs() {
  # Build the public canonical associative array name expected by the developer
  local target_input_map_name="CMD_${SHELL_CLI_RUNTIME_PKG}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_INPUT"

  # Enforce strict global associative instantiation for the final public contract
  declare -gA "${target_input_map_name}"

  # Scan through our active runtime sandbox and clone every clean payload
  local key_token
  for key_token in "${!SHELL_CLI_RUNTIME_RAW_INPUTS[@]}"; do
    local assignment_target="${target_input_map_name}[\"${key_token}\"]"
    eval "${assignment_target}=\"\${SHELL_CLI_RUNTIME_RAW_INPUTS[\$key_token]}\""
  done

  return 0
}

# shell_cli_runtime_handle_help intercepts execution to render manuals.
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
shell_cli_runtime_handle_help() {
  # Assert if the help trigger switch was pulled during ingestion phase
  if [ "$SHELL_CLI_TRIGGER_HELP" != "1" ]; then
    return 1
  fi

  # Route help layout based on whether the command tree points to the core root
  if [ "$SHELL_CLI_RUNTIME_COMMAND_TREE" = "ORES" ] || [ "$SHELL_CLI_RUNTIME_COMMAND_TREE" = "ORES_help" ]; then
    shell_cli_help_render_global
  else
    shell_cli_help_render_contextual
  fi

  return 0
}

# shell_cli_runtime_handle_interactive orchestrates step-by-step user terminal input.
#
# Arguments:
#   None.
#
# Returns:
#   - 0: If interactive questionnaire finishes and all parameters are populated.
#   - 1: If the interactive mode trigger switch was not activated by the user.
#   - 2: If the user explicitly triggers a system escape token sequence to abort.
#
# Error & Panic Natures:
#   - Return Errors: None. Internal infinite loop handles inline validation
#     feedback directly inside the terminal interface until data satisfies specs.
shell_cli_runtime_handle_interactive() {
  # Assert if the interactive prompt trigger switch was pulled during ingestion phase
  if [ "$SHELL_CLI_TRIGGER_INTERACTIVE" != "1" ] || [ "$SHELL_CLI_TRIGGER_HELP" = "1" ]; then
    return 1
  fi
  if [ ! -t 0 ]; then
    echo "[ERR] Interactive mode (-itr) cannot be executed in a non-TTY environment (e.g., CI/CD pipelines, cron jobs)." >&2
    exit 1
  fi

  # ENFORCE EXCLUSIVITY: Purge any partial inline arguments to ensure a clean slate form
  SHELL_CLI_RUNTIME_RAW_INPUTS=()

  # Standardize the print layout: convert underscore structures back into command spacing
  local print_cmd="${SHELL_CLI_RUNTIME_COMMAND_TREE//_/ }"
  if [[ "$print_cmd" =~ ^ores[[:space:]] ]]; then
    print_cmd="${print_cmd#ores }"
  fi

  # Render a unique macro-lifecycle header separator marking the form initiation
  echo "================================================================================"
  echo "[RUN] ${print_cmd^^} - Input in interactive mode"
  echo "[ ! ] Note: Type ':q!' at any prompt to abort execution safely."
  echo "================================================================================"

  local current_flag_token
  for current_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${current_flag_token}"
    local -n _int_f="$runtime_flag_array_name"
    
    local long_name="${_int_f["long"]}"

    # Compile the human-centric single-line prompt message with fallback layout
    local prompt_msg="${_int_f["tipinput"]}"
    if [ -z "$prompt_msg" ]; then
      prompt_msg="Enter value for --${long_name}"
    fi

    # Infinite single-line prompt loop until data satisfies the criteria
    while true; do
      local captured_raw_input=""
      
      echo -e "[ > ] ${prompt_msg}: "
      echo -n "      "
      read -r captured_raw_input

      # INTERCEPT ESCAPE TOKEN: Check if the user wants an immediate graceful shutdown
      if [ "$captured_raw_input" = ":q!" ]; then
        echo ""
        echo "================================================================================"
        echo "[END] Aborted by user."
        echo "================================================================================"
        return 2
      fi

      # Execute instant atomic data validation on input capture
      if ! shell_cli_type_validate_value "$captured_raw_input" "$runtime_flag_array_name"; then
        # Output atomic validation error tracing and force immediate user retry loop
        echo -e "${VALIDATION_ERROR_MSG}"
        continue
      fi

      # Lock the successfully verified value into the runtime sandbox cache
      SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]="$SHELL_CLI_VALIDATED_VALUE"
      break
    done
  done

  echo ""
  echo "================================================================================"
  echo "[ . ] End interactive mode. Proceeding... "
  echo "================================================================================"

  return 0
}

# shell_cli_run centralizes and drives the comprehensive lifecycle execution pipeline.
#
# Arguments:
#   - $@: The comprehensive execution argument passdown directly from the shell entrypoint.
#
# Returns:
#   - 0: If the complete orchestration pipeline and downstream business actions pass perfectly.
#   - 1: If any compilation error, user parameter violation, or logic contract fails.
shell_cli_run() {

  # ----------------------------------------------------------------------------
  # PRE-FLIGHT BOUNDARY CHECK: SAME-LEVEL NESTED CALL DETECTOR (ANTI-POLLUTION)
  # ----------------------------------------------------------------------------

  # Enforce strict process sandboxing laws. Nested execution without local
  # sub-shell encapsulation triggers an immediate system panic termination.
  if [ "$SHELL_CLI_PROCESS_LOCK_ACTIVE" = "1" ] && [ "$SHELL_CLI_PROCESS_LOCK_PID" = "$BASHPID" ]; then
    echo "[ERR] Critical Architecture Panic :: Inline nested command invocation detected!"
    echo "[ERR] Context: Concurrent execution sharing the same active memory stack frame is strictly prohibited."
    echo "[ERR] Resolution: Wrap your programmatic downstream calls using standard isolated sub-shell tokens: ( shell_cli_run ... )"
    return 1
  fi

  # Activate the process locks for the current pipeline instance context
  SHELL_CLI_PROCESS_LOCK_ACTIVE="1"
  SHELL_CLI_PROCESS_LOCK_PID="$BASHPID"

  # ----------------------------------------------------------------------------
  # STEP 1: VALIDATE THE DEVELOPER PROVIDED WORKSPACE ROOT DIRECTION
  # ----------------------------------------------------------------------------
  if [ -z "$SHELL_CLI_ACTIVE_ROOT_PATH" ] || [ ! -d "$SHELL_CLI_ACTIVE_ROOT_PATH" ]; then
    echo "[ERR] Critical Workspace Fault :: Target 'SHELL_CLI_ACTIVE_ROOT_PATH'='$SHELL_CLI_ACTIVE_ROOT_PATH' is missing or points to an invalid directory."
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi

  # ----------------------------------------------------------------------------
  # STEP 2: SANDBOX COMPILE, MEMORY CONTRACT & USER INPUT STREAM INGESTION
  # ----------------------------------------------------------------------------
  if ! shell_cli_runtime_compile "$SHELL_CLI_ACTIVE_PKG" "$@"; then
    echo -e "$VALIDATION_ERROR_MSG"
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi

  # ----------------------------------------------------------------------------
  # STEP 2.1: INTERCEPT EXECUTION TO RENDER CONTEXTUAL OR GLOBAL HELP STREAMS
  # ----------------------------------------------------------------------------
  # If help triggers are pulled, render manuals and die immediately with safety
  if shell_cli_runtime_handle_help; then
    shell_cli_runtime_reset
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 0
  fi

  # ----------------------------------------------------------------------------
  # STEP 2.2: ORCHESTRATE INTERACTIVE RUNTIME STEP-BY-STEP QUESTIONNAIRE
  # ----------------------------------------------------------------------------
  # Catch the precise execution status return code from the interactive pipeline
  local skip_inputs_validation=0
  shell_cli_runtime_handle_interactive
  local interactive_status=$?

  if [ "$interactive_status" -eq 0 ]; then
    # Questionnaire passed perfectly, skip batch validations at Step 3
    skip_inputs_validation=1
  elif [ "$interactive_status" -eq 2 ]; then
    # User requested a graceful termination. Clear memory, drop locks and exit.
    shell_cli_runtime_reset
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi

  # ----------------------------------------------------------------------------
  # STEP 3: EXPLICIT RUNTIME VALUES COMPLIANCE VALIDATION
  # ----------------------------------------------------------------------------
  # Executed only if standard parameters were provided directly via terminal args
  if [ "$skip_inputs_validation" -eq 0 ]; then
    if ! shell_cli_runtime_validate_inputs; then
      echo -e "$VALIDATION_ERROR_MSG"
      shell_cli_runtime_reset
      SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
      SHELL_CLI_PROCESS_LOCK_PID=""
      return 1
    fi
  fi

  # ----------------------------------------------------------------------------
  # STEP 4: MATERIALIZE AND EXPORT PUBLIC INPUT CONTRACTS
  # ----------------------------------------------------------------------------
  # Clone validated inputs into the public dynamic CoC map 'CMD_<PKG>_<TREE>_INPUT'
  shell_cli_runtime_export_inputs

  # ----------------------------------------------------------------------------
  # STEP 5: EXECUTE BUSINESS LIFE CYCLE ACTION HOOK PIPELINES
  # ----------------------------------------------------------------------------
  # If help system was triggered, we can handle it or pass directly to execution.
  # First execute the optional cross-validation business rules hook
  if declare -f "$SHELL_CLI_RUNTIME_FN_VALIDATE" >/dev/null; then
    if ! "$SHELL_CLI_RUNTIME_FN_VALIDATE"; then
      echo -e "$VALIDATION_ERROR_MSG"
      shell_cli_runtime_reset
      SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
      SHELL_CLI_PROCESS_LOCK_PID=""
      return 1
    fi
  fi

  # Finally trigger the mandatory core action logic block
  "$SHELL_CLI_RUNTIME_FN_ACTION"
  local action_exit_code=$?


  # ----------------------------------------------------------------------------
  # STEP 6: TERMINATION PURGE AND LOCK RELEASE
  # ----------------------------------------------------------------------------
  shell_cli_runtime_reset
  SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
  SHELL_CLI_PROCESS_LOCK_PID=""

  return $action_exit_code
}