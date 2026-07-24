#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/01_string.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_string normalize 'string' value.
# - remove ALL control characters (except \n, \r, and \t)
# - remove text control characters (\n, \r, and \t)
# - performa a trim
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_string() {
  shell_cli_type_normalize_main "$1" "1" "1" "1"
}



# shell_cli_type_validate_string validate 'string'.
# - invalidate if found ANY control characters (except \n, \r, and \t)
# - invalidate if found ANY text control characters (\n, \r, and \t)
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_string() {
  local status=$(shell_cli_type_validate_main "$1" "1" "1"; echo $?)
  return "$status"
}
