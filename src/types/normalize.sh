#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/types/normalize.sh
# DESCRIPTION: 
# ==============================================================================

#
# GROUP 01 : Primitives

# shell_cli_flag_normalize_string normalize 'string' value.
#
# Removes all control characters except \n, \r, and \t.
#
# Arguments:
# - value: raw value.
# - trim: use '1' to normalize string with 'trim' removing all empty spaces
#   before and after the first and last visible chars including boundery
#   \n, \r, and \t.
# - fullClean: use '1' to remove all control chars including \n, \r, and \t.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string() {
  local value="$1"
  local trim="$2"
  local fullClean="$3"
  
  local clean_text=$(printf "%s" "$value" | tr -d '\000-\010\013\014\016-\037\177')
  # Removed chars
  # \000-\010 - 0 -> 8    (NUL; SOH; STX; ETX; EOT; ENQ; ACK; BEL)
  # \013\014  - 11 and 12 (VT; FF)
  # \016-\037 - 14 -> 31  (SO; SI; DLE; DC1; DC2; DC3; DC4; NAK; SYN; ETB; CAN; EM; SUB; ESC; FS; GS; RS; US)
  # \177      - 127       (DEL)
  # 
  # Preserved chars:
  # \011      - 9         (HT) [ \t HORIZONTAL TABULATION ]
  # \012      - 10        (LF) [ \n LINE FEED ]
  # \015      - 13        (CR) [ \r CARRIAGE RETURN ]
  if [ "$trim" = "1" ]; then
    clean_text="${clean_text#"${clean_text%%[![:space:]]*}"}" # trim L
    clean_text="${clean_text%"${clean_text##*[![:space:]]}"}" # trim R
  fi


  if [ "$fullClean" = "1" ]; then
    clean_text=$(printf "%s" "$clean_text" | tr -d '\011\012\015')
    # Removed chars
    # \011      - 9         (HT) [ \t HORIZONTAL TABULATION ]
    # \012      - 10        (LF) [ \n LINE FEED ]
    # \015      - 13        (CR) [ \r CARRIAGE RETURN ]
  fi

  echo "${clean_text}"
}

# shell_cli_flag_normalize_string_full normalize 'string' removind ALL
# control characters (including \n, \r and \t).
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string_full() {
  local value=$(shell_cli_flag_normalize_string "${1}" "1" "1")
  echo "$value"
}

# shell_cli_flag_normalize_string_trim normalize 'string' removind ALL
# control characters (except \n, \r and \t) and trim it.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string_trim() {
  local value=$(shell_cli_flag_normalize_string "${1}" "1" "0")
  echo "$value"
}

# shell_cli_flag_normalize_bool normalize 'bool' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs:
#   "1" for true/1 
#   "0" for false/0
#   or the original string otherwise.
shell_cli_flag_normalize_bool() {
  local value=$(shell_cli_flag_normalize_string_full "${1,,}")

  case "$value" in
    0|false) value="0"  ;;
    1|true)  value="1"  ;;
    *)       value="$1" ;;
  esac

  echo "$value"
}

# shell_cli_flag_normalize_int normalize 'int' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_int() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_float normalize 'float' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_float() {
  shell_cli_flag_normalize_string_full "${1}"
}





#
# GROUP 02 : Date and Time

# shell_cli_flag_normalize_time normalize 'time' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   time in HH:MM:SS format
#   or the original string otherwise.
shell_cli_flag_normalize_time() {
  local value=$(shell_cli_flag_normalize_string_trim "${1}")

  case "${#value}" in
    2) value="${value}:00:00" ;; # HH     -> HH:00:00
    5) value="${value}:00"    ;; # HH:MM  -> HH:MM:00
    8) value="$value"         ;; # Fully formed
    *) value="$1"             ;;
  esac

  echo "$value"
}

# shell_cli_flag_normalize_date normalize 'date' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   date in YYYY-MM-DD format
#   or the original string otherwise.
shell_cli_flag_normalize_date() {
  local value=$(shell_cli_flag_normalize_string_full "${1}")

  case "${#value}" in
    4)  value="${value}-01-01"  ;; # YYYY     -> YYYY-01-01
    7)  value="${value}-01"     ;; # YYYY-MM  -> YYYY-MM-01
    10) value="$value"          ;; # Fully formed
    *)  value="$1"              ;;
  esac

  echo "$value"
}

# shell_cli_flag_normalize_datetime normalize 'datetime' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   date in YYYY-MM-DD HH:MM:SS format
#   or the original string otherwise.
shell_cli_flag_normalize_datetime() {
  local value=$(shell_cli_flag_normalize_string_full "${1}")
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

  local clean_date=$(shell_cli_flag_normalize_date "$date_part")
  local clean_time=$(shell_cli_flag_normalize_time "$time_part")

  echo "${clean_date} ${clean_time}"
}




#
# GROUP 03 : Structured

# shell_cli_flag_normalize_email normalize 'email' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_email() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_enum normalize 'enum' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_enum() {
  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$1"; then
    return "1"
  fi
  echo "${SHELL_CLI_PARSE_JSON_TO_ASSOC_STRING}"
}

# shell_cli_flag_normalize_json normalize 'json' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_json() {
  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$1"; then
    return "1"
  fi
  echo "${SHELL_CLI_PARSE_JSON_TO_ASSOC_STRING}"
}

# shell_cli_flag_normalize_function normalize 'function' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_function() {
  shell_cli_flag_normalize_string_full "${1}"
}





#
# GROUP 04 : System Paths and URLs

# shell_cli_flag_normalize_path normalize 'path' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_path() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_relativepath normalize 'relativepath' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_relativepath() {
  shell_cli_flag_normalize_string_full "${1}"
}



# shell_cli_flag_normalize_filename normalize 'filename' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_filename() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_filepath normalize 'filepath' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_filepath() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_dirname normalize 'dirname' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_dirname() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_dirpath normalize 'dirpath' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_dirpath() {
  shell_cli_flag_normalize_string_full "${1}"
}



# shell_cli_flag_normalize_url normalize 'url' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_url() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_fullurl normalize 'fullurl' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_fullurl() {
  shell_cli_flag_normalize_string_full "${1}"
}

# shell_cli_flag_normalize_relativeurl normalize 'relativeurl' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_flag_normalize_relativeurl() {
  shell_cli_flag_normalize_string_full "${1}"
}
