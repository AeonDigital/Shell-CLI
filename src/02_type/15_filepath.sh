#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/15_filepath.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_filepath normalize 'filepath' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_filepath() {
  shell_cli_type_normalize_string_full "${1}"
}



# shell_cli_type_validate_filepath validate 'filepath'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_filepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if ! shell_cli_type_validate_path "$value"; then
    return 1
  fi

  # Rejects strings terminating with a path divider trailing slash character
  if [[ "$value" =~ \/$ ]] || [[ "$value" =~ \\$ ]] || [ -z "$value" ]; then
    return 1
  fi

  return 0
}
