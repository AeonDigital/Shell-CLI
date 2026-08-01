#!/usr/bin/env bash

# shell_cli_type_normalize_int - normalize 'int' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Does not enforce numeric conversion; if the input is not a valid integer,
#   the original string is returned unchanged.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input is not a valid integer, the original string is echoed.
shell_cli_type_normalize_int() {
  shell_cli_type_normalize_string "${1}"
}



# shell_cli_type_validate_int - validate 'int' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Accepts only values matching the integer pattern:
#   * Optional leading minus sign.
#   * One or more digits (0–9).
# - Any other input is considered invalid.
#
# Returns:
# - 0: validation success (value is a valid integer).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_int() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if [[ ! "${value}" =~ ^-?[0-9]+$ ]]; then
    return 1
  fi

  return 0
}
