#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/math.sh
# DESCRIPTION: Native arbitrary-precision string math library processing 
#              decimal and float comparison boundaries in pure Bash.
# ==============================================================================

# shell_cli_utils_math_compare_float — compares two string-formatted decimal numbers.
#
# Arguments:
# - val1: The first string decimal number to compare. Supports negative decimals
#     (e.g., "-5.23"). Automatically normalizes incomplete decimals (e.g., ".5" → "0.5").
# - val2: The second string decimal number acting as the boundary threshold.
#     Supports the same negative/decimal formatting as val1.
# - strict_mode: If "1", forces exclusive inequality (e.g., > or < instead of >= or <=).
#     Defaults to "0" (inclusive inequality).
#
# Returns:
# - 0: If val1 is strictly greater than val2 (or equal when strict_mode=0).
# - 1: If val1 is less than val2 (or equal when strict_mode=1).
#
# Special Cases:
# - Negative number handling: Positive values always exceed negative values.
# - Zero equality: Both -0.0 and 0.0 are treated as mathematically identical.
# - Decimal normalization: Partial decimals (.5) are internally normalized to 0.5.
shell_cli_utils_math_compare_float() {
  local val1="${1}"
  local val2="${2}"
  local strict="${3:-0}"

  # 1. Handle signs explicitly to support negative floats natively
  local sign1="+"
  local sign2="+"
  [[ "${val1}" =~ ^- ]] && sign1="-"
  [[ "${val2}" =~ ^- ]] && sign2="-"

  # Strip signs for absolute processing later
  local abs1="${val1#-}"
  local abs2="${val2#-}"

  # Extract integer and decimal components using native pattern stripping
  local int1="${abs1%%.*}"
  local int2="${abs2%%.*}"
  local dec1="${abs1#*.}"
  local dec2="${abs2#*.}"

  # Fallback to zero if no decimal point exists in the string sequence
  [[ "${abs1}" != *.* ]] && dec1="0"
  [[ "${abs2}" != *.* ]] && dec2="0"

  # Normalize empty integers (e.g. .5 -> 0.5)
  [[ -z "${int1}" ]] && int1="0"
  [[ -z "${int2}" ]] && int2="0"

  # If signs are different, the positive one is always greater
  if [[ "${sign1}" != "${sign2}" ]]; then
    if [[ "${sign1}" == "+" && ( "${int1}" -ne 0 || "${dec1}" -ne 0 ) ]]; then
      return 0
    elif [[ "${sign2}" == "+" && ( "${int2}" -ne 0 || "${dec2}" -ne 0 ) ]]; then
      return 1
    fi
    # If both evaluate mathematically to 0 (e.g. -0.0 vs 0.0), proceed to equality check
  fi

  # Determine if we need to invert the comparison logic (when both are negative)
  local invert=0
  [[ "${sign1}" == "-" && "${sign2}" == "-" ]] && invert=1

  # 2. Coordinate primary integer comparison logic
  if (( ${int1} > ${int2} )); then
    [[ "${invert}" -eq 1 ]] && return 1 || return 0
  elif (( ${int1} < ${int2} )); then
    [[ "${invert}" -eq 1 ]] && return 0 || return 1
  fi

  # 3. Integer components are equal: normalize decimal length matrices (Zero padding)
  local len1=${#dec1}
  local len2=${#dec2}

  if (( ${len1} < ${len2} )); then
    while (( ${#dec1} < ${len2} )); do dec1="${dec1}0"; done
  elif (( ${len2} < ${len1} )); then
    while (( ${#dec2} < ${len1} )); do dec2="${dec2}0"; done
  fi

  # Remove leading zeros inside arithmetic context to prevent octal parsing errors
  dec1=$((10#${dec1}))
  dec2=$((10#${dec2}))

  # 4. Coordinate secondary fractional comparison logic
  if (( ${dec1} > ${dec2} )); then
    [[ "${invert}" -eq 1 ]] && return 1 || return 0
  elif (( ${dec1} < ${dec2} )); then
    [[ "${invert}" -eq 1 ]] && return 0 || return 1
  fi

  # 5. Values are mathematically identical: evaluate strict operational parameters
  if [ "${strict}" = "1" ]; then
    return 1 # Rejected as inclusive equality was disabled
  fi

  return 0
}

# shell_cli_utils_math_is_greater_or_equal — asserts if val1 is higher or equal 
# than val2 bounds.
#
# Arguments:
# - val1: The first string decimal number to compare.
# - val2: The second string decimal number acting as the boundary threshold.
#
# Returns:
# - 0: If the verification condition is perfectly satisfied (val1 >= val2).
# - 1: If the input falls short of the expected boundary range (val1 < val2).
shell_cli_utils_math_is_greater_or_equal() {
  shell_cli_utils_math_compare_float "${1}" "${2}" "0"
  return $?
}

# shell_cli_utils_math_is_less_or_equal — asserts if val1 is lower or equal 
# than val2 bounds.
#
# Arguments:
# - val1: The first string decimal number to compare.
# - val2: The second string decimal number acting as the boundary threshold.
#
# Returns:
# - 0: If the verification condition is perfectly satisfied (val1 <= val2).
# - 1: If the input exceeds the expected boundary range (val1 > val2).
shell_cli_utils_math_is_less_or_equal() {
  shell_cli_utils_math_compare_float "${2}" "${1}" "0"
  return $?
}

# shell_cli_utils_math_is_greater_than — asserts if val1 is strictly greater 
# than val2 bounds.
#
# Arguments:
# - val1: The first string decimal number to compare.
# - val2: The second string decimal number acting as the boundary threshold.
#
# Returns:
# - 0: If the verification condition is perfectly satisfied (val1 > val2).
# - 1: If the input is less than or equal to the boundary range (val1 <= val2).
shell_cli_utils_math_is_greater_than() {
  shell_cli_utils_math_compare_float "${1}" "${2}" "1"
  return $?
}

# shell_cli_utils_math_is_less_than — asserts if val1 is strictly less 
# than val2 bounds.
#
# Arguments:
# - val1: The first string decimal number to compare.
# - val2: The second string decimal number acting as the boundary threshold.
#
# Returns:
# - 0: If the verification condition is perfectly satisfied (val1 < val2).
# - 1: If the input is greater than or equal to the boundary range (val1 >= val2).
shell_cli_utils_math_is_less_than() {
  shell_cli_utils_math_compare_float "${2}" "${1}" "1"
  return $?
}
