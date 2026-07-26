#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/11_max.sh
# DESCRIPTION: enforces the maximum boundary size constraint allowed for the 
#   payload. Evaluates value based on the primary type field.
# ==============================================================================

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





# shell_cli_metaflag_property_validate_max — validate metaflag 'max'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'max' property is consistent with the paired 'min' property.
# - Delegates validation to 'shell_cli_metaflag_property_cross_validate_min_max',
#   which checks logical consistency between minimum and maximum boundaries.
# - Clears any previous error message before validation.
# - On failure, stores the error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (min/max boundaries consistent).
# - 1: validation failure (cross-validation failed).
shell_cli_metaflag_property_validate_max() {
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if ! shell_cli_metaflag_property_cross_validate_min_max "${1}" "${2}"; then
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_max — check input for metaflag 'max'.
#
# Arguments:
# - inputVal: value provided by user input (normalized and validated by type).
# - typeVal: type of value (e.g., int, float, date, time, datetime, string).
# - ruleVal: current value of this property (maximum boundary).
#
# Behavior:
# - Validates whether the input respects the maximum boundary defined by 'ruleVal'.
# - If 'ruleVal' is empty, no validation is applied.
# - Type-specific checks:
#   * int: input must be ≤ max.
#   * float: input must be ≤ max (using math utility for precision).
#   * date/time/datetime: input timestamp must be ≤ max timestamp.
#   * string/other: input length must be ≤ max.
# - On violation, stores an error message in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
# - On success, stores the validated input in
#   'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'.
#
# Returns:
# - 0: validation success (input meets maximum boundary).
# - 1: validation failure (input exceeds maximum boundary).
shell_cli_metaflag_check_input_max() {
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
