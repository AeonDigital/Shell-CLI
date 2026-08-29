CODING STANDARDS
================================

> This document establishes the official architectural standards, coding conventions, and quality gates for Bash shell scripting to guarantee low cognitive load, cross-platform portability, and maximum system predictability."




&nbsp;
________________________________________________________________________________

## 1. GLOBAL ARTIFACT & ENVIRONMENT STANDARDS

### 1.1 Strict Encoding Directives & Legacy Terminal Compatibility

All source files, script hooks, and technical documentation must be natively encoded
in UTF-8 format strictly without a Byte Order Mark (BOM).

All visible UTF-8 characters are permitted by default within code strings and files.
For baseline compatibility with legacy terminal architectures and maximal visual
predictability, authors are strongly encouraged to prioritize standard US-ASCII characters
in technical prose, comments, and strings.

The Unicode Box-Drawing Characters block (`U+2500` through `U+257F`) is explicitly
encouraged for generating visual tree directory structures and operational flowcharts
inside raw text headers or terminal layout functions. Additional non-ASCII visible
characters may be used only when technical precision or specific domain context requires
them.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 1.2 Content Constraints & Prohibited Elements (Negative Rules)

To protect the script lifecycle, ensure predictable runtime logging, and prevent
interpreter parser failures, specific formatting, visual, and hidden elements are
restricted across all codebase artifacts.

Emojis and arbitrary graphical ideograms are strictly prohibited inside script logic,
technical comments, variable assignments, and standard terminal logs. Standard textual
signs must be used exclusively to represent interface status.

Smart Quotes (curved typographic punctuation marks like `"` and `"`) must never be
used. Authors must employ standard vertical plain-text quote characters (`"` or `'`).
No invisible Unicode markers (such as Zero Width Spaces) or hidden ASCII control
characters are permitted, with the sole exception of standard line-termination and
spacing sequences (`\n`, `\r`, and `\t`).



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 1.3 Orthographic Normalization for Comments Prose Safety

To prevent downstream documentation engines and automated code parsers from accidentally
misinterpreting text blocks inside technical comments, punctuation characters embedded
in fluid comment blocks must follow explicit boundaries.

Whenever a standard hyphen (`-`), plus sign (`+`), or asterisk (`*`) character is
used as a standalone punctuation marker within a paragraph comment block—specifically
when bounded by leading and trailing space characters—it must be normalized into
its non-syntactic Unicode equivalent to avoid parsing collisions with markdown lists
or arithmetic triggers.

The transformation must follow these semantic mappings:

- ` - ` (Space-Hyphen-Space) → ` — ` (Space-EmDash-Space)
- ` + ` (Space-Plus-Space) → ` ＋ ` (Space-FullWidthPlus-Space)
- ` * ` (Space-Asterisk-Space) → ` ∗ ` (Space-AsteriskOperator-Space)

*Note: This rule applies exclusively to parsed comment streams and prose blocks.
Active structural list tokens located at the initialization index of a comment line
(e.g., within Function Document Anatomy definitions) or code inside protected blocks
are strictly exempt from this normalization.*



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 1.4 Line Endings Cross-Platform Standard (LF vs CRLF)

To ensure seamless execution, precise formatting parity, and to prevent static analysis
validation failures across heterogeneous operating systems (Linux, macOS, Windows),
this project enforces strict Line Feed (`LF`, `\n`) canonical terminations on all
shell script artifacts, configuration manifests, and code components.

Windows environments naturally utilize Carriage Return Line Feed (`CRLF`, `\r\n`).
Developers working natively on Windows platforms must decouple this behavior by configuring
their environment and git settings (`core.autocrlf input`) to enforce canonical `LF`
conversions upon checkout and commit.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 1.5 Mandatory Cross-Platform Shebang Enforcement

To ensure maximum runtime portability and dynamic environment path resolution across
different UNIX-like distributions (Linux, macOS, BSD), all executable shell script
source artifacts must utilize the environment-aware bash path declaration at the
absolute first line of the file:

