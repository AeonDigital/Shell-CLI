#!/usr/bin/env bash

dumpArray() {
  local -n arr="$1"
  local k=""
  local v=""
  
  local -a sortKeys
  mapfile -t sortKeys < <(printf "%s\n" "${!arr[@]}" | sort)

  echo "DUMP OF '$1'"
  for k in "${sortKeys[@]}"; do
    v="${arr[$k]}"
    echo "- '$k' = '$v'"
  done
  echo "----  ---- -------- ----  ---- -------- ----  ----"
}
clear
sourceDir="${PWD}/src"

echo "INICIANDO"
echo "${sourceDir}"

for filePath in $(find "${sourceDir}" -type f -name "*.sh" | sort); do 
  # if [[ "$filePath" =~ "/03_metaflag/" ]]; then
  #   fileName="${filePath##*/}"
  #   if [ "${fileName}" != "00_cross_validate.sh" ] && [ "${fileName}" != "00_vars.sh" ] && [ "${fileName}" != "00_test.sh" ]; then
  #     continue
  #   fi
  # fi
  # echo $filePath
  . "$filePath"
done
echo "LOAD SOURCES"



shell_cli_compile_flag_family "METAFLAG" "SHELL_CLI_METAFLAG_DEFAULT_ORDER"
if [ "$?" != "0" ]; then
  echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
  exit 1
fi

dumpArray "METAFLAG_type"
echo "${!SHELL_CLI_FLAG_COMPILED_FAMILY[@]}"
echo "FIM"