#!/usr/bin/env bash

# shell_cli_type_normalize_string — normalize 'string' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Removes all code control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the fully normalized text results.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_string() {
  local value="${1}"

  # Invoke core normalization utility directly
  shell_cli_type_normalize_main "${value}" "1" "1" "1"

  return 0
}



# shell_cli_type_validate_string — validate 'string' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - Invalidates if any code control characters are found (including '\n', '\r', and
#   '\t').
# 
# Returns:
# - 0: validation success.
# - 1: reserved/not used in current implementation.
# - 10: invalid control characters detected.
shell_cli_type_validate_string() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  shell_cli_type_validate_main "${value}" "1" "1"
  local status=$?

  return "${status}"
}