```bash
#!/usr/bin/env bash
```

No alternate formats, hardcoded local paths (e.g., `#!/bin/bash`), or secondary shells
are permitted.




&nbsp;
________________________________________________________________________________

## 2. CODE ARCHITECTURE & PARADIGMS

### 2.1 POSIX File Sourcing Compliance & Shell Feature Constraints

To ensure maximum runtime portability and guarantee reliable cross-platform execution
across minimal or hardened UNIX environments, developers must utilize the native
POSIX dot notation (`.`) instead of the non-standard `source` built-in command when
importing external source artifacts into the active execution context:

```bash
# Correct architectural standard (POSIX Compliance)
. "./globals/utils.sh"

# Incorrect bashism pattern (Prohibited)
source "./globals/utils.sh"
```


While the codebase targets compatibility with modern Bash features, sourcing operations
must retain this foundational syntax to maintain system-level integrity.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 2.2 Shell Feature Target & Native Utility Preferences (The 32-Line Flexibility Rule)

This project explicitly targets and mandates compatibility with modern Bash runtime
environments, prioritizing **Bash 5.2+** and its advanced built-in features. Developers
must continuously leverage native shell mechanics (e.g., advanced internal parameter
expansions, built-in string manipulation, and internal mathematical contexts) to
actively eliminate process forks and external binary executions (such as `sed`, `awk`,
`tr`, or `date`).

Subprocesses and external utilities should only be introduced when an equivalent,
performant native Bash execution path does not exist, or when implementing the logic
natively would require more than **32 lines of new code**. If an external tool is
utilized due to this complexity threshold, the developer must explicitly document
the engineering justification in the architectural notes of the component.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 2.3 Subshell Execution Restraints

Invoking subshells via commands enclosed in parenthesis `( ... )` or using command
substitution `$( ... )` introduces substantial operating system overhead and process-cloning
degradation. To maximize framework throughput and maintain deterministic execution
loops, the indiscriminate or nested use of subshells is strictly prohibited. Developers
must prefer executing logic within the current shell context using functions, global
state mutation structures, or native variable passing mechanisms.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 2.4 Interactive Terminal Detection

Automation scripts must dynamically evaluate their environment context to determine
if they are operating within an interactive terminal or a headless CI/CD automation
pipeline. This detection must guide UI rendering, verbose logging, and user prompts.
To maintain POSIX compliance while evaluating multiple descriptors in a single block,
developers must use the standard `-a` logical operator:

```bash
# Standard Interactive Terminal Check Constraint
if [ -t 0 ] && [ -t 1 ]; then
  # Execution context is an interactive terminal session
  readonly IS_INTERACTIVE="true"
else
  # Execution context is non-interactive / automated script run
  readonly IS_INTERACTIVE="false"
fi
```




&nbsp;
________________________________________________________________________________

## 3. NAMING CONVENTIONS & VARIABLE SCOPING

### 3.1 Casing Rules for Functions and Variables

To lower cognitive load and maintain structural consistency across all project domains,
a strict case-segregation rule is applied to all identifiers based on their scope
and nature:

- **Functions & Local Variables:** Must strictly utilize lowercase `snake_case` (e.g.,
  `calculate_metrics`, `local target_path=""`).
- **Global Variables:** Must strictly utilize uppercase `UPPER_CASE` (e.g., `SHELL_CLI_CMD_INPUT`).
  Special design-driven framework instances (such as dynamic structural tokens or
  utility flags like `codeNL`) are explicitly exempt from this constraint.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 3.2 Variable Declaration, Scoping & Single-Line Constraints

To guarantee strict isolation and prevent catastrophic memory leaks or unexpected
state mutations within the execution pool, developers must explicitly scope and initialize
every variable upon instantiation:

- **Inside Functions:** Every single variable must be explicitly declared utilizing
  the `local` keyword.
