#!/usr/bin/env bash

declare -gA METAFLAG_is_assoc=()
METAFLAG_is_assoc["long"]="is_assoc"
METAFLAG_is_assoc["short"]=""
METAFLAG_is_assoc["type"]="bool"
METAFLAG_is_assoc["accept_values"]=""

METAFLAG_is_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_is_assoc["tipinput"]=""

METAFLAG_is_assoc["default"]="0"
METAFLAG_is_assoc["required"]=false

METAFLAG_is_assoc["normalize"]=""
METAFLAG_is_assoc["min"]=""
METAFLAG_is_assoc["max"]=""
METAFLAG_is_assoc["regex"]=""
METAFLAG_is_assoc["validate"]=""
METAFLAG_is_assoc["transform"]=""

METAFLAG_is_assoc["is_array"]=false
METAFLAG_is_assoc["min_array"]=""
METAFLAG_is_assoc["max_array"]=""

METAFLAG_is_assoc["is_assoc"]=false
METAFLAG_is_assoc["required_keys"]=""





# shell_cli_metaflag_property_validate_is_assoc - validate metaflag 'is_assoc'.
#
# Arguments:
# - fval: value (normalized and validated by type).
# - fassoc: name of associative array with all flag definitions.
#
# Behavior:
# - Ensures that the 'is_assoc' property is explicitly defined (cannot be empty).
# - Checks consistency with 'is_array':
#   * If 'is_assoc=true' and 'is_array=true' simultaneously, validation fails.
# - On failure, stores an error message in
#   'SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE'.
#
# Returns:
# - 0: validation success (value non-empty and consistent with 'is_array').
# - 1: validation failure (empty or conflicting configuration).
shell_cli_metaflag_property_validate_is_assoc() {
  local fval="${1}"
  local fassoc="${2}"
  SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""

  if [ "${fval}" = "" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
    return 1
  fi

  local -n __assoc="${fassoc}"
  local _array="${__assoc["is_array"]}"

  if [ "${fval}" = "1" ] && [ "${_array}" = "1" ]; then
    SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'is_assoc=true' and 'is_array=true' simultaneously."
    return 1
  fi

  return 0
}



# shell_cli_metaflag_check_input_is_assoc - check input for metaflag 'is_assoc'.
#
# Arguments:
# - inputVal: value provided by user input.
# - typeVal: type of value.
# - ruleVal: current value of this property (boolean indicator).
#
# Behavior:
# - Validates whether the input should be treated as an associative map.
# - If 'ruleVal=0' (false) or input is empty, no validation is applied.
# - If input is already an associative array, passes through unchanged and
#   stores its name in SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE.
# - Otherwise, attempts to parse the input string as a serialized JSON‑like
#   structure using 'shell_cli_parse_sjson_to_assoc'.
# - On parse failure, stores the parser's error message in
#   SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE.
# - On success:
#   * Stores the name of the internal parsed assoc object
#     ('SHELL_CLI_PARSE_SJSON_TO_ASSOC') in SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE.
#   * Stores the deserialized key‑value pairs in
#     SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC.
#   * Preserves the declaration order of keys in
#     SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER.
#
# Returns:
# - 0: validation success (input accepted as associative map).
# - 1: validation failure (input not compatible with associative format).
shell_cli_metaflag_check_input_is_assoc() {
  local inputVal="${1}"
  local typeVal="${2}"
  local ruleVal="${3}"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()

  if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
    return 0
  fi

  if shell_cli_utils_array_is_assoc "${inputVal}"; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
    return 0
  fi

  shell_cli_parse_sjson_to_assoc "${inputVal}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE}"
    return 1
  else
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="SHELL_CLI_PARSE_SJSON_TO_ASSOC"
    SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=("${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[@]}")

    local k=""
    local v=""
    for k in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC[@]}"; do
      v="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[${k}]}"
      SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC["${k}"]="${v}"
    done
  fi

  return 0
}
