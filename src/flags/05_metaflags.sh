#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/metaflags.sh
# DESCRIPTION: 
# ==============================================================================

# Global associative array mapping all mandatory and optional metadata schema keys
# to their framework-specified fallback default compilation values.
declare -gA CORE_METAFLAG_DEFAULTS=()

# Global indexed array defining the strict execution sequence order for evaluating
# metadata schema configuration rules during framework pre-flight compilation loops.
declare -ga CORE_METAFLAG_DEFAULTS_ORDER=()





# METAFLAG_short defines the short alphanumeric alias for a command-line flag.
# It acts as a single-dash alternative (e.g., -s) and must not exceed 3 characters.
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

CORE_METAFLAG_DEFAULTS["short"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("short")



# METAFLAG_long defines the canonical long name identifier for a command-line flag.
# It acts as a double-dash option (e.g., --scope) and maps directly to parsed storage keys.
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
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="32"
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""

CORE_METAFLAG_DEFAULTS["long"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("long")



# METAFLAG_type defines the primitive, structured, or system classification of the flag data.
# It instructs the core engine which specialized native validation routine to trigger.
declare -gA METAFLAG_type=()
METAFLAG_type["short"]=""
METAFLAG_type["long"]="type"
METAFLAG_type["type"]="enum"
METAFLAG_type["array"]="0"
METAFLAG_type["assoc"]="0"
METAFLAG_type["required"]="1"
METAFLAG_type["default"]=""
METAFLAG_type["enum"]="CORE_METAFLAG_TYPES"
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

CORE_METAFLAG_DEFAULTS["type"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("type")



# METAFLAG_array declares whether the flag parameter accepts a structured collection.
# If active (1), the engine parses the payload as a JSON array and validates every item.
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
METAFLAG_array["validate"]=""
METAFLAG_array["transform"]=""

CORE_METAFLAG_DEFAULTS["array"]="0"
CORE_METAFLAG_DEFAULTS_ORDER+=("array")



# METAFLAG_assoc declares whether the flag parameter operates as an associative map.
# Accepts a global variable name pointer or an inline JSON object sequence.
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
METAFLAG_assoc["validate"]=""
METAFLAG_assoc["transform"]=""

CORE_METAFLAG_DEFAULTS["assoc"]="0"
CORE_METAFLAG_DEFAULTS_ORDER+=("assoc")



# METAFLAG_required declares whether the flag must be explicitly supplied by the user.
# If active (1), the framework automatically mandates a non-empty presence check.
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

CORE_METAFLAG_DEFAULTS["required"]="0"
CORE_METAFLAG_DEFAULTS_ORDER+=("required")



# METAFLAG_default defines the fallback value automatically assigned if the user omits the flag.
# Core compiler rules reject schemas where required is true (1) and a default is simultaneously set.
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

CORE_METAFLAG_DEFAULTS["default"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("default")



# METAFLAG_enum specifies a JSON array with the accepted values or aliases.
# Mandatory if type is set to 'enum'. Rejects definitions that fail alias syntax rules.
declare -gA METAFLAG_enum=()
METAFLAG_enum["short"]=""
METAFLAG_enum["long"]="enum"
METAFLAG_enum["type"]="string"
METAFLAG_enum["array"]="1"
METAFLAG_enum["assoc"]="0"
METAFLAG_enum["required"]="0"
METAFLAG_enum["default"]=""
METAFLAG_enum["enum"]=""
METAFLAG_enum["assoc_keys"]=""
METAFLAG_enum["min"]=""
METAFLAG_enum["max"]=""
METAFLAG_enum["min_array"]=""
METAFLAG_enum["max_array"]=""
METAFLAG_enum["regex"]=""
METAFLAG_enum["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_enum["tipinput"]=""
METAFLAG_enum["validate"]=""
METAFLAG_enum["transform"]=""

CORE_METAFLAG_DEFAULTS["enum"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("enum")



# METAFLAG_assoc_keys defines a comma-separated list of mandatory keys for maps.
# Operates exclusively when assoc is active (1) to enforce field presence.
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

CORE_METAFLAG_DEFAULTS["assoc_keys"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("assoc_keys")



# METAFLAG_min enforces the minimum boundary size constraint allowed for the payload.
# Evaluates string/token length or raw numerical boundaries based on the primary type field.
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

CORE_METAFLAG_DEFAULTS["min"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("min")



# METAFLAG_max enforces the maximum boundary size constraint allowed for the payload.
# Evaluates string/token length or raw numerical boundaries based on the primary type field.
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

CORE_METAFLAG_DEFAULTS["max"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("max")



# METAFLAG_min_array defines the minimum number of elements required inside a collection.
# This evaluation is optional and operates exclusively when the array attribute is active (1).
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

CORE_METAFLAG_DEFAULTS["min_array"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("min_array")



# METAFLAG_max_array defines the maximum number of elements allowed inside a collection.
# This evaluation is optional and operates exclusively when the array attribute is active (1).
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

CORE_METAFLAG_DEFAULTS["max_array"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("max_array")



# METAFLAG_regex provisions an optional regular expression verification constraint pattern.
# Evaluates whether incoming values perfectly satisfy native Bash or grep pattern criteria.
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

CORE_METAFLAG_DEFAULTS["regex"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("regex")



# METAFLAG_description maps the essential human documentation text used to render help modules.
# Mandatory framework constraint ensuring zero undocumented features bypass compiler loops.
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
METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""
METAFLAG_description["regex"]=""
METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""

CORE_METAFLAG_DEFAULTS["description"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("description")



# METAFLAG_tipinput specifies the custom interactive question or behavioral guide 
# displayed to the user when the framework operates under strict interactive modes.
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
METAFLAG_tipinput["min"]="4"
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""
METAFLAG_tipinput["regex"]=""
METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""

CORE_METAFLAG_DEFAULTS["tipinput"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("tipinput")



# METAFLAG_validate captures a JSON array of downstream investigator function names.
# Invoked at the absolute tail of validation loops to compute complex domain-specific rules.
declare -gA METAFLAG_validate=()
METAFLAG_validate["short"]=""
METAFLAG_validate["long"]="validate"
METAFLAG_validate["type"]="function"
METAFLAG_validate["array"]="1"
METAFLAG_validate["assoc"]="0"
METAFLAG_validate["required"]="0"
METAFLAG_validate["default"]=""
METAFLAG_validate["enum"]=""
METAFLAG_validate["assoc_keys"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["description"]="Pointer to indexed array with all validate functions to call for this value."
METAFLAG_validate["tipinput"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""

CORE_METAFLAG_DEFAULTS["validate"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("validate")



# METAFLAG_transform captures a JSON array of downstream transformation function names.
# Invoked only after validation succeeds and before the final parsed value is stored.
declare -gA METAFLAG_transform=()
METAFLAG_transform["short"]=""
METAFLAG_transform["long"]="transform"
METAFLAG_transform["type"]="function"
METAFLAG_transform["array"]="1"
METAFLAG_transform["assoc"]="0"
METAFLAG_transform["required"]="0"
METAFLAG_transform["default"]=""
METAFLAG_transform["enum"]=""
METAFLAG_transform["assoc_keys"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""

CORE_METAFLAG_DEFAULTS["transform"]=""
CORE_METAFLAG_DEFAULTS_ORDER+=("transform")



#shell_cli_flag_rules_finalize_register "METAFLAG" "CORE_METAFLAG_DEFAULTS_ORDER"



# # ------------------------------------------------------------------------------
# # PHASE 1: ATOMIC METADATA VALIDATION (FOLLOWING STRICT SPECIFIED ORDER)
# # ------------------------------------------------------------------------------
# for meta_key in "${CORE_METAFLAG_DEFAULTS_ORDER[@]}"; do
#   local current_meta_val="${ref_flag["$meta_key"]}"
#   local meta_spec_array="METAFLAG_${meta_key}"

#   # Verify if the framework schema matrix for the target meta-key exists
#   if ! declare -p "$meta_spec_array" &>/dev/null; then
#     VALIDATION_ERROR_MSG="${err_prefix} :: internal engine layout error. Schema array '${meta_spec_array}' is missing."
#     return 1
#   fi

#   # Invoke the central engine validator to check the developer's assignment
#   if ! shell_cli_flag_validate_value "$current_meta_val" "$meta_spec_array"; then
#     VALIDATION_ERROR_MSG="${VALIDATION_ERROR_MSG} \n[ERR] ${err_prefix}[ key: ${meta_key} ] :: invalid design property."
#     return 1
#   fi
# done





# shell_cli_flag_rules_normalize_all normalizes and populates uninitialized schema metadata keys.
#
# Arguments:
#   - flag_assoc: The string name of the target associative array.
#
# Returns:
#   - 0: Always terminates with success state after dynamically filling missing keys.
shell_cli_flag_rules_normalize_all() {
  local flag_assoc="$1"
  local -n assoc_ref="$flag_assoc"

  # NORMALIZE: Converts developer "true/false" metadata strings into strict "1/0" engine bytes
  local bool_keys=("required" "array" "assoc")
  for b_key in "${bool_keys[@]}"; do
    local val="${assoc_ref["${b_key}"]}"
    if [ "$val" != "" ]; then
      assoc_ref["$b_key"]=$(shell_cli_flag_normalize_bool "$val")
    fi
  done

  # NORMALIZE: Infers and expands partial dates, times, or datetimes for metadata bounds
  local k_type="${assoc_ref["type"]}"
  if [[ "$k_type" =~ ^(date|time|datetime)$ ]]; then
    local bound_keys=("min" "max")
    
    for bound_key in "${bound_keys[@]}"; do
      local b_val="${assoc_ref["$bound_key"]}"
      if [ "$b_val" != "" ]; then
        assoc_ref["$bound_key"]=$(_shell_cli_flag_normalize_${k_type} "$b_val")
      fi
    done
  fi

  # Iteratively evaluate and apply official system fallbacks using data-driven keys
  for key in "${!CORE_METAFLAG_DEFAULTS[@]}"; do
    if [ -z "${assoc_ref["$key"]}" ]; then
      assoc_ref["$key"]="${CORE_METAFLAG_DEFAULTS["$key"]}"
    fi
  done

  return 0
}

# shell_cli_flag_rules_validate normalize and asserts flag specifications.
#
# Arguments:
#   - flag_assoc: The string name of the target associative array.
#
# Returns:
#   - 0: If the configuration schema is structurally intact and logically sound.
#   - 1: If any metadata constraint fails or a logical architectural rule breaks.
shell_cli_flag_rules_validate() {
  local flag_assoc="$1"
  
  # First, ensure all uninitialized metadata keys are filled with system defaults
  shell_cli_flag_rules_normalize_all "$flag_assoc"

  local -n ref_flag="$flag_assoc"

  local err_prefix="[ERR]"
  err_prefix+="[ ${flag_assoc} ]"
  err_prefix+="[ flag: ${ref_flag["long"]} ]"

  local err_key=""



  # ------------------------------------------------------------------------------
  # PHASE 1: CROSS-PROPERTY LOGICAL CONSTRAINTS VERIFICATION
  # ------------------------------------------------------------------------------

  local k_long="${ref_flag["long"]}"
  local k_short="${ref_flag["short"]}"
  local k_type="${ref_flag["type"]}"
  local k_array="${ref_flag["array"]}"
  local k_assoc="${ref_flag["assoc"]}"
  local k_required="${ref_flag["required"]}"
  local k_default="${ref_flag["default"]}"
  local k_enum="${ref_flag["enum"]}"
  local k_assoc_keys="${ref_flag["assoc_keys"]}"
  local k_min="${ref_flag["min"]}"
  local k_max="${ref_flag["max"]}"
  local k_min_array="${ref_flag["min_array"]}"
  local k_max_array="${ref_flag["max_array"]}"
  local k_regex="${ref_flag["regex"]}"
  local k_description="${ref_flag["description"]}"
  local k_tipinput="${ref_flag["tipinput"]}"
  local k_validate="${ref_flag["validate"]}"
  local k_transform="${ref_flag["transform"]}"



  #
  # Key: long
  err_key="[ key: long ]"

  # Rule A1: Required
  if [ "$k_long" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: is required."
    return 1
  fi

  # Rule A2: Reserved Keyword
  if [[ "$k_long" =~ ^(help|interactive)$ ]]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: names 'help' and 'interactive' are reserved."
    return 1
  fi



  #
  # Key: short
  err_key="[ key: short ]"

  # Rule B1: Reserved Keyword
  if [[ "$k_short" =~ ^(h|itr)$ ]]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: names 'h' and 'itr' are reserved."
    return 1
  fi

  # Rule B2: Prevent collision
  if [ "$k_long" = "$k_short" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot be the same as 'long' ( short='$k_short' )."
    return 1
  fi



  #
  # Key: type
  err_key="[ key: type ]"

  # Rule C1: validate 'type'
  if [ "${CORE_METAFLAG_TYPES["$k_type"]}" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid definition ( type='$k_type' )."
    return 1
  fi



  #
  # Key: array
  err_key="[ key: array ]"

  # Rule D1: If is a valid boolean
  if [ "$k_array" != "1" ] && [ "$k_array" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( array='$k_array' )."
    return 1
  fi



  #
  # Key: assoc
  err_key="[ key: assoc ]"

  # Rule E1: If is a valid boolean
  if [ "$k_assoc" != "1" ] && [ "$k_assoc" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( assoc='$k_assoc' )."
    return 1
  fi



  #
  # Key: array | assoc
  err_key="[ key: array, assoc ]"

  # Rule F1: Array vs Assoc exclusivity
  if [ "$k_array" = "1" ] && [ "$k_assoc" = "1" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot declare 'array=true' and 'assoc=true' simultaneously."
    return 1
  fi



  #
  # Key: required
  err_key="[ key: required ]"

  # Rule G1: If is a valid boolean
  if [ "$k_required" != "1" ] && [ "$k_required" != "0" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: expected boolean ( required='$k_required' )."
    return 1
  fi



  #
  # Key: default
  err_key="[ key: default ]"

  # Rule H1: Required vs Default exclusivity
  if [ "$k_required" = "1" ] && [ "$k_default" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot provision a 'default' assignment if 'required=true'."
    return 1
  fi



  #
  # Key: enum
  err_key="[ key: enum ]"

  # Rule I1: Cannot define 'enum' for non 'type=enum' flag
  if [ "$k_type" != "enum" ] && [ "$k_enum" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'enum' for a non 'type=enum' flag."
    return 1
  fi

  # Rule I2: Required 'enum' definition for 'type=enum' flag
  if [ "$k_type" = "enum" ] && [ "$k_enum" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: flags with 'type=enum' must declare 'enum' property."
    return 1
  fi

  # Rule I3: Enum pointer verification
  if [ "$k_type" = "enum" ]; then
    local str_declare=$(declare -p "$k_enum" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_enum' must be an associative array (declare -A)."
      return 1
    fi
  fi



  #
  # Key: assoc_keys
  err_key="[ key: assoc_keys ]"

  # Rule J1: Cannot define 'assoc_keys' for a 'assoc=0' flag
  if [ "$k_assoc" = "0" ] && [ "$k_assoc_keys" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'assoc_keys' for a 'assoc=false' flag."
    return 1
  fi

  # Rule J2: Assoc keys pointer verification
  if [ "$k_assoc_keys" != "" ]; then
    local str_declare=$(declare -p "$k_assoc_keys" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_assoc_keys' must be an indexed array (declare -a)."
      return 1
    fi
  fi



  #
  # Key: min
  err_key="[ key: min ]"

  if [ "$k_min" != "" ]; then
    # Rule K1: Check 'time' 'min'
    if [ "$k_type" = "time" ]; then
      if [[ ! "$k_min" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'time' value ( min='$k_min'; expected HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "0001-01-01 $k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 $k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%H:%M:%S 2>/dev/null || date -j -r "$ts" +%H:%M:%S 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies an invalid or impossible time ( min='$k_min' )."
        return 1
      fi
    fi

    # Rule K2: Check 'date' 'min'
    if [ "$k_type" = "date" ]; then
      if [[ ! "$k_min" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'date' value ( min='$k_min'; expected YYYY-MM-DD )."
        return 1
      fi

      local ts=$(date -d "$k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%Y-%m-%d 2>/dev/null || date -j -r "$ts" +%Y-%m-%d 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent calendar date ( min='$k_min' )."
        return 1
      fi
    fi

    # Rule K3: Check 'datetime' 'min'
    if [ "$k_type" = "datetime" ]; then
      if [[ ! "$k_min" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'datetime' value ( min='$k_min'; expected YYYY-MM-DD HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "$k_min" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$k_min" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      if [ "$k_min" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent timestamp ( min='$k_min' )."
        return 1
      fi
    fi
  fi



  #
  # Key: max
  err_key="[ key: max ]"

  if [ "$k_max" != "" ]; then
    # Rule L1: Check 'time' 'max'
    if [ "$k_type" = "time" ]; then
      if [[ ! "$k_max" =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'time' value ( max='$k_max'; expected HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "0001-01-01 $k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 $k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%H:%M:%S 2>/dev/null || date -j -r "$ts" +%H:%M:%S 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies an invalid or impossible time ( max='$k_max' )."
        return 1
      fi
    fi

    # Rule L2: Check 'date' 'max'
    if [ "$k_type" = "date" ]; then
      if [[ ! "$k_max" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'date' value ( max='$k_max'; expected YYYY-MM-DD )."
        return 1
      fi

      local ts=$(date -d "$k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" +%Y-%m-%d 2>/dev/null || date -j -r "$ts" +%Y-%m-%d 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent calendar date ( max='$k_max' )."
        return 1
      fi
    fi

    # Rule L3: Check 'datetime' 'max'
    if [ "$k_type" = "datetime" ]; then
      if [[ ! "$k_max" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid 'datetime' value ( max='$k_max'; expected YYYY-MM-DD HH:MM:SS )."
        return 1
      fi

      local ts=$(date -d "$k_max" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$k_max" +%s 2>/dev/null)
      local check_val=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      if [ "$k_max" != "$check_val" ] || [ -z "$ts" ]; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: specifies a non-existent timestamp ( max='$k_max' )."
        return 1
      fi
    fi
  fi



  #
  # Key: min | max
  err_key="[ key: min, max ]"

  # Rule M1: Check Range Inversion between 'min' and 'max'
  if [ "$k_min" != "" ] && [ "$k_max" != "" ]; then
    case "$k_type" in
      int)
        if (( $k_min > $k_max )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
        
      float)
        if ! shell_cli_math_is_less_or_equal "$k_min" "$k_max" "0"; then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;

      time|date|datetime)
        local prefix=""
        local fmt="%Y-%m-%d %H:%M:%S"
        
        if [ "$k_type" = "date" ]; then
          fmt="%Y-%m-%d"
        elif [ "$k_type" = "time" ]; then
          prefix="0001-01-01 "
        fi

        local min_sec=$(date -d "${prefix}${k_min}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${k_min}" +%s 2>/dev/null)
        local max_sec=$(date -d "${prefix}${k_max}" +%s 2>/dev/null || date -j -f "$fmt" "${prefix}${k_max}" +%s 2>/dev/null)

        if (( $min_sec > $max_sec )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' limit cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
        
      *)
        if (( $k_min > $k_max )); then
          VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min' length cannot exceed 'max' ( min='$k_min', max='$k_max' )."
          return 1
        fi
        ;;
    esac
  fi



  #
  # Key: min_array
  err_key="[ key: min_array ]"

  # Rule N1: Cannot define 'min_array' for a 'array=0' flag
  if [ "$k_array" = "0" ] &&  [ "$k_min_array" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'min_array' for a 'array=false' flag."
    return 1
  fi



  #
  # Key: max_array
  err_key="[ key: max_array ]"

  # Rule O1: Cannot define 'max_array' for a 'array=0' flag
  if [ "$k_array" = "0" ] &&  [ "$k_max_array" != "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: cannot define 'max_array' for a 'array=false' flag."
    return 1
  fi



  #
  # Key: min_array | max_array
  err_key="[ key: min_array, max_array ]"

  # Rule P1: Check Range Inversion between 'min_array' and 'max_array'
  if [ "$k_min_array" != "" ] && [ "$k_max_array" != "" ]; then
    if (( $k_min_array > $k_max_array )); then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: 'min_array' limit cannot exceed 'max_array' ( min_array='$k_min_array', max_array='$k_max_array' )."
      return 1
    fi
  fi



  #
  # Key: regex
  err_key="[ key: regex ]"

  # Rule Q1: Check regular expression
  if [ "$k_regex" != "" ]; then
    ( [[ "" =~ $k_regex ]] ) 2>/dev/null
    local exit_status=$?

    if [ $exit_status -eq 2 ]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: invalid regular expression ( regex='$k_regex' )."
      return 1
    fi
  fi



  #
  # Key: description
  err_key="[ key: description ]"

  # Rule R1: Required
  if [ "$k_description" = "" ]; then
    VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: is required."
    return 1
  fi



  #
  # Key: validate
  err_key="[ key: validate ]"

  # Rule S1: Check validate functions
  if [ "$k_validate" != "" ]; then
    local str_declare=$(declare -p "$k_validate" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_validate' must be an indexed array (declare -a)."
      return 1
    fi

    local -n ref_validate="$k_validate"
    for fn_validate in "${ref_validate[@]}"; do
      if ! declare -f "$fn_validate" >/dev/null; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: validation function does not exist ( fn='${fn_validate}' )."
        return 1
      fi
    done
  fi



  #
  # Key: transform
  err_key="[ key: transform ]"

  # Rule T1: Check transform functions
  if [ "$k_transform" != "" ]; then
    local str_declare=$(declare -p "$k_transform" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
      VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: pointer '$k_transform' must be an indexed array (declare -a)."
      return 1
    fi

    local -n ref_transform="$k_transform"
    for fn_transform in "${ref_transform[@]}"; do
      if ! declare -f "$fn_transform" >/dev/null; then
        VALIDATION_ERROR_MSG="${err_prefix}${err_key} :: transform function does not exist ( fn='${fn_transform}' )."
        return 1
      fi
    done
  fi

  return 0
}

# shell_cli_flag_rules_validate_all normalize and asserts all flag from same family.
#
# Arguments:
#   - prefix: Prefix used to define all flags under the same family.
#   - order_array: Name of the order array with all flag names.
#
# Returns:
#   - 0: If the configuration schema is structurally intact and logically sound.
#   - 1: If any metadata constraint fails or a logical architectural rule breaks.
shell_cli_flag_rules_finalize_register() {
  local prefix="$1"
  local order_array="$2"

  if [ "$prefix" == "" ]; then
    VALIDATION_ERROR_MSG="[ERR] :: Flag family prefix is required."
    return 1
  fi

  if [ "$order_array" == "" ]; then
    VALIDATION_ERROR_MSG="[ERR] :: Default order array is required."
    return 1
  fi

  local str_declare=$(declare -p "$order_array" 2>/dev/null)
  if [[ ! "$str_declare" =~ ^"declare -a" ]]; then
    VALIDATION_ERROR_MSG="[ERR] :: Invalid default order array. Expected indexed array (declare -a)."
    return 1
  fi

  local -n ref_order_array="$order_array"
  if [ "${#ref_order_array[@]}" == "0" ]; then
    return 0
  fi

  for flag_name in "${ref_order_array[@]}"; do
    local flag_assoc="${prefix}_${flag_name}"

    local str_declare=$(declare -p "$flag_assoc" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      VALIDATION_ERROR_MSG="[ERR] :: Invalid or undefined assoc flag '$flag_assoc'. Expected associative array (declare -A)."
      return 1
    fi

    if ! shell_cli_flag_rules_validate "${flag_assoc}"; then
      echo -e "${VALIDATION_ERROR_MSG}"
      return 1
    fi
  done
}





# shell_cli_flag_normalize_array parses string components into a native indexed array.
#
# Arguments:
#   - value: The verified raw array string sequence (e.g., ['val1', 'val2']).
#
# Side Effects:
#   - Resets and populates the global indexed array SHELL_CLI_NORMALIZATED_ARRAY.
shell_cli_flag_normalize_array() {
  local input="$1"
  local inner="${input#?}"
  inner="${inner%?}"

  # Reset global indexed array cleanly
  SHELL_CLI_NORMALIZATED_ARRAY=()
  
  local current=""
  local idx=0
  local len=${#inner}
  local in_q=0

  while [ "$idx" -lt "$len" ]; do
    local char="${inner:$idx:1}"
    if [ "$in_q" -eq 1 ]; then
      if [ "$char" = "'" ] || [ "$char" = '"' ]; then
        in_q=0
        SHELL_CLI_NORMALIZATED_ARRAY+=("$current")
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

