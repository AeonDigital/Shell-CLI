#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/01_normalize.sh
# DESCRIPTION: 
# ==============================================================================

#
# GROUP 01 : Primitives

# shell_cli_flag_normalize_string normalize 'string' value.
#
# Arguments:
#   - value: raw value.
#   - trim: use '1' to normalize string with 'trim'.
#
# Returns:
#   - Outputs normalizated value.
#     text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string() {
  local value="$1"
  local clean_text=$(echo -n "$value" | tr -d '[:space:]')

  if [ "$2" == "1" ]; then
    clean_text="${clean_text#"${clean_text%%[![:space:]]*}"}" # trim L
    clean_text="${clean_text%"${clean_text##*[![:space:]]}"}" # trim R
  fi

  echo "${clean_text}"
}

# shell_cli_flag_normalize_string_trim normalize 'string' value and 'trim' it.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string_trim() {
  local value=$(shell_cli_flag_normalize_string_trim "${1}")
  echo "$value"
}



# shell_cli_flag_normalize_bool normalize 'bool' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs:
#     "1" for true/1 
#     "0" for false/0
#     or the original string otherwise.
shell_cli_flag_normalize_bool() {
  local value=$(shell_cli_flag_normalize_string_trim "${1,,}")

  case "$value" in
    0|false) value="0"  ;;
    1|true)  value="1"  ;;
    *)       value="$1" ;;
  esac

  echo "$value"
}

# shell_cli_flag_normalize_bool normalize 'int' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_int() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'float' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_float() {
  shell_cli_flag_normalize_string_trim "${1}"
}





#
# GROUP 02 : Date and Time

# shell_cli_flag_normalize_time normalize 'time' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     time in HH:MM:SS format
#     or the original string otherwise.
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

# shell_cli_flag_normalize_time normalize 'date' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     date in YYYY-MM-DD format
#     or the original string otherwise.
shell_cli_flag_normalize_date() {
  local value=$(shell_cli_flag_normalize_string_trim "${1}")

  case "${#value}" in
    4)  value="${value}-01-01"  ;; # YYYY     -> YYYY-01-01
    7)  value="${value}-01"     ;; # YYYY-MM  -> YYYY-MM-01
    10) value="$value"          ;; # Fully formed
    *)  value="$1"              ;;
  esac

  echo "$value"
}

# shell_cli_flag_normalize_time normalize 'datetime' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     date in YYYY-MM-DD HH:MM:SS format
#     or the original string otherwise.
shell_cli_flag_normalize_datetime() {
  local value=$(shell_cli_flag_normalize_string_trim "${1}")
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

# shell_cli_flag_normalize_bool normalize 'email' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_email() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'enum' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_enum() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'json' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_json() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'function' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_function() {
  shell_cli_flag_normalize_string_trim "${1}"
}





#
# GROUP 04 : System Paths and URLs

# shell_cli_flag_normalize_bool normalize 'path' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_path() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'relativepath' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_relativepath() {
  shell_cli_flag_normalize_string_trim "${1}"
}



# shell_cli_flag_normalize_bool normalize 'filename' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_filename() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'filepath' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_filepath() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'dirname' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_dirname() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'dirpath' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_dirpath() {
  shell_cli_flag_normalize_string_trim "${1}"
}



# shell_cli_flag_normalize_bool normalize 'url' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_url() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'fullurl' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_fullurl() {
  shell_cli_flag_normalize_string_trim "${1}"
}

# shell_cli_flag_normalize_bool normalize 'relativeurl' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_relativeurl() {
  shell_cli_flag_normalize_string_trim "${1}"
}
















