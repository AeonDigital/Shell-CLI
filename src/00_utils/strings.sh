#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/strings.sh
# DESCRIPTION: Native utility operations processing safe character wrapping
#              and dynamic terminal geometry line adjustments.
# ==============================================================================

# shell_cli_utils_string_wrap — formats long paragraphs into word-wrapped lines.
#
# Arguments:
# - text: The comprehensive raw text string sentence to be wrapped.
# - max_width: Optional static numeric upper boundary character width limit.
#     Defaults to 80 characters if left empty or unassigned.
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
shell_cli_utils_string_wrap() {
  local raw_text="${1}"
  local target_width="${2:-80}"
  local term_cols=""

  # Capture the current terminal window column geometry count dynamically
  if term_cols=$(tput cols 2>/dev/null); then
    # If the user terminal window is narrower than our limit, adapt to its width
    if [ "${term_cols}" -lt "${target_width}" ] && [ "${term_cols}" -gt 20 ]; then
      target_width="${term_cols}"
    fi
  fi

  # Enforce hard boundaries constraint ceiling to protect horizontal standard
  if [ "${target_width}" -gt 120 ]; then
    target_width="120"
  fi

  # Process paragraph lines natively utilizing the system standard word wrap calculator
  local line=""
  for word in ${raw_text}; do
    if [ -z "${line}" ]; then
      line="${word}"
    elif (( ${#line} + ${#word} + 1 <= target_width )); then
      line+=" ${word}"
    else
      echo "${line}"
      line="${word}"
    fi
  done

  [ -n "${line}" ] && echo "${line}"
  return 0
}
