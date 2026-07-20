#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/03_validate_types.sh
# DESCRIPTION: 
# ==============================================================================

#
# GROUP 01 : Primitives

# shell_cli_flag_validate_string validate 'string'.
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
shell_cli_flag_validate_string() {
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

# shell_cli_flag_validate_bool validate 'bool'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_bool() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if [ "$value" != "1" ] && [ "$value" != "0" ]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_int validate 'int'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_int() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_float validate 'float'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_float() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if [[ ! "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    return 1
  fi

  return 0
}





#
# GROUP 02 : Date and Time

# shell_cli_flag_validate_time validate 'time' (HH:MM:SS).
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_time() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
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

# shell_cli_flag_validate_date validate 'date' (YYYY-MM-DD).
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_date() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
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

# shell_cli_flag_validate_datetime validate 'datetime' (YYYY-MM-DD HH:MM:SS).
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_datetime() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
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




#
# GROUP 03 : Structured

# shell_cli_flag_validate_email validate 'email'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_email() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  local email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
  if [[ ! "$value" =~ $email_regex ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_enum validate 'enum'.
#
# Arguments:
# - value: normalizated value.
# - aux: associative array name or JSON string.
#
# Returns:
# - 0: if the value is a valid representative of this type
#      the given value must match with any 'key' or 'value' in the
#      assoc array map.
# - 1: if the value is not a valid representative of this type.
# - 2: if the aux is not a valid assoc array or stringified JSON object.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_enum() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "1"; then
    return 10
  fi

  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$aux"; then
    return "2"
  fi

  # Check if the input exists as a value or an aliased group literal string
  local key=""
  local val=""
  for key in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC[@]}"; do
    val="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[$key]}"
    if [ "$value" = "$key" ] || [ "$value" = "$val" ]; then
      return 0
    fi
  done

  return 1
}

# shell_cli_flag_validate_json validate 'json'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_json() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "1"; then
    return 10
  fi

  # In this case, normalization is identical to validation.
  if ! shell_cli_parse_sjson_to_assoc "$value"; then
    return "2"
  fi

  return 0
}

# shell_cli_flag_validate_function validate 'function'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_function() {
  local value="$1"
  local aux="$2"

  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if declare -f "$value" >/dev/null; then
    return 0
  fi

  return 1
}





#
# GROUP 04 : System Paths and URLs

# shell_cli_flag_validate_path validate 'path'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_path() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes (") and pipe (|)
  if [[ "$value" =~ [\*\?\"\<\>\|] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_relativepath validate 'relativepath'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_relativepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # Leverage core validation rules for general character checking first
  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi

  # Reject absolute Unix roots or Windows drive letters prefix structures
  if [[ "$value" =~ ^\/ ]] || [[ "$value" =~ ^[A-Za-z]:\\ ]] || [[ "$value" =~ ^[A-Za-z]:\/ ]]; then
    return 1
  fi

  return 0
}



# shell_cli_flag_validate_filename validate 'filename'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_filename() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # File names cannot possess directory trailing slash or path separator tokens
  if [[ "$value" == *\/* ]] || [[ "$value" == *\\* ]] || [ -z "$value" ]; then
    return 1
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes ("), pipe (|) and Windows colon (:)
  if [[ "$value" =~ [\*\?\"\<\>\|:] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_filepath validate 'filepath'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_filepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi

  # Rejects strings terminating with a path divider trailing slash character
  if [[ "$value" =~ \/$ ]] || [[ "$value" =~ \\$ ]] || [ -z "$value" ]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_dirname validate 'dirname'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_dirname() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # Reuses individual filename structural constraints as rules match exactly
  if ! shell_cli_flag_validate_filename "$value"; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_dirpath validate 'dirpath'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_dirpath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi

  return 0
}



# shell_cli_flag_validate_url validate 'url'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_url() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  if shell_cli_flag_validate_fullurl "$value" || shell_cli_flag_validate_relativeurl "$value"; then
    return 0
  fi

  return 1
}

# shell_cli_flag_validate_fullurl validate 'fullurl'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_fullurl() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # Enforces explicit schema protocol definitions followed by hostname validation
  local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
  if [[ "$value" =~ $url_regex ]]; then
    return 0
  fi

  return 1
}

# shell_cli_flag_validate_relativeurl validate 'relativeurl'.
#
# Arguments:
# - value: normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_flag_validate_relativeurl() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value"; then
    return 10
  fi

  # Relative URLs must omit network protocol configurations and initialize with a forward slash
  if [[ "$value" =~ ^https?:\/\/ ]] || [[ "$value" =~ ^ftp:\/\/ ]]; then
    return 1
  fi

  if [[ "$value" =~ ^\/[A-Za-z0-9._%+-]*(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$ ]]; then
    return 0
  fi

  return 1
}
