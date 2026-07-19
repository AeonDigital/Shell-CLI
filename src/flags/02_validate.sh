#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/02_validate.sh
# DESCRIPTION: 
# ==============================================================================

#
# GROUP 01 : Primitives

# shell_cli_flag_validate_string validate 'string'.
#
# Arguments:
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_string() {
  local value="$1"
  local aux="$2"

  # Assert if any remaining invisible control character block is present
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    return 2
  fi

  return 0
}

# shell_cli_flag_validate_bool validate 'bool'.
#
# Arguments:
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_bool() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
  fi

  if [ "$value" != "1" ] && [ "$value" != "0" ]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_int validate 'int'.
#
# Arguments:
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_int() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
  fi

  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_float validate 'float'.
#
# Arguments:
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_float() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
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
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_time() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
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
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_date() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
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
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_datetime() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
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
#   - value: normalizated value.
#   - aux: optional auxiliary configuration.
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_email() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
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
#   - value: normalizated value.
#   - aux: assoc name with enum values (match with keys or values).
#
# Returns:
#   - 0: if the value is a valid representative of this type
#   - 1: if the value is not a valid representative of this type.
#   - 2: if the value contains any control characters.
shell_cli_flag_validate_enum() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 2
  fi

  local str_declare=$(declare -p "$aux" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
    return 1
  fi

  # Check if the input exists as a value or an aliased group literal string
  local -n enum_assoc="$aux"
  local match="0"
  local key=""
  local val=""
  for key in "${!enum_assoc[@]}"; do
    val="${enum_assoc[$key]}"
    if [ "$value" == "$key" ] || [ "$value" == "$val" ]; then
      return 0
    fi
  done

  return 1
}



# shell_cli_flag_validate_function validates that the supplied value is the name of
# an existing shell function.
#
# Arguments:
#   - value: The candidate function name.
#   - aux: Unused auxiliary argument.
#
# Returns:
#   - 0: If the target function exists.
#   - 1: If the target function does not exist.
shell_cli_flag_validate_function() {
  local value="$1"
  local aux="$2"

  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  if declare -f "$value" >/dev/null; then
    return 0
  fi

  return 1
}



# shell_cli_flag_validate_array validates pure JSON arrays at the root level.
#
# Arguments:
#   - value: The raw input string payload to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string is a valid top-level JSON array.
#   - 1: If syntax boundaries or states are violated.
shell_cli_flag_validate_array() {
  local value="$1"
  local aux="$2"
  local clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # Enforce root array boundaries
  if [[ ! "$clean_value" =~ ^\[.*\]$ ]]; then
    return 1
  fi

  if [ "$clean_value" = "[]" ]; then
    SHELL_CLI_VALIDATED_VALUE="[]"
    return 0
  fi

  local payload="${clean_value#?}"
  payload="${payload%?}"

  # States: 0=expect_value, 1=expect_comma_or_end
  local state=0
  local in_quotes=0
  local current_token=""
  local normalized_json="["
  local len=${#payload}
  local idx=0

  while [ "$idx" -lt "$len" ]; do
    local char="${payload:$idx:1}"

    if [ "$in_quotes" -eq 1 ]; then
      if [ "$char" = "\\" ]; then
        current_token+="${char}${payload:$((idx + 1)):1}"
        idx=$((idx + 2))
        continue
      fi
      if [ "$char" = '"' ]; then
        in_quotes=0
        if [ "$state" -eq 0 ]; then
          normalized_json+="\"${current_token}\""
          state=1
        else
          return 1
        fi
        current_token=""
      else
        current_token+="$char"
      fi
    else
      if [[ "$char" =~ [[:space:]] ]]; then
        idx=$((idx + 1))
        continue
      fi

      case "$char" in
        '"')
          in_quotes=1
          if [ "$state" -ne 0 ]; then return 1; fi
          ;;
        ',')
          if [ "$state" -ne 1 ]; then return 1; fi
          normalized_json+=","
          state=0
          ;;
        *)
          if [ "$state" -eq 0 ]; then
            current_token+="$char"
            local next_idx=$((idx + 1))
            local next_char="${payload:$next_idx:1}"
            if [[ "$next_char" =~ [,:[:space:]] ]] || [ "$next_idx" -eq "$len" ]; then
              if [[ "$current_token" =~ ^[0-9]+([.][0-9]+)?$ ]] || \
                 [ "$current_token" = "true" ] || \
                 [ "$current_token" = "false" ] || \
                 [ "$current_token" = "null" ]; then
                normalized_json+="$current_token"
                current_token=""
                state=1
              else
                return 1
              fi
            fi
          else
            return 1
          fi
          ;;
      esac
    fi
    idx=$((idx + 1))
  done

  if [ "$in_quotes" -ne 0 ] || [ "$state" -ne 1 ]; then
    return 1
  fi

  normalized_json+="]"
  SHELL_CLI_VALIDATED_VALUE="$normalized_json"
  return 0
}

