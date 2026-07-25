#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/13_validate.sh
# DESCRIPTION: allows you to configure a series of validator functions to be 
#   executed against the received value.
# ==============================================================================

declare -gA METAFLAG_validate=()
METAFLAG_validate["long"]="validate"
METAFLAG_validate["short"]=""
METAFLAG_validate["type"]="function"
METAFLAG_validate["accept_values"]=""

METAFLAG_validate["description"]="Pointer to indexed array with all validate functions to call for this value."
METAFLAG_validate["tipinput"]=""

METAFLAG_validate["default"]=""
METAFLAG_validate["required"]=false

METAFLAG_validate["normalize"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""

METAFLAG_validate["is_array"]=true
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""

METAFLAG_validate["is_assoc"]=false
METAFLAG_validate["required_keys"]=""





# shell_cli_metaflag_property_validate_validate metaflag 'validate'.
#
# Arguments:
# - fval: value (normalizated and validate by type).
# - fassoc: name of associative array with all flag definitions.
#
# Returns:
# - 0: if the value can be used in this flag.
# - 1: if the value cannot be used in this flag.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'
shell_cli_metaflag_property_validate_validate() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "$fval" = "" ]; then
    return 0
  fi

  if ! shell_cli_utils_array_is_indexed "$fval"; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an indexed array (declare -a)."
    return 1
  fi

  local -n ref_validate="$fval"
  for fn_validate in "${ref_validate[@]}"; do
    if ! declare -f "$fn_validate" >/dev/null; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="validation function does not exist ( fn='${fn_validate}' )."
      return 1
    fi
  done

  return 0
}
