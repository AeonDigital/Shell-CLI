#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/03_code.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_code normalize 'code' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_code() {
  echo "$1"
}



# shell_cli_type_validate_code validate 'code'.
#
# Arguments:
# - value: non empty normalizated value.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_code() {
  return 0
}
