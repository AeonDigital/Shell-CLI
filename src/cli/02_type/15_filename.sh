#!/usr/bin/env bash

# shell_cli_type_normalize_filename — normalize 'filename' values.
# 
# Arguments:
# - value: raw input string.
# 
# Behavior:
# - Applies string normalization using 'shell_cli_type_normalize_string'.
# - Removes control characters (including '\n', '\r', and '\t').
# - Trims leading and trailing whitespace.
# - Does not guarantee that the resulting string is a valid filename; only ensures
#   a safe and clean format.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the normalized filename candidate.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_type_normalize_filename() {
  local value="${1}"

  # Invoke string normalization
  shell_cli_type_normalize_string "${value}"

  return 0
}



# shell_cli_type_validate_filename — validate 'filename' values.
# 
# Arguments:
# - value: non‑empty normalized string to validate.
# - aux: optional auxiliary configuration (not used in current implementation).
# 
# Behavior:
# - First enforces strict string safety using 'shell_cli_type_validate_string'.
# - Rejects values that contain path separators:
#   + Unix '/'.
#   + Windows '\'.
#   + Empty strings.
# - Rejects unsafe characters commonly invalid in filenames:
#   + Wildcards (?, *).
#   + HTML boundaries (<, >).
#   + Quotes (").
#   + Pipe (|).
#   + Colon (:) — reserved in Windows filenames.
# - Performs a cross‑platform check for Windows drive letters:
#   + Accepts values like "C:" only if they match the drive letter pattern.
#   + Rejects other uses of ':' in filenames.
# - Does not check for actual existence of the file in the filesystem, only structural
#   correctness and safety.
# 
# Returns:
# - 0: validation success (value is structurally valid as a filename).
# - 1: value is not a valid representative of this type.
# - 10: invalid control characters detected.
shell_cli_type_validate_filename() {
  local value="${1}"
  local aux="${2}"

  # Execute validation utility
  if ! shell_cli_type_validate_string "${value}"; then
    return 10
  fi

  # File names cannot possess directory trailing slash or path separator tokens
  if [[ "${value}" == *\/* ]] || [[ "${value}" == *\\* ]] || [ -z "${value}" ]; then
    return 1
  fi

  # Rejects wildcards (?, *), html boundaries (<, >), quotes ("), pipe (|) and Windows
  # colon (:)
  if [[ "${value}" =~ [\*\?\"\<\>\|:] ]]; then
    return 1
  fi

  # Cross-Platform check for Windows drive letters (e.g., C:)
  if [[ "${value}" =~ : ]] && [[ ! "${value}" =~ ^[A-Za-z]: ]]; then
    return 1
  fi

  return 0
}
