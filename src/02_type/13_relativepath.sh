#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/13_relativepath.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_relativepath normalize 'relativepath' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_relativepath() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_relativepath validate 'relativepath'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_relativepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  # Leverage core validation rules for general character checking first
  if ! shell_cli_type_validate_path "$value"; then
    return 1
  fi

  # Reject absolute Unix roots or Windows drive letters prefix structures
  if [[ "$value" =~ ^\/ ]] || [[ "$value" =~ ^[A-Za-z]:\\ ]] || [[ "$value" =~ ^[A-Za-z]:\/ ]]; then
    return 1
  fi

  return 0
}
