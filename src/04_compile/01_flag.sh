#!/usr/bin/env bash

# shell_cli_compile_flag - Compile, normalize, and validate a target flag definition schema.
#
# Arguments
# - flagVarName: Name of the associative array representing the flag structure to compile.
#
# Global outputs
# - SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE: Stores descriptive compilation or validation failure messages.
#
# Notes
# - Skips compilation and returns 0 immediately if the flag already has '__checked=1' set.
# - Phase 1 (Hydration): Populates unassigned schema properties with framework-specified defaults.
# - Phase 2 (Type & Collection): Runs type-specific normalization and validation; complex structural 
#   collections ('array' or 'assoc') are cloned into dedicated persistent reference memory objects.
# - Phase 3 (Cross-Validation): Invokes isolated and cross-reference constraint checkers for each rule.
# - Mutations: Destructively modifies the target definition by updating keys to normalized formats, 
#   injecting memory references, and marking execution status with '__checked=1' upon success.
# - Context: Failures at this lifecycle stage are treated as fatal framework configuration breaks.
#
# Returns
# - 0: Success (flag successfully compiled, cached, and validated).
# - 1+: Failure (invalid base structure, normalization type breach, or metaflag property rule violation).
shell_cli_compile_flag() {

  local flagVarName="${1}"
  local errPrefix="[ERR][ ${flagVarName} ]"
  SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""


  if ! shell_cli_utils_array_is_assoc "${flagVarName}"; then
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
      flagPropValue=$("${flagTypeNormalizeFN}" "${flagPropValue}")


      #
      # Validate value after normalization
      local flagTypeValidateFN="shell_cli_type_validate_${metaFlagType}"
      "${flagTypeValidateFN}" "${flagPropValue}"
      local validateStatus=$?

      if [ "${validateStatus}" != "0" ]; then
        errPrefix+="[ prop: ${flagPropName} ]"
        SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: not a valid '${metaFlagType}' type; ( value: '${flagPropValue}' )"

        if [ "${validateStatus}" = "10" ]; then
          SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE+="; ( remove control characters )"
        fi

        return "${validateStatus}"
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
      case "${metaFlagArrayType}" in
        array)
          normalizatedObjectName=$(shell_cli_type_normalize_main_array_types "${flagPropValue}")
          shell_cli_utils_array_indexed_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != "0" ]; then
            errPrefix+="[ prop: ${flagPropName} ]"
            SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the indexed array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
            return 1
          fi
          flagPropValue="${compiledObjectName}"
          ;;

        assoc)
          normalizatedObjectName=$(shell_cli_type_normalize_main_assoc_types "${flagPropValue}")
          shell_cli_utils_array_assoc_clone "${normalizatedObjectName}" "${compiledObjectName}"
          if [ "$?" != "0" ]; then
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