# shell_cli_flag_normalize_array parses string components into a native indexed array.
#
# Arguments:
#   - value: The verified raw array string sequence (e.g., ['val1', 'val2']).
#
# Side Effects:
#   - Resets and populates the global indexed array SHELL_CLI_NORMALIZATED_ARRAY.
shell_cli_flag_normalize_array() {
  local input="$1"
  local inner="${input#?}"
  inner="${inner%?}"

  # Reset global indexed array cleanly
  SHELL_CLI_NORMALIZATED_ARRAY=()
  
  local current=""
  local idx=0
  local len=${#inner}
  local in_q=0

  while [ "$idx" -lt "$len" ]; do
    local char="${inner:$idx:1}"
    if [ "$in_q" -eq 1 ]; then
      if [ "$char" = "'" ] || [ "$char" = '"' ]; then
        in_q=0
        SHELL_CLI_NORMALIZATED_ARRAY+=("$current")
        current=""
      else
        current+="$char"
      fi
    else
      if [ "$char" = "'" ] || [ "$char" = '"' ]; then
        in_q=1
      fi
    fi
    idx=$((idx + 1))
  done
}

# shell_cli_flag_normalize_assoc parses string components into a native associative map.
#
# Arguments:
#   - value: The verified flat JSON object string sequence.
#
# Side Effects:
#   - Resets and populates the global associative map SHELL_CLI_NORMALIZATED_ASSOC.
shell_cli_flag_normalize_assoc() {
  local input="$1"
  local inner="${input#?}"
  inner="${inner%?}"

  # Reset global associative array cleanly
  SHELL_CLI_NORMALIZATED_ASSOC=()
  
  local key=""
  local val=""
  local current=""
  local idx=0
  local len=${#inner}
  local in_q=0
  local capture_state=0 # 0=key, 1=value

  while [ "$idx" -lt "$len" ]; do
    local char="${inner:$idx:1}"
    if [ "$in_q" -eq 1 ]; then
      if [ "$char" = '"' ] || [ "$char" = "'" ]; then
        in_q=0
        if [ "$capture_state" -eq 0 ]; then
          key="$current"
        else
          val="$current"
          SHELL_CLI_NORMALIZATED_ASSOC["$key"]="$val"
          capture_state=0
        fi
        current=""
      else
        current+="$char"
      fi
    else
      case "$char" in
        '"'|"'") in_q=1 ;;
        ':')     capture_state=1 ;;
        ',')     : ;;
      esac
    fi
    idx=$((idx + 1))
  done
}










# shell_cli_flag_rules_normalize_all normalizes and populates uninitialized schema metadata keys.
#
# Arguments:
#   - flag_assoc: The string name of the target associative array.
#
# Returns:
#   - 0: Always terminates with success state after dynamically filling missing keys.
shell_cli_flag_rules_normalize_all() {
  local flag_assoc="$1"
  local -n assoc_ref="$flag_assoc"

  # NORMALIZE: Converts developer "true/false" metadata strings into strict "1/0" engine bytes
  local bool_keys=("required" "array" "assoc")
  for b_key in "${bool_keys[@]}"; do
    local val="${assoc_ref["${b_key}"]}"
    if [ "$val" != "" ]; then
      assoc_ref["$b_key"]=$(shell_cli_flag_normalize_bool "$val")
    fi
  done

  # NORMALIZE: Infers and expands partial dates, times, or datetimes for metadata bounds
  local k_type="${assoc_ref["type"]}"
  if [[ "$k_type" =~ ^(date|time|datetime)$ ]]; then
    local bound_keys=("min" "max")
    
    for bound_key in "${bound_keys[@]}"; do
      local b_val="${assoc_ref["$bound_key"]}"
      if [ "$b_val" != "" ]; then
        assoc_ref["$bound_key"]=$(_shell_cli_flag_normalize_${k_type} "$b_val")
      fi
    done
  fi

  # Iteratively evaluate and apply official system fallbacks using data-driven keys
  for key in "${!CORE_METAFLAG_DEFAULTS[@]}"; do
    if [ -z "${assoc_ref["$key"]}" ]; then
      assoc_ref["$key"]="${CORE_METAFLAG_DEFAULTS["$key"]}"
    fi
  done

  return 0
}

