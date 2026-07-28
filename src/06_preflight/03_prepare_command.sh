#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 
# DESCRIPTION: 
# ==============================================================================

# SHELL_CLI_ROOT_PATH — global variable holding the absolute root path of the CLI project.
#
# - Populated by the 'shell_cli_preflight_prepare_command' function.
# - Represents the base directory from which command sources and assets are resolved.
# - Used as the starting point for locating entrypoint scripts, globals, and command tree contexts.
declare -g SHELL_CLI_ROOT_PATH=""


# SHELL_CLI_COMMAND_NAME — Global variable holding the normalized main command name.
#
# - Set during preflight preparation after user input normalization.
declare -g SHELL_CLI_COMMAND_NAME=""


# SHELL_CLI_COMMAND_DIR — Global variable holding the absolute path to the command directory.
#
# - Built from rootPath and command tree arguments.
# - Used to locate and source scripts specific to the command context.
declare -g SHELL_CLI_COMMAND_DIR=""


# SHELL_CLI_COMMAND_PATH — Global variable holding the relative path of the command tree.
#
# - Represents the hierarchical structure of subcommands.
# - Used to resolve execution flow and locate command-specific assets.
declare -g SHELL_CLI_COMMAND_PATH=""


# SHELL_CLI_COMMAND_TREE — Global variable holding the textual representation of the command tree.
#
# - Concatenates all subcommand parts into a single string.
# - Used for error reporting and to preserve the logical execution context.
declare -g SHELL_CLI_COMMAND_TREE=""





# SHELL_CLI_COMMAND_FLAG_FAMILY — global variable holding the canonical name prefix
#   for the associative array that defines the command’s flags.
#
# - Built dynamically during 'shell_cli_preflight_prepare_command' using the
#   normalized command name and command tree.
# - Convention: the array must be declared as 'declare -A CMD_<command>_<subcommands>_FLAG'.
# - Expected keys inside this associative array: 'cmd', 'summary', and 'description'.
# - Used as the reference point for compiling and validating all flags of the command.
declare -g SHELL_CLI_COMMAND_FLAG_FAMILY=""


# SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER — global variable holding the canonical name
#   of the indexed array that defines the order of flags for the command.
#
# - Built dynamically during 'shell_cli_preflight_prepare_command' using the
#   normalized command name and command tree.
# - Convention: the array must be declared as 'declare -a CMD_<command>_<subcommands>_FLAG_ORDER'.
# - Each element represents the name of a flag, which must correspond to an
#   associative array defined under the same family prefix.
# - Used to preserve the declaration order of flags and ensure consistent iteration.
declare -g SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER=""





# SHELL_CLI_COMMAND_FN_ACTION — global variable holding the canonical name of the
#   function responsible for executing the command’s main action.
#
# - Populated by 'shell_cli_preflight_prepare_command' using the normalized command
#   name and command tree.
# - Convention: must point to a function named 'cmd_<command>_<subcommands>_action'.
# - Invoked after all validations and flag compilations succeed, representing the
#   actual business logic of the command.
declare -g SHELL_CLI_COMMAND_FN_ACTION=""


# SHELL_CLI_COMMAND_FN_VALIDATE — global variable holding the canonical name of the
#   function responsible for validating the command’s execution context.
#
# - Populated by 'shell_cli_preflight_prepare_command' using the normalized command
#   name and command tree.
# - Convention: must point to a function named 'cmd_<command>_<subcommands>_validate'.
# - Invoked before executing the action function, ensuring that all required flags
#   and contextual rules are satisfied.
declare -g SHELL_CLI_COMMAND_FN_VALIDATE=""





# SHELL_CLI_COMMAND_FLAG_LONGNAME — global associative array mapping long flag names.
#
# - Keys: canonical long names of flags (e.g., "--verbose").
# - Values: reference to the corresponding associative array definition for the flag.
# - Populated during 'shell_cli_preflight_prepare_command' by iterating the flag family order.
# - Used to resolve flags by their long name at runtime.
declare -gA SHELL_CLI_COMMAND_FLAG_LONGNAME=()


# SHELL_CLI_COMMAND_FLAG_SHORTNAME — global associative array mapping short flag names.
#
# - Keys: canonical short names of flags (e.g., "-v").
# - Values: the corresponding long flag name.
# - Populated during 'shell_cli_preflight_prepare_command' alongside long names.
# - Used to resolve flags by their short name and link them to their long form.
declare -gA SHELL_CLI_COMMAND_FLAG_SHORTNAME=()





