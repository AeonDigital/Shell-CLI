#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: export/main.sh
# DESCRIPTION: A high-performance, modular distribution bundler engineered to 
#              consolidate multiple codebase assets (.sh, .md, .go, .js) into a 
#              single standalone file. Automates comments stripping, minification,
#              and dynamic meta-markup generation per file extension.
#              
# USAGE EXAMPLES:
#   # Predefined Presets:
#   ./export/main.sh --sh-src-pkg
#   ./export/main.sh --md-docs
#
#   # Format Scanners (Targets the entire workspace ROOT_PATH by default):
#   ./export/main.sh --sh
#   ./export/main.sh --md
#   ./export/main.sh --go
#   ./export/main.sh --js
#
#   # Target Modification Sub-scanners:
#   ./export/main.sh --sh=src/core
#   ./export/main.sh --go=cmd/api
#
#   # Dynamic Overrides & Multi-file Operations:
#   ./export/main.sh --js=src --file="bundle.js" --exclude="*_test.js" --split=0
#   ./export/main.sh --md=docs --file="docs.md" --before="intro.md" --after="END.md"
#   ./export/main.sh --sh=src --header="# MIT License\n# Copyright 2026"
#   ./export/main.sh --go=pkg --header="export/headers/license.txt"
#
#   # System Help:
#   ./export/main.sh --help
# ==============================================================================





# ==============================================================================
# BUNDLER GLOBAL CONFIGURATIONS
# ==============================================================================

# The absolute base directory of the project workspace. Automatically calculated 
# by default, but can be manually overridden when running inside submodules.
declare -g SHELL_CLI_EXPORT_ROOT_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)

# The relative directory path (starting from ROOT_PATH) where the primary file 
# search will be executed. Can be empty or "." to target the ROOT_PATH itself.
declare -g SHELL_CLI_EXPORT_TARGET_DIR=""

# Maximum directory depth level for the file discovery engine. Limits how deep 
# the recursive search goes to prevent unintended matches (e.g., "1", "2").
declare -g SHELL_CLI_EXPORT_MAX_DEPTH=""

# A space-separated list of target file extension patterns to strictly include 
# in the compilation (e.g., "*.sh *.bash" or "*.md").
declare -g SHELL_CLI_EXPORT_EXTENSIONS_IN=""

# A space-separated list of file extension patterns or path structures to 
# forcefully exclude from compilation (e.g., "*_test.sh" or "*/path/to/exclude/*").
declare -g SHELL_CLI_EXPORT_EXTENSIONS_EX=""

# A space-separated list of explicit file paths to be consolidated at the very 
# beginning of the bundle. Relative paths are always evaluated from ROOT_PATH.
# Files must exist on disk, otherwise the compilation process must fail.
declare -g SHELL_CLI_EXPORT_FILES_BEFORE=""

# A space-separated list of explicit file paths to be consolidated at the very 
# end of the bundle. Relative paths are always evaluated from ROOT_PATH.
# Files must exist on disk, otherwise the compilation process must fail.
declare -g SHELL_CLI_EXPORT_FILES_AFTER=""

# Custom header string payload OR absolute/relative file path containing text 
# to be injected at the very beginning of the compiled bundle (optional).
declare -g SHELL_CLI_EXPORT_HEADER=""

# The destination filename or path for the final consolidated distribution bundle.
# Relative paths are always evaluated from ROOT_PATH.
declare -g SHELL_CLI_EXPORT_OUTPUT_FILE=""

# Flag ("1" or "0") determining whether metadata boundaries enclosing the origin 
# file paths should be injected into the output bundle.
declare -g SHELL_CLI_EXPORT_SPLIT_MARKERS=""





# ==============================================================================
# FORMATTER PLUGINS (EXTENSION-SPECIFIC PACKAGERS)
# ==============================================================================

# _shell_cli_export_xml_style_streamer centralizes IO tasks for text payloads.
# Injects structural XML/HTML markers and streams core raw data content.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
_shell_cli_export_xml_style_streamer() {
  local file_path="$1"

  # Inject HTML comment initialization meta-markers if splitting is enabled
  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "<!--:: "
    echo "[FILE INI] ${file_path} "
    echo "-->"
  fi

  # Stream the entire raw payload intact directly from disk
  cat "${file_path}"

  # Inject HTML comment finalization meta-markers if splitting is enabled
  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo ""
    echo "<!--:: "
    echo "[FILE END] ${file_path} "
    echo "-->"

    # Guarantee a clean 5-line structural separator between files
    printf "\n\n\n\n\n"
  fi
}

