#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/00_cross_validate.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_metaflag_property_cross_validate_min_max metaflag 'min' and 'max'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Note:
# If validation is successful, it adds a '__cross_min_max' key indicating that 
# this validation has already been performed.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
shell_cli_metaflag_property_cross_validate_min_max() {
  local fassoc="$2"
  local -n __assoc="${fassoc}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${__assoc["__cross_min_max"]}" == "1" ]; then
    return 0
  fi

  local _min="${__assoc["min"]}"
  local _max="${__assoc["max"]}"

  if [ "$_min" != "" ] && [ "$_max" != "" ]; then
    local _type="${__assoc["type"]}"

    case "$_type" in
      int)
        if (( $_min > $_max )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='$_min', max='$_max' )."
          return 1
        fi
        ;;
        
      float)
        if ! shell_cli_utils_math_is_less_or_equal "$_min" "$_max" "0"; then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='$_min', max='$_max' )."
          return 1
        fi
        ;;

      time|date|datetime)
        local prefix=""
        local fmt="%Y-%m-%d %H:%M:%S"
        
        if [ "$_type" = "date" ]; then
          fmt="%Y-%m-%d"
        elif [ "$_type" = "time" ]; then
          prefix="0001-01-01 "
        fi

        local min_sec=$(date -d "${prefix}${_min}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${_min}" +%s 2>/dev/null)
        local max_sec=$(date -d "${prefix}${_max}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${_max}" +%s 2>/dev/null)

        if (( $min_sec > $max_sec )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='$_min', max='$_max' )."
          return 1
        fi
        ;;
        
      *)
        if (( $_min > $_max )); then
          SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' length cannot exceed 'max' ( min='$_min', max='$_max' )."
          return 1
        fi
        ;;
    esac
  fi

  __assoc["__cross_min_max"]="1"
  return 0
}

# shell_cli_metaflag_property_cross_validate_min_array_max_array metaflag 'min_array' and 'max_array'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Note:
# If validation is successful, it adds a '__cross_min_array_max_array' key indicating that 
# this validation has already been performed.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
shell_cli_metaflag_property_cross_validate_min_array_max_array() {
  local fassoc="$2"
  local -n __assoc="${fassoc}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${__assoc["__cross_min_array_max_array"]}" == "1" ]; then
    return 0
  fi

  local _array="${__assoc["array"]}"
  local _min_array="${__assoc["min_array"]}"
  local _max_array="${__assoc["max_array"]}"

  if [ "${_array}" = "1" ] && [ "$_min_array" != "" ] && [ "$_max_array" != "" ]; then
    if (( $_min_array > $_max_array )); then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min_array' limit cannot exceed 'max_array' ( min_array='$_min_array', max_array='$_max_array' )."
      return 1
    fi
  fi

  __assoc["__cross_min_array_max_array"]="1"
  return 0
}
