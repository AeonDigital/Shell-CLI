#!/usr/bin/env bash

# SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE — Temporary store for the active scalar element
# during pipeline evaluation.
# 
# - Holds the individual atomized value being piped through property-specific validation
#   functions.
# - Updated in-place with the normalized/transformed output at each successful evaluation
#   step.
declare -g SHELL_CLI_PROCESS_FLAG_SINGLE_VALUE=""

# SHELL_CLI_PROCESS_FLAG_TYPE — Runtime reference for the active flag data type.
# 
# - Ingested from the core flag schema definition before any validation cycles initiate.
# - Used by type-specific normalization and validation functions to dynamically build
#   command strings.
declare -g SHELL_CLI_PROCESS_FLAG_TYPE=""

# SHELL_CLI_PROCESS_FLAG_VALUE — Orquestrator pipeline buffer for the target flag
# input payload.
# 
# - Stores the primary input value or reference pointer name passed to the validation
#   engine.
# - Mutated across top-level property check wrappers to hold the fully normalized
#   final result.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE=""

# SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX — Visual contextual token prepended to
# framework error messages.
# 
# - Dynamically compiled using the active flag's canonical long name (e.g., "[ x
#   ][ --flag-name ]").
# - Used to provide unambiguous error trace context inside log or terminal output
#   strings.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_PREFIX=""

# SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE — Error message store for runtime payload
# evaluation failures.
# 
# - Captures specific structural, boundary, or type violation messages during processing.
# - Explicitly cleared and reset to an empty string at the beginning of each evaluation
#   cycle.
declare -g SHELL_CLI_PROCESS_FLAG_VALUE_ERR_MESSAGE=""

# SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER — Runtime index tracker for associative
# map declaration sequence.
# 
# - Populated by duplicating parsed sequence arrays discovered during dictionary
#   object ingestion.
# - Preserves chronological semantic key consistency for downstream collection loops
#   and reconstructions.
# - Explicitly reset to an empty array at the beginning of each flag processing workflow.
declare -ga SHELL_CLI_PROCESS_FLAG_VALUE_ASSOC_ORDER=()
