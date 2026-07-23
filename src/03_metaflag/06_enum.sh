#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 03_metaflag/06_enum.sh
# DESCRIPTION: specifies a JSON array with the accepted values or aliases.
#   Mandatory if type is set to 'enum'. Rejects definitions that fail alias 
#   syntax rules.
# ==============================================================================

declare -gA METAFLAG_enum=()
METAFLAG_enum["long"]="enum"
METAFLAG_enum["short"]=""
METAFLAG_enum["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_enum["tipinput"]=""
METAFLAG_enum["type"]="text"
METAFLAG_enum["enum"]=""

METAFLAG_enum["required"]=false
METAFLAG_enum["default"]=""

METAFLAG_enum["array"]=true
METAFLAG_enum["assoc"]=false
METAFLAG_enum["assoc_keys"]=""

METAFLAG_enum["normalize"]=""
METAFLAG_enum["validate"]=""
METAFLAG_enum["transform"]=""
METAFLAG_enum["regex"]=""

METAFLAG_enum["min"]=""
METAFLAG_enum["max"]=""
METAFLAG_enum["min_array"]=""
METAFLAG_enum["max_array"]=""



# shell_cli_metaflag_property_validate_enum metaflag 'enum'.
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
shell_cli_metaflag_property_validate_enum() {
  local fval="$1"
  local fassoc="$2"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  local -n __assoc="${fassoc}"
  local _type="${__assoc["type"]}"

  if [ "$_type" != "enum" ]; then
    if [ "$fval" != "" ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'enum' for a non 'type=$_type' flag."
      return 1
    fi
  else
    if [ "$fval" = "" ]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="flags with 'type=enum' must declare 'enum' property."
      return 1
    fi

    local str_declare=$(declare -p "$fval" 2>/dev/null)
    if [[ ! "$str_declare" =~ ^"declare -A" ]]; then
      SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '$fval' must be an associative array (declare -A)."
      return 1
    fi
  fi

  return 0
}



# shell_cli_metaflag_check_input_enum checks whether the input flag 
# value matches the configuration of this property.
#
# Arguments:
# - inputVal: value inputed (normalizated and validate by type).
# - ruleVal: current value of this property.
#
# Returns:
# - 0: if valid.
#      The new value after check will be stored in
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE'
# - 1: if invalid.
#      In this case, an error message will be stored in 
#      'SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE'
shell_cli_metaflag_check_input_enum() {
  local inputVal="$1"
  local ruleVal="$2"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""

  if [ "$inputVal" = "" ]; then
    return 0
  fi

  local -n flagEnum="${ruleVal}"
  local k=""
  local v=""
  for k in "${!flagEnum[@]}"; do
    v="${flagEnum[$k]}"

    if [ "$inputVal" = "$k" ] || [ "$inputVal" = "$v" ]; then
      SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="$k"
      return 0
    fi
  done

  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="must be a '$ruleVal' collection member; value='$inputVal'"
  return 1
}