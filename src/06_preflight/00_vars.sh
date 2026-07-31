#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 06_preflight/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# SHELL_CLI_CORE_LOAD - global variable indicating the load state of the 
# Shell-CLI core.
#
# - Initialized to "-1" if not yet defined.
# - Updated by 'shell_cli_client_load_core_engine' and 
#   'shell_cli_preflight_load_core_engine'.
# - Used to determine whether the runtime engine is already active in the session.
if [ "${SHELL_CLI_CORE_LOAD}" = "" ]; then
  declare -g SHELL_CLI_CORE_LOAD="-1"
fi



if [ "${SHELL_CLI_PROCESS_LOCK_PID}" = "" ]; then
  # SHELL_CLI_PROCESS_LOCK_PID - global variable storing the process identifier (PID).
  #
  # - Updated when a process lock is activated.
  # - Used to detect nested executions sharing the same memory stack frame.
  declare -g SHELL_CLI_PROCESS_LOCK_PID="-"

  # SHELL_CLI_PROCESS_LOCK_ACTIVE — global variable acting as a boolean flag.
  #
  # - "1" indicates that a process lock is active for the current pipeline.
  # - "0" indicates no active lock.
  declare -g SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
fi



# SHELL_CLI_MAIN_CMD_ROOT_PATH — global variable holding the absolute root path of the CLI project.
#
# - Populated by the 'shell_cli_preflight_prepare_command' function.
# - Represents the base directory from which command sources and assets are resolved.
# - Used as the starting point for locating entrypoint scripts, globals, and command tree contexts.
declare -g SHELL_CLI_MAIN_CMD_ROOT_PATH=""


# SHELL_CLI_MAIN_CMD_NAME — Global variable holding the normalized main command name.
#
# - Set during preflight preparation after user input normalization.
declare -g SHELL_CLI_MAIN_CMD_NAME=""


declare -g SHELL_CLI_MAIN_CMD_REGISTRY=""
declare -g SHELL_CLI_MAIN_CMD_REGISTRY_ORDER=""




# SHELL_CLI_RESOURCE_PATH — Global variable holding the absolute path to the command directory.
#
# - Built from rootPath and command tree arguments.
# - Used to locate and source scripts specific to the command context.
declare -g SHELL_CLI_RESOURCE_PATH=""

declare -g SHELL_CLI_RESOURCE_NAME=""



# SHELL_CLI_RESOURCE_TREE — Global variable holding the textual representation of the command tree.
#
# - Concatenates all subcommand parts into a single string.
# - Used for error reporting and to preserve the logical execution context.
declare -g SHELL_CLI_RESOURCE_TREE=""


# SHELL_CLI_RESOURCE_REGISTRY — global variable holding the canonical name of the
#   associative array that defines the main command.
#
# - Convention: must be declared in the client as 'declare -A SHELL_CLI_CMD_<CMDNAME>'.
# - Expected keys: 'cmd', 'summary', and 'description'.
# - Populated during 'shell_cli_preflight_prepare_command' to reference the main
#   command’s metadata definition.
# - Used to build help output and provide context for the root command.
declare -g SHELL_CLI_RESOURCE_REGISTRY=""


declare -g SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER=""


# SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER — global variable holding the canonical name of
#   the indexed array that defines the order of subcommands for the main command.
#
# - Convention: must be declared in the client as
#   'declare -a SHELL_CLI_CMD_<CMDNAME>_RESOURCE_ORDER'.
# - Each element represents a subcommand name, listed in the order they should
#   appear in help and documentation.
# - Populated during 'shell_cli_preflight_prepare_command' to reference the
#   subcommand ordering array.
# - Used to ensure consistent listing of subcommands when generating help output.
declare -g SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER=""





# SHELL_CLI_COMMAND_RESOURCE_ORDER — global indexed array holding available subcommands.
#
# - Declared as an indexed array (declare -a) only if not already defined by the CLI client.
# - If the client has previously initialized it, the existing definition is preserved.
# - Each element represents a subcommand name in the order they should appear.
# - Used primarily to build the help output, ensuring that subcommands are listed
#   consistently and in the intended sequence.
if ! declare -p "SHELL_CLI_COMMAND_RESOURCE_ORDER" &>/dev/null; then
  declare -ga SHELL_CLI_COMMAND_RESOURCE_ORDER=()
fi