# shell_cli_export_format_txt processes a single .txt document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_txt() {
  _shell_cli_export_xml_style_streamer "$1"
}

# shell_cli_export_format_tmpl processes a single .tmpl document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_tmpl() {
  _shell_cli_export_xml_style_streamer "$1"
}

# shell_cli_export_format_md processes a single .md document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_md() {
  _shell_cli_export_xml_style_streamer "$1"
}





# shell_cli_export_format_sh processes a single .sh document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_sh() {
  local file_path="$1"
  local raw_line=""
  local clean_line=""

  # Inject standard initialization meta-markers if splitting is enabled
  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "#"
    echo "##:: [FILE INI] ${file_path}"
  fi

  # Stream file line-by-line using a standard robust loop sequence
  IFS=$'\n'
  while read -r raw_line || [ -n "${raw_line}" ]; do
    clean_line="${raw_line}"
    clean_line="${clean_line#"${clean_line%%[![:space:]]*}"}" # trim L
    clean_line="${clean_line%"${clean_line##*[![:space:]]}"}" # trim R

    # Drop fully empty lines or explicit functional script comments
    if [ "${clean_line}" != "" ] && [ "${clean_line:0:1}" != "#" ]; then
      echo "${raw_line}"
    fi
  done < "${file_path}"
  unset IFS

  # Inject standard finalization meta-markers if splitting is enabled
  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "##:: [FILE END] ${file_path}"
    echo "#"

    # Guarantee a clean 5-line structural separator between files
    printf "\n\n\n\n\n"
  fi
}





# _shell_cli_export_c_style_cleaner handles comment stripping for Go and JS/TS.
# Evaluates line comments (//) and tracks multi-line blocks (/* */) gracefully.
#
# Arguments:
#   - file_path: Target absolute or relative script file path.
_shell_cli_export_c_style_cleaner() {
  local file_path="$1"
  local raw_line=""
  local clean_line=""
  local in_block_comment="0"

  IFS=$'\n'
  while read -r raw_line || [ -n "${raw_line}" ]; do
    clean_line="${raw_line}"
    clean_line="${clean_line#"${clean_line%%[![:space:]]*}"}" # trim L
    clean_line="${clean_line%"${clean_line##*[![:space:]]}"}" # trim R

    # Skip fully empty whitespace lines immediately
    if [ "${clean_line}" == "" ]; then
      continue
    fi

    # Scenario A: We are currently inside a trapped multi-line comment block
    if [ "${in_block_comment}" == "1" ]; then
      if [[ "${clean_line}" == *"*/"* ]]; then
        in_block_comment="0"
        # Extract remaining valid code executing strictly after the block closure segment
        local post_code="${clean_line#*\"*/\"}"
        post_code="${clean_line##*\"*/\"}"
        post_code="${clean_line#*\/}" # fallback safe path extract
        # Clean parsing extraction strategy for inline trailing code sequences
        local remainder="${raw_line#*\*\/}"
        local clean_remainder="${remainder#"${remainder%%[![:space:]]*}"}"
        if [ "${clean_remainder}" != "" ]; then
          echo "${remainder}"
        fi
      fi
      continue
    fi

    # Scenario B: Trapped initialization of a standard inline block sequence
    if [[ "${clean_line}" == "/*"* ]]; then
      if [[ "${clean_line}" == *"*/" ]]; then
        # Inline closed block: Entire line is a comment block, skip it
        continue
      elif [[ "${clean_line}" == *"*/"* ]]; then
        # Block opens and closes inside the same line but contains code at the end
        local remainder="${raw_line#*\*\/}"
        echo "${remainder}"
      else
        # Multi-line block opened. Toggle structural tracker state active
        in_block_comment="1"
      fi
      continue
    fi

    # Scenario C: Dropping explicit standard C-style single line comments
    if [ "${clean_line:0:2}" == "//" ]; then
      continue
    fi

    # Handle standard trailing inline comments if required (preserving original leading layout tabs)
    if [[ "${clean_line}" == *" //"* || "${clean_line}" == *"	//"* ]]; then
      # Extract only code executing prior to the comment element injection mark
      echo "${raw_line%% //*}"
      continue
    fi

    # No structural comment found: Print the original raw structural line sequence
    echo "${raw_line}"
  done < "${file_path}"
  unset IFS
}

# shell_cli_export_format_go processes a single .go document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_go() {
  local file_path="$1"

  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "//"
    echo "//:: [FILE INI] ${file_path}"
  fi

  _shell_cli_export_c_style_cleaner "${file_path}"

  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "//:: [FILE END] ${file_path}"
    echo "//"
    printf "\n\n\n\n\n"
  fi
}


