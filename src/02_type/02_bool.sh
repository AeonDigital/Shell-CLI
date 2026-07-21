#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/02_bool.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_bool normalize 'bool' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs:
#   "1" for true/1 
#   "0" for false/0
#   or the original string otherwise.
shell_cli_type_normalize_bool() {
  local value=$(shell_cli_type_normalize_string_full "${1,,}")

  case "$value" in
    0|false) value="0"  ;;
    1|true)  value="1"  ;;
    *)       value="$1" ;;
  esac

  echo "$value"
}



# shell_cli_type_validate_bool validate 'bool'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_bool() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [ "$value" != "1" ] && [ "$value" != "0" ]; then
    return 1
  fi

  return 0
}
