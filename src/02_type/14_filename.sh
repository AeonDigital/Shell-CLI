#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/14_filename.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_filename normalize 'filename' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_filename() {
  shell_cli_type_normalize_string_full "${1}"
}



# shell_cli_type_validate_filename validate 'filename'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_filename() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  # File names cannot possess directory trailing slash or path separator tokens
  if [[ "$value" == *\/* ]] || [[ "$value" == *\\* ]] || [ -z "$value" ]; then
    return 1
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes ("), pipe (|) and Windows colon (:)
  if [[ "$value" =~ [\*\?\"\<\>\|:] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}
