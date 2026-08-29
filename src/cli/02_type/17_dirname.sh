#!/usr/bin/env bash

# shell_cli_type_normalize_dirname — normalize 'dirname' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid directory name; only
#   ensures a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized dirname candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_dirname() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_dirname — validate 'dirname' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Reuses the same structural constraints applied to filenames via 'shell_cli_type_validate_filename',
#   since directory names follow identical rules (no path separators, no unsafe characters).
# - Accepts only structurally safe directory names (e.g., "config", "src", "backup_2026").
# - Does not check for actual existence of the directory in the filesystem, only
#   structural correctness and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a dirname).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_dirname() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if ! shell_cli_type_validate_filename "${value}"; then
    return 1
  fi

  return 0
}
