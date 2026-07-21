#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/09_enum.sh
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
  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$1"; then
    return "1"
  fi
  echo "${SHELL_CLI_PARSE_JSON_TO_ASSOC_STRING}"
}



# shell_cli_type_validate_enum validate 'enum'.
#
# Arguments:
# - value: normalizated value.
# - aux: associative array name or JSON string.
#
# Returns:
# - 0: if the value is a valid representative of this type
#      the given value must match with any 'key' or 'value' in the
#      assoc array map.
# - 1: if the value is not a valid representative of this type.
# - 2: if the aux is not a valid assoc array or stringified JSON object.
# - 10: if the value contains any control characters.
shell_cli_type_validate_enum() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value" "1"; then
    return 10
  fi

  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$aux"; then
    return "2"
  fi

  # Check if the input exists as a value or an aliased group literal string
  local key=""
  local val=""
  for key in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC[@]}"; do
    val="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[$key]}"
    if [ "$value" = "$key" ] || [ "$value" = "$val" ]; then
      return 0
    fi
  done

  return 1
}