# shell_cli_flag_validate_json validates root JSON objects, allowing nested structures as values.
#
# Arguments:
#   - value: The raw input string payload to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string matches a baseline valid flat JSON object sequence.
#   - 1: If the input layout violates syntax state routing or token boundaries.
shell_cli_flag_validate_json() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # Perform native extreme trim removing leading and trailing space characters
  local clean_value
  clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # 1. Enforce physical outer structural boundaries verification
  if [[ ! "$clean_value" =~ ^\{.*\}$ ]]; then
    return 1
  fi

  # Support trivial minimal representation states immediately
  if [ "$clean_value" = "{}" ] ; then
    SHELL_CLI_VALIDATED_VALUE="{}"
    return 0
  fi

  # State routing flags: 
  # state: 0=expect_key, 1=expect_colon, 2=expect_value, 3=expect_comma_or_end
  local state=0
  local in_quotes=0
  local current_token=""
  local normalized_json="{"
  
  # Strip the outermost wrapping brackets to isolate the core stream content
  local payload="${clean_value#?}"
  payload="${payload%%?}"

  local len=${#payload}
  local idx=0

  # 2. Execute deep character-by-character validation loop pipeline
  while [ "$idx" -lt "$len" ]; do
    local char="${payload:$idx:1}"
    
    if [ "$in_quotes" -eq 1 ]; then
      # Handle escaping character masks lookahead safely
      if [ "$char" = "\\" ]; then
        current_token+="${char}${payload:$((idx + 1)):1}"
        idx=$((idx + 2))
        continue
      fi

      if [ "$char" = '"' ]; then
        in_quotes=0
        if [ "$state" -eq 0 ]; then
          # Removed the strict regex constraint to accept spaces/special chars in keys
          normalized_json+="\"${current_token}\""
          state=1
        elif [ "$state" -eq 2 ]; then
          normalized_json+="\"${current_token}\""
          state=3
        fi
        current_token=""
      else
        current_token+="$char"
      fi
    else
      # Outside quotes: ignore whitespace components entirely
      if [[ "$char" =~ [[:space:]] ]]; then
        idx=$((idx + 1))
        continue
      fi

      case "$char" in
        '"')
          in_quotes=1
          if [ "$state" -ne 0 ] && [ "$state" -ne 2 ]; then return 1; fi
          ;;
        ':')
          if [ "$state" -ne 1 ]; then return 1; fi
          normalized_json+=":"
          state=2 
          ;;
        ',')
          if [ "$state" -ne 3 ]; then return 1; fi
          normalized_json+=","
          state=0 
          ;;
        '{'|'[')
          # Sub-structure routing: Triggered when an object or array is found as a value
          if [ "$state" -ne 2 ]; then return 1; fi
          
          # Dynamic lookahead to capture everything until the matching closing bracket
          local target_close="}"
          if [ "$char" = "[" ]; then target_close="]"; fi
          
          local sub_structure="$char"
          local depth=1
          idx=$((idx + 1))
          
          while [ "$idx" -lt "$len" ] && [ "$depth" -gt 0 ]; do
            local sub_char="${payload:$idx:1}"
            sub_structure+="$sub_char"
            if [ "$sub_char" = "$char" ]; then
              depth=$((depth + 1))
            elif [ "$sub_char" = "$target_close" ]; then
              depth=$((depth - 1))
            fi
            idx=$((idx + 1))
          done
          
          if [ "$depth" -ne 0 ]; then return 1; fi # Unmatched nested block
          
          normalized_json+="$sub_structure"
          state=3
          idx=$((idx - 1)) # Balance main loop increment
          ;;
        *)
          if [ "$state" -eq 2 ]; then
            current_token+="$char"
            local next_idx=$((idx + 1))
            local next_char="${payload:$next_idx:1}"
            if [[ "$next_char" =~ [,:[:space:]] ]] || [ "$next_idx" -eq "$len" ]; then
              if [[ "$current_token" =~ ^[0-9]+([.][0-9]+)?$ ]] || \
                 [ "$current_token" = "true" ] || \
                 [ "$current_token" = "false" ] || \
                 [ "$current_token" = "null" ]; then
                normalized_json+="$current_token"
                current_token=""
                state=3
              else
                return 1
              fi
            fi
          else
            return 1
          fi
          ;;
      esac
    fi
    idx=$((idx + 1))
  done

  if [ "$in_quotes" -ne 0 ] || [ "$state" -ne 3 ]; then
    return 1
  fi

  normalized_json+="}"
  SHELL_CLI_VALIDATED_VALUE="$normalized_json"
  return 0
}





