#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/19_fullurl.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_fullurl normalize 'fullurl' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_fullurl() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_fullurl validate 'fullurl'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_fullurl() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  # Enforces explicit schema protocol definitions followed by hostname validation
  local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
  if [[ "$value" =~ $url_regex ]]; then
    return 0
  fi

  return 1
}
