#!/usr/bin/env bash

# shell_cli_type_normalize_date - normalize 'date' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Adjusts the format based on input length:
#   * Length 4 = "YYYY" = converted to "YYYY-01-01".
#   * Length 7 = "YYYY-MM" = converted to "YYYY-MM-01".
#   * Length 10 = "YYYY-MM-DD" = accepted as fully formed.
#   * Any other length = returned unchanged.
# - Does not guarantee that the resulting string is a valid date;
#   only ensures a consistent format when possible.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input does not match expected lengths, the original string is echoed.
shell_cli_type_normalize_date() {
  local value=$(shell_cli_type_normalize_string "${1}")

  case "${#value}" in
    4)  value="${value}-01-01"  ;; # YYYY     -> YYYY-01-01
    7)  value="${value}-01"     ;; # YYYY-MM  -> YYYY-MM-01
    10) value="${value}"        ;; # Fully formed
    *)  value="${1}"            ;;
  esac

  echo "$value"
}



# shell_cli_type_validate_date - validate 'date' values (YYYY-MM-DD).
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Requires the input to have exactly 10 characters ("YYYY-MM-DD").
# - Uses system 'date' command to parse the value:
#   * On Linux: 'date -d'.
#   * On BSD/macOS: 'date -j -f "%Y-%m-%d"'.
# - Converts the parsed timestamp back to "YYYY-MM-DD" and compares with
#   the original input to ensure structural validity.
# - If parsing fails or the comparison does not match, the value is invalid.
#
# Returns:
# - 0: validation success (value is a valid date in YYYY-MM-DD).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_date() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [ "${#value}" != "10" ]; then
    return 1
  fi

  local ts=$(date -d "${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${value}" +%s 2>/dev/null)
  local check_val=$(date -d "@${ts}" +%Y-%m-%d 2>/dev/null || date -j -r "${ts}" +%Y-%m-%d 2>/dev/null)

  if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
    return 1
  fi

  return 0
}
