#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 01_parse/sjson_to_assoc.sh
# DESCRIPTION: 
# ==============================================================================

# JSON‑like string reconstructed from the input (e.g. {"k1":"v1","k2":"v2"}).
# In case of error, contains the original string.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""

# Stores the name of the original array when the input is a reference
# to an existing associative array. Empty otherwise.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME=""

# Associative array holding the key/value pairs extracted from the input.
# Always reset at the beginning of the function.
declare -gA SHELL_CLI_PARSE_SJSON_TO_ASSOC=()

# Holds the order of discovered keys.
# Reliable only when parsing from a JSON string.
# When input is an existing associative array, Bash does not preserve
# insertion order, so this information is not reliable.
declare -ga SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()

# Holds the parser error message when a failure occurs.
# Empty on success.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE=""





# shell_cli_parse_sjson_to_assoc parse a JSON‑like object string to 
# associative array.
#
# Arguments:
# - value: associative array name or JSON string.
#
# Accepted input:
# - The name of an existing associative array.
# - A string representing a single‑level JSON object.
# - An empty string (special case).
#
# Behavior:
# - If the input is the name of an associative array:
#   * All key/value pairs are copied into 'SHELL_CLI_PARSE_SJSON_TO_ASSOC'.
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING' is set to the reconstructed 
#     JSON‑like string (e.g. {"k1":"v1","k2":"v2"}).
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME' is set to the array name.
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER' is populated, but order is not 
#     reliable since Bash associative arrays do not preserve insertion order.
#
# - If the input is a JSON string:
#   * Empty objects "{}" or "{   }" set 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING' 
#     to "{}" and produce no pairs.
#   * Valid single‑level objects are parsed and populate
#     'SHELL_CLI_PARSE_SJSON_TO_ASSOC' with each key/value pair.
#   * The order of discovered keys is stored in 
#     'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER' and is fully reliable when 
#     originating from JSON parsing.
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING' is set to the reconstructed 
#     JSON string.
#
# - If the input is an empty string:
#   * Function returns with status 0.
#   * No global variables are populated.
#
# - If the string is malformed:
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE' is set with the error message.
#   * 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING' is set to the original string.
#   * Function returns with status 1.
#
# Constraints:
# - Only single‑level JSON objects are supported.
# - Keys must always be quoted with ' or ".
# - Accepted values: simple strings (quoted with ' or "),
#   numbers, booleans, and alphanumeric tokens including '.'.
# - Spaces are only supported inside quoted strings. Unquoted values cannot 
#   contain spaces.
# - Escapes are limited: only \" or \' inside quoted strings are accepted.
# - Nested objects, arrays, and complex escape sequences are not supported.
#
# Error cases:
# - Missing opening or closing curly brackets produces the message
#   "invalid syntax; loss of curly brackets."
# - Empty key names are invalid and produce an error.
# - Duplicated keys are rejected with the message
#   "invalid object; duplicated key '<key>'."
# - Any invalid character in unexpected position produces a descriptive
#   error message stored in 'SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE'.
# - Mismatched number of keys and values produces the message
#   "invalid parse; found '<klen>' keys to '<vlen>' values."
#
# Returns:
# - 0: on success
# - 1: on error
#
# - Populates the five global variables as described above:
#   * SHELL_CLI_PARSE_SJSON_TO_ASSOC
#   * SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING
#   * SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME
#   * SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER
#   * SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE
shell_cli_parse_sjson_to_assoc() {
  # clean json string
  local value="${1}"
  value=$(printf "%s" "${value}" | tr -d '\000-\010\013\014\016-\037\177')
  value="${value#"${value%%[![:space:]]*}"}" # trim L
  value="${value%"${value##*[![:space:]]}"}" # trim R


  # Reset external control variables
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME=""
  SHELL_CLI_PARSE_SJSON_TO_ASSOC=()
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()


  # empty value
  if [ "${value}" == "" ]; then
    return 0
  fi

  # pointer to assoc array
  if shell_cli_utils_array_is_assoc "${value}"; then
    local -n tmp_assoc="${value}"
    local k=""
    local v=""

    local stringifiedJSON+="{"
    for k in "${!tmp_assoc[@]}"; do 
      v="${tmp_assoc[${k}]}"
      SHELL_CLI_PARSE_SJSON_TO_ASSOC["${k}"]="${v}"
      SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("${k}")

      if [ "${stringifiedJSON}" != "{" ]; then
        stringifiedJSON+=","
      fi
      stringifiedJSON+="\"${k}\":\"${v}\""
    done
    stringifiedJSON+="}"
    
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="${stringifiedJSON}"
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME="${value}"
    return 0
  fi

  # empty object
  if [[ "${value}" =~ ^\{[[:space:]]*\}$ ]]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="{}"
    return 0
  fi

  # invalid object
  if [ "${value:0:1}" != "{" ] || [ "${value: -1}" != "}" ]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; loss of curly brackets."
    return 1
  fi



  local inner="${value#?}"
  inner="${inner%?}"

  local nl=$'\n'
  
  local idx="0"
  local len=${#inner}
  local lastCharIndex=$((${len} - 1))
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



  while [ "${idx}" -lt "${len}" ]; do
    char="${inner:${idx}:1}"

    if [ "${reading}" = "key" ]; then
      if [ "${openkey}" = "0" ]; then
        if [ "${char}" = "'" ] || [ "${char}" = '"' ]; then
          openkey="1"
          currentkey=""
          openkeywith="${char}"
        fi
      elif [ "${openkey}" = "1" ]; then
        if [ "${char}" != "${openkeywith}" ]; then
          if [ "${char}" = "${nl}" ]; then
            SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; found \\n char in key name."
            return 1
          fi
          currentkey+="${char}"
        else
          if [ "${currentkey}" = "" ]; then
            SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; unexpected empty key."
            return 1
          fi

          reading=":"
          arr_tmp_keys+=("${currentkey}")

          openkey="0"
          currentkey=""
          openkeywith=""
        fi
      fi
    elif [ "${reading}" = ":" ]; then
      if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
        if [ "${char}" != ":" ]; then
          SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
          return 1
        else
          reading="value"

          openvalue="0"
          currentvalue=""
          openvaluewith=""
        fi
      fi
    elif [ "${reading}" = "value" ]; then
      if [ "${openvalue}" = "0" ]; then
        if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
          if [[ "${char}" =~ ^[0-9A-Za-z\'\".]+$ ]]; then

            openvalue="1"
            currentvalue=""
            openvaluewith=""

            if [ "${char}" = "'" ] || [ "${char}" = '"' ]; then
              openvaluewith="${char}"
            else 
              currentvalue="${char}"
            fi

          else
            SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
            return 1
          fi
        fi
      elif [ "${openvalue}" = "1" ]; then
        local stopread="0"

        if [ "${openvaluewith}" = "" ]; then
          if [ "${char}" = " " ] || [ "${char}" = "," ] || [ "${char}" = "${nl}" ]; then
            stopread="1"
          elif [ "${char}" = "'" ] || [ "${char}" = '"' ] || [[ ! "${char}" =~ ^[0-9A-Za-z.]+$ ]]; then
            SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
            return 1
          fi

          if [ "${idx}" = "${lastCharIndex}" ]; then
            stopread="1"
            currentvalue+="${char}"
          fi
        elif [ "${openvaluewith}" != "" ]; then
          if [ "${char}" = "${openvaluewith}" ]; then
            if [ "${previousChar}" != "\\" ]; then
              stopread="1"
            else
              if [ "${idx}" = "${lastCharIndex}" ]; then
                stopread="1"
                currentvalue+="${char}"
              fi
            fi
          fi
        fi
        
        if [ "${stopread}" = "0" ]; then
          currentvalue+="${char}"
        else
          reading=","
          arr_tmp_values+=("${currentvalue}")

          openvalue="0"
          currentvalue=""
          openvaluewith=""

          if [ "${char}" = "," ]; then
            reading="key"
          fi
        fi
      fi
    elif [ "${reading}" = "," ]; then
      if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
        if [ "${char}" != "," ]; then
          SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
          return 1
        else
          reading="key"
        fi
      fi
    fi
    
    idx=$((${idx} + 1))
    previousChar="${char}"
  done



  local klen="${#arr_tmp_keys[@]}"
  local vlen="${#arr_tmp_values[@]}"
  if [ "${klen}" != "${vlen}" ]; then
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid parse; found '${klen}' keys to '${vlen}' values."
    return 1
  else
    local k=""
    local -A arr_duplicated=()
    for k in "${arr_tmp_keys[@]}"; do
      if [ "${arr_duplicated["${k}"]}" = "" ]; then
        arr_duplicated["${k}"]="1"
        continue
      fi

      SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid object; duplicated key '${k}'."
      return 1
    done
  fi



  local i=""
  local k=""
  local v=""
  
  local stringifiedJSON+="{"
  for i in "${!arr_tmp_keys[@]}"; do
    if [ "${i}" -gt "0" ]; then
      stringifiedJSON+=","
    fi

    k="${arr_tmp_keys[${i}]}"
    v="${arr_tmp_values[${i}]}"

    SHELL_CLI_PARSE_SJSON_TO_ASSOC["${k}"]="${v}"
    SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("${k}")
    stringifiedJSON+="\"${k}\":\"${v}\""
  done
  stringifiedJSON+="}"

  SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="${stringifiedJSON}"
  return 0
}
