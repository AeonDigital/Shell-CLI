#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/18_dirname.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_dirname normalize 'dirname' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_dirname() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_dirname validate 'dirname'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_dirname() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  # Reuses individual filename structural constraints as rules match exactly
  if ! shell_cli_type_validate_filename "$value"; then
    return 1
  fi

  return 0
}
