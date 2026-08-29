#!/usr/bin/env bash

# shell_cli_type_normalize_bool — normalize 'bool' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Converts the input to lowercase and applies string normalization.
# - Maps recognized boolean representations:
#   * "0" or "false" → "0"
#   * "1" or "true"  → "1"
# - If the input does not match any recognized representation, returns the original
#   string unchanged.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing "1" for true, "0" for false, or the original
#   input.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_bool() {
  local origValue="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${origValue,,}"
  local value="${SHELL_CLI_FN_RETURN}"

  case "${value}" in
    0|false) value="0"   ;;
    1|true)  value="1"   ;;
    *)       value="${origValue}" ;;
  esac

  # Assign global variables
  SHELL_CLI_FN_RETURN="${value}"

  return 0
}



# shell_cli_type_validate_bool — validate 'bool' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Accepts only "1" or "0" as valid normalized values.
# - Any other input is considered invalid.
# 
# Returns:
# - 0: validation success (value is "1" or "0").
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_bool() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if [ "${value}" != "1" ] && [ "${value}" != "0" ]; then
    return 1
  fi

  return 0
}
