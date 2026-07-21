#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/12_path.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_path normalize 'path' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_path() {
  shell_cli_type_normalize_string_full "${1}"
}



# shell_cli_type_validate_path validate 'path'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_path() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes (") and pipe (|)
  if [[ "$value" =~ [\*\?\"\<\>\|] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}
