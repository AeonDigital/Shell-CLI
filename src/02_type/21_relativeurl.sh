#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/21_relativeurl.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_relativeurl — normalize 'relativeurl' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not garantir que o valor seja uma URL relativa válida;
#   apenas garante uma forma limpa e segura.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input is not a valid relative URL, the original string is echoed.
shell_cli_type_normalize_relativeurl() {
  shell_cli_type_normalize_string "${1}"
}



# shell_cli_type_validate_relativeurl — validate 'relativeurl' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Explicitly rejects values that begin with network protocols:
#   * "http://", "https://".
#   * "ftp://".
# - Accepts only values that start with a forward slash ('/'), followed by
#   safe path segments.
# - Regex allows:
#   * Nested path segments (e.g., "/assets/img/logo.png").
#   * Optional query strings (e.g., "?id=123").
#   * Optional fragments (e.g., "#section").
# - If the regex matches, the value is considered valid.
# - If not, the value is considered invalid.
# - Does not check for actual existence of the resource, only structural
#   correctness and relativity.
#
# Returns:
# - 0: validation success (value is structurally valid as a relative URL).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_relativeurl() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # Relative URLs must omit network protocol configurations and initialize with a forward slash
  if [[ "${value}" =~ ^https?:\/\/ ]] || [[ "${value}" =~ ^ftp:\/\/ ]]; then
    return 1
  fi

  if [[ "${value}" =~ ^\/[A-Za-z0-9._%+-]*(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$ ]]; then
    return 0
  fi

  return 1
}
