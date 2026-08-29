#!/usr/bin/env bash

# shell_cli_compile_flag — Compile, normalize, and validate a target flag definition
# schema.
# 
# Arguments
# - flagVarName: Name of the associative array representing the flag structure to
#   compile.
# 
# Global outputs
# - SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE: Stores descriptive compilation or validation
#   failure messages.
# 
# Notes
# - Skips compilation and returns 0 immediately if the flag already has '__checked=1'
#   set.
# - Phase 1 (Hydration): Populates unassigned schema properties with framework-specified
#   defaults.
# - Phase 2 (Type & Collection): Runs type-specific normalization and validation;
#   complex structural collections ('array' or 'assoc') are cloned into dedicated
#   persistent reference memory objects.
# - Phase 3 (Cross-Validation): Invokes isolated and cross-reference constraint checkers
#   for each rule.
# - Mutations: Destructively modifies the target definition by updating keys to normalized
#   formats, injecting memory references, and marking execution status with '__checked=1'
#   upon success.
# - Context: Failures at this lifecycle stage are treated as fatal framework configuration
#   breaks.
# 
# Returns
# - 0: Success (flag successfully compiled, cached, and validated).
# - 1+: Failure (invalid base structure, normalization type breach, or metaflag property
#   rule violation).
shell_cli_compile_flag() {
  local flagVarName="${1}"

  # Reset global variables
  SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""

  local errPrefix="[ERR][ ${flagVarName} ]"
  local errExtraData=""
  local flagPropName=""
  local flagPropValue=""
  local flagPropDefault=""
  local flagPropType=""



  local metaFlagArrayType=""
  local compiledObjectName=""
  local normalizatedObjectName=""
  local -a validatePropKeys=()
  local -a validatePropValues=()

  if ! shell_cli_utils_array_is_assoc "${flagVarName}"; then
    SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: invalid definition; must be an associative array (declare -A)."
    return 1
  fi

  # Loads the flag's associative array and checks if it has already been validated
  local -n flagAssocDefinition="${flagVarName}"
  if [ "${flagAssocDefinition["__checked"]}" = "1" ]; then
    return 0
  fi

  # 
  # initiates normalization of flag properties
  # 

  # STEP 01:  
  # Defines all keys that are not present in the passed associative array and populates
  # them with their default values.
  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"
    flagPropDefault="${SHELL_CLI_METAFLAG_DEFAULT["${flagPropName}"]}"

    if [ "${flagPropValue}" = "" ] && [ "${flagPropDefault}" != "" ]; then
      flagAssocDefinition["${flagPropName}"]="$flagPropDefault"
    fi
  done

  # STEP 2:  
  # For each property with a defined value (i.e., not empty), it invokes the normalizer
  # and validator for the corresponding type, ensuring that the defined value is
  # a valid representative of that expected type.
  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"

    if [ "${flagPropValue}" != "" ]; then
      local -n metaFlag="METAFLAG_${flagPropName}"

      # Normalize array or assoc values
      metaFlagArrayType=""
      compiledObjectName=""
      normalizatedObjectName=""
      validatePropKeys=()
      validatePropValues=()



      # The tests below were intentionally designed to have no effect if both the
      # 'is_array' and 'is_assoc' properties are set to 'true'. Since this configuration
      # is invalid, it will trigger an error during the validation stage.
      if [ "${metaFlag["is_array"]}" = "1" ] || [ "${metaFlag["is_array"]}" = "true" ]; then
        metaFlagArrayType+="array"
        compiledObjectName="${flagVarName}_${flagPropName}_array"
      fi
      if [ "${metaFlag["is_assoc"]}" = "1" ] || [ "${metaFlag["is_assoc"]}" = "true" ]; then
        metaFlagArrayType+="assoc"
        compiledObjectName="${flagVarName}_${flagPropName}_assoc"
      fi

      # Normalizes 'array' or 'assoc' values by converting them into a dedicated
      # object to serve as a reference for this property of this flag.
      case "${metaFlagArrayType}" in
        array)
          shell_cli_type_normalize_main_array_types "${flagPropValue}"
          normalizatedObjectName="${SHELL_CLI_FN_RETURN}"
          shell_cli_utils_array_indexed_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != "0" ]; then
            errPrefix+="[ prop: ${flagPropName} ]"
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the indexed array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
            return 1
          fi

          local i=""
          local -n arr="${compiledObjectName}"
          for i in "${!arr[@]}"; do
            validatePropKeys+=("")
            validatePropValues+=("${arr["${i}"]}")
          done

          flagPropValue="${compiledObjectName}"
          ;;

        assoc)
          shell_cli_type_normalize_main_assoc_types "${flagPropValue}"
          normalizatedObjectName="${SHELL_CLI_FN_RETURN}"
          shell_cli_utils_array_assoc_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != "0" ]; then
            errPrefix+="[ prop: ${flagPropName} ]"
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the assoc array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
            return 1
          fi

          local k=""
          local -n assoc="${compiledObjectName}"
          for k in "${!assoc[@]}"; do
            validatePropKeys+=("${k}")
            validatePropValues+=("${assoc["${k}"]}")
          done

          flagPropValue="${compiledObjectName}"
          ;;

        *)
          validatePropKeys+=("")
          validatePropValues+=("${flagPropValue}")
          ;;
      esac



      local i=""
      local key=""
      local val=""
      flagPropType="${metaFlag["type"]}"
      for i in "${!validatePropValues[@]}"; do
        key="${validatePropKeys["${i}"]}"
        val="${validatePropValues["${i}"]}"

        shell_cli_compile_flag_single_value_validation "${flagPropType}" "${val}"
        local validateStatus="$?"
        if [ "${validateStatus}" -ne 0 ]; then
          errPrefix+="[ prop: ${flagPropName} ]"
          errExtraData="value: '${val}'"
          if [ "${key}" != "" ]; then
            errExtraData="key:'${key}'; value: '${val}'"
          fi

          SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: not a valid '${flagPropType}' type; ( ${errExtraData} )"
          if [ "${validateStatus}" -eq 10 ]; then
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE+="; ( remove control characters )"
          fi

          return "${validateStatus}"
        fi

        validatePropValues["${i}"]="${SHELL_CLI_FN_RETURN}"
      done



      case "${metaFlagArrayType}" in
        array)
          local i=""
          local -n arrayValues="${flagPropValue}"
          for i in "${!validatePropValues[@]}"; do
            arrayValues["${i}"]="${validatePropValues["${i}"]}"
          done
          ;;

        assoc)
          local i=""
          local -n assocValues="${flagPropValue}"
          for i in "${!validatePropValues[@]}"; do
            key="${validatePropKeys["${i}"]}"
            val="${validatePropValues["${i}"]}"
            assocValues["${key}"]="${val}"
          done
          ;;

        *)
          flagPropValue="${validatePropValues[0]}"
          ;;
      esac


      flagAssocDefinition["${flagPropName}"]="${flagPropValue}"
      unset -n metaFlag
    fi
  done




  # STEP 3:  
  # For each properly normalized flag property value, a final validation is performed
  # based on the specific rules for each, including cross-referencing the current
  # value against the values of the other properties.
  local metaflagPropertyValidateFN=""
  local metaFlagPropertyValidateStatus=0

  for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
    flagPropValue="${flagAssocDefinition["${flagPropName}"]}"

    metaflagPropertyValidateFN="shell_cli_metaflag_property_validate_${flagPropName}"
    metaFlagPropertyValidateStatus=0

    "${metaflagPropertyValidateFN}" "${flagPropValue}" "${flagVarName}"
    metaFlagPropertyValidateStatus="$?"
    if [ "${metaFlagPropertyValidateStatus}" != "0" ]; then
      errPrefix+="[ prop: ${flagPropName} ]"
      SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE}"
      return "${metaFlagPropertyValidateStatus}"
    fi
  done

  flagAssocDefinition["__checked"]="1"
  return 0
}





shell_cli_compile_flag_single_value_validation() {
  local flagPropType="${1}"
  local flagPropValue="${2}"

  local flagTypeNormalizeFN="shell_cli_type_normalize_${flagPropType}"
  local flagTypeValidateFN="shell_cli_type_validate_${flagPropType}"

  # Normalize raw value
  "${flagTypeNormalizeFN}" "${flagPropValue}"
  flagPropValue="${SHELL_CLI_FN_RETURN}"

  # Validate value after normalization
  "${flagTypeValidateFN}" "${flagPropValue}"

  SHELL_CLI_FN_RETURN="${flagPropValue}"
  return $?
}
