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






# ----  ---- -------- ----  ---- -------- ----  ----
# NORMALIZE ASSOC ( JSON object string )
# ----  ---- -------- ----  ---- -------- ----  ----

# Normalized JSON string reconstructed from the object/string originally 
# provided.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_STRING=""

# Name of the object originally provided if it is already an associative 
# array.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME=""

# Values ​​obtained from the extraction performed on the object/string 
# originally provided.
declare -gA SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC=()

# Holds the order of discovered keys.
# Note: This order is fully reliable only when parsing from a JSON string.
#       When input is an existing associative array, Bash does not preserve
#       insertion order, so this information is lost.
declare -ga SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER=()

# Normalization error message.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ERR_MESSAGE=""



# shell_cli_type_normalize_main_assoc normalize 'assoc' value.
#
# Arguments:
# - value: a string containing the name of an associative array, or a JSON 
#          object string representing the same.
#
# Returns:
# - 0: if success
#      The temporary objects below will be populated with the values ​
#      ​obtained from the execution of 'shell_cli_parse_sjson_to_assoc'.
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_STRING
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ERR_MESSAGE
#
# - 1: if fail
shell_cli_type_normalize_main_assoc() {
  shell_cli_parse_sjson_to_assoc "$1"
  local parseStatus="$?"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_STRING="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING}"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC=()

  local k=""
  local v=""
  local i=""
  for i in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[@]}"; do
    k="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[$i]}"
    v="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[$k]}"

    SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC["$k"]="$v"
    SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER+=("$k")
  done

  SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ERR_MESSAGE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE}"
  return "$parseStatus"
}

# shell_cli_type_normalize_main_assoc_types general-purpose normalization 
# function for any type that uses an associative array as value.
#
# Arguments:
# - value: a string containing the name of an associative array, or a JSON 
#          object string representing the same.
#
# Returns:
# - The normalized value is always the name of a temporary associative 
#   array whose values ​​must be relocated as soon as possible, as they 
#   will be reset upon the next call to this function.
#
#   If a serialized JSON string is passed and considered invalid, it 
#   will be returned exactly as received.
shell_cli_type_normalize_main_assoc_types() {
  local strReturn="$1"

  local strNormalizated=$(shell_cli_type_normalize_main "$strReturn" "1" "0" "1")
  if shell_cli_type_normalize_main_assoc "$strNormalizated"; then
    #
    # Uses the name of the temporary object containing the obtained values.
    strReturn="SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC"

    #
    # If the originally passed value was a valid object, it returns it.
    if [ "$SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME" != "" ]; then
      strReturn="$SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME"
    fi
  fi

  echo "$strReturn"
}



# Temporarily stores the selected 'key' value identified by 
# validation 'shell_cli_type_validate_main_assoc_types'.
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY=""

# Temporarily stores the selected 'value' value identified by 
# validation 'shell_cli_type_validate_main_assoc_types'.
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE=""

# shell_cli_type_validate_main_assoc_types general validation function 
# for any type that uses an associative array as value.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: name of the associative array containing the acceptable values.
#
# Returns:
# - 0: if the value is a valid representative of this type
#      the given value must match with any 'key' or 'value' in the
#      assoc array map.
#      The values ​​corresponding to the selected 'key' and 'value' will 
#      be stored in the variables:
#      - SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY
#      - SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE
#
# - 1: if the value is not a valid representative of this type.
# - 2: if 'aux' is not an assoc.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_main_assoc_types() {
  local value="$1"
  local aux="$2"
  SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY=""
  SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE=""

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_normalize_main "$value" "1" "0" "1"; then
    return 10
  fi

  # Ensures that an association exists to execute this test.
  if ! shell_cli_utils_array_is_assoc "$aux"; then
    return 2
  fi

  # Check if the input exists as a value or key
  local k=""
  local v=""
  local -n tmpAssoc="$aux"
  for k in "${!tmpAssoc[@]}"; do
    v="${tmpAssoc[$k]}"
    if [ "$value" = "$k" ] || [ "$value" = "$v" ]; then
      SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY="$k"
      SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE="$v"
      return 0
    fi
  done

  return 1
}






