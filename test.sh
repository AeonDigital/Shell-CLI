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


declare -gA METAFLAG_test=()
METAFLAG_test["test"]="test"
METAFLAG_test["long"]="test"
METAFLAG_test["short"]="teste"
METAFLAG_test["description"]="test"
METAFLAG_test["tipinput"]=""
METAFLAG_test["type"]="string"

METAFLAG_test["required"]=false
METAFLAG_test["default"]=""

METAFLAG_test["array"]=false
METAFLAG_test["assoc"]=true
METAFLAG_test["assoc_keys"]=""

METAFLAG_test["normalize"]=""
METAFLAG_test["validate"]=""
METAFLAG_test["transform"]=""
METAFLAG_test["regex"]="^[a-z0-9_-]+$"

METAFLAG_test["min"]="4"
METAFLAG_test["max"]="32"
METAFLAG_test["min_array"]=""
METAFLAG_test["max_array"]=""



shell_cli_metaflag_property_validate_test() {
  return 0
}

shell_cli_metaflag_check_input_test() {
  # This check should never be performed.
  # It is included here solely as a placeholder.
  local inputVal="$1"
  local typeVal="$2"
  local ruleVal="$3"
  SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'test'"
  SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
  return 1
}

shell_cli_compile_flag "METAFLAG_test"
if [ "$?" != "0" ]; then
  echo "${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
  exit 1
fi

dumpArray "METAFLAG_test"

echo "FIM"