- **Outside Functions (Global Scope):** Global variables must be explicitly registered
  utilizing the global declaration command flag `declare -g`, along with any structural
  attributes required (e.g., `-a` for indexed vectors or `-A` for associative matrices).

Every variable declaration must occupy its own **isolated, single line**. Bundling
or stacking multiple variable declarations onto a single code line is strictly prohibited.

- **Mandatory Explicit Initialization:** Variables must never be declared "naked"
  or left uninitialized. The initial default state must be visually and structurally
  explicit at the exact moment of declaration to lower cognitive strain and prevent
  inheritance side-effects:


```bash
# Correct explicit initialization standard
local target_str=""
local -a record_list=()
local -A metadata_matrix=()

# Incorrect/Prohibited naked declaration patterns
local target_str
local -a record_list
local -A metadata_matrix=
```


*Note: These isolated, explicitly initialized declaration lines do not count toward
the maximum function length limits defined in later architectural sections of this
document.*



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 3.3 Mandatory Parameter Bracing, Enclosure & Human-Readable Logic

To prevent visual ambiguity, eliminate unexpected string concatenation failures,
and guarantee absolute predictability, developers must consistently encapsulate variable
expansions:

- **Expansion Standard:** The explicit use of protective parameter braces `${var}`
  combined with enclosing double quotes `"${...}"` is strictly mandatory for all
  variable references across all operational blocks (including `if` statements, `while`
  loops, and general assignments).


- **Arithemetic Exception:** Native mathematical evaluation contexts wrapped in double
  parenthesis `(( ... ))` are strictly exempt from this double-quoting constraint,
  as quotes degrade arithmetic processing.


```bash
# Correct architectural standard (Mandatory Bracing and Quotes)
local target_dir="${1}"
if [ "${target_dir}" = "" ]; then
  echo "${target_dir}"
fi

# Incorrect unbraced/unquoted pattern (Prohibited)
local target_dir=$1
if [ -z $target_dir ]; then
  echo $target_dir
fi
```


- **Human-Readable Logic Preference:** To reduce cognitive costs and keep code accessible
  to developers coming from non-shell backgrounds, authors must prioritize clear,
  explicit comparisons over cryptic shell flags whenever possible. For instance,
  testing for an empty string using `[ "${my_var}" = "" ]` is strongly preferred
  over the less accessible `[ -z "${my_var}" ]`.


- **Cognitive-Load Constraint (Logical Operators):** Cryptic, legacy shell-specific
  compound operators inside single brackets—specifically `-a` (AND) and `-o` (OR)—are
  strictly prohibited. Developers must employ universally recognized chaining mechanics
  (`&&` and `||`) outside the evaluation brackets to keep logic clean and human-readable:


```bash
# Correct human-readable standard (Low Cognitive Cost)
if [ "${is_valid}" = "true" ] && [ "${has_permission}" = "true" ]; then

# Incorrect cryptic standard (Prohibited)
if [ "${is_valid}" = "true" -a "${has_permission}" = "true" ]; then
```




&nbsp;
________________________________________________________________________________

## 4. FUNCTION DESIGN & RETURN MECHANICS

### 4.1 Function Complexity, Sizing Trigger Boundaries & Cyclomatic Paths

To preserve long-term maintainability and guarantee readability, developers must
strictly avoid creating monolithic subroutines. Large functions must be decomposed
into smaller, highly specialized routines based on explicit visual and structural
triggers:

- **Sizing Range Trigger:** A flexible threshold between 64 and 128 lines of code
  serves as the primary indicator that a function is expanding beyond safe architectural
  limits.
- **The Loop & Branching Trigger:** The absolute trigger for decomposition is the
  presence of loops (`for`, `while`, `until`). If a function contains loop mechanisms,
  it must be aggressively broken down into sub-functions.
- **Exception for Monolithic Scopes:** A function may exceed the 64-to-128 line boundary
  *only* if it contains zero loops and its cyclomatic complexity remains low, meaning
  the execution logic encounters no more than 3 distinct paths (branches).



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 4.2 Standardized Multi-Value Return Architectural Pattern (`_status` & `_return`)

