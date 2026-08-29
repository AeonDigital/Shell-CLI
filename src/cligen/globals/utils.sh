#!/usr/bin/env bash

# ==============================================================================
# DESCRIPTION: Global shared utility functions and validation transformers.
# ==============================================================================

# Note: shared functions and global variables should be declared directly inside
# this architecture layer to enable cross-command reuse.

if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" = "" ]; then
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="0"

  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PATH=""

  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""


  declare -ga SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
  declare -gx XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""

  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""

  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME=""
  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT=""

  declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
fi




# shell_cli_cmd_cligen_env_reset
# 
# Completely resets the currently defined environment variables.
shell_cli_cmd_cligen_env_reset() {
  SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="0"

  SHELL_CLI_CMD_CLIGEN_ENV_PATH=""

  SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""


  SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
  XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""

  SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT=""

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
}



# shell_cli_cmd_cligen_pkg_set
shell_cli_cmd_cligen_pkg_set() {
  local pkg="${1}"
  local pkgfn="${pkg//-/_}"

  SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME="${pkg}"
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH="${SHELL_CLI_CMD_CLIGEN_ENV_PATH}/${pkgfn}"
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/${pkgfn}.sh"
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER="${pkgfn,,}"
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER="${pkgfn^^}"

  return 0
}
# shell_cli_cmd_cligen_pkg_unset
shell_cli_cmd_cligen_pkg_unset() {
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
  SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""


  SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
  XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""
}


# shell_cli_cmd_cligen_cmd_set
shell_cli_cmd_cligen_cmd_set() {
  local cmd="${1}"
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
  SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
  SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}/${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER}.sh"



  local -n array_cmd="${cmd}"
  local c=""
  local cpath=""

  for c in "${array_cmd[@]}"; do
    if [ "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}" != "" ]; then
      SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
      SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
    fi

    cpath="${c//-/_}"
    SHELL_CLI_CMD_CLIGEN_ENV_CMD+=("${c}")
    SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME="${c}"
    SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE+="${c} "
    SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH+="/src/${cpath}"
    SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER+="${cpath,,}_"
    SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER+="${cpath^^}_"
  done

  # 
  # In Bash, it is not possible to export arrays. We solved this by serializing the
  # value so it can be retrieved in a subsequent session.
  XSHELL_CLI_CMD_CLIGEN_ENV_CMD="${SHELL_CLI_CMD_CLIGEN_ENV_CMD[*]}"

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE:0: -1}"
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER:0: -1}"
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER:0: -1}"

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/flags.sh"

  return 0
}
# shell_cli_cmd_cligen_cmd_unset
shell_cli_cmd_cligen_cmd_unset() {
  SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
  XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""

  SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
}





declare -gx SHELL_CLI_CMD_CLIGEN_TEMPLATE_URL="https://raw.githubusercontent.com/AeonDigital/Shell-CLI/refs/heads/main/src/cligen/templates"
declare -gx SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH=""
declare -ga SHELL_CLI_CMD_CLIGEN_TEMPLATE_FILES=(
  "pkg_boot.tmpl"
  "pkg_cmd.tmpl"
  "pkg_entrypoint.tmpl"
  "pkg_readme.tmpl"

  "cmd_action.tmpl"
  "cmd_cmd.tmpl"
  "cmd_flags.tmpl"

  "global_flags.tmpl"
  "global_utils.tmpl"
)


# shell_cli_cmd_cligen_utils_template_set_dirpath
# 
# Obtains the full path to the template files directory and assigns this information
# to the global variable 'SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH'.
shell_cli_cmd_cligen_utils_template_set_dirpath() {
  if [ "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}" = "" ]; then
    SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH="${SHELL_CLI_RESOURCE_PATH}/templates"
    if [ "${SHELL_CLI_DEBUG}" = "1" ]; then
      SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/templates"
    fi
  fi

  return 0
}


# shell_cli_cmd_cligen_utils_template_check_directory
# 
# Checks if the template file directory exists at the specified location.
shell_cli_cmd_cligen_utils_template_check_directory() {
  if [ ! -d "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}" ]; then
    echo "[ x ] :: Templates directory not found!"
    echo "         Looking in '${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}'"
    echo "         Run the 'update-template' command to perform the download."
    echo ""
    return 1
  fi

  return 0
}


# shell_cli_cmd_cligen_utils_template_check_files
# 
# Checks if all template files are available in the current installation.
shell_cli_cmd_cligen_utils_template_check_files() {
  shell_cli_cmd_cligen_utils_template_set_dirpath

  if ! shell_cli_cmd_cligen_utils_template_check_directory; then
    return 1
  fi


  local file=""
  local ok="1"
  for file in "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_FILES[@]}"; do
    if [ ! -f "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/${file}" ]; then
      ok="0"
      echo "[ x ] File template '"${file}"' not found!"
      echo ""
    fi
  done


  if [ "${ok}" = "0" ]; then
    echo "[ x ] :: Run the 'update-template' command to perform the download"
    echo "         of the missing files"
    echo ""
    return 1
  fi

  return 0
}





shell_cli_cmd_cligen_utils_clear_non_empty_directory() {
  local tgt_dir="${1}"

  if [ -d "${tgt_dir}" ]; then
    local user_choice=""

    echo "================================================================================"
    echo "[ ! ] WARNING: Target directory is not empty!"
    echo ""
    echo "      Target Path: ${tgt_dir}"
    echo ""
    echo "      Proceeding will remove all existing content, including commands, subcommands,"
    echo "      configurations and any other auxiliary files within the respective directory."
    echo ""
    echo "      This action cannot be undone!"
    echo ""

    # Inquire user confirmation to prevent accidental project destruction
    echo "[ ? ] :: Do you want to continue? (y/N):"
    read -p "[ > ] :: " -r user_choice < /dev/tty
    user_choice="${user_choice,,}"

    if [ "${user_choice}" != "y" ]; then
      echo "[END] Execution aborted by user."
      return 1
    fi

    rm -rf "${tgt_dir}" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "[ x ] It was not possible to delete the existing content."
      echo "      Check your user permissions and try again."
      echo "[END] Execution interrupted."
      echo ""
      return 1
    fi

    echo "[ v ] Target directory successfully removed!"
    echo ""
  fi

  return 0
}





declare -gAx SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER=()

# shell_cli_cmd_cligen_placeholder_set_assoc
shell_cli_cmd_cligen_placeholder_set_assoc() {
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["ENV_PATH"]="${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"

  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_NAME"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_FN_LOWER"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_FN_UPPER"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER}"

  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_NAME"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_TREE"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_PATH"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_SCRIPT"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_FN_LOWER"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_FN_UPPER"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER}"

  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["FLAG_SCRIPT"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"

  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["SUMMARY"]="${SHELL_CLI_CMD_INPUT["summary"]}"
  SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["DESCRIPTION"]="${SHELL_CLI_CMD_INPUT["description"]}"
}