# SHELL_CLI_RESOURCE_FLAG_FAMILY — global variable holding the canonical name prefix
#   for the associative array that defines the command’s flags.
#
# - Built dynamically during 'shell_cli_preflight_prepare_command' using the
#   normalized command name and command tree.
# - Convention: the array must be declared as 'declare -A CMD_<command>_<subcommands>_FLAG'.
# - Expected keys inside this associative array: 'cmd', 'summary', and 'description'.
# - Used as the reference point for compiling and validating all flags of the command.
declare -g SHELL_CLI_RESOURCE_FLAG_FAMILY=""


# SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER — global variable holding the canonical name
#   of the indexed array that defines the order of flags for the command.
#
# - Built dynamically during 'shell_cli_preflight_prepare_command' using the
#   normalized command name and command tree.
# - Convention: the array must be declared as 'declare -a CMD_<command>_<subcommands>_FLAG_ORDER'.
# - Each element represents the name of a flag, which must correspond to an
#   associative array defined under the same family prefix.
# - Used to preserve the declaration order of flags and ensure consistent iteration.
declare -g SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER=""


# SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME — global associative array mapping long flag names.
#
# - Keys: canonical long names of flags (e.g., "--verbose").
# - Values: reference to the corresponding associative array definition for the flag.
# - Populated during 'shell_cli_preflight_prepare_command' by iterating the flag family order.
# - Used to resolve flags by their long name at runtime.
declare -gA SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME=()


# SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME — global associative array mapping short flag names.
#
# - Keys: canonical short names of flags (e.g., "-v").
# - Values: the corresponding long flag name.
# - Populated during 'shell_cli_preflight_prepare_command' alongside long names.
# - Used to resolve flags by their short name and link them to their long form.
declare -gA SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME=()


# SHELL_CLI_RESOURCE_FUNCTION_ACTION — global variable holding the canonical name of the
#   function responsible for executing the command’s main action.
#
# - Populated by 'shell_cli_preflight_prepare_command' using the normalized command
#   name and command tree.
# - Convention: must point to a function named 'cmd_<command>_<subcommands>_action'.
# - Invoked after all validations and flag compilations succeed, representing the
#   actual business logic of the command.
declare -g SHELL_CLI_RESOURCE_FUNCTION_ACTION=""


# SHELL_CLI_RESOURCE_FUNCTION_VALIDATE — global variable holding the canonical name of the
#   function responsible for validating the command’s execution context.
#
# - Populated by 'shell_cli_preflight_prepare_command' using the normalized command
#   name and command tree.
# - Convention: must point to a function named 'cmd_<command>_<subcommands>_validate'.
# - Invoked before executing the action function, ensuring that all required flags
#   and contextual rules are satisfied.
declare -g SHELL_CLI_RESOURCE_FUNCTION_VALIDATE=""





# SHELL_CLI_TRIGGER_HELP — global flag indicating help mode.
#
# - "1" when the command was invoked with "help", "--help" or "-h".
# - Used to short-circuit execution and display usage information.
declare -g SHELL_CLI_TRIGGER_HELP="0"

# SHELL_CLI_TRIGGER_INTERACTIVE — global flag indicating interactive mode.
#
# - "1" when the command was invoked with "interactive" or "--interactive"/"-itr".
# - Used to trigger interactive execution flow instead of standard batch mode.
declare -g SHELL_CLI_TRIGGER_INTERACTIVE="0"

# SHELL_CLI_INPUT_RAW_FLAG — global indexed array storing raw flags.
#
# - Contains all flags exactly as typed by the user (e.g., "--opt=value").
# - Populated during input parsing before normalization.
declare -ga SHELL_CLI_INPUT_RAW_FLAG=()

# SHELL_CLI_INPUT_RAW_FLAG_ASSOC — global associative array mapping flags to values.
#
# - Keys: canonical long flag names.
# - Values: raw values provided by the user (or "1" for boolean flags).
# - Populated after validation of existence and duplication.
declare -gA SHELL_CLI_INPUT_RAW_FLAG_ASSOC=()

# SHELL_CLI_INPUT_RAW_FLAG_ORDER — global indexed array preserving flag order.
#
# - Stores the sequence of flags as they were provided by the user.
# - Ensures deterministic iteration and validation order.
declare -ga SHELL_CLI_INPUT_RAW_FLAG_ORDER=()




declare -gA SHELL_CLI_CMD_INPUT=()
declare -ga SHELL_CLI_CMD_INPUT_ORDER=()
declare -g SHELL_CLI_CMD_VALIDATE_ERR=""






