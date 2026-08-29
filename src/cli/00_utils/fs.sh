#!/usr/bin/env bash

# shell_cli_utils_fs_dir_path_exists — Checks if the provided directory exists.
# 
# Arguments:
#   - str: Directory path.
# 
# Returns:
# - 0 : if the directory exists
# - 1 : if the directory does not exist. In this case, an error message will be added
#   to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_fs_dir_path_exists() {
  SHELL_CLI_FN_RETURN=""
  if [ ! -d "${1}" ]; then
    SHELL_CLI_FN_RETURN="The specified path does not point to an existing directory ( value='${1}' )."
    return 1
  fi
  return 0
}


# shell_cli_utils_fs_to_absolute_dir_path — Resolve a relative directory path (like
# '.' or '..') into its absolute equivalent.
# 
# Arguments:
#   - str: The relative directory path string to be resolved.
# 
# Returns:
# - 0 : if the directory exists In this case, the absolute dir path will be added
#   to the global variable SHELL_CLI_FN_RETURN.
# - 1 : if the directory does not exist.
shell_cli_utils_fs_to_absolute_dir_path() {
  SHELL_CLI_FN_RETURN=""
  if ! shell_cli_utils_fs_dir_path_exists "${1}"; then
    SHELL_CLI_FN_RETURN=""
    return 1
  fi
  SHELL_CLI_FN_RETURN="$(cd "${1}" && pwd)"
  return 0
}


# shell_cli_utils_fs_file_path_exists — Checks if the provided file exists.
# 
# Arguments:
#   - str: File path.
# 
# Returns:
# - 0 : if the file exists
# - 1 : if the file does not exist. In this case, an error message will be added
#   to the global variable SHELL_CLI_FN_RETURN..
shell_cli_utils_fs_file_path_exists() {
  SHELL_CLI_FN_RETURN=""
  if [ ! -f "${1}" ]; then
    SHELL_CLI_FN_RETURN="The specified path does not point to an existing file ( value='${1}' )."
    return 1
  fi
  return 0
}


# shell_cli_utils_fs_to_absolute_file_path — Resolve a relative file path (like '.'
# or '..') into its absolute equivalent.
# 
# Arguments:
#   - str: The relative file path string to be resolved.
# 
# Returns:
# - 0 : if the file exists In this case, the absolute file path will be added to
#   the global variable SHELL_CLI_FN_RETURN.
# - 1 : if the file does not exist.
shell_cli_utils_fs_to_absolute_file_path() {
  SHELL_CLI_FN_RETURN=""
  local dirpath=$(dirname "${1}")
  if ! shell_cli_utils_fs_dir_path_exists "${dirpath}"; then
    SHELL_CLI_FN_RETURN=""
    return 1
  fi

  local filename=$(basename "${1}")
  local absfilepath="${dirpath}/${filename}"
  if ! shell_cli_utils_fs_file_path_exists "${filename}"; then
    SHELL_CLI_FN_RETURN=""
    return 1
  fi

  SHELL_CLI_FN_RETURN="${absfilepath}"
  return 0
}



# shell_cli_utils_fs_remove_traversal_path — Strip all relative parent directory
# markers ('../' and '..') from a path string.
# 
# Arguments:
#   - str: The raw path string to be sanitized.
# 
# Returns:
# - Assigns the sanitized path string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_fs_remove_traversal_path() {
  SHELL_CLI_FN_RETURN=""
  local path="${1}"

  # 1. Remove '../' when it appears at the very beginning
  path="${path#../}"

  # 2. Remove all occurrences of '/../' from the middle of the string
  path="${path//\/..\//\/}"

  # 3. Remove '../' if it appears at the very end of the string
  path="${path%/../}"
  path="${path%../}"

  SHELL_CLI_FN_RETURN="${path}"
}
