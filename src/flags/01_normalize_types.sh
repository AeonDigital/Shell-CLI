#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/01_normalize.sh
# DESCRIPTION: 
# ==============================================================================

#
# GROUP 01 : Primitives

# shell_cli_flag_normalize_string normalize 'string' value.
#
# Removes all control characters except \n, \r, and \t.
#
# Arguments:
#   - value: raw value.
#   - trim: use '1' to normalize string with 'trim' removing all empty spaces
#     before and after the first and last visible chars including boundery
#     \n, \r, and \t.
#   - fullClean: use '1' to remove all control chars including \n, \r, and \t.
#
# Returns:
#   - Outputs normalizated value.
#     text contains only printable characters and safe whitespace.
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
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string_full() {
  local value=$(shell_cli_flag_normalize_string "${1}" "1" "1")
  echo "$value"
}

# shell_cli_flag_normalize_string_trim normalize 'string' removind ALL
# control characters (except \n, \r and \t) and trim it.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     text contains only printable characters and safe whitespace.
shell_cli_flag_normalize_string_trim() {
  local value=$(shell_cli_flag_normalize_string "${1}" "1" "0")
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
  local value=$(shell_cli_flag_normalize_string_full "${1,,}")

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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  local value=$(shell_cli_flag_normalize_string_full "${1}")

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

# shell_cli_flag_normalize_assoc normalize 'assoc' string.
#
# Accepted input:
# - The name of an existing associative array.
# - A string representing a single‑level JSON object.
#
# Behavior:
# - If the input is the name of an associative array:
#   * All key/value pairs are copied into 'SHELL_CLI_NORMALIZATED_ASSOC'.
#   * The function returns the array name.
#   * Note: 'SHELL_CLI_NORMALIZATED_ASSOC_ORDER' is not reliable in this case,
#     since Bash associative arrays do not preserve insertion order.
#
# - If the input is a JSON string:
#   * Empty objects "{}" or "{   }" return "{}" and produce no pairs.
#   * Valid single‑level objects are parsed and populate
#     'SHELL_CLI_NORMALIZATED_ASSOC' with each key/value pair.
#   * The order of discovered keys is stored in
#     'SHELL_CLI_NORMALIZATED_ASSOC_ORDER' and is fully reliable when 
#     originating from JSON parsing.
#   * The function returns the reconstructed JSON string.
#
# - If the string is malformed:
#   * 'SHELL_CLI_NORMALIZATED_ASSOC' will contain:
#     SHELL_CLI_NORMALIZATED_ASSOC['!']="$raw"
#     SHELL_CLI_NORMALIZATED_ASSOC['err']="$invalidJSONMsg"
#   * The function returns the original string and exits with status 1.
#
# Constraints:
# - Only single‑level JSON objects are supported.
# - Accepted values: simple strings (quoted with ' or "),
#   numbers, booleans, and alphanumeric tokens including '.'.
# - Nested objects, arrays, and complex escape sequences are not supported!
#
# Arguments:
# - value: associative array name or JSON string.
#
# Returns:
# - Prints the normalized value (array name or reconstructed JSON).
# - Populates 'SHELL_CLI_NORMALIZATED_ASSOC' and
#   'SHELL_CLI_NORMALIZATED_ASSOC_ORDER' accordingly.
# - On error, prints the original string and populates
#   'SHELL_CLI_NORMALIZATED_ASSOC' with '!' and 'err'.
shell_cli_flag_normalize_assoc() {
  local value=$(shell_cli_flag_normalize_string_trim "${1}")

  # Reset global associative array cleanly
  SHELL_CLI_NORMALIZATED_ASSOC=()
  SHELL_CLI_NORMALIZATED_ASSOC_ORDER=()

  local invalidJSON="0"
  local invalidJSONMsg=""
  local stringifiedJSON=""

  # empty value
  if [ "$value" == "" ]; then
    echo ""
    return 0
  fi

  # pointer to assoc array
  local str_declare=$(declare -p "$value" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -A" ]]; then
    local -n tmp_assoc="$value"
    for k in "${!tmp_assoc[@]}"; do 
      local v="${tmp_assoc[$k]}"
      SHELL_CLI_NORMALIZATED_ASSOC["$k"]="$v"
      SHELL_CLI_NORMALIZATED_ASSOC_ORDER+=("$k")
    done
    
    echo "$value"
    return 0
  fi

  # empty object
  if [[ "$value" =~ ^\{[[:space:]]*\}$ ]]; then
    echo "{}"
    return 0
  fi

  # invalid object
  if [ "${value:0:1}" != "{" ] || [ "${value: -1}" != "}" ]; then
    invalidJSON="1"
    invalidJSONMsg="invalid syntax; loss of curly brackets."
  fi


  if [ "$invalidJSON" = "0" ]; then
    local inner="${value#?}"
    inner="${inner%?}"

    
    local idx="0"
    local len=${#inner}
    local lastCharIndex=$((len - 1))
    local char=""
    local previousChar=""
    local reading="key" # 'key' ; ':' ; 'value' ; ','
    
    # key
    local openkey="0"
    local currentkey=""
    local openkeywith=""
    local -a arr_tmp_keys=()

    # value
    local openvalue="0"
    local currentvalue=""
    local openvaluewith=""
    local -a arr_tmp_values=()


    while [ "$idx" -lt "$len" ]; do
      char="${inner:$idx:1}"

      if [ "$reading" = "key" ]; then
        if [ "$openkey" = "0" ]; then
          if [ "$char" = "'" ] || [ "$char" = '"' ]; then
            openkey="1"
            currentkey=""
            openkeywith="$char"
          fi
        elif [ "$openkey" = "1" ]; then
          if [ "$char" != "$openkeywith" ]; then
            currentkey+="$char"
          else 
            if [ "$currentkey" = "" ]; then
              invalidJSON="1"
              invalidJSONMsg="invalid syntax; unexpected empty key."
              break
            fi

            reading=":"
            arr_tmp_keys+=("$currentkey")

            openkey="0"
            currentkey=""
            openkeywith=""
          fi
        fi
      elif [ "$reading" = ":" ]; then
        if [ "$char" = ":" ]; then
          reading="value"

          openvalue="0"
          currentvalue=""
          openvaluewith=""
        fi
      elif [ "$reading" = "value" ]; then
        if [ "$openvalue" = "0" ]; then
          if [ "$char" != " " ]; then
            if [[ "$char" =~ ^[0-9A-Za-z\'\".]+$ ]]; then

              openvalue="1"
              currentvalue=""
              openvaluewith=""

              if [ "$char" = "'" ] || [ "$char" = '"' ]; then
                openvaluewith="$char"
              else 
                currentvalue="$char"
              fi

            else
              invalidJSON="1"
              invalidJSONMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
              break
            fi
          fi
        elif [ "$openvalue" = "1" ]; then
          local stopread="0"

          if [ "$openvaluewith" = "" ]; then
            if [ "$char" = " " ] || [ "$char" = "," ]; then
              stopread="1"
            elif [ "$char" = "'" ] || [ "$char" = '"' ] || [[ ! "$char" =~ ^[0-9A-Za-z.]+$ ]]; then
              invalidJSON="1"
              invalidJSONMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
              break
            fi

            if [ "$idx" = "$lastCharIndex" ]; then
              stopread="1"
              currentvalue+="$char"
            fi
          elif [ "$openvaluewith" != "" ]; then
            if [ "$char" = "$openvaluewith" ]; then
              if [ "$previousChar" != "\\" ]; then
                stopread="1"
              else
                if [ "$idx" = "$lastCharIndex" ]; then
                  stopread="1"
                  currentvalue+="$char"
                fi
              fi
            fi
          fi
          
          if [ "$stopread" = "0" ]; then
            currentvalue+="$char"
          else
            reading=","
            arr_tmp_values+=("$currentvalue")

            openvalue="0"
            currentvalue=""
            openvaluewith=""
          fi
        fi
      elif [ "$reading" = "," ]; then
        if [ "$char" = "," ]; then
          reading="key"
        fi
      fi
      
      idx=$((idx + 1))
      previousChar="$char"
    done


    if [ "$invalidJSON" = "0" ]; then
      local klen="${#arr_tmp_keys[@]}"
      local vlen="${#arr_tmp_values[@]}"
      if [ "$klen" != "$vlen" ]; then
        invalidJSON="1"
        invalidJSONMsg="invalid parse; found '$klen' keys to '$vlen' values."
      else
        local k=""
        local -A arr_duplicated=()
        for k in "${arr_tmp_keys[@]}"; do
          if [ "${arr_duplicated["$k"]}" = "" ]; then
            arr_duplicated["$k"]="1"
            continue
          fi

          invalidJSON="1"
          invalidJSONMsg="invalid object; duplicated key '$k'."
          break
        done
      fi
    fi


    if [ "$invalidJSON" = "0" ]; then
      local i=""
      local k=""
      local v=""
      stringifiedJSON+="{"
      for i in "${!arr_tmp_keys[@]}"; do
        if [ "$i" -gt "0" ]; then
          stringifiedJSON+=","
        fi

        k="${arr_tmp_keys[$i]}"
        v="${arr_tmp_values[$i]}"

        SHELL_CLI_NORMALIZATED_ASSOC["$k"]="${v}"
        SHELL_CLI_NORMALIZATED_ASSOC_ORDER+=("$k")
        stringifiedJSON+="\"$k\":\"$v\""
      done
      stringifiedJSON+="}"
    fi

  fi


  if [ "$invalidJSON" = "1" ]; then
    SHELL_CLI_NORMALIZATED_ASSOC['!']="${value}"
    SHELL_CLI_NORMALIZATED_ASSOC['err']="${invalidJSONMsg}"
    echo "$value"
    return 1
  fi

  echo "$stringifiedJSON"
  return 0
}





# shell_cli_flag_normalize_bool normalize 'email' value.
#
# Arguments:
#   - value: raw value.
#
# Returns:
#   - Outputs normalizated value.
#     or the original string otherwise.
shell_cli_flag_normalize_email() {
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
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
  shell_cli_flag_normalize_string_full "${1}"
}
