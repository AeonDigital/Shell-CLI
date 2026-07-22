#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/03_int.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_int normalize 'int' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_int() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_int validate 'int'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_int() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    return 1
  fi

  return 0
}
