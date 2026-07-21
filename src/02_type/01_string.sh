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
# - trim: use '1' to normalize string with 'trim' removing all empty spaces
#   before and after the first and last visible chars including boundery
#   \n, \r, and \t.
# - fullClean: use '1' to remove all control chars including \n, \r, and \t.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_type_normalize_string() {
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

# shell_cli_type_normalize_string_full normalize 'string' removind ALL
# control characters (including \n, \r and \t).
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_type_normalize_string_full() {
  local value=$(shell_cli_type_normalize_string "${1}" "1" "1")
  echo "$value"
}

# shell_cli_type_normalize_string_trim normalize 'string' removind ALL
# control characters (except \n, \r and \t) and trim it.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   text contains only printable characters and safe whitespace.
shell_cli_type_normalize_string_trim() {
  local value=$(shell_cli_type_normalize_string "${1}" "1" "0")
  echo "$value"
}



# shell_cli_type_validate_string validate 'string'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#   * default (empty or not "1"): reject any control character.
#   * "1": allow only \t, \n, and \r.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_string() {
  local value="$1"
  local aux="$2"

  if [ "$aux" = "1" ]; then
    # Invalid control chars
    # \000-\010 - 0 -> 8    (NUL; SOH; STX; ETX; EOT; ENQ; ACK; BEL)
    # \013\014  - 11 and 12 (VT; FF)
    # \016-\037 - 14 -> 31  (SO; SI; DLE; DC1; DC2; DC3; DC4; NAK; SYN; ETB; CAN; EM; SUB; ESC; FS; GS; RS; US)
    # \177      - 127       (DEL)
    # 
    # Accepted control chars:
    # \011      - 9         (HT) [ \t HORIZONTAL TABULATION ]
    # \012      - 10        (LF) [ \n LINE FEED ]
    # \015      - 13        (CR) [ \r CARRIAGE RETURN ]
    if [[ "$value" =~ [$'\000'-$'\010'$'\013'$'\014'$'\016'-$'\037'$'\177'] ]]; then
      return 10
    fi
  else
    # Strict mode: disallow all control characters
    if [[ "$value" =~ [[:cntrl:]] ]]; then
      return 10
    fi
  fi

  return 0
}
