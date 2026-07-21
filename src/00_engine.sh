#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/engine.sh
# DESCRIPTION: Framework flag compilation filler and orchestrated runtime 
#              validation engines processing structural user argument matrices.
# ==============================================================================

# shell_cli_type_validate_single_value checks a scalar string against core rules.
#
# Arguments:
#   - value: The raw or inferred scalar value string to be evaluated.
#   - flag_array_name: The name of the target flag metadata configuration map.
#   - context_key: Optional dictionary key identifier for error messages.
#   - context_index: Optional indexed array counter position for error messages.
#
# Returns:
#   - 0: If the scalar value passes all type, bounds, and regex constraints.
#   - 1: If any individual constraint or system rule boundary is violated.
shell_cli_type_validate_single_value() {
  local value="$1"
  local flag_name="$2"
  local c_key="$3"
  local c_idx="$4"

  # ----------------------------------------------------------------------------
  # SANDBOX INITIALIZATION & SAFETY PURGE
  # ----------------------------------------------------------------------------
  # Clear residual global values to block previous validation data leakages
  SHELL_CLI_VALIDATED_VALUE=""
  
  # Prefix variables to protect against native circular name reference bugs
  local -n _sval_rules="$flag_name"

  local l_name="--${_sval_rules["long"]}"
  local target_type="${_sval_rules["type"]}"
  local validator_fn="shell_cli_type_validate_${target_type}"

  # Build the dynamic contextual visual signature prefix uniformly
  local prefix="[ ${l_name} ]"
  [ -n "$c_key" ] && prefix+="[ key: ${c_key} ]"
  [ -n "$c_idx" ] && prefix+="[ index: ${c_idx} ]"

  # 1. Assert core type classification mask conformity
  if ! "$validator_fn" "$value" "${_sval_rules["enum"]}"; then
    VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value '${value}' violates type '${target_type}'."
    return 1
  fi

  # Synchronize potential completion updates from inference pipelines
  if [ -n "$SHELL_CLI_VALIDATED_VALUE" ]; then
    value="$SHELL_CLI_VALIDATED_VALUE"
  else
    SHELL_CLI_VALIDATED_VALUE="$value"
  fi

  # 2. Evaluate scalar boundary limitations (min / max bounds)
  if [ -n "${_sval_rules["min"]}" ] || [ -n "${_sval_rules["max"]}" ]; then
    if [ "$target_type" = "int" ]; then
      if [ -n "${_sval_rules["min"]}" ] && (( value < ${_sval_rules["min"]} )); then
        VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates minimum allowed (min: ${_sval_rules["min"]})."
        return 1
      fi
      if [ -n "${_sval_rules["max"]}" ] && (( value > ${_sval_rules["max"]} )); then
        VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates maximum allowed (max: ${_sval_rules["max"]})."
        return 1
      fi
    elif [ "$target_type" = "float" ]; then
      if [ -n "${_sval_rules["min"]}" ]; then
        if ! shell_cli_utils_math_is_greater_or_equal "$value" "${_sval_rules["min"]}" "0"; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates minimum allowed (min: ${_sval_rules["min"]})."
          return 1
        fi
      fi
      if [ -n "${_sval_rules["max"]}" ]; then
        if ! shell_cli_utils_math_is_less_or_equal "$value" "${_sval_rules["max"]}" "0"; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates maximum allowed (max: ${_sval_rules["max"]})."
          return 1
        fi
      fi
    elif [[ "$target_type" =~ ^(date|time|datetime)$ ]]; then
      # Chronological epoch timestamp processing alignment via system tools
      local val_sec=$(date -d "$value" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$value" +%s 2>/dev/null)
      
      if [ -n "${_sval_rules["min"]}" ]; then
        local min_sec=$(date -d "${_sval_rules["min"]}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${_sval_rules["min"]}" +%s 2>/dev/null)
        if [ -n "$min_sec" ] && [ "$val_sec" -lt "$min_sec" ]; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates minimum allowed (min: ${_sval_rules["min"]})."
          return 1
        fi
      fi
      if [ -n "${_sval_rules["max"]}" ]; then
        local max_sec=$(date -d "${_sval_rules["max"]}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${_sval_rules["max"]}" +%s 2>/dev/null)
        if [ -n "$max_sec" ] && [ "$val_sec" -gt "$max_sec" ]; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates maximum allowed (max: ${_sval_rules["max"]})."
          return 1
        fi
      fi
    else
      # Text strings and system paths length evaluation (Character count)
      if [ -n "${_sval_rules["min"]}" ] && [ "${#value}" -lt "${_sval_rules["min"]}" ]; then
        VALIDATION_ERROR_MSG="[ x ] ${prefix} :: character length is lower than required (min: ${_sval_rules["min"]})."
        return 1
      fi
      if [ -n "${_sval_rules["max"]}" ] && [ "${#value}" -gt "${_sval_rules["max"]}" ]; then
        VALIDATION_ERROR_MSG="[ x ] ${prefix} :: character length is bigger than required (max: ${_sval_rules["max"]})."
        return 1
      fi
    fi
  fi

  # 3. Assert static regular expression custom mask rules if configured
  if [ -n "${_sval_rules["regex"]}" ] && [[ ! "$value" =~ ${_sval_rules["regex"]} ]]; then
    VALIDATION_ERROR_MSG="[ x ] ${prefix} :: does not match with regular expression (regex: ${_sval_rules["regex"]} )."
    return 1
  fi

  # 4. Invoke secondary domain custom developer function hooks FOR THIS SPECIFIC VALUE
  if [ -n "${_sval_rules["validate"]}" ]; then
    for custom_fn in ${_sval_rules["validate"]}; do
      if declare -f "$custom_fn" >/dev/null; then
        if ! "$custom_fn" "$value"; then
          if [[ ! "$VALIDATION_ERROR_MSG" =~ ^\[[[:space:]]*x[[:space:]]*\] ]]; then
            VALIDATION_ERROR_MSG="[ x ] ${prefix} :: ${VALIDATION_ERROR_MSG}"
          fi
          return 1
        fi
      fi
    done
  fi

  # ----------------------------------------------------------------------------
  # FINAL SYNCHRONIZATION PIPELINE BOUNDARY
  # ----------------------------------------------------------------------------
  # Lock the completely approved and validated payload into the global register
  SHELL_CLI_VALIDATED_VALUE="$value"

  return 0
}

# shell_cli_flag_apply_transformations runs developer-defined post-validation
# transform hooks over the final validated value before it is stored.
#
# Arguments:
#   - value: The already validated scalar value or collection string.
#   - flag_array_name: The name of the fully filled flag metadata configuration map.
#
# Returns:
#   - 0: If all transform hooks run successfully.
#   - 1: If a transform hook is missing or fails.
shell_cli_flag_apply_transformations() {
  local value="$1"
  local flag_name="$2"

  local -n _tval_rules="$flag_name"
  local transform_list="${_tval_rules["transform"]}"

  if [ -z "$transform_list" ] || [ "$transform_list" = "[]" ]; then
    SHELL_CLI_VALIDATED_VALUE="$value"
    return 0
  fi

  if ! shell_cli_type_validate_array "$transform_list"; then
    VALIDATION_ERROR_MSG="[ x ] [ --${_tval_rules["long"]} ] :: transform list must be a valid array collection []."
    return 1
  fi

  shell_cli_type_normalize_array "$transform_list"

  local transformed_value="$value"
  for custom_fn in "${SHELL_CLI_NORMALIZATED_ARRAY[@]}"; do
    if ! transformed_value="$("$custom_fn" "$transformed_value")"; then
      VALIDATION_ERROR_MSG="[ x ] [ --${_tval_rules["long"]} ] :: transform function '${custom_fn}' failed."
      return 1
    fi
  done

  SHELL_CLI_VALIDATED_VALUE="$transformed_value"
  return 0
}

# shell_cli_type_validate_value asserts arguments against compiled metadata matrices.
#
# Arguments:
#   - value: The raw parameter argument string typed by the user terminal.
#   - flag_array_name: The name of the fully filled flag metadata configuration map.
#
# Returns:
#   - 0: If the user input perfectly satisfies all rule constraints.
#   - 1: If any boundary, type mask, collection, or custom validator fails.
shell_cli_type_validate_value() {
  local value="$1"
  local flag_name="$2"
  
  # Prefix variables to protect against native circular name reference bugs
  local -n _vval_rules="$flag_name"

  local l_name="--${_vval_rules["long"]}"

  # 1. Evaluate primitive presence constraints (Required checking)
  if [ -z "$value" ] && [ "${_vval_rules["required"]}" = "0" ]; then
    SHELL_CLI_VALIDATED_VALUE="${_vval_rules["default"]}"
    SHELL_CLI_NORMALIZATED_ARRAY=()
    SHELL_CLI_NORMALIZATED_ASSOC=()
    if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
      return 1
    fi
    return 0
  fi

  if [ -z "$value" ] && [ "${_vval_rules["required"]}" = "1" ]; then
    VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: cannot be empty or omitted."
    return 1
  fi

  # 2. Direct data routing evaluation according to array layout configurations
  if [ "${_vval_rules["array"]}" = "1" ]; then
    if ! shell_cli_type_validate_array "$value"; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: must be a valid array collection []."
      return 1
    fi

    shell_cli_type_normalize_array "$value"

    local -a transformed_items=()
    local count=0
    for current_token in "${SHELL_CLI_NORMALIZATED_ARRAY[@]}"; do
      if ! shell_cli_type_validate_single_value "$current_token" "$flag_name" "" "$count"; then
        return 1
      fi
      if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
        return 1
      fi
      transformed_items+=("$SHELL_CLI_VALIDATED_VALUE")
      count=$((count + 1))
    done

    SHELL_CLI_NORMALIZATED_ARRAY=("${transformed_items[@]}")

    # Validate overall collection sizing array length restrictions
    local total_elements="${#SHELL_CLI_NORMALIZATED_ARRAY[@]}"
    if [ -n "${_vval_rules["min_array"]}" ] && [ "$total_elements" -lt "${_vval_rules["min_array"]}" ]; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: collection violates minimum item count (min_array: ${_vval_rules["min_array"]})."
      return 1
    fi
    if [ -n "${_vval_rules["max_array"]}" ] && [ "$total_elements" -gt "${_vval_rules["max_array"]}" ]; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: collection violates maximum item count (max_array: ${_vval_rules["max_array"]})."
      return 1
    fi

    local serialized_array="["
    local first=1
    for current_token in "${SHELL_CLI_NORMALIZATED_ARRAY[@]}"; do
      if [ "$first" -eq 0 ]; then
        serialized_array+=","
      fi
      serialized_array+="\"${current_token}\""
      first=0
    done
    serialized_array+="]"
    SHELL_CLI_VALIDATED_VALUE="$serialized_array"

  # 3. Direct data routing evaluation according to map dictionary layouts
  elif [ "${_vval_rules["assoc"]}" = "1" ]; then
    if ! shell_cli_type_validate_json "$value"; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: must be a valid json string."
      return 1
    fi

    shell_cli_type_normalize_assoc "$value"

    # Enforce strict sorted predictability over mandatory structural key checks
    if [ -n "${_vval_rules["assoc_keys"]}" ]; then
      local keys_list="${_vval_rules["assoc_keys"]}"
      # Split, clear whitespace and pass through sort to guarantee predictable order
      local sorted_expected_keys
      sorted_expected_keys=$(echo "${keys_list// /}" | tr ',' '\n' | sort)

      while IFS= read -r expected || [ -n "$expected" ]; do
        [ -z "$expected" ] && continue
        if [ -z "${SHELL_CLI_NORMALIZATED_ASSOC["$expected"]+exists}" ]; then
          VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: required key '${expected}' is missing."
          return 1
        fi
      done <<< "$sorted_expected_keys"
    fi

    # Sort dictionary keys to provide deterministic sequential evaluation outputs
    local sorted_assoc_keys
    sorted_assoc_keys=$(echo "${!SHELL_CLI_NORMALIZATED_ASSOC[@]}" | tr ' ' '\n' | sort)

    local -A transformed_assoc=()
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      local current_val="${SHELL_CLI_NORMALIZATED_ASSOC["$key"]}"
      if ! shell_cli_type_validate_single_value "$current_val" "$flag_name" "$key" ""; then
        return 1
      fi
      if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
        return 1
      fi
      transformed_assoc["$key"]="$SHELL_CLI_VALIDATED_VALUE"
    done <<< "$sorted_assoc_keys"

    SHELL_CLI_NORMALIZATED_ASSOC=()
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      SHELL_CLI_NORMALIZATED_ASSOC["$key"]="${transformed_assoc["$key"]}"
    done <<< "$sorted_assoc_keys"

    local serialized_assoc="{"
    local first=1
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      if [ "$first" -eq 0 ]; then
        serialized_assoc+=","
      fi
      serialized_assoc+="\"${key}\":\"${SHELL_CLI_NORMALIZATED_ASSOC["$key"]}\""
      first=0
    done <<< "$sorted_assoc_keys"
    serialized_assoc+="}"
    SHELL_CLI_VALIDATED_VALUE="$serialized_assoc"

  # 4. Standard validation loop for single scalar values parameters
  else
    if ! shell_cli_type_validate_single_value "$value" "$flag_name" "" ""; then
      return 1
    fi
    if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
      return 1
    fi
  fi

  return 0
}


# shell_cli_flag_validate orchestrates the sequential validation of all parsed CLI flags.
#
# Arguments:
#   - flag_prefix: The global naming prefix for the flag schema arrays (e.g., "FLAG").
#   - order_array_name: Name of the indexed array defining the strict evaluation order.
#   - parsed_maps_name: Name of the associative array storing the parsed user arguments.
#
# Returns:
#   - 0: If all present user arguments perfectly satisfy their compiled schemas.
#   - 1: If any configuration schema is missing or a validation rule fails.
shell_cli_flag_validate() {
  local prefix_key="$1"
  local order_array="$2"
  local parsed_maps="$3"

  # Protect against native circular name reference bugs via unique local prefixes
  local -n _val_order="$order_array"
  local -n _val_parsed="$parsed_maps"

  # Iteratively process every flag defined in the developer's strict order checklist
  for flag_name in "${_val_order[@]}"; do
    local target_schema_array="${prefix_key}_${flag_name}"

    # 1. Assert physical schema definition existence in the active runtime space
    if ! declare -p "$target_schema_array" &>/dev/null; then
      VALIDATION_ERROR_MSG="[ERR] Configuration schema array '${target_schema_array}' not exists."
      return 1
    fi

    # Reference the target flag's rule matrix dynamically
    local -n _current_rules="$target_schema_array"
    local raw_user_value="${_val_parsed["$flag_name"]}"

    # 2. Invoke the central engine validator passing the user input and the schema pointer
    if ! shell_cli_type_validate_value "$raw_user_value" "$target_schema_array"; then
      return 1
    fi

    # 3. Synchronize clean inferred or default updates back into the user's parsed map registers
    _val_parsed["$flag_name"]="$SHELL_CLI_VALIDATED_VALUE"
  done

  return 0
}
