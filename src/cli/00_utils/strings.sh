#!/usr/bin/env bash

# A read-only, global string containing the native newline character control byte
# (\n).
if [ -z "${codeNL+x}" ]; then
  declare -gr codeNL=$'\n'
fi

# SHELL_CLI_UTILS_STRING_WRAP_LINES — global string tracking word-wrap output content.
# 
# - Dynamic string containing the comprehensive formatted multi-line text block.
# - Updated automatically upon completion of the shell_cli_utils_string_wrap tool.
declare -g SHELL_CLI_UTILS_STRING_WRAP_LINES=""

# SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT — global counter tracking word-wrap lines.
# 
# - Dynamic integer reflecting the exact total count of formatted text lines.
# - Updated automatically upon completion of the shell_cli_utils_string_wrap tool.
declare -g SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT="0"

# SHELL_CLI_FN_RETURN — global string tracking the final returned output block.
# 
# - Dynamic string acting as the central buffer for functional return values.
# - Updated automatically upon completion of the targeted utility execution.
declare -g SHELL_CLI_FN_RETURN=""





# shell_cli_utils_trim_line — Strip leading and trailing whitespace characters from
# a string.
# 
# Arguments:
# - str: The raw input string containing potential leading or trailing whitespace.
# 
# Returns:
# - Assigns the fully cleaned and trimmed string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_trim_line() {
  local str="${1}"
  str="${str#"${str%%[![:space:]]*}"}" # trim L
  SHELL_CLI_FN_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}

# shell_cli_utils_trimL_line — Strip leading whitespace characters from the left
# side of a string.
# 
# Arguments:
# - str: The raw input string containing potential leading spaces or tabs.
# 
# Returns:
# - Assigns the left-trimmed string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_trimL_line() {
  local str="${1}"
  SHELL_CLI_FN_RETURN="${str#"${str%%[![:space:]]*}"}" # trim L
}

# shell_cli_utils_trimR_line — Strip trailing whitespace characters from the right
# side of a string.
# 
# Arguments:
# - str: The raw input string containing potential trailing spaces or tabs.
# 
# Returns:
# - Assigns the right-trimmed string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_trimR_line() {
  local str="${1}"
  SHELL_CLI_FN_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}





# shell_cli_utils_to_uppercase — converts an input string variable to uppercase.
# 
# Arguments:
#   - str: The raw input string.
# 
# Returns:
# - Assigns the uppercase string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_to_uppercase() {
  SHELL_CLI_FN_RETURN="${1^^}"
}

# shell_cli_utils_to_lowercase — converts an input string variable to lowercase.
# 
# Arguments:
#   - str: The raw input string.
# 
# Returns:
# - Assigns the lowercase string to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_to_lowercase() {
  SHELL_CLI_FN_RETURN="${1,,}"
}





