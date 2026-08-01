#!/usr/bin/env bash

declare -gA METAFLAG_required_keys=()
METAFLAG_required_keys["long"]="required_keys"
METAFLAG_required_keys["short"]=""
METAFLAG_required_keys["type"]="text"
METAFLAG_required_keys["accept_values"]=""

METAFLAG_required_keys["description"]="Pointer to array or a JSON-array string with the required 'keys'."
METAFLAG_required_keys["tipinput"]=""

METAFLAG_required_keys["default"]=""
METAFLAG_required_keys["required"]=false

METAFLAG_required_keys["normalize"]=""
METAFLAG_required_keys["min"]=""
METAFLAG_required_keys["max"]=""
METAFLAG_required_keys["regex"]=""
METAFLAG_required_keys["validate"]=""
METAFLAG_required_keys["transform"]=""

METAFLAG_required_keys["is_array"]=true
METAFLAG_required_keys["min_array"]=""
METAFLAG_required_keys["max_array"]=""

METAFLAG_required_keys["is_assoc"]=false
METAFLAG_required_keys["required_keys"]=""





# shell_cli_metaflag_property_validate_required_keys - validate metaflag 'required_keys'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'required_keys' property is only defined when 'is_assoc=true'.
# - If 'is_assoc=false' and 'required_keys' is set, validation fails.
# - If 'is_assoc=true' and 'required_keys' is set, verifies that the pointer
#   refers to an indexed array (declare -a).
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (property consistent with is_assoc and array type).
# - 1: validation failure (defined for non-assoc flag or not an indexed array).
shell_cli_metaflag_property_validate_required_keys() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["is_assoc"]}"

  if [ "${_assoc}" = "0" ]; then
    if [ "${fval}" != "" ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'required_keys' for a 'is_assoc=false' flag."
      return 1
    fi
  else
    if [ "${fval}" != "" ]; then
      if ! shell_cli_utils_array_is_indexed "${fval}"; then
        SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
        return 1
      fi
    fi
  fi

  return 0
}



# shell_cli_metaflag_check_input_required_keys - check input for metaflag 'required_keys'.
#
# Arguments:
# - inputVal: associative array name containing values provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (pointer to indexed array of required keys).
#
# Behavior:
# - Validates whether the input associative array contains all required keys.
# - If 'ruleVal=0' (false) or input is empty, no validation is applied.
# - Otherwise, dereferences both the associative array and the required keys array.
# - Iterates through the required keys:
#   * If a key is missing in the associative array, adds it to a list of lost keys.
# - If any required keys are missing, validation fails:
#   * Stores an error message listing the missing keys in
#     'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'.
#   * Returns error code 1.
# - On success, the input associative array is accepted unchanged.
#
# Returns:
# - 0: validation success (all required keys present or rule not enforced).
# - 1: validation failure (one or more required keys missing).
shell_cli_metaflag_check_input_required_keys() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    return 0
  fi

  local -n inputAssocValues="${inputVal}"
  local -n requiredKeys="${ruleVal}"
  local -a lostAssocKeys=()

  local k=""
  for k in "${requiredKeys[@]}"; do
    if [[ -v "${inputAssocValues[${k}]}" ]]; then
      continue
    fi
    lostAssocKeys+=("${k}")
  done

  if [ "${#lostAssocKeys[@]}" != "0" ]; then
    local lostKeys=""
    printf -v lostKeys "%s, " "${lostAssocKeys[@]}"
    lostKeys="${lostKeys%, }"

    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="missing keys '${lostKeys}'"
    return 1
  fi

  return 0
}
