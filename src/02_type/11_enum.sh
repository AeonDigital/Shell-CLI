#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/11_enum.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_enum normalize 'enum' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_enum() {
  shell_cli_type_normalize_main_assoc_types "$1"
}



# shell_cli_type_validate_enum validate 'enum'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: name of the associative array containing the acceptable values.
#
# Returns:
# - 0: if the value is a valid representative of this type
#      the given value must match with any 'key' or 'value' in the
#      assoc array map.
#      The values ​​corresponding to the selected 'key' and 'value' will 
#      be stored in the variables:
#      - SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_KEY
#      - SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_VALUE
#
# - 1: if the value is not a valid representative of this type.
# - 2: if 'aux' is not an assoc.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_enum() {
  shell_cli_type_validate_main_assoc_types "$1" "$2"
  return "$?"
}
