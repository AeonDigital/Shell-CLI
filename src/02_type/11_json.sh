#!/usr/bin/env bash

# shell_cli_type_normalize_json - normalize 'json' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - First applies string normalization via 'shell_cli_type_normalize_string'.
# - Attempts to parse the input as a simplified JSON string using
#   'shell_cli_parse_sjson_to_assoc'.
# - If parsing succeeds:
#   * By default, returns the name of the internal assoc object
#     ('SHELL_CLI_PARSE_SJSON_TO_ASSOC') that holds the parsed key/value pairs.
#   * If 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME' is set (meaning the input
#     referenced an existing assoc variable), returns that variable name instead.
# - If parsing fails, returns the original input unchanged, consistent with
#   the behavior of other normalization functions.
#
# Returns:
# - Echoes the name of the assoc variable to stdout (either the internal
#   parse object or the original assoc name).
# - If parsing fails, echoes the original string.
shell_cli_type_normalize_json() {
  local value=$(shell_cli_type_normalize_string "${1}")

  if shell_cli_parse_sjson_to_assoc "${value}"; then
    value="SHELL_CLI_PARSE_SJSON_TO_ASSOC"

    if [ "${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}" != "" ]; then
      value="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}"
    fi
  fi
  
  echo "${value}"
}



# shell_cli_type_validate_json - validate 'json' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Attempts to parse the input as simplified JSON (SJSON) using
#   'shell_cli_parse_sjson_to_assoc'.
# - If parsing fails, the value is considered invalid.
# - If parsing succeeds, the value is considered valid.
# - Unlike normalization, validation does not produce a normalized output;
#   it only returns a status code indicating success or failure.
#
# Returns:
# - 0: validation success (value is a valid JSON string).
# - 1: validation failure (parse failed).
# - 10: invalid control characters detected.
shell_cli_type_validate_json() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if ! shell_cli_parse_sjson_to_assoc "${value}"; then
    return "2"
  fi

  return 0
}
