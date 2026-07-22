#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/01_string.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_string normalize 'string' value.
#
# Removes all control characters except \n, \r, and \t.
#
# Arguments:
# - value: raw value.
# - removeCodeCtrlChars: use '1' to remove all control characters 
#   except '\n', '\t' and '\r'.
# - removeTextCtrlChars: use '1' to remove all text control 
#   characters like \n, \r, and \t.
# - trim: use '1' to performa a string 'trim' removing all empty spaces
#   before and after the first and last visible chars including boundery
#   \n, \r, and \t.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_type_normalize_string() {
  local value="$1"
  local removeCodeCtrlChars="$2"
  local removeTextCtrlChars="$3"
  local trim="$4"


  if [ "$removeCodeCtrlChars" = "1" ]; then
    # control chars
    # \000-\010 - 0 -> 8    (NUL; SOH; STX; ETX; EOT; ENQ; ACK; BEL)
    # \013\014  - 11 and 12 (VT; FF)
    # \016-\037 - 14 -> 31  (SO; SI; DLE; DC1; DC2; DC3; DC4; NAK; SYN; ETB; CAN; EM; SUB; ESC; FS; GS; RS; US)
    # \177      - 127       (DEL)
    local code_ctrl_chars=""
    code_ctrl_chars+=$'\000'$'\001'$'\002'$'\003'$'\004'$'\005'$'\006'$'\007'$'\010'
    code_ctrl_chars+=$'\013'$'\014'$'\016'$'\017'$'\020'$'\021'$'\022'$'\023'$'\024'
    code_ctrl_chars+=$'\025'$'\026'$'\027'$'\030'$'\031'$'\032'$'\033'$'\034'$'\035'
    code_ctrl_chars+=$'\036'$'\037'$'\177'

    local clean_text=$(printf "%s" "$value" | tr -d "$code_ctrl_chars")
  fi

  if [ "$removeTextCtrlChars" = "1" ]; then
    # text control chars:
    # \011      - 9         (HT) [ \t HORIZONTAL TABULATION ]
    # \012      - 10        (LF) [ \n LINE FEED ]
    # \015      - 13        (CR) [ \r CARRIAGE RETURN ]
    local text_ctrl_chars=$'\011'$'\012'$'\015'

    clean_text=$(printf "%s" "$clean_text" | tr -d "$text_ctrl_chars")
  fi

  if [ "$trim" = "1" ]; then
    clean_text="${clean_text#"${clean_text%%[![:space:]]*}"}" # trim L
    clean_text="${clean_text%"${clean_text##*[![:space:]]}"}" # trim R
  fi

  echo "${clean_text}"
}



# shell_cli_type_normalize_string_code_text_trim normalize 'string' with:
# - remove ALL control characters (except \n, \r, and \t)
# - remove text control characters (\n, \r, and \t)
# - performa a trim
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_string_code_text_trim() {
  local value=$(shell_cli_type_normalize_string "${1}" "1" "1" "1")
  echo "$value"
}

# shell_cli_type_normalize_string_code_text normalize 'string' with:
# - remove ALL control characters (except \n, \r, and \t)
# - remove text control characters (\n, \r, and \t)
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_string_code_text() {
  local value=$(shell_cli_type_normalize_string "${1}" "1" "1" "0")
  echo "$value"
}

# shell_cli_type_normalize_string_code_trim normalize 'string' with:
# - remove ALL control characters (except \n, \r, and \t)
# - performa a trim
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_string_code_trim() {
  local value=$(shell_cli_type_normalize_string "${1}" "1" "0" "1")
  echo "$value"
}

# shell_cli_type_normalize_string_trim normalize 'string' with:
# - performa a trim
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
shell_cli_type_normalize_string_trim() {
  local value=$(shell_cli_type_normalize_string "${1}" "0" "0" "1")
  echo "$value"
}

# shell_cli_type_normalize_string_none non normalize 'string'.
# Use to obtain control chars from the user.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs raw value.
shell_cli_type_normalize_string_none() {
  echo "$1"
}





# shell_cli_type_validate_string validate 'string'.
#
# Arguments:
# - value: non empty normalizated value.
# - invalidateCodeCtrlChars: invalidate any string contains any control 
#   characters (except \n, \t and \r).
# - invalidateTextCtrlChars: invalidate any string contains any text control 
#   characters like \n, \r, and \t.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_string() {
  local value="$1"
  local invalidateCodeCtrlChars="$2"
  local invalidateTextCtrlChars="$3"


  if [ "$invalidateCodeCtrlChars" = "1" ]; then
    # control chars
    # \000-\010 - 0 -> 8    (NUL; SOH; STX; ETX; EOT; ENQ; ACK; BEL)
    # \013\014  - 11 and 12 (VT; FF)
    # \016-\037 - 14 -> 31  (SO; SI; DLE; DC1; DC2; DC3; DC4; NAK; SYN; ETB; CAN; EM; SUB; ESC; FS; GS; RS; US)
    # \177      - 127       (DEL)
    local code_ctrl_chars=""
    code_ctrl_chars+=$'\000'$'\001'$'\002'$'\003'$'\004'$'\005'$'\006'$'\007'$'\010'
    code_ctrl_chars+=$'\013'$'\014'$'\016'$'\017'$'\020'$'\021'$'\022'$'\023'$'\024'
    code_ctrl_chars+=$'\025'$'\026'$'\027'$'\030'$'\031'$'\032'$'\033'$'\034'$'\035'
    code_ctrl_chars+=$'\036'$'\037'$'\177'

    if [[ "$value" =~ [$code_ctrl_chars] ]]; then
      return 10
    fi
  fi

  if [ "$invalidateTextCtrlChars" = "1" ]; then
    # text control chars:
    # \011      - 9         (HT) [ \t HORIZONTAL TABULATION ]
    # \012      - 10        (LF) [ \n LINE FEED ]
    # \015      - 13        (CR) [ \r CARRIAGE RETURN ]
    local text_ctrl_chars=$'\011'$'\012'$'\015'

    if [[ "$value" =~ [$text_ctrl_chars] ]]; then
      return 10
    fi
  fi

  return 0
}

# shell_cli_type_validate_string_code_text validate 'string'.
# - invalidate if found ANY control characters (except \n, \r, and \t)
# - invalidate if found ANY text control characters (\n, \r, and \t)
#
# Arguments:
# - value: non empty normalizated value.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_string_code_text() {
  shell_cli_type_validate_string "${1}" "1" "1"
}

# shell_cli_type_validate_string_code validate 'string'.
# - invalidate if found ANY control characters (except \n, \r, and \t)
#
# Arguments:
# - value: non empty normalizated value.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_string_code_trim() {
  shell_cli_type_validate_string "${1}" "1" "0"
}

# shell_cli_type_validate_string_none validate 'string'.
#
# Arguments:
# - value: non empty normalizated value.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_string_none() {
  return 0
}
