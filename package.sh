#!/usr/bin/env bash

# ==============================================================================
#        ORIGIN : https://github.com/AeonDigital/Shell-CLI
#   DESCRIPTION : Single-file distribution bundle of the Shell-CLI framework,
#                 generated from the source tree for standalone use.
#        README : https://github.com/AeonDigital/Shell-CLI/blob/main/README.md
# ==============================================================================


#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/flags/engine.sh
_shell_cli_meta_normalize_bool() {
  local meta_value="${1,,}"
  if [ "$meta_value" = "1" ] || [ "$meta_value" = "true" ]; then
    echo "1"
  elif [ "$meta_value" = "0" ] || [ "$meta_value" = "false" ]; then
    echo "0"
  else
    echo "$1"
  fi
}
shell_cli_flag_fill() {
  local flag_name="$1"
  local -n flag_ref="$flag_name"
  local bool_keys=("required" "array" "assoc")
  for b_key in "${bool_keys[@]}"; do
    if [ -n "${flag_ref["$b_key"]+exists}" ]; then
      flag_ref["$b_key"]=$(_shell_cli_meta_normalize_bool "${flag_ref["$b_key"]}")
    fi
  done
  for key in "${!CORE_METAFLAG_DEFAULTS[@]}"; do
    if [ -z "${flag_ref["$key"]}" ]; then
      flag_ref["$key"]="${CORE_METAFLAG_DEFAULTS["$key"]}"
    fi
  done
  return 0
}
shell_cli_flag_validate_single_value() {
  local value="$1"
  local flag_name="$2"
  local c_key="$3"
  local c_idx="$4"
  SHELL_CLI_VALIDATED_VALUE=""
  local -n _sval_rules="$flag_name"
  local l_name="--${_sval_rules["long"]}"
  local target_type="${_sval_rules["type"]}"
  local validator_fn="shell_cli_flag_validate_${target_type}"
  local prefix="[ ${l_name} ]"
  [ -n "$c_key" ] && prefix+="[ key: ${c_key} ]"
  [ -n "$c_idx" ] && prefix+="[ index: ${c_idx} ]"
  if ! "$validator_fn" "$value" "${_sval_rules["enum"]}"; then
    VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value '${value}' violates type '${target_type}'."
    return 1
  fi
  if [ -n "$SHELL_CLI_VALIDATED_VALUE" ]; then
    value="$SHELL_CLI_VALIDATED_VALUE"
  else
    SHELL_CLI_VALIDATED_VALUE="$value"
  fi
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
        if ! shell_cli_math_is_greater_or_equal "$value" "${_sval_rules["min"]}" "0"; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates minimum allowed (min: ${_sval_rules["min"]})."
          return 1
        fi
      fi
      if [ -n "${_sval_rules["max"]}" ]; then
        if ! shell_cli_math_is_less_or_equal "$value" "${_sval_rules["max"]}" "0"; then
          VALIDATION_ERROR_MSG="[ x ] ${prefix} :: value violates maximum allowed (max: ${_sval_rules["max"]})."
          return 1
        fi
      fi
    elif [[ "$target_type" =~ ^(date|time|datetime)$ ]]; then
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
  if [ -n "${_sval_rules["regex"]}" ] && [[ ! "$value" =~ ${_sval_rules["regex"]} ]]; then
    VALIDATION_ERROR_MSG="[ x ] ${prefix} :: does not match with regular expression (regex: ${_sval_rules["regex"]} )."
    return 1
  fi
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
  SHELL_CLI_VALIDATED_VALUE="$value"
  return 0
}
shell_cli_flag_apply_transformations() {
  local value="$1"
  local flag_name="$2"
  local -n _tval_rules="$flag_name"
  local transform_list="${_tval_rules["transform"]}"
  if [ -z "$transform_list" ] || [ "$transform_list" = "[]" ]; then
    SHELL_CLI_VALIDATED_VALUE="$value"
    return 0
  fi
  if ! shell_cli_flag_validate_array "$transform_list"; then
    VALIDATION_ERROR_MSG="[ x ] [ --${_tval_rules["long"]} ] :: transform list must be a valid array collection []."
    return 1
  fi
  shell_cli_flag_extract_array "$transform_list"
  local transformed_value="$value"
  for custom_fn in "${SHELL_CLI_VALIDATED_ARRAY[@]}"; do
    if ! transformed_value="$("$custom_fn" "$transformed_value")"; then
      VALIDATION_ERROR_MSG="[ x ] [ --${_tval_rules["long"]} ] :: transform function '${custom_fn}' failed."
      return 1
    fi
  done
  SHELL_CLI_VALIDATED_VALUE="$transformed_value"
  return 0
}
shell_cli_flag_validate_value() {
  local value="$1"
  local flag_name="$2"
  local -n _vval_rules="$flag_name"
  local l_name="--${_vval_rules["long"]}"
  if [ -z "$value" ] && [ "${_vval_rules["required"]}" = "0" ]; then
    SHELL_CLI_VALIDATED_VALUE="${_vval_rules["default"]}"
    SHELL_CLI_VALIDATED_ARRAY=()
    SHELL_CLI_VALIDATED_ASSOC=()
    if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
      return 1
    fi
    return 0
  fi
  if [ -z "$value" ] && [ "${_vval_rules["required"]}" = "1" ]; then
    VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: cannot be empty or omitted."
    return 1
  fi
  if [ "${_vval_rules["array"]}" = "1" ]; then
    if ! shell_cli_flag_validate_array "$value"; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: must be a valid array collection []."
      return 1
    fi
    shell_cli_flag_extract_array "$value"
    local -a transformed_items=()
    local count=0
    for current_token in "${SHELL_CLI_VALIDATED_ARRAY[@]}"; do
      if ! shell_cli_flag_validate_single_value "$current_token" "$flag_name" "" "$count"; then
        return 1
      fi
      if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
        return 1
      fi
      transformed_items+=("$SHELL_CLI_VALIDATED_VALUE")
      count=$((count + 1))
    done
    SHELL_CLI_VALIDATED_ARRAY=("${transformed_items[@]}")
    local total_elements="${#SHELL_CLI_VALIDATED_ARRAY[@]}"
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
    for current_token in "${SHELL_CLI_VALIDATED_ARRAY[@]}"; do
      if [ "$first" -eq 0 ]; then
        serialized_array+=","
      fi
      serialized_array+="\"${current_token}\""
      first=0
    done
    serialized_array+="]"
    SHELL_CLI_VALIDATED_VALUE="$serialized_array"
  elif [ "${_vval_rules["assoc"]}" = "1" ]; then
    if ! shell_cli_flag_validate_json "$value"; then
      VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: must be a valid json string."
      return 1
    fi
    shell_cli_flag_extract_assoc "$value"
    if [ -n "${_vval_rules["assoc_keys"]}" ]; then
      local keys_list="${_vval_rules["assoc_keys"]}"
      local sorted_expected_keys
      sorted_expected_keys=$(echo "${keys_list// /}" | tr ',' '\n' | sort)
      while IFS= read -r expected || [ -n "$expected" ]; do
        [ -z "$expected" ] && continue
        if [ -z "${SHELL_CLI_VALIDATED_ASSOC["$expected"]+exists}" ]; then
          VALIDATION_ERROR_MSG="[ x ] [ ${l_name} ] :: required key '${expected}' is missing."
          return 1
        fi
      done <<< "$sorted_expected_keys"
    fi
    local sorted_assoc_keys
    sorted_assoc_keys=$(echo "${!SHELL_CLI_VALIDATED_ASSOC[@]}" | tr ' ' '\n' | sort)
    local -A transformed_assoc=()
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      local current_val="${SHELL_CLI_VALIDATED_ASSOC["$key"]}"
      if ! shell_cli_flag_validate_single_value "$current_val" "$flag_name" "$key" ""; then
        return 1
      fi
      if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
        return 1
      fi
      transformed_assoc["$key"]="$SHELL_CLI_VALIDATED_VALUE"
    done <<< "$sorted_assoc_keys"
    SHELL_CLI_VALIDATED_ASSOC=()
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      SHELL_CLI_VALIDATED_ASSOC["$key"]="${transformed_assoc["$key"]}"
    done <<< "$sorted_assoc_keys"
    local serialized_assoc="{"
    local first=1
    while IFS= read -r key || [ -n "$key" ]; do
      [ -z "$key" ] && continue
      if [ "$first" -eq 0 ]; then
        serialized_assoc+=","
      fi
      serialized_assoc+="\"${key}\":\"${SHELL_CLI_VALIDATED_ASSOC["$key"]}\""
      first=0
    done <<< "$sorted_assoc_keys"
    serialized_assoc+="}"
    SHELL_CLI_VALIDATED_VALUE="$serialized_assoc"
  else
    if ! shell_cli_flag_validate_single_value "$value" "$flag_name" "" ""; then
      return 1
    fi
    if ! shell_cli_flag_apply_transformations "$SHELL_CLI_VALIDATED_VALUE" "$flag_name"; then
      return 1
    fi
  fi
  return 0
}
shell_cli_flag_validate_rules() {
  local target_flag_name="$1"
  local -n _comp_flag="$target_flag_name"
  shell_cli_flag_fill "$target_flag_name"
  local f_label="[ flag_meta: ${target_flag_name} ]"
  for meta_key in "${CORE_METAFLAG_DEFAULTS_ORDER[@]}"; do
    local current_meta_val="${_comp_flag["$meta_key"]}"
    local meta_spec_array="METAFLAG_${meta_key}"
    if ! declare -p "$meta_spec_array" &>/dev/null; then
      VALIDATION_ERROR_MSG="[ERR] ${f_label} :: internal engine layout error. Schema array '${meta_spec_array}' is missing."
      return 1
    fi
    if ! shell_cli_flag_validate_value "$current_meta_val" "$meta_spec_array"; then
      VALIDATION_ERROR_MSG="${VALIDATION_ERROR_MSG} \n[ERR] ${f_label}[ key: ${meta_key} ] :: invalid design property."
      return 1
    fi
  done
  if [ "${_comp_flag["array"]}" = "1" ] && [ "${_comp_flag["assoc"]}" = "1" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: structural conflict. A parameter cannot be declared as 'array' and 'assoc' simultaneously."
    return 1
  fi
  if [ "${_comp_flag["required"]}" = "1" ] && [ -n "${_comp_flag["default"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: logical breakdown. A mandatory 'required=1' flag cannot provision a fallback 'default' assignment."
    return 1
  fi
  if [ "${_comp_flag["array"]}" = "0" ]; then
    if [ -n "${_comp_flag["min_array"]}" ] || [ -n "${_comp_flag["max_array"]}" ]; then
      VALIDATION_ERROR_MSG="[ERR] ${f_label} :: design orphan. Properties 'min_array' or 'max_array' mandate 'array=1' activation."
      return 1
    fi
  fi
  if [ "${_comp_flag["assoc"]}" = "0" ] && [ -n "${_comp_flag["assoc_keys"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: design orphan. The property 'assoc_keys' mandates 'assoc=1' activation."
    return 1
  fi
  if [ "${_comp_flag["type"]}" = "enum" ] && [ -z "${_comp_flag["enum"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: configuration breakdown. Flags classifying as 'type=enum' must declare a target dynamic 'enum' pointer array name."
    return 1
  fi
  if [ -n "${_comp_flag["min_array"]}" ] && [ -n "${_comp_flag["max_array"]}" ]; then
    if (( ${_comp_flag["min_array"]} > ${_comp_flag["max_array"]} )); then
      VALIDATION_ERROR_MSG="[ERR] ${f_label} :: logical inversion. The 'min_array' property cannot be higher than 'max_array'."
      return 1
    fi
  fi
  if [ -n "${_comp_flag["min"]}" ] && [ -n "${_comp_flag["max"]}" ]; then
    local target_type="${_comp_flag["type"]}"
    if [ "$target_type" = "int" ]; then
      if (( ${_comp_flag["min"]} > ${_comp_flag["max"]} )); then
        VALIDATION_ERROR_MSG="[ERR] ${f_label} :: range inversion. The 'min' mathematical limit cannot exceed 'max'."
        return 1
      fi
    elif [ "$target_type" = "float" ]; then
      if ! shell_cli_math_is_less_or_equal "${_comp_flag["min"]}" "${_comp_flag["max"]}" "0"; then
        VALIDATION_ERROR_MSG="[ERR] ${f_label} :: range inversion. The 'min' decimal limit cannot exceed 'max'."
        return 1
      fi
    elif [[ "$target_type" =~ ^(date|time|datetime)$ ]]; then
      local min_sec=$(date -d "${_comp_flag["min"]}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${_comp_flag["min"]}" +%s 2>/dev/null)
      local max_sec=$(date -d "${_comp_flag["max"]}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${_comp_flag["max"]}" +%s 2>/dev/null)
      if [ -n "$min_sec" ] && [ -n "$max_sec" ] && [ "$min_sec" -gt "$max_sec" ]; then
        VALIDATION_ERROR_MSG="[ERR] ${f_label} :: range inversion. The 'min' chronological limit cannot exceed 'max'."
        return 1
      fi
    else
      if (( ${_comp_flag["min"]} > ${_comp_flag["max"]} )); then
        VALIDATION_ERROR_MSG="[ERR] ${f_label} :: sizing inversion. The 'min' character length threshold cannot exceed 'max'."
        return 1
      fi
    fi
  fi
  if [ -n "${_comp_flag["regex"]}" ]; then
    if ! [[ "" =~ ${_comp_flag["regex"]} ]] 2>/dev/null; then
      VALIDATION_ERROR_MSG="[ERR] ${f_label}[ key: regex ] :: syntax corruption. The regular expression pattern is malformed or invalid."
      return 1
    fi
  fi
  if [ -n "${_comp_flag["validate"]}" ]; then
    for custom_fn in ${_comp_flag["validate"]}; do
      if ! declare -f "$custom_fn" >/dev/null; then
        VALIDATION_ERROR_MSG="[ERR] ${f_label}[ key: validate ] :: implementation gap. Custom validation investigator function '${custom_fn}' does not exist."
        return 1
      fi
    done
  fi
  local check_long="${_comp_flag["long"]}"
  local check_short="${_comp_flag["short"]}"
  if [[ "$check_long" =~ ^(h|help|itr|interactive)$ ]] || [[ "$check_short" =~ ^(h|help|itr|interactive)$ ]]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: nomenclature collision. The names 'help', 'h', 'interactive', and 'itr' are strictly reserved for framework core orchestration."
    return 1
  fi
  return 0
}
shell_cli_flag_validate() {
  local prefix_key="$1"
  local order_array="$2"
  local parsed_maps="$3"
  local -n _val_order="$order_array"
  local -n _val_parsed="$parsed_maps"
  for flag_name in "${_val_order[@]}"; do
    local target_schema_array="${prefix_key}_${flag_name}"
    if ! declare -p "$target_schema_array" &>/dev/null; then
      VALIDATION_ERROR_MSG="[ERR] Configuration schema array '${target_schema_array}' not exists."
      return 1
    fi
    local -n _current_rules="$target_schema_array"
    local raw_user_value="${_val_parsed["$flag_name"]}"
    if ! shell_cli_flag_validate_value "$raw_user_value" "$target_schema_array"; then
      return 1
    fi
    _val_parsed["$flag_name"]="$SHELL_CLI_VALIDATED_VALUE"
  done
  return 0
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/flags/engine.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/flags/meta.sh
declare -gA CORE_SUPPORTED_TYPES=(
  ["string"]="string" 
  ["int"]="int" 
  ["float"]="float" 
  ["bool"]="bool"
  ["date"]="date" 
  ["time"]="time" 
  ["datetime"]="datetime" 
  ["email"]="email" 
  ["enum"]="enum"
  ["json"]="json" 
  ["function"]="function"
  ["path"]="path" 
  ["relativepath"]="relativepath" 
  ["filename"]="filename" 
  ["filepath"]="filepath" 
  ["dirname"]="dirname" 
  ["dirpath"]="dirpath"
  ["url"]="url" 
  ["fullurl"]="fullurl" 
  ["relativeurl"]="relativeurl"
)
declare -gA METAFLAG_short=()
METAFLAG_short["short"]=""
METAFLAG_short["long"]="short"
METAFLAG_short["type"]="string"
METAFLAG_short["array"]="0"
METAFLAG_short["assoc"]="0"
METAFLAG_short["required"]="0"
METAFLAG_short["default"]=""
METAFLAG_short["enum"]=""
METAFLAG_short["assoc_keys"]=""
METAFLAG_short["min"]="1"
METAFLAG_short["max"]="3"
METAFLAG_short["min_array"]=""
METAFLAG_short["max_array"]=""
METAFLAG_short["regex"]="^[a-zA-Z0-9]+$"
METAFLAG_short["description"]="Short alphanumeric character alias for the flag (1 to 3 chars)."
METAFLAG_short["tipinput"]=""
METAFLAG_short["validate"]=""
METAFLAG_short["transform"]=""
declare -gA METAFLAG_long=()
METAFLAG_long["short"]=""
METAFLAG_long["long"]="long"
METAFLAG_long["type"]="string"
METAFLAG_long["array"]="0"
METAFLAG_long["assoc"]="0"
METAFLAG_long["required"]="1"
METAFLAG_long["default"]=""
METAFLAG_long["enum"]=""
METAFLAG_long["assoc_keys"]=""
METAFLAG_long["min"]="1"
METAFLAG_long["max"]="32"
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""
declare -gA METAFLAG_type=()
METAFLAG_type["short"]=""
METAFLAG_type["long"]="type"
METAFLAG_type["type"]="enum"
METAFLAG_type["array"]="0"
METAFLAG_type["assoc"]="0"
METAFLAG_type["required"]="1"
METAFLAG_type["default"]="string"
METAFLAG_type["enum"]="CORE_SUPPORTED_TYPES"
METAFLAG_type["assoc_keys"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""
declare -gA METAFLAG_array=()
METAFLAG_array["short"]=""
METAFLAG_array["long"]="array"
METAFLAG_array["type"]="bool"
METAFLAG_array["array"]="0"
METAFLAG_array["assoc"]="0"
METAFLAG_array["required"]="0"
METAFLAG_array["default"]="0"
METAFLAG_array["enum"]=""
METAFLAG_array["assoc_keys"]=""
METAFLAG_array["min"]=""
METAFLAG_array["max"]=""
METAFLAG_array["min_array"]=""
METAFLAG_array["max_array"]=""
METAFLAG_array["regex"]=""
METAFLAG_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_array["tipinput"]=""
METAFLAG_array["validate"]="check_meta_array_exclusivity"
METAFLAG_array["transform"]=""
declare -gA METAFLAG_assoc=()
METAFLAG_assoc["short"]=""
METAFLAG_assoc["long"]="assoc"
METAFLAG_assoc["type"]="bool"
METAFLAG_assoc["array"]="0"
METAFLAG_assoc["assoc"]="0"
METAFLAG_assoc["required"]="0"
METAFLAG_assoc["default"]="0"
METAFLAG_assoc["enum"]=""
METAFLAG_assoc["assoc_keys"]=""
METAFLAG_assoc["min"]=""
METAFLAG_assoc["max"]=""
METAFLAG_assoc["min_array"]=""
METAFLAG_assoc["max_array"]=""
METAFLAG_assoc["regex"]=""
METAFLAG_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_assoc["tipinput"]=""
METAFLAG_assoc["validate"]="check_meta_assoc_exclusivity"
METAFLAG_assoc["transform"]=""
declare -gA METAFLAG_required=()
METAFLAG_required["short"]=""
METAFLAG_required["long"]="required"
METAFLAG_required["type"]="bool"
METAFLAG_required["array"]="0"
METAFLAG_required["assoc"]="0"
METAFLAG_required["required"]="0"
METAFLAG_required["default"]="0"
METAFLAG_required["enum"]=""
METAFLAG_required["assoc_keys"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""
declare -gA METAFLAG_default=()
METAFLAG_default["short"]=""
METAFLAG_default["long"]="default"
METAFLAG_default["type"]="string"
METAFLAG_default["array"]="0"
METAFLAG_default["assoc"]="0"
METAFLAG_default["required"]="0"
METAFLAG_default["default"]=""
METAFLAG_default["enum"]=""
METAFLAG_default["assoc_keys"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""
declare -gA METAFLAG_enum=()
METAFLAG_enum["short"]=""
METAFLAG_enum["long"]="enum"
METAFLAG_enum["type"]="string"
METAFLAG_enum["array"]="1"
METAFLAG_enum["assoc"]="0"
METAFLAG_enum["required"]="0"
METAFLAG_enum["default"]="[]"
METAFLAG_enum["enum"]=""
METAFLAG_enum["assoc_keys"]=""
METAFLAG_enum["min"]=""
METAFLAG_enum["max"]=""
METAFLAG_enum["min_array"]=""
METAFLAG_enum["max_array"]=""
METAFLAG_enum["regex"]=""
METAFLAG_enum["description"]="JSON array listing accepted values and internal semantic aliases."
METAFLAG_enum["tipinput"]=""
METAFLAG_enum["validate"]="check_meta_enum_syntax"
METAFLAG_enum["transform"]=""
declare -gA METAFLAG_assoc_keys=()
METAFLAG_assoc_keys["short"]=""
METAFLAG_assoc_keys["long"]="assoc_keys"
METAFLAG_assoc_keys["type"]="string"
METAFLAG_assoc_keys["array"]="0"
METAFLAG_assoc_keys["assoc"]="0"
METAFLAG_assoc_keys["required"]="0"
METAFLAG_assoc_keys["default"]=""
METAFLAG_assoc_keys["enum"]=""
METAFLAG_assoc_keys["assoc_keys"]=""
METAFLAG_assoc_keys["min"]=""
METAFLAG_assoc_keys["max"]=""
METAFLAG_assoc_keys["min_array"]=""
METAFLAG_assoc_keys["max_array"]=""
METAFLAG_assoc_keys["regex"]=""
METAFLAG_assoc_keys["description"]="Comma-separated collection of mandatory dictionary keys required in the map."
METAFLAG_assoc_keys["tipinput"]=""
METAFLAG_assoc_keys["validate"]=""
METAFLAG_assoc_keys["transform"]=""
declare -gA METAFLAG_min=()
METAFLAG_min["short"]=""
METAFLAG_min["long"]="min"
METAFLAG_min["type"]="string"
METAFLAG_min["array"]="0"
METAFLAG_min["assoc"]="0"
METAFLAG_min["required"]="0"
METAFLAG_min["default"]=""
METAFLAG_min["enum"]=""
METAFLAG_min["assoc_keys"]=""
METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""
METAFLAG_min["regex"]=""
METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""
declare -gA METAFLAG_max=()
METAFLAG_max["short"]=""
METAFLAG_max["long"]="max"
METAFLAG_max["type"]="string"
METAFLAG_max["array"]="0"
METAFLAG_max["assoc"]="0"
METAFLAG_max["required"]="0"
METAFLAG_max["default"]=""
METAFLAG_max["enum"]=""
METAFLAG_max["assoc_keys"]=""
METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""
METAFLAG_max["regex"]=""
METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""
declare -gA METAFLAG_min_array=()
METAFLAG_min_array["short"]=""
METAFLAG_min_array["long"]="min_array"
METAFLAG_min_array["type"]="int"
METAFLAG_min_array["array"]="0"
METAFLAG_min_array["assoc"]="0"
METAFLAG_min_array["required"]="0"
METAFLAG_min_array["default"]=""
METAFLAG_min_array["enum"]=""
METAFLAG_min_array["assoc_keys"]=""
METAFLAG_min_array["min"]=""
METAFLAG_min_array["max"]=""
METAFLAG_min_array["min_array"]=""
METAFLAG_min_array["max_array"]=""
METAFLAG_min_array["regex"]=""
METAFLAG_min_array["description"]="Minimum allowable element count within a validated array collection."
METAFLAG_min_array["tipinput"]=""
METAFLAG_min_array["validate"]=""
METAFLAG_min_array["transform"]=""
declare -gA METAFLAG_max_array=()
METAFLAG_max_array["short"]=""
METAFLAG_max_array["long"]="max_array"
METAFLAG_max_array["type"]="int"
METAFLAG_max_array["array"]="0"
METAFLAG_max_array["assoc"]="0"
METAFLAG_max_array["required"]="0"
METAFLAG_max_array["default"]=""
METAFLAG_max_array["enum"]=""
METAFLAG_max_array["assoc_keys"]=""
METAFLAG_max_array["min"]=""
METAFLAG_max_array["max"]=""
METAFLAG_max_array["min_array"]=""
METAFLAG_max_array["max_array"]=""
METAFLAG_max_array["regex"]=""
METAFLAG_max_array["description"]="Maximum allowable element count within a validated array collection."
METAFLAG_max_array["tipinput"]=""
METAFLAG_max_array["validate"]=""
METAFLAG_max_array["transform"]=""
declare -gA METAFLAG_regex=()
METAFLAG_regex["short"]=""
METAFLAG_regex["long"]="regex"
METAFLAG_regex["type"]="string"
METAFLAG_regex["array"]="0"
METAFLAG_regex["assoc"]="0"
METAFLAG_regex["required"]="0"
METAFLAG_regex["default"]=""
METAFLAG_regex["enum"]=""
METAFLAG_regex["assoc_keys"]=""
METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""
METAFLAG_regex["regex"]=""
METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""
declare -gA METAFLAG_description=()
METAFLAG_description["short"]=""
METAFLAG_description["long"]="description"
METAFLAG_description["type"]="string"
METAFLAG_description["array"]="0"
METAFLAG_description["assoc"]="0"
METAFLAG_description["required"]="1"
METAFLAG_description["default"]=""
METAFLAG_description["enum"]=""
METAFLAG_description["assoc_keys"]=""
METAFLAG_description["min"]="1"
METAFLAG_description["max"]="256"
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""
METAFLAG_description["regex"]=""
METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""
declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["type"]="string"
METAFLAG_tipinput["array"]="0"
METAFLAG_tipinput["assoc"]="0"
METAFLAG_tipinput["required"]="0"
METAFLAG_tipinput["default"]=""
METAFLAG_tipinput["enum"]=""
METAFLAG_tipinput["assoc_keys"]=""
METAFLAG_tipinput["min"]=""
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""
METAFLAG_tipinput["regex"]=""
METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""
declare -gA METAFLAG_validate=()
METAFLAG_validate["short"]=""
METAFLAG_validate["long"]="validate"
METAFLAG_validate["type"]="function"
METAFLAG_validate["array"]="1"
METAFLAG_validate["assoc"]="0"
METAFLAG_validate["required"]="0"
METAFLAG_validate["default"]="[]"
METAFLAG_validate["enum"]=""
METAFLAG_validate["assoc_keys"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["description"]="JSON array of dynamic function pointers processing deep user custom validation states."
METAFLAG_validate["tipinput"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""
declare -gA METAFLAG_transform=()
METAFLAG_transform["short"]=""
METAFLAG_transform["long"]="transform"
METAFLAG_transform["type"]="function"
METAFLAG_transform["array"]="1"
METAFLAG_transform["assoc"]="0"
METAFLAG_transform["required"]="0"
METAFLAG_transform["default"]="[]"
METAFLAG_transform["enum"]=""
METAFLAG_transform["assoc_keys"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["description"]="JSON array of dynamic function pointers processing post-validation value transformations."
METAFLAG_transform["tipinput"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/flags/meta.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/flags/parsers.sh
shell_cli_flag_extract_array() {
  local input="$1"
  local inner="${input#?}"
  inner="${inner%?}"
  SHELL_CLI_VALIDATED_ARRAY=()
  local current=""
  local idx=0
  local len=${#inner}
  local in_q=0
  while [ "$idx" -lt "$len" ]; do
    local char="${inner:$idx:1}"
    if [ "$in_q" -eq 1 ]; then
      if [ "$char" = "'" ] || [ "$char" = '"' ]; then
        in_q=0
        SHELL_CLI_VALIDATED_ARRAY+=("$current")
        current=""
      else
        current+="$char"
      fi
    else
      if [ "$char" = "'" ] || [ "$char" = '"' ]; then
        in_q=1
      fi
    fi
    idx=$((idx + 1))
  done
}
shell_cli_flag_extract_assoc() {
  local input="$1"
  local inner="${input#?}"
  inner="${inner%?}"
  SHELL_CLI_VALIDATED_ASSOC=()
  local key=""
  local val=""
  local current=""
  local idx=0
  local len=${#inner}
  local in_q=0
  local capture_state=0 # 0=key, 1=value
  while [ "$idx" -lt "$len" ]; do
    local char="${inner:$idx:1}"
    if [ "$in_q" -eq 1 ]; then
      if [ "$char" = '"' ] || [ "$char" = "'" ]; then
        in_q=0
        if [ "$capture_state" -eq 0 ]; then
          key="$current"
        else
          val="$current"
          SHELL_CLI_VALIDATED_ASSOC["$key"]="$val"
          capture_state=0
        fi
        current=""
      else
        current+="$char"
      fi
    else
      case "$char" in
        '"'|"'") in_q=1 ;;
        ':')     capture_state=1 ;;
        ',')     : ;;
      esac
    fi
    idx=$((idx + 1))
  done
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/flags/parsers.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/flags/validate.sh
shell_cli_flag_validate_string() {
  local value="$1"
  local aux="$2"
  local clean_text
  clean_text=$(echo -n "$value" | tr -d '[:space:]')
  if [[ "$clean_text" =~ [[:cntrl:]] ]]; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_int() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ "$value" =~ ^-?[0-9]+$ ]]; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_float() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_bool() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local lower_value="${value,,}"
  if [[ "$lower_value" =~ ^(1|0|true|false)$ ]]; then
    if [[ "$lower_value" == "true" ]]; then
      SHELL_CLI_VALIDATED_VALUE="1"
    elif [[ "$lower_value" == "false" ]]; then
      SHELL_CLI_VALIDATED_VALUE="0"
    else
      SHELL_CLI_VALIDATED_VALUE="$lower_value"
    fi
    return 0
  fi
  return 1
}
shell_cli_flag_validate_date() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local inferred="$value"
  case "${#value}" in
    4)  # YYYY -> YYYY-01-01
      [[ "$value" =~ ^[0-9]{4}$ ]] || return 1
      inferred="${value}-01-01"
      ;;
    7)  # YYYY-MM -> YYYY-MM-01
      [[ "$value" =~ ^[0-9]{4}-[0-9]{2}$ ]] || return 1
      inferred="${value}-01"
      ;;
    10) # YYYY-MM-DD -> Fully formed
      [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
      ;;
    *)
      return 1 
      ;;
  esac
  if date -d "$inferred" +%Y-%m-%d &>/dev/null; then
    SHELL_CLI_VALIDATED_VALUE="$inferred"
    return 0
  elif date -j -f "%Y-%m-%d" "$inferred" +%Y-%m-%d &>/dev/null; then
    SHELL_CLI_VALIDATED_VALUE="$inferred"
    return 0
  fi
  return 1
}
shell_cli_flag_validate_time() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local inferred="$value"
  case "${#value}" in
    2)  # HH -> HH:00:00
      [[ "$value" =~ ^[0-9]{2}$ ]] || return 1
      inferred="${value}:00:00"
      ;;
    5)  # HH:MM -> HH:MM:00
      [[ "$value" =~ ^[0-9]{2}:[0-9]{2}$ ]] || return 1
      inferred="${value}:00"
      ;;
    8)  # HH:MM:SS -> Fully formed
      [[ "$value" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || return 1
      ;;
    *)
      return 1 
      ;;
  esac
  local time_regex="^([0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"
  if [[ "$inferred" =~ $time_regex ]]; then
    SHELL_CLI_VALIDATED_VALUE="$inferred"
    return 0
  fi
  return 1
}
shell_cli_flag_validate_datetime() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local date_part=""
  local time_part=""
  if [[ "$value" == *[[:space:]]* ]]; then
    date_part="${value%% *}"
    time_part="${value#* }"
  else
    if [[ "$value" == *:* ]]; then
      date_part="0001-01-01"
      time_part="$value"
    else
      date_part="$value"
      time_part="00:00:00"
    fi
  fi
  if ! shell_cli_flag_validate_date "$date_part"; then
    return 1
  fi
  local clean_date="$SHELL_CLI_VALIDATED_VALUE"
  if ! shell_cli_flag_validate_time "$time_part"; then
    return 1
  fi
  local clean_time="$SHELL_CLI_VALIDATED_VALUE"
  SHELL_CLI_VALIDATED_VALUE="${clean_date} ${clean_time}"
  return 0
}
shell_cli_flag_validate_email() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
  if [[ "$value" =~ $email_regex ]]; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_function() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if declare -f "$value" >/dev/null; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_enum() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local array_name="$aux"
  if [ -z "$array_name" ] || ! declare -p "$array_name" &> /dev/null; then
    return 1
  fi
  local -n target_array="$array_name"
  for item in "${target_array[@]}"; do
    if [ "$value" = "$item" ]; then
      return 0
    fi
  done
  return 1
}
shell_cli_flag_validate_array() {
  local value="$1"
  local aux="$2"
  local clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ ! "$clean_value" =~ ^\[.*\]$ ]]; then
    return 1
  fi
  if [ "$clean_value" = "[]" ]; then
    SHELL_CLI_VALIDATED_VALUE="[]"
    return 0
  fi
  local payload="${clean_value#?}"
  payload="${payload%?}"
  local state=0
  local in_quotes=0
  local current_token=""
  local normalized_json="["
  local len=${#payload}
  local idx=0
  while [ "$idx" -lt "$len" ]; do
    local char="${payload:$idx:1}"
    if [ "$in_quotes" -eq 1 ]; then
      if [ "$char" = "\\" ]; then
        current_token+="${char}${payload:$((idx + 1)):1}"
        idx=$((idx + 2))
        continue
      fi
      if [ "$char" = '"' ]; then
        in_quotes=0
        if [ "$state" -eq 0 ]; then
          normalized_json+="\"${current_token}\""
          state=1
        else
          return 1
        fi
        current_token=""
      else
        current_token+="$char"
      fi
    else
      if [[ "$char" =~ [[:space:]] ]]; then
        idx=$((idx + 1))
        continue
      fi
      case "$char" in
        '"')
          in_quotes=1
          if [ "$state" -ne 0 ]; then return 1; fi
          ;;
        ',')
          if [ "$state" -ne 1 ]; then return 1; fi
          normalized_json+=","
          state=0
          ;;
        *)
          if [ "$state" -eq 0 ]; then
            current_token+="$char"
            local next_idx=$((idx + 1))
            local next_char="${payload:$next_idx:1}"
            if [[ "$next_char" =~ [,:[:space:]] ]] || [ "$next_idx" -eq "$len" ]; then
              if [[ "$current_token" =~ ^[0-9]+([.][0-9]+)?$ ]] || \
                 [ "$current_token" = "true" ] || \
                 [ "$current_token" = "false" ] || \
                 [ "$current_token" = "null" ]; then
                normalized_json+="$current_token"
                current_token=""
                state=1
              else
                return 1
              fi
            fi
          else
            return 1
          fi
          ;;
      esac
    fi
    idx=$((idx + 1))
  done
  if [ "$in_quotes" -ne 0 ] || [ "$state" -ne 1 ]; then
    return 1
  fi
  normalized_json+="]"
  SHELL_CLI_VALIDATED_VALUE="$normalized_json"
  return 0
}
shell_cli_flag_validate_json() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local clean_value
  clean_value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [[ ! "$clean_value" =~ ^\{.*\}$ ]]; then
    return 1
  fi
  if [ "$clean_value" = "{}" ] ; then
    SHELL_CLI_VALIDATED_VALUE="{}"
    return 0
  fi
  local state=0
  local in_quotes=0
  local current_token=""
  local normalized_json="{"
  local payload="${clean_value#?}"
  payload="${payload%%?}"
  local len=${#payload}
  local idx=0
  while [ "$idx" -lt "$len" ]; do
    local char="${payload:$idx:1}"
    if [ "$in_quotes" -eq 1 ]; then
      if [ "$char" = "\\" ]; then
        current_token+="${char}${payload:$((idx + 1)):1}"
        idx=$((idx + 2))
        continue
      fi
      if [ "$char" = '"' ]; then
        in_quotes=0
        if [ "$state" -eq 0 ]; then
          normalized_json+="\"${current_token}\""
          state=1
        elif [ "$state" -eq 2 ]; then
          normalized_json+="\"${current_token}\""
          state=3
        fi
        current_token=""
      else
        current_token+="$char"
      fi
    else
      if [[ "$char" =~ [[:space:]] ]]; then
        idx=$((idx + 1))
        continue
      fi
      case "$char" in
        '"')
          in_quotes=1
          if [ "$state" -ne 0 ] && [ "$state" -ne 2 ]; then return 1; fi
          ;;
        ':')
          if [ "$state" -ne 1 ]; then return 1; fi
          normalized_json+=":"
          state=2 
          ;;
        ',')
          if [ "$state" -ne 3 ]; then return 1; fi
          normalized_json+=","
          state=0 
          ;;
        '{'|'[')
          if [ "$state" -ne 2 ]; then return 1; fi
          local target_close="}"
          if [ "$char" = "[" ]; then target_close="]"; fi
          local sub_structure="$char"
          local depth=1
          idx=$((idx + 1))
          while [ "$idx" -lt "$len" ] && [ "$depth" -gt 0 ]; do
            local sub_char="${payload:$idx:1}"
            sub_structure+="$sub_char"
            if [ "$sub_char" = "$char" ]; then
              depth=$((depth + 1))
            elif [ "$sub_char" = "$target_close" ]; then
              depth=$((depth - 1))
            fi
            idx=$((idx + 1))
          done
          if [ "$depth" -ne 0 ]; then return 1; fi # Unmatched nested block
          normalized_json+="$sub_structure"
          state=3
          idx=$((idx - 1)) # Balance main loop increment
          ;;
        *)
          if [ "$state" -eq 2 ]; then
            current_token+="$char"
            local next_idx=$((idx + 1))
            local next_char="${payload:$next_idx:1}"
            if [[ "$next_char" =~ [,:[:space:]] ]] || [ "$next_idx" -eq "$len" ]; then
              if [[ "$current_token" =~ ^[0-9]+([.][0-9]+)?$ ]] || \
                 [ "$current_token" = "true" ] || \
                 [ "$current_token" = "false" ] || \
                 [ "$current_token" = "null" ]; then
                normalized_json+="$current_token"
                current_token=""
                state=3
              else
                return 1
              fi
            fi
          else
            return 1
          fi
          ;;
      esac
    fi
    idx=$((idx + 1))
  done
  if [ "$in_quotes" -ne 0 ] || [ "$state" -ne 3 ]; then
    return 1
  fi
  normalized_json+="}"
  SHELL_CLI_VALIDATED_VALUE="$normalized_json"
  return 0
}
shell_cli_flag_validate_path() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ "$value" =~ [\*\?\"\<\>\|] ]]; then
    return 1
  fi
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    return 1
  fi
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_relativepath() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi
  if [[ "$value" =~ ^\/ ]] || [[ "$value" =~ ^[A-Za-z]:\\ ]] || [[ "$value" =~ ^[A-Za-z]:\/ ]]; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_filename() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ "$value" == *\/* ]] || [[ "$value" == *\\* ]] || [ -z "$value" ]; then
    return 1
  fi
  if [[ "$value" =~ [\*\?\"\<\>\|:] ]]; then
    return 1
  fi
  if [[ "$value" =~ [[:cntrl:]] ]]; then
    return 1
  fi
  if [[ "$value" =~ : ]] && [[ ! "$value" =~ ^[A-Za-z]: ]]; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_filepath() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi
  if [[ "$value" =~ \/$ ]] || [[ "$value" =~ \\$ ]] || [ -z "$value" ]; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_dirname() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if ! shell_cli_flag_validate_filename "$value"; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_dirpath() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if ! shell_cli_flag_validate_path "$value"; then
    return 1
  fi
  return 0
}
shell_cli_flag_validate_url() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if shell_cli_flag_validate_fullurl "$value" || shell_cli_flag_validate_relativeurl "$value"; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_fullurl() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
  if [[ "$value" =~ $url_regex ]]; then
    return 0
  fi
  return 1
}
shell_cli_flag_validate_relativeurl() {
  local value="$1"
  local aux="$2"
  if ! shell_cli_flag_validate_string "$value" "$aux"; then
    return 1
  fi
  if [[ "$value" =~ ^https?:\/\/ ]] || [[ "$value" =~ ^ftp:\/\/ ]]; then
    return 1
  fi
  if [[ "$value" =~ ^\/[A-Za-z0-9._%+-]*(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$ ]]; then
    return 0
  fi
  return 1
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/flags/validate.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/help.sh
shell_cli_help_render_global() {
  local p_name="$SHELL_CLI_RUNTIME_PKG"
  local lowercase_script_name="${p_name,,}"
  echo "================================================================================"
  echo "  ${p_name} - Enterprise Shell Command Automation Utility"
  echo "================================================================================"
  echo ""
  echo "Usage:"
  echo "  ./${lowercase_script_name}.sh <resource> <action> [flags]"
  echo "  ./${lowercase_script_name}.sh <ores-action> [flags]"
  echo ""
  echo "Global System Flags:"
  echo "  -h, --help          Display guidance documentation and metadata definitions."
  echo "  -itr, --interactive Force step-by-step user interaction prompt mode."
  echo ""
  echo "Available Operational Command Tree:"
  local cmd_var
  for cmd_var in $(declare -p | cut -d'=' -f1 | rev | cut -d' ' -f1 | rev | grep "^CMD_${p_name}_" | sort); do
    if [[ "$cmd_var" == *_FLAG_* ]] || [[ "$cmd_var" == *_INPUT ]]; then
      continue
    fi
    local -n _g_cmd="$cmd_var"
    local raw_tree="${cmd_var#"CMD_${p_name}_"}"
    local print_cmd="${raw_tree//_/ }"
    if [[ "$print_cmd" =~ ^ores[[:space:]] ]]; then
      print_cmd="${print_cmd#ores }"
    fi
    printf "  %-20s %s\n" "$print_cmd" "${_g_cmd["summary"]:-No summary documented.}"
  done
  echo "================================================================================"
  return 0
}
shell_cli_help_render_contextual() {
  local p_name="$SHELL_CLI_RUNTIME_PKG"
  local c_tree="$SHELL_CLI_RUNTIME_COMMAND_TREE"
  if [ -z "${SHELL_CLI_RUNTIME_CMD["cmd"]}" ]; then
    shell_cli_help_render_global
    return 0
  fi
  local print_cmd="${c_tree//_/ }"
  [[ "$print_cmd" =~ ^ores[[:space:]] ]] && print_cmd="${print_cmd#ores }"
  echo "================================================================================"
  echo "COMMAND: ${print_cmd}"
  echo "SUMMARY: ${SHELL_CLI_RUNTIME_CMD["summary"]:-No summary available.}"
  if [ -n "${SHELL_CLI_RUNTIME_CMD["description"]}" ]; then
    echo "DESCRIPTION:"
    shell_cli_string_wrap "${SHELL_CLI_RUNTIME_CMD["description"]}" "120"
  fi
  echo "================================================================================"
  if [ "${#SHELL_CLI_RUNTIME_FLAG_ORDER[@]}" -gt 0 ]; then
    echo "Command Parameter Flags (Evaluated in strict checklist sequence):"
    echo ""
    local f_token
    for f_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
      local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${f_token}"
      local -n _f_h_rules="$runtime_flag_array_name"
      local short_opt="${_f_h_rules["short"]}"
      local long_opt="${_f_h_rules["long"]}"
      local display_flag=""
      if [ -n "$short_opt" ]; then
        display_flag="-${short_opt}, --${long_opt}"
      else
        display_flag="    --${long_opt}"
      fi
      local meta_status="[optional]"
      [ "${_f_h_rules["required"]}" = "1" ] && meta_status="[REQUIRED]"
      local structural_type="${_f_h_rules["type"]}"
      [ "${_f_h_rules["array"]}" = "1" ] && structural_type="array<${structural_type}>"
      [ "${_f_h_rules["assoc"]}" = "1" ] && structural_type="map<string,${structural_type}>"
      printf "  %-25s %-18s %s\n" "${display_flag}" "${structural_type}" "${meta_status}"
      if [ -n "${_f_h_rules["description"]}" ]; then
        echo -n "      Description: "
        shell_cli_string_wrap "${_f_h_rules["description"]}" "100" | sed '2,$s/^/                   /'
      fi
      if [ "${_f_h_rules["required"]}" = "0" ] && [ -n "${_f_h_rules["default"]}" ]; then
        echo "      Default: \"${_f_h_rules["default"]}\""
      fi
      if [ -n "${_f_h_rules["min"]}" ] || [ -n "${_f_h_rules["max"]}" ]; then
        local limits=""
        if [ -n "${_f_h_rules["min"]}" ]; then
          limits="min: ${_f_h_rules["min"]}"
        fi
        if [ -n "${_f_h_rules["max"]}" ]; then
          if [ -n "$limits" ]; then
            limits="${limits}, "
          fi
          limits="${limits}max: ${_f_h_rules["max"]}"
        fi
        echo "      Constraints: [${limits}]"
      fi
      echo ""
    done
  else
    echo "This operational command option does not register or mandate any parameter flags."
  fi
  echo "================================================================================"
  return 0
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/help.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/main.sh
shell_cli_runtime_compile() {
  local target_pkg="$1"
  local target_tree="$2"
  shell_cli_runtime_reset
  SHELL_CLI_RUNTIME_PKG="$target_pkg"
  SHELL_CLI_RUNTIME_COMMAND_TREE="$target_tree"
  local blueprint_prefix="CMD_${target_pkg}_${target_tree}"
  if ! declare -p "${blueprint_prefix}" &>/dev/null; then
    VALIDATION_ERROR_MSG="[ERR] Architecture Breakdown :: Master command layout definition '${blueprint_prefix}' is missing."
    return 1
  fi
  local src_cmd_key
  for src_cmd_key in "cmd" "summary" "description"; do
    local indirect_cmd_ref="${blueprint_prefix}[\"${src_cmd_key}\"]"
    SHELL_CLI_RUNTIME_CMD["$src_cmd_key"]="${!indirect_cmd_ref}"
  done
  local src_order_ref="${blueprint_prefix}_FLAG_ORDER[@]"
  SHELL_CLI_RUNTIME_FLAG_ORDER=("${!src_order_ref}")
  local active_flag_token
  for active_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local src_flag_array_name="${blueprint_prefix}_FLAG_${active_flag_token}"
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${active_flag_token}"
    if ! _shell_cli_runtime_compile_single_flag "$src_flag_array_name" "$runtime_flag_array_name"; then
      return 1
    fi
    local -n _idx_f="$runtime_flag_array_name"
    SHELL_CLI_RUNTIME_FLAG_LONGNAME["${_idx_f["long"]}"]="${active_flag_token}"
    if [ -n "${_idx_f["short"]}" ]; then
      SHELL_CLI_RUNTIME_FLAG_SHORTNAME["${_idx_f["short"]}"]="${_idx_f["long"]}"
    fi
  done
  if ! shell_cli_runtime_ingest_raw_inputs "$@"; then
    return 1
  fi
  return 0
}
_shell_cli_runtime_compile_single_flag() {
  local src_flag_array_name="$1"
  local runtime_flag_array_name="$2"
  declare -gA "${runtime_flag_array_name}"
  local current_meta_key
  for current_meta_key in "${CORE_METAFLAG_DEFAULTS_ORDER[@]}"; do
    local indirect_flag_ref="${src_flag_array_name}[\"${current_meta_key}\"]"
    local source_value="${!indirect_flag_ref}"
    if [ -z "$source_value" ]; then
      local fallback_ref="CORE_METAFLAG_DEFAULTS[\"${current_meta_key}\"]"
      source_value="${!fallback_ref}"
    fi
    local runtime_flag_assignment="${runtime_flag_array_name}[\"${current_meta_key}\"]"
    eval "${runtime_flag_assignment}=\"\${source_value}\""
  done
  local -n _c_flag="$runtime_flag_array_name"
  local f_label="[ flag_meta: ${runtime_flag_array_name} ]"
  if [ "${_c_flag["array"]}" = "1" ] && [ "${_c_flag["assoc"]}" = "1" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: structural conflict. A parameter cannot be declared as 'array' and 'assoc' simultaneously."
    return 1
  fi
  if [ "${_c_flag["required"]}" = "1" ] && [ -n "${_c_flag["default"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: logical breakdown. A mandatory 'required=1' flag cannot provision a fallback 'default' assignment."
  fi
  if [ "${_c_flag["type"]}" = "enum" ] && [ -z "${_c_flag["enum"]}" ]; then
    VALIDATION_ERROR_MSG="[ERR] ${f_label} :: configuration breakdown. Flags classifying as 'type=enum' must declare a target dynamic 'enum' pointer array name."
    return 1
  fi
  return 0
}
shell_cli_runtime_ingest_raw_inputs() {
  if [ "$1" = "$SHELL_CLI_RUNTIME_PKG" ]; then
    shift
  fi
  local -a positional_commands=()
  local -a flag_tokens=()
  local scanning_flags=0
  while [ $# -gt 0 ]; do
    local current_token="$1"
    if [[ "$current_token" =~ ^- ]]; then
      scanning_flags=1
    fi
    if [ "$scanning_flags" -eq 0 ]; then
      if [ "$current_token" = "help" ]; then
        SHELL_CLI_TRIGGER_HELP="1"
      else
        positional_commands+=("$current_token")
      fi
    else
      if ! [[ "$current_token" =~ ^- ]]; then
        VALIDATION_ERROR_MSG="[ x ] Syntax Error :: Positional argument '${current_token}' discovered after flags stream initialization."
        return 1
      fi
      flag_tokens+=("$current_token")
    fi
    shift
  done
  local total_pos="${#positional_commands[@]}"
  if [ "$total_pos" -eq 0 ]; then
    SHELL_CLI_RUNTIME_COMMAND_TREE="ORES"
  else
    local tree_buffer="ORES"
    local i
    for ((i=0; i<total_pos; i++)); do
      tree_buffer+="_${positional_commands[$i]}"
    done
    SHELL_CLI_RUNTIME_COMMAND_TREE="$tree_buffer"
  fi
  local lowercase_pkg="${SHELL_CLI_RUNTIME_PKG,,}"
  SHELL_CLI_RUNTIME_FN_VALIDATE="cmd_${lowercase_pkg}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_main_validate"
  SHELL_CLI_RUNTIME_FN_ACTION="cmd_${lowercase_pkg}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_action"
  if ! declare -f "$SHELL_CLI_RUNTIME_FN_ACTION" >/dev/null; then
    VALIDATION_ERROR_MSG="[ERR] Implementation Fail :: Mandatory execution action hook function '${SHELL_CLI_RUNTIME_FN_ACTION}' is missing."
    return 1
  fi
  local raw_flag
  for raw_flag in "${flag_tokens[@]}"; do
    local flag_key="${raw_flag%%=*}"
    if [[ "$flag_key" =~ ^(--help|-h)$ ]]; then
      SHELL_CLI_TRIGGER_HELP="1"
    fi
    if [[ "$flag_key" =~ ^(--interactive|-itr)$ ]]; then
      SHELL_CLI_TRIGGER_INTERACTIVE="1"
    fi
  done
  if [ "$SHELL_CLI_TRIGGER_HELP" = "1" ]; then
    SHELL_CLI_TRIGGER_INTERACTIVE="0"
    return 0
  fi
  if [ "$SHELL_CLI_TRIGGER_INTERACTIVE" = "1" ]; then
    return 0
  fi
  local idx=0
  while [ $idx -lt "${#flag_tokens[@]}" ]; do
    local current_flag="${flag_tokens[$idx]}"
    local extracted_key=""
    local extracted_val=""
    if [[ "$current_flag" == *=* ]]; then
      extracted_key="${current_flag%%=*}"
      extracted_val="${current_flag#*=}"
    else
      extracted_key="$current_flag"
      extracted_val="1"
    fi
    local clean_key="${extracted_key#--}"
    clean_key="${clean_key#-}"
    if [ -n "${SHELL_CLI_RUNTIME_FLAG_SHORTNAME["$clean_key"]+exists}" ]; then
      clean_key="${SHELL_CLI_RUNTIME_FLAG_SHORTNAME["$clean_key"]}"
    fi
    if [ -z "${SHELL_CLI_RUNTIME_FLAG_LONGNAME["$clean_key"]+exists}" ]; then
      VALIDATION_ERROR_MSG="[ x ] Parameter Error :: Unknown or unregistered flag token '${extracted_key}' provided."
      return 1
    fi
    if [ -n "${SHELL_CLI_RUNTIME_RAW_INPUTS["$clean_key"]+exists}" ]; then
      VALIDATION_ERROR_MSG="[ x ] Duplicated Error :: Parameter '${extracted_key}' was provided multiple times."
      return 1
    fi
    SHELL_CLI_RUNTIME_RAW_INPUTS["$clean_key"]="$extracted_val"
    idx=$((idx + 1))
  done
  return 0
}
shell_cli_runtime_validate_inputs() {
  if [ "$SHELL_CLI_TRIGGER_HELP" = "1" ] || [ "$SHELL_CLI_TRIGGER_INTERACTIVE" = "1" ]; then
    return 0
  fi
  local current_flag_token
  for current_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${current_flag_token}"
    local -n _v_flag="$runtime_flag_array_name"
    local long_name="${_v_flag["long"]}"
    local user_raw_value=""
    if [ -n "${SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]+exists}" ]; then
      user_raw_value="${SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]}"
    fi
    if ! shell_cli_flag_validate_value "$user_raw_value" "$runtime_flag_array_name"; then
      return 1
    fi
    SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]="$SHELL_CLI_VALIDATED_VALUE"
  done
  return 0
}
shell_cli_runtime_export_inputs() {
  local target_input_map_name="CMD_${SHELL_CLI_RUNTIME_PKG}_${SHELL_CLI_RUNTIME_COMMAND_TREE}_INPUT"
  declare -gA "${target_input_map_name}"
  local key_token
  for key_token in "${!SHELL_CLI_RUNTIME_RAW_INPUTS[@]}"; do
    local assignment_target="${target_input_map_name}[\"${key_token}\"]"
    eval "${assignment_target}=\"\${SHELL_CLI_RUNTIME_RAW_INPUTS[\$key_token]}\""
  done
  return 0
}
shell_cli_runtime_handle_help() {
  if [ "$SHELL_CLI_TRIGGER_HELP" != "1" ]; then
    return 1
  fi
  if [ "$SHELL_CLI_RUNTIME_COMMAND_TREE" = "ORES" ] || [ "$SHELL_CLI_RUNTIME_COMMAND_TREE" = "ORES_help" ]; then
    shell_cli_help_render_global
  else
    shell_cli_help_render_contextual
  fi
  return 0
}
shell_cli_runtime_handle_interactive() {
  if [ "$SHELL_CLI_TRIGGER_INTERACTIVE" != "1" ] || [ "$SHELL_CLI_TRIGGER_HELP" = "1" ]; then
    return 1
  fi
  if [ ! -t 0 ]; then
    echo "[ERR] Interactive mode (-itr) cannot be executed in a non-TTY environment (e.g., CI/CD pipelines, cron jobs)." >&2
    exit 1
  fi
  SHELL_CLI_RUNTIME_RAW_INPUTS=()
  local print_cmd="${SHELL_CLI_RUNTIME_COMMAND_TREE//_/ }"
  if [[ "$print_cmd" =~ ^ores[[:space:]] ]]; then
    print_cmd="${print_cmd#ores }"
  fi
  echo "================================================================================"
  echo "[RUN] ${print_cmd^^} - Input in interactive mode"
  echo "[ ! ] Note: Type ':q!' at any prompt to abort execution safely."
  echo "================================================================================"
  local current_flag_token
  for current_flag_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
    local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${current_flag_token}"
    local -n _int_f="$runtime_flag_array_name"
    local long_name="${_int_f["long"]}"
    local prompt_msg="${_int_f["tipinput"]}"
    if [ -z "$prompt_msg" ]; then
      prompt_msg="Enter value for --${long_name}"
    fi
    while true; do
      local captured_raw_input=""
      echo -e "[ > ] ${prompt_msg}: "
      echo -n "      "
      read -r captured_raw_input
      if [ "$captured_raw_input" = ":q!" ]; then
        echo ""
        echo "================================================================================"
        echo "[END] Aborted by user."
        echo "================================================================================"
        return 2
      fi
      if ! shell_cli_flag_validate_value "$captured_raw_input" "$runtime_flag_array_name"; then
        echo -e "${VALIDATION_ERROR_MSG}"
        continue
      fi
      SHELL_CLI_RUNTIME_RAW_INPUTS["$long_name"]="$SHELL_CLI_VALIDATED_VALUE"
      break
    done
  done
  echo ""
  echo "================================================================================"
  echo "[ . ] End interactive mode. Proceeding... "
  echo "================================================================================"
  return 0
}
shell_cli_run() {
  if [ "$SHELL_CLI_PROCESS_LOCK_ACTIVE" = "1" ] && [ "$SHELL_CLI_PROCESS_LOCK_PID" = "$BASHPID" ]; then
    echo "[ERR] Critical Architecture Panic :: Inline nested command invocation detected!"
    echo "[ERR] Context: Concurrent execution sharing the same active memory stack frame is strictly prohibited."
    echo "[ERR] Resolution: Wrap your programmatic downstream calls using standard isolated sub-shell tokens: ( shell_cli_run ... )"
    return 1
  fi
  SHELL_CLI_PROCESS_LOCK_ACTIVE="1"
  SHELL_CLI_PROCESS_LOCK_PID="$BASHPID"
  if [ -z "$SHELL_CLI_ACTIVE_ROOT_PATH" ] || [ ! -d "$SHELL_CLI_ACTIVE_ROOT_PATH" ]; then
    echo "[ERR] Critical Workspace Fault :: Target 'SHELL_CLI_ACTIVE_ROOT_PATH'='$SHELL_CLI_ACTIVE_ROOT_PATH' is missing or points to an invalid directory."
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi
  if ! shell_cli_runtime_compile "$SHELL_CLI_ACTIVE_PKG" "$@"; then
    echo -e "$VALIDATION_ERROR_MSG"
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi
  if shell_cli_runtime_handle_help; then
    shell_cli_runtime_reset
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 0
  fi
  local skip_inputs_validation=0
  shell_cli_runtime_handle_interactive
  local interactive_status=$?
  if [ "$interactive_status" -eq 0 ]; then
    skip_inputs_validation=1
  elif [ "$interactive_status" -eq 2 ]; then
    shell_cli_runtime_reset
    SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
    SHELL_CLI_PROCESS_LOCK_PID=""
    return 1
  fi
  if [ "$skip_inputs_validation" -eq 0 ]; then
    if ! shell_cli_runtime_validate_inputs; then
      echo -e "$VALIDATION_ERROR_MSG"
      shell_cli_runtime_reset
      SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
      SHELL_CLI_PROCESS_LOCK_PID=""
      return 1
    fi
  fi
  shell_cli_runtime_export_inputs
  if declare -f "$SHELL_CLI_RUNTIME_FN_VALIDATE" >/dev/null; then
    if ! "$SHELL_CLI_RUNTIME_FN_VALIDATE"; then
      echo -e "$VALIDATION_ERROR_MSG"
      shell_cli_runtime_reset
      SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
      SHELL_CLI_PROCESS_LOCK_PID=""
      return 1
    fi
  fi
  "$SHELL_CLI_RUNTIME_FN_ACTION"
  local action_exit_code=$?
  shell_cli_runtime_reset
  SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
  SHELL_CLI_PROCESS_LOCK_PID=""
  return $action_exit_code
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/main.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/utils/math.sh
shell_cli_math_compare_float() {
  local val1="$1"
  local val2="$2"
  local strict="${3:-0}"
  local int1="${val1%%.*}"
  local int2="${val2%%.*}"
  local dec1="${val1#*.}"
  local dec2="${val2#*.}"
  [[ "$val1" != *.* ]] && dec1="0"
  [[ "$val2" != *.* ]] && dec2="0"
  [ "$int1" = "-0" ] && int1="0"
  [ "$int2" = "-0" ] && int2="0"
  if (( int1 > int2 )); then
    return 0
  elif (( int1 < int2 )); then
    return 1
  fi
  local len1=${#dec1}
  local len2=${#dec2}
  if (( len1 < len2 )); then
    while (( ${#dec1} < len2 )); do dec1="${dec1}0"; done
  elif (( len2 < len1 )); then
    while (( ${#dec2} < len1 )); do dec2="${dec2}0"; done
  fi
  if (( dec1 > dec2 )); then
    return 0
  elif (( dec1 < dec2 )); then
    return 1
  fi
  if [ "$strict" = "1" ]; then
    return 1 # Rejected as inclusive equality was disabled
  fi
  return 0
}
shell_cli_math_is_greater_or_equal() {
  shell_cli_math_compare_float "$1" "$2" "$3"
  return $?
}
shell_cli_math_is_less_or_equal() {
  shell_cli_math_compare_float "$2" "$1" "$3"
  return $?
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/utils/math.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/utils/strings.sh
shell_cli_string_wrap() {
  local raw_text="$1"
  local target_width="${2:-80}"
  local term_cols
  if term_cols=$(tput cols 2>/dev/null); then
    if [ "$term_cols" -lt "$target_width" ] && [ "$term_cols" -gt 20 ]; then
      target_width="$term_cols"
    fi
  fi
  if [ "$target_width" -gt 120 ]; then
    target_width=120
  fi
  local line=""
  for word in $raw_text; do
    if [ -z "$line" ]; then
      line="$word"
    elif (( ${#line} + ${#word} + 1 <= target_width )); then
      line+=" $word"
    else
      echo "$line"
      line="$word"
    fi
  done
  [ -n "$line" ] && echo "$line"
  return 0
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/utils/strings.sh
#





#
##:: [FILE INI] /home/rianna/Projetos/Shell-CLI/src/vars.sh
declare -g SHELL_CLI_PROCESS_LOCK_PID=""
declare -g SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
declare -g SHELL_CLI_ACTIVE_PKG=""
declare -g SHELL_CLI_ACTIVE_ROOT_PATH=""
declare -g SHELL_CLI_ACTIVE_COMMAND_TREE=""
declare -g SHELL_CLI_TRIGGER_HELP="0"
declare -g SHELL_CLI_TRIGGER_INTERACTIVE="0"
declare -g SHELL_CLI_VALIDATED_VALUE=""
declare -ga SHELL_CLI_VALIDATED_ARRAY=()
declare -gA SHELL_CLI_VALIDATED_ASSOC=()
declare -g VALIDATION_ERROR_MSG=""
declare -gA CORE_METAFLAG_DEFAULTS=(
  ["short"]=""
  ["long"]=""
  ["type"]="string"
  ["array"]="0"
  ["assoc"]="0"
  ["required"]="0"
  ["default"]=""
  ["enum"]=""
  ["assoc_keys"]=""
  ["min"]=""
  ["max"]=""
  ["min_array"]=""
  ["max_array"]=""
  ["regex"]=""
  ["description"]=""
  ["tipinput"]=""
  ["validate"]=""
  ["transform"]=""
)
declare -ga CORE_METAFLAG_DEFAULTS_ORDER=(
  "short" "long" "type" "array" "assoc" "required" "default"
  "enum" "assoc_keys" "min" "max" "min_array" "max_array"
  "regex" "description" "tipinput" "validate" "transform"
)
declare -g SHELL_CLI_RUNTIME_PKG=""
declare -g SHELL_CLI_RUNTIME_COMMAND_TREE=""
declare -g SHELL_CLI_RUNTIME_FN_VALIDATE=""
declare -g SHELL_CLI_RUNTIME_FN_ACTION=""
declare -gA SHELL_CLI_RUNTIME_CMD=()
SHELL_CLI_RUNTIME_CMD["cmd"]=""
SHELL_CLI_RUNTIME_CMD["summary"]=""
SHELL_CLI_RUNTIME_CMD["description"]=""
declare -ga SHELL_CLI_RUNTIME_FLAG_ORDER=()
declare -gA SHELL_CLI_RUNTIME_FLAG_LONGNAME=()
declare -gA SHELL_CLI_RUNTIME_FLAG_SHORTNAME=()
declare -gA SHELL_CLI_RUNTIME_RAW_INPUTS=()
shell_cli_runtime_reset() {
  SHELL_CLI_TRIGGER_HELP="0"
  SHELL_CLI_TRIGGER_INTERACTIVE="0"
  SHELL_CLI_VALIDATED_VALUE=""
  VALIDATION_ERROR_MSG=""
  declare -gA SHELL_CLI_RUNTIME_FLAG_LONGNAME=()
  declare -gA SHELL_CLI_RUNTIME_FLAG_SHORTNAME=()
  declare -gA SHELL_CLI_RUNTIME_RAW_INPUTS=()
  declare -ga SHELL_CLI_VALIDATED_ARRAY=()
  declare -gA SHELL_CLI_VALIDATED_ASSOC=()
  SHELL_CLI_RUNTIME_PKG=""
  SHELL_CLI_RUNTIME_COMMAND_TREE=""
  SHELL_CLI_RUNTIME_FN_VALIDATE=""
  SHELL_CLI_RUNTIME_FN_ACTION=""
  declare -gA SHELL_CLI_RUNTIME_CMD=()
  SHELL_CLI_RUNTIME_CMD["cmd"]=""
  SHELL_CLI_RUNTIME_CMD["summary"]=""
  SHELL_CLI_RUNTIME_CMD["description"]=""
  declare -ga SHELL_CLI_RUNTIME_FLAG_ORDER=()
  local current_var_symbol
  while IFS= read -r current_var_symbol || [ -n "$current_var_symbol" ]; do
    [ -z "$current_var_symbol" ] && continue
    unset "$current_var_symbol"
  done <<< "$(compgen -v SHELL_CLI_RUNTIME_FLAG_)"
  return 0
}
##:: [FILE END] /home/rianna/Projetos/Shell-CLI/src/vars.sh
#





