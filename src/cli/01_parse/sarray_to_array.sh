#!/usr/bin/env bash

# SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING — Reconstructed JSON-like array string representation.
# 
# - Contains the formatted string (e.g., ["v1","v2"]) on success.
# - Stores the original unparsed input string in case of an error.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""

# SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME — Reference to the input indexed array name.
# 
# - Stores the variable name only when an existing indexed array is passed as input.
# - Remains empty when the input is a direct JSON-like string.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME=""

# SHELL_CLI_PARSE_SARRAY_TO_ARRAY — Global indexed array holding the extracted values.
# 
# - Populated with the elements parsed from the string or copied from the reference
#   array.
# - Always reset and cleared at the beginning of the execution.
declare -ga SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()

# SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE — Parser error message store.
# 
# - Contains a descriptive syntax or format error message when execution fails.
# - Cleared and remains empty on successful parsing.
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE=""





# shell_cli_parse_sarray_to_array — Parse a JSON-like array string or local indexed
# array into global variables.
# 
# Arguments
# - value: Name of an existing indexed array OR a single-level JSON-like array string
#   (e.g., '["a","b"]').
# 
# Global outputs
# - SHELL_CLI_PARSE_SARRAY_TO_ARRAY: Indexed array populated with the parsed/copied
#   elements.
# - SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING: Reconstructed JSON-like array string
#   representation.
# - SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME: Stored input array name (only when an array
#   name is passed).
# - SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE: Contains descriptive error message
#   on failure.
# 
# Notes
# - Only supports single-level arrays; nested structures, objects, or complex escapes
#   are not supported.
# - Spaces are only allowed inside quoted values (single or double quotes).
# - Escapes are limited to \' and \" inside matching quotes.
# - If the input is empty, it clears global outputs and returns 0 without error.
# 
# Returns
# - 0: Success.
# - 1: Failure (malformed string, missing brackets, or invalid syntax).
shell_cli_parse_sarray_to_array() {
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
