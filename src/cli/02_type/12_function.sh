#!/usr/bin/env bash

# shell_cli_type_normalize_function — normalize 'function' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string corresponds to an actual function
#   defined in the shell; only ensures a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized function name candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_function() {
  local value="${1}"

  # Invoke core string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_function — validate 'function' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Uses 'declare -f' to check if a function with the given name exists in the current
#   shell environment.
# - If the function is defined, the value is considered valid.
# - If not, the value is considered invalid.
# 
# Returns:
# - 0: validation success (function exists).
# - 1: value is not a valid representative of this type (function not found).
# - 10: invalid control characters detected.
shell_cli_type_validate_function() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if declare -f "${value}" >/dev/null; then
    return 0
  fi

  return 1
}
