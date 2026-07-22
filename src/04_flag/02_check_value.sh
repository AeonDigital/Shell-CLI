#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/02_check_value.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the last error message generated from the last 
# execution of 'shell_cli_flag_check_value' function.
declare -g SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE=""



# shell_cli_flag_check_value normalize, validate and asserts a given value 
# against your flag rule definitions
#
# Arguments:
# - value: raw flag value.
# - assocName: name of the associative array with the flag rules.
# - contextIndex: optional indexed array position of the value.
# - contextKey: optional associative array key of the value.
#
# Returns:
# - 0: if value are valid against flag rules
# - 1: if any flag rule is violated by this value
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE'
shell_cli_flag_check_value() {
  local value="$1"
  local assocName="$2"
  local contextIndex="$3"
  local contextKey="$4"
  SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE=""



  #
  # Check flag rules consistency
  shell_cli_flag_check_rules "${assocName}"
  local checkFlagStatus="$?"
  if [ "${checkFlagStatus}" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE}"
    return "${checkFlagStatus}"
  fi



  #
  # Loads the flag definition
  local -n flagAssocDefinition="${assocName}"
  local flagLong="${flagAssocDefinition["long"]}"
  local flatType="${flagAssocDefinition["type"]}"

  local errPrefix="[ERR][ --${flagLong} ]"
  if [ "${contextIndex}" != "" ]; then
    errPrefix+="[ index: ${contextIndex} ]"
  fi
  if [ "${contextKey}" != "" ]; then
    errPrefix+="[ key: ${contextKey} ]"
  fi



  # #
  # #
  # local normalizeByTypeFN="shell_cli_type_normalize_${flatType}"
  # local validateByTypeFN="shell_cli_type_validate_${flatType}"
  # local normalizatedValue=""
  # local validateStatus=""

  # if [ "$flatType" = "enum" ]; then
  #   normalizatedValue=$("${normalizeByTypeFN}" "${flagAssocDefinition["enum"]}")
  #   validateStatus=$("${validateByTypeFN}" "${value}" "$normalizatedValue"; echo $?)
  #   normalizatedValue="${value}"
  # else

  #   normalizatedValue=$("${normalizeByTypeFN}" "${value}")
  #   validateStatus=$("${validateByTypeFN}" "$normalizatedValue"; echo $?)
  # fi


  # if [ "${validateStatus}" != 0 ]; then
  #   SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="${errPrefix}[ prop: ${flatType} ] :: invalid property '${fpropName}'; value='${normalizatedValue}'"
  #   if [ "${validateStatus}" = "10" ]; then
  #     SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE+=" (remove control characters)"
  #   fi
  #   return "$validateStatus"
  # fi

  # finalPropValue="$normalizatedValue"




  return 0
}
