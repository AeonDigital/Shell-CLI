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
  SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE=""

  local str_declare=$(declare -p "$assocName" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
    SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="invalid flag definition '$assocName'; must be an associative array (declare -A)."
    return 1
  fi



  local -n flagAssoc="${assocName}"
  local fpropName=""
  local fpropValue=""

  # defines all keys that have not yet been defined using the default values
  for fpropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    fpropValue="${flagAssoc["${fpropName}"]}"
    
    if [ "${fpropValue}" = "" ]; then
      flagAssoc["${fpropName}"]="${SHELL_CLI_METAFLAG_DEFAULT["${fpropName}"]}"
    fi
  done



  local fpropNormalizeFN=""
  local fpropValidateFN=""

  local fpropNormalizeStringRules=""  
  local fpropValidateStringRules=""

  local fpropNormalizatedValue=""
  local fpropValidateStatus=""


  for fpropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    fpropValue="${flagAssoc["${fpropName}"]}"
    
    local -n metaFlag="METAFLAG_${fpropName}"
    local metaFlagType="${metaFlag["type"]}"

    fpropNormalizeFN="shell_cli_type_normalize_${metaFlagType}"
    fpropValidateFN="shell_cli_type_validate_${metaFlagType}"

    if [ "$metaFlagType" = "string" ]; then
      fpropNormalizeStringRules="${SHELL_CLI_METAFLAG_NORMALIZE_STRING_TYPE["${fpropName}"]}"
      fpropValidateStringRules="${fpropNormalizeStringRules/_trim/}"

      fpropNormalizeFN+="_${fpropNormalizeStringRules}"
      fpropValidateFN+="_${fpropValidateStringRules}"
    fi

    fpropNormalizatedValue=$("${fpropNormalizeFN}" "${fpropValue}")
    fpropValidateStatus=$("${fpropValidateFN}" "$fpropNormalizatedValue"; echo $?)
    if [ "${fpropValidateStatus}" != 0 ]; then
      SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE="invalid flag '${fpropName}'; given '${fpropNormalizatedValue}'"
      if [ "${fpropValidateStatus}" = "10" ]; then
        SHELL_CLI_FLAG_CHECK_RULES_ERR_MESSAGE+=" (remove control characters)"
      fi
      return "$fpropValidateStatus"
    fi
  done

  return 0
}
