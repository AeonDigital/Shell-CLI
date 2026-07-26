#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/19_required_keys.sh
# DESCRIPTION: specifies a list of keys that MUST be present in the passed 
#   value. Use only if is_assoc=true.
# ==============================================================================

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





# shell_cli_metaflag_property_validate_required_keys metaflag 'required_keys'.
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
shell_cli_metaflag_property_validate_required_keys() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _assoc="${__assoc["is_assoc"]}"

  if [ "$_assoc" = "0" ]; then
    if [ "$fval" != "" ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'required_keys' for a 'is_assoc=false' flag."
      return 1
    fi
  else
    if [ "$fval" != "" ]; then
      if ! shell_cli_utils_array_is_indexed "$fval"; then
        SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an indexed array (declare -a)."
        return 1
      fi
    fi
  fi

  return 0
}



# shell_cli_metaflag_check_input_required_keys checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: assoc name with values inputed.
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
shell_cli_metaflag_check_input_required_keys() {
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "$inputVal" = "" ] || [ "$ruleVal" = "" ]; then
    return 0
  fi

  local -n inputAssocValues="${inputVal}"
  local -n requiredKeys="${ruleVal}"
  local -a lostAssocKeys=()

  local k=""
  for k in "${requiredKeys[@]}"; do
    if [[ -v "${inputAssocValues[$k]}" ]]; then
      continue
    fi
    lostAssocKeys+=("$k")
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
