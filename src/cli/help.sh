#!/usr/bin/env bash

# shell_cli_help — Displays the core engineering manual and architecture guide for
# the shell_cli framework.
# 
# Returns:
# - Outputs the formatted technical reference layout directly to stdout.
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
