#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/help.sh
# DESCRIPTION: Dynamic help rendering engines providing global directories and
#              contextual documentation screens for the active CLI sandbox.
# ==============================================================================

# shell_cli_help_render_global renders the root CLI guidance and command directory.
#
# Arguments:
#   None. Uses the active SHELL_CLI_RUNTIME_PKG context register directly.
#
# Returns:
#   - 0: Always terminates successfully after rendering the console layout.
shell_cli_help_render_global() {
  local p_name="$SHELL_CLI_RUNTIME_PKG"
  local lowercase_script_name="${p_name,,}"

  echo "================================================================================"
  echo "  ${p_name} - Enterprise Shell Command Automation Utility"
  echo "================================================================================"
  echo ""
  echo "Usage:"
  echo "  ./${lowercase_script_name}.sh <resource> <action> [flags]"
  echo "  ./${lowercase_script_name}.sh <ores-action> [flags]"
  echo ""
  echo "Global System Flags:"
  echo "  -h, --help          Display guidance documentation and metadata definitions."
  echo "  -itr, --interactive Force step-by-step user interaction prompt mode."
  echo ""
  echo "Available Operational Command Tree:"

  # Scan the active runtime context to dynamically identify registered command structures
  local cmd_var
  for cmd_var in $(declare -p | cut -d'=' -f1 | rev | cut -d' ' -f1 | rev | grep "^CMD_${p_name}_" | sort); do
    # Skip metadata sub-arrays like FLAG_ORDER or OVERRIDE to isolate root commands
    if [[ "$cmd_var" == *_FLAG_* ]] || [[ "$cmd_var" == *_INPUT ]]; then
      continue
    fi

    local -n _g_cmd="$cmd_var"
    # Extract the clean tree identifier layout from the variable nomenclature string
    local raw_tree="${cmd_var#"CMD_${p_name}_"}"
    
    # Standardize the print layout: convert underscore structures back into command spacing
    local print_cmd="${raw_tree//_/ }"
    if [[ "$print_cmd" =~ ^ores[[:space:]] ]]; then
      print_cmd="${print_cmd#ores }"
    fi

    printf "  %-20s %s\n" "$print_cmd" "${_g_cmd["summary"]:-No summary documented.}"
  done
  echo "================================================================================"
  return 0
}

# shell_cli_help_render_contextual builds a dynamic manual for a specific command tree.
#
# Arguments:
#   None. Uses compiled SHELL_CLI_RUNTIME_* sandbox registers directly.
#
# Returns:
#   - 0: Always terminates successfully after rendering the contextual details.
shell_cli_help_render_contextual() {
  local p_name="$SHELL_CLI_RUNTIME_PKG"
  local c_tree="$SHELL_CLI_RUNTIME_COMMAND_TREE"

  # Fall back to global overview screen if the target runtime layout layout is missing
  if [ -z "${SHELL_CLI_RUNTIME_CMD["cmd"]}" ]; then
    shell_cli_help_render_global
    return 0
  fi

  local print_cmd="${c_tree//_/ }"
  [[ "$print_cmd" =~ ^ores[[:space:]] ]] && print_cmd="${print_cmd#ores }"

  echo "================================================================================"
  echo "COMMAND: ${print_cmd}"
  echo "SUMMARY: ${SHELL_CLI_RUNTIME_CMD["summary"]:-No summary available.}"
  if [ -n "${SHELL_CLI_RUNTIME_CMD["description"]}" ]; then
    echo "DESCRIPTION:"
    shell_cli_string_wrap "${SHELL_CLI_RUNTIME_CMD["description"]}" "120"
  fi
  echo "================================================================================"

  if [ "${#SHELL_CLI_RUNTIME_FLAG_ORDER[@]}" -gt 0 ]; then
    echo "Command Parameter Flags (Evaluated in strict checklist sequence):"
    echo ""

    local f_token
    for f_token in "${SHELL_CLI_RUNTIME_FLAG_ORDER[@]}"; do
      local runtime_flag_array_name="SHELL_CLI_RUNTIME_FLAG_${f_token}"
      local -n _f_h_rules="$runtime_flag_array_name"
      
      # Assemble the option display mask combination string
      local short_opt="${_f_h_rules["short"]}"
      local long_opt="${_f_h_rules["long"]}"
      local display_flag=""

      if [ -n "$short_opt" ]; then
        display_flag="-${short_opt}, --${long_opt}"
      else
        display_flag="    --${long_opt}"
      fi

      # Build the parameter status indicators (Required vs Optional)
      local meta_status="[optional]"
      [ "${_f_h_rules["required"]}" = "1" ] && meta_status="[REQUIRED]"

      # Extract array and assoc structural identifiers for high-density typing info
      local structural_type="${_f_h_rules["type"]}"
      [ "${_f_h_rules["array"]}" = "1" ] && structural_type="array<${structural_type}>"
      [ "${_f_h_rules["assoc"]}" = "1" ] && structural_type="map<string,${structural_type}>"

      # Render the primary compiled specification parameter line block
      printf "  %-25s %-18s %s\n" "${display_flag}" "${structural_type}" "${meta_status}"
      
      # Render the human-centric functional usage description text statement
      if [ -n "${_f_h_rules["description"]}" ]; then
        echo -n "      Description: "
        shell_cli_string_wrap "${_f_h_rules["description"]}" "100" | sed '2,$s/^/                   /'
      fi

      # Render optional default fallback mapping hints if configured in the matrix
      if [ "${_f_h_rules["required"]}" = "0" ] && [ -n "${_f_h_rules["default"]}" ]; then
        echo "      Default: \"${_f_h_rules["default"]}\""
      fi

      # Render optional validation limits (min/max boundaries)
      if [ -n "${_f_h_rules["min"]}" ] || [ -n "${_f_h_rules["max"]}" ]; then
        local limits=""
        
        if [ -n "${_f_h_rules["min"]}" ]; then
          limits="min: ${_f_h_rules["min"]}"
        fi
        
        if [ -n "${_f_h_rules["max"]}" ]; then
          if [ -n "$limits" ]; then
            limits="${limits}, "
          fi
          limits="${limits}max: ${_f_h_rules["max"]}"
        fi
        echo "      Constraints: [${limits}]"
      fi
      echo ""
    done
  else
    echo "This operational command option does not register or mandate any parameter flags."
  fi
  echo "================================================================================"
  return 0
}