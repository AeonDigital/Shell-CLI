#!/usr/bin/env bash

# ==============================================================================
# SINGLE-FILE DISTRIBUTION SHELL PACKAGE 
# 
# PROJECT     : Shell-CLI  
# ORIGIN URL  : https://github.com/AeonDigital/Shell-CLI  
# EXPORTED AT : 2026-08-30 00:59:17  
# LICENSE     : MIT [ https://github.com/AeonDigital/Shell-CLI/LICENSE ]  
# ==============================================================================



shell_cli_utils_array_is_indexed() {
local str_declare=$(declare -p "${1}" 2>/dev/null)
if [[ "${str_declare}" =~ ^"declare -a" ]]; then
return 0
fi
return 1
}
shell_cli_utils_array_is_assoc() {
local str_declare=$(declare -p "${1}" 2>/dev/null)
if [[ "${str_declare}" =~ ^"declare -A" ]]; then
return 0
fi
return 1
}
shell_cli_utils_array_indexed_clone() {
local originalArray="${1}"
local cloneArrayName="${2}"
if ! shell_cli_utils_array_is_indexed "${originalArray}"; then
return 1
fi
eval "declare -ga ${cloneArrayName}=()"
local -n objArray="${originalArray}"
local -n tmpClone="${cloneArrayName}"
local v=""
for v in "${objArray[@]}"; do
tmpClone+=("${v}")
done
return 0
}
shell_cli_utils_array_assoc_clone() {
local originalAssoc="${1}"
local cloneAssocName="${2}"
if ! shell_cli_utils_array_is_assoc "${originalAssoc}"; then
return 1
fi
eval "declare -gA ${cloneAssocName}=()"
local -n objAssoc="${originalAssoc}"
local -n tmpClone="${cloneAssocName}"
local k=""
local v=""
for k in "${!objAssoc[@]}"; do
v="${objAssoc[${k}]}"
tmpClone["${k}"]="${v}"
done
return 0
}


shell_cli_utils_fs_dir_path_exists() {
SHELL_CLI_FN_RETURN=""
if [ ! -d "${1}" ]; then
SHELL_CLI_FN_RETURN="The specified path does not point to an existing directory ( value='${1}' )."
return 1
fi
return 0
}
shell_cli_utils_fs_to_absolute_dir_path() {
SHELL_CLI_FN_RETURN=""
if ! shell_cli_utils_fs_dir_path_exists "${1}"; then
SHELL_CLI_FN_RETURN=""
return 1
fi
SHELL_CLI_FN_RETURN="$(cd "${1}" && pwd)"
return 0
}
shell_cli_utils_fs_file_path_exists() {
SHELL_CLI_FN_RETURN=""
if [ ! -f "${1}" ]; then
SHELL_CLI_FN_RETURN="The specified path does not point to an existing file ( value='${1}' )."
return 1
fi
return 0
}
shell_cli_utils_fs_to_absolute_file_path() {
SHELL_CLI_FN_RETURN=""
local dirpath=$(dirname "${1}")
if ! shell_cli_utils_fs_dir_path_exists "${dirpath}"; then
SHELL_CLI_FN_RETURN=""
return 1
fi
local filename=$(basename "${1}")
local absfilepath="${dirpath}/${filename}"
if ! shell_cli_utils_fs_file_path_exists "${filename}"; then
SHELL_CLI_FN_RETURN=""
return 1
fi
SHELL_CLI_FN_RETURN="${absfilepath}"
return 0
}
shell_cli_utils_fs_remove_traversal_path() {
SHELL_CLI_FN_RETURN=""
local path="${1}"
path="${path#../}"
path="${path//\/..\//\/}"
path="${path%/../}"
path="${path%../}"
SHELL_CLI_FN_RETURN="${path}"
}


