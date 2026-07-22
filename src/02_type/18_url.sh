#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/18_url.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_url normalize 'url' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_url() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_url validate 'url'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_url() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if shell_cli_type_validate_fullurl "$value" || shell_cli_type_validate_relativeurl "$value"; then
    return 0
  fi

  return 1
}
