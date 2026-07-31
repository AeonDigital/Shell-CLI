#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/strings.sh
# DESCRIPTION: Native utility operations processing safe character wrapping
#              and dynamic terminal geometry line adjustments.
# ==============================================================================

# shell_cli_utils_string_wrap — formats long paragraphs into word-wrapped lines.
#
# Arguments:
# - rawText: The comprehensive raw text string sentence to be wrapped.
# - targetWidth: Optional static numeric upper boundary character width limit.
#     Defaults to 80 characters if left empty or unassigned.
# - indentFirst: Optional positive integer defining indentation width for the first line.
#     Defaults to 0 characters if left empty or unassigned.
# - indentRest: Optional positive integer defining indentation width for subsequent lines.
#     Defaults to 0 characters if left empty or unassigned.
#
# Returns:
# - 0: Always terminates with success echoing the formatted paragraphs.
#
# Behavioral Details:
# - Dynamic terminal adaptation: Automatically detects terminal width via tput(1).
#     If terminal width is smaller than max_width, adapts to terminal width.
# - Hard ceiling constraint: Maximum output width capped at 120 characters,
#     regardless of terminal width or max_width parameter value.
# - Terminal minimum: Requires terminal width >= 20 characters for adaptation.
# - Indentation-aware wrapping: Dynamically reduces available text line width by 
#     the current active indentation size to strictly prevent horizontal overflow.
shell_cli_utils_string_wrap() {
  local rawText="${1}"
  local targetWidth="${2:-80}"
  local indentFirst="${3:-0}"
  local indentRest="${4:-0}"
  local maxColumns=""

  # Capture the current terminal window column geometry count dynamically
  if maxColumns=$(tput cols 2>/dev/null); then
    # If the user terminal window is narrower than our limit, adapt to its width
    if [ "${maxColumns}" -lt "${targetWidth}" ] && [ "${maxColumns}" -gt 20 ]; then
      targetWidth="${maxColumns}"
    fi
  fi

  # Enforce hard boundaries constraint ceiling to protect horizontal standard
  if [ "${targetWidth}" -gt 120 ]; then
    targetWidth="120"
  fi

  # Gerar as strings de espaços em branco para a indentação
  local prefixFirst=""
  local prefixRest=""
  if [ "${indentFirst}" -gt 0 ]; then
    printf -v prefixFirst "%${indentFirst}s" ""
  fi
  if [ "${indentRest}" -gt 0 ]; then
    printf -v prefixRest "%${indentRest}s" ""
  fi

  local line=""
  local word=""
  local inFirstLine="1"
  local useIndentLength="${indentFirst}"
  local usePrefix="${prefixFirst}"


  for word in ${rawText}; do
    if [ -z "${line}" ]; then
      line="${word}"
    elif (( useIndentLength + ${#line} + ${#word} + 1 <= targetWidth )); then
      line+=" ${word}"
    else
      echo "${usePrefix}${line}"
      
      inFirstLine=0
      useIndentLength="${indentRest}"
      usePrefix="${prefixRest}"
      
      line="${word}"
    fi
  done

  if [ -n "${line}" ]; then
    echo "${usePrefix}${line}"
  fi

  return 0
}
