#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/02_text.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_text normalize 'text' value.
# - remove ALL control characters (except \n, \r, and \t)
# - performa a trim
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_text() {
  shell_cli_type_normalize_main "$1" "1" "0" "1"
}



# shell_cli_type_validate_text validate 'text'.
# - invalidate if found ANY control characters (except \n, \r, and \t)
#
# Arguments:
# - value: non empty normalizated value.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_text() {
  local status=$(shell_cli_type_validate_main "$1" "1" "0"; echo $?)
  return "$status"
}
