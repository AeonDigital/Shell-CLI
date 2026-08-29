#!/usr/bin/env bash

# shell_cli_type_normalize_dirpath — normalize 'dirpath' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid directory path; only
#   ensures a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized dirpath candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_dirpath() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_dirpath — validate 'dirpath' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Leverages 'shell_cli_type_validate_path' to apply core path validation rules
#   (rejecting unsafe characters and invalid structures).
# - Accepts structurally safe directory paths (e.g., "/home/user/docs", "C:\Users\Public",
#   "./config").
# - Unlike 'filepath', allows trailing path separators, since directories may be
#   represented with a final '/' or '\'.
# - Does not check for actual existence of the directory in the filesystem, only
#   structural correctness and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a dirpath).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_dirpath() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if ! shell_cli_type_validate_path "${value}"; then
    return 1
  fi

  return 0
}
