#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/17_max.sh
# DESCRIPTION: enforces the maximum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_max=()
METAFLAG_max["long"]="max"
METAFLAG_max["short"]=""
METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""
METAFLAG_max["type"]="string"
METAFLAG_max["enum"]=""

METAFLAG_max["required"]=false
METAFLAG_max["default"]=""

METAFLAG_max["array"]=false
METAFLAG_max["assoc"]=false
METAFLAG_max["assoc_keys"]=""

METAFLAG_max["normalize"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""
METAFLAG_max["regex"]=""

METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""



# shell_cli_metaflag_property_validate_max metaflag 'max'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_property_validate_max() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if ! shell_cli_metaflag_property_cross_validate_min_max "$1" "$2"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_max checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed (normalizated and validate by type).
# - typeVal: type of value.
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      The new value after check will be stored in
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_max() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    return 0
  fi

  case "${typeVal}" in
    int)
      if [ "$inputVal" -lt "${ruleVal}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '"${typeVal}"'; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;

    float)
      if ! shell_cli_utils_math_is_less_or_equal "$inputVal" "${ruleVal}" "0"; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '"${typeVal}"'; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;

    date|time|datetime)
      # Chronological epoch timestamp processing alignment via system tools
      local valTS=$(date -d "$inputVal" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$inputVal" +%s 2>/dev/null)
      local maxTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)

      if [ "$valTS" -gt "$maxTS" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates maximum allowed '"${typeVal}"'; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;
    
    *)
      if [ "${#inputVal}" -gt "${ruleVal}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="character length is lower than required; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;
  esac

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