# ----  ---- -------- ----  ---- -------- ----  ----
# NORMALIZE AARRAYSSOC ( JSON array string )
# ----  ---- -------- ----  ---- -------- ----  ----

# Normalized JSON array string reconstructed from the object/string originally 
# provided.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_STRING=""

# Name of the object originally provided if it is already an indexed 
# array.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_NAME=""

# Values ​​obtained from the extraction performed on the object/string 
# originally provided.
declare -ga SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY=()

# Normalization error message.
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_ERR_MESSAGE=""



# shell_cli_type_normalize_main_array normalize 'array' value.
#
# Arguments:
# - value: a string containing the name of an indexed array, or a JSON 
#          array string representing the same.
#
# Returns:
# - 0: if success
#      The temporary objects below will be populated with the values ​
#      ​obtained from the execution of 'shell_cli_parse_sarray_to_array'.
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_STRING
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_NAME
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY
#      - SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_ERR_MESSAGE
#
# - 1: if fail
shell_cli_type_normalize_main_array() {
  shell_cli_parse_sarray_to_array "$1"
  local parseStatus="$?"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_STRING="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING}"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_NAME="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}"
  SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY=()

  local v=""
  local i=""
  for i in "${!SHELL_CLI_PARSE_SARRAY_TO_ARRAY[@]}"; do
    v="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[$i]}"

    SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY+=("$k")
  done

  SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_ERR_MESSAGE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE}"
  return "$parseStatus"
}

# shell_cli_type_normalize_main_array_types general-purpose normalization 
# function for any type that uses an indexed array as value.
#
# Arguments:
# - value: a string containing the name of an indexed array, or a JSON 
#          array string representing the same.
#
# Returns:
# - The normalized value is always the name of a temporary indexed 
#   array whose values ​​must be relocated as soon as possible, as they 
#   will be reset upon the next call to this function.
#
#   If a serialized JSON string is passed and considered invalid, it 
#   will be returned exactly as received.
shell_cli_type_normalize_main_array_types() {
  local strReturn="$1"

  local strNormalizated=$(shell_cli_type_normalize_main "$strReturn" "1" "0" "1")
  if shell_cli_type_normalize_main_array "$strNormalizated"; then
    #
    # Uses the name of the temporary object containing the obtained values.
    strReturn="SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY"

    #
    # If the originally passed value was a valid object, it returns it.
    if [ "$SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME" != "" ]; then
      strReturn="$SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME"
    fi
  fi

  echo "$strReturn"
}



# Temporarily stores the selected 'index' value identified by 
# validation 'shell_cli_type_validate_main_array_types'.
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX=""

# Temporarily stores the selected 'value' value identified by 
# validation 'shell_cli_type_validate_main_array_types'.
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE=""

# shell_cli_type_validate_main_array_types general validation function 
# for any type that uses an indexed array as value.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: name of the indexed array containing the acceptable values.
#
# Returns:
# - 0: if the value is a valid representative of this type
#      the given value must match with any 'index' or 'value' in the
#      indexed array map.
#      The values ​​corresponding to the selected 'index' and 'value' will 
#      be stored in the variables:
#      - SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX
#      - SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE
#
# - 1: if the value is not a valid representative of this type.
# - 2: if 'aux' is not an assoc.
# - 10: if the value contains any invalid control characters.
shell_cli_type_validate_main_array_types() {
  local value="$1"
  local aux="$2"
  SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX=""
  SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE=""

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_normalize_main "$value" "1" "0" "1"; then
    return 10
  fi

  # Ensures that an association exists to execute this test.
  if ! shell_cli_utils_array_is_indexed "$aux"; then
    return 2
  fi

  # Check if the input exists as a value or key
  local i=""
  local v=""
  local -n tmpAssoc="$aux"
  for i in "${!tmpAssoc[@]}"; do
    v="${tmpAssoc[$i]}"
    if [ "$value" = "$i" ] || [ "$value" = "$v" ]; then
      SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX="$i"
      SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE="$v"
      return 0
    fi
  done

  return 1
}

