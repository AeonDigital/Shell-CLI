#!/usr/bin/env bash

# SHELL_CLI_FLAG_COMPILED_FAMILY — Associative tracking matrix for compiled flag
# families.
# 
# - Maps flag family string prefixes to their current compilation status.
# - Stores a success token value of "1" upon successful completion of family processing.
# - Serves as an internal cache layer to prevent redundant reprocessing during a
#   session loop.
declare -gA SHELL_CLI_FLAG_COMPILED_FAMILY=()

# SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE — Single source of truth for framework compilation
# failures.
# 
# - Captures descriptive validation or structural violation strings from compilation
#   functions.
# - Cleared and reset to an empty string at the beginning of every compilation attempt.
# - Acts as the primary pipeline barrier used to halt execution and report core engine
#   errors.
declare -g SHELL_CLI_FLAG_COMPILE_ERR_MESSAGE=""
