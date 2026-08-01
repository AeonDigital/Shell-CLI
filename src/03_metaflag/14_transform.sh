#!/usr/bin/env bash

#
# METAFLAG 'transform'
# Canonical definition scheme for this flag.
declare -gA METAFLAG_transform=()
METAFLAG_transform["long"]="transform"
METAFLAG_transform["short"]=""
METAFLAG_transform["type"]="function"
METAFLAG_transform["accept_values"]=""

METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""

METAFLAG_transform["default"]=""
METAFLAG_transform["required"]=false

METAFLAG_transform["normalize"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""

METAFLAG_transform["is_array"]=true
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""

METAFLAG_transform["is_assoc"]=false
METAFLAG_transform["required_keys"]=""





# shell_cli_metaflag_property_validate_transform - validate structural integrity of this metaflag.
#
# Arguments
# - fval: value (normalized and validated by type). 
# - fassoc: Name of the associative array with flag definition.
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_property_validate_transform() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    return 0
  fi

  if ! shell_cli_utils_array_is_indexed "${fval}"; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
    return 1
  fi

  local -n ref_transform="${fval}"
  local fn_transform=""
  for fn_transform in "${ref_transform[@]}"; do
    if ! declare -f "$fn_transform" >/dev/null; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="transform function does not exist ( fn='${fn_transform}' )."
      return 1
    fi
  done

  return 0
}



# shell_cli_metaflag_check_input_transform - runtime input check placeholder for this metaflag.
#
# Arguments
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Returns
# - 0: Success.
# - 1: Failure.
shell_cli_metaflag_check_input_transform() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "${ruleVal}" = "" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  local currentVal="${inputVal}"
  local -n ref_transform="${ruleVal}"
  local fn_transform=""
  for fn_transform in "${ref_transform[@]}"; do
    local newVal="$("${fn_transform}" "${currentVal}")"
    local exitCode=$?

    if [ ${exitCode} -ne 0 ]; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="transformation failed in function '${fn_transform}' ( value='${currentVal}' )."
      return 1
    fi

    currentVal="${newVal}"
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${currentVal}"
  return 0
}