# shell_cli_flag_rules_validate normalize and asserts flag specifications.
#
# Arguments:
#   - flag_assoc: The string name of the target associative array.
#
# Returns:
#   - 0: If the configuration schema is structurally intact and logically sound.
#   - 1: If any metadata constraint fails or a logical architectural rule breaks.
shell_cli_flag_rules_validate() {
  local flag_assoc="$1"
  
  # First, ensure all uninitialized metadata keys are filled with system defaults
  shell_cli_flag_rules_normalize_all "$flag_assoc"

  local -n ref_flag="$flag_assoc"

  local err_prefix="[ERR]"
  err_prefix+="[ ${flag_assoc} ]"
  err_prefix+="[ flag: ${ref_flag["long"]} ]"

  local err_key=""



  # ------------------------------------------------------------------------------
  # PHASE 1: CROSS-PROPERTY LOGICAL CONSTRAINTS VERIFICATION
  # ------------------------------------------------------------------------------

  local k_long="${ref_flag["long"]}"
  local k_short="${ref_flag["short"]}"
  local k_type="${ref_flag["type"]}"
  local k_array="${ref_flag["array"]}"
  local k_assoc="${ref_flag["assoc"]}"
  local k_required="${ref_flag["required"]}"
  local k_default="${ref_flag["default"]}"
  local k_enum="${ref_flag["enum"]}"
  local k_assoc_keys="${ref_flag["assoc_keys"]}"
  local k_min="${ref_flag["min"]}"
  local k_max="${ref_flag["max"]}"
  local k_min_array="${ref_flag["min_array"]}"
  local k_max_array="${ref_flag["max_array"]}"
  local k_regex="${ref_flag["regex"]}"
  local k_description="${ref_flag["description"]}"
  local k_tipinput="${ref_flag["tipinput"]}"
  local k_validate="${ref_flag["validate"]}"
  local k_transform="${ref_flag["transform"]}"



  #
  # Key: long
  err_key="[ key: long ]"

  # Rule A1: Required
  if [ "$k_long" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: is required."
    return 1
  fi

  # Rule A2: Reserved Keyword
  if [[ "$k_long" =~ ^(help|interactive)$ ]]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: names 'help' and 'interactive' are reserved."
    return 1
  fi



  #
  # Key: short
  err_key="[ key: short ]"

  # Rule B1: Reserved Keyword
  if [[ "$k_short" =~ ^(h|itr)$ ]]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: names 'h' and 'itr' are reserved."
    return 1
  fi

  # Rule B2: Prevent collision
  if [ "$k_long" = "$k_short" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot be the same as 'long' ( short='$k_short' )."
    return 1
  fi



  #
  # Key: type
  err_key="[ key: type ]"

  # Rule C1: validate 'type'
  if [ "${CORE_METAFLAG_TYPES["$k_type"]}" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid definition ( type='$k_type' )."
    return 1
  fi



  #
  # Key: array
  err_key="[ key: array ]"

  # Rule D1: If is a valid boolean
  if [ "$k_array" != "1" ] && [ "$k_array" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( array='$k_array' )."
    return 1
  fi



  #
  # Key: assoc
  err_key="[ key: assoc ]"

  # Rule E1: If is a valid boolean
  if [ "$k_assoc" != "1" ] && [ "$k_assoc" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( assoc='$k_assoc' )."
    return 1
  fi



  #
  # Key: array | assoc
  err_key="[ key: array, assoc ]"

  # Rule F1: Array vs Assoc exclusivity
  if [ "$k_array" = "1" ] && [ "$k_assoc" = "1" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot declare 'array=true' and 'assoc=true' simultaneously."
    return 1
  fi



  #
  # Key: required
  err_key="[ key: required ]"

  # Rule G1: If is a valid boolean
  if [ "$k_required" != "1" ] && [ "$k_required" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( required='$k_required' )."
    return 1
  fi



  #
  # Key: default
  err_key="[ key: default ]"

  # Rule H1: Required vs Default exclusivity
  if [ "$k_required" = "1" ] && [ "$k_default" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi



  #
  # Key: enum
  err_key="[ key: enum ]"

  # Rule I1: Cannot define 'enum' for non 'type=enum' flag
  if [ "$k_type" != "enum" ] && [ "$k_enum" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'enum' for a non 'type=enum' flag."
    return 1
  fi

  # Rule I2: Required 'enum' definition for 'type=enum' flag
  if [ "$k_type" = "enum" ] && [ "$k_enum" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: flags with 'type=enum' must declare 'enum' property."
    return 1
  fi

  # Rule I3: Enum pointer verification
  if [ "$k_type" = "enum" ]; then
    local str_declare=$(declare -p "$k_enum" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_enum' must be an associative array (declare -A)."
      return 1
    fi
  fi



  #
  # Key: assoc_keys
  err_key="[ key: assoc_keys ]"

  # Rule J1: Cannot define 'assoc_keys' for a 'assoc=0' flag
  if [ "$k_assoc" = "0" ] && [ "$k_assoc_keys" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'assoc_keys' for a 'assoc=false' flag."
    return 1
  fi

  # Rule J2: Assoc keys pointer verification
  if [ "$k_assoc_keys" != "" ]; then
    local str_declare=$(declare -p "$k_assoc_keys" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_assoc_keys' must be an indexed array (declare -a)."
      return 1
    fi
  fi



  #
  # Key: min
  err_key="[ key: min ]"

  if [ "$k_min" != "" ]; then
    # Rule K1: Check 'time' 'min'
    if [ "$k_type" = "time" ]; then
      if [[ ! "$k_min" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'time' value ( min='$k_min'; expected HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "0001-01-01 $k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 $k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%H:%M:%S 2>/dev/null || date -j -r "$ts" +%H:%M:%S 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies an invalid or impossible time ( min='$k_min' )."
        return 1
      fi
    fi

    # Rule K2: Check 'date' 'min'
    if [ "$k_type" = "date" ]; then
      if [[ ! "$k_min" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'date' value ( min='$k_min'; expected YYYY-MM-DD )."
        return 1
      fi

      local ts=$(date -d "$k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%Y-%m-%d 2>/dev/null || date -j -r "$ts" +%Y-%m-%d 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent calendar date ( min='$k_min' )."
        return 1
      fi
    fi

    # Rule K3: Check 'datetime' 'min'
    if [ "$k_type" = "datetime" ]; then
      if [[ ! "$k_min" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'datetime' value ( min='$k_min'; expected YYYY-MM-DD HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "$k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent timestamp ( min='$k_min' )."
        return 1
      fi
    fi
  fi



  #
  # Key: max
  err_key="[ key: max ]"

  if [ "$k_max" != "" ]; then
    # Rule L1: Check 'time' 'max'
    if [ "$k_type" = "time" ]; then
      if [[ ! "$k_max" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'time' value ( max='$k_max'; expected HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "0001-01-01 $k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 $k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%H:%M:%S 2>/dev/null || date -j -r "$ts" +%H:%M:%S 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies an invalid or impossible time ( max='$k_max' )."
        return 1
      fi
    fi

    # Rule L2: Check 'date' 'max'
    if [ "$k_type" = "date" ]; then
      if [[ ! "$k_max" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'date' value ( max='$k_max'; expected YYYY-MM-DD )."
        return 1
      fi

      local ts=$(date -d "$k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%Y-%m-%d 2>/dev/null || date -j -r "$ts" +%Y-%m-%d 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent calendar date ( max='$k_max' )."
        return 1
      fi
    fi

    # Rule L3: Check 'datetime' 'max'
    if [ "$k_type" = "datetime" ]; then
      if [[ ! "$k_max" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'datetime' value ( max='$k_max'; expected YYYY-MM-DD HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "$k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent timestamp ( max='$k_max' )."
        return 1
      fi
    fi
  fi



  #
  # Key: min | max
  err_key="[ key: min, max ]"

  # Rule M1: Check Range Inversion between 'min' and 'max'
  if [ "$k_min" != "" ] && [ "$k_max" != "" ]; then
    case "$k_type" in
      int)
        if (( $k_min > $k_max )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
        
      float)
        if ! shell_cli_math_is_less_or_equal "$k_min" "$k_max" "0"; then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;

      time|date|datetime)
        local prefix=""
        local fmt="%Y-%m-%d %H:%M:%S"
        
        if [ "$k_type" = "date" ]; then
          fmt="%Y-%m-%d"
        elif [ "$k_type" = "time" ]; then
          prefix="0001-01-01 "
        fi

        local min_sec=$(date -d "${prefix}${k_min}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${k_min}" +%s 2>/dev/null)
        local max_sec=$(date -d "${prefix}${k_max}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${k_max}" +%s 2>/dev/null)

        if (( $min_sec > $max_sec )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
        
      *)
        if (( $k_min > $k_max )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' length cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
    esac
  fi



  #
  # Key: min_array
  err_key="[ key: min_array ]"

  # Rule N1: Cannot define 'min_array' for a 'array=0' flag
  if [ "$k_array" = "0" ] &&  [ "$k_min_array" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'min_array' for a 'array=false' flag."
    return 1
  fi



  #
  # Key: max_array
  err_key="[ key: max_array ]"

  # Rule O1: Cannot define 'max_array' for a 'array=0' flag
  if [ "$k_array" = "0" ] &&  [ "$k_max_array" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'max_array' for a 'array=false' flag."
    return 1
  fi



  #
  # Key: min_array | max_array
  err_key="[ key: min_array, max_array ]"

  # Rule P1: Check Range Inversion between 'min_array' and 'max_array'
  if [ "$k_min_array" != "" ] && [ "$k_max_array" != "" ]; then
    if (( $k_min_array > $k_max_array )); then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min_array' limit cannot exceed 'max_array' ( min_array='$k_min_array', max_array='$k_max_array' )."
      return 1
    fi
  fi



  #
  # Key: regex
  err_key="[ key: regex ]"

  # Rule Q1: Check regular expression
  if [ "$k_regex" != "" ]; then
    ( [[ "" =~ $k_regex ]] ) 2>/dev/null
    local exit_status=$?

    if [ $exit_status -eq 2 ]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid regular expression ( regex='$k_regex' )."
      return 1
    fi
  fi



  #
  # Key: description
  err_key="[ key: description ]"

  # Rule R1: Required
  if [ "$k_description" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: is required."
    return 1
  fi



  #
  # Key: validate
  err_key="[ key: validate ]"

  # Rule S1: Check validate functions
  if [ "$k_validate" != "" ]; then
    local str_declare=$(declare -p "$k_validate" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_validate' must be an indexed array (declare -a)."
      return 1
    fi

    local -n ref_validate="$k_validate"
    for fn_validate in "${ref_validate[@]}"; do
      if ! declare -f "$fn_validate" >/dev/null; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: validation function does not exist ( fn='${fn_validate}' )."
        return 1
      fi
    done
  fi



  #
  # Key: transform
  err_key="[ key: transform ]"

  # Rule T1: Check transform functions
  if [ "$k_transform" != "" ]; then
    local str_declare=$(declare -p "$k_transform" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_transform' must be an indexed array (declare -a)."
      return 1
    fi

    local -n ref_transform="$k_transform"
    for fn_transform in "${ref_transform[@]}"; do
      if ! declare -f "$fn_transform" >/dev/null; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: transform function does not exist ( fn='${fn_transform}' )."
        return 1
      fi
    done
  fi

  return 0
}

# shell_cli_flag_rules_validate_all normalize and asserts all flag from same family.
#
# Arguments:
#   - prefix: Prefix used to define all flags under the same family.
#   - order_array: Name of the order array with all flag names.
#
# Returns:
#   - 0: If the configuration schema is structurally intact and logically sound.
#   - 1: If any metadata constraint fails or a logical architectural rule breaks.
shell_cli_flag_rules_finalize_register() {
  local prefix="$1"
  local order_array="$2"

  if [ "$prefix" == "" ]; then
    VALIDATION_ERROR_MSG="[ERR] :: Flag family prefix is required."
    return 1
  fi

  if [ "$order_array" == "" ]; then
    VALIDATION_ERROR_MSG="[ERR] :: Default order array is required."
    return 1
  fi

  local str_declare=$(declare -p "$order_array" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
    VALIDATION_ERROR_MSG="[ERR] :: Invalid default order array. Expected indexed array (declare -a)."
    return 1
  fi

  local -n ref_order_array="$order_array"
  if [ "${#ref_order_array[@]}" == "0" ]; then
    return 0
  fi

  for flag_name in "${ref_order_array[@]}"; do
    local flag_assoc="${prefix}_${flag_name}"

    local str_declare=$(declare -p "$flag_assoc" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      VALIDATION_ERROR_MSG="[ERR] :: Invalid or undefined assoc flag '$flag_assoc'. Expected associative array (declare -A)."
      return 1
    fi

    if ! shell_cli_flag_rules_validate "${flag_assoc}"; then
      echo -e "${VALIDATION_ERROR_MSG}"
      return 1
    fi
  done
}
