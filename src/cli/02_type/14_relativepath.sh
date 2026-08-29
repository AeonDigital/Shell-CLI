#!/usr/bin/env bash

# shell_cli_type_normalize_relativepath — normalize 'relativepath' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid relative path; only ensures
#   a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized relative path candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_relativepath() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_relativepath — validate 'relativepath' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Leverages 'shell_cli_type_validate_path' to apply core path validation rules
#   (rejecting unsafe characters and invalid structures).
# - Explicitly rejects absolute paths:
#   + Unix roots starting with '/'.
#   + Windows drive letter prefixes (e.g., "C:\", "D:/").
# - Accepts only structurally safe relative paths (e.g., "folder/file.txt", "./script.sh",
#   "../config").
# - Does not check for actual existence of the path in the filesystem, only structural
#   correctness and relativity.
# 
# Returns:
# - 0: validation success (value is structurally valid as a relative path).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_relativepath() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if ! shell_cli_type_validate_path "${value}"; then
    return 1
  fi

  # Reject absolute Unix roots or Windows drive letters prefix structures
  if [[ "${value}" =~ ^\/ ]] || [[ "${value}" =~ ^[A-Za-z]:\\ ]] || [[ "${value}" =~ ^[A-Za-z]:\/ ]]; then
    return 1
  fi

  return 0
}
