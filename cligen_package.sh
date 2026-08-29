#!/usr/bin/env bash

# ==============================================================================
# SINGLE-FILE DISTRIBUTION SHELL PACKAGE 
# 
# PROJECT     : Shell-CLI-CLIGEN  
# ORIGIN URL  : https://github.com/AeonDigital/Shell-CLI  
# EXPORTED AT : 2026-08-30 00:59:24  
# LICENSE     : MIT [ https://github.com/AeonDigital/Shell-CLI/LICENSE ]  
# ==============================================================================



if [ "${SHELL_CLI_CMD_EXEC_MODE}" = "" ]; then
declare -g SHELL_CLI_CMD_EXEC_MODE="SOURCING"
if [ "${BASH_SOURCE[-1]}" = "${0}" ]; then
SHELL_CLI_CMD_EXEC_MODE="EXECUTION"
fi
fi
[ "${SHELL_CLI_DEBUG}" = "" ] && declare -g SHELL_CLI_DEBUG="0"
[ "${SHELL_CLI_CORE_LOADING}" = "" ] && declare -g SHELL_CLI_CORE_LOADING="0"
[ "${SHELL_CLI_CORE_LOADED}" = "" ] && declare -g SHELL_CLI_CORE_LOADED="0"
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
shell_cli_engine_boot() {
if [ "${SHELL_CLI_CORE_LOADED}" -ge "1" ]; then
return 0
fi
local path_to_main_pkg_dir="$(cd "${SHELL_CLI_CMD_ROOT_PATH}/../.." && pwd)"
local path_to_devexec_script="${path_to_main_pkg_dir}/.dev/devexec.sh"
if [ -f "${path_to_devexec_script}" ]; then
SHELL_CLI_DEBUG="1"
. "${path_to_devexec_script}" "${path_to_main_pkg_dir}/src/cli"; SHELL_CLI_CORE_LOADED="2"
. "${path_to_devexec_script}" "${SHELL_CLI_CMD_ROOT_PATH}"; SHELL_CLI_CORE_LOADED="1"
return 0
fi
local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/shell_cli"
local local_package_file_path="${local_package_dir_path}/package.sh"
if [ -f "${local_package_file_path}" ]; then
. "${local_package_file_path}"
SHELL_CLI_CORE_LOADED="1"
return 0
fi
return 1
}
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


declare -g SHELL_CLI_CMD_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
if ! declare -f "shell_cli_engine_boot" >/dev/null; then
if [ ! -f "${SHELL_CLI_CMD_ROOT_PATH}/boot.sh" ]; then
echo "[FATAL] :: Shell CLI boot functions were not found."; exit 1
fi
. "${SHELL_CLI_CMD_ROOT_PATH}/boot.sh"
shell_cli_engine_preboot
fi
if [ "${SHELL_CLI_CORE_LOADED}" = "1" ]; then
if [ "${SHELL_CLI_DEBUG}" = "1" ]; then
SHELL_CLI_CORE_LOADED="0"
shell_cli_engine_boot
fi
SHELL_CLI_CORE_LOAD="1"
shell_cli "${SHELL_CLI_CMD_ROOT_PATH}" "$@"
fi


declare -gA SHELL_CLI_CMD_CLIGEN=()
SHELL_CLI_CMD_CLIGEN["cmd"]="cligen"
SHELL_CLI_CMD_CLIGEN["summary"]="Shell CLI/PKG generator."
SHELL_CLI_CMD_CLIGEN["description"]="Allows creating and editing projects implemented with the Shell-CLI."
declare -ga SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER=()
SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("update-template")
SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("set-env")
SHELL_CLI_CMD_CLIGEN_RESOURCE_ORDER+=("create")




