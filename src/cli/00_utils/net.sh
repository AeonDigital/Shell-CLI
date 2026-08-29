#!/usr/bin/env bash

# shell_cli_utils_net_download — Download a file via curl, with strict HTTP failure
# and network error trapping.
# 
# Arguments:
# - download_full_url:        The full remote URL of the file to be downloaded.
# - download_save_full_path:  The absolute destination file path where the file will
#   be saved.
# 
# Returns:
# - None on success. Writes the file directly to disk.
# 
# Return Codes:
# - 0: if download was successful.
# - 1: If the curl command fails due to network/DNS issues or returns a non-2xx HTTP
#   status code.  
# In this case, an error message will be added to the global variable SHELL_CLI_FN_RETURN.
shell_cli_utils_net_download() {
  SHELL_CLI_FN_RETURN=""
  local download_full_url="${1}"
  local download_save_full_path="${2}"

  local curl_output=$(curl -sSL -S -w "%{http_code}" "${download_full_url}" -o "${download_save_full_path}" 2>&1)

  local curl_status=$?
  if [ "${curl_status}" != 0 ]; then
    SHELL_CLI_FN_RETURN+="[ERR] :: Download fail.${codeNL}"
    SHELL_CLI_FN_RETURN+="         Target : '${download_full_url}'${codeNL}"
    SHELL_CLI_FN_RETURN+="         Network Error: ${curl_output%000}${codeNL}"

    rm -f "${download_save_full_path}"
    return 1
  fi

  local http_code="${curl_output: -3}"
  if [[ ! "${http_code}" =~ ^2[0-9]{2}$ ]]; then
    SHELL_CLI_FN_RETURN+="[ERR] :: Download fail.${codeNL}"
    SHELL_CLI_FN_RETURN+="         Target : '${download_full_url}'${codeNL}"
    SHELL_CLI_FN_RETURN+="         HTTP Status Code: ${http_code}${codeNL}"

    rm -f "${download_save_full_path}"
    return 1
  fi

  return 0
}
