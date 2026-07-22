#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/07_datetime.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_datetime normalize 'datetime' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   date in YYYY-MM-DD HH:MM:SS format
#   or the original string otherwise.
shell_cli_type_normalize_datetime() {
  local value=$(shell_cli_type_normalize_string_code_text_trim "${1}")
  local date_part=""
  local time_part=""

  if [[ "$value" == *[[:space:]]* ]]; then
    date_part="${value%% *}"
    time_part="${value#* }"
  else
    if [[ "$value" == *:* ]]; then
      date_part="0001-01-01"
      time_part="$value"
    else
      date_part="$value"
      time_part="00:00:00"
    fi
  fi

  local clean_date=$(shell_cli_type_normalize_date "$date_part")
  local clean_time=$(shell_cli_type_normalize_time "$time_part")

  echo "${clean_date} ${clean_time}"
}



# shell_cli_type_validate_datetime validate 'datetime' (YYYY-MM-DD HH:MM:SS).
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_datetime() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  if [ "${#value}" != "19" ]; then
    return 1
  fi

  if [[ ! "$value" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[0-9]|3)[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
    return 1
  fi

  local ts=$(date -d "$value" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$value" +%s 2>/dev/null)
  local check_val=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

  if [ -z "$ts" ] || [ "$value" != "$check_val" ]; then
    return 1
  fi

  return 0
}