# shell_cli_flag_validate_path asserts structural path character conformity.
#
# Arguments:
#   - value: The raw input string path sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string contains only legal directory and separator characters.
#   - 1: If illegal control characters, wildcards, or null bytes are detected.
shell_cli_flag_validate_path() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes (") and pipe (|)
  if [[ "$value" =~ [\*\?\"\<\>\|] ]]; then
    return 1
  fi

  # 2. Rejects strict control characters (ASCII 0-31 and 127) across ANY language/locale
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_relativepath verifies strict non-root directory masks.
#
# Arguments:
#   - value: The raw input string path sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string conforms to a path and does not initialize as root.
#   - 1: If path triggers absolute roots (/ or C:\) or contains illegal signs.
shell_cli_flag_validate_relativepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
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





# shell_cli_flag_validate_filename asserts safe naming schemas for individual files.
#
# Arguments:
#   - value: The raw input filename token string to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string is a valid file token without folder path dividers.
#   - 1: If slash dividers, paths tokens, or forbidden characters are present.
shell_cli_flag_validate_filename() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # File names cannot possess directory trailing slash or path separator tokens
  if [[ "$value" == *\/* ]] || [[ "$value" == *\\* ]] || [ -z "$value" ]; then
    return 1
  fi

  # 1. Rejects wildcards (?, *), html boundaries (<, >), quotes ("), pipe (|) and Windows colon (:)
  if [[ "$value" =~ [\*\?\"\<\>\|:] ]]; then
    return 1
  fi

  # 2. Rejects strict control characters (ASCII 0-31 and 127) across ANY language/locale
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_filepath asserts character compliance for files sequences.
#
# Arguments:
#   - value: The raw input filepath string sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string contains a legal folder and filename sequence structure.
#   - 1: If file endings are blank or contain system illegal layout markers.
shell_cli_flag_validate_filepath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
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

# shell_cli_flag_validate_dirname asserts safe naming schemas for single directories.
#
# Arguments:
#   - value: The raw input directory token string to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string is a valid standalone directory name token string.
#   - 1: If path slashes delimiters or system illegal markers are present.
shell_cli_flag_validate_dirname() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # Reuses individual filename structural constraints as rules match exactly
  if ! shell_cli_flag_validate_filename "$value"; then
    return 1
  fi

  return 0
}

# shell_cli_flag_validate_dirpath asserts character compliance for folders trees.
#
# Arguments:
#   - value: The raw input directory path string to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the string maps to a well-formed directory path layout model.
#   - 1: If character boundaries or structural mask formatting fail check.
shell_cli_flag_validate_dirpath() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi

  return 0
}





# shell_cli_flag_validate_url checks flexible protocol or relative web address formatting.
#
# Arguments:
#   - value: The raw input web address string sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the payload qualifies as either a valid absolute or relative URL.
#   - 1: If spaces or severe syntax corruption break standard address masks.
shell_cli_flag_validate_url() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  if shell_cli_flag_validate_fullurl "$value" || shell_cli_flag_validate_relativeurl "$value"; then
    return 0
  fi

  return 1
}

# shell_cli_flag_validate_fullurl asserts absolute corporate internet mask constraints.
#
# Arguments:
#   - value: The raw absolute URL address string sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If schema protocol, domain boundaries, and paths layout match criteria.
#   - 1: If protocol configurations are absent or character structures fail.
shell_cli_flag_validate_fullurl() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi

  # Enforces explicit schema protocol definitions followed by hostname validation
  local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
  if [[ "$value" =~ $url_regex ]]; then
    return 0
  fi

  return 1
}

# shell_cli_flag_validate_relativeurl asserts local web path context routing masks.
#
# Arguments:
#   - value: The raw localized endpoint URI string sequence to be evaluated.
#   - aux: Optional auxiliary validation constraints configuration.
#
# Returns:
#   - 0: If the sequence establishes a clean relative path interface signature.
#   - 1: If schemas protocols are embedded or white spaces are intercepted.
shell_cli_flag_validate_relativeurl() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
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
