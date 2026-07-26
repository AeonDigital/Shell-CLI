#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/14_relativepath.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_relativepath — normalize 'relativepath' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee que o valor seja um caminho relativo válido;
#   apenas garante uma forma limpa e segura.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input is not a valid relative path, the original string is echoed.
shell_cli_type_normalize_relativepath() {
  shell_cli_type_normalize_string "${1}"
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
#   * Unix roots starting with '/'.
#   * Windows drive letter prefixes (e.g., "C:\", "D:/").
# - Accepts only structurally safe relative paths (e.g., "folder/file.txt",
#   "./script.sh", "../config").
# - Does not check for actual existence of the path in the filesystem,
#   only structural correctness and relativity.
#
# Returns:
# - 0: validation success (value is structurally valid as a relative path).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_relativepath() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # Leverage core validation rules for general character checking first
  if ! shell_cli_type_validate_path "${value}"; then
    return 1
  fi

  # Reject absolute Unix roots or Windows drive letters prefix structures
  if [[ "${value}" =~ ^\/ ]] || [[ "${value}" =~ ^[A-Za-z]:\\ ]] || [[ "${value}" =~ ^[A-Za-z]:\/ ]]; then
    return 1
  fi

  return 0
}