if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" = "" ]; then
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="0"
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PATH=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""
declare -ga SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
declare -gx XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT=""
declare -gx SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
fi
shell_cli_cmd_cligen_env_reset() {
SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="0"
SHELL_CLI_CMD_CLIGEN_ENV_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
}
shell_cli_cmd_cligen_pkg_set() {
local pkg="${1}"
local pkgfn="${pkg//-/_}"
SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME="${pkg}"
SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH="${SHELL_CLI_CMD_CLIGEN_ENV_PATH}/${pkgfn}"
SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/${pkgfn}.sh"
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER="${pkgfn,,}"
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER="${pkgfn^^}"
return 0
}
shell_cli_cmd_cligen_pkg_unset() {
SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER=""
SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""
}
shell_cli_cmd_cligen_cmd_set() {
local cmd="${1}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}/${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER}.sh"
local -n array_cmd="${cmd}"
local c=""
local cpath=""
for c in "${array_cmd[@]}"; do
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}" != "" ]; then
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
fi
cpath="${c//-/_}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD+=("${c}")
SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME="${c}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE+="${c} "
SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH+="/src/${cpath}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER+="${cpath,,}_"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER+="${cpath^^}_"
done
XSHELL_CLI_CMD_CLIGEN_ENV_CMD="${SHELL_CLI_CMD_CLIGEN_ENV_CMD[*]}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE:0: -1}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER:0: -1}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER:0: -1}"
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/flags.sh"
return 0
}
shell_cli_cmd_cligen_cmd_unset() {
SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
XSHELL_CLI_CMD_CLIGEN_ENV_CMD=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER=""
SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT=""
}
declare -gx SHELL_CLI_CMD_CLIGEN_TEMPLATE_URL="https://raw.githubusercontent.com/AeonDigital/Shell-CLI/refs/heads/main/src/cligen/templates"
declare -gx SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH=""
declare -ga SHELL_CLI_CMD_CLIGEN_TEMPLATE_FILES=(
"pkg_boot.tmpl"
"pkg_cmd.tmpl"
"pkg_entrypoint.tmpl"
"pkg_readme.tmpl"
"cmd_action.tmpl"
"cmd_cmd.tmpl"
"cmd_flags.tmpl"
"global_flags.tmpl"
"global_utils.tmpl"
)
shell_cli_cmd_cligen_utils_template_set_dirpath() {
if [ "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}" = "" ]; then
SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH="${SHELL_CLI_RESOURCE_PATH}/templates"
if [ "${SHELL_CLI_DEBUG}" = "1" ]; then
SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/templates"
fi
fi
return 0
}
shell_cli_cmd_cligen_utils_template_check_directory() {
if [ ! -d "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}" ]; then
echo "[ x ] :: Templates directory not found!"
echo "         Looking in '${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}'"
echo "         Run the 'update-template' command to perform the download."
echo ""
return 1
fi
return 0
}
shell_cli_cmd_cligen_utils_template_check_files() {
shell_cli_cmd_cligen_utils_template_set_dirpath
if ! shell_cli_cmd_cligen_utils_template_check_directory; then
return 1
fi
local file=""
local ok="1"
for file in "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_FILES[@]}"; do
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/${file}" ]; then
ok="0"
echo "[ x ] File template '"${file}"' not found!"
echo ""
fi
done
if [ "${ok}" = "0" ]; then
echo "[ x ] :: Run the 'update-template' command to perform the download"
echo "         of the missing files"
echo ""
return 1
fi
return 0
}
shell_cli_cmd_cligen_utils_clear_non_empty_directory() {
local tgt_dir="${1}"
if [ -d "${tgt_dir}" ]; then
local user_choice=""
echo "================================================================================"
echo "[ ! ] WARNING: Target directory is not empty!"
echo ""
echo "      Target Path: ${tgt_dir}"
echo ""
echo "      Proceeding will remove all existing content, including commands, subcommands,"
echo "      configurations and any other auxiliary files within the respective directory."
echo ""
echo "      This action cannot be undone!"
echo ""
echo "[ ? ] :: Do you want to continue? (y/N):"
read -p "[ > ] :: " -r user_choice < /dev/tty
user_choice="${user_choice,,}"
if [ "${user_choice}" != "y" ]; then
echo "[END] Execution aborted by user."
return 1
fi
rm -rf "${tgt_dir}" 2>/dev/null
if [ $? -ne 0 ]; then
echo "[ x ] It was not possible to delete the existing content."
echo "      Check your user permissions and try again."
echo "[END] Execution interrupted."
echo ""
return 1
fi
echo "[ v ] Target directory successfully removed!"
echo ""
fi
return 0
}
declare -gAx SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER=()
shell_cli_cmd_cligen_placeholder_set_assoc() {
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["ENV_PATH"]="${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_NAME"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_FN_LOWER"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_LOWER}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["PKG_FN_UPPER"]="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_FN_UPPER}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_NAME"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_TREE"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_PATH"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_SCRIPT"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_FN_LOWER"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_LOWER}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["CMD_FN_UPPER"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FN_UPPER}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["FLAG_SCRIPT"]="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["SUMMARY"]="${SHELL_CLI_CMD_INPUT["summary"]}"
SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER["DESCRIPTION"]="${SHELL_CLI_CMD_INPUT["description"]}"
}


