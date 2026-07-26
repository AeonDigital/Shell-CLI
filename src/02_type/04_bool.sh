#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/04_bool.sh
# DESCRIPTION: 
# ==============================================================================

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
# - If the input does not match any recognized representation,
#   returns the original string unchanged.
#
# Returns:
# - Outputs:
#   * "1" for true/1
#   * "0" for false/0
#   * Original string otherwise
shell_cli_type_normalize_bool() {
  local value=$(shell_cli_type_normalize_string "${1,,}")

  case "$value" in
    0|false) value="0"  ;;
    1|true)  value="1"  ;;
    *)       value="${1}" ;;
  esac

  echo "${value}"
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