To completely eliminate the processing overhead and performance degradation caused
by indiscriminate subshell forks, functions must never pass data upstream by printing
raw outputs to standard streams for capture via command substitution.

Instead, the project enforces a standardized architectural pattern for multi-value
returns utilizing specialized global communication registers. To prevent variable
pollution and state inheritance bugs, a framework initialization hook must be invoked
at the absolute beginning of every function to reset these global spaces:

- **Standard Global Return Registers:** The ecosystem pre-defines the following target
  stores for routine output communication:
  + `_status` : Holds the numeric operational exit code or boolean flag status.
  + `_return` / `_return_N` : Holds standard scalar or string results (where `_return`
    can omit the suffix if only a single value is returned, or scale to `_return_1`,
    `_return_2` for multiple outputs).
  + `_array_return` / `_array_return_N` : Holds indexed vector structures.
  + `_assoc_return` / `_assoc_return_N` : Holds associative matrix structures.

*Note: This specification defines the interface standard that developers must target;
the dynamic automated utility function responsible for managing and clearing these
registers will be supplied by future framework implementations.*



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 4.3 Data Persistence & Array Serialization Strategies between Sessions

Because the native Bash environment explicitly restricts the exporting of complex
data structures—making it technically impossible to utilize the standard `export`
utility for indexed arrays or associative matrices across decoupled operational boundaries—the
project dictates a strict serialization paradigm.

To preserve complex data integrity across decoupled system actions or framework execution
steps, arrays must be programmatically serialized into unified string buffers or
flattened raw code block formats. These buffers can then be safely bound to standard
environmental variables and reconstructed (deserialized) into fully active array
tracks inside downstream current-shell execution contexts, eliminating the need for
slow filesystem operations or subshell overhead.

**Universal Pattern (Works for both Indexed and Associative Arrays):**

To serialize any complex array structure safely into a standard environmental variable,
developers must capture its internal definition via the core `declare -p` mechanism.
Re-hydration is performed by evaluating the captured definition string.

```bash
# Global definitions inside the framework environment context
declare -A MY_ASSOC_ARRAY=([key1]="val1" [key2]="val2")
declare -gx X_SERIALIZED_ARRAY_STORE=""

# Step 1: Serialize the complete structure (definition, keys, and values)
shell_cli_serialize_array() {
  # Captures the exact literal declaration statement of the target array variable
  X_SERIALIZED_ARRAY_STORE=\$(declare -p MY_ASSOC_ARRAY)
}

# Step 2: Reconstruct and deserialize the array inside the downstream session
shell_cli_deserialize_array() {
  # Evaluate the declaration string to re-hydrate the array with full context intact
  eval "\${X_SERIALIZED_ARRAY_STORE}"
}
```



*Architectural Directive: The `eval` execution pattern for array re-hydration is
permitted exclusively when parsing internal framework configuration variables that
have been strictly sanitized. This mechanism guarantees that associative keys and
nested sparse indexes are natively preserved across execution lifecycles without
data degradation.*




&nbsp;
________________________________________________________________________________

## 5. DOCUMENTATION & TECHNICAL COMMENT STANDARDS

### 5.1 General Comment Constraints & Formatting Visual Spacing

All code documentation, technical inline analysis, and structural metadata naming
must utilize 100% technical English.

To maximize scannability and guarantee long-term maintainability, developers must
strictly avoid dense, blocky, inline comments that choke code readability. Source
implementations must employ generous visual spacing, intentional line breaks, and
consistent indentation blocks so that engineers can skim code flows and logic barriers
effortlessly.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 5.2 Function Comment Anatomy (Tiered Metadata Design)

Every shell function documentation block must utilize an agnostic, highly scannable
tiered metadata design using strict capitalized headers. Implementations must follow
this exact anatomy sequence:

