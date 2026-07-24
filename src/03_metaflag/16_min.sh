#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/16_min.sh
# DESCRIPTION: enforces the minimum boundary size constraint allowed for the 
#   payload. Evaluates string/token length or raw numerical boundaries based on 
#   the primary type field.
# ==============================================================================

declare -gA METAFLAG_min=()
METAFLAG_min["long"]="min"
METAFLAG_min["short"]=""
METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""
METAFLAG_min["type"]="string"
METAFLAG_min["enum"]=""

METAFLAG_min["required"]=false
METAFLAG_min["default"]=""

METAFLAG_min["array"]=false
METAFLAG_min["assoc"]=false
METAFLAG_min["assoc_keys"]=""

METAFLAG_min["normalize"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""
METAFLAG_min["regex"]=""

METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""



# shell_cli_metaflag_property_validate_min metaflag 'min'.
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
shell_cli_metaflag_property_validate_min() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
  
  if ! shell_cli_metaflag_property_cross_validate_min_max "$1" "$2"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_min checks whether the input flag 
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
shell_cli_metaflag_check_input_min() {
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
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '"${typeVal}"'; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;

    float)
      if ! shell_cli_utils_math_is_greater_or_equal "$inputVal" "${ruleVal}" "0"; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '"${typeVal}"'; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;

    date|time|datetime)
      # Chronological epoch timestamp processing alignment via system tools
      local valTS=$(date -d "$inputVal" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$inputVal" +%s 2>/dev/null)
      local minTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)

      if [ "$valTS" -lt "$minTS" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates minimum allowed '"${typeVal}"'; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;
    
    *)
      if [ "${#inputVal}" -lt "${ruleVal}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="character length is lower than required; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;
  esac

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
  return 0
}
