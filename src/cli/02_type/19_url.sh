#!/usr/bin/env bash

# shell_cli_type_normalize_url — normalize 'url' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid URL; only ensures a safe
#   and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized URL candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_url() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_url — validate 'url' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Attempts validation using two complementary routines:
#   + 'shell_cli_type_validate_fullurl' — checks for absolute URLs with scheme (http,
#     https, ftp, etc.).
#   + 'shell_cli_type_validate_relativeurl' — checks for relative URL structures
#     (e.g., "/path/resource").
# - If either validation succeeds, the value is considered valid.
# - If both fail, the value is considered invalid.
# - Does not check for actual reachability of the URL, only structural correctness
#   and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a URL).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_url() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if shell_cli_type_validate_fullurl "${value}" || shell_cli_type_validate_relativeurl "${value}"; then
    return 0
  fi

  return 1
}