# shell_cli_preflight_prepare_command — validate and prepare command execution context.
#
# Arguments:
# - rootPath: base directory where command sources are located.
# - commandName: normalized name of the main command (entrypoint).
# - $@: remaining arguments representing the command tree (subcommands).
#
# Behavior:
# - Ensures the core engine is initialized before proceeding.
# - Validates that both command name and command context are provided.
# - Confirms that rootPath exists and contains the expected entrypoint script.
# - Builds the command tree from user arguments, requiring at least one subcommand.
# - Verifies that the command directory exists for the assembled tree.
# - Loads global asset scripts (from "globals") and command-specific scripts
#   (from the resolved command directory), excluding test files.
#
# - Updates global variables with the validated and assembled execution context:
#   · SHELL_CLI_ROOT_PATH, SHELL_CLI_COMMAND_NAME, SHELL_CLI_COMMAND_DIR,
#     SHELL_CLI_COMMAND_PATH, SHELL_CLI_COMMAND_TREE.
#   · SHELL_CLI_COMMAND_FLAG_FAMILY and SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER,
#     following strict naming conventions for flag definitions.
#   · SHELL_CLI_COMMAND_FN_ACTION and SHELL_CLI_COMMAND_FN_VALIDATE,
#     following strict naming conventions for command-specific functions.
#   · SHELL_CLI_COMMAND_FLAG_LONGNAME and SHELL_CLI_COMMAND_FLAG_SHORTNAME,
#     associative arrays mapping flag identifiers to their definitions, ensuring
#     consistent resolution of both long and short flag names.
#
# - Enforces conventions:
#   · Each command must declare an associative array named as per
#     SHELL_CLI_COMMAND_FLAG_FAMILY, containing 'cmd', 'summary', and 'description'.
#   · Each command must declare an indexed array named as per
#     SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER, listing flag names in order.
#   · Each flag listed must have a corresponding associative array definition.
#
# - Compiles metaflags (SHELL_CLI_METAFLAG_DEFAULT_ORDER) and command-specific flags
#   using 'shell_cli_compile_flag_family'.
#
# Returns:
# - 0: success (command context prepared and globals set).
# - 1: failure (missing engine, invalid arguments, nonexistent paths, or missing flag definitions).
shell_cli_preflight_prepare_command() {
  local rootPath="${1}"; shift
  local commandName=$(shell_cli_type_normalize_string "${2,,}"); shift

  local commandDir="${rootPath}/src/"
  local commandPath=""
  local commandTree=""
  local commandFlagPrefix="CMD_${commandName}_"


  SHELL_CLI_ROOT_PATH=""
  SHELL_CLI_COMMAND_NAME=""
  SHELL_CLI_COMMAND_DIR=""
  SHELL_CLI_COMMAND_PATH=""
  SHELL_CLI_COMMAND_TREE=""
  SHELL_CLI_COMMAND_FLAG_FAMILY=""
  SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER=""
  SHELL_CLI_COMMAND_FN_ACTION=""
  SHELL_CLI_COMMAND_FN_VALIDATE=""
  SHELL_CLI_COMMAND_FLAG_LONGNAME=()
  SHELL_CLI_COMMAND_FLAG_SHORTNAME=()


  #
  # 0. If shell cli not initializated by 'shell_cli_preflight_load_core_engine'
  if [ "${SHELL_CLI_CORE_LOAD}" = "" ] || [ -d "${SHELL_CLI_CORE_LOAD}" ]; then
    echo "[ERR] Shell CLI not found."
    return 1
  fi

  #
  # 1. Blocks execution if the main command name is omitted.
  if [ "${commandName}" = "" ]; then
    echo "[ERR] Missing operational main command name context."
    return 1
  fi

  #
  # 2. Blocks execution if the command context is omitted.
  if [ "$#" = "0" ]; then
    echo "[ERR] Missing command context."
    return 1
  fi

  #
  # 3. Checks if 'rootPath' exists
  if [ ! -d "${rootPath}" ]; then
    echo "[ERR] Command Root Path '${rootPath}' does not exists."
    return 1
  fi

  #
  # 4. Checks if the command entrypoint file exists.
  if [ ! -f "${rootPath}/${commandName}.sh" ]; then
    echo "[ERR] Command entrypoint '${commandName}' does not exists."
    echo "      Missing file '${rootPath}/${commandName}.sh'."
    return 1
  fi

  #
  # 5. Assembles the command tree to be executed.
  local arg=""
  for arg in "$@"; do
    arg=$(shell_cli_type_normalize_string "${arg,,}")
    if [ "${arg}" != "" ]; then
      if [ "${arg:0:1}" = "-" ]; then
        break
      fi

      commandDir+="${arg}/"
      commandPath+="${arg}/"
      commandTree+="${arg} "
      commandFlagPrefix+="${arg}_"
    fi
  done

  commandDir="${commandDir%/}"
  commandPath="${commandTree%/}"
  commandTree="${commandTree% }"
  commandFlagPrefix="${commandFlagPrefix%_}"

  #
  # 6. The command tree must have at least one argument.
  if [ "${commandTree}" = "" ]; then
    echo "[ERR] Empty/invalid command context."
    echo "      Expected at least one subcommand. Type '${commandName} -h' to know options."
    return 1
  fi

  #
  # 7. Checks if the path to the command directory exists.
  if [ ! -d "${commandDir}" ]; then
    echo "[ERR] Command tree context '${commandName} ${commandTree}' not found."
    echo "      Missing directory '${commandDir}'."
    return 1
  fi

  #
  # 8. Loads all global asset scripts.
  local file=""
  if [ -d "${rootPath}/globals" ]; then
    local tgtGlobalFiles=($(find "${rootPath}/globals" -type f -name "*.sh" | sort))
    
    for file in "${tgtGlobalFiles[@]}"; do
      if [[ "${file}" == *_test.sh ]]; then
        continue
      fi
      . "${file}"
    done
  fi

  #
  # 9. Loads all scripts specific to the command tree context.
  local tgtCommandFiles=($(find "${commandDir}" -type f -name "*.sh" | sort))
  for file in "${tgtCommandFiles[@]}"; do
    if [[ "${file}" == *_test.sh ]]; then
      continue
    fi
    . "${file}"
  done





  SHELL_CLI_ROOT_PATH="${rootPath}"
  SHELL_CLI_COMMAND_NAME="${commandName}"
  SHELL_CLI_COMMAND_DIR="${commandDir}"
  SHELL_CLI_COMMAND_PATH="${commandPath}"
  SHELL_CLI_COMMAND_TREE="${commandTree}"
  SHELL_CLI_COMMAND_FLAG_FAMILY="${commandFlagPrefix}_FLAG"
  SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER="${SHELL_CLI_COMMAND_FLAG_FAMILY}_ORDER"

  SHELL_CLI_COMMAND_FN_ACTION="${commandFlagPrefix,,}_action"
  SHELL_CLI_COMMAND_FN_VALIDATE="${commandFlagPrefix,,}_validate"



  #
  # 10. checks if the command returns the record defined in the scope
  if ! shell_cli_utils_array_is_assoc "${SHELL_CLI_COMMAND_FLAG_FAMILY}"; then
    echo "[ERR] Command layout definition is missing."
    echo "      expected an associative array (declare -A) with the name '${SHELL_CLI_COMMAND_FLAG_FAMILY}'."
    echo "      containing 'cmd', 'summary' and 'description' keys."
    return 1
  fi


  #
  # 11. Checks if the flag ordenador array exists for the command being prepared.
  if ! shell_cli_utils_array_is_indexed "${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"; then
    echo "[ERR] The flag-ordering array was not defined."
    echo "      expected an indexed array (declare -a) with the name '${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}'."
    return 1
  fi


  #
  # 12. checks whether the flags defined in the ordenador array have their respective definitions
  local -n flagNameOrder="${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"
  if [ "${#flagNameOrder[@]}" -gt "0" ]; then
    local flagName=""
    local flagAssocName=""
    local flagLong=""
    local flagShort=""
    
    for flagName in "${flagNameOrder[@]}"; do
      flagAssocName="${SHELL_CLI_COMMAND_FLAG_FAMILY}_${flagName}"
      if shell_cli_utils_array_is_assoc "${flagAssocName}"; then
        echo "[ERR] The flag '${flagName}' does not have its corresponding definition."
        echo "      expected an associative array (declare -A) with the name '${flagAssocName}'."
        return 1
      fi

      local -n flagAssocDefinition="${flagAssocName}"
      flagLong="${flagAssocDefinition["long"]}"
      flagShort="${flagAssocDefinition["short"]}"
      SHELL_CLI_COMMAND_FLAG_LONGNAME["${flagLong}"]="${flagAssoc}"
      SHELL_CLI_COMMAND_FLAG_SHORTNAME["${flagShort}"]="${flagLong}"
      unset -n flagAssocDefinition
    done
  fi
  unset -n flagNameOrder


  #
  # 13. Checks if the command's main function actually exists.
  if ! declare -f "$SHELL_CLI_COMMAND_FN_ACTION" >/dev/null; then
    echo "[ERR] Main action function '${SHELL_CLI_COMMAND_FN_ACTION}' is missing."
    return 1
  fi


  #
  # 14. Check if the command's special validation function is present.
  if ! declare -f "$SHELL_CLI_COMMAND_FN_VALIDATE" >/dev/null; then
    SHELL_CLI_COMMAND_FN_VALIDATE=""
  fi


  #
  # 15. compiles engine Shell CLI metaflags
  if ! shell_cli_compile_flag_family "METAGFLAG" "SHELL_CLI_METAFLAG_DEFAULT_ORDER"; then
    echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return 1
  fi


  #
  # 16. compiles the command flags
  if ! shell_cli_compile_flag_family "${SHELL_CLI_COMMAND_FLAG_FAMILY}" "${SHELL_CLI_COMMAND_FLAG_FAMILY_ORDER}"; then
    echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
    return 1
  fi


  return 0
}
