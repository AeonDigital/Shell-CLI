#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/06_date.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_date normalize 'date' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   date in YYYY-MM-DD format
#   or the original string otherwise.
shell_cli_type_normalize_date() {
  local value=$(shell_cli_type_normalize_string_code_text_trim "${1}")

  case "${#value}" in
    4)  value="${value}-01-01"  ;; # YYYY     -> YYYY-01-01
    7)  value="${value}-01"     ;; # YYYY-MM  -> YYYY-MM-01
    10) value="$value"          ;; # Fully formed
    *)  value="$1"              ;;
  esac

  echo "$value"
}



# shell_cli_type_validate_date validate 'date' (YYYY-MM-DD).
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_date() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [ "${#value}" != "10" ]; then
    return 1
  fi

  local ts=$(date -d "$value" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$value" +%s 2>/dev/null)
  local check_val=$(date -d "@$ts" +%Y-%m-%d 2>/dev/null || date -j -r "$ts" +%Y-%m-%d 2>/dev/null)

  if [ -z "$ts" ] || [ "$value" != "$check_val" ]; then
    return 1
  fi

  return 0
}
