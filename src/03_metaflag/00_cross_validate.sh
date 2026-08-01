#!/usr/bin/env bash

# shell_cli_metaflag_property_cross_validate_min_max - cross-validate metaflags 
# 'min' and 'max'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures logical consistency between 'min' and 'max' boundaries for a flag.
# - If validation has already been performed, indicated by '__cross_min_max=1',
#   the function exits successfully without repeating checks.
# - When both 'min' and 'max' are defined:
#   * int: verifies that min ≤ max.
#   * float: verifies that min ≤ max using math utility for precision.
#   * date/time/datetime: converts values to epoch timestamps and verifies
#     that min ≤ max chronologically.
#   * string/other: verifies that minimum length ≤ maximum length.
# - On violation, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
# - On success, marks '__cross_min_max=1' in the flag definition to avoid
#   redundant checks.
#
# Returns:
# - 0: validation success (boundaries consistent or already validated).
# - 1: validation failure (min exceeds max).
shell_cli_metaflag_property_cross_validate_min_max() {
  local fassoc="${2}"
  local -n __assoc="${fassoc}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${__assoc["__cross_min_max"]}" == "1" ]; then
    return 0
  fi

  local _min="${__assoc["min"]}"
  local _max="${__assoc["max"]}"

  if [ "${_min}" != "" ] && [ "${_max}" != "" ]; then
    local _type="${__assoc["type"]}"

    case "${_type}" in
      int)
        if (( ${_min} > ${_max} )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
          return 1
        fi
        ;;
        
      float)
        if ! shell_cli_utils_math_is_less_or_equal "${_min}" "${_max}" "0"; then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
          return 1
        fi
        ;;

      time|date|datetime)
        local prefix=""
        local fmt="%Y-%m-%d %H:%M:%S"
        
        if [ "${_type}" = "date" ]; then
          fmt="%Y-%m-%d"
        elif [ "${_type}" = "time" ]; then
          prefix="0001-01-01 "
        fi

        local min_sec=$(date -d "${prefix}${_min}" +%s 2>/dev/null || date -j -f "${fmt}" "${prefix}${_min}" +%s 2>/dev/null)
        local max_sec=$(date -d "${prefix}${_max}" +%s 2>/dev/null || date -j -f "${fmt}" "${prefix}${_max}" +%s 2>/dev/null)

        if (( ${min_sec} > ${max_sec} )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
          return 1
        fi
        ;;
        
      *)
        if (( ${_min} > ${_max} )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' length cannot exceed 'max' ( min='${_min}', max='${_max}' )."
          return 1
        fi
        ;;
    esac
  fi

  __assoc["__cross_min_max"]="1"
  return 0
}

# shell_cli_metaflag_property_cross_validate_min_array_max_array - cross-validate 
# metaflags 'min_array' and 'max_array'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures logical consistency between 'min_array' and 'max_array' boundaries
#   when the flag is defined as an array.
# - If validation has already been performed, indicated by 
#   '__cross_min_array_max_array=1', the function exits successfully without 
#   repeating checks.
# - When 'is_array' is true and both 'min_array' and 'max_array' are defined:
#   * Verifies that min_array ≤ max_array.
#   * If min_array > max_array, validation fails and an error message is stored in
#     'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
# - On success, marks '__cross_min_array_max_array=1' in the flag definition to
#   avoid redundant checks.
#
# Returns:
# - 0: validation success (boundaries consistent or already validated).
# - 1: validation failure (min_array exceeds max_array).
shell_cli_metaflag_property_cross_validate_min_array_max_array() {
  local fassoc="${2}"
  local -n __assoc="${fassoc}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${__assoc["__cross_min_array_max_array"]}" == "1" ]; then
    return 0
  fi

  local _array="${__assoc["is_array"]}"
  local _min_array="${__assoc["min_array"]}"
  local _max_array="${__assoc["max_array"]}"

  if [ "${_array}" = "1" ] && [ "${_min_array}" != "" ] && [ "${_max_array}" != "" ]; then
    if (( ${_min_array} > ${_max_array} )); then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min_array' limit cannot exceed 'max_array' ( min_array='${_min_array}', max_array='${_max_array}' )."
      return 1
    fi
  fi

  __assoc["__cross_min_array_max_array"]="1"
  return 0
}
