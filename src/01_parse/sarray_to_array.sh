#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 01_parse/sarray_to_array.sh
# DESCRIPTION: 
# ==============================================================================

# JSON‑like string reconstructed from the input (e.g. ["v1","v2"]).
# In case of error, contains the original string.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""

# Stores the name of the original array when the input is a reference
# to an existing indexed array. Empty otherwise.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME=""

# Indexed array holding the values extracted from the input.
# Always reset at the beginning of the function
declare -ga SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()

# Holds the parser error message when a failure occurs.
# Empty on success.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE=""





# shell_cli_parse_sarray_to_array parse a JSON‑like array string to 
# indexed array.
#
# Arguments:
# - value: indexed array name or array string.
#
# Accepted input:
# - The name of an existing indexed array.
# - A string representing a single‑level JSON‑like array.
# - An empty string (special case).
#
# Behavior:
# - If the input is the name of an indexed array:
#   * All values are copied into 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY'.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the reconstructed 
#      JSON‑like string (e.g. ["v1","v2"]).
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME' is set to the array name.
#
# - If the input is an array string:
#   * Empty arrays "[]" or "[   ]" set
#     'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' to "[]".
#   * Valid single‑level arrays are parsed and populate
#     'SHELL_CLI_PARSE_SARRAY_TO_ARRAY' with each value.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the 
#     reconstructed array.
#
# - If the input is an empty string:
#   * Function returns with status 0.
#   * No global variables are populated.
#
# - If the string is malformed:
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY' will contain a single element with the 
#     error message.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE' is set with the 
#     error message.
#   * 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING' is set to the original string.
#   * Function returns with status 1.
#
# Constraints:
# - Only single‑level arrays are supported.
# - Accepted values: simple strings (quoted with ' or "),
#   numbers, booleans, and alphanumeric tokens including '.'.
# - Unquoted values cannot contain spaces.
# - Spaces are only supported inside quoted strings. 
# - Escapes are limited: only \" or \' inside quoted strings are accepted.
# - Nested arrays, objects, and complex escape sequences are not supported.
#
# Error cases:
# - Missing opening or closing square brackets produces the message
#   "invalid syntax; loss of square brackets."
# - Any invalid character in unexpected position produces a descriptive
#   error message stored in 'SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE'.
#
# Returns:
# - 0: on success
# - 1: on error
#
# - Populates the four global variables as described above:
#   * SHELL_CLI_PARSE_SARRAY_TO_ARRAY
#   * SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING
#   * SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME
#   * SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE
shell_cli_parse_sarray_to_array() {
  # clean json string
  local value="${1}"
  value=$(printf "%s" "${value}" | tr -d '\000-\010\013\014\016-\037\177')
  value="${value#"${value%%[![:space:]]*}"}" # trim L
  value="${value%"${value##*[![:space:]]}"}" # trim R


  # Reset external control variables
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME=""
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE=""


  # empty value
  if [ "${value}" == "" ]; then
    return 0
  fi

  # pointer to indexed array
  if shell_cli_utils_array_is_indexed "${value}"; then
    local -n tmp_array="${value}"
    local i=""
    local v=""

    local stringifiedArray="["
    for i in "${!tmp_array[@]}"; do 
      v="${tmp_array[${i}]}"
      SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("${v}")


      if [ "${i}" -gt "0" ]; then
        stringifiedArray+=","
      fi
      stringifiedArray+="\"${v}\""
    done
    stringifiedArray="]"
    
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="${stringifiedArray}"
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME="${value}"
    return 0
  fi

  # empty object
  if [[ "${value}" =~ ^\[[[:space:]]*\]$ ]]; then
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="[]"
    return 0
  fi

  # invalid object
  if [ "${value:0:1}" != "[" ] || [ "${value: -1}" != "]" ]; then
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; loss of square brackets."
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
  local reading="value" # 'value' ; ','
  
  # value
  local openvalue="0"
  local currentvalue=""
  local openvaluewith=""
  local -a arr_tmp_values=()



  while [ "${idx}" -lt "${len}" ]; do
    char="${inner:${idx}:1}"

    if [ "${reading}" = "value" ]; then
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
            SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
            return 1
          fi
        fi
      elif [ "${openvalue}" = "1" ]; then
        local stopread="0"

        if [ "${openvaluewith}" = "" ]; then
          if [ "${char}" = " " ] || [ "${char}" = "," ] || [ "${char}" = "${nl}" ]; then
            stopread="1"
          elif [ "${char}" = "'" ] || [ "${char}" = '"' ] || [[ ! "${char}" =~ ^[0-9A-Za-z.]+$ ]]; then
            SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
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
            reading="value"
          fi
        fi
      fi
    elif [ "${reading}" = "," ]; then
      if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
        if [ "${char}" != "," ]; then
          SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
          return 1
        else
          reading="value"
        fi
      fi
    fi
    
    idx=$((${idx} + 1))
    previousChar="${char}"
  done



  local i=""
  local v=""
  local stringifiedArray="["
  for i in "${!arr_tmp_values[@]}"; do 
    v="${arr_tmp_values[${i}]}"
    SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("${v}")


    if [ "${i}" -gt "0" ]; then
      stringifiedArray+=","
    fi
    stringifiedArray+="\"${v}\""
  done
  stringifiedArray="]"
  
  SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="${stringifiedArray}"
  return 0
}
