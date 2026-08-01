#!/usr/bin/env bash

# shell_cli_type_normalize_array - normalize 'array' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - First applies string normalization via 'shell_cli_type_normalize_string'.
# - Attempts to parse the input as a simplified JSON‑array string using
#   'shell_cli_parse_sarray_to_array'.
# - If parsing succeeds:
#   * By default, returns the name of the internal indexed array object
#     ('SHELL_CLI_PARSE_SARRAY_TO_ARRAY') that holds the parsed elements.
#   * If 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME' is set (meaning the input
#     referenced an existing array variable), returns that variable name instead.
# - If parsing fails, returns the original input unchanged, consistent with
#   the behavior of other normalization functions.
#
# Returns:
# - Echoes the name of the array variable to stdout (either the internal
#   parse object or the original array name).
# - If parsing fails, echoes the original string.
shell_cli_type_normalize_array() {
  local value=$(shell_cli_type_normalize_string "${1}")

  if shell_cli_parse_sarray_to_array "${value}"; then
    value="SHELL_CLI_PARSE_SARRAY_TO_ARRAY"

    if [ "${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}" != "" ]; then
      value="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}"
    fi
  fi
  
  echo "${value}"
}



# shell_cli_type_validate_array - validate 'array' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Attempts to parse the input as a simplified JSON‑array string using
#   'shell_cli_parse_sarray_to_array'.
# - If parsing fails, the value is considered invalid.
# - If parsing succeeds, the value is considered valid.
# - Unlike normalization, validation does not produce a normalized output;
#   it only returns a status code indicating success or failure.
#
# Returns:
# - 0: validation success (value is a valid JSON-array string).
# - 1: validation failure (parse failed).
# - 10: invalid control characters detected.
shell_cli_type_validate_array() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if ! shell_cli_parse_sarray_to_array "${value}"; then
    return "2"
  fi

  return 0
}
