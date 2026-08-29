#!/usr/bin/env bash

# shell_cli_type_normalize_time — normalize 'time' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Adjusts the format based on input length:
#   * Length 2 = "HH" = converted to "HH:00:00".
#   * Length 5 = "HH:MM" = converted to "HH:MM:00".
#   * Length 8 = "HH:MM:SS" = accepted as fully formed.
#   * Any other length = returned unchanged.
# - Does not guarantee that the resulting string is a valid time; only ensures a
#   consistent format when possible.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the standardized time formatting.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_time() {
  local origValue="${1}"

  # Reset global variables
  SHELL_CLI_FN_RETURN=""

  # Invoke core string normalization
  shell_cli_type_normalize_string "${origValue}"
  local value="${SHELL_CLI_FN_RETURN}"

  case "${#value}" in
    2) value="${value}:00:00" ;; # HH     -> HH:00:00
    5) value="${value}:00"    ;; # HH:MM  -> HH:MM:00
    8) value="${value}"       ;; # Fully formed
    *) value="${origValue}"   ;;
  esac

  # Assign global variables
  SHELL_CLI_FN_RETURN="${value}"

  return 0
}



# shell_cli_type_validate_time — validate 'time' values (HH:MM:SS).
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Requires the input to have exactly 8 characters ("HH:MM:SS").
# - Uses system 'date' command to parse the value against a fixed date (e.g., "0001-01-01
#   HH:MM:SS") to check validity.
# - Compares the parsed result back to the original string to ensure the time is
#   structurally valid and correctly formatted.
# - If parsing fails or the comparison does not match, the value is invalid.
# 
# Returns:
# - 0: validation success (value is a valid time in HH:MM:SS).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_time() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if [ "${#value}" != "8" ]; then
    return 1
  fi

  local ts=$(date -d "0001-01-01 ${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 ${value}" +%s 2>/dev/null)
  local check_val=$(date -d "@${ts}" +%H:%M:%S 2>/dev/null || date -j -r "${ts}" +%H:%M:%S 2>/dev/null)

  if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
    return 1
  fi

  return 0
}
