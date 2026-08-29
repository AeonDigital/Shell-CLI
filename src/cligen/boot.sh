#!/usr/bin/env bash

# SHELL_CLI_CMD_EXEC_MODE
# 
# Detects the invocation mode
if [ "${SHELL_CLI_CMD_EXEC_MODE}" = "" ]; then
  declare -g SHELL_CLI_CMD_EXEC_MODE="SOURCING"
  if [ "${BASH_SOURCE[-1]}" = "${0}" ]; then
    SHELL_CLI_CMD_EXEC_MODE="EXECUTION"
  fi
fi

# SHELL_CLI_DEBUG
# 
# Identifies when it is running in a development environment.
[ "${SHELL_CLI_DEBUG}" = "" ] && declare -g SHELL_CLI_DEBUG="0"

# SHELL_CLI_CORE_LOADING
# 
# Indicates whether the 'Shell-CLI' core package It is loading.
[ "${SHELL_CLI_CORE_LOADING}" = "" ] && declare -g SHELL_CLI_CORE_LOADING="0"

# SHELL_CLI_CORE_LOADED
# 
# Indicates whether the 'Shell-CLI' core package is already loaded in the current
# session scope.
[ "${SHELL_CLI_CORE_LOADED}" = "" ] && declare -g SHELL_CLI_CORE_LOADED="0"



# shell_cli_engine_preboot Prepares the environment before performing the boot.
shell_cli_engine_preboot() {
  if [ "${SHELL_CLI_CORE_LOADING}" -ge "1" ]; then
    return 0
  fi
  SHELL_CLI_CORE_LOADING="1"

  shell_cli_engine_boot
  if [ $? -ne 0 ]; then
    shell_cli_engine_download
    if [ $? -ne 0 ]; then
      return 1
    fi

    shell_cli_engine_boot
    if [ $? -ne 0 ]; then
      echo "[FATAL] :: It was not possible to load the Shell CLI engine";
      return 1
    fi
  fi

  return 0
}



# shell_cli_engine_boot  
# Loads the main Shell-CLI package from potential locations where it might be available,
# or downloads and installs it.
shell_cli_engine_boot() {
  if [ "${SHELL_CLI_CORE_LOADED}" -ge "1" ]; then
    return 0
  fi


  # 
  # 1. Identifies whether it is running in a development environment and within the
  #    original repository.
  local path_to_main_pkg_dir="$(cd "${SHELL_CLI_CMD_ROOT_PATH}/../.." && pwd)"
  local path_to_devexec_script="${path_to_main_pkg_dir}/.dev/devexec.sh"
  if [ -f "${path_to_devexec_script}" ]; then
    SHELL_CLI_DEBUG="1"
    . "${path_to_devexec_script}" "${path_to_main_pkg_dir}/src/cli"; SHELL_CLI_CORE_LOADED="2"
    . "${path_to_devexec_script}" "${SHELL_CLI_CMD_ROOT_PATH}"; SHELL_CLI_CORE_LOADED="1"
    return 0
  fi


  # 
  # 2. Loads the package if it exists in the specified installation directory.
  local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/shell_cli"
  local local_package_file_path="${local_package_dir_path}/package.sh"
  if [ -f "${local_package_file_path}" ]; then
    . "${local_package_file_path}"
    SHELL_CLI_CORE_LOADED="1"
    return 0
  fi


  return 1
}



# shell_cli_engine_download — Download the main Shell-CLI package and install it
# locally.
shell_cli_engine_download() {
  local package_name="Shell-CLI"
  local package_filename="package.sh"
  local target_url="https://raw.githubusercontent.com/AeonDigital/Shell-CLI/refs/heads/main/package.sh"


  local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/shell_cli"
  local local_package_file_path="${local_package_dir_path}/package.sh"


  echo "================================================================================"
  echo "[RUN] Provisioning Shell-CLI"
  echo ""
  echo "[ . ] Provisioning isolated shell-cli workspace environment..."

  if [ ! -d "${local_package_dir_path}" ]; then
    mkdir -p "${local_package_dir_path}"

    if [ $? -ne 0 ]; then
      echo "[ERR] :: Could not create the directory '${local_package_dir_path}' "
      echo "         required for the installation of the 'Shell-CLI' package."
      echo "         Check user/group permissions and try again"
      return 1
    fi
  fi


  # Execute network stream ingestion tracking error contexts inline
  local curl_output=""
  curl_output=$(curl -sSL -S -w "%{http_code}" "${target_url}" -o "${local_package_file_path}" 2>&1)
  local curl_status=$?

  if [ ${curl_status} -ne 0 ]; then
    echo "[ERR] :: Transmit stream failed."
    echo "         Target : '${target_url}'"
    echo "         Network Diagnostics: ${curl_output%000}"
    rm -f "${local_package_file_path}"
    return 1
  fi

  # Extracts the HTTP Status Code using safe fallback parsing metrics
  local http_code="${curl_output: -3}"
  if [[ ! "${http_code}" =~ ^2[0-9]{2}$ ]]; then
    echo "[ERR] :: Upstream package retrieval failed."
    echo "         Target : '${target_url}'"
    echo "         HTTP Status Code: ${http_code}"
    rm -f "${local_package_file_path}"
    return 1
  fi

  echo "[ v ] :: Package '${package_name} -> ${package_filename}' successfully downloaded to"
  echo "         '${local_package_file_path}'"

  # Provision executable flags to integrate the script into local execution workflows
  chmod +x "${local_package_file_path}"
  if [ $? -ne 0 ]; then
    echo "[ x ] :: Could not grant execution (+x) permission for the downloaded package."
    echo "         Check user/group permissions and execute manually:"
    echo "         > chmod +x '${local_package_file_path}'"
    echo "[END] :: Installation completed with partial operational state."
    return 1
  fi

  echo ""
  echo "[OKK] Installation of the 'Shell-CLI' package was successful."
  echo "================================================================================"
  echo ""

  return 0
}
