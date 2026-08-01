#!/usr/bin/env bash

# shell_cli_type_normalize_dirname - normalize 'dirname' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not garantir que o valor seja um nome de diretório válido;
#   apenas garante uma forma limpa e segura.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input is not a valid dirname, the original string is echoed.
shell_cli_type_normalize_dirname() {
  shell_cli_type_normalize_string "${1}"
}



# shell_cli_type_validate_dirname - validate 'dirname' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Reuses the same structural constraints applied to filenames via
#   'shell_cli_type_validate_filename', since directory names follow
#   identical rules (no path separators, no unsafe characters).
# - Accepts only structurally safe directory names (e.g., "config", "src",
#   "backup_2026").
# - Does not check for actual existence of the directory in the filesystem,
#   only structural correctness and safety.
#
# Returns:
# - 0: validation success (value is structurally valid as a dirname).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_dirname() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # Reuses individual filename structural constraints as rules match exactly
  if ! shell_cli_type_validate_filename "${value}"; then
    return 1
  fi

  return 0
}
