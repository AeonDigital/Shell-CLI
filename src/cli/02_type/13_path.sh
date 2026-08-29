#!/usr/bin/env bash

# shell_cli_type_normalize_path — normalize 'path' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string corresponds to a valid filesystem
#   path; only ensures a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized path name candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_path() {
  local value="${1}"

  # Invoke core string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_path — validate 'path' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Rejects unsafe characters commonly invalid in paths:
#   + Wildcards (?, *).
#   + HTML boundaries (<, >).
#   + Quotes (").
#   + Pipe (|).
# - Performs a cross‑platform check for Windows drive letters:
#   + Accepts values like "C:" or "D:\folder".
#   + Rejects strings containing ':' that do not match the drive letter pattern.
# - Does not check for actual existence of the path in the filesystem, only structural
#   correctness and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a path).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_path() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # Rejects wildcards (?, *), html boundaries (<, >), quotes (") and pipe (|)
  if [[ "${value}" =~ [\*\?\"\<\>\|] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "${value}" =~ : ]] && [[ ! "${value}" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}