# shell_cli_utils_string_wrap — formats long paragraphs into word-wrapped lines.
# 
# Arguments:
# - rawText: The comprehensive raw text string sentence to be wrapped.
# - targetWidth: Optional static numeric upper boundary character width limit. Defaults
#   to 80 characters if left empty or unassigned.
# - indentFirst: Optional positive integer defining indentation width for the first
#   line. Defaults to 0 characters if left empty or unassigned.
# - indentRest: Optional positive integer defining indentation width for subsequent
#   lines. Defaults to 0 characters if left empty or unassigned.
# 
# Global Outputs:
# - SHELL_CLI_UTILS_STRING_WRAP_LINES: String containing the full formatted text.
# - SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT: Integer reflecting the exact total count
#   of formatted lines calculated during execution.
# 
# Returns:
# - 0: Always terminates with success isolating side-effects until the final block.
shell_cli_utils_string_wrap() {
  local rawText="${1}"
  local targetWidth="${2:-80}"
  local indentFirst="${3:-0}"
  local indentRest="${4:-0}"
  local maxColumns=""
  local totalLines=0
  local outputBuffer=""

  # Reset global telemetry metric tracking boundary across isolated execution cycles
  SHELL_CLI_UTILS_STRING_WRAP_LINES=""
  SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT=0

  # Capture the current terminal window column geometry count dynamically
  local currentCols="${COLUMNS:-80}"

  # If the user terminal window is narrower than our limit, adapt to its width
  if [ "${currentCols}" -lt "${targetWidth}" ] && [ "${currentCols}" -gt 20 ]; then
    targetWidth="${currentCols}"
  fi

  # Enforce hard boundaries constraint ceiling to protect horizontal standard
  if [ "${targetWidth}" -gt 120 ]; then
    targetWidth="120"
  fi

  # Generate whitespace indentation prefix strings
  local prefixFirst=""
  local prefixRest=""
  if [ "${indentFirst}" -gt 0 ]; then
    printf -v prefixFirst "%${indentFirst}s" ""
  fi
  if [ "${indentRest}" -gt 0 ]; then
    printf -v prefixRest "%${indentRest}s" ""
  fi

  local line=""
  local currentToken=""
  local isSpacesToken=""
  local inFirstLine="1"
  local useIndentLength="${indentFirst}"
  local usePrefix="${prefixFirst}"

  local i=0
  local char=""
  for (( i=0; i<${#rawText}; i++ )); do
    char="${rawText:$i:1}"

    # Check for literal newline character to enforce immediate breaking behavior
    if [ "${char}" = $'\n' ]; then
      # Flush existing active token before breaking the line
      if [ -n "${currentToken}" ]; then
        if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
          line+="${currentToken}"
        else
          if [ "${isSpacesToken}" -eq 0 ]; then
            outputBuffer+="${usePrefix}${line}${codeNL}"
            ((totalLines++))

            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line="${currentToken}"
          else
            local remainingSpaces="${currentToken}"
            while (( useIndentLength + ${#line} < targetWidth && ${#remainingSpaces} > 0 )); do
              line+="${remainingSpaces:0:1}"
              remainingSpaces="${remainingSpaces:1}"
            done
            outputBuffer+="${usePrefix}${line}${codeNL}"
            ((totalLines++))

            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line=""
            while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
              local chunkLength=$(( targetWidth - useIndentLength ))
              outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
              ((totalLines++))

              remainingSpaces="${remainingSpaces:$chunkLength}"
            done
            line="${remainingSpaces}"
          fi
        fi
        currentToken=""
      fi

      # Buffer current line layout and transition to the next block structure
      outputBuffer+="${usePrefix}${line}${codeNL}"
      ((totalLines++))

      inFirstLine=0
      useIndentLength="${indentRest}"
      usePrefix="${prefixRest}"
      line=""
      continue
    fi

    # Identify type of character to split raw text into clean distinct tokens
    local isCharSpace=0
    if [[ "${char}" =~ [[:space:]] ]]; then
      isCharSpace=1
    fi

    # Process and flush previous token when transitioning between word and space
    if [ -n "${currentToken}" ]; then
      if [ "${isCharSpace}" -ne "${isSpacesToken}" ]; then
        if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
          line+="${currentToken}"
        else
          if [ "${isSpacesToken}" -eq 0 ]; then
            outputBuffer+="${usePrefix}${line}${codeNL}"
            ((totalLines++))

            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line="${currentToken}"
          else
            local remainingSpaces="${currentToken}"
            while (( useIndentLength + ${#line} < targetWidth && ${#remainingSpaces} > 0 )); do
              line+="${remainingSpaces:0:1}"
              remainingSpaces="${remainingSpaces:1}"
            done
            outputBuffer+="${usePrefix}${line}${codeNL}"
            ((totalLines++))

            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line=""

            while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
              local chunkLength=$(( targetWidth - useIndentLength ))
              outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
              ((totalLines++))

              remainingSpaces="${remainingSpaces:$chunkLength}"
            done
            line="${remainingSpaces}"
          fi
        fi
        currentToken=""
      fi
    fi

    # Initialize token type tracking context on fresh boundary detections
    if [ -z "${currentToken}" ]; then
      isSpacesToken="${isCharSpace}"
    fi
    currentToken+="${char}"
  done

  # Flush final remaining trailing token buffer to active line layout
  if [ -n "${currentToken}" ]; then
    if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
      line+="${currentToken}"
    else
      if [ "${isSpacesToken}" -eq 0 ]; then
        outputBuffer+="${usePrefix}${line}${codeNL}"
        ((totalLines++))

        inFirstLine=0
        useIndentLength="${indentRest}"
        usePrefix="${prefixRest}"
        line="${currentToken}"
      else
        local remainingSpaces="${currentToken}"
        while (( useIndentLength + ${#line} < targetWidth && ${#remainingSpaces} > 0 )); do
          line+="${remainingSpaces:0:1}"
          remainingSpaces="${remainingSpaces:1}"
        done
        outputBuffer+="${usePrefix}${line}${codeNL}"
        ((totalLines++))

        inFirstLine=0
        useIndentLength="${indentRest}"
        usePrefix="${prefixRest}"
        line=""
        while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
          local chunkLength=$(( targetWidth - useIndentLength ))
          outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
          ((totalLines++))
          remainingSpaces="${remainingSpaces:$chunkLength}"
        done
        line="${remainingSpaces}"
      fi
    fi
  fi

  # Buffer final remaining line layout to standard output context
  if [ -n "${line}" ]; then
    outputBuffer+="${usePrefix}${line}${codeNL}"
    ((totalLines++))
  fi

  # Assign finalized results back into global context only at the very end
  SHELL_CLI_UTILS_STRING_WRAP_LINES="${outputBuffer:0: -1}"
  SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT="${totalLines}"

  return 0
}



# shell_cli_utils_string_replace_placeholder — parses template files to replace custom
# placeholders inline.
# 
# Arguments:
# - filepath: The absolute or relative system path pointing to the source template
#   file.
# - assocPH: Name reference to an active Bash associative array mapping target keys
#   to their corresponding substitution values.
# 
# Global Outputs:
# - SHELL_CLI_FN_RETURN: String containing the full compiled file content with all
#   matched tokens successfully processed and injected.
# 
# Returns:
# - 0: Operation completed successfully or terminated early due to empty content
#   data.
# - 1: Target file does not exist, resolving structural validation context failure.
# - 2: Second argument failed valid data typing validation for an associative array.
shell_cli_utils_string_replace_placeholder() {
  SHELL_CLI_FN_RETURN=""
  local filepath="${1}"
  if [ ! -f "${filepath}" ]; then
    return 1
  fi

  if ! shell_cli_utils_array_is_assoc "${2}"; then
    return 2
  fi
  local -n assocPH="${2}"

  local filecontent=$(< "${filepath}")
  if [ "${filecontent}" = "" ] || [ "${#assocPH[@]}" = "0" ]; then
    return 0
  fi

  local k=""
  local v=""
  local ph=""
  for k in "${!assocPH[@]}"; do
    ph="{{${k}}}"
    v="${assocPH["${k}"]}"
    filecontent="${filecontent//${ph}/${v}}"
  done

  SHELL_CLI_FN_RETURN="${filecontent}"
  return 0
}