shell_cli_utils_math_compare_float() {
local val1="${1}"
local val2="${2}"
local strict="${3:-0}"
local sign1="+"
local sign2="+"
[[ "${val1}" =~ ^- ]] && sign1="-"
[[ "${val2}" =~ ^- ]] && sign2="-"
local abs1="${val1#-}"
local abs2="${val2#-}"
local int1="${abs1%%.*}"
local int2="${abs2%%.*}"
local dec1="${abs1#*.}"
local dec2="${abs2#*.}"
[[ "${abs1}" != *.* ]] && dec1="0"
[[ "${abs2}" != *.* ]] && dec2="0"
[[ -z "${int1}" ]] && int1="0"
[[ -z "${int2}" ]] && int2="0"
if [[ "${sign1}" != "${sign2}" ]]; then
if [[ "${sign1}" == "+" && ( "${int1}" -ne 0 || "${dec1}" -ne 0 ) ]]; then
return 0
elif [[ "${sign2}" == "+" && ( "${int2}" -ne 0 || "${dec2}" -ne 0 ) ]]; then
return 1
fi
fi
local invert=0
[[ "${sign1}" == "-" && "${sign2}" == "-" ]] && invert=1
if (( ${int1} > ${int2} )); then
[[ "${invert}" -eq 1 ]] && return 1 || return 0
elif (( ${int1} < ${int2} )); then
[[ "${invert}" -eq 1 ]] && return 0 || return 1
fi
local len1=${#dec1}
local len2=${#dec2}
if (( ${len1} < ${len2} )); then
while (( ${#dec1} < ${len2} )); do dec1="${dec1}0"; done
elif (( ${len2} < ${len1} )); then
while (( ${#dec2} < ${len1} )); do dec2="${dec2}0"; done
fi
dec1=$((10#${dec1}))
dec2=$((10#${dec2}))
if (( ${dec1} > ${dec2} )); then
[[ "${invert}" -eq 1 ]] && return 1 || return 0
elif (( ${dec1} < ${dec2} )); then
[[ "${invert}" -eq 1 ]] && return 0 || return 1
fi
if [ "${strict}" = "1" ]; then
return 1 # Rejected as inclusive equality was disabled
fi
return 0
}
shell_cli_utils_math_is_greater_or_equal() {
shell_cli_utils_math_compare_float "${1}" "${2}" "0"
return $?
}
shell_cli_utils_math_is_less_or_equal() {
shell_cli_utils_math_compare_float "${2}" "${1}" "0"
return $?
}
shell_cli_utils_math_is_greater_than() {
shell_cli_utils_math_compare_float "${1}" "${2}" "1"
return $?
}
shell_cli_utils_math_is_less_than() {
shell_cli_utils_math_compare_float "${2}" "${1}" "1"
return $?
}


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


if [ -z "${codeNL+x}" ]; then
declare -gr codeNL=$'\n'
fi
declare -g SHELL_CLI_UTILS_STRING_WRAP_LINES=""
declare -g SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT="0"
declare -g SHELL_CLI_FN_RETURN=""
shell_cli_utils_trim_line() {
local str="${1}"
str="${str#"${str%%[![:space:]]*}"}" # trim L
SHELL_CLI_FN_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}
shell_cli_utils_trimL_line() {
local str="${1}"
SHELL_CLI_FN_RETURN="${str#"${str%%[![:space:]]*}"}" # trim L
}
shell_cli_utils_trimR_line() {
local str="${1}"
SHELL_CLI_FN_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}
shell_cli_utils_to_uppercase() {
SHELL_CLI_FN_RETURN="${1^^}"
}
shell_cli_utils_to_lowercase() {
SHELL_CLI_FN_RETURN="${1,,}"
}
shell_cli_utils_string_wrap() {
local rawText="${1}"
local targetWidth="${2:-80}"
local indentFirst="${3:-0}"
local indentRest="${4:-0}"
local maxColumns=""
local totalLines=0
local outputBuffer=""
SHELL_CLI_UTILS_STRING_WRAP_LINES=""
SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT=0
local currentCols="${COLUMNS:-80}"
if [ "${currentCols}" -lt "${targetWidth}" ] && [ "${currentCols}" -gt 20 ]; then
targetWidth="${currentCols}"
fi
if [ "${targetWidth}" -gt 120 ]; then
targetWidth="120"
fi
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
if [ "${char}" = $'\n' ]; then
if [ -n "${currentToken}" ]; then
if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
line+="${currentToken}"
else
if [ "${isSpacesToken}" -eq 0 ]; then
outputBuffer+="${usePrefix}${line}${codeNL}"
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
outputBuffer+="${usePrefix}${line}${codeNL}"
((totalLines++))
inFirstLine=0
useIndentLength="${indentRest}"
usePrefix="${prefixRest}"
line=""
while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
local chunkLength=$(( targetWidth - useIndentLength ))
outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
((totalLines++))
remainingSpaces="${remainingSpaces:$chunkLength}"
done
line="${remainingSpaces}"
fi
fi
currentToken=""
fi
outputBuffer+="${usePrefix}${line}${codeNL}"
((totalLines++))
inFirstLine=0
useIndentLength="${indentRest}"
usePrefix="${prefixRest}"
line=""
continue
fi
local isCharSpace=0
if [[ "${char}" =~ [[:space:]] ]]; then
isCharSpace=1
fi
if [ -n "${currentToken}" ]; then
if [ "${isCharSpace}" -ne "${isSpacesToken}" ]; then
if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
line+="${currentToken}"
else
if [ "${isSpacesToken}" -eq 0 ]; then
outputBuffer+="${usePrefix}${line}${codeNL}"
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
outputBuffer+="${usePrefix}${line}${codeNL}"
((totalLines++))
inFirstLine=0
useIndentLength="${indentRest}"
usePrefix="${prefixRest}"
line=""
while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
local chunkLength=$(( targetWidth - useIndentLength ))
outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
((totalLines++))
remainingSpaces="${remainingSpaces:$chunkLength}"
done
line="${remainingSpaces}"
fi
fi
currentToken=""
fi
fi
if [ -z "${currentToken}" ]; then
isSpacesToken="${isCharSpace}"
fi
currentToken+="${char}"
done
if [ -n "${currentToken}" ]; then
if (( useIndentLength + ${#line} + ${#currentToken} <= targetWidth )); then
line+="${currentToken}"
else
if [ "${isSpacesToken}" -eq 0 ]; then
outputBuffer+="${usePrefix}${line}${codeNL}"
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
outputBuffer+="${usePrefix}${line}${codeNL}"
((totalLines++))
inFirstLine=0
useIndentLength="${indentRest}"
usePrefix="${prefixRest}"
line=""
while (( ${#remainingSpaces} > (targetWidth - useIndentLength) )); do
local chunkLength=$(( targetWidth - useIndentLength ))
outputBuffer+="${usePrefix}${remainingSpaces:0:$chunkLength}${codeNL}"
((totalLines++))
remainingSpaces="${remainingSpaces:$chunkLength}"
done
line="${remainingSpaces}"
fi
fi
fi
if [ -n "${line}" ]; then
outputBuffer+="${usePrefix}${line}${codeNL}"
((totalLines++))
fi
SHELL_CLI_UTILS_STRING_WRAP_LINES="${outputBuffer:0: -1}"
SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT="${totalLines}"
return 0
}
shell_cli_utils_string_replace_placeholder() {
SHELL_CLI_FN_RETURN=""
local filepath="${1}"
if [ ! -f "${filepath}" ]; then
return 1
fi
if ! shell_cli_utils_array_is_assoc "${2}"; then
return 2
fi
local -n assocPH="${2}"
local filecontent=$(< "${filepath}")
if [ "${filecontent}" = "" ] || [ "${#assocPH[@]}" = "0" ]; then
return 0
fi
local k=""
local v=""
local ph=""
for k in "${!assocPH[@]}"; do
ph="{{${k}}}"
v="${assocPH["${k}"]}"
filecontent="${filecontent//${ph}/${v}}"
done
SHELL_CLI_FN_RETURN="${filecontent}"
return 0
}


declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME=""
declare -ga SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()
declare SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE=""
shell_cli_parse_sarray_to_array() {
local value="${1}"
value=$(printf "%s" "${value}" | tr -d '\000-\010\013\014\016-\037\177')
value="${value#"${value%%[![:space:]]*}"}" # trim L
value="${value%"${value##*[![:space:]]}"}" # trim R
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING=""
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME=""
SHELL_CLI_PARSE_SARRAY_TO_ARRAY=()
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE=""
if [ "${value}" == "" ]; then
return 0
fi
if shell_cli_utils_array_is_indexed "${value}"; then
local -n tmp_array="${value}"
local i=""
local v=""
local stringifiedArray="["
for i in "${!tmp_array[@]}"; do
v="${tmp_array[${i}]}"
SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("${v}")
if [ "${i}" -gt "0" ]; then
stringifiedArray+=","
fi
stringifiedArray+="\"${v}\""
done
stringifiedArray="]"
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="${stringifiedArray}"
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME="${value}"
return 0
fi
if [[ "${value}" =~ ^\[[[:space:]]*\]$ ]]; then
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="[]"
return 0
fi
if [ "${value:0:1}" != "[" ] || [ "${value: -1}" != "]" ]; then
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; loss of square brackets."
return 1
fi
local inner="${value#?}"
inner="${inner%?}"
local nl=$'\n'
local idx="0"
local len=${#inner}
local lastCharIndex=$((${len} - 1))
local char=""
local previousChar=""
local reading="value" # 'value' ; ','
local openvalue="0"
local currentvalue=""
local openvaluewith=""
local -a arr_tmp_values=()
while [ "${idx}" -lt "${len}" ]; do
char="${inner:${idx}:1}"
if [ "${reading}" = "value" ]; then
if [ "${openvalue}" = "0" ]; then
if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
if [[ "${char}" =~ ^[0-9A-Za-z\'\".]+$ ]]; then
openvalue="1"
currentvalue=""
openvaluewith=""
if [ "${char}" = "'" ] || [ "${char}" = '"' ]; then
openvaluewith="${char}"
else
currentvalue="${char}"
fi
else
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
fi
fi
elif [ "${openvalue}" = "1" ]; then
local stopread="0"
if [ "${openvaluewith}" = "" ]; then
if [ "${char}" = " " ] || [ "${char}" = "," ] || [ "${char}" = "${nl}" ]; then
stopread="1"
elif [ "${char}" = "'" ] || [ "${char}" = '"' ] || [[ ! "${char}" =~ ^[0-9A-Za-z.]+$ ]]; then
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
fi
if [ "${idx}" = "${lastCharIndex}" ]; then
stopread="1"
currentvalue+="${char}"
fi
elif [ "${openvaluewith}" != "" ]; then
if [ "${char}" = "${openvaluewith}" ]; then
if [ "${previousChar}" != "\\" ]; then
stopread="1"
else
if [ "${idx}" = "${lastCharIndex}" ]; then
stopread="1"
currentvalue+="${char}"
fi
fi
fi
fi
if [ "${stopread}" = "0" ]; then
currentvalue+="${char}"
else
reading=","
arr_tmp_values+=("${currentvalue}")
openvalue="0"
currentvalue=""
openvaluewith=""
if [ "${char}" = "," ]; then
reading="value"
fi
fi
fi
elif [ "${reading}" = "," ]; then
if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
if [ "${char}" != "," ]; then
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
else
reading="value"
fi
fi
fi
idx=$((${idx} + 1))
previousChar="${char}"
done
local i=""
local v=""
local stringifiedArray="["
for i in "${!arr_tmp_values[@]}"; do
v="${arr_tmp_values[${i}]}"
SHELL_CLI_PARSE_SARRAY_TO_ARRAY+=("${v}")
if [ "${i}" -gt "0" ]; then
stringifiedArray+=","
fi
stringifiedArray+="\"${v}\""
done
stringifiedArray="]"
SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING="${stringifiedArray}"
return 0
}


declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME=""
declare -gA SHELL_CLI_PARSE_SJSON_TO_ASSOC=()
declare -ga SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()
declare SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE=""
shell_cli_parse_sjson_to_assoc() {
local value="${1}"
value=$(printf "%s" "${value}" | tr -d '\000-\010\013\014\016-\037\177')
value="${value#"${value%%[![:space:]]*}"}" # trim L
value="${value%"${value##*[![:space:]]}"}" # trim R
SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING=""
SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME=""
SHELL_CLI_PARSE_SJSON_TO_ASSOC=()
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER=()
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE=""
if [ "${value}" == "" ]; then
return 0
fi
if shell_cli_utils_array_is_assoc "${value}"; then
local -n tmp_assoc="${value}"
local k=""
local v=""
local stringifiedJSON+="{"
for k in "${!tmp_assoc[@]}"; do
v="${tmp_assoc[${k}]}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC["${k}"]="${v}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("${k}")
if [ "${stringifiedJSON}" != "{" ]; then
stringifiedJSON+=","
fi
stringifiedJSON+="\"${k}\":\"${v}\""
done
stringifiedJSON+="}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="${stringifiedJSON}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME="${value}"
return 0
fi
if [[ "${value}" =~ ^\{[[:space:]]*\}$ ]]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="{}"
return 0
fi
if [ "${value:0:1}" != "{" ] || [ "${value: -1}" != "}" ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; loss of curly brackets."
return 1
fi
local inner="${value#?}"
inner="${inner%?}"
local nl=$'\n'
local idx="0"
local len=${#inner}
local lastCharIndex=$((${len} - 1))
local char=""
local previousChar=""
local reading="key" # 'key' ; ':' ; 'value' ; ','
local openkey="0"
local currentkey=""
local openkeywith=""
local -a arr_tmp_keys=()
local openvalue="0"
local currentvalue=""
local openvaluewith=""
local -a arr_tmp_values=()
while [ "${idx}" -lt "${len}" ]; do
char="${inner:${idx}:1}"
if [ "${reading}" = "key" ]; then
if [ "${openkey}" = "0" ]; then
if [ "${char}" = "'" ] || [ "${char}" = '"' ]; then
openkey="1"
currentkey=""
openkeywith="${char}"
fi
elif [ "${openkey}" = "1" ]; then
if [ "${char}" != "${openkeywith}" ]; then
if [ "${char}" = "${nl}" ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; found \\n char in key name."
return 1
fi
currentkey+="${char}"
else
if [ "${currentkey}" = "" ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; unexpected empty key."
return 1
fi
reading=":"
arr_tmp_keys+=("${currentkey}")
openkey="0"
currentkey=""
openkeywith=""
fi
fi
elif [ "${reading}" = ":" ]; then
if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
if [ "${char}" != ":" ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
else
reading="value"
openvalue="0"
currentvalue=""
openvaluewith=""
fi
fi
elif [ "${reading}" = "value" ]; then
if [ "${openvalue}" = "0" ]; then
if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
if [[ "${char}" =~ ^[0-9A-Za-z\'\".]+$ ]]; then
openvalue="1"
currentvalue=""
openvaluewith=""
if [ "${char}" = "'" ] || [ "${char}" = '"' ]; then
openvaluewith="${char}"
else
currentvalue="${char}"
fi
else
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
fi
fi
elif [ "${openvalue}" = "1" ]; then
local stopread="0"
if [ "${openvaluewith}" = "" ]; then
if [ "${char}" = " " ] || [ "${char}" = "," ] || [ "${char}" = "${nl}" ]; then
stopread="1"
elif [ "${char}" = "'" ] || [ "${char}" = '"' ] || [[ ! "${char}" =~ ^[0-9A-Za-z.]+$ ]]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
fi
if [ "${idx}" = "${lastCharIndex}" ]; then
stopread="1"
currentvalue+="${char}"
fi
elif [ "${openvaluewith}" != "" ]; then
if [ "${char}" = "${openvaluewith}" ]; then
if [ "${previousChar}" != "\\" ]; then
stopread="1"
else
if [ "${idx}" = "${lastCharIndex}" ]; then
stopread="1"
currentvalue+="${char}"
fi
fi
fi
fi
if [ "${stopread}" = "0" ]; then
currentvalue+="${char}"
else
reading=","
arr_tmp_values+=("${currentvalue}")
openvalue="0"
currentvalue=""
openvaluewith=""
if [ "${char}" = "," ]; then
reading="key"
fi
fi
fi
elif [ "${reading}" = "," ]; then
if [ "${char}" != " " ] && [ "${char}" != "${nl}" ]; then
if [ "${char}" != "," ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid syntax; char '${char}' in invalid position [ idx: ${idx} ]."
return 1
else
reading="key"
fi
fi
fi
idx=$((${idx} + 1))
previousChar="${char}"
done
local klen="${#arr_tmp_keys[@]}"
local vlen="${#arr_tmp_values[@]}"
if [ "${klen}" != "${vlen}" ]; then
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid parse; found '${klen}' keys to '${vlen}' values."
return 1
else
local k=""
local -A arr_duplicated=()
for k in "${arr_tmp_keys[@]}"; do
if [ "${arr_duplicated["${k}"]}" = "" ]; then
arr_duplicated["${k}"]="1"
continue
fi
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE="invalid object; duplicated key '${k}'."
return 1
done
fi
local i=""
local k=""
local v=""
local stringifiedJSON+="{"
for i in "${!arr_tmp_keys[@]}"; do
if [ "${i}" -gt "0" ]; then
stringifiedJSON+=","
fi
k="${arr_tmp_keys[${i}]}"
v="${arr_tmp_values[${i}]}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC["${k}"]="${v}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER+=("${k}")
stringifiedJSON+="\"${k}\":\"${v}\""
done
stringifiedJSON+="}"
SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING="${stringifiedJSON}"
return 0
}


shell_cli_type_normalize_main() {
local value="${1}"
local removeCodeCtrlChars="${2}"
local removeTextCtrlChars="${3}"
local trim="${4}"
SHELL_CLI_FN_RETURN=""
local clean_text="${value}"
if [ "${removeCodeCtrlChars}" = "1" ]; then
local code_ctrl_chars=""
code_ctrl_chars+=$'\000'$'\001'$'\002'$'\003'$'\004'$'\005'$'\006'$'\007'$'\010'
code_ctrl_chars+=$'\013'$'\014'$'\016'$'\017'$'\020'$'\021'$'\022'$'\023'$'\024'
code_ctrl_chars+=$'\025'$'\026'$'\027'$'\030'$'\031'$'\032'$'\033'$'\034'$'\035'
code_ctrl_chars+=$'\036'$'\037'$'\177'
clean_text=$(printf "%s" "${clean_text}" | tr -d "${code_ctrl_chars}")
fi
if [ "${removeTextCtrlChars}" = "1" ]; then
local text_ctrl_chars=$'\011'$'\012'$'\015'
clean_text=$(printf "%s" "${clean_text}" | tr -d "${text_ctrl_chars}")
fi
if [ "${trim}" = "1" ]; then
clean_text="${clean_text#"${clean_text%%[![:space:]]*}"}" # trim L
clean_text="${clean_text%"${clean_text##*[![:space:]]}"}" # trim R
fi
SHELL_CLI_FN_RETURN="${clean_text}"
return 0
}
shell_cli_type_validate_main() {
local value="${1}"
local invalidateCodeCtrlChars="${2}"
local invalidateTextCtrlChars="${3}"
if [ "${invalidateCodeCtrlChars}" = "1" ]; then
local code_ctrl_chars=""
code_ctrl_chars+=$'\000'$'\001'$'\002'$'\003'$'\004'$'\005'$'\006'$'\007'$'\010'
code_ctrl_chars+=$'\013'$'\014'$'\016'$'\017'$'\020'$'\021'$'\022'$'\023'$'\024'
code_ctrl_chars+=$'\025'$'\026'$'\027'$'\030'$'\031'$'\032'$'\033'$'\034'$'\035'
code_ctrl_chars+=$'\036'$'\037'$'\177'
if [[ "${value}" =~ [${code_ctrl_chars}] ]]; then
return 10
fi
fi
if [ "${invalidateTextCtrlChars}" = "1" ]; then
local text_ctrl_chars=$'\011'$'\012'$'\015'
if [[ "${value}" =~ [${text_ctrl_chars}] ]]; then
return 10
fi
fi
return 0
}
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_STRING=""
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_NAME=""
declare -ga SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY=()
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_ERR_MESSAGE=""
shell_cli_type_normalize_main_array() {
shell_cli_parse_sarray_to_array "${1}"
local parseStatus="$?"
SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_STRING="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_STRING}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_NAME="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY=()
SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY_ERR_MESSAGE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE}"
local i=""
for i in "${!SHELL_CLI_PARSE_SARRAY_TO_ARRAY[@]}"; do
SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY+=("${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[${i}]}")
done
return "${parseStatus}"
}
shell_cli_type_normalize_main_array_types() {
local strReturn="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_main "${strReturn}" "1" "0" "1"
local strNormalizated="${SHELL_CLI_FN_RETURN}"
if shell_cli_type_normalize_main_array "${strNormalizated}"; then
strReturn="SHELL_CLI_TYPE_NORMALIZE_TMP_ARRAY"
if [ "${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}" != "" ]; then
strReturn="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}"
fi
fi
SHELL_CLI_FN_RETURN="${strReturn}"
return 0
}
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX=""
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE=""
shell_cli_type_validate_main_array_types() {
local value="${1}"
local aux="${2}"
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX=""
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE=""
if ! shell_cli_type_normalize_main "${value}" "1" "0" "1"; then
return 10
fi
if ! shell_cli_utils_array_is_indexed "${aux}"; then
return 2
fi
local i=""
local v=""
local -n tmpAssoc="${aux}"
for i in "${!tmpAssoc[@]}"; do
v="${tmpAssoc[$i]}"
if [ "${value}" = "${i}" ] || [ "${value}" = "${v}" ]; then
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_INDEX="${i}"
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ARRAY_VALUE="${v}"
return 0
fi
done
return 1
}
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_STRING=""
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME=""
declare -gA SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC=()
declare -ga SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER=()
declare -g SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ERR_MESSAGE=""
shell_cli_type_normalize_main_assoc() {
shell_cli_parse_sjson_to_assoc "${1}"
local parseStatus="$?"
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_STRING="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_STRING}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC=()
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER=()
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ERR_MESSAGE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE}"
local k=""
local v=""
local i=""
for i in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[@]}"; do
k="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[${i}]}"
v="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[${k}]}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC["${k}"]="${v}"
SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_ORDER+=("${k}")
done
return "${parseStatus}"
}
shell_cli_type_normalize_main_assoc_types() {
local strReturn="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_main "${strReturn}" "1" "0" "1"
local strNormalizated="${SHELL_CLI_FN_RETURN}"
if shell_cli_type_normalize_main_assoc "${strNormalizated}"; then
strReturn="SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC"
if [ "${SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME}" != "" ]; then
strReturn="${SHELL_CLI_TYPE_NORMALIZE_TMP_ASSOC_NAME}"
fi
fi
SHELL_CLI_FN_RETURN="${strReturn}"
return 0
}
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY=""
declare -g SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE=""
shell_cli_type_validate_main_assoc_types() {
local value="${1}"
local aux="${2}"
SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY=""
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE=""
if ! shell_cli_type_normalize_main "${value}" "1" "0" "1"; then
return 10
fi
if ! shell_cli_utils_array_is_assoc "${aux}"; then
return 2
fi
local k=""
local v=""
local -n tmpAssoc="${aux}"
for k in "${!tmpAssoc[@]}"; do
v="${tmpAssoc[$k]}"
if [ "${value}" = "${k}" ] || [ "${value}" = "${v}" ]; then
SHELL_CLI_TYPE_VALIDATE_TMP_ASSOC_SELECTED_KEY="${k}"
SHELL_CLI_TYPE_VALIDATE_TMP_SELECTED_ASSOC_VALUE="${v}"
return 0
fi
done
return 1
}


declare -gA SHELL_CLI_TYPE=(
["string"]="string"
["text"]="text"
["code"]="code"
["bool"]="bool"
["int"]="int"
["float"]="float"
["time"]="time"
["date"]="date"
["datetime"]="datetime"
["email"]="email"
["array"]="array"
["json"]="json"
["function"]="function"
["path"]="path"
["relativepath"]="relativepath"
["filename"]="filename"
["filepath"]="filepath"
["dirname"]="dirname"
["dirpath"]="dirpath"
["url"]="url"
["fullurl"]="fullurl"
["relativeurl"]="relativeurl"
)


shell_cli_type_normalize_string() {
local value="${1}"
shell_cli_type_normalize_main "${value}" "1" "1" "1"
return 0
}
shell_cli_type_validate_string() {
local value="${1}"
local aux="${2}"
shell_cli_type_validate_main "${value}" "1" "1"
local status=$?
return "${status}"
}


shell_cli_type_normalize_text() {
local value="${1}"
shell_cli_type_normalize_main "${value}" "1" "0" "1"
return 0
}
shell_cli_type_validate_text() {
local value="${1}"
local aux="${2}"
shell_cli_type_validate_main "${value}" "1" "0"
local status=$?
return "${status}"
}


shell_cli_type_normalize_code() {
local value="${1}"
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_code() {
local value="${1}"
local aux="${2}"
return 0
}


shell_cli_type_normalize_bool() {
local origValue="${1}"
shell_cli_type_normalize_string "${origValue,,}"
local value="${SHELL_CLI_FN_RETURN}"
case "${value}" in
0|false) value="0"   ;;
1|true)  value="1"   ;;
*)       value="${origValue}" ;;
esac
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_bool() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [ "${value}" != "1" ] && [ "${value}" != "0" ]; then
return 1
fi
return 0
}


shell_cli_type_normalize_int() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_int() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [[ ! "${value}" =~ ^-?[0-9]+$ ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_float() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_float() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [[ ! "${value}" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_time() {
local origValue="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_string "${origValue}"
local value="${SHELL_CLI_FN_RETURN}"
case "${#value}" in
2) value="${value}:00:00" ;; # HH     -> HH:00:00
5) value="${value}:00"    ;; # HH:MM  -> HH:MM:00
8) value="${value}"       ;; # Fully formed
*) value="${origValue}"   ;;
esac
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_time() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [ "${#value}" != "8" ]; then
return 1
fi
local ts=$(date -d "0001-01-01 ${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "0001-01-01 ${value}" +%s 2>/dev/null)
local check_val=$(date -d "@${ts}" +%H:%M:%S 2>/dev/null || date -j -r "${ts}" +%H:%M:%S 2>/dev/null)
if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
return 1
fi
return 0
}


shell_cli_type_normalize_date() {
local origValue="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_string "${origValue}"
local value="${SHELL_CLI_FN_RETURN}"
case "${#value}" in
4)  value="${value}-01-01" ;; # YYYY     -> YYYY-01-01
7)  value="${value}-01"    ;; # YYYY-MM  -> YYYY-MM-01
10) value="${value}"       ;; # Fully formed
*)  value="${origValue}"   ;;
esac
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_date() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [ "${#value}" != "10" ]; then
return 1
fi
local ts=$(date -d "${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${value}" +%s 2>/dev/null)
local check_val=$(date -d "@${ts}" +%Y-%m-%d 2>/dev/null || date -j -r "${ts}" +%Y-%m-%d 2>/dev/null)
if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
return 1
fi
return 0
}


shell_cli_type_normalize_datetime() {
local origValue="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_string "${origValue}"
local value="${SHELL_CLI_FN_RETURN}"
local date_part=""
local time_part=""
if [[ "${value}" == *[[:space:]]* ]]; then
date_part="${value%% *}"
time_part="${value#* }"
else
if [[ "${value}" == *:* ]]; then
date_part="0001-01-01"
time_part="${value}"
else
date_part="${value}"
time_part="00:00:00"
fi
fi
shell_cli_type_normalize_date "${date_part}"
local clean_date="${SHELL_CLI_FN_RETURN}"
shell_cli_type_normalize_time "${time_part}"
local clean_time="${SHELL_CLI_FN_RETURN}"
SHELL_CLI_FN_RETURN="${clean_date} ${clean_time}"
return 0
}
shell_cli_type_validate_datetime() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [ "${#value}" != "19" ]; then
return 1
fi
if [[ ! "${value}" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[0-9]|3)[[:space:]]([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]; then
return 1
fi
local ts=$(date -d "${value}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${value}" +%s 2>/dev/null)
local check_val=$(date -d "@${ts}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -j -r "${ts}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
if [ -z "${ts}" ] || [ "${value}" != "${check_val}" ]; then
return 1
fi
return 0
}


shell_cli_type_normalize_email() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_email() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
local email_regex="^[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+|xn--[A-Za-z0-9-]+)\.[A-Za-z]{2,}$"
if [[ ! "${value}" =~ ${email_regex} ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_array() {
local origValue="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_string "${origValue}"
local value="${SHELL_CLI_FN_RETURN}"
if shell_cli_parse_sarray_to_array "${value}"; then
value="SHELL_CLI_PARSE_SARRAY_TO_ARRAY"
if [ "${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}" != "" ]; then
value="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_NAME}"
fi
else
value="${origValue}"
fi
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_array() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_parse_sarray_to_array "${value}"; then
return 2
fi
return 0
}


shell_cli_type_normalize_json() {
local origValue="${1}"
SHELL_CLI_FN_RETURN=""
shell_cli_type_normalize_string "${origValue}"
local value="${SHELL_CLI_FN_RETURN}"
if shell_cli_parse_sjson_to_assoc "${value}"; then
value="SHELL_CLI_PARSE_SJSON_TO_ASSOC"
if [ "${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}" != "" ]; then
value="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_NAME}"
fi
else
value="${origValue}"
fi
SHELL_CLI_FN_RETURN="${value}"
return 0
}
shell_cli_type_validate_json() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_parse_sjson_to_assoc "${value}"; then
return 2
fi
return 0
}


shell_cli_type_normalize_function() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_function() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if declare -f "${value}" >/dev/null; then
return 0
fi
return 1
}


shell_cli_type_normalize_path() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_path() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [[ "${value}" =~ [\*\?\"\<\>\|] ]]; then
return 1
fi
if [[ "${value}" =~ : ]] && [[ ! "${value}" =~ ^[A-Za-z]: ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_relativepath() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_relativepath() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_type_validate_path "${value}"; then
return 1
fi
if [[ "${value}" =~ ^\/ ]] || [[ "${value}" =~ ^[A-Za-z]:\\ ]] || [[ "${value}" =~ ^[A-Za-z]:\/ ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_filename() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_filename() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [[ "${value}" == *\/* ]] || [[ "${value}" == *\\* ]] || [ -z "${value}" ]; then
return 1
fi
if [[ "${value}" =~ [\*\?\"\<\>\|:] ]]; then
return 1
fi
if [[ "${value}" =~ : ]] && [[ ! "${value}" =~ ^[A-Za-z]: ]]; then
return 1
fi
return 0
}


shell_cli_type_normalize_filepath() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_filepath() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_type_validate_path "${value}"; then
return 1
fi
if [[ "${value}" =~ \/$ ]] || [[ "${value}" =~ \\$ ]] || [ -z "${value}" ]; then
return 1
fi
return 0
}


shell_cli_type_normalize_dirname() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_dirname() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_type_validate_filename "${value}"; then
return 1
fi
return 0
}


shell_cli_type_normalize_dirpath() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_dirpath() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if ! shell_cli_type_validate_path "${value}"; then
return 1
fi
return 0
}


shell_cli_type_normalize_url() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_url() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if shell_cli_type_validate_fullurl "${value}" || shell_cli_type_validate_relativeurl "${value}"; then
return 0
fi
return 1
}


shell_cli_type_normalize_fullurl() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_fullurl() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
local url_regex="^(https?|ftp|file):\/\/([A-Za-z0-9.-]+)(:[0-9]+)?(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$"
if [[ "${value}" =~ ${url_regex} ]]; then
return 0
fi
return 1
}


shell_cli_type_normalize_relativeurl() {
local value="${1}"
shell_cli_type_normalize_string "${value}"
return 0
}
shell_cli_type_validate_relativeurl() {
local value="${1}"
local aux="${2}"
if ! shell_cli_type_validate_string "${value}"; then
return 10
fi
if [[ "${value}" =~ ^https?:\/\/ ]] || [[ "${value}" =~ ^ftp:\/\/ ]]; then
return 1
fi
if [[ "${value}" =~ ^\/[A-Za-z0-9._%+-]*(\/[A-Za-z0-9._%+-]*)*(\?.*)?(#.*)?$ ]]; then
return 0
fi
return 1
}


shell_cli_metaflag_property_cross_validate_min_max() {
local fassoc="${2}"
local -n __assoc="${fassoc}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${__assoc["__cross_min_max"]}" == "1" ]; then
return 0
fi
local _min="${__assoc["min"]}"
local _max="${__assoc["max"]}"
if [ "${_min}" != "" ] && [ "${_max}" != "" ]; then
local _type="${__assoc["type"]}"
case "${_type}" in
int)
if (( ${_min} > ${_max} )); then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
return 1
fi
;;
float)
if ! shell_cli_utils_math_is_less_or_equal "${_min}" "${_max}" "0"; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
return 1
fi
;;
time|date|datetime)
local prefix=""
local fmt="%Y-%m-%d %H:%M:%S"
if [ "${_type}" = "date" ]; then
fmt="%Y-%m-%d"
elif [ "${_type}" = "time" ]; then
prefix="0001-01-01 "
fi
local min_sec=$(date -d "${prefix}${_min}" +%s 2>/dev/null || date -j -f "${fmt}" "${prefix}${_min}" +%s 2>/dev/null)
local max_sec=$(date -d "${prefix}${_max}" +%s 2>/dev/null || date -j -f "${fmt}" "${prefix}${_max}" +%s 2>/dev/null)
if (( ${min_sec} > ${max_sec} )); then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' limit cannot exceed 'max' ( min='${_min}', max='${_max}' )."
return 1
fi
;;
*)
if (( ${_min} > ${_max} )); then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min' length cannot exceed 'max' ( min='${_min}', max='${_max}' )."
return 1
fi
;;
esac
fi
__assoc["__cross_min_max"]="1"
return 0
}
shell_cli_metaflag_property_cross_validate_min_array_max_array() {
local fassoc="${2}"
local -n __assoc="${fassoc}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${__assoc["__cross_min_array_max_array"]}" == "1" ]; then
return 0
fi
local _array="${__assoc["is_array"]}"
local _min_array="${__assoc["min_array"]}"
local _max_array="${__assoc["max_array"]}"
if [ "${_array}" = "1" ] && [ "${_min_array}" != "" ] && [ "${_max_array}" != "" ]; then
if (( ${_min_array} > ${_max_array} )); then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="'min_array' limit cannot exceed 'max_array' ( min_array='${_min_array}', max_array='${_max_array}' )."
return 1
fi
fi
__assoc["__cross_min_array_max_array"]="1"
return 0
}


declare -g SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
declare -g SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()
declare -gA SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()
declare -ga SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()
declare -gA SHELL_CLI_METAFLAG_DEFAULT=()
SHELL_CLI_METAFLAG_DEFAULT["long"]=""
SHELL_CLI_METAFLAG_DEFAULT["short"]=""
SHELL_CLI_METAFLAG_DEFAULT["type"]=""
SHELL_CLI_METAFLAG_DEFAULT["accept_values"]=""
SHELL_CLI_METAFLAG_DEFAULT["description"]=""
SHELL_CLI_METAFLAG_DEFAULT["tipinput"]=""
SHELL_CLI_METAFLAG_DEFAULT["default"]=""
SHELL_CLI_METAFLAG_DEFAULT["required"]=false
SHELL_CLI_METAFLAG_DEFAULT["normalize"]=""
SHELL_CLI_METAFLAG_DEFAULT["min"]=""
SHELL_CLI_METAFLAG_DEFAULT["max"]=""
SHELL_CLI_METAFLAG_DEFAULT["regex"]=""
SHELL_CLI_METAFLAG_DEFAULT["validate"]=""
SHELL_CLI_METAFLAG_DEFAULT["transform"]=""
SHELL_CLI_METAFLAG_DEFAULT["is_array"]=false
SHELL_CLI_METAFLAG_DEFAULT["min_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["max_array"]=""
SHELL_CLI_METAFLAG_DEFAULT["is_assoc"]=false
SHELL_CLI_METAFLAG_DEFAULT["required_keys"]=""
declare -ga SHELL_CLI_METAFLAG_DEFAULT_ORDER=()
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("long")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("short")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("type")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("accept_values")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("description")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("tipinput")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("default")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("normalize")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("regex")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("validate")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("transform")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("is_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("min_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("max_array")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("is_assoc")
SHELL_CLI_METAFLAG_DEFAULT_ORDER+=("required_keys")


declare -gA METAFLAG_long=()
METAFLAG_long["long"]="long"
METAFLAG_long["short"]=""
METAFLAG_long["type"]="string"
METAFLAG_long["accept_values"]=""
METAFLAG_long["description"]="Long canonical name identifier for the flag execution mapping."
METAFLAG_long["tipinput"]=""
METAFLAG_long["default"]=""
METAFLAG_long["required"]=true
METAFLAG_long["normalize"]=""
METAFLAG_long["min"]="4"
METAFLAG_long["max"]="16"
METAFLAG_long["regex"]="^[a-z0-9_-]+$"
METAFLAG_long["validate"]=""
METAFLAG_long["transform"]=""
METAFLAG_long["is_array"]=false
METAFLAG_long["min_array"]=""
METAFLAG_long["max_array"]=""
METAFLAG_long["is_assoc"]=false
METAFLAG_long["required_keys"]=""
shell_cli_metaflag_property_validate_long() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
if [[ "${fval}" =~ ^(help|interactive)$ ]]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'help' and 'interactive' are reserved."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_long() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'long'"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
return 1
}


declare -gA METAFLAG_short=()
METAFLAG_short["long"]="short"
METAFLAG_short["short"]=""
METAFLAG_short["type"]="string"
METAFLAG_short["accept_values"]=""
METAFLAG_short["description"]="Short alphanumeric character alias for the flag (1 to 3 chars)."
METAFLAG_short["tipinput"]=""
METAFLAG_short["default"]=""
METAFLAG_short["required"]=false
METAFLAG_short["normalize"]=""
METAFLAG_short["min"]="1"
METAFLAG_short["max"]="3"
METAFLAG_short["regex"]="^[a-zA-Z0-9]+$"
METAFLAG_short["validate"]=""
METAFLAG_short["transform"]=""
METAFLAG_short["is_array"]=false
METAFLAG_short["min_array"]=""
METAFLAG_short["max_array"]=""
METAFLAG_short["is_assoc"]=false
METAFLAG_short["required_keys"]=""
shell_cli_metaflag_property_validate_short() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
if [[ "${fval}" =~ ^(h|itr)$ ]]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="names 'h' and 'itr' are reserved."
return 1
fi
local -n __assoc="${fassoc}"
local _long="${__assoc["long"]}"
if [ "${fval}" = "${_long}" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be the same as 'long' ( short='${fval}' )."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_short() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'short'"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
return 1
}


declare -gA METAFLAG_type=()
METAFLAG_type["long"]="type"
METAFLAG_type["short"]=""
METAFLAG_type["type"]="string"
METAFLAG_type["accept_values"]="SHELL_CLI_TYPE"
METAFLAG_type["description"]="Data type classification enforcing specific core parsing and validation pipelines."
METAFLAG_type["tipinput"]=""
METAFLAG_type["default"]=""
METAFLAG_type["required"]=true
METAFLAG_type["normalize"]=""
METAFLAG_type["min"]=""
METAFLAG_type["max"]=""
METAFLAG_type["regex"]=""
METAFLAG_type["validate"]=""
METAFLAG_type["transform"]=""
METAFLAG_type["is_array"]=false
METAFLAG_type["min_array"]=""
METAFLAG_type["max_array"]=""
METAFLAG_type["is_assoc"]=false
METAFLAG_type["required_keys"]=""
shell_cli_metaflag_property_validate_type() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
return 0
}
shell_cli_metaflag_check_input_type() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'type'"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
return 1
}


declare -gA METAFLAG_accept_values=()
METAFLAG_accept_values["long"]="accept_values"
METAFLAG_accept_values["short"]=""
METAFLAG_accept_values["type"]="text"
METAFLAG_accept_values["accept_values"]=""
METAFLAG_accept_values["description"]="Pointer to assoc array where 'keys' are the real options to accept."
METAFLAG_accept_values["tipinput"]=""
METAFLAG_accept_values["default"]=""
METAFLAG_accept_values["required"]=false
METAFLAG_accept_values["normalize"]=""
METAFLAG_accept_values["min"]=""
METAFLAG_accept_values["max"]=""
METAFLAG_accept_values["regex"]=""
METAFLAG_accept_values["validate"]=""
METAFLAG_accept_values["transform"]=""
METAFLAG_accept_values["is_array"]=false
METAFLAG_accept_values["min_array"]=""
METAFLAG_accept_values["max_array"]=""
METAFLAG_accept_values["is_assoc"]=true
METAFLAG_accept_values["required_keys"]=""
shell_cli_metaflag_property_validate_accept_values() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
if ! shell_cli_utils_array_is_assoc "${fval}"; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an associative array (declare -A)."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_accept_values() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local -n flagEnum="${ruleVal}"
local k=""
local v=""
for k in "${!flagEnum[@]}"; do
v="${flagEnum[${k}]}"
if [ "${inputVal}" = "${k}" ] || [ "${inputVal}" = "${v}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${k}"
return 0
fi
done
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="expected one of '${ruleVal}' collection member; ( value: '${inputVal}' )"
return 1
}


declare -gA METAFLAG_description=()
METAFLAG_description["long"]="description"
METAFLAG_description["short"]=""
METAFLAG_description["type"]="text"
METAFLAG_description["accept_values"]=""
METAFLAG_description["description"]="Human-readable operational statement describing flag objective for automated UI rendering."
METAFLAG_description["tipinput"]=""
METAFLAG_description["default"]=""
METAFLAG_description["required"]=true
METAFLAG_description["normalize"]=""
METAFLAG_description["min"]="4"
METAFLAG_description["max"]="256"
METAFLAG_description["regex"]=""
METAFLAG_description["validate"]=""
METAFLAG_description["transform"]=""
METAFLAG_description["is_array"]=false
METAFLAG_description["min_array"]=""
METAFLAG_description["max_array"]=""
METAFLAG_description["is_assoc"]=false
METAFLAG_description["required_keys"]=""
shell_cli_metaflag_property_validate_description() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
return 0
}
shell_cli_metaflag_check_input_description() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'description'"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
return 1
}


declare -gA METAFLAG_tipinput=()
METAFLAG_tipinput["long"]="tipinput"
METAFLAG_tipinput["short"]=""
METAFLAG_tipinput["type"]="text"
METAFLAG_tipinput["accept_values"]=""
METAFLAG_tipinput["description"]="Custom interactive question phrase displayed during user prompt execution."
METAFLAG_tipinput["tipinput"]=""
METAFLAG_tipinput["default"]=""
METAFLAG_tipinput["required"]=false
METAFLAG_tipinput["normalize"]=""
METAFLAG_tipinput["min"]="4"
METAFLAG_tipinput["max"]="256"
METAFLAG_tipinput["regex"]=""
METAFLAG_tipinput["validate"]=""
METAFLAG_tipinput["transform"]=""
METAFLAG_tipinput["is_array"]=false
METAFLAG_tipinput["min_array"]=""
METAFLAG_tipinput["max_array"]=""
METAFLAG_tipinput["is_array"]=false
METAFLAG_tipinput["required_keys"]=""
shell_cli_metaflag_property_validate_tipinput() {
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
return 0
}
shell_cli_metaflag_check_input_tipinput() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="inapplicable validation of 'tipinput'"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="!ERR"
return 1
}


declare -gA METAFLAG_default=()
METAFLAG_default["long"]="default"
METAFLAG_default["short"]=""
METAFLAG_default["type"]="code"
METAFLAG_default["accept_values"]=""
METAFLAG_default["description"]="Fallback visual or data value applied if the user execution omits the parameter."
METAFLAG_default["tipinput"]=""
METAFLAG_default["default"]=""
METAFLAG_default["required"]=false
METAFLAG_default["normalize"]=""
METAFLAG_default["min"]=""
METAFLAG_default["max"]=""
METAFLAG_default["regex"]=""
METAFLAG_default["validate"]=""
METAFLAG_default["transform"]=""
METAFLAG_default["is_array"]=false
METAFLAG_default["min_array"]=""
METAFLAG_default["max_array"]=""
METAFLAG_default["is_assoc"]=false
METAFLAG_default["required_keys"]=""
shell_cli_metaflag_property_validate_default() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
local -n __assoc="${fassoc}"
local _required="${__assoc["required"]}"
if [ "${fval}" != "" ] && [ "${_required}" = "1" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot provision a 'default' assignment if 'required=true'."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_default() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${inputVal}" = "" ] && [ "${ruleVal}" != "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${ruleVal}"
return 0
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_required=()
METAFLAG_required["long"]="required"
METAFLAG_required["short"]=""
METAFLAG_required["type"]="bool"
METAFLAG_required["accept_values"]=""
METAFLAG_required["description"]="Boolean flag asserting if the parameter must be explicitly present during runtime execution."
METAFLAG_required["tipinput"]=""
METAFLAG_required["default"]="0"
METAFLAG_required["required"]=false
METAFLAG_required["normalize"]=""
METAFLAG_required["min"]=""
METAFLAG_required["max"]=""
METAFLAG_required["regex"]=""
METAFLAG_required["validate"]=""
METAFLAG_required["transform"]=""
METAFLAG_required["is_array"]=false
METAFLAG_required["min_array"]=""
METAFLAG_required["max_array"]=""
METAFLAG_required["is_assoc"]=false
METAFLAG_required["required_keys"]=""
shell_cli_metaflag_property_validate_required() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
return 0
}
shell_cli_metaflag_check_input_required() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${inputVal}" = "" ] && [ "${ruleVal}" = "1" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="cannot be empty or omitted"
return 1
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_normalize=()
METAFLAG_normalize["long"]="normalize"
METAFLAG_normalize["short"]=""
METAFLAG_normalize["type"]="function"
METAFLAG_normalize["accept_values"]=""
METAFLAG_normalize["description"]="Specifies a function responsible for normalizing the value before validation."
METAFLAG_normalize["tipinput"]=""
METAFLAG_normalize["default"]=""
METAFLAG_normalize["required"]=false
METAFLAG_normalize["normalize"]=""
METAFLAG_normalize["min"]=""
METAFLAG_normalize["max"]=""
METAFLAG_normalize["regex"]=""
METAFLAG_normalize["validate"]=""
METAFLAG_normalize["transform"]=""
METAFLAG_normalize["is_array"]=false
METAFLAG_normalize["min_array"]=""
METAFLAG_normalize["max_array"]=""
METAFLAG_normalize["is_assoc"]=false
METAFLAG_normalize["required_keys"]=""
shell_cli_metaflag_property_validate_normalize() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
if ! declare -f "${fval}" >/dev/null; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="normalize function does not exist ( fn='${fval}' )."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_normalize() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local newVal=$("${ruleVal}" "${inputVal}")
local exitCode=$?
if [ ${exitCode} = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${newVal}"
return 0
else
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="normalize function failed; ( fn='${ruleVal}'; value='${inputVal}' )"
return 1
fi
}


declare -gA METAFLAG_min=()
METAFLAG_min["long"]="min"
METAFLAG_min["short"]=""
METAFLAG_min["type"]="string"
METAFLAG_min["accept_values"]=""
METAFLAG_min["description"]="Minimum boundary size asserting string token length or lower numerical value restrictions."
METAFLAG_min["tipinput"]=""
METAFLAG_min["default"]=""
METAFLAG_min["required"]=false
METAFLAG_min["normalize"]=""
METAFLAG_min["min"]=""
METAFLAG_min["max"]=""
METAFLAG_min["regex"]=""
METAFLAG_min["validate"]=""
METAFLAG_min["transform"]=""
METAFLAG_min["is_array"]=false
METAFLAG_min["min_array"]=""
METAFLAG_min["max_array"]=""
METAFLAG_min["is_assoc"]=false
METAFLAG_min["required_keys"]=""
shell_cli_metaflag_property_validate_min() {
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if ! shell_cli_metaflag_property_cross_validate_min_max "${1}" "${2}"; then
return 1
fi
return 0
}
shell_cli_metaflag_check_input_min() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
case "${typeVal}" in
int)
if [ "${inputVal}" -lt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
return 1
fi
;;
float)
if ! shell_cli_utils_math_is_greater_or_equal "${inputVal}" "${ruleVal}" "0"; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
return 1
fi
;;
date|time|datetime)
local valTS=$(date -d "${inputVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${inputVal}" +%s 2>/dev/null)
local minTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)
if [ "${valTS}" -lt "${minTS}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates minimum allowed '${typeVal}'; ( min: '${ruleVal}' )"
return 1
fi
;;
*)
if [ "${#inputVal}" -lt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="character length is lower than required; ( min: '${ruleVal}' )"
return 1
fi
;;
esac
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_max=()
METAFLAG_max["long"]="max"
METAFLAG_max["short"]=""
METAFLAG_max["type"]="string"
METAFLAG_max["accept_values"]=""
METAFLAG_max["description"]="Maximum boundary size asserting string token length or upper numerical value restrictions."
METAFLAG_max["tipinput"]=""
METAFLAG_max["default"]=""
METAFLAG_max["required"]=false
METAFLAG_max["normalize"]=""
METAFLAG_max["min"]=""
METAFLAG_max["max"]=""
METAFLAG_max["regex"]=""
METAFLAG_max["validate"]=""
METAFLAG_max["transform"]=""
METAFLAG_max["is_array"]=false
METAFLAG_max["min_array"]=""
METAFLAG_max["max_array"]=""
METAFLAG_max["is_assoc"]=false
METAFLAG_max["required_keys"]=""
shell_cli_metaflag_property_validate_max() {
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if ! shell_cli_metaflag_property_cross_validate_min_max "${1}" "${2}"; then
return 1
fi
return 0
}
shell_cli_metaflag_check_input_max() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
case "${typeVal}" in
int)
if [ "${inputVal}" -lt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
return 1
fi
;;
float)
if ! shell_cli_utils_math_is_less_or_equal "${inputVal}" "${ruleVal}" "0"; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="violate maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
return 1
fi
;;
date|time|datetime)
local valTS=$(date -d "${inputVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${inputVal}" +%s 2>/dev/null)
local maxTS=$(date -d "${ruleVal}" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "${ruleVal}" +%s 2>/dev/null)
if [ "$valTS" -gt "$maxTS" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="value violates maximum allowed '${typeVal}'; ( max: '${ruleVal}' )"
return 1
fi
;;
*)
if [ "${#inputVal}" -gt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="character length is lower than required; ( max: '${ruleVal}' )"
return 1
fi
;;
esac
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_regex=()
METAFLAG_regex["long"]="regex"
METAFLAG_regex["short"]=""
METAFLAG_regex["type"]="text"
METAFLAG_regex["accept_values"]=""
METAFLAG_regex["description"]="Optional structural regular expression layout pattern verified natively at runtime."
METAFLAG_regex["tipinput"]=""
METAFLAG_regex["default"]=""
METAFLAG_regex["required"]=false
METAFLAG_regex["normalize"]=""
METAFLAG_regex["min"]=""
METAFLAG_regex["max"]=""
METAFLAG_regex["regex"]=""
METAFLAG_regex["validate"]=""
METAFLAG_regex["transform"]=""
METAFLAG_regex["is_array"]=false
METAFLAG_regex["min_array"]=""
METAFLAG_regex["max_array"]=""
METAFLAG_regex["is_assoc"]=false
METAFLAG_regex["required_keys"]=""
shell_cli_metaflag_property_validate_regex() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" != "" ]; then
( [[ "" =~ ${fval} ]] ) 2>/dev/null
local exit_status=$?
if [ ${exit_status} -eq 2 ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="invalid regular expression ( regex='${fval}' )."
return 1
fi
fi
return 0
}
shell_cli_metaflag_check_input_regex() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
if [[ ! "${inputVal}" =~ ${ruleVal} ]]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="does not match with regular expression; ( regex: '${ruleVal}' )"
return 1
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_validate=()
METAFLAG_validate["long"]="validate"
METAFLAG_validate["short"]=""
METAFLAG_validate["type"]="function"
METAFLAG_validate["accept_values"]=""
METAFLAG_validate["description"]="Pointer to indexed array with all validate functions to call for this value."
METAFLAG_validate["tipinput"]=""
METAFLAG_validate["default"]=""
METAFLAG_validate["required"]=false
METAFLAG_validate["normalize"]=""
METAFLAG_validate["min"]=""
METAFLAG_validate["max"]=""
METAFLAG_validate["regex"]=""
METAFLAG_validate["validate"]=""
METAFLAG_validate["transform"]=""
METAFLAG_validate["is_array"]=true
METAFLAG_validate["min_array"]=""
METAFLAG_validate["max_array"]=""
METAFLAG_validate["is_assoc"]=false
METAFLAG_validate["required_keys"]=""
shell_cli_metaflag_property_validate_validate() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
if ! shell_cli_utils_array_is_indexed "${fval}"; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
return 1
fi
local -n ref_validate="${fval}"
local fn_validate=""
for fn_validate in "${ref_validate[@]}"; do
if ! declare -f "${fn_validate}" >/dev/null; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="validation function does not exist ( fn='${fn_validate}' )."
return 1
fi
done
return 0
}
shell_cli_metaflag_check_input_validate() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local -n ref_validate="${ruleVal}"
local fn_validate=""
for fn_validate in "${ref_validate[@]}"; do
if ! "${fn_validate}" "${inputVal}"; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="validation failed in function '${fn_validate}' ( value='${inputVal}' )."
if [ "${SHELL_CLI_FN_RETURN}" != "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_FN_RETURN}"
fi
return 1
fi
done
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_transform=()
METAFLAG_transform["long"]="transform"
METAFLAG_transform["short"]=""
METAFLAG_transform["type"]="function"
METAFLAG_transform["accept_values"]=""
METAFLAG_transform["description"]="Pointer to indexed array with all transformation functions to use in this value after validation."
METAFLAG_transform["tipinput"]=""
METAFLAG_transform["default"]=""
METAFLAG_transform["required"]=false
METAFLAG_transform["normalize"]=""
METAFLAG_transform["min"]=""
METAFLAG_transform["max"]=""
METAFLAG_transform["regex"]=""
METAFLAG_transform["validate"]=""
METAFLAG_transform["transform"]=""
METAFLAG_transform["is_array"]=true
METAFLAG_transform["min_array"]=""
METAFLAG_transform["max_array"]=""
METAFLAG_transform["is_assoc"]=false
METAFLAG_transform["required_keys"]=""
shell_cli_metaflag_property_validate_transform() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
return 0
fi
if ! shell_cli_utils_array_is_indexed "${fval}"; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
return 1
fi
local -n ref_transform="${fval}"
local fn_transform=""
for fn_transform in "${ref_transform[@]}"; do
if ! declare -f "$fn_transform" >/dev/null; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="transform function does not exist ( fn='${fn_transform}' )."
return 1
fi
done
return 0
}
shell_cli_metaflag_check_input_transform() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${ruleVal}" = "" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local currentVal="${inputVal}"
local -n ref_transform="${ruleVal}"
local fn_transform=""
for fn_transform in "${ref_transform[@]}"; do
"${fn_transform}" "${currentVal}"
local newVal="${SHELL_CLI_FN_RETURN}"
local exitCode=$?
if [ ${exitCode} -ne 0 ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="transformation failed in function '${fn_transform}' ( value='${currentVal}' )."
return 1
fi
currentVal="${newVal}"
done
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${currentVal}"
return 0
}


declare -gA METAFLAG_is_array=()
METAFLAG_is_array["long"]="is_array"
METAFLAG_is_array["short"]=""
METAFLAG_is_array["type"]="bool"
METAFLAG_is_array["accept_values"]=""
METAFLAG_is_array["description"]="Boolean flag asserting if the parameter operates as an iterable collection array."
METAFLAG_is_array["tipinput"]=""
METAFLAG_is_array["default"]="0"
METAFLAG_is_array["required"]=false
METAFLAG_is_array["normalize"]=""
METAFLAG_is_array["min"]=""
METAFLAG_is_array["max"]=""
METAFLAG_is_array["regex"]=""
METAFLAG_is_array["validate"]=""
METAFLAG_is_array["transform"]=""
METAFLAG_is_array["is_array"]=false
METAFLAG_is_array["min_array"]=""
METAFLAG_is_array["max_array"]=""
METAFLAG_is_array["is_assoc"]=false
METAFLAG_is_array["required_keys"]=""
shell_cli_metaflag_property_validate_is_array() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
local -n __assoc="${fassoc}"
local _assoc="${__assoc["is_assoc"]}"
if [ "${fval}" = "1" ] && [ "${_assoc}" = "1" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'is_array=true' and 'is_assoc=true' simultaneously."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_is_array() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=()
if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
if shell_cli_utils_array_is_indexed "${inputVal}"; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
shell_cli_parse_sarray_to_array "${inputVal}"
if [ "$?" != "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SARRAY_TO_ARRAY_ERR_MESSAGE}"
return 1
else
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="SHELL_CLI_PARSE_SARRAY_TO_ARRAY"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ARRAY=("${SHELL_CLI_PARSE_SARRAY_TO_ARRAY[@]}")
fi
return 0
}


declare -gA METAFLAG_min_array=()
METAFLAG_min_array["long"]="min_array"
METAFLAG_min_array["short"]=""
METAFLAG_min_array["type"]="int"
METAFLAG_min_array["accept_values"]=""
METAFLAG_min_array["description"]="Minimum allowable element count within a validated array collection."
METAFLAG_min_array["tipinput"]=""
METAFLAG_min_array["default"]=""
METAFLAG_min_array["required"]=false
METAFLAG_min_array["normalize"]=""
METAFLAG_min_array["min"]=""
METAFLAG_min_array["max"]=""
METAFLAG_min_array["regex"]=""
METAFLAG_min_array["validate"]=""
METAFLAG_min_array["transform"]=""
METAFLAG_min_array["is_array"]=false
METAFLAG_min_array["min_array"]=""
METAFLAG_min_array["max_array"]=""
METAFLAG_min_array["is_assoc"]=false
METAFLAG_min_array["required_keys"]=""
shell_cli_metaflag_property_validate_min_array() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
local -n __assoc="${fassoc}"
local _array="${__assoc["is_array"]}"
if [ "${_array}" = "0" ] &&  [ "${fval}" != "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'min_array' for a 'is_array=false' flag."
return 1
fi
if ! shell_cli_metaflag_property_cross_validate_min_array_max_array "${fval}" "${fassoc}"; then
return 1
fi
return 0
}
shell_cli_metaflag_check_input_min_array() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local -n inputArrayValues="${inputVal}"
if [ "${#inputArrayValues[@]}" -lt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="collection violates minimum item count; ( min_array: '${ruleVal}' )"
return 1
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_max_array=()
METAFLAG_max_array["long"]="max_array"
METAFLAG_max_array["short"]=""
METAFLAG_max_array["type"]="int"
METAFLAG_max_array["accept_values"]=""
METAFLAG_max_array["description"]="Maximum allowable element count within a validated array collection."
METAFLAG_max_array["tipinput"]=""
METAFLAG_max_array["default"]=""
METAFLAG_max_array["required"]=false
METAFLAG_max_array["normalize"]=""
METAFLAG_max_array["min"]=""
METAFLAG_max_array["max"]=""
METAFLAG_max_array["validate"]=""
METAFLAG_max_array["transform"]=""
METAFLAG_max_array["regex"]=""
METAFLAG_max_array["is_array"]=false
METAFLAG_max_array["min_array"]=""
METAFLAG_max_array["max_array"]=""
METAFLAG_max_array["is_assoc"]=false
METAFLAG_max_array["required_keys"]=""
shell_cli_metaflag_property_validate_max_array() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
local -n __assoc="${fassoc}"
local _array="${__assoc["is_array"]}"
if [ "${_array}" = "0" ] &&  [ "${fval}" != "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'max_array' for a 'is_array=false' flag."
return 1
fi
if ! shell_cli_metaflag_property_cross_validate_min_array_max_array "${fval}" "${fassoc}"; then
return 1
fi
return 0
}
shell_cli_metaflag_check_input_max_array() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local -n inputArrayValues="${inputVal}"
if [ "${#inputArrayValues[@]}" -gt "${ruleVal}" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="collection violates maximum item count; ( max_array: '${ruleVal}' )"
return 1
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_is_assoc=()
METAFLAG_is_assoc["long"]="is_assoc"
METAFLAG_is_assoc["short"]=""
METAFLAG_is_assoc["type"]="bool"
METAFLAG_is_assoc["accept_values"]=""
METAFLAG_is_assoc["description"]="Boolean flag asserting if the parameter operates as an associative map."
METAFLAG_is_assoc["tipinput"]=""
METAFLAG_is_assoc["default"]="0"
METAFLAG_is_assoc["required"]=false
METAFLAG_is_assoc["normalize"]=""
METAFLAG_is_assoc["min"]=""
METAFLAG_is_assoc["max"]=""
METAFLAG_is_assoc["regex"]=""
METAFLAG_is_assoc["validate"]=""
METAFLAG_is_assoc["transform"]=""
METAFLAG_is_assoc["is_array"]=false
METAFLAG_is_assoc["min_array"]=""
METAFLAG_is_assoc["max_array"]=""
METAFLAG_is_assoc["is_assoc"]=false
METAFLAG_is_assoc["required_keys"]=""
shell_cli_metaflag_property_validate_is_assoc() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
if [ "${fval}" = "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot be empty"
return 1
fi
local -n __assoc="${fassoc}"
local _array="${__assoc["is_array"]}"
if [ "${fval}" = "1" ] && [ "${_array}" = "1" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot declare 'is_assoc=true' and 'is_array=true' simultaneously."
return 1
fi
return 0
}
shell_cli_metaflag_check_input_is_assoc() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC=()
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=()
if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
if shell_cli_utils_array_is_assoc "${inputVal}"; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
shell_cli_parse_sjson_to_assoc "${inputVal}"
if [ "$?" != "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ERR_MESSAGE}"
return 1
else
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="SHELL_CLI_PARSE_SJSON_TO_ASSOC"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER=("${SHELL_CLI_PARSE_SJSON_TO_ASSOC_ORDER[@]}")
local k=""
local v=""
for k in "${!SHELL_CLI_PARSE_SJSON_TO_ASSOC[@]}"; do
v="${SHELL_CLI_PARSE_SJSON_TO_ASSOC[${k}]}"
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC["${k}"]="${v}"
done
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA METAFLAG_required_keys=()
METAFLAG_required_keys["long"]="required_keys"
METAFLAG_required_keys["short"]=""
METAFLAG_required_keys["type"]="text"
METAFLAG_required_keys["accept_values"]=""
METAFLAG_required_keys["description"]="Pointer to array or a JSON-array string with the required 'keys'."
METAFLAG_required_keys["tipinput"]=""
METAFLAG_required_keys["default"]=""
METAFLAG_required_keys["required"]=false
METAFLAG_required_keys["normalize"]=""
METAFLAG_required_keys["min"]=""
METAFLAG_required_keys["max"]=""
METAFLAG_required_keys["regex"]=""
METAFLAG_required_keys["validate"]=""
METAFLAG_required_keys["transform"]=""
METAFLAG_required_keys["is_array"]=true
METAFLAG_required_keys["min_array"]=""
METAFLAG_required_keys["max_array"]=""
METAFLAG_required_keys["is_assoc"]=false
METAFLAG_required_keys["required_keys"]=""
shell_cli_metaflag_property_validate_required_keys() {
local fval="${1}"
local fassoc="${2}"
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE=""
local -n __assoc="${fassoc}"
local _assoc="${__assoc["is_assoc"]}"
if [ "${_assoc}" = "0" ]; then
if [ "${fval}" != "" ]; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="cannot define 'required_keys' for a 'is_assoc=false' flag."
return 1
fi
else
if [ "${fval}" != "" ]; then
if ! shell_cli_utils_array_is_indexed "${fval}"; then
SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE="pointer '${fval}' must be an indexed array (declare -a)."
return 1
fi
fi
fi
return 0
}
shell_cli_metaflag_check_input_required_keys() {
local inputVal="${1}"
local typeVal="${2}"
local ruleVal="${3}"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE=""
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE=""
if [ "${inputVal}" = "" ] || [ "${ruleVal}" = "0" ]; then
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
fi
local -n inputAssocValues="${inputVal}"
local -n requiredKeys="${ruleVal}"
local -a lostAssocKeys=()
local k=""
for k in "${requiredKeys[@]}"; do
if [[ -v "${inputAssocValues[${k}]}" ]]; then
continue
fi
lostAssocKeys+=("${k}")
done
if [ "${#lostAssocKeys[@]}" != "0" ]; then
local lostKeys=""
printf -v lostKeys "%s, " "${lostAssocKeys[@]}"
lostKeys="${lostKeys%, }"
SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE="missing keys '${lostKeys}'"
return 1
fi
SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE="${inputVal}"
return 0
}


declare -gA SHELL_CLI_FLAG_COMPILED_FAMILY=()
declare -g SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""


shell_cli_compile_flag() {
local flagVarName="${1}"
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""
local errPrefix="[ERR][ ${flagVarName} ]"
local errExtraData=""
local flagPropName=""
local flagPropValue=""
local flagPropDefault=""
local flagPropType=""
local metaFlagArrayType=""
local compiledObjectName=""
local normalizatedObjectName=""
local -a validatePropKeys=()
local -a validatePropValues=()
if ! shell_cli_utils_array_is_assoc "${flagVarName}"; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: invalid definition; must be an associative array (declare -A)."
return 1
fi
local -n flagAssocDefinition="${flagVarName}"
if [ "${flagAssocDefinition["__checked"]}" = "1" ]; then
return 0
fi
for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
flagPropValue="${flagAssocDefinition["${flagPropName}"]}"
flagPropDefault="${SHELL_CLI_METAFLAG_DEFAULT["${flagPropName}"]}"
if [ "${flagPropValue}" = "" ] && [ "${flagPropDefault}" != "" ]; then
flagAssocDefinition["${flagPropName}"]="$flagPropDefault"
fi
done
for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
flagPropValue="${flagAssocDefinition["${flagPropName}"]}"
if [ "${flagPropValue}" != "" ]; then
local -n metaFlag="METAFLAG_${flagPropName}"
metaFlagArrayType=""
compiledObjectName=""
normalizatedObjectName=""
validatePropKeys=()
validatePropValues=()
if [ "${metaFlag["is_array"]}" = "1" ] || [ "${metaFlag["is_array"]}" = "true" ]; then
metaFlagArrayType+="array"
compiledObjectName="${flagVarName}_${flagPropName}_array"
fi
if [ "${metaFlag["is_assoc"]}" = "1" ] || [ "${metaFlag["is_assoc"]}" = "true" ]; then
metaFlagArrayType+="assoc"
compiledObjectName="${flagVarName}_${flagPropName}_assoc"
fi
case "${metaFlagArrayType}" in
array)
shell_cli_type_normalize_main_array_types "${flagPropValue}"
normalizatedObjectName="${SHELL_CLI_FN_RETURN}"
shell_cli_utils_array_indexed_clone "${normalizatedObjectName}" "${compiledObjectName}"
if [ "$?" != "0" ]; then
errPrefix+="[ prop: ${flagPropName} ]"
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the indexed array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
return 1
fi
local i=""
local -n arr="${compiledObjectName}"
for i in "${!arr[@]}"; do
validatePropKeys+=("")
validatePropValues+=("${arr["${i}"]}")
done
flagPropValue="${compiledObjectName}"
;;
assoc)
shell_cli_type_normalize_main_assoc_types "${flagPropValue}"
normalizatedObjectName="${SHELL_CLI_FN_RETURN}"
shell_cli_utils_array_assoc_clone "${normalizatedObjectName}" "${compiledObjectName}"
if [ "$?" != "0" ]; then
errPrefix+="[ prop: ${flagPropName} ]"
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: cannot clone the assoc array '${normalizatedObjectName}' to new '${compiledObjectName}' object."
return 1
fi
local k=""
local -n assoc="${compiledObjectName}"
for k in "${!assoc[@]}"; do
validatePropKeys+=("${k}")
validatePropValues+=("${assoc["${k}"]}")
done
flagPropValue="${compiledObjectName}"
;;
*)
validatePropKeys+=("")
validatePropValues+=("${flagPropValue}")
;;
esac
local i=""
local key=""
local val=""
flagPropType="${metaFlag["type"]}"
for i in "${!validatePropValues[@]}"; do
key="${validatePropKeys["${i}"]}"
val="${validatePropValues["${i}"]}"
shell_cli_compile_flag_single_value_validation "${flagPropType}" "${val}"
local validateStatus="$?"
if [ "${validateStatus}" -ne 0 ]; then
errPrefix+="[ prop: ${flagPropName} ]"
errExtraData="value: '${val}'"
if [ "${key}" != "" ]; then
errExtraData="key:'${key}'; value: '${val}'"
fi
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: not a valid '${flagPropType}' type; ( ${errExtraData} )"
if [ "${validateStatus}" -eq 10 ]; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE+="; ( remove control characters )"
fi
return "${validateStatus}"
fi
validatePropValues["${i}"]="${SHELL_CLI_FN_RETURN}"
done
case "${metaFlagArrayType}" in
array)
local i=""
local -n arrayValues="${flagPropValue}"
for i in "${!validatePropValues[@]}"; do
arrayValues["${i}"]="${validatePropValues["${i}"]}"
done
;;
assoc)
local i=""
local -n assocValues="${flagPropValue}"
for i in "${!validatePropValues[@]}"; do
key="${validatePropKeys["${i}"]}"
val="${validatePropValues["${i}"]}"
assocValues["${key}"]="${val}"
done
;;
*)
flagPropValue="${validatePropValues[0]}"
;;
esac
flagAssocDefinition["${flagPropName}"]="${flagPropValue}"
unset -n metaFlag
fi
done
local metaflagPropertyValidateFN=""
local metaFlagPropertyValidateStatus=0
for flagPropName in "${SHELL_CLI_METAFLAG_DEFAULT_ORDER[@]}"; do
flagPropValue="${flagAssocDefinition["${flagPropName}"]}"
metaflagPropertyValidateFN="shell_cli_metaflag_property_validate_${flagPropName}"
metaFlagPropertyValidateStatus=0
"${metaflagPropertyValidateFN}" "${flagPropValue}" "${flagVarName}"
metaFlagPropertyValidateStatus="$?"
if [ "${metaFlagPropertyValidateStatus}" != "0" ]; then
errPrefix+="[ prop: ${flagPropName} ]"
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_METAFLAG_PROPERTY_VALIDATE_ERR_MESSAGE}"
return "${metaFlagPropertyValidateStatus}"
fi
done
flagAssocDefinition["__checked"]="1"
return 0
}
shell_cli_compile_flag_single_value_validation() {
local flagPropType="${1}"
local flagPropValue="${2}"
local flagTypeNormalizeFN="shell_cli_type_normalize_${flagPropType}"
local flagTypeValidateFN="shell_cli_type_validate_${flagPropType}"
"${flagTypeNormalizeFN}" "${flagPropValue}"
flagPropValue="${SHELL_CLI_FN_RETURN}"
"${flagTypeValidateFN}" "${flagPropValue}"
SHELL_CLI_FN_RETURN="${flagPropValue}"
return $?
}


shell_cli_compile_flag_family() {
local flagFamily="${1}"
local flagOrderArray="${2}"
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""
local flagName=""
local checkStatus=0
local -a flagAssocNames=()
if [ "${SHELL_CLI_FLAG_COMPILED_FAMILY["$flagFamily"]}" = "1" ]; then
return 0
fi
if [ "${flagFamily}" = "" ]; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Flag family name is required."
return 1
fi
if [ "${flagOrderArray}" = "" ]; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Default order array is required."
return 1
fi
if ! shell_cli_utils_array_is_indexed "${flagOrderArray}"; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid default order array '${flagOrderArray}'. Expected indexed array (declare -a)."
return 1
fi
local -n arrayOrder="${flagOrderArray}"
if [ "${#arrayOrder[@]}" = "0" ]; then
SHELL_CLI_FLAG_COMPILED_FAMILY["${flagFamily}"]="1"
return 0
fi
for flagName in "${arrayOrder[@]}"; do
flagName="${flagFamily}_${flagName}"
if ! shell_cli_utils_array_is_assoc "${flagName}"; then
SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE="[ERR] :: Invalid or undefined assoc flag '${flagName}'. Expected associative array (declare -A)."
return 1
fi
flagAssocNames+=("${flagName}")
done
for flagName in "${flagAssocNames[@]}"; do
shell_cli_compile_flag "${flagName}"
checkStatus=$?
if [ "${checkStatus}" != "0" ]; then
return "${checkStatus}"
fi
done
SHELL_CLI_FLAG_COMPILED_FAMILY["${flagFamily}"]="1"
return 0
}


declare -g SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE=""
declare -g SHELL_CLI_PROCESS_FLAG_TYPE=""
declare -g SHELL_CLI_PROCESS_FLAG_VALUE=""
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX=""
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""
declare -ga SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()


shell_cli_process_flag_single_value() {
local rawSingleValue="${1}"
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE=""
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""
if [ "${rawSingleValue}" = "" ]; then
return 0
fi
local normalizeByTypeFN=""
local validateStatus="0"
local validateByTypeFN=""
normalizeByTypeFN="shell_cli_type_normalize_${SHELL_CLI_PROCESS_FLAG_TYPE}"
"${normalizeByTypeFN}" "${rawSingleValue}"
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_FN_RETURN}"
validateByTypeFN="shell_cli_type_validate_${SHELL_CLI_PROCESS_FLAG_TYPE}"
"${validateByTypeFN}" "$SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE"
validateStatus=$?
if [ "${validateStatus}" != 0 ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="not a valid '${SHELL_CLI_PROCESS_FLAG_TYPE}' type; ( value: '${rawSingleValue}' )"
if [ "${validateStatus}" = "10" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE+=" (remove control characters)"
fi
return "${validateStatus}"
fi
shell_cli_process_flag_single_value_against_prop_accept_values "${flagAssocDefinition["accept_values"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_normalize "${flagAssocDefinition["normalize"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_min "${flagAssocDefinition["min"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_max "${flagAssocDefinition["max"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_regex "${flagAssocDefinition["regex"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_validate "${flagAssocDefinition["validate"]}"
if [ "$?" != "0" ]; then
return 1
fi
shell_cli_process_flag_single_value_against_prop_transform "${flagAssocDefinition["transform"]}"
if [ "$?" != "0" ]; then
return 1
fi
return 0
}


shell_cli_process_flag_value() {
local flagVarName="${1}"
local rawInputValue="${2}"
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""
shell_cli_compile_flag "${flagVarName}"
local compileFlagStatus="$?"
if [ "${compileFlagStatus}" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE}"
return "${compileFlagStatus}"
fi
local -a flagKeys=()
local -a flagValues=()
local typeOfValue="single"
local arrayKeyType=""
local errPrefix=""
local i=""
local k=""
local v=""
declare -gn flagAssocDefinition="${flagVarName}"
SHELL_CLI_PROCESS_FLAG_TYPE="${flagAssocDefinition["type"]}"
SHELL_CLI_PROCESS_FLAG_VALUE="${rawInputValue}"
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX="[ x ][ --${flagAssocDefinition["long"]} ]"
SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()
shell_cli_process_flag_value_against_prop_required "${flagAssocDefinition["required"]}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
shell_cli_process_flag_value_against_prop_default "${flagAssocDefinition["default"]}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
if [ "${flagAssocDefinition["is_array"]}" = "1" ]; then
typeOfValue="array"
arrayKeyType="idx"
if [ "${rawInputValue}" = "" ]; then
return 0
fi
shell_cli_process_flag_value_against_prop_is_array "${flagAssocDefinition["min_array"]}" "${flagAssocDefinition["max_array"]}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
local -n tmpArray="${SHELL_CLI_PROCESS_FLAG_VALUE}"
for i in "${!tmpArray[@]}"; do
v="${tmpArray[${i}]}"
flagKeys+=("${i}")
flagValues+=("${v}")
done
unset -n tmpArray
fi
if [ "${flagAssocDefinition["is_assoc"]}" = "1" ]; then
typeOfValue="assoc"
arrayKeyType="key"
if [ "${rawInputValue}" = "" ]; then
return 0
fi
shell_cli_process_flag_value_against_prop_is_assoc "${flagAssocDefinition["required_keys"]}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
local -n tmpAssoc="${SHELL_CLI_PROCESS_FLAG_VALUE}"
for k in "${!SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER[@]}"; do
v="${tmpAssoc[${k}]}"
flagKeys+=("${k}")
flagValues+=("${v}")
done
unset -n tmpAssoc
fi
if [ "${typeOfValue}" = "single" ]; then
flagKeys+=("-")
flagValues+=("${SHELL_CLI_PROCESS_FLAG_VALUE}")
fi
for i in "${!flagKeys[@]}"; do
k="${flagKeys[${i}]}"
v="${flagValues[${i}]}"
shell_cli_process_flag_single_value "${v}"
if [ "$?" != 0 ]; then
errPrefix="${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX}"
if [ "${typeOfValue}" != "single" ]; then
errPrefix+="[ ${arrayKeyType}: ${k} ]"
fi
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${errPrefix} :: ${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
flagValues["${i}"]="${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}"
done
case "${typeOfValue}" in
single)
SHELL_CLI_PROCESS_FLAG_VALUE="${flagValues[0]}"
;;
array)
local flagValueArrayName="${flagVarName,,}_array"
eval "declare -ga ${flagValueArrayName}=()"
local -n tmpArrayRef="${flagValueArrayName}"
for i in "${!flagValues[@]}"; do
tmpArrayRef["${i}"]="${flagValues["${i}"]}"
done
unset -n tmpArrayRef
SHELL_CLI_PROCESS_FLAG_VALUE="${flagValueArrayName}"
;;
assoc)
local flagValueAssocName="${flagVarName,,}_assoc"
eval "declare -gA ${flagValueAssocName}=()"
local -n tmpAssocRef="${flagValueAssocName}"
for i in "${!flagValues[@]}"; do
k="${flagKeys["${i}"]}"
v="${flagValues["${i}"]}"
tmpAssocRef["${k}"]="${v}"
done
unset -n tmpAssocRef
SHELL_CLI_PROCESS_FLAG_VALUE="${flagValueAssocName}"
;;
esac
return 0
}


shell_cli_process_flag_single_value_against_prop_accept_values() {
shell_cli_metaflag_check_input_accept_values "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_normalize() {
shell_cli_metaflag_check_input_normalize "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_min() {
shell_cli_metaflag_check_input_min "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_max() {
shell_cli_metaflag_check_input_max "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_regex() {
shell_cli_metaflag_check_input_regex "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_validate() {
shell_cli_metaflag_check_input_validate "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_single_value_against_prop_transform() {
shell_cli_metaflag_check_input_transform "${SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_value_against_prop_required() {
shell_cli_metaflag_check_input_required "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_value_against_prop_default() {
shell_cli_metaflag_check_input_default "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
}


shell_cli_process_flag_value_against_prop_is_array() {
shell_cli_metaflag_check_input_is_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
shell_cli_metaflag_check_input_min_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
shell_cli_metaflag_check_input_max_array "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${2}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
return 0
}


shell_cli_process_flag_value_against_prop_is_assoc() {
shell_cli_metaflag_check_input_is_assoc "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "1"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_PROCESS_FLAG_VALUE="${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_VALUE}"
SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=(${SHELL_CLI_METAFLAG_CHECK_INPUT_NEW_ASSOC_ORDER[@]})
shell_cli_metaflag_check_input_required_keys "${SHELL_CLI_PROCESS_FLAG_VALUE}" "${SHELL_CLI_PROCESS_FLAG_TYPE}" "${1}"
if [ "$?" != "0" ]; then
SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE="${SHELL_CLI_METAFLAG_CHECK_INPUT_ERR_MESSAGE}"
return 1
fi
return 0
}


if [ "${SHELL_CLI_CORE_LOAD}" = "" ]; then
declare -g SHELL_CLI_CORE_LOAD="-1"
fi
if [ "${SHELL_CLI_PROCESS_LOCK_PID}" = "" ]; then
declare -g SHELL_CLI_PROCESS_LOCK_PID="-"
declare -g SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
fi
declare -g SHELL_CLI_MAIN_CMD_ROOT_PATH=""
declare -g SHELL_CLI_MAIN_CMD_NAME=""
declare -g SHELL_CLI_MAIN_CMD_REGISTRY=""
declare -g SHELL_CLI_MAIN_CMD_REGISTRY_ORDER=""
declare -g SHELL_CLI_RESOURCE_PATH=""
declare -g SHELL_CLI_RESOURCE_NAME=""
declare -g SHELL_CLI_RESOURCE_TREE=""
declare -g SHELL_CLI_RESOURCE_REGISTRY=""
declare -g SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER=""
declare -g SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER=""
if ! declare -p "SHELL_CLI_COMMAND_RESOURCE_ORDER" &>/dev/null; then
declare -ga SHELL_CLI_COMMAND_RESOURCE_ORDER=()
fi
declare -g SHELL_CLI_RESOURCE_FLAG_FAMILY=""
declare -g SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER=""
declare -gA SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME=()
declare -gA SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME=()
declare -g SHELL_CLI_RESOURCE_FUNCTION_ACTION=""
declare -g SHELL_CLI_RESOURCE_FUNCTION_VALIDATE=""
declare -g SHELL_CLI_TRIGGER_HELP="0"
declare -g SHELL_CLI_TRIGGER_INTERACTIVE="0"
declare -ga SHELL_CLI_INPUT_RAW_FLAG=()
declare -gA SHELL_CLI_INPUT_RAW_FLAG_ASSOC=()
declare -ga SHELL_CLI_INPUT_RAW_FLAG_ORDER=()
declare -gA SHELL_CLI_CMD_INPUT=()
declare -ga SHELL_CLI_CMD_INPUT_ORDER=()
shell_cli_preflight_reset() {
SHELL_CLI_MAIN_CMD_ROOT_PATH=""
SHELL_CLI_MAIN_CMD_NAME=""
SHELL_CLI_MAIN_CMD_REGISTRY=""
SHELL_CLI_MAIN_CMD_REGISTRY_ORDER=""
SHELL_CLI_RESOURCE_PATH=""
SHELL_CLI_RESOURCE_NAME=""
SHELL_CLI_RESOURCE_TREE=""
SHELL_CLI_RESOURCE_REGISTRY=""
SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER=""
SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER=""
SHELL_CLI_RESOURCE_FUNCTION_ACTION=""
SHELL_CLI_RESOURCE_FUNCTION_VALIDATE=""
SHELL_CLI_RESOURCE_FLAG_FAMILY=""
SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER=""
SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME=()
SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME=()
SHELL_CLI_TRIGGER_HELP="0"
SHELL_CLI_TRIGGER_INTERACTIVE="0"
SHELL_CLI_INPUT_RAW_FLAG=()
SHELL_CLI_INPUT_RAW_FLAG_ASSOC=()
SHELL_CLI_INPUT_RAW_FLAG_ORDER=()
SHELL_CLI_CMD_INPUT=()
SHELL_CLI_CMD_INPUT_ORDER=()
}
shell_cli_context_dump() {
echo "MAIN CMD"
echo "  ROOT PATH : $SHELL_CLI_MAIN_CMD_ROOT_PATH"
echo "       NAME : $SHELL_CLI_MAIN_CMD_NAME"
echo "  ASSOC REG : $SHELL_CLI_MAIN_CMD_REGISTRY"
echo "  ARRAY ORD : $SHELL_CLI_MAIN_CMD_REGISTRY_ORDER"
echo ""
echo "SELECTED RESOURCE"
echo "       PATH : $SHELL_CLI_RESOURCE_PATH"
echo "       NAME : $SHELL_CLI_RESOURCE_NAME"
echo "       TREE : $SHELL_CLI_RESOURCE_TREE"
echo "  ASSOC REG : $SHELL_CLI_RESOURCE_REGISTRY"
echo " ACTION ORD : $SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER"
echo "   FLAG ORD : $SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER"
echo "  FN ACTION : $SHELL_CLI_RESOURCE_FUNCTION_ACTION"
echo "  FN VALIDA : $SHELL_CLI_RESOURCE_FUNCTION_VALIDATE"
echo ""
echo "RESOURCE FLAG"
echo "     FAMILY : $SHELL_CLI_RESOURCE_FLAG_FAMILY"
echo " FAMILY ORD : $SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER"
echo ""
echo "RESOURCE FLAG MAP"
local i=""
local k=""
local v=""
echo "  SHORT NAME : "
for k in "${!SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME[@]}"; do
v="${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${k}"]}"
echo "    [ ${k} ] = '${v}'"
done
echo ""
echo "  LONG NAME : "
for k in "${!SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME[@]}"; do
v="${SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${k}"]}"
echo "    [ ${k} ] = '${v}'"
done
echo ""
echo "TRIGGERS"
echo "       HELP : $SHELL_CLI_TRIGGER_HELP"
echo "INTERACTIVE : $SHELL_CLI_TRIGGER_INTERACTIVE"
echo ""
echo " RAW FLAGS : "
echo "  SHELL_CLI_INPUT_RAW_FLAG"
for i in "${!SHELL_CLI_INPUT_RAW_FLAG[@]}"; do
v="${SHELL_CLI_INPUT_RAW_FLAG["${i}"]}"
echo "    [ ${i} ] = '${v}'"
done
echo ""
echo "FLAG ASSOC [in order] : "
echo "  SHELL_CLI_INPUT_RAW_FLAG_ORDER"
echo "  SHELL_CLI_INPUT_RAW_FLAG_ASSOC || SHELL_CLI_CMD_INPUT"
for k in "${SHELL_CLI_INPUT_RAW_FLAG_ORDER[@]}"; do
v="${SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${k}"]}"
t="${SHELL_CLI_CMD_INPUT["${k}"]}"
echo "    [ ${k} ] = '${v}' || ${t}"
done
}


shell_cli_preflight_check_command_registry() {
local assocCmdName="${1}"
if ! shell_cli_utils_array_is_assoc "${assocCmdName}"; then
return 1
fi
local -n assocCmdRegistry="${assocCmdName}"
if [ "${assocCmdRegistry["__checked"]}" = "1" ]; then
return 0
fi
local requiredKeys=("cmd" "summary")
local k=""
for k in "${requiredKeys[@]}"; do
if [ "${assocCmdRegistry["${k}"]}" = "" ]; then
return 2
fi
done
assocCmdRegistry["__checked"]="1"
return 0
}


shell_cli_preflight_process_lock() {
if [ "${SHELL_CLI_PROCESS_LOCK_ACTIVE}" = "1" ] && [ "${SHELL_CLI_PROCESS_LOCK_PID}" = "${BASHPID}" ]; then
echo "[ERR] Critical Architecture Panic :: Inline nested command invocation detected!"
echo "[ERR] Context: Concurrent execution sharing the same active memory stack frame is strictly prohibited."
echo "[ERR] Resolution: Wrap your programmatic downstream calls using standard isolated sub-shell tokens: ( shell_cli ... )"
return 1
fi
SHELL_CLI_PROCESS_LOCK_PID="${BASHPID}"
SHELL_CLI_PROCESS_LOCK_ACTIVE="1"
}


shell_cli_preflight_process_unlock() {
SHELL_CLI_PROCESS_LOCK_PID="-"
SHELL_CLI_PROCESS_LOCK_ACTIVE="0"
}


shell_cli_preflight_prepare_main_cmd() {
if [ "${SHELL_CLI_CORE_LOAD}" != "1" ]; then
echo "[ERR] :: Shell CLI not found or not load."
return 1
fi
shell_cli_preflight_reset
local errTitle="[ERR] :: Invalid command definition."
local errIndent="         "
local mainCmdRootPath="${1}"; shift
shell_cli_type_normalize_string "${1,,}"; shift
local mainCmdName="${SHELL_CLI_FN_RETURN//-/_}"
local mainCmdRegistry="SHELL_CLI_CMD_${mainCmdName^^}"
local mainCmdRegistryResourceOrder="${mainCmdRegistry}_RESOURCE_ORDER"
if [ "${mainCmdName}" = "" ]; then
echo "[ERR] :: Missing operational main command name context."
return 1
fi
if [ ! -d "${mainCmdRootPath}" ]; then
echo "${errTitle}"
echo "${errIndent}> '${mainCmdName}'"
echo "${errIndent}Command Root Path '${mainCmdRootPath}' does not exists."
return 1
fi
if [ ! -f "${mainCmdRootPath}/${mainCmdName}.sh" ]; then
echo "${errTitle}"
echo "${errIndent}Command entrypoint '${mainCmdName}' does not exists."
echo "${errIndent}Missing file '${mainCmdRootPath}/${mainCmdName}.sh'."
return 1
fi
if [ ! -f "${mainCmdRootPath}/cmd.sh" ]; then
echo "${errTitle}"
echo "${errIndent}Command registry 'cmd.sh' does not exists."
echo "${errIndent}Missing file '${mainCmdRootPath}/cmd.sh'."
return 1
fi
. "${mainCmdRootPath}/cmd.sh"
shell_cli_preflight_check_command_registry "${mainCmdRegistry}"
local s="$?"
if [ "${s}" = "1" ]; then
echo "${errTitle}"
echo "${errIndent}Not found '${mainCmdRegistry}' associative array (declare -A)."
return 1
elif [ "${s}" = "2" ]; then
echo "${errTitle}"
echo "${errIndent}Assoc '${mainCmdRegistry}' missing one or more mandatory keys."
echo "${errIndent}Expected 'cmd', 'summary', and 'description' to exist and be populated."
return 1
fi
if ! shell_cli_utils_array_is_indexed "${mainCmdRegistryResourceOrder}"; then
echo "${errTitle}"
echo "${errIndent}Resource register array '${mainCmdRegistryResourceOrder}' not found."
return 1
fi
if [ -d "${mainCmdRootPath}/globals" ]; then
local file=""
local tgtGlobalFiles=($(find "${mainCmdRootPath}/globals" -type f -name "*.sh" | sort))
for file in "${tgtGlobalFiles[@]}"; do
if [[ "${file}" == *_test.sh ]]; then
continue
fi
. "${file}"
done
fi
if ! shell_cli_compile_flag_family "METAFLAG" "SHELL_CLI_METAFLAG_DEFAULT_ORDER"; then
local errPrefix="\[ERR\] :: "
echo "${errTitle}"
echo "${errIndent}${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE/${errPrefix}/}"
return 1
fi
SHELL_CLI_MAIN_CMD_ROOT_PATH="${mainCmdRootPath}"
SHELL_CLI_MAIN_CMD_NAME="${mainCmdName}"
SHELL_CLI_MAIN_CMD_REGISTRY="${mainCmdRegistry}"
SHELL_CLI_MAIN_CMD_REGISTRY_ORDER="${mainCmdRegistryResourceOrder}"
return 0
}


shell_cli_preflight_prepare_target_resource() {
shell_cli_type_normalize_string "${1,,}"; shift
local resourceName="${SHELL_CLI_FN_RETURN}"
if [ "${resourceName}" == "" ]; then
SHELL_CLI_RESOURCE_TREE="."
return 0
fi
if [ "${resourceName}" == "help" ]; then
SHELL_CLI_RESOURCE_TREE="."
SHELL_CLI_TRIGGER_HELP="1"
SHELL_CLI_TRIGGER_INTERACTIVE="0"
return 0
fi
local errTitle="[ERR] :: Invalid resource definition."
local errIndent="         "
local triggerHelp="0"
local mainCmdName="${SHELL_CLI_MAIN_CMD_NAME}"
local resourcePath="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/src/${resourceName//-/_}"
local resourceCmdTree="${resourceName}"
local resourceRegistry="SHELL_CLI_CMD_${SHELL_CLI_MAIN_CMD_NAME^^}_${resourceName^^}"
resourceRegistry="${resourceRegistry//-/_}"
local resourceRegistryActionOrder=""
local resourceRegistryFlagOrder=""
local resourceFunctionAction=""
local resourceFunctionValidate=""
local resourceFlagFamily=""
local resourceFlagFamilyOrder=""
local arg=""
for arg in "$@"; do
shell_cli_type_normalize_string "${arg,,}"
arg="${SHELL_CLI_FN_RETURN}"
if [ "${arg}" != "" ]; then
if [ "${arg:0:1}" = "-" ]; then
break
fi
if [ "${arg}" = "help" ]; then
triggerHelp="1"
break
fi
resourcePath+="/src/${arg}"
resourceCmdTree+=" ${arg}"
resourceRegistry+="_${arg^^}"
fi
done
resourceRegistryActionOrder="${resourceRegistry}_ACTION_ORDER"
resourceRegistryFlagOrder="${resourceRegistry}_FLAG_ORDER"
resourceFunctionAction="${resourceRegistry,,}_action"
resourceFunctionValidate="${resourceRegistry,,}_validate"
resourceFlagFamily="${resourceRegistry}_FLAG"
resourceFlagFamilyOrder="${resourceRegistry}_FLAG_ORDER"
if [ ! -d "${resourcePath}" ]; then
echo "${errTitle}"
echo "${errIndent}Source code not found for > '${mainCmdName} ${resourceCmdTree}'."
echo "${errIndent}Missing directory '${resourcePath}'."
return 1
fi
if [ ! -f "${resourcePath}/cmd.sh" ]; then
echo "${errTitle}"
echo "${errIndent}Definition resource not found for > '${mainCmdName} ${resourceCmdTree}'."
echo "${errIndent}Missing file '${resourcePath}/cmd.sh'."
return 1
fi
. "${resourcePath}/cmd.sh"
shell_cli_preflight_check_command_registry "${resourceRegistry}"
local s="$?"
if [ "${s}" = "1" ]; then
echo "${errTitle}"
echo "${errIndent}Not found '${resourceRegistry}' associative array (declare -A)."
return 1
elif [ "${s}" = "2" ]; then
echo "${errTitle}"
echo "${errIndent}Assoc '${resourceRegistry}' missing one or more mandatory keys."
echo "${errIndent}Expected 'cmd', 'summary', and 'description' to exist and be populated."
return 1
fi
if ! shell_cli_utils_array_is_indexed "${resourceRegistryActionOrder}"; then
echo "${errTitle}"
echo "${errIndent}Not found '${resourceRegistryActionOrder}' indexed array (declare -a)."
return 1
fi
if [ ! -f "${resourcePath}/flags.sh" ]; then
echo "${errTitle}"
echo "${errIndent}Definition flags not found for > '${mainCmdName} ${resourceCmdTree}'."
echo "${errIndent}Missing file '${resourcePath}/flags.sh'."
return 1
fi
. "${resourcePath}/flags.sh"
if ! shell_cli_utils_array_is_indexed "${resourceRegistryFlagOrder}"; then
echo "${errTitle}"
echo "${errIndent}Not found '${resourceRegistryFlagOrder}' indexed array (declare -a)."
return 1
fi
local -n arrayResourceRegistryOrder="${resourceRegistryFlagOrder}"
if [ "${#arrayResourceRegistryOrder[@]}" -gt "0" ]; then
local flagName=""
local flagAssocName=""
local flagRefAssocName=""
for flagName in "${arrayResourceRegistryOrder[@]}"; do
flagAssocName="${resourceRegistry}_FLAG_${flagName,,}"
if ! shell_cli_utils_array_is_assoc "${flagAssocName}"; then
flagRefAssocName="${!flagAssocName}"
if shell_cli_utils_array_is_assoc "${flagRefAssocName}"; then
shell_cli_utils_array_assoc_clone "${flagRefAssocName}" "${flagAssocName}"
if [ $? -eq 0 ]; then
if shell_cli_utils_array_is_assoc "${flagAssocName}_OVERRIDE"; then
local -n assoc_flag="${flagAssocName}"
local -n assoc_override="${flagAssocName}_OVERRIDE"
local k=""
for k in "${!assoc_override[@]}"; do
assoc_flag["${k}"]="${assoc_override["${k}"]}"
done
fi
fi
fi
fi
if ! shell_cli_utils_array_is_assoc "${flagAssocName}"; then
echo "${errTitle}"
echo "${errIndent}The flag '${flagName}' does not have its corresponding definition..."
echo "${errIndent}expected an associative array (declare -A) with the name '${flagAssocName}'."
return 1
fi
done
fi
unset -n arrayResourceRegistryOrder
if [ ! -f "${resourcePath}/action.sh" ]; then
echo "${errTitle}"
echo "${errIndent}Entrypoint not found for > '${mainCmdName} ${resourceCmdTree}'."
echo "${errIndent}Missing file '${resourcePath}/action.sh'."
return 1
fi
. "${resourcePath}/action.sh"
if ! declare -f "${resourceFunctionAction}" >/dev/null; then
echo "${errTitle}"
echo "${errIndent}Main function '${resourceFunctionAction}' is missing."
return 1
fi
if ! declare -f "${resourceFunctionValidate}" >/dev/null; then
resourceFunctionValidate=""
fi
SHELL_CLI_RESOURCE_PATH="${resourcePath}"
SHELL_CLI_RESOURCE_NAME="${resourceName}"
SHELL_CLI_RESOURCE_TREE="${resourceCmdTree}"
SHELL_CLI_RESOURCE_REGISTRY="${resourceRegistry}"
SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER="${resourceRegistryActionOrder}"
SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER="${resourceRegistryFlagOrder}"
SHELL_CLI_RESOURCE_FUNCTION_ACTION="${resourceFunctionAction}"
SHELL_CLI_RESOURCE_FUNCTION_VALIDATE="${resourceFunctionValidate}"
SHELL_CLI_RESOURCE_FLAG_FAMILY="${resourceFlagFamily}"
SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER="${resourceFlagFamilyOrder}"
if [ "${triggerHelp}" == "1" ]; then
SHELL_CLI_TRIGGER_HELP="1"
SHELL_CLI_TRIGGER_INTERACTIVE="0"
fi
return 0
}


shell_cli_preflight_prepare_target_resource_flags() {
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
return 0
fi
if ! shell_cli_compile_flag_family "${SHELL_CLI_RESOURCE_FLAG_FAMILY}" "${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"; then
local errTitle="[ERR] :: Invalid resource flag definition."
local errIndent="         "
local errPrefix="\[ERR\] :: "
echo "${errTitle}"
echo "${errIndent}${SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE/${errPrefix}/}"
return 1
fi
local -n arrayResourceRegistryOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
if [ "${#arrayResourceRegistryOrder[@]}" -gt "0" ]; then
local flagName=""
local flagLong=""
local flagShort=""
local flagAssocName=""
for flagName in "${arrayResourceRegistryOrder[@]}"; do
flagAssocName="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName,,}"
local -n flagAssocDefinition="${flagAssocName}"
flagLong="${flagAssocDefinition["long"]}"
flagShort="${flagAssocDefinition["short"]}"
SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${flagLong}"]="${flagAssocName}"
if [ "${flagShort}" != "" ]; then
SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${flagShort}"]="${flagLong}"
fi
unset -n flagAssocDefinition
done
fi
unset -n arrayResourceRegistryOrder
return 0
}


shell_cli_preflight_prepare_input() {
if [ "${SHELL_CLI_TRIGGER_HELP}" = "1" ]; then
return 0
fi
local arg=""
local readingFlags="0"
local flagKey=""
for arg in "$@"; do
if [ "${readingFlags}" -eq "0" ] && [ "${arg}" = "help" ]; then
SHELL_CLI_TRIGGER_HELP="1"
SHELL_CLI_TRIGGER_INTERACTIVE="0"
return 0
fi
if [ "${arg:0:1}" = "-" ]; then
readingFlags="1"
SHELL_CLI_INPUT_RAW_FLAG+=("${arg}")
flagKey="${arg%%=*}"
if [[ "${flagKey}" =~ ^(--help|-h)$ ]]; then
SHELL_CLI_TRIGGER_HELP="1"
SHELL_CLI_TRIGGER_INTERACTIVE="0"
return 0
elif [[ "${flagKey}" =~ ^(--interactive|-itr)$ ]]; then
SHELL_CLI_TRIGGER_INTERACTIVE="1"
fi
else
if [ "${readingFlags}" -eq "1" ]; then
echo "[ x ] Syntax Error :: Command '${arg}' discovered after flags stream initialization."
return 1
fi
fi
done
if [ "${SHELL_CLI_TRIGGER_INTERACTIVE}" = "1" ]; then
return 0
fi
local currentFlagRaw=""
local currentFlagK=""
local currentFlagKey=""
local currentFlagValue=""
local currentFlagAssocName=""
for currentFlagRaw in "${SHELL_CLI_INPUT_RAW_FLAG[@]}"; do
if [[ "$currentFlagRaw" == *=* ]]; then
currentFlagK="${currentFlagRaw%%=*}"
currentFlagValue="${currentFlagRaw#*=}"
else
currentFlagK="${currentFlagRaw}"
currentFlagValue="1"
fi
currentFlagKey="${currentFlagK}"
currentFlagKey="${currentFlagKey#--}"
currentFlagKey="${currentFlagKey#-}"
if [ "${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${currentFlagKey}"]}" != "" ]; then
currentFlagKey=${SHELL_CLI_RESOURCE_FLAG_MAP_SHORTNAME["${currentFlagKey}"]}
fi
if [ "${SHELL_CLI_RESOURCE_FLAG_MAP_LONGNAME["${currentFlagKey}"]}" = "" ]; then
echo "[ x ] Parameter Error :: Unknown flag '${currentFlagK}'."
return 1
fi
if [[ -v SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${currentFlagKey}"] ]]; then
echo "[ x ] Duplicated Error :: Parameter '${currentFlagK}' was provided multiple times."
return 1
fi
SHELL_CLI_INPUT_RAW_FLAG_ORDER+=("${currentFlagKey}")
SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${currentFlagKey}"]="${currentFlagValue}"
done
if [ "${SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER}" != "" ]; then
local -n flagFamilyOrder="${SHELL_CLI_RESOURCE_FLAG_FAMILY_ORDER}"
for currentFlagKey in "${flagFamilyOrder[@]}"; do
shell_cli_process_flag_value \
"${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${currentFlagKey}" \
"${SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${currentFlagKey}"]}"
if [ "$?" != "0" ]; then
echo "${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE}"
return 1
fi
SHELL_CLI_CMD_INPUT["${currentFlagKey}"]="${SHELL_CLI_PROCESS_FLAG_VALUE}"
done
fi
SHELL_CLI_CMD_INPUT_ORDER=("${SHELL_CLI_INPUT_RAW_FLAG_ORDER[@]}")
return 0
}


declare -g SHELL_CLI_HANDLER_HELP_COLUMNS="100"
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR="="
declare -g SHELL_CLI_HANDLER_HELP_SEPARATOR=""
shell_cli_handler_help() {
local currentCols="${COLUMNS:-80}"
if [ "${currentCols}" -lt "${SHELL_CLI_HANDLER_HELP_COLUMNS}" ] && [ "${currentCols}" -gt 20 ]; then
SHELL_CLI_HANDLER_HELP_COLUMNS="${currentCols}"
fi
for ((i=0; i<SHELL_CLI_HANDLER_HELP_COLUMNS; i++)); do
SHELL_CLI_HANDLER_HELP_SEPARATOR+="${SHELL_CLI_HANDLER_HELP_SEPARATOR_CHAR}"
done
_shell_cli_handler_help_render_header
_shell_cli_handler_help_render_usage
_shell_cli_handler_help_render_global_flags
_shell_cli_handler_help_render_subcmd_options
_shell_cli_handler_help_render_flags
return 0
}
_shell_cli_handler_help_render_header() {
local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
local subCmdName="> ${SHELL_CLI_RESOURCE_TREE/ / > }"
local useCmdRegistry="${SHELL_CLI_RESOURCE_REGISTRY}"
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
useCmdRegistry="${SHELL_CLI_MAIN_CMD_REGISTRY}"
subCmdName=""
fi
local -n assocCmdRegistry="${useCmdRegistry}"
local cmdSummary="${assocCmdRegistry["summary"]}"
local cmdDescription="${assocCmdRegistry["description"]}"
echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
echo "# Shell CLI > Help > ${cmdName} ${subCmdName}"
echo ""
shell_cli_utils_string_wrap "${cmdSummary}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "2" "2"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
if [ "${cmdDescription}" != "" ]; then
shell_cli_utils_string_wrap "${cmdDescription}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "2" "2"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
fi
}
_shell_cli_handler_help_render_usage() {
local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
echo ""
echo "## Usage:"
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
echo "   ./${cmdName}.sh <action> [flags]"
echo "   ./${cmdName}.sh <resource> [<action>] [flags]"
else
echo "   ./${cmdName}.sh ${SHELL_CLI_RESOURCE_TREE} [<action>] [flags]"
fi
}
_shell_cli_handler_help_render_global_flags() {
local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
echo ""
echo "## Global System Flags:"
echo "   -h, --help            Display documentation and metadata definitions."
echo "   -itr, --interactive   Starts user interaction prompt mode."
}
_shell_cli_handler_help_render_subcmd_options() {
local useSubCmdType="Actions"
local useCmdRegistry="${SHELL_CLI_RESOURCE_REGISTRY}"
local useAssocCmdName="${SHELL_CLI_RESOURCE_REGISTRY_ACTION_ORDER}"
local useCmdResourcePath="${SHELL_CLI_RESOURCE_PATH}"
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
local useSubCmdType="Resources"
useCmdRegistry="${SHELL_CLI_MAIN_CMD_REGISTRY}"
useAssocCmdName="${SHELL_CLI_MAIN_CMD_REGISTRY_ORDER}"
useCmdResourcePath="${SHELL_CLI_MAIN_CMD_ROOT_PATH}/src"
fi
local -n arraySubCmdOrder="${useAssocCmdName}"
if [ "${#arraySubCmdOrder[@]}" = "0" ]; then
return 0
fi
local -a arraySubCmdName=()
local -a arraySubCmdSummary=()
local subCmdName=""
local subCmdSummary=""
local subCmdPath=""
local subCmdRegistry=""
local maxSubCmdNameLength="0"
for subCmdName in "${arraySubCmdOrder[@]}"; do
arraySubCmdName+=("${subCmdName}")
if [ "${#subCmdName}" -gt "${maxSubCmdNameLength}" ]; then
maxSubCmdNameLength="${#subCmdName}"
fi
subCmdPath="${useCmdResourcePath}/src/${subCmdName//-/_}/cmd.sh"
if [ ! -f "${subCmdPath}" ]; then
local nl=$'\n'
arraySubCmdSummary+=("Sub-Command definition not found.${nl}Missing file: '${subCmdPath}'.")
continue
fi
. "${subCmdPath}"
subCmdRegistry="${useCmdRegistry}_${subCmdName^^}"
subCmdRegistry="${subCmdRegistry//-/_}"
shell_cli_preflight_check_command_registry "${subCmdRegistry}"
local s="$?"
local ref=""
if [ "${s}" = "1" ]; then
arraySubCmdSummary+=("Not found '${subCmdRegistry}' associative array (declare -A) in '${subCmdPath}'.")
continue
elif [ "${s}" = "2" ]; then
arraySubCmdSummary+=("Assoc '${subCmdRegistry}'  in '${subCmdPath}' missing one or more mandatory keys.")
continue
fi
ref="${subCmdRegistry}[summary]"
arraySubCmdSummary+=("${!ref}")
done
echo ""
echo "## Available ${useSubCmdType}:"
local i=""
local txtSubCmdName=""
local txtSubCmdInfo=""
local txtSubCmdIndent="3"
local txtSubCmdSeparator="3"
local txtSubCmdSpace="0"
(( txtSubCmdSpace = txtSubCmdIndent + maxSubCmdNameLength + txtSubCmdSeparator))
local lastLineI="${#arraySubCmdOrder[@]}"
(( lastLineI = lastLineI - 1 ))
for i in "${!arraySubCmdOrder[@]}"; do
subCmdName="${arraySubCmdOrder["${i}"]}"
subCmdSummary="${arraySubCmdSummary["${i}"]}"
txtSubCmdName=$(printf "%-${maxSubCmdNameLength}s" "${subCmdName}")
txtSubCmdInfo="${txtSubCmdName}   ${subCmdSummary}"
shell_cli_utils_string_wrap "${txtSubCmdInfo}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${txtSubCmdIndent}" "${txtSubCmdSpace}"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
if [ "${SHELL_CLI_UTILS_STRING_WRAP_LINES_COUNT}" -ge "2" ] && [ "${i}" != "${lastLineI}" ]; then
echo ""
fi
done
}
_shell_cli_handler_help_render_flags() {
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
echo ""
return 0
fi
local useCmdFlagOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
local -n arrayCmdFlagOrder="${useCmdFlagOrder}"
echo ""
echo "## Parameter Flags:"
if [ "${#arrayCmdFlagOrder[@]}" = "0" ]; then
echo "   This command has no flag options."
echo ""
echo "${SHELL_CLI_HANDLER_HELP_SEPARATOR}"
echo ""
return 0
fi
local arraySubCmdFlagNameMaxLength="0"
local -a arraySubCmdFlagName=()
local -a arraySubCmdFlagType=()
local -a arraySubCmdFlagMode=()
local -a arraySubCmdFlagDefault=()
local -a arraySubCmdFlagDescription=()
local -a arraySubCmdFlagConstraints=()
local flagName=""
for flagName in "${arrayCmdFlagOrder[@]}"; do
local -n assocFlagRules="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName}"
local flagLong="${assocFlagRules["long"]}"
local flagShort="${assocFlagRules["short"]}"
local strShowFlags="--${flagLong}"
if [ "${flagShort}" != "" ]; then
strShowFlags="-${flagShort}, --${flagLong}"
fi
arraySubCmdFlagName+=("${strShowFlags}")
if [ "${#strShowFlags}" -gt "${arraySubCmdFlagNameMaxLength}" ]; then
arraySubCmdFlagNameMaxLength="${#strShowFlags}"
fi
local strShowType="${assocFlagRules["type"]}"
local strShowArrayType=""
if [ "${assocFlagRules["is_array"]}" = "1" ] || [ "${assocFlagRules["is_array"]}" = "true" ]; then
strShowType="<${strShowType}>"
strShowArrayType="array"
elif [ "${assocFlagRules["is_ssoc"]}" = "1" ] || [ "${assocFlagRules["is_ssoc"]}" = "true" ]; then
strShowType="<string, ${strShowType}>"
strShowArrayType="map"
else
strShowType="<${strShowType}>"
fi
arraySubCmdFlagType+=("${strShowArrayType}${strShowType}")
local strShowMode=""
if [ "${assocFlagRules["required"]}" = "1" ] || [ "${assocFlagRules["required"]}" = "true" ]; then
strShowMode="[REQUIRED]"
fi
arraySubCmdFlagMode+=("${strShowMode}")
arraySubCmdFlagDefault+=("${assocFlagRules["default"]}")
arraySubCmdFlagDescription+=("${assocFlagRules["description"]}")
local flagMin="${assocFlagRules["min"]}"
local flagMax="${assocFlagRules["max"]}"
local strShowConstraints=""
if [ "${flagMin}" != "" ] || [ "${flagMax}" != "" ]; then
local constraints=""
if [ "${flagMin}" != "" ]; then
constraints+="min: ${flagMin}, "
fi
if [ "${flagMax}" != "" ]; then
constraints+="max: ${flagMax}, "
fi
strShowConstraints="${constraints%, }"
fi
arraySubCmdFlagConstraints+=("${strShowConstraints}")
done
local i=""
local lastLineI="${#arrayCmdFlagOrder[@]}"
(( lastLineI = lastLineI - 1 ))
for i in "${!arrayCmdFlagOrder[@]}"; do
local strFlagName=$(printf "%${arraySubCmdFlagNameMaxLength}s" "${arraySubCmdFlagName["${i}"]}")
local strFlagType="${arraySubCmdFlagType["${i}"]}"
local strFlagMode="${arraySubCmdFlagMode["${i}"]}"
local strFlagDefault="${arraySubCmdFlagDefault["${i}"]}"
local strFlagConstraints="${arraySubCmdFlagConstraints["${i}"]}"
local strFlagDescription="${arraySubCmdFlagDescription["${i}"]}"
local useIndent="${arraySubCmdFlagNameMaxLength}"
(( useIndent = useIndent + 6))
local strFlagTitle="${strFlagName}   ${strFlagType}  ${strFlagMode}"
shell_cli_utils_string_wrap "${strFlagTitle}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "3" "3"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
if [ "${strFlagDefault}" != "" ]; then
shell_cli_utils_string_wrap "Default='${strFlagDefault}'" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
fi
if [ "${strFlagConstraints}" != "" ]; then
shell_cli_utils_string_wrap "Constraints='${strFlagConstraints}'" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
fi
if [ "${strFlagDescription}" != "" ]; then
shell_cli_utils_string_wrap "${strFlagDescription}" "${SHELL_CLI_HANDLER_HELP_COLUMNS}" "${useIndent}" "${useIndent}"
echo "${SHELL_CLI_UTILS_STRING_WRAP_LINES}"
if [ "${i}" != "${lastLineI}" ]; then
echo ""
fi
fi
done
echo ""
return
}


declare -g SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS="100"
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR="="
declare -g SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR=""
shell_cli_handler_interactive() {
if [ ! -t 0 ]; then
echo "[ERR] Interactive mode (-itr) cannot be executed in a non-TTY environment (e.g., CI/CD pipelines, cron jobs)." >&2
exit 1
fi
if [ "${SHELL_CLI_RESOURCE_TREE}" = "." ]; then
echo "[ERR] :: Interactive mode not available for the main command."
return 1
fi
local useCmdFlagOrder="#${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}[@]"
if [ "${!useCmdFlagOrder}" -eq "0" ]; then
echo "[ERR] :: No flag found; Interactive mode not available for this command."
return 1
fi
local currentCols="${COLUMNS:-80}"
if [ "${currentCols}" -lt "${SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS}" ] && [ "${currentCols}" -gt 20 ]; then
SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS="${currentCols}"
fi
for ((i=0; i<SHELL_CLI_HANDLER_INTERACTIVE_COLUMNS; i++)); do
SHELL_CLI_HANDLER_HELP_SEPARATOR+="${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR_CHAR}"
done
_shell_cli_handler_interactive_loop
return "$?"
}
_shell_cli_handler_interactive_loop() {
local cmdName="${SHELL_CLI_MAIN_CMD_NAME}"
local subCmdName="> ${SHELL_CLI_RESOURCE_TREE/ / > }"
echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
echo "[RUN] ${cmdName}${subCmdName} - Input in interactive mode"
echo "[ ! ] Note: Type ':q!' at any prompt to abort execution safely."
local useCmdFlagOrder="${SHELL_CLI_RESOURCE_REGISTRY_FLAG_ORDER}"
local -n arrayCmdFlagOrder="${useCmdFlagOrder}"
local flagName=""
local flagAssocName=""
for flagName in "${arrayCmdFlagOrder[@]}"; do
flagAssocName="${SHELL_CLI_RESOURCE_FLAG_FAMILY}_${flagName}"
local -n assocFlagRules="${flagAssocName}"
local flaglong="${assocFlagRules["long"]}"
local flagTipInput="${assocFlagRules["tipinput"]}"
if [ "$flagTipInput" = "" ]; then
flagTipInput="Enter value"
fi
while true; do
local flagRawInput=""
echo ""
echo -e "[ > ][ flag: --${flaglong} ] ${flagTipInput}: "
echo -n "     "
read -r flagRawInput
if [ "${flagRawInput}" = ":q!" ]; then
echo ""
echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
echo "[END] Aborted by user."
echo ""
return 10
fi
if ! shell_cli_process_flag_value "${flagAssocName}" "$flagRawInput"; then
local removeFlag="\[ --${flaglong} \]"
echo "${SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE/removeFlag/}"
continue
fi
SHELL_CLI_INPUT_RAW_FLAG_ASSOC["${flaglong}"]="${SHELL_CLI_PROCESS_FLAG_VALUE}"
SHELL_CLI_INPUT_RAW_FLAG_ORDER+=("${flaglong}")
SHELL_CLI_INPUT_RAW_FLAG+=("--${flaglong}='${SHELL_CLI_PROCESS_FLAG_VALUE}'")
break
done
done
echo ""
echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
echo "[ . ] End interactive mode. Proceeding... "
echo "${SHELL_CLI_HANDLER_INTERACTIVE_SEPARATOR}"
return 0
}


shell_cli_help() {
local msg=""
msg+="NAME\n"
msg+="  shell_cli - Dataset-driven, CoC-based CLI compiler and orchestration engine\n\n"
msg+="SYNOPSIS (MINIMAL BOOTSTRAP)\n"
msg+="  . shell_cli/main.sh\n"
msg+="  SHELL_CLI_ACTIVE_ROOT_PATH=\"\$(pwd)\"\n"
msg+="  declare -gA CMD_<PKG>_<TREE>=( ... )\n"
msg+="  declare -ga CMD_<PKG>_<TREE>_FLAG_ORDER=( ... )\n"
msg+="  shell_cli_run \"<PKGNAME>\" \"\$@\"\n\n"
msg+="DESCRIPTION\n"
msg+="  An enterprise-grade, native Bash framework driven by Convention over Configuration (CoC).\n"
msg+="  It isolates business logic by completely decoupling parameter parsing, atomic type validation,\n"
msg+="  and conversational interface handling without requiring external third-party binary utilities.\n"
msg+="  It intercepts schema structural failures during compilation loops (Developer Domain - Error 500)\n"
msg+="  and traps user token input violations during runtime execution streams (User Domain - Error 400).\n\n"
msg+="INTEGRATED LIFECYCLE (5 PIPELINE PHASES)\n"
msg+="  Phase 1: Sandboxing & Preflight   - Enforces runtime process locks and asserts schema integrity.\n"
msg+="  Phase 2: Parameter Resolution     - Resolves positional sub-routes and parses raw input tokens.\n"
msg+="  Phase 3: Interceptor Hijack       - Diverts execution flows to auto-help or conversational prompts.\n"
msg+="  Phase 4: Context Guard & Ingest   - Sanitizes raw inputs and triggers custom cross-validate hooks.\n"
msg+="  Phase 5: Business Execution       - Delivers clean data maps and fires target action function pointers.\n\n"
msg+="STRICT CONVENTION NAMING BLUEPRINT\n"
msg+="  The engine dynamically evaluates framework parameters using predictable, structured tokens:\n"
msg+="    Base Command Registry:  CMD_<PKGNAME>_<TREE>\n"
msg+="    Flag Checklist Sequence: CMD_<PKGNAME>_<TREE>_FLAG_ORDER\n"
msg+="    Flag Specific Schema:   CMD_<PKGNAME>_<TREE>_FLAG_<flag_long>\n"
msg+="    Localized Rule Override: CMD_<PKGNAME>_<TREE>_FLAG_<flag_long>_OVERRIDE\n"
msg+="    Sanitized Ingest Target: CMD_<PKGNAME>_<TREE>_INPUT[\"<flag_long>\"]\n"
msg+="    Cross-Validation Hook:  cmd_<pkgname>_<tree>_main_validate\n"
msg+="    Business Action Target:  cmd_<pkgname>_<tree>_action\n\n"
msg+="    * Note: For single-action applications, the <TREE> token falls back to 'ORES_<cmd>'.\n\n"
msg+="RESERVED FRAMEWORK FLAGS\n"
msg+="  -h,   --help             Triggers the core interceptor layer to render this manual context map.\n"
msg+="  -itr, --interactive      Forces field-by-field interactive prompt sequences using the FLAG_ORDER matrix.\n\n"
msg+="EXIT CODE SIGNATURES & RUNTIME TRACES\n"
msg+="  [ x ]  User Ingest Error - Type validation faults, range boundary breaches, or unmapped flags (Status 1).\n"
msg+="  [ ! ]  Business Warning  - Data constraint warning captured by the cross-validation hook (Status 2).\n"
msg+="  [ERR]  Compiler Failure  - Critical schema error caught during initialization loops (Status 10).\n\n"
msg+="COMPLEMENTARY TECHNICAL MANUALS (EXPLORE THE DOCS)\n"
msg+="  To master the ecosystem configurations without auditing underlying source code, consult docs/:\n\n"
msg+="  » docs/FLAGS.md\n"
msg+="    The absolute engineering reference guide detailing the 18 parameter configuration properties\n"
msg+="    (short, long, type, required, array, assoc, enum, regex, tipinput, transform, etc.).\n"
msg+="    Explains how the core normalizes text booleans ('true'/'false') into logic digits ('1'/'0').\n\n"
msg+="  » docs/TYPES.md\n"
msg+="    Architectural deep dive covering the native validation rules split across 3 data tiers:\n"
msg+="    - Primitives: string, int, float, bool.\n"
msg+="    - Structured Layouts: json, date, time, datetime, email, enum.\n"
msg+="    - System Environments: path, filepath, dirname, filename, url, and function references.\n\n"
msg+="  » docs/USAGE.md & docs/EXAMPLE.md\n"
msg+="    Practical companion walkthroughs and minimal working blueprints specifically engineered\n"
msg+="    to accelerate command generation for both human developers and Large Language Models (LLMs).\n"
echo -e "${msg}"
}


shell_cli() {
local mainCmdRootPath="${1}"; shift
local commandName=$(basename "${mainCmdRootPath}" ".sh")
if ! shell_cli_preflight_process_lock; then
return 1
fi
if ! shell_cli_preflight_prepare_main_cmd "${mainCmdRootPath}" "${commandName}" "$@"; then
shell_cli_preflight_process_unlock
return 1
fi
if ! shell_cli_preflight_prepare_target_resource "$@"; then
shell_cli_preflight_process_unlock
return 1
fi
if ! shell_cli_preflight_prepare_target_resource_flags; then
shell_cli_preflight_process_unlock
return 1
fi
if ! shell_cli_preflight_prepare_input "$@"; then
shell_cli_preflight_process_unlock
return 1
fi
if [ "${SHELL_CLI_TRIGGER_HELP}" = "1" ] || [ "${SHELL_CLI_RESOURCE_FUNCTION_ACTION}" = "" ]; then
shell_cli_handler_help
shell_cli_preflight_process_unlock
return 0
fi
if [ "${SHELL_CLI_TRIGGER_INTERACTIVE}" = "1" ]; then
if [ ! shell_cli_handler_interactive ]; then
shell_cli_preflight_process_unlock
return "$?"
fi
fi
if [ "${SHELL_CLI_RESOURCE_FUNCTION_VALIDATE}" != "" ]; then
if ! "${SHELL_CLI_RESOURCE_FUNCTION_VALIDATE}"; then
local validateStatus="$?"
shell_cli_preflight_reset
shell_cli_preflight_process_unlock
return "${validateStatus}"
fi
fi
"${SHELL_CLI_RESOURCE_FUNCTION_ACTION}"
local actionStatus="$?"
shell_cli_preflight_reset
shell_cli_preflight_process_unlock
return "${actionStatus}"
}


if [ "${BASH_SOURCE}" = "${0}" ]; then
for arg in "$@"; do
if [[ "${arg}" == -* ]]; then
case ${arg} in
-h|--help)
shell_cli_help
exit $?
;;
esac
fi
done
shell_cli "$@"
fi
