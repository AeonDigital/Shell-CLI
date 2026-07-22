#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/10_email.sh
# DESCRIPTION: 
# ==============================================================================

# shell_cli_type_normalize_email normalize 'email' value.
#
# Arguments:
# - value: raw value.
#
# Returns:
# - Outputs normalizated value.
#   or the original string otherwise.
shell_cli_type_normalize_email() {
  shell_cli_type_normalize_string_code_text_trim "${1}"
}



# shell_cli_type_validate_email validate 'email'.
#
# Arguments:
# - value: non empty normalizated value.
# - aux: optional auxiliary configuration.
#
# Returns:
# - 0: if the value is a valid representative of this type
# - 1: if the value is not a valid representative of this type.
# - 10: if the value contains any control characters.
shell_cli_type_validate_email() {
  local value="$1"
  local aux="$2"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "$value"; then
    return 10
  fi

  local email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
  if [[ ! "$value" =~ $email_regex ]]; then
    return 1
  fi

  return 0
}
