#!/usr/bin/env bash

# shell_cli_type_normalize_email - normalize 'email' values.
#
# Arguments:
# - value: raw input string.
#
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes all control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid email address;
#   only ensures a safe and clean format.
#
# Returns:
# - Outputs the normalized string to stdout.
# - If the input is not a valid email, the original string is echoed.
shell_cli_type_normalize_email() {
  shell_cli_type_normalize_string "${1}"
}



# shell_cli_type_validate_email - validate 'email' values.
#
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
#
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Uses a regex to check structural validity:
#   * Local part: letters, digits, and allowed symbols (._%+-).
#   * '@' separator.
#   * Domain part: letters, digits, hyphens, dots, or punycode prefix 'xn--'.
#   * TLD: at least 2 alphabetic characters.
# - Supports internationalized domain names (IDN) via punycode, e.g.:
#   * "bücher.de" = "xn--bcher-kva.de"
# - Does not check for actual domain existence or deliverability,
#   only structural correctness.
#
# Returns:
# - 0: validation success (value matches email regex).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_email() {
  local value="${1}"
  local aux="${2}"

  # Enforce strict terminal and structural string safety first
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  local email_regex="^[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+|xn--[A-Za-z0-9-]+)\.[A-Za-z]{2,}$"
  if [[ ! "${value}" =~ ${email_regex} ]]; then
    return 1
  fi

  return 0
}