1. **Summary line:** The function name followed immediately by a single hyphen and
   a brief, single-line explanation of its overarching structural purpose (e.g.,
   `# func_name - Summary description.`).


2. **Arguments:** Mandatory header if parameters are accepted. Uses a flat list detailing
   positional tokens or custom names (e.g., `- ruleVal: Description.`).


3. **Global inputs:** Mandatory header if the routine consumes standard frame states
   or ecosystem environment maps.


4. **Global outputs:** Mandatory header if the routine triggers ecosystem-wide side-effects,
   alters shared pipelines, or mutates high-level system states.


5. **Notes:** Mandatory header to isolate architectural constraints, structural phases,
   processing assumptions, or short-circuit bypass paths.


6. **Returns:** Mandatory header mapping expected operational exit status codes,
   alongside the explicit declaration of the standard global return communication
   registers (`_status`, `_return`, `_array_return`, `_assoc_return`) populated by
   the function.

**Example Pattern:**

```bash
# shell_cli_orchestrate_pipeline - Agnostic core processor managing downstream structural loops.
#
# Arguments
# - ruleVal: Configured baseline constraints matrix used to validate incoming payload bytes.
#
# Global inputs
# - SHELL_CLI_CMD_INPUT: Main production-ready associative registry available to action handlers.
#
# Notes
# - Pipeline Phase 1: Loops sequentially to apply parameter substitution compilation drivers.
# - Short-circuits execution immediately upon encountering internal calculation overflows.
#
# Returns
# - _status: 0 on success, 10 on critical processing overflow error.
# - _return: A scalar string containing the compiled pipeline execution hash key.
```



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 5.3 Global Variable Comment Anatomy

To guarantee architectural parity across the entire ecosystem, global variables (scalars,
associative matrices, or indexed vector tracks) must follow a predictable blueprint
consisting of a primary summary header followed by bulleted functional notes:

1. **Summary Header:** The uppercase variable name followed by a single hyphen and
   a brief, agnostic definition of its role as a registry or pipeline buffer.
2. **Bulleted Notes:** A short list detailing mutation conditions, fallback token
   values (e.g., `"-"`, `"0"`, `"-1"`), initialization resets, or engine index limitations.

**Example Pattern:**

```bash
# SHELL_CLI_CMD_VALIDATE_ERR - Domain-level error message store for custom context validation breakdowns.
#
# - Captures specific procedural violation strings generated inside user-defined '_validate' hook extensions.
# - Evaluated by the execution coordinator immediately before dispatching the main application action payload.
declare -g SHELL_CLI_CMD_VALIDATE_ERR=""
```




&nbsp;
________________________________________________________________________________

## 6. TERMINAL INTERFACE & SIGNAGE CONVENTION

### 6.1 Atomic Actions & Individual Tasks

To maximize terminal portability, avoid character encoding breakages across different
emulators, and maintain a unified visual identity, the use of emojis in automation
scripts, logs, and interface output stream layers is strictly prohibited.

Instead, developers must utilize standardized, low-cognitive-cost textual brackets
to specify the execution status of isolated operations (e.g., evaluating a single
file or checking a specific state):

- **`[ v ]` (Success):** Applied when an attempted specific action succeeded perfectly.
- **`[ x ]` (Failure):** Applied when an attempted or evaluated specific action failed.
- **`[ . ]` (Progress):** Applied to signal a minor, localized sub-task currently
  in progress or non critic information.
- **`[ ! ]` (Warning):** Applied to highlight non-blocking architectural alerts,
  deprecation notes, or transient operational anomalies.
- **`[ ? ]` (Inquiry/Question):** Applied exclusively when the runtime engine poses
  a direct, binary, or specific choice query to the operating engineer, preceding
  the question message.
- **`[ > ]` (Prompt):** Applied exclusively on the line where the script halts to
  capture user interaction, marking the exact prompt index where the user types the
  terminal input.

**Example Pattern:**