shell_cli_cmd_cligen_create_presets() {
return 0
}
shell_cli_cmd_cligen_create_validate() {
return 0
}
shell_cli_cmd_cligen_create_action() {
return 0
}


declare -gA SHELL_CLI_CMD_CLIGEN_CREATE=()
SHELL_CLI_CMD_CLIGEN_CREATE["cmd"]="create"
SHELL_CLI_CMD_CLIGEN_CREATE["summary"]="Main resource for creating elements for a CLI project."
SHELL_CLI_CMD_CLIGEN_CREATE["description"]="The environment level defined by the 'set-env' command allows elements to be created within that context."
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER=()
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("pkg")
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("cmd")
SHELL_CLI_CMD_CLIGEN_CREATE_ACTION_ORDER+=("flag")


declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_ORDER=()


declare -g SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET="0"
declare -ga SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD=()
shell_cli_cmd_cligen_create_cmd_presets() {
if [ "${SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET}" = "1" ]; then
return 0
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -lt 2 ]; then
echo "[ x ] To perform this action, you must select a target package command."
echo ""
echo "      Run"
echo "      > 'set-env --path=\"...\" --pkg=\"...\"'"
echo "      or"
echo "      > 'set-env --path=\"...\" --pkg=\"...\"' --cmd=\"...\""
return 1
fi
shell_cli_cmd_cligen_utils_template_check_files
if [ $? -ne 0 ]; then
return 1
fi
SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD=(${XSHELL_CLI_CMD_CLIGEN_ENV_CMD})
SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD+=("${SHELL_CLI_CMD_INPUT["name"]}")
shell_cli_cmd_cligen_cmd_unset
shell_cli_cmd_cligen_cmd_set "SHELL_CLI_CMD_CLIGEN_ENV_NEWCMD"
shell_cli_cmd_cligen_placeholder_set_assoc
SHELL_CLI_CME_CLIGEN_CREATE_CMD_PRESET="1"
return 0
}
shell_cli_cmd_cligen_create_cmd_validate() {
shell_cli_cmd_cligen_create_cmd_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
return 0
}
shell_cli_cmd_cligen_create_cmd_action() {
shell_cli_cmd_cligen_create_cmd_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_utils_clear_non_empty_directory "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
echo "================================================================================"
echo "[RUN] Creating CLI PKG CMD structure..."
echo ""
echo "    Workspace : ${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
echo ""
echo "      Package : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
echo ""
echo "   Parent CMD : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME}"
echo "   Entrypoint : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
echo ""
echo "      Command : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
echo "         Tree : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
echo ""
shell_cli_cmd_cligen_create_cmd_action_step_01
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_create_cmd_action_step_02
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_create_cmd_action_step_03
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
echo "[OKK] A new structure for the CLI PKG Command was successfully generated."
return 0
}
shell_cli_cmd_cligen_create_cmd_action_step_01() {
local ok="1"
local dir=""
local -a arr_newdir=(
"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
)
echo "[ . ] Generating directory structure..."
for dir in "${arr_newdir[@]}"; do
if ! mkdir -p "${dir}" 2>/dev/null; then
echo "[ x ] Could not create the directory"
echo "      '${dir}'"
ok="0"
fi
echo "[ v ] Directory '${dir}' successfully created."
done
if [ "${ok}" = "0" ]; then
echo "[ERR] :: Check your user permissions and try again."
echo ""
return 1
fi
echo "[ v ] Directory structure successfully generated."
return 0
}
shell_cli_cmd_cligen_create_cmd_action_step_02() {
local -a arr_templatefiles=(
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_action.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_cmd.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/cmd_flags.tmpl"
)
local -a arr_projectfiles=(
"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/action.sh"
"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/cmd.sh"
"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}/flags.sh"
)
local i=""
local ok="1"
local tfile=""
local pfile""
echo ""
echo "[ . ] Installing initial files for the new CLI PKG CMD..."
echo "[ . ] Copying template files..."
for i in "${!arr_templatefiles[@]}"; do
tfile="${arr_templatefiles["${i}"]}"
pfile="${arr_projectfiles["${i}"]}"
shell_cli_utils_string_replace_placeholder "${tfile}" "SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER"
if [ $? -ne 0 ]; then
echo "[ x ] Failed to create file content from template"
echo "      '${tfile}' to '${pfile}'"
ok="0"
else
echo "${SHELL_CLI_FN_RETURN}" > "${pfile}"
if [ $? -ne 0 ]; then
echo "[ x ] Failed to deploy file"
echo "      '${tfile}' to '${pfile}'"
ok="0"
fi
fi
echo "[ v ] File '${pfile}' successfully created."
done
if [ "${ok}" = "0" ]; then
echo "[ERR] :: Check your user permissions and try again."
echo ""
return 1
fi
echo ""
echo "[ v ] Files successfully installed."
return 0
}
shell_cli_cmd_cligen_create_cmd_action_step_03() {
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}" ]; then
echo "[ x ] Parent command script not found."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
return 1
fi
local content=$(< "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}")
if [ "${content}" = "" ]; then
echo "[ x ] Parent command script is empty."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
return 1
fi
local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE% *}"
target_parent_tree="${target_parent_tree^^}"
target_parent_tree="${target_parent_tree// /_}"
local target_array_name="SHELL_CLI_CMD_"
target_array_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
target_array_name+="${target_parent_tree}_"
target_array_name+="ACTION_ORDER"
local tgt_anchor="# {{REGISTER ACTION PLACEHOLDER}}"
if [[ ! "${content}" == *"${tgt_anchor}"* ]]; then
echo "[ x ] Could not find the editing anchor for new action registrations "
echo "      in the main script command."
echo ""
echo "      Missing markup:"
echo "      \`\`\`"
echo "      ${tgt_anchor}"
echo "      \`\`\`"
echo ""
echo ""
echo "      Please insert it after the last record of type '${target_array_name}'"
echo "      according to the template below and try again."
echo ""
echo "      \`\`\` ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
echo "      declare -ga ${target_array_name}=()"
echo "      ${target_array_name}+=(\"first\")"
echo "      ${target_array_name}+=(\"second\")"
echo "      ${target_array_name}+=(\"last\")"
echo "      ${tgt_anchor}"
echo "      \`\`\`"
return 1
fi
local new_registry="${target_array_name}+=(\"${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}\")"
if [[ "${content}" == *"${new_registry}"* ]]; then
echo "[ ! ] A record for this command already exists."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'"
return 0
fi
local use_anchor="\# \{\{REGISTER ACTION PLACEHOLDER\}\}"
local use_registry="${new_registry}${codeNL}${tgt_anchor}"
content="${content/${use_anchor}/${use_registry}}"
echo "${content}" > "${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
if [ $? -ne 0 ]; then
echo "[ x ] Unable to update the script '${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}'."
echo "[ERR] :: Check your user permissions and try again."
return 1
fi
return 0
}


declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["cmd"]="cmd"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["summary"]="Instantiates a new Command for selected CLI PKG."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD["description"]="Generates the entire structure required to correspond to the newly specified command."
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_CMD_ACTION_ORDER=()


declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("name")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["long"]="name"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["min"]="3"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["max"]="16"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["description"]="Name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["tipinput"]="Enter the name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_name["transform"]='["shell_cli_utils_to_lowercase"]'
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("summary")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["long"]="summary"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["max"]="256"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["description"]="Brief single-line summary description of the generated Command."
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_summary["tipinput"]="Enter a short, single-line summary of what this Command does"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_ORDER+=("description")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description=()
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["long"]="description"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["max"]="2048"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["description"]="Full detailed architectural and operational explanation of the Command"
SHELL_CLI_CMD_CLIGEN_CREATE_CMD_FLAG_description["tipinput"]="Enter a full, detailed operational explanation for this Command"


declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET="0"
declare -ga TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD=()
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE=""
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER=""
declare -g SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC=""
shell_cli_cmd_cligen_create_flag_presets() {
if [ "${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET}" = "1" ]; then
return 0
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -lt 3 ]; then
echo "[ x ] To perform this action, you must select a target package command."
echo ""
echo "      Run"
echo "      > 'set-env --path=\"...\" --pkg=\"...\"' --cmd=\"...\""
return 1
fi
shell_cli_cmd_cligen_utils_template_check_files
if [ $? -ne 0 ]; then
return 1
fi
TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD=(${XSHELL_CLI_CMD_CLIGEN_ENV_CMD})
shell_cli_cmd_cligen_cmd_unset
shell_cli_cmd_cligen_cmd_set "TMP_SHELL_CLI_CMD_CLIGEN_ENV_CMD"
shell_cli_cmd_cligen_placeholder_set_assoc
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_PRESET="1"
return 0
}
shell_cli_cmd_cligen_create_flag_validate() {
shell_cli_cmd_cligen_create_flag_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
return 0
}
shell_cli_cmd_cligen_create_flag_action() {
shell_cli_cmd_cligen_create_flag_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
echo "================================================================================"
echo "[RUN] Creating New Command Flag ..."
echo ""
echo "    Workspace : ${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
echo ""
echo "      Package : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
echo ""
echo "   Parent CMD : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_NAME}"
echo "   Entrypoint : ${SHELL_CLI_CMD_CLIGEN_ENV_PARENT_CMD_SCRIPT}"
echo ""
echo "      Command : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
echo "         Tree : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
echo "         Flag : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"
echo ""
shell_cli_cmd_cligen_create_flag_action_step_01
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_create_flag_action_step_02
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
echo "[OKK] A new structure for the CLI PKG Command was successfully generated."
return 0
}
shell_cli_cmd_cligen_create_flag_action_step_01() {
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE=""
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER=""
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC=""
local fname="${SHELL_CLI_CMD_INPUT["long"]}"
local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
target_parent_tree="${target_parent_tree^^}"
target_parent_tree="${target_parent_tree// /_}"
local target_base_name="SHELL_CLI_CMD_"
target_base_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
target_base_name+="${target_parent_tree}_"
target_base_name+="FLAG"
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER="${target_base_name}_ORDER+=(\"${fname}\")"
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC="declare -gA ${target_base_name}_${fname}=()"
local code=""
code+="# ${codeNL}"
code+="# FLAG ${fname}${codeNL}"
code+="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}${codeNL}"
code+="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}${codeNL}"
local f=""
local v=""
local assoc_flag="${target_base_name}_${fname}"
for f in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
v="${SHELL_CLI_CMD_INPUT["${f}"]}"
if [ "${v}" != "" ]; then
code+="${assoc_flag}[\"${f}\"]="
case "${f}" in
required|is_array|is_assoc)
if [ "${v}" = "0" ]; then
v="false"
elif [ "${v}" = "1" ]; then
v="true"
fi
;;
esac
if [ "${v}" = "true" ] || [ "${v}" = "false" ]; then
code+="${v}"
else
code+="\"${v}\""
fi
code+="${codeNL}"
fi
done
SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE="${code}"
}
shell_cli_cmd_cligen_create_flag_action_step_02() {
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}" ]; then
echo "[ x ] Parent flag script not found."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
return 1
fi
local content=$(< "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}")
if [ "${content}" = "" ]; then
echo "[ x ] Parent command flag is empty."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
return 1
fi
local target_parent_tree="${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE% *}"
target_parent_tree="${target_parent_tree^^}"
target_parent_tree="${target_parent_tree// /_}"
local target_array_name="SHELL_CLI_CMD_"
target_array_name+="${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME^^}_"
target_array_name+="${target_parent_tree}_"
target_array_name+="ACTION_ORDER"
local tgt_anchor="# {{REGISTER FLAG PLACEHOLDER}}"
if [[ ! "${content}" == *"${tgt_anchor}"* ]]; then
echo "[ x ] Could not find the editing anchor for new flag registrations "
echo "      in the main script command."
echo ""
echo "      Missing markup:"
echo "      \`\`\`"
echo "      ${tgt_anchor}"
echo "      \`\`\`"
echo ""
echo ""
echo "      Please insert this after the last flag entry in the flags script"
echo "      and try again."
return 1
fi
if [[ "${content}" == *"${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}"* ]]; then
echo "[ ! ] A record for this flag already exists."
echo "      Find code line:"
echo "      > ${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ORDER}"
echo "      in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
echo ""
echo "      Remove it to proceed"
return 1
fi
if [[ "${content}" == *"${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}"* ]]; then
echo "[ ! ] A record for this flag already exists."
echo "      Find code line:"
echo "      > ${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE_ASSOC}"
echo "      in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
echo ""
echo "      Remove it to proceed"
return 1
fi
local use_anchor="\# \{\{REGISTER FLAG PLACEHOLDER\}\}"
local use_registry="${SHELL_CLI_CME_CLIGEN_CREATE_FLAG_CODE}${codeNL}${tgt_anchor}"
content="${content/${use_anchor}/${use_registry}}"
echo "${content}" > "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}"
if [ $? -ne 0 ]; then
echo "[ x ] Unable to update the script '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'."
echo "[ERR] :: Check your user permissions and try again."
return 1
fi
return 0
}


declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_FLAG=()
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["cmd"]="flag"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["summary"]="Adds a new flag to the selected command."
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG["description"]="Configures the use of a new flag for the command, allowing each of its technical aspects to be edited."
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_ACTION_ORDER=()


declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER=()
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("long")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_long="METAFLAG_long"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("short")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_short="METAFLAG_short"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("type")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_type="METAFLAG_type"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("accept_values")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_accept_values="METAFLAG_accept_values"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("description")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_description="METAFLAG_description"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("tipinput")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_tipinput="METAFLAG_tipinput"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("default")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_default="METAFLAG_default"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("required")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_required="METAFLAG_required"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("normalize")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_normalize="METAFLAG_normalize"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("min")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_min="METAFLAG_min"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("max")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_max="METAFLAG_max"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("regex")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_regex="METAFLAG_regex"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("validate")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_validate="METAFLAG_validate"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("transform")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_transform="METAFLAG_transform"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("is_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_is_array="METAFLAG_is_array"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("min_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_min_array="METAFLAG_min_array"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("max_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_max_array="METAFLAG_max_array"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("is_assoc")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_is_assoc="METAFLAG_is_assoc"
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("required_keys")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_required_keys="METAFLAG_required_keys"


declare -g SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET="0"
shell_cli_cmd_cligen_create_pkg_presets() {
if [ "${SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET}" = "1" ]; then
return 0
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -le 0 ]; then
echo "[ x ] No Environment Set to perform this action."
echo ""
echo "      Run 'set-env' --path=\"...\" command first!"
return 1
fi
shell_cli_cmd_cligen_utils_template_check_files
if [ $? -ne 0 ]; then
return 1
fi
shell_cli_cmd_cligen_pkg_set "${SHELL_CLI_CMD_INPUT["name"]}"
shell_cli_cmd_cligen_placeholder_set_assoc
SHELL_CLI_CME_CLIGEN_CREATE_PKG_PRESET="1"
return 0
}
shell_cli_cmd_cligen_create_pkg_validate() {
shell_cli_cmd_cligen_create_pkg_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
return 0
}
shell_cli_cmd_cligen_create_pkg_action() {
shell_cli_cmd_cligen_create_pkg_presets
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_utils_clear_non_empty_directory "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
if [ $? -ne 0 ]; then
return 1
fi
echo "================================================================================"
echo "[RUN] :: Creating CLI PKG structure..."
echo ""
echo "                    PKG : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
echo "        Local Directory : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
echo "    Templates Directory : ${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}"
echo ""
shell_cli_cmd_cligen_create_pkg_action_step_01
if [ $? -ne 0 ]; then
echo "      Action interrupted"
echo ""
return 1
fi
shell_cli_cmd_cligen_create_pkg_action_step_02
if [ $? -ne 0 ]; then
echo "      Action interrupted!"
echo ""
return 1
fi
shell_cli_cmd_cligen_create_pkg_action_step_03
if [ $? -ne 0 ]; then
echo "[END] The structure was generated, but errors occurred;"
echo "      please check it before proceeding!"
else
echo "[OKK] A new structure for the CLI Project was successfully generated."
fi
echo "================================================================================"
return 0
}
shell_cli_cmd_cligen_create_pkg_action_step_01() {
local ok="1"
local dir=""
local -a arr_newdir=(
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/src"
)
echo "[ . ] Generating directory structure..."
for dir in "${arr_newdir[@]}"; do
if ! mkdir -p "${dir}" 2>/dev/null; then
echo "[ x ] Could not create the directory"
echo "      '${dir}'"
ok="0"
fi
echo "[ v ] Directory '${dir}' successfully created."
done
if [ "${ok}" = "0" ]; then
echo "[ERR] :: Check your user permissions and try again."
echo ""
return 1
fi
echo "[ v ] Directory structure successfully generated."
return 0
}
shell_cli_cmd_cligen_create_pkg_action_step_02() {
local -a arr_templatefiles=(
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_boot.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_cmd.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_entrypoint.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/pkg_readme.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/global_flags.tmpl"
"${SHELL_CLI_CMD_CLIGEN_TEMPLATE_DIRPATH}/global_utils.tmpl"
)
local -a arr_projectfiles=(
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/boot.sh"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/cmd.sh"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/README.md"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals/flags.sh"
"${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}/globals/utils.sh"
)
local i=""
local ok="1"
local tfile=""
local pfile""
echo ""
echo "[ . ] Installing initial files for the new CLI PKG..."
echo "[ . ] Copying template files..."
for i in "${!arr_templatefiles[@]}"; do
tfile="${arr_templatefiles["${i}"]}"
pfile="${arr_projectfiles["${i}"]}"
shell_cli_utils_string_replace_placeholder "${tfile}" "SHELL_CLI_CMD_CLIGEN_ASSOC_PLACEHOLDER"
if [ $? -ne 0 ]; then
echo "[ x ] Failed to create file content from template"
echo "      '${tfile}' to '${pfile}'"
ok="0"
else
echo "${SHELL_CLI_FN_RETURN}" > "${pfile}"
if [ $? -ne 0 ]; then
echo "[ x ] Failed to deploy file"
echo "      '${tfile}' to '${pfile}'"
ok="0"
fi
fi
echo "[ v ] File '${pfile}' successfully created."
done
if [ "${ok}" = "0" ]; then
echo "[ERR] :: Check your user permissions and try again."
echo ""
return 1
fi
echo ""
echo "[ v ] Files successfully installed."
return 0
}
shell_cli_cmd_cligen_create_pkg_action_step_03() {
chmod +x "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}"
if [ $? -ne 0 ]; then
echo ""
echo "[ ! ] - Operational execution flag assignment denied."
echo "        Please grant runtime validation permissions explicitly:"
echo "        > chmod +x '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}'"
echo ""
return 1
fi
echo ""
echo "[ v ] Executable main.sh project driver layer armed."
echo ""
return 0
}


declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_PKG=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["cmd"]="pkg"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["summary"]="Starts a new CLI PKG Project"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG["description"]="A CLI Project is a Package that enables the execution of one or more tasks—grouped by commands—within a rigidly defined hierarchical structure."
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_PKG_ACTION_ORDER=()


declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_ORDER=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_ORDER+=("name")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["long"]="name"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["min"]="3"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["max"]="16"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["description"]="Name of the new package to be created in the current workspace."
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["tipinput"]="Enter the name of the new package to be created in the selected workspace."
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_name["transform"]='["shell_cli_utils_to_lowercase"]'
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_ORDER+=("summary")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["long"]="summary"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["max"]="256"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["description"]="Brief single-line summary description of the generated CLI PKG Project."
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_summary["tipinput"]="Enter a short, single-line summary of what this CLI PKG Project does"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_ORDER+=("description")
declare -gA SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description=()
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["long"]="description"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["type"]="string"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["required"]=true
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["min"]="1"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["max"]="2048"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["description"]="Full detailed architectural and operational explanation of the CLI PKG Project"
SHELL_CLI_CMD_CLIGEN_CREATE_PKG_FLAG_description["tipinput"]="Enter a full, detailed operational explanation for this CLI PKG Project"


shell_cli_cmd_cligen_set_env_presets() {
if [ "${SHELL_CLI_CMD_EXEC_MODE}" != "SOURCING" ]; then
echo "[ERR] This command must be run using 'source' or the '.' operator."
echo "      > . ${0}"
return 1
fi
local path="${SHELL_CLI_CMD_INPUT["path"]}"
SHELL_CLI_CMD_CLIGEN_ENV_PATH="${path}"
SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="1"
local pkg="${SHELL_CLI_CMD_INPUT["pkg"]}"
if [ "${pkg}" != "" ]; then
shell_cli_cmd_cligen_pkg_set "${pkg}"
SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="2"
fi
local cmd="${SHELL_CLI_CMD_INPUT["cmd"]}"
if [ "${pkg}" != "" ] && [ "${cmd}" != "" ]; then
shell_cli_cmd_cligen_cmd_set "${cmd}"
SHELL_CLI_CMD_CLIGEN_ENV_LEVEL="3"
fi
return 0
}
shell_cli_cmd_cligen_set_env_validate() {
shell_cli_cmd_cligen_env_reset
shell_cli_cmd_cligen_set_env_presets
if [ $? -ne 0 ]; then
shell_cli_cmd_cligen_env_reset
return 1
fi
if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_PATH}" ]; then
echo "[ x ] The given path for the CLI Project root directory does not exist."
echo "      Looking in '${path}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}" != "" ]; then
if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}" ]; then
echo "[ x ] The given Package Name does not correspond to an existing directory"
echo "      within the CLI project root."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}" ]; then
echo "[ x ] The startup script for this package was not found at the expected location."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_PKG_SCRIPT}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}" != "" ]; then
if [ ! -d "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}" ]; then
echo "[ x ] The given Command Name does not correspond to an existing directory"
echo "      within the CLI project root."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}" ]; then
echo "[ x ] The startup script for this command was not found at the expected location."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_SCRIPT}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
if [ ! -f "${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}" ]; then
echo "[ x ] The flags script for this command was not found at the expected location."
echo "      Looking in '${SHELL_CLI_CMD_CLIGEN_ENV_CMD_FLAG_SCRIPT}'"
shell_cli_cmd_cligen_env_reset
return 1
fi
fi
return 0
}
shell_cli_cmd_cligen_set_env_action() {
echo "================================================================================"
echo "[RUN] Setting Environment"
echo ""
echo "    Workspace : ${SHELL_CLI_CMD_CLIGEN_ENV_PATH}"
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -ge "2" ]; then
echo ""
echo "      Package : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_NAME}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_PKG_PATH}"
fi
if [ "${SHELL_CLI_CMD_CLIGEN_ENV_LEVEL}" -ge "3" ]; then
echo ""
echo "      Command : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_NAME}"
echo "         Tree : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_TREE}"
echo "         Path : ${SHELL_CLI_CMD_CLIGEN_ENV_CMD_PATH}"
fi
echo ""
echo "[OKK]"
return 0
}


declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV=()
SHELL_CLI_CMD_CLIGEN_SET_ENV["cmd"]="set-env"
SHELL_CLI_CMD_CLIGEN_SET_ENV["summary"]="Sets the working environment."
SHELL_CLI_CMD_CLIGEN_SET_ENV["description"]="Sets the working environment for the other commands of this CLI as the working directory, pkg, cmd, and/or flag."
declare -ga SHELL_CLI_CMD_CLIGEN_SET_ENV_ACTION_ORDER=()


declare -ga SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("path")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["long"]="path"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["type"]="dirpath"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["required"]=true
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["description"]="Path to the root of the CLI Project architecture."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["tipinput"]="Enter the CLI project's root directory."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["validate"]='["shell_cli_utils_fs_dir_path_exists"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_path["transform"]='["shell_cli_utils_fs_to_absolute_dir_path"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("pkg")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["long"]="pkg"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["type"]="string"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["required"]=false
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["min"]="3"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["max"]="16"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["description"]="CLI Project main package name"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["tipinput"]="Enter the CLI Project main package name"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_pkg["transform"]='["shell_cli_utils_to_lowercase"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_ORDER+=("cmd")
declare -gA SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd=()
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["long"]="cmd"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["type"]="string"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["required"]=false
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["min"]="3"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["max"]="16"
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["description"]="Collection of commands chained hierarchically up to the item currently in focus."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["tipinput"]="Enter the name of the new CLI Command to be created."
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["transform"]='["shell_cli_utils_to_lowercase"]'
SHELL_CLI_CMD_CLIGEN_SET_ENV_FLAG_cmd["is_array"]=true


shell_cli_cmd_cligen_update_template_presets() {
shell_cli_cmd_cligen_utils_template_set_dirpath
return 0
}
shell_cli_cmd_cligen_update_template_validate() {
return 0
}
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


declare -gA SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE=()
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["cmd"]="update-template"
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["summary"]="Updates the templates"
SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE["description"]="Updates the templates for generating commands, flags, and other CLI features."
declare -ga SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE_ACTION_ORDER=()


declare -ga SHELL_CLI_CMD_CLIGEN_UPDATE_TEMPLATE_FLAG_ORDER=()
