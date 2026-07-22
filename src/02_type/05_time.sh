#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/05_time.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_time normalize 'time' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   time in HH:MM:SS format
#   or the original string otherwise.
shell_cli_type_normalize_time() {
  local value=$(shell_cli_type_normalize_string_code_text_trim "${1}")

  case "${#value}" in
    2) value="${value}:00:00" ;; # HH     -> HH:00:00
    5) value="${value}:00"    ;; # HH:MM  -> HH:MM:00
    8) value="$value"         ;; # Fully formed
    *) value="$1"             ;;
  esac

  echo "$value"
}



# shell_cli_type_validate_time validate 'time' (HH:MM:SS).
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_time() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [ "${#value}" != "8" ]; then
    return 1
  fi

  local ts=$(date -d "0001-01-01 $value" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 $value" +%s 2>/dev/null)
  local check_val=$(date -d "@$ts" +%H:%M:%S 2>/dev/null || date -j -r "$ts" +%H:%M:%S 2>/dev/null)

  if [ -z "$ts" ] || [ "$value" != "$check_val" ]; then
    return 1
  fi

  return 0
}

