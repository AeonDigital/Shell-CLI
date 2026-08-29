#!/usr/bin/env bash

# SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER
# 
# Coordinator of flag population in interactive mode and during the internal validation
# period.
declare -ga SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER=()



# 
# FLAG long
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("long")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_long="METAFLAG_long"

# 
# FLAG short
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("short")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_short="METAFLAG_short"

# 
# FLAG type
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("type")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_type="METAFLAG_type"

# 
# FLAG accept_values
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("accept_values")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_accept_values="METAFLAG_accept_values"

# 
# FLAG description
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("description")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_description="METAFLAG_description"

# 
# FLAG tipinput
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("tipinput")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_tipinput="METAFLAG_tipinput"

# 
# FLAG default
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("default")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_default="METAFLAG_default"

# 
# FLAG required
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("required")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_required="METAFLAG_required"

# 
# FLAG normalize
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("normalize")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_normalize="METAFLAG_normalize"

# 
# FLAG min
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("min")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_min="METAFLAG_min"

# 
# FLAG max
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("max")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_max="METAFLAG_max"

# 
# FLAG regex
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("regex")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_regex="METAFLAG_regex"

# 
# FLAG validate
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("validate")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_validate="METAFLAG_validate"

# 
# FLAG transform
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("transform")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_transform="METAFLAG_transform"

# 
# FLAG is_array
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("is_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_is_array="METAFLAG_is_array"

# 
# FLAG min_array
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("min_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_min_array="METAFLAG_min_array"

# 
# FLAG max_array
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("max_array")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_max_array="METAFLAG_max_array"

# 
# FLAG is_assoc
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("is_assoc")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_is_assoc="METAFLAG_is_assoc"

# 
# FLAG required_keys
SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_ORDER+=("required_keys")
declare -g SHELL_CLI_CMD_CLIGEN_CREATE_FLAG_FLAG_required_keys="METAFLAG_required_keys"

# {{REGISTER FLAG PLACEHOLDER}}
