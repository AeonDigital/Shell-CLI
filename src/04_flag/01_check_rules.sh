#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_flag/01_check_rules.sh
# DESCRIPTION: 
# ==============================================================================

# Stores the last error message generated from the last 
# execution of 'shell_cli_flag_check_rules' function.
declare -g SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE=""


# shell_cli_flag_check_rules normalize, validate and asserts all flag specifications.
#
# Arguments:
# - fassoc: name of associative array with all flag definitions.
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
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="${errPrefix} :: invalid flag definition '$assocName'; must be an associative array (declare -A)."
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
