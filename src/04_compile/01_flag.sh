#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 04_compile/01_flagsh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_compile_flag compiles the raw properties of the provided flag. This 
# process normalizes values ​​by type and validates them against each property's 
# rules.
#
# The validations performed here are "low-level—meaning" they merely verify 
# whether the received values ​​are valid representations for the respective 
# properties, without checking for violations of advanced rules such as 
# "min/max" constraints or "regex" patterns.
#
# Any error at this stage must completely halt the CLI's execution.
#
# Certain types, such as 'bool', 'array', and 'assoc', can be substituted 
# according to their 'normalization' specifications.
# In the case of 'bool', they can accept 'true' or 'false', but normalization 
# converts them to '1' or '0'. As for 'array' and 'assoc', if defined as a valid 
# string, they are replaced by the name of an array of the corresponding type 
# containing the provided values.
#
# Upon successful completion, the compiled flag's associative array is assigned 
# the key "__checked" with the value "1" to prevent it from being reprocessed 
# during the same session.
#
# Arguments:
# - flagVarName: name of the associative array representing the flag to be checked.
#
# Returns:
# - 0: If the flag can be compiled correctly.
# - 1: In the event of any compilation error.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE'
shell_cli_compile_flag() {
  local flagVarName="$1"
  local errPrefix="[ERR][ ${flagVarName} ]"
  SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""


  if ! shell_cli_utils_array_is_assoc "$flagVarName"; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: invalid definition; must be an associative array (declare -A)."
    return 1
  fi


  #
  # Loads the flag's associative array and checks if it has already been validated.
  local -n flagAssocDefinition="${flagVarName}"
  if [ "${flagAssocDefinition["__checked"]}" = "1" ]; then
    return 0
  fi


  # ----  ---- -------- ----  ---- -------- ----  ----
  # initiates normalization of flag properties
  # ----  ---- -------- ----  ---- -------- ----  ----


  #
  # STEP 01:
  # Defines all keys that are not present in the passed associative array 
  # and populates them with their default values.
  local flagPropName=""
  local flagPropValue=""
  local flagPropDefault=""

  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"
    
    flagPropDefault="${SHELL_CLI_METAFLAG_DEFAULT["${flagPropName}"]}"
    if [ "${flagPropValue}" = "" ] && [ "${flagPropDefault}" != "" ]; then
      flagAssocDefinition["${flagPropName}"]="$flagPropDefault"
    fi
  done



  #
  # STEP 2
  # For each property with a defined value (i.e., not empty), it invokes the normalizer and 
  # validator for the corresponding type, ensuring that the defined value is a valid 
  # representative of that expected type.
  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"

    if [ "${flagPropValue}" != "" ]; then
      local -n metaFlag="METAFLAG_${flagPropName}"
      local metaFlagType="${metaFlag["type"]}"


      #
      # Normalize raw value; 
      local flagTypeNormalizeFN="shell_cli_type_normalize_${metaFlagType}"
      flagPropValue=$("${flagTypeNormalizeFN}" "$flagPropValue")


      #
      # Validate value after normalization
      local flagTypeValidateFN="shell_cli_type_validate_${metaFlagType}"
      local validateStatus=$("${flagTypeValidateFN}" "$flagPropValue"; echo $?)
      if [ "$validateStatus" != "0" ]; then
        errPrefix+="[ prop: ${flagPropName} ]"
        SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: not a valid '${metaFlagType}' type; ( value: '${flagPropValue}' )"

        if [ "${validateStatus}" = "10" ]; then
          SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE+="; ( remove control characters )"
        fi

        return "$validateStatus"
      fi


      #
      # Normalize array or assoc values
      local metaFlagArrayType=""
      local compiledObjectName=""
      local normalizatedObjectName=""

      # The tests below were intentionally designed to have no effect if both the 'is_array' and 
      # 'is_assoc' properties are set to 'true'. Since this configuration is invalid, it will 
      # trigger an error during the validation stage.
      if [ "${metaFlag["is_array"]}" = "1" ] || [ "${metaFlag["is_array"]}" = "true" ]; then
        metaFlagArrayType+="array"
        compiledObjectName="${flagVarName}_${flagPropName}_array"
      fi
      if [ "${metaFlag["is_assoc"]}" = "1" ] || [ "${metaFlag["is_assoc"]}" = "true" ]; then
        metaFlagArrayType+="assoc"
        compiledObjectName="${flagVarName}_${flagPropName}_assoc"
      fi

      #
      # Normalizes 'array' or 'assoc' values ​​by converting them into a dedicated object to serve 
      # as a reference for this property of this flag.
      case "$metaFlagArrayType" in
        array)
          normalizatedObjectName=$(shell_cli_type_normalize_main_array_types "${flagPropValue}")
          shell_cli_utils_array_indexed_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != 0 ]; then
            errPrefix+="[ prop: ${flagPropName} ]"
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the indexed array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
            return 1
          fi
          flagPropValue="${compiledObjectName}"
          ;;

        assoc)
          normalizatedObjectName=$(shell_cli_type_normalize_main_assoc_types "${flagPropValue}")
          shell_cli_utils_array_assoc_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != 0 ]; then
            errPrefix+="[ prop: ${flagPropName} ]"
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the assoc array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
            return 1
          fi
          flagPropValue="${compiledObjectName}"
          ;;
      esac


      flagAssocDefinition["${flagPropName}"]="$flagPropValue"
      unset -n metaFlag
    fi
  done



  #
  # STEP 3
  # For each properly normalized flag property value, a final validation is performed based on 
  # the specific rules for each, including cross-referencing the current value against the 
  # values ​​of the other properties..
  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"

    local metaflagPropertyValidateFN="shell_cli_metaflag_property_validate_${flagPropName}"
    local metaFlagPropertyValidateStatus=""

    "$metaflagPropertyValidateFN" "$flagPropValue" "$flagVarName"
    metaFlagPropertyValidateStatus="$?"
    if [ "${metaFlagPropertyValidateStatus}" != "0" ]; then
      errPrefix+="[ prop: ${flagPropName} ]"
      SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE}"
      return "$metaFlagPropertyValidateStatus"
    fi
  done


  flagAssocDefinition["__checked"]="1"
  return 0
}
