#!/usr/bin/env bash

#
# METAFLAG 'min'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_min=()
METAFLAG_min["long"]="min"
METAFLAG_min["short"]=""
METAFLAG_min["type"]="string"
METAFLAG_min["accept_values"]=""

METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""

METAFLAG_min["default"]=""
METAFLAG_min["required"]=false

METAFLAG_min["normalize"]=""
METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["regex"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""

METAFLAG_min["is_array"]=false
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""

METAFLAG_min["is_assoc"]=false
METAFLAG_min["required_keys"]=""





# shell_cli_metaflag_property_validate_min - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_min() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
  
  if ! shell_cli_metaflag_property_cross_validate_min_max "${1}" "${2}"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_min - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_min() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    return 0
  fi

  case "${typeVal}" in
    int)
      if [ "${inputVal}" -lt "${ruleVal}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;

    float)
      if ! shell_cli_utils_math_is_greater_or_equal "${inputVal}" "${ruleVal}" "0"; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
        return 1
      fi
      ;;

    date|time|datetime)
      # Chronological epoch timestamp processing alignment via system tools
      local valTS=$(date -d "${inputVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${inputVal}" +%s 2>/dev/null)
      local minTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)

      if [ "${valTS}" -lt "${minTS}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
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
