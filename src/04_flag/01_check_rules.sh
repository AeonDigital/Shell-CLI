#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/01_check_rules.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the last error message generated from the last 
# execution of 'shell_cli_flag_check_rules' function.
declare -g SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE=""


# Stores the name of each flag family that has been fully validated.
declare -A SHELL_CLI_FLAG_CHECKED_FAMILY=()



# shell_cli_flag_check_rules normalize, validate and asserts all flag properties
# specifications.
#
# Arguments:
# - assocName: name of the associative array representing the flag to be checked.
#
# Returns:
# - 0: if all flag properties are valid.
# - 1: if any flag property are invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE'
shell_cli_flag_check_rules() {
  local assocName="$1"
  local errPrefix="[ERR][ ${assocName} ]"
  SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE=""

  local str_declare=$(declare -p "$assocName" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="${errPrefix} :: invalid definition '$assocName'; must be an associative array (declare -A)."
    return 1
  fi


  #
  # Loads the flag's associative array and checks if it has already been validated.
  local -n flagAssoc="${assocName}"
  if [ "${flagAssoc["__checked"]}" = "1" ]; then
    return 0
  fi



  #
  # defines all keys that have not yet been defined using the default values
  local fpropName=""
  local fpropValue=""
  local fpropDefault=""

  for fpropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    fpropValue="${flagAssoc["${fpropName}"]}"
    
    fpropDefault="${SHELL_CLI_METAFLAG_DEFAULT["${fpropName}"]}"
    if [ "${fpropValue}" = "" ] && [ "${fpropDefault}" != "" ]; then
      flagAssoc["${fpropName}"]="$fpropDefault"
    fi
  done



  #
  # Normalize and validate raw values of each property in the given flag
  for fpropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    fpropValue="${flagAssoc["${fpropName}"]}"
    local finalPropValue="${fpropValue}"
    
    local -n metaFlag="METAFLAG_${fpropName}"


    #
    # checks whether the specified value is acceptable as a possible 
    # value for the current property
    if [ "${fpropValue}" != "" ]; then
      local metaFlagType="${metaFlag["type"]}"

      local propNormalizeFN="shell_cli_type_normalize_${metaFlagType}"
      local propValidateFN="shell_cli_type_validate_${metaFlagType}"
      local propNormalizatedValue=""
      local propValidateStatus=""

      if [ "$metaFlagType" = "enum" ]; then
        propNormalizatedValue=$("${propNormalizeFN}" "${metaFlag["enum"]}")
        propValidateStatus=$("${propValidateFN}" "${fpropValue}" "$propNormalizatedValue"; echo $?)
        propNormalizatedValue="${fpropValue}"
      else
        if [ "$metaFlagType" = "string" ]; then
          local fpropNormalizeStringRules="${SHELL_CLI_METAFLAG_PREPARE_STRING_VALUE["${fpropName}"]}"
          local fpropValidateStringRules="${fpropNormalizeStringRules/_trim/}"

          propNormalizeFN+="_${fpropNormalizeStringRules}"
          propValidateFN+="_${fpropValidateStringRules}"
        fi

        propNormalizatedValue=$("${propNormalizeFN}" "${fpropValue}")
        propValidateStatus=$("${propValidateFN}" "$propNormalizatedValue"; echo $?)
      fi


      if [ "${propValidateStatus}" != 0 ]; then
        SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="${errPrefix}[ prop: ${metaFlagType} ] :: invalid property '${fpropName}'; value='${propNormalizatedValue}'"
        if [ "${propValidateStatus}" = "10" ]; then
          SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE+=" (remove control characters)"
        fi
        return "$propValidateStatus"
      fi

      finalPropValue="$propNormalizatedValue"
    fi


    flagAssoc["${fpropName}"]="$finalPropValue"
    unset -n metaFlag
  done



  #
  # Validates the value against the flag's specific rules and in 
  # relation to its other properties.
  for fpropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    fpropValue="${flagAssoc["${fpropName}"]}"

    local metaflagValidateFN="shell_cli_metaflag_validate_${fpropName}"
    local metaFlagValidateStatus=""

    "$metaflagValidateFN" "$fpropValue" "$assocName"
    metaFlagValidateStatus="$?"
    if [ "${metaFlagValidateStatus}" != "0" ]; then
      SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="${errPrefix}[ prop: ${fpropName} ] :: ${SHELL_CLI_METAFLAG_VALIDATE_ERR_MESSAGE}"
      return "$metaFlagValidateStatus"
    fi
  done


  flagAssoc["__checked"]="1"
  return 0
}



# shell_cli_flag_check_flagfamily_rules normalizes, validates, and asserts all flag specifications
# for the entire specified family.
#
# Arguments:
# - flagFamily: name (prefix) of the flag definitions to be checked.
# - flagOrderArray: name of the indexed array that orders this family flag.
#
# Returns:
# - 0: if all flag properties of the entire family are valid.
# - 1: if any flag property are invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE'
shell_cli_flag_check_flagfamily_rules() {
  local flagFamily="$1"
  local flagOrderArray="$2"


  if [ "${SHELL_CLI_FLAG_CHECKED_FAMILY["$flagFamily"]}" = "1" ]; then
    return 0
  fi



  if [ "${flagFamily}" = "" ]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="[ERR] :: Flag family name is required."
    return 1
  fi

  if [ "${flagOrderArray}" = "" ]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="[ERR] :: Default order array is required."
    return 1
  fi

  local str_declare=$(declare -p "$flagOrderArray" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="[ERR] :: Invalid default order array '$flagOrderArray'. Expected indexed array (declare -a)."
    return 1
  fi


  #
  # Loads the flag's associative array and checks if it has already been validated.
  local -n arrayOrder="${flagOrderArray}"
  if [ "${#arrayOrder[@]}" = "0" ]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="[ERR] :: invalid order definition '$flagOrderArray'; empty array."
    return 1
  fi

  #
  # Get entire assoc flag definition for this family and chek if all exists
  local -a flagAssocNames=()
  local flagName=""
  for flagName in "${arrayOrder[@]}"; do
    flagName="${flagFamily}_${flagName}"

    local str_declare=$(declare -p "$flagName" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="[ERR] :: Invalid or undefined assoc flag '$flagName'. Expected associative array (declare -A)."
      return 1
    fi

    flagAssocNames+=("${flagName}")
  done



  #
  # check all flags
  local checkStatus="0"
  for flagName in "${flagAssocNames[@]}"; do
    shell_cli_flag_check_rules "${flagName}"
    checkStatus=$?

    if [ "$checkStatus" != "0" ]; then
      return $checkStatus
    fi
  done


  SHELL_CLI_FLAG_CHECKED_FAMILY["$flagFamily"]="1"
  return 0
}