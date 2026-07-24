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
#
# Returns:
# - 0: valid value.
# - 1: invalid value.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE'
shell_cli_flag_check_value() {
  local rawValue="$1"
  local flagVarName="$2"
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
  local singleValue="1"
  local arrayKeyType=""

  local errPrefix="[ x ][ --${flagLong} ]"

  local -a flagKeys=()
  local -a flagValues=()



  #
  # Check Required
  shell_cli_metaflag_check_input_required "${rawValue}" "${flagType}" "${flagAssocDefinition["required"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  else
    rawValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi


  #
  # Check Default
  shell_cli_metaflag_check_input_default "${rawValue}" "${flagType}" "${flagAssocDefinition["default"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  else
    rawValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi


  #
  # Check Array
  shell_cli_metaflag_check_input_array "${rawValue}" "${flagType}" "${flagAssocDefinition["array"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  else
    shell_cli_metaflag_check_input_min_array "${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY}" "${flagAssocDefinition["min_array"]}"
    if [ "$?" != "0" ]; then
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
      return 1
    fi
    
    shell_cli_metaflag_check_input_max_array "${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY}" "${flagAssocDefinition["max_array"]}"
    if [ "$?" != "0" ]; then
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
      return 1
    fi


    rawValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
    singleValue="0"
    arrayKeyType="idx"

    local k=""
    local v=""
    for k in "${!SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY[@]}"; do
      v="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY[$k]}"
      flagKeys+=("$k")
      flagValues+=("$v")
    done
  fi


  #
  # Check Assoc
  shell_cli_metaflag_check_input_assoc "${rawValue}" "${flagType}" "${flagAssocDefinition["assoc"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  else
    #
    # Check Assoc Keys
    shell_cli_metaflag_check_input_assoc_keys "SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC" "${flagAssocDefinition["assoc_keys"]}"
    if [ "$?" != "0" ]; then
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
      return 1
    fi


    rawValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
    singleValue="0"
    arrayKeyType="key"

    local k=""
    local v=""
    for k in "${!SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC[@]}"; do
      v="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC[$k]}"
      flagKeys+=("$k")
      flagValues+=("$v")
    done
  fi


  #
  # If is a single value
  if [ "${singleValue}" = "1" ]; then
    flagKeys+=("-")
    flagValues+=("$rawValue")
  fi


  #
  # Check each value atomically
  local i=""
  local k=""
  local v=""
  for i in "${!flagValues[@]}"; do
    k="${flagKeys[$i]}"
    v="${flagValues[$i]}"

    shell_cli_flag_check_single_value "$v" "${flagVarName}"
    if [ "$?" != 0 ]; then
      if [ "$singleValue" = "0" ]; then
        errPrefix+="[ ${arrayKeyType}: $k ]"
      fi
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE}"
      return 1
    fi
  done

  return 0
}





# shell_cli_flag_check_value normalize, validate and asserts a given value 
# against your flag rule definitions.
#
# Arguments:
# - rawValue: single raw flag value (array/assoc not allowed).
# - flagVarName: name of the associative array with the flag rules.
#
# Returns:
# - 0: valid value.
# - 1: invalid value.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE'
shell_cli_flag_check_single_value() {
  local rawValue="$1"
  local norValue="$1"
  local flagVarName="$2"
  SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE=""

  local -n flagAssocDefinition="${flagVarName}"
  local flagType="${flagAssocDefinition["type"]}"

  # @TODO  NORMALIZE; VALIDATE AND TRANSFORM VALUES
  #
  # Only normalize and validate by type if raw value is not empty
  if [ "${rawValue}" != "" ]; then
    local normalizeByTypeFN="shell_cli_type_normalize_${flagType}"
    local validateByTypeFN="shell_cli_type_validate_${flagType}"
    local valStatus="0"

    norValue=$("${normalizeByTypeFN}" "${rawValue}")
    valStatus=$("${validateByTypeFN}" "$norValue"; echo $?)

    if [ "${valStatus}" != 0 ]; then
      SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="not a valid '${flagType}' type; ( value: '${rawValue}' )"
      if [ "${valStatus}" = "10" ]; then
        SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE+=" (remove control characters)"
      fi
      return "$valStatus"
    fi
  fi


  #
  # Check Enum
  shell_cli_metaflag_check_input_enum "${norValue}" "${flagType}" "${flagAssocDefinition["enum"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
  else
    norValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi


  #
  # Check Regex
  shell_cli_metaflag_check_input_regex "${norValue}" "${flagType}" "${flagAssocDefinition["regex"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
  else
    norValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi


  #
  # Check Min
  shell_cli_metaflag_check_input_min "${norValue}" "${flagType}" "${flagAssocDefinition["min"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
  else
    norValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi


  #
  # Check Max
  shell_cli_metaflag_check_input_max "${norValue}" "${flagType}" "${flagAssocDefinition["max"]}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_FLAG_CHECK_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
  else
    norValue="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
  fi

  return 0
}

