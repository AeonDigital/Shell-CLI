#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/00_parse_sjson_to_assoc.sh
# DESCRIPTION: 
# ==============================================================================

# Holds all key/value pairs extracted from the input.
declare -gA SHELL_CLI_PARSE_SJSON_TO_ASSOC=()

# Holds the order of discovered keys.
# Note: This order is fully reliable only when parsing from a JSON string.
#       When input is an existing associative array, Bash does not preserve
#       insertion order, so this information is lost.
declare -ga SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()

# Holds the normalized string result (array name or reconstructed JSON).
# On error, contains the original raw string.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""

# Exit status indicator of the last parse attempt.
# "0" means success, "1" means error.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_RESULT="0"





# shell_cli_parse_sjson_to_assoc parse a JSON string to assoc array.
#
# Accepted input:
# - The name of an existing associative array.
# - A string representing a single‑level JSON object.
#
# Behavior:
# - If the input is the name of an associative array:
#   * All key/value pairs are copied into 'SHELL_CLI_PARSE_SJSON_TO_ASSOC'.
#   * The function returns the array name.
#   * Note: 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER' is not reliable in this case,
#     since Bash associative arrays do not preserve insertion order.
#
# - If the input is a JSON string:
#   * Empty objects "{}" or "{   }" return "{}" and produce no pairs.
#   * Valid single‑level objects are parsed and populate
#     'SHELL_CLI_PARSE_SJSON_TO_ASSOC' with each key/value pair.
#   * The order of discovered keys is stored in
#     'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER' and is fully reliable when 
#     originating from JSON parsing.
#   * The function returns the reconstructed JSON string.
#
# - If the string is malformed:
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC' will contain:
#     ['!ERR'] : original value
#     ['err']  : error message
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING' is set to the original string.
#   * Function returns with status 1.
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
# - Exit status 0 on success, 1 on error.
# - Populates the three global variables as described above.
shell_cli_parse_sjson_to_assoc() {
  # clean json string
  local value="$1"
  value=$(printf "%s" "$value" | tr -d '\000-\010\013\014\016-\037\177')
  value="${value#"${value%%[![:space:]]*}"}" # trim L
  value="${value%"${value##*[![:space:]]}"}" # trim R


  # Reset global associative array cleanly
  SHELL_CLI_PARSE_SJSON_TO_ASSOC=()
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_RESULT="0"

  local invalidJSON="0"
  local invalidJSONMsg=""
  local stringifiedJSON=""

  # empty value
  if [ "$value" == "" ]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""
    return 0
  fi

  # pointer to assoc array
  local str_declare=$(declare -p "$value" 2>/dev/null)
  if [[ "$str_declare" =~ ^"declare -A" ]]; then
    local -n tmp_assoc="$value"
    for k in "${!tmp_assoc[@]}"; do 
      local v="${tmp_assoc[$k]}"
      SHELL_CLI_PARSE_SJSON_TO_ASSOC["$k"]="$v"
      SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("$k")
    done
    
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="$value"
    return 0
  fi

  # empty object
  if [[ "$value" =~ ^\{[[:space:]]*\}$ ]]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="{}"
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

    local nl=$'\n'
    
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
            if [ "$char" = "$nl" ]; then
              invalidJSON="1"
              invalidJSONMsg="invalid syntax; found \\n char in key name."
              break
            fi
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
        if [ "$char" != " " ] && [ "$char" != "$nl" ]; then
          if [ "$char" != ":" ]; then
            invalidArray="1"
            invalidArrayMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
            break
          else
            reading="value"

            openvalue="0"
            currentvalue=""
            openvaluewith=""
          fi
        fi
      elif [ "$reading" = "value" ]; then
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
              invalidJSON="1"
              invalidJSONMsg="invalid syntax; char '$char' in invalid position [ idx: $idx ]."
              break
            fi
          fi
        elif [ "$openvalue" = "1" ]; then
          local stopread="0"

          if [ "$openvaluewith" = "" ]; then
            if [ "$char" = " " ] || [ "$char" = "," ] || [ "$char" = "$nl" ]; then
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

            if [ "$char" = "," ]; then
              reading="key"
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
            reading="key"
          fi
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

        SHELL_CLI_PARSE_SJSON_TO_ASSOC["$k"]="${v}"
        SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("$k")
        stringifiedJSON+="\"$k\":\"$v\""
      done
      stringifiedJSON+="}"
    fi

  fi


  if [ "$invalidJSON" = "1" ]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC['!ERR']="${value}"
    SHELL_CLI_PARSE_SJSON_TO_ASSOC['err']="${invalidJSONMsg}"
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="$value"
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_RESULT="1"
    return 1
  fi

  SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="$stringifiedJSON"
  return 0
}
