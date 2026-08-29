#!/usr/bin/env bash

# 
# METAFLAG 'max'  
# Canonical definition scheme for this flag.
declare -gA METAFLAG_max=()
METAFLAG_max["long"]="max"
METAFLAG_max["short"]=""
METAFLAG_max["type"]="string"
METAFLAG_max["accept_values"]=""

METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""

METAFLAG_max["default"]=""
METAFLAG_max["required"]=false

METAFLAG_max["normalize"]=""
METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["regex"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""

METAFLAG_max["is_array"]=false
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""

METAFLAG_max["is_assoc"]=false
METAFLAG_max["required_keys"]=""





# shell_cli_metaflag_property_validate_max — validate structural integrity of this
# metaflag.
# 
# Arguments
# - fval: value (normalized and validated by type).
# - fassoc: Name of the associative array with flag definition.
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_max() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if ! shell_cli_metaflag_property_cross_validate_min_max "${1}" "${2}"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_max — runtime input check placeholder for this metaflag.
# 
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
# 
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_max() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  case "${typeVal}" in
    int)
      if [ "${inputVal}" -lt "${ruleVal}" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;

    float)
      if ! shell_cli_utils_math_is_less_or_equal "${inputVal}" "${ruleVal}" "0"; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
        return 1
      fi
      ;;

    date|time|datetime)
      # Chronological epoch timestamp processing alignment via system tools
      local valTS=$(date -d "${inputVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${inputVal}" +%s 2>/dev/null)
      local maxTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)

      if [ "$valTS" -gt "$maxTS" ]; then
        SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
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
