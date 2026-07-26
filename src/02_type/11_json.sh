#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/11_json.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_json — normalize 'json' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Attempts to parse the input as simplified JSON (SJSON) using
#   'shell_cli_parse_sjson_to_assoc'.
# - If parsing succeeds:
#   * By default, returns the normalized JSON string stored in
#     'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING'.
#   * If 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME' is set (indicating that
#     the input referenced an existing assoc), returns that name instead.
# - If parsing fails, returns the original input unchanged, consistent
#   with the behavior of other normalization functions.
#
# Returns:
# - Outputs the normalized JSON string or assoc name to stdout.
# - If parsing fails, echoes the original string.
shell_cli_type_normalize_json() {
  local value=$(shell_cli_type_normalize_string "${1}")

  if shell_cli_parse_sjson_to_assoc "${value}"; then
    value="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING}"

    if [ "${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}" != "" ]; then
      value="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}"
    fi
  fi
  
  echo "${value}"
}



# shell_cli_type_validate_json — validate 'json' values.
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
# - Validation here is closely tied to normalization, since both rely
#   on the same parsing routine, but validation differs in that it
#   only returns a status code (success/failure) rather than producing
#   a normalized output.
#
# Returns:
# - 0: validation success (value is valid JSON).
# - 1: value is not a valid representative of this type (parse failed).
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
