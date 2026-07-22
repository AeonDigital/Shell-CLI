#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/12_json.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_json normalize 'json' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_json() {
  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$1"; then
    return "1"
  fi
  echo "${SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING}"
}



# shell_cli_type_validate_json validate 'json'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_json() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value" "1"; then
    return 10
  fi

  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$value"; then
    return "2"
  fi

  return 0
}
