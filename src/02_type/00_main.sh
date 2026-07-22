#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/00_main.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_main normalize.
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
shell_cli_type_normalize_main() {
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





# shell_cli_type_validate_main validate.
#
# Arguments:
# - value: non empty normalizated value.
# - invalidateCodeCtrlChars: invalidate any string contains any control 
#   characters (except \n, \t and \r).
# - invalidateTextCtrlChars: invalidate any string contains any text control 
#   characters like \n, \r, and \t.
#
# Returns:
# - 0: if success
# - 1: if fail.
# - 10: if has invalid control characters.
shell_cli_type_validate_main() {
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