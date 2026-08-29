#!/usr/bin/env bash

# shell_cli_type_normalize_fullurl — normalize 'fullurl' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid full URL; only ensures
#   a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized fullurl candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_fullurl() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_fullurl — validate 'fullurl' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Applies a regex that enforces explicit schema protocol definitions (http, https,
#   ftp, file) followed by hostname validation.
# - Regex also allows:
#   + Optional port numbers (e.g., ":8080").
#   + Optional path segments (e.g., "/index.html").
#   + Optional query strings (e.g., "?id=123").
#   + Optional fragments (e.g., "#section").
# - If the regex matches, the value is considered valid.
# - If not, the value is considered invalid.
# - Does not check for actual reachability of the URL, only structural correctness
#   and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a full URL).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_fullurl() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # Enforces explicit schema protocol definitions followed by hostname validation
  local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
  if [[ "${value}" =~ ${url_regex} ]]; then
    return 0
  fi

  return 1
}
