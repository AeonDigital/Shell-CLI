#!/usr/bin/env bash

# SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING — Reconstructed JSON object string representation.
# 
# - Contains the formatted object string (e.g., {"k1":"v1"}) on success.
# - Stores the original unparsed input string in case of an error.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""

# SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME — Reference to the input associative array
# name.
# 
# - Stores the variable name only when an existing associative array is passed as
#   input.
# - Remains empty when the input is a direct JSON string.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME=""

# SHELL_CLI_PARSE_SJSON_TO_ASSOC — Global associative array holding extracted key-value
# pairs.
# 
# - Populated with pairs parsed from the string or copied from the reference array.
# - Always reset and cleared at the beginning of the execution.
declare -gA SHELL_CLI_PARSE_SJSON_TO_ASSOC=()

# SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER — Global indexed array tracking object key
# sequence.
# 
# - Guarantees insertion order only when parsing directly from a JSON string.
# - Unreliable when copying from an associative array reference due to Bash engine
#   indexing.
declare -ga SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()

# SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE — Parser error message store.
# 
# - Contains a descriptive syntax, duplicate key, or mismatch error message on failure.
# - Cleared and remains empty on successful parsing.
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE=""





# shell_cli_parse_sjson_to_assoc — Parse a single-level JSON object string or local
# associative array into global variables.
# 
# Arguments
# - value: Name of an existing associative array OR a single-level JSON object string
#   (e.g., '{"k":"v"}').
# 
# Global outputs
# - SHELL_CLI_PARSE_SJSON_TO_ASSOC: Associative array populated with the parsed/copied
#   key-value pairs.
# - SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER: Indexed array maintaining the insertion
#   order of the parsed keys.
# - SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING: Reconstructed JSON object string representation.
# - SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME: Stored input array name (only when an associative
#   array name is passed).
# - SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE: Contains descriptive error message
#   on failure.
# 
# Notes
# - Only supports single-level JSON objects; nested objects, arrays, or complex escapes
#   are not supported.
# - Object keys must be explicitly enclosed in single or double quotes and cannot
#   contain newline characters.
# - Values support unquoted alphanumeric tokens (no spaces) or quoted strings (spaces
#   allowed).
# - Duplicate keys within the input JSON string will cause a parsing failure.
# - If the input is empty, it clears all global outputs and returns 0 without error.
# 
# Returns
# - 0: Success.
# - 1: Failure (malformed string, missing curly brackets, duplicate keys, or key/value
#   count mismatch).
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
  SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE=""


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