# shell_cli_export_format_js processes a single .js document file path.
#
# Arguments:
#   - file_path: Absolute or relative path to the target file.
#
# Returns:
#   - Streamed stdout containing the processed bundle fragment.
shell_cli_export_format_js() {
  local file_path="$1"

  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "//"
    echo "//:: [FILE INI] ${file_path}"
  fi

  _shell_cli_export_c_style_cleaner "${file_path}"

  if [ "${SHELL_CLI_EXPORT_SPLIT_MARKERS}" == "1" ]; then
    echo "//:: [FILE END] ${file_path}"
    echo "//"
    printf "\n\n\n\n\n"
  fi
}





# ==============================================================================
# MAIN CORE DISPATCH ENGINE
# ==============================================================================

# _shell_cli_export_validate_and_compile orchestrates the file discovery engine,
# runs structural safety compliance checks, and streams formatted code output.
#
# Returns:
#   - 0: If the distribution bundle compiles smoothly without safety violations.
#   - 1: If any asset check fails, directory is missing, or formatting is corrupted.
_shell_cli_export_validate_and_compile() {
  # Assert workspace directory structural requirements
  if [ "${SHELL_CLI_EXPORT_ROOT_PATH}" == "" ]; then
    echo "[ERR] Global SHELL_CLI_EXPORT_ROOT_PATH cannot be empty."
    return 1
  fi
  if [ ! -d "${SHELL_CLI_EXPORT_ROOT_PATH}" ]; then
    echo "[ERR] Calculated ROOT_PATH directory does not exist: '${SHELL_CLI_EXPORT_ROOT_PATH}'"
    return 1
  fi

  # Fallback target directory evaluation to root if left empty
  local target_dir="${SHELL_CLI_EXPORT_TARGET_DIR}"
  if [ "${target_dir}" == "" ] || [ "${target_dir}" == "." ]; then
    target_dir="${SHELL_CLI_EXPORT_ROOT_PATH}"
  else
    target_dir="${SHELL_CLI_EXPORT_ROOT_PATH}/${target_dir}"
  fi

  if [ ! -d "${target_dir}" ]; then
    echo "[ERR] Target lookup directory does not exist: '${target_dir}'"
    return 1
  fi

  # Enforce strict single-extension compliance on core lookup patterns
  if [ "${SHELL_CLI_EXPORT_EXTENSIONS_IN}" == "" ]; then
    echo "[ERR] Global SHELL_CLI_EXPORT_EXTENSIONS_IN must declare exactly one pattern (e.g., '*.sh')."
    return 1
  fi
  
  # Strip possible wildcard tokens to isolate the raw textual extension identifier
  local base_ext="${SHELL_CLI_EXPORT_EXTENSIONS_IN#*.*}"
  if [[ "${base_ext}" == *" "* || "${base_ext}" == *"*"* ]]; then
    echo "[ERR] SHELL_CLI_EXPORT_EXTENSIONS_IN contains spaces or multiple wildcards. Only one extension allowed."
    return 1
  fi

  # Verify if a dedicated plugin exists for this isolated file format extension
  if [ "$(type -t "shell_cli_export_format_${base_ext}")" != "function" ]; then
    echo "[ERR] Missing expert formatting plugin function: 'shell_cli_export_format_${base_ext}'"
    return 1
  fi


  local -a compilation_queue=()

  # 1. Process and aggressively validate early injectable floating assets (BEFORE)
  local file_entry=""
  for file_entry in ${SHELL_CLI_EXPORT_FILES_BEFORE}; do
    local resolved_path="${file_entry}"
    if [[ "${resolved_path}" != /* ]]; then
      resolved_path="${SHELL_CLI_EXPORT_ROOT_PATH}/${file_entry}"
    fi

    if [ ! -f "${resolved_path}" ]; then
      echo "[ERR] Critical BEFORE floating asset not found on disk: '${resolved_path}'"
      return 1
    fi
    compilation_queue+=("${resolved_path}")
  done


  # 2. Dynamic directory scanning mapping sequence (FIND)
  local -a find_args=()
  find_args+=("${target_dir}")

  # Inject dynamic directory traversal bounds constraint limits
  if [ "${SHELL_CLI_EXPORT_MAX_DEPTH}" != "" ]; then
    find_args+=("-maxdepth" "${SHELL_CLI_EXPORT_MAX_DEPTH}")
  fi

  find_args+=("-type" "f" "-name" "${SHELL_CLI_EXPORT_EXTENSIONS_IN}")

  # Build logical exclusion blocks out of space-separated global matrices
  local exclusion_pattern=""
  for exclusion_pattern in ${SHELL_CLI_EXPORT_EXTENSIONS_EX}; do
    if [[ "${exclusion_pattern}" == *"/"* ]]; then
      find_args+=("!" "-path" "${exclusion_pattern}")
    else
      find_args+=("!" "-name" "${exclusion_pattern}")
    fi
  done

  # Stream discovery elements into temporary tracking buffers
  while IFS= read -r -d '' file; do
    compilation_queue+=("$file")
  done < <(find "${find_args[@]}" -print0 | LC_ALL=C sort -z)


  # 3. Process and aggressively validate late injectable floating assets (AFTER)
  for file_entry in ${SHELL_CLI_EXPORT_FILES_AFTER}; do
    local resolved_path="${file_entry}"
    if [[ "${resolved_path}" != /* ]]; then
      resolved_path="${SHELL_CLI_EXPORT_ROOT_PATH}/${file_entry}"
    fi

    if [ ! -f "${resolved_path}" ]; then
      echo "[ERR] Critical AFTER floating asset not found on disk: '${resolved_path}'"
      return 1
    fi
    compilation_queue+=("${resolved_path}")
  done


  # 4. Strict structural compilation compliance and consistency analysis
  if [ ${#compilation_queue[@]} -eq 0 ]; then
    echo "[ ! ] Compilation stack is empty. No files discovered to pack."
    echo "[END] End compilation."
    return 0
  fi

  # Assert extension type homogeneity across the entire generated queue block
  local active_file=""
  for active_file in "${compilation_queue[@]}"; do
    local active_ext="${active_file#*.*}"
    # Strip compound directory structures or nested path configurations out of sub-extensions
    if [[ "${active_file}" == *"."* ]]; then
      active_ext="${active_file##*.}"
    fi

    if [ "${active_ext}" != "${base_ext}" ]; then
      echo "[ERR] Extension homogeneity violation! File '${active_file}' does not match expected format extension '.${base_ext}'."
      return 1
    fi
  done


  # 5. Iterative Bundle Building Compilation Sequence
  if [ "${SHELL_CLI_EXPORT_OUTPUT_FILE}" == "" ]; then
    echo "[ERR] Global SHELL_CLI_EXPORT_OUTPUT_FILE destination cannot be empty."
    return 1
  fi

  local output_dest="${SHELL_CLI_EXPORT_OUTPUT_FILE}"
  if [[ "${output_dest}" != /* ]]; then
    output_dest="${SHELL_CLI_EXPORT_ROOT_PATH}/${output_dest}"
  fi

  # Clear old pre-existing target file bundles gracefully before stream injection
  : > "${output_dest}"
  if [ "$?" != "0" ]; then
    echo "[ERR] Write permission denied or device error on destination path: '${output_dest}'"
    return 1
  fi

  if [ "${SHELL_CLI_EXPORT_HEADER}" != "" ]; then
    # Resolve potential relative paths if checking for an on-disk header asset
    local header_file_path="${SHELL_CLI_EXPORT_HEADER}"
    if [[ "${header_file_path}" != /* ]]; then
      header_file_path="${SHELL_CLI_EXPORT_ROOT_PATH}/${SHELL_CLI_EXPORT_HEADER}"
    fi

    if [ -f "${header_file_path}" ]; then
      local tmp_header_content=$(< "$header_file_path")
      echo -e "${tmp_header_content}" >> "${output_dest}"
      printf "\n\n" >> "${output_dest}"
    else
      echo -e "${SHELL_CLI_EXPORT_HEADER}" >> "${output_dest}"
      printf "\n\n" >> "${output_dest}"
    fi
  fi

  # Loop and delegate text conversion streams directly to the chosen specialist plugin
  local final_bundle_content=""
  for active_file in "${compilation_queue[@]}"; do
    "shell_cli_export_format_${base_ext}" "${active_file}" >> "${output_dest}"
  done

  echo "[OKK] Standalone bundle successfully written to disk: '${output_dest}'"
  return 0
}





# ==============================================================================
# ENVIRONMENT CLEANUP (DESTROYS ENVIRONMENT SYMBOLS)
# ==============================================================================

# _shell_cli_export_cleanup removes all global variables, functions, and
# temporary environment markers created during script execution.
_shell_cli_export_cleanup() {
  # Destroy public configuration global states
  unset SHELL_CLI_EXPORT_ROOT_PATH
  unset SHELL_CLI_EXPORT_TARGET_DIR
  unset SHELL_CLI_EXPORT_MAX_DEPTH
  unset SHELL_CLI_EXPORT_EXTENSIONS_IN
  unset SHELL_CLI_EXPORT_EXTENSIONS_EX
  unset SHELL_CLI_EXPORT_FILES_BEFORE
  unset SHELL_CLI_EXPORT_FILES_AFTER
  unset SHELL_CLI_EXPORT_HEADER
  unset SHELL_CLI_EXPORT_OUTPUT_FILE
  unset SHELL_CLI_EXPORT_SPLIT_MARKERS

  # Destroy framework layout control primitives
  unset codeNL
  unset rootPath
  unset arg
  unset execution_status

  # Clean runtime compilation helper core primitives
  unset -f _shell_cli_export_validate_and_compile
  unset -f _shell_cli_export_c_style_cleaner
  unset -f shell_cli_export_format_sh
  unset -f shell_cli_export_format_md
  unset -f shell_cli_export_format_go
  unset -f shell_cli_export_format_js
  unset -f _shell_cli_export_cleanup
  unset -f _shell_cli_export_cleanup
}





# ==============================================================================
# HELP
# ==============================================================================

# _shell_cli_export_show_help prints the standard CLI manual to standard output.
_shell_cli_export_show_help() {
  echo -e "Usage: ./export/main.sh [OPTIONS]..."
  echo -e "Consolidates workspace distribution files into a single standalone bundle."
  echo -e ""
  echo -e "Format Scanners (Targets the entire workspace ROOT_PATH by default):"
  echo -e "  --sh                      Target Shell Script (.sh) files."
  echo -e "  --sh=DIR                  Target Shell Script files restricted to ROOT_PATH/DIR."
  echo -e "  --md                      Target Markdown (.md) files."
  echo -e "  --md=DIR                  Target Markdown files restricted to ROOT_PATH/DIR."
  echo -e "  --js                      Target JavaScript (.js) files."
  echo -e "  --js=DIR                  Target JavaScript files restricted to ROOT_PATH/DIR."
  echo -e "  --go                      Target Go (.go) files."
  echo -e "  --go=DIR                  Target Go files restricted to ROOT_PATH/DIR."
  echo -e ""
  echo -e "Advanced Options Overrides:"
  echo -e "  --file=FILENAME           The destination output filename or absolute/relative path."
  echo -e "  --header=STRING|PATH      Custom raw header text string OR file path to append at top."
  echo -e "  --exclude=PATTERN         Space-separated patterns/paths to forcefully exclude from find."
  echo -e "  --before=FILE_LIST        Space-separated explicit file list to consolidate at the very beginning."
  echo -e "  --after=FILE_LIST         Space-separated explicit file list to consolidate at the very end."
  echo -e "  --split=1|0               Inject structural file origin meta-markers (1=ON, 0=OFF). Default: 1."
  echo -e ""
  echo -e "Predefined Presets (Shortcuts):"
  echo -e "  --sh-src-pkg              Preset configuration for shell package distribution bundles."
  echo -e "  --md-docs                 Preset configuration for standard repository documentation compilations."
  echo -e ""
  echo -e "System Operations:"
  echo -e "  -h, --help                Display this comprehensive user assistance text and exit immediately."
}






# ==============================================================================
# CLI ARGUMENT PARSER AND INITIALIZATION
# ==============================================================================

# Phase 1: Evaluate special presets first to establish baseline states
for arg in "${@}"; do
  case "${arg}" in
    "-h"|"--help")
      _shell_cli_export_show_help
      _shell_cli_export_cleanup
      exit 0
      ;;
    "--sh-src-pkg")
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.sh"
      SHELL_CLI_EXPORT_TARGET_DIR="src"
      SHELL_CLI_EXPORT_OUTPUT_FILE="package.sh"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.sh"
      SHELL_CLI_EXPORT_HEADER="./export/header-sh.txt"
      SHELL_CLI_EXPORT_SPLIT_MARKERS="1"
      ;;
    "--sh-gen-pkg")
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.sh"
      SHELL_CLI_EXPORT_TARGET_DIR="gen"
      SHELL_CLI_EXPORT_OUTPUT_FILE="gen.sh"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.sh"
      SHELL_CLI_EXPORT_SPLIT_MARKERS="1"
      ;;
    "--sh-gen-tmpl")
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.tmpl"
      SHELL_CLI_EXPORT_TARGET_DIR="gen"
      SHELL_CLI_EXPORT_OUTPUT_FILE="gen.tmpl"
      SHELL_CLI_EXPORT_SPLIT_MARKERS="1"
      ;;
    "--md-docs")
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.md"
      SHELL_CLI_EXPORT_TARGET_DIR="docs"
      SHELL_CLI_EXPORT_OUTPUT_FILE="documents.md"
      SHELL_CLI_EXPORT_FILES_BEFORE="README.md"
      SHELL_CLI_EXPORT_SPLIT_MARKERS="1"
      ;;
  esac
done


# Phase 2: Parse and override with dynamic fine-grained parameters
while [ "$#" -gt 0 ]; do
  case "${1}" in
    --sh=*)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.sh"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.sh"
      SHELL_CLI_EXPORT_TARGET_DIR="${1#*=}"
      ;;
    --sh)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.sh"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.sh"
      SHELL_CLI_EXPORT_TARGET_DIR="."
      ;;
    --md=*)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.md"
      SHELL_CLI_EXPORT_TARGET_DIR="${1#*=}"
      ;;
    --md)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.md"
      SHELL_CLI_EXPORT_TARGET_DIR="."
      ;;
    --js=*)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.js"
      SHELL_CLI_EXPORT_TARGET_DIR="${1#*=}"
      ;;
    --js)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.js"
      SHELL_CLI_EXPORT_TARGET_DIR="."
      ;;
    --go=*)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.go"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.go"
      SHELL_CLI_EXPORT_TARGET_DIR="${1#*=}"
      ;;
    --go)
      SHELL_CLI_EXPORT_EXTENSIONS_IN="*.go"
      SHELL_CLI_EXPORT_EXTENSIONS_EX="*_test.go"
      SHELL_CLI_EXPORT_TARGET_DIR="."
      ;;
    --exclude=*)
      SHELL_CLI_EXPORT_EXTENSIONS_EX="${1#*=}"
      ;;
    --before=*)
      SHELL_CLI_EXPORT_FILES_BEFORE="${1#*=}"
      ;;
    --after=*)
      SHELL_CLI_EXPORT_FILES_AFTER="${1#*=}"
      ;;
    --header=*)
      SHELL_CLI_EXPORT_HEADER="${1#*=}"
      ;;
    --file=*)
      SHELL_CLI_EXPORT_OUTPUT_FILE="${1#*=}"
      ;;
    --split=*)
      SHELL_CLI_EXPORT_SPLIT_MARKERS="${1#*=}"
      ;;
    --sh-src-pkg|--sh-gen-pkg|--sh-gen-tmpl|--md-docs)
      # Already handled in Phase 1, skipping safely
      shift
      continue
      ;;
    *)
      echo "[ERR] Unknown CLI option modifier passed: '${1}'"
      _shell_cli_export_cleanup
      exit 1
      ;;
  esac
  shift
done


# Fire the validation and bundle builder compilation core engine
_shell_cli_export_validate_and_compile
execution_status=$?

# Final execution sequence cleanup trigger
_shell_cli_export_cleanup