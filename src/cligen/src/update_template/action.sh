#!/usr/bin/env bash



# shell_cli_cmd_cligen_update_template_presets — presets that must be available for
# the validation and/or execution stage of this command.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Optionally and explicitly invoked within the 'validation' function and/or the
#   'action' of this command.
# - It plays a centralizing role for actions necessary for the overall performance
#   of this command—or even others to be executed subsequently via the shared environment.
# 
# Returns
# - 0: Success (context satisfies all domain-level guard rails, permitting business
#   actions to proceed).
# - 1+: Failure (domain violation detected; short-circuits execution and reports
#   the custom message).
shell_cli_cmd_cligen_update_template_presets() {
  shell_cli_cmd_cligen_utils_template_set_dirpath
  return 0
}




# shell_cli_cmd_cligen_update_template_validate — Custom post-parameter-receipt validation
# for high-level checks.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Invoked automatically by the core framework after input collection (CLI/Interactive)
#   but before business actions run.
# - Designed to evaluate multi-flag balance constraints, environmental states, and
#   safety policies.
# 
# Returns
# - 0: Success (context satisfies all domain-level guard rails, permitting business
#   actions to proceed).
# - 1+: Failure (domain violation detected; short-circuits execution and reports
#   the custom message).
shell_cli_cmd_cligen_update_template_validate() {
  return 0
}





# shell_cli_cmd_cligen_update_template_action — Core business logic handler orchestrating
# the main operations of the command path.
# 
# Arguments
# - None.
# 
# Global inputs
# - SHELL_CLI_CMD_INPUT: Associative matrix containing all sanitized, type-validated,
#   and normalized parameters.
# - SHELL_CLI_CMD_INPUT_ORDER: Indexed matrix tracking the precise registration sequence
#   of the captured flags.
# 
# Notes
# - Acts as the final execution block in the framework lifecycle pipeline for a successfully
#   matched command route node.
# - Dispatches primary operational workloads (e.g., orchestration, file manipulation,
#   automation, or task sequences).
# 
# Returns
# - 0: Success (all internal operations completed their processing loops smoothly
#   with zero errors).
# - 1+: Failure (runtime exception, storage fault, or downstream processing barrier
#   encountered).
shell_cli_cmd_cligen_update_template_action() {
  shell_cli_cmd_cligen_update_template_presets
  if [ $? -ne 0 ]; then
    return 1
  fi


  echo "================================================================================"
  echo "[RUN] Starting template update..."
  echo ""
  echo "      Local Directory: ${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}"
  echo ""


  if [ -d "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}" ]; then
    local user_choice=""
    echo "[ ? ] This action cannot be undone."
    echo "      All content in the local directory will be deleted."
    echo "      Are you sure you want to proceed? (y/n)"
    read -p "[ > ] " -r user_choice < /dev/tty
    user_choice="${user_choice,,}"

    if [ "${user_choice}" != "y" ]; then
      echo ""
      echo "[END] Action canceled."
      echo "      No changes were made!"
      echo ""
      return 0
    fi

    rm -rf "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}"
    if [ $? -ne 0 ]; then
      echo ""
      echo "[ERR] Unable to delete the old content."
      echo "      Check the permissions and try again."
      echo ""
      return 1
    fi
  fi

  mkdir -p "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}"
  if [ $? -ne 0 ]; then
    echo ""
    echo "[ERR] Could not create the local directory"
    echo "      Check the permissions and try again."
    echo ""
    return 1
  fi


  echo ""
  echo "[ . ] Starting update of remote files to the local template directory."
  local file=""
  local ok="1"
  for file in "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_FILES[@]}"; do
    shell_cli_utils_net_download \
      "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_URL}/${file}" \
      "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/${file}"

    if [ $? -ne 0 ]; then
      ok="0"
      echo "[ x ] File '"${file}"' fail!"
      echo "${SHELL_CLI_FN_RETURN}"
      echo ""
      echo "         Update failed."
      echo ""
    fi

    echo "[ v ] File '"${file}"' updated!"
  done


  echo ""
  if [ "${ok}" = "0" ]; then
    echo "[ERR] The update finished with errors."
    echo "================================================================================"
    return 1
  fi

  echo "[OKK] The update completed successfully."
  echo "================================================================================"
  return 0
}
