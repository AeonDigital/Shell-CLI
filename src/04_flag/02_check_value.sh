#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/02_check_value.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_flag_check_value normalize, validate and asserts a given value 
# against your flag rule definitions.
#
# Arguments:
# - rawValue: raw flag value.
# - flagVarName: name of the associative array with the flag rules.
# - contextIndex: optional indexed array position of the value.
# - contextKey: optional associative array key of the value.
#
# Returns:
# - 0: valid value.
# - 1: invalid value.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE'
shell_cli_flag_check_value() {
  local rawValue="$1"
  local norValue=""
  local flagVarName="$2"
  local contextIndex="$3"
  local contextKey="$4"
  SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE=""



  #
  # Check flag rules consistency
  shell_cli_flag_check_rules "${flagVarName}"
  local checkFlagStatus="$?"
  if [ "${checkFlagStatus}" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_FLAG_CHECK_RULE_ERR_MESSAGE}"
    return "${checkFlagStatus}"
  fi



  #
  # Loads flag definition
  local -n flagAssocDefinition="${flagVarName}"
  local flagLong="${flagAssocDefinition["long"]}"
  local flagType="${flagAssocDefinition["type"]}"
  local flagEnum="${flagAssocDefinition["enum"]}"
  local flagRequired="${flagAssocDefinition["required"]}"
  local flagDefault="${flagAssocDefinition["default"]}"
  local flagArray="${flagAssocDefinition["array"]}"
  local flagAssoc="${flagAssocDefinition["assoc"]}"
  local flagAssocKeys="${flagAssocDefinition["assoc_keys"]}"
  local flagNormalize="${flagAssocDefinition["normalize"]}"
  local flagValidate="${flagAssocDefinition["validate"]}"
  local flagTransform="${flagAssocDefinition["transform"]}"
  local flagRegex="${flagAssocDefinition["regex"]}"
  local flagMin="${flagAssocDefinition["min"]}"
  local flagMax="${flagAssocDefinition["max"]}"
  local flagMinArray="${flagAssocDefinition["min_array"]}"
  local flagMaxArray="${flagAssocDefinition["max_array"]}"


  local errPrefix="[ x ][ --${flagLong} ]"
  if [ "${contextIndex}" != "" ]; then
    errPrefix+="[ index: ${contextIndex} ]"
  fi
  if [ "${contextKey}" != "" ]; then
    errPrefix+="[ key: ${contextKey} ]"
  fi


  #
  # Only check type if raw value is not empty
  local checkType="0"
  if [ "${rawValue}" != "" ]; then
    checkType="1"
  fi
  #
  # If enum, no normalize, validate or check type.
  if [ "$flagType" = "enum" ]; then
    checkType="0"
    norValue="${rawValue}"
  fi
  #
  # checks whether the specified value is acceptable like the expected type
  if [ "${checkType}" = "1" ]; then
    local normalizeByTypeFN="shell_cli_type_normalize_${flagType}"
    local validateByTypeFN="shell_cli_type_validate_${flagType}"
    local validateStatus="0"

    norValue=$("${normalizeByTypeFN}" "${rawValue}")
    validateStatus=$("${validateByTypeFN}" "$norValue"; echo $?)

    if [ "${validateStatus}" != 0 ]; then
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: not a valid '${flagType}' type; value='${rawValue}'"
      if [ "${validateStatus}" = "10" ]; then
        SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE+=" (remove control characters)"
      fi
      return "$validateStatus"
    fi
  fi



  #
  # Required
  if [ "$value" = "" ] && [ "${flagRequired}" = "1" ]; then
    VALIDATION_ERROR_MSG="${errPrefix} :: cannot be empty or omitted."
  fi
  #
  # Default
  if [ "$value" = "" ] && [ "${flagDefault}" != "" ]; then
    value="${flagDefault}"
  fi


  return 0
}
