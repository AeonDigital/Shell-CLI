#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 00_utils/strings.sh
# DESCRIPTION: Native utility operations processing safe character wrapping
#              and dynamic terminal geometry line adjustments.
# ==============================================================================



# SHELL_CLI_UTILS_STRING_WRAP_LINES — global counter tracking word-wrap lines.
#
# - Dynamic integer reflecting the exact total count of formatted text lines.
# - Updated automatically upon completion of the shell_cli_utils_string_wrap tool.
declare -g SHELL_CLI_UTILS_STRING_WRAP_LINES="0"



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
# Global Outputs:
# - SHELL_CLI_UTILS_STRING_WRAP_LINES: Integer reflecting the exact total count
#     of formatted lines printed to standard output during execution.
#
# Behavioral Details:
# - Dynamic terminal adaptation: Automatically detects terminal width via tput(1).
#     If terminal width is smaller than max_width, adapts to terminal width.
# - Hard ceiling constraint: Maximum output width capped at 120 characters,
#     regardless of terminal width or max_width parameter value.
# - Terminal minimum: Requires terminal width >= 20 characters for adaptation.
# - Indentation-aware wrapping: Dynamically reduces available text line width by 
#     the current active indentation size to strictly prevent horizontal overflow.
# - Space preservation: Retains consecutive whitespaces within the raw text string,
#     wrapping them gracefully across line boundaries without compression.
# - Line break awareness: Respects explicit newline (\n) characters inside the raw
#     text, instantly forcing a line break while preserving configured indentations.
shell_cli_utils_string_wrap() {
  local rawText="${1}"
  local targetWidth="${2:-80}"
  local indentFirst="${3:-0}"
  local indentRest="${4:-0}"
  local maxColumns=""
  local totalLines=0

  # Reset global telemetry metric tracking boundary across isolated execution cycles
  SHELL_CLI_UTILS_STRING_WRAP_LINES=0

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
            echo "${usePrefix}${line}"
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
            echo "${usePrefix}${line}"
            ((totalLines++))
            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line=""
            while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
              local chunkLength=$(( targetWidth - useIndentLength ))
              echo "${usePrefix}${remainingSpaces:0:$chunkLength}"
              ((totalLines++))
              remainingSpaces="${remainingSpaces:$chunkLength}"
            done
            line="${remainingSpaces}"
          fi
        fi
        currentToken=""
      fi
      
      # Print current line layout and transition to the next block structure
      echo "${usePrefix}${line}"
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
            echo "${usePrefix}${line}"
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
            echo "${usePrefix}${line}"
            ((totalLines++))
            inFirstLine=0
            useIndentLength="${indentRest}"
            usePrefix="${prefixRest}"
            line=""
            
            while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
              local chunkLength=$(( targetWidth - useIndentLength ))
              echo "${usePrefix}${remainingSpaces:0:$chunkLength}"
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
        echo "${usePrefix}${line}"
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
        echo "${usePrefix}${line}"
        ((totalLines++))
        inFirstLine=0
        useIndentLength="${indentRest}"
        usePrefix="${prefixRest}"
        line=""
        while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
          local chunkLength=$(( targetWidth - useIndentLength ))
          echo "${usePrefix}${remainingSpaces:0:$chunkLength}"
          ((totalLines++))
          remainingSpaces="${remainingSpaces:$chunkLength}"
        done
        line="${remainingSpaces}"
      fi
    fi
  fi

  # Print final remaining line buffer to standard output
  if [ -n "${line}" ]; then
    echo "${usePrefix}${line}"
    ((totalLines++))
  fi

  # Assign telemetry results back into the system environment context
  SHELL_CLI_UTILS_STRING_WRAP_LINES="${totalLines}"

  return 0
}
