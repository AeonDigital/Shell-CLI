#!/usr/bin/env bash

# shell_cli_process_flag_value_against_prop_default - Evaluate and apply fallback initialization rules if the active payload is empty.
#
# Arguments
# - ruleVal: Configured baseline default value to substitute when no runtime payload is provided.
#
# Global outputs
# - SHELL_CLI_PROCESS_FLAG_VALUE: Updated with the runtime default fallback or the verified original payload upon success.
# - SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE: Appended with a formatted framework violation string upon failure.
#
# Notes
# - Leverages 'shell_cli_metaflag_check_input_default' internally to manage schema placeholder injection.
# - Combines the generic flag context error prefix and the specific validator message into the global error store.
#
# Returns
# - 0: Success (fallback value applied successfully or the original input payload accepted).
# - 1: Failure (default value injection pipeline broke or failed internal type compliance checking).
shell_cli_process_flag_value_against_prop_default() {
  shell_cli_metaflag_check_input_default "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
  if [ "$?" != "0" ]; then
    SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
    return 1
  fi

  SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}