# shell_cli_preflight_reset — clear all global variables related to command execution.
#
# Arguments:
# - None.
#
# Behavior:
# - Resets every global variable used to control the execution context of a command.
# - Ensures no residual state from previous executions interferes with the next run.
# - Clears root path, command name, command tree, flag families, flag mappings,
#   and references to action/validation functions.
# - Also resets the temporary registries for the main command definition and
#   its subcommand ordering array.
#
# Returns:
# - 0: always succeeds (globals reset to default values).
shell_cli_preflight_reset() {
  # MAIN CMD
  SHELL_CLI_MAIN_CMD_ROOT_PATH=""
  SHELL_CLI_MAIN_CMD_NAME=""
  SHELL_CLI_MAIN_CMD_REGISTRY=""
  SHELL_CLI_MAIN_CMD_REGISTRY_ORDER=""


  # SELECTED RESOURCE
  SHELL_CLI_RESOURCE_PATH=""
  SHELL_CLI_RESOURCE_NAME=""
  SHELL_CLI_RESOURCE_TREE=""
  SHELL_CLI_RESOURCE_REGISTRY=""
  SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER=""
  SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER=""
  SHELL_CLI_RESOURCE_FUNCTION_ACTION=""
  SHELL_CLI_RESOURCE_FUNCTION_VALIDATE=""

  # RESOURCE FLAG
  SHELL_CLI_RESOURCE_FLAG_FAMILY=""
  SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER=""

  # RESOURCE FLAG MAP
  SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME=()
  SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME=()

  # TRIGGERS
  SHELL_CLI_TRIGGER_HELP="0"
  SHELL_CLI_TRIGGER_INTERACTIVE="0"

  # INPUT FLAGS
  SHELL_CLI_INPUT_RAW_FLAG=()
  SHELL_CLI_INPUT_RAW_FLAG_ASSOC=()
  SHELL_CLI_INPUT_RAW_FLAG_ORDER=()


  # CLIENT CLI CMD
  SHELL_CLI_CMD_INPUT=()
  SHELL_CLI_CMD_INPUT_ORDER=()
  SHELL_CLI_CMD_VALIDATE_ERR=""
}

shell_cli_context_dump() {
  echo "MAIN CMD"
  echo "  ROOT PATH : $SHELL_CLI_MAIN_CMD_ROOT_PATH"
  echo "       NAME : $SHELL_CLI_MAIN_CMD_NAME"
  echo "  ASSOC REG : $SHELL_CLI_MAIN_CMD_REGISTRY"
  echo "  ARRAY ORD : $SHELL_CLI_MAIN_CMD_REGISTRY_ORDER"
  echo ""

  echo "SELECTED RESOURCE"
  echo "       PATH : $SHELL_CLI_RESOURCE_PATH"
  echo "       NAME : $SHELL_CLI_RESOURCE_NAME"
  echo "       TREE : $SHELL_CLI_RESOURCE_TREE"
  echo "  ASSOC REG : $SHELL_CLI_RESOURCE_REGISTRY"
  echo " ACTION ORD : $SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER"
  echo "   FLAG ORD : $SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER"
  echo "  FN ACTION : $SHELL_CLI_RESOURCE_FUNCTION_ACTION"
  echo "  FN VALIDA : $SHELL_CLI_RESOURCE_FUNCTION_VALIDATE"
  echo ""

  echo "RESOURCE FLAG"
  echo "     FAMILY : $SHELL_CLI_RESOURCE_FLAG_FAMILY"
  echo " FAMILY ORD : $SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER"
  echo ""

  
  echo "RESOURCE FLAG MAP"
  local i=""
  local k=""
  local v=""
  
  echo "  SHORT NAME : "
  for k in "${!SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME[@]}"; do
    v="${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${k}"]}"
    echo "    [ ${k} ] = '${v}'"
  done

  echo ""

  echo "  LONG NAME : "
  for k in "${!SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME[@]}"; do
    v="${SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${k}"]}"
    echo "    [ ${k} ] = '${v}'"
  done
  
  echo ""

  echo "TRIGGERS"
  echo "       HELP : $SHELL_CLI_TRIGGER_HELP"
  echo "INTERACTIVE : $SHELL_CLI_TRIGGER_INTERACTIVE"

  echo ""

  echo " RAW FLAGS : "
  for i in "${!SHELL_CLI_INPUT_RAW_FLAG[@]}"; do
    v="${SHELL_CLI_INPUT_RAW_FLAG["${i}"]}"
    echo "    [ ${i} ] = '${v}'"
  done

  echo ""

  echo "FLAG ASSOC [in order] : "
  for k in "${SHELL_CLI_INPUT_RAW_FLAG_ORDER[@]}"; do
    v="${SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${k}"]}"
    echo "    [ ${k} ] = '${v}'"
  done
}
