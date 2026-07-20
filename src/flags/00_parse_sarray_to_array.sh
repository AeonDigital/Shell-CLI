#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/00_parse_sarray_to_array.sh
# DESCRIPTION: 
# ==============================================================================

# Holds all values extracted from the input.
declare -ga SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()

# Holds the normalized string result (array name or reconstructed array).
# On error, contains the original raw string.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""

# Exit status indicator of the last parse attempt.
# "0" means success, "1" means error.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="0"





# shell_cli_parse_sarray_to_array — parse a JSON‑like array string to indexed array.
#
# Accepted input:
#   - The name of an existing indexed array.
#   - A string representing a single‑level JSON‑like array.
#
# Behavior:
# - If the input is the name of an indexed array:
#   * All values are copied into 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY'.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the array name.
#
# - If the input is an array string:
#   * Empty arrays "[]" or "[   ]" set
#     'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' to "[]".
#   * Valid single‑level arrays are parsed and populate
#     'SHELL_CLI_PARSE_SARRAY_TO_ARRAY' with each value.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the reconstructed array.
#
# - If the string is malformed:
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY' will contain a single element
#     starting with "!ERR" followed by the error message.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the original string.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT' is set to "1".
#   * Function returns with status 1.
#
# Constraints:
# - Only single‑level arrays are supported.
# - Accepted values: simple strings (quoted with ' or "),
#   numbers, booleans, and alphanumeric tokens including '.'.
# - Nested arrays, objects, and complex escape sequences are not supported.
#
# Arguments:
# - value: indexed array name or array string.
#
# Returns:
# - Exit status 0 on success, 1 on error.
# - Populates the three global variables as described above.
shell_cli_parse_sarray_to_array() {
  # clean json string
  local value="$1"
  value=$(printf "%s" "$value" | tr -d '\000-\010\013\014\016-\037\177')
  value="${value#"${value%%[![:space:]]*}"}" # trim L
  value="${value%"${value##*[![:space:]]}"}" # trim R


  # Reset global associative array cleanly
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="0"

  local invalidArray="0"
  local invalidArrayMsg=""
  local stringifiedArray=""

  # empty value
  if [ "$value" == "" ]; then
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""
    return 0
  fi

  # pointer to indexed array
  local str_declare=$(declare -p "$value" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -a" ]]; then
    local -n tmp_assoc="$value"
    for v in "${tmp_assoc[@]}"; do 
      SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("$v")
    done
    
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="$value"
    return 0
  fi

  # empty object
  if [[ "$value" =~ ^\[[[:space:]]*\]$ ]]; then
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="[]"
    return 0
  fi

  # invalid object
  if [ "${value:0:1}" != "[" ] || [ "${value: -1}" != "]" ]; then
    invalidArray="1"
    invalidArrayMsg="invalid syntax; loss of square brackets."
  fi


  if [ "$invalidArray" = "0" ]; then
    local inner="${value#?}"
    inner="${inner%?}"

    local nl=$'\n'
    
    local idx="0"
    local len=${#inner}
    local lastCharIndex=$((len - 1))
    local char=""
    local previousChar=""
    local reading="value" # 'value' ; ','
    
    # value
    local openvalue="0"
    local currentvalue=""
    local openvaluewith=""
    local -a arr_tmp_values=()


    while [ "$idx" -lt "$len" ]; do
      char="${inner:$idx:1}"

      if [ "$reading" = "value" ]; then
        if [ "$openvalue" = "0" ]; then
          if [ "$char" != " " ] && [ "$char" != "$nl" ]; then
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
              invalidArray="1"
              invalidArrayMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
              break
            fi
          fi
        elif [ "$openvalue" = "1" ]; then
          local stopread="0"

          if [ "$openvaluewith" = "" ]; then
            if [ "$char" = " " ] || [ "$char" = "," ] || [ "$char" = "$nl" ]; then
              stopread="1"
            elif [ "$char" = "'" ] || [ "$char" = '"' ] || [[ ! "$char" =~ ^[0-9A-Za-z.]+$ ]]; then
              invalidArray="1"
              invalidArrayMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
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

            if [ "$char" = "," ]; then
              reading="value"
            fi
          fi
        fi
      elif [ "$reading" = "," ]; then
        if [ "$char" != " " ] && [ "$char" != "$nl" ]; then
          if [ "$char" != "," ]; then
            invalidArray="1"
            invalidArrayMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
            break
          else
            reading="value"
          fi
        fi
      fi
      
      idx=$((idx + 1))
      previousChar="$char"
    done


    if [ "$invalidArray" = "0" ]; then
      local i=""
      local v=""
      stringifiedArray+="["
      for i in "${!arr_tmp_values[@]}"; do
        if [ "$i" -gt "0" ]; then
          stringifiedArray+=","
        fi

        v="${arr_tmp_values[$i]}"

        SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("${v}")
        stringifiedArray+="\"$v\""
      done
      stringifiedArray+="]"
    fi

  fi


  if [ "$invalidArray" = "1" ]; then
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=('!ERR'" $invalidArrayMsg")
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="$value"
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="1"
    return 1
  fi

  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_RESULT="$stringifiedArray"
  return 0
}
