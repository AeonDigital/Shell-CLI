#!/usr/bin/env bash

# shell_cli_type_normalize_datetime — normalize 'datetime' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Splits the input into date and time parts:
#   + If the input contains whitespace, the first part is treated as date, the second
#     as time.
#   + If the input contains ':' but no whitespace, assumes only time and prepends
#     "0001-01-01" as the date.
#   + Otherwise, assumes only date and appends "00:00:00" as the time.
# - Normalizes each part separately using 'shell_cli_type_normalize_date' and 'shell_cli_type_normalize_time'.
# - Concatenates the normalized parts into "YYYY-MM-DD HH:MM:SS".
# - Does not guarantee that the resulting string is a valid datetime; only ensures
#   a consistent format when possible.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the standardized datetime formatting.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_datetime() {
  local origValue="${1}"

  # Reset global variables
  SHELL_CLI_FN_RETURN=""

  # Invoke core string normalization
  shell_cli_type_normalize_string "${origValue}"
  local value="${SHELL_CLI_FN_RETURN}"

  local date_part=""
  local time_part=""

  if [[ "${value}" == *[[:space:]]* ]]; then
    date_part="${value%% *}"
    time_part="${value#* }"
  else
    if [[ "${value}" == *:* ]]; then
      date_part="0001-01-01"
      time_part="${value}"
    else
      date_part="${value}"
      time_part="00:00:00"
    fi
  fi

  # Normalize the date segment directly and store its context locally
  shell_cli_type_normalize_date "${date_part}"
  local clean_date="${SHELL_CLI_FN_RETURN}"

  # Normalize the time segment directly and store its context locally
  shell_cli_type_normalize_time "${time_part}"
  local clean_time="${SHELL_CLI_FN_RETURN}"

  # Assign global variables
  SHELL_CLI_FN_RETURN="${clean_date} ${clean_time}"

  return 0
}



# shell_cli_type_validate_datetime — validate 'datetime' values (YYYY-MM-DD HH:MM:SS).
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Requires the input to have exactly 19 characters ("YYYY-MM-DD HH:MM:SS").
# - Uses a regex to check structural validity:
#   + Year: 4 digits.
#   + Month: 01–12.
#   + Day: 01–31 (basic check, not calendar‑aware).
#   + Hour: 00–23.
#   + Minute: 00–59.
#   + Second: 00–59.
# - Uses system 'date' command to parse the value:
#   + On Linux: 'date -d'.
#   + On BSD/macOS: 'date -j -f "%Y-%m-%d %H:%M:%S"'.
# - Converts the parsed timestamp back to "YYYY-MM-DD HH:MM:SS" and compares with
#   the original input to ensure structural and semantic validity.
# - If parsing fails or the comparison does not match, the value is invalid.
# 
# Returns:
# - 0: validation success (value is a valid datetime).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_datetime() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  if [ "${#value}" != "19" ]; then
    return 1
  fi

  if [[ ! "${value}" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[0-9]|3)[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
    return 1
  fi

  local ts=$(date -d "${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${value}" +%s 2>/dev/null)
  local check_val=$(date -d "@${ts}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "${ts}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

  if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
    return 1
  fi

  return 0
}