```bash
echo "[ ? ] Do you want to proceed with the migration? (y/n)"
read -r -p "[ > ] " user_input
```



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 6.2 Macro-Execution & Lifecycle States

Applied to signal high-level orchestration milestones, global multi-task states,
or major script lifecycle transitions across the system runtime pipeline:

- **`[RUN]` (Running):** Indicates the absolute initialization or startup phase of
  a major technical execution pipeline or workflow engine.


- **`[END]` (Finishing):** Indicates the exact boundary where a primary script execution
  cycle or workflow block terminates its processes.


- **`[OKK]` (Global Success):** Signifies that a complete sequence of multiple tasks
  or a major operational subsystem finished successfully with zero issues.


- **`[ERR]` (Global Failure):** Signifies that a major global operation, execution
  orchestration loop, or critical script phase failed completely with unrecoverable
  errors.


- **`[FATAL]` (Unrecoverable Infrastructure Failure):** Applied exclusively when
  a critical, unexpected dependency or structural asset is completely missing (e.g.,
  a required binary like `curl` is absent, or a primary configuration manifest cannot
  be found), forcing an immediate, hard abort of the entire execution lifecycle.

**Example Pattern:**

```bash
if ! command -v curl &> /dev/null; then
  echo "[FATAL] Core dependency 'curl' is not installed. Aborting execution."
  exit 1
fi
```



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 6.3 Standard Visual Section Separator & Console Layout

To visually isolate core logical steps, major transitions, or high-level workflow
initializations inside the algorithm terminal execution stream, developers must wrap
the entire execution lifespan of a block using a strict 80-character horizontal bar
constraint that opens and closes the process sequence.

The layout requires that the initialization of a major block opens with the appropriate
Macro-Lifecycle sign (typically `[RUN]`) bounded by bars, leaving the logging area
open. Once the workflow terminates, it must be cleanly closed by echoing the final
status sign (e.g., `[OKK]`. `[END]` or `[ERR]`) right before drawing the final horizontal
boundary:

**Block Initialization Pattern (Opening the Context):**

```bash
# Correct layout implementation to open a major console workflow section
echo "================================================================================"
echo "[RUN] Initializing standard architectural block operation..."
echo ""
```

**Block Termination Pattern (Closing the Context):**

```bash
# Correct layout implementation to close a major console workflow section
echo ""
echo "[OKK] The standard architectural block operation finished successfully."
echo "================================================================================"
```




&nbsp;
________________________________________________________________________________

## 7. QUALITY ASSURANCE & TESTING ARCHITECTURE

### 7.1 Logical Path Coverage Requirements & Isolated Focus

Maximizing code coverage through automated testing is a primary goal to preserve
internal system predictability, prevent regressions, and guarantee long-term stability.

- **Comprehensive Path Exploration:** Every unit test suite must systematically validate
  every internal branch, conditional execution path, and logical switch statement
  belonging to the target script or function.


- **Isolated Target Focus:** Functions under examination should be targeted independently
  within their dedicated test routines. Developers must completely avoid mixing testing
  contexts, nesting scopes across unrelated logic, or chaining side-effects between
  distinct functions to guarantee a deterministic outcome.



&nbsp;
---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- 

### 7.2 Pre-Commit Automated Validation Hooks

To guarantee absolute compliance with these coding standards and protect the shared
repository state, automated quality verification barriers are strictly enforced before
any code can be committed.

Developers must integrate and execute the following automated validation pipelines
locally within their Git `pre-commit` hook architecture:

- **Static Analysis (Linting):** All executable shell artifacts and `.sh` files must
  pass static analysis checks (e.g., via `shellcheck`) with zero warnings or errors
  to enforce safety against common shell scripting pitfalls.
- **Unit Testing Execution:** The automated test runner must be automatically triggered
  upon every commit attempt. The commit action will be immediately short-circuited
  and rejected if any single unit test case fails.
- **Style Enforcement:** Visual formatting validations, soft indentation limits,
  and line termination standards (`LF`) must be verified programmatically before
  code ingestion.