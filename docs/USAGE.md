Usage Guide
================================

This document is a practical companion to the technical reference docs. It is
meant for developers and AI assistants who need to build a command using the
shell_cli framework without having to infer the conventions from the source.


&nbsp;
&nbsp;


________________________________________________________________________________

## 1. What you need to create

To build a new CLI command with shell_cli, you should prepare the following
pieces in your entrypoint script:

1. Load the framework entrypoint from [main.sh](../main.sh).
2. Define `SHELL_CLI_ACTIVE_ROOT_PATH` with an existing directory.
3. Register the command metadata block.
4. Register the ordered flag list.
5. Define the flag schemas.
6. Implement the validation hook if you need cross-flag rules.
7. Implement the action hook that will execute the command.
8. Call `shell_cli_run` at the end.


&nbsp;
&nbsp;


________________________________________________________________________________

## 2. Minimum structure

A minimal command implementation usually follows this pattern:

```bash
#!/usr/bin/env bash

set -e

. shell_cli/main.sh

SHELL_CLI_ACTIVE_ROOT_PATH="$(pwd)"

declare -gA CMD_MYTOOL_ORES_status=(
  ["cmd"]="status"
  ["summary"]="check tool status"
  ["description"]="Describe what this command does"
)

declare -ga CMD_MYTOOL_ORES_status_FLAG_ORDER=("environment")

declare -gA CMD_MYTOOL_ORES_status_FLAG_environment=(
  ["short"]="e"
  ["long"]="environment"
  ["type"]="string"
  ["required"]=true
  ["description"]="Target environment"
)

cmd_mytool_ores_status_main_validate() {
  return 0
}

cmd_mytool_ores_status_action() {
  local env_stage="${CMD_MYTOOL_ORES_status_INPUT["environment"]}"
  echo "Running with ${env_stage}"
}

shell_cli_run "MYTOOL" "$@"
```


&nbsp;
&nbsp;


________________________________________________________________________________

## 3. Naming conventions

The framework relies on convention over configuration. The names below are not
optional if you want the engine to discover and invoke your command correctly:

* Command registry: `CMD_<PKG>_<TREE>`
* Flag order list: `CMD_<PKG>_<TREE>_FLAG_ORDER`
* Flag schema: `CMD_<PKG>_<TREE>_FLAG_<NAME>`
* Cross-validation hook: `cmd_<pkg>_<tree>_main_validate`
* Action hook: `cmd_<pkg>_<tree>_action`
* Validated inputs map: `CMD_<PKG>_<TREE>_INPUT`

The `<TREE>` portion is derived from the positional command path. For example,
`status` becomes `ORES_status` when used as the single positional command.


&nbsp;
&nbsp;


________________________________________________________________________________

## 4. Flags and aliases

Each flag schema should define at least:

* `short`: optional single-letter alias
* `long`: canonical long name
* `type`: validation type
* `required`: whether the value must be supplied
* `description`: text used in help rendering

The framework also treats the following as reserved control flags:

* `-h`, `--help`
* `-itr`, `--interactive`

If the user supplies an undeclared flag, or supplies both the short and long
form of the same property, the framework stops with an input error in the
`[ x ]` style.


&nbsp;
&nbsp;


________________________________________________________________________________

## 5. Validation flow

The execution lifecycle is roughly:

1. `shell_cli_run` checks that `SHELL_CLI_ACTIVE_ROOT_PATH` exists.
2. The entrypoint parses the incoming CLI input.
3. The framework validates the command and flag schemas.
4. If present, `cmd_<pkg>_<tree>_main_validate` runs.
5. If everything passes, `cmd_<pkg>_<tree>_action` runs.

This means the action hook can safely assume that the values are already parsed
and validated.


&nbsp;
&nbsp;


________________________________________________________________________________

## 6. Where to read the validated values

The validated and transformed values are not written to a single global map. 
They are stored in a clean, command-specific inputs map named:

```bash
CMD_<PKG>_<TREE>_INPUT
```

Your action hook should read from that map directly using long-name keys.


&nbsp;
&nbsp;


________________________________________________________________________________

## 7. Common mistakes to avoid

* Forgetting to define `SHELL_CLI_ACTIVE_ROOT_PATH`.
* Using the wrong function name for the action or validation hook.
* Declaring a flag without a `long` name.
* Mixing `array` and `assoc` on the same flag.
* Declaring `required="1"` together with a `default` value.
* Expecting values in a global map instead of `CMD_<PKG>_<TREE>_INPUT`.


&nbsp;
&nbsp;


________________________________________________________________________________

## 8. When to read the technical docs

Use the technical reference docs when you need the exact rule for a specific
property or validator:

* [FLAGS.md](./FLAGS.md) for schema properties and compiler constraints.
* [TYPES.md](./TYPES.md) for the supported data types.
* [EXAMPLE.md](./EXAMPLE.md) for a full end-to-end example.
