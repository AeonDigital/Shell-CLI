#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/02_text.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_text — normalize 'text' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Removes all code control characters (except '\n', '\r', and '\t').
# - Preserves text control characters ('\n', '\r', and '\t') to allow
#   multi‑line text formatting.
# - Trims leading and trailing whitespace, including spaces, tabs,
#   and boundary '\n' and '\r'.
#
# Returns:
# - Outputs the normalized string to stdout.
shell_cli_type_normalize_text() {
  shell_cli_type_normalize_main "${1}" "1" "0" "1"
}



# shell_cli_type_validate_text — validate 'text' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - Invalidates if any code control characters are found (except '\n', '\r', and '\t').
# - Text control characters ('\n', '\r', and '\t') are allowed.
# - Delegates validation to 'shell_cli_type_validate_main'.
#
# Returns:
# - 0: validation success.
# - 1: reserved/not used in current implementation.
# - 10: invalid control characters detected.
shell_cli_type_validate_text() {
  local status=$(shell_cli_type_validate_main "${1}" "1" "0"; echo $?)
  return "${status}"
}
