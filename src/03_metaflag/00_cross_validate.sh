#!/usr/bin/env bash

# shell_cli_metaflag_property_cross_validate_min_max - Cross-validate 'min' and 'max' metaflag boundaries.
#
# Arguments
# - fval: Normalized and type-validated input value.
# - fassoc: Name of the associative array containing the flag definition properties.
#
# Global outputs
# - SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE: Stores descriptive violation message on failure.
#
# Notes
# - Skips validation and returns 0 if '__cross_min_max=1' is already set in the flag definition.
# - Evaluates boundaries based on data type: numeric comparison for 'int'/'float', chronological epoch 
#   comparison for 'date'/'time'/'datetime', and length comparison for 'string' or other types.
# - Mutates the input associative array by setting '__cross_min_max=1' upon successful validation to cache results.
#
# Returns
# - 0: Success (boundaries are consistent or already validated).
# - 1: Failure ('min' boundary or length exceeds 'max').
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





# shell_cli_metaflag_property_cross_validate_min_array_max_array - Cross-validate 'min_array' and 'max_array' boundaries.
#
# Arguments
# - fval: Normalized and type-validated input value.
# - fassoc: Name of the associative array containing the flag definition properties.
#
# Global outputs
# - SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE: Stores descriptive violation message on failure.
#
# Notes
# - Skips validation and returns 0 if '__cross_min_array_max_array=1' is already set in the flag definition.
# - Enforcement only triggers when 'is_array' equals 1 and both boundaries are explicitly defined.
# - Mutates the input associative array by setting '__cross_min_array_max_array=1' upon success to cache results.
#
# Returns
# - 0: Success (boundaries are consistent, inapplicable, or already validated).
# - 1: Failure ('min_array' size boundary exceeds 'max_array').
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
