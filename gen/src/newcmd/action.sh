#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: action.sh
# DESCRIPTION: Implements validation and generation pipelines for building new
#              Shell-CLI compliant structural projects natively.
# ==============================================================================

# cmd_gen_ores_newcmd_main_validate enforces contextual pre-execution checks.
#
# Arguments:
#   - None: Consumes global input variables maps directly.
#
# Returns:
#   - 0: If all system configurations and parameters pass strict validations.
#   - 1: If contextual boundaries or safety policies are violated.
cmd_gen_ores_newcmd_main_validate() {
  local target_path="${CMD_GEN_ORES_newcmd_PARSED["path"]}"

  # Verify if the target workspace path already exists and contains files
  if [ -d "$target_path" ] && [ "$(ls -A "$target_path" 2>/dev/null)" ]; then
    echo "================================================================================"
    echo "[ ! ] WARNING: Target deployment directory is not empty!"
    echo "================================================================================"
    echo "[ ! ] Path: $target_path"
    echo "[ ! ] Proceeding will inject or potentially overwrite existing structural files."
    
    # Inquire user confirmation to prevent accidental project destruction
    local user_confirmation
    echo "================================================================================"
    read -p "[ ? ] Do you want to continue with the scaffolding process? (y/N): " user_confirmation
    echo "================================================================================"
    
    if [[ ! "$user_confirmation" =~ ^[Yy]$ ]]; then
      echo "[ x ] Execution aborted by the operating engineer."
      return 1
    fi
  fi

  return 0
}


# cmd_gen_ores_newcmd_action orchestrates the dynamic scaffold engine flow.
#
# Arguments:
#   - None: Consumes structured configuration variables.
#
# Returns:
#   - 0: On absolute multi-task initialization success with zero pipeline errors.
#   - 1: If any critical directory or template compilation command fails.
cmd_gen_ores_newcmd_action() {
  # Exporting parameters to environment scope so external templates can consume them
  export TARGET_PATH="${CMD_GEN_ORES_newcmd_PARSED["path"]}"
  export TARGET_PKG="${CMD_GEN_ORES_newcmd_PARSED["pkg"]}"
  export TARGET_CMD="${CMD_GEN_ORES_newcmd_PARSED["cmd"]}"
  export TARGET_SUM="${CMD_GEN_ORES_newcmd_PARSED["summary"]}"
  export TARGET_DESC="${CMD_GEN_ORES_newcmd_PARSED["description"]}"

  # Operational variables derived from parameters
  export TARGET_LOWER_PKG
  TARGET_LOWER_PKG=$(echo "$TARGET_PKG" | tr '[:upper:]' '[:lower:]')
  
  local template_dir="${SHELL_CLI_ACTIVE_ROOT_PATH}/src/newcmd/templates"
  local main_executable="${TARGET_PATH}/main.sh"

  echo "================================================================================"
  echo "[RUN] Initializing structural project workspace scaffolding generation..."
  echo "================================================================================"

  # 1. Establish the directory tree architecture physical layers
  echo "[ . ] Creating structural directory layouts inside file system..."
  if ! mkdir -p "${TARGET_PATH}/globals" "${TARGET_PATH}/src/${TARGET_CMD}" 2>/dev/null; then
    echo "[ x ] Critical write error: Failed to initialize layout folders at '${TARGET_PATH}'"
    echo "================================================================================"
    echo "[ERR] Monorepo workspace bootstrap setup failed completely."
    echo "================================================================================"
    return 1
  fi
  echo "[ v ] Target directory matrix generated successfully."

  # 2. Verify template repository availability
  if [ ! -d "$template_dir" ]; then
    echo "[ x ] Critical system configuration fault: Templates directory not found!"
    echo "================================================================================"
    echo "[ERR] Scaffolding process halted due to missing assets."
    echo "================================================================================"
    return 1
  fi

  # 3. Process and deploy global operational layer artifacts
  echo "[ . ] Compiling and deploying global architecture layers..."
  if ! envsubst < "${template_dir}/global_flags.tmpl" > "${TARGET_PATH}/globals/flags.sh" 2>/dev/null || \
    ! envsubst < "${template_dir}/global_utils.tmpl" > "${TARGET_PATH}/globals/utils.sh" 2>/dev/null; then
    echo "[ x ] Failure compiling global resource operational structures."
    return 1
  fi
  echo "[ v ] Global operational layer resources successfully deployed."

  # 4. Process and deploy target command artifacts
  echo "[ . ] Compiling localized templates for command '${TARGET_CMD}'..."
  if ! envsubst < "${template_dir}/cmd_flags.tmpl" > "${TARGET_PATH}/src/${TARGET_CMD}/flags.sh" 2>/dev/null || \
    ! envsubst < "${template_dir}/cmd_action.tmpl" > "${TARGET_PATH}/src/${TARGET_CMD}/action.sh" 2>/dev/null; then
    echo "[ x ] Failure compiling command local metadata files."
    return 1
  fi
  echo "[ v ] Command specific layers allocation maps compiled."

  # 5. Process and deploy project orchestration artifacts
  echo "[ . ] Framing cross-platform adaptive engine main entry-point..."
  if ! envsubst < "${template_dir}/main_sh.tmpl" > "$main_executable" 2>/dev/null || \
    ! envsubst < "${template_dir}/readme_md.tmpl" > "${TARGET_PATH}/README.md" 2>/dev/null; then
    echo "[ x ] Failure generating project main orchestration documents."
    return 1
  fi
  
  chmod +x "$main_executable"
  echo "[ v ] Executable main.sh project driver layer armed."

  echo "================================================================================"
  echo "[OKK] Structural project workspace generated flawlessly!"
  echo "================================================================================"
  return 0
}
