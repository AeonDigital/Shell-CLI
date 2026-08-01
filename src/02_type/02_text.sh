#!/usr/bin/env bash

# shell_cli_type_normalize_text - normalize 'text' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Removes all code control characters except '\n', '\r', and '\t' to allow multi‑line text formatting.
# - Trims leading and trailing whitespace.
#
# Returns:
# - Outputs the normalized string to stdout.
shell_cli_type_normalize_text() {
  shell_cli_type_normalize_main "${1}" "1" "0" "1"
}



# shell_cli_type_validate_text - validate 'text' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - Invalidates if any code control characters are found (except '\n', '\r', and '\t').
#
# Returns:
# - 0: validation success.
# - 1: reserved/not used in current implementation.
# - 10: invalid control characters detected.
shell_cli_type_validate_text() {
  local status=$(shell_cli_type_validate_main "${1}" "1" "0"; echo $?)
  return "${status}"
}
