#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/11_function.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_function normalize 'function' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_function() {
  shell_cli_type_normalize_string_full "${1}"
}



# shell_cli_type_validate_function validate 'function'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_function() {
  local value="$1"
  local aux="$2"

  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if declare -f "$value" >/dev/null; then
    return 0
  fi

  return 1
}
