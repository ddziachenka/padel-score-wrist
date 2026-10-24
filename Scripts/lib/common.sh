#!/usr/bin/env bash
# Scripts/lib/common.sh — shared behavior for every script in this template.
#
# Sourced, never executed. Callers are responsible for `set -euo pipefail`;
# everything here is written to behave correctly under it.
#
# Compatibility contract: macOS default /bin/bash is 3.2. Do not introduce
# associative arrays, `mapfile`/`readarray`, `${var,,}`, or globstar. Expand
# possibly-empty arrays as ${arr[@]+"${arr[@]}"} — a bare "${arr[@]}" on an
# empty array is an error under `set -u` in bash 3.2.
#
# No absolute tool paths appear here. Tools are resolved with `command -v`.

# Do not trust an inherited "already loaded" marker. Every entry point starts a
# new Bash process and sources this file exactly once; accepting an ambient
# IOSAI_COMMON_SH_LOADED used to let a caller skip the library entirely.
IOSAI_COMMON_SH_LOADED=1
readonly IOSAI_COMMON_SH_LOADED

# ---------------------------------------------------------------------------
# Exit-code vocabulary (sysexits-style; matches the convention already used by
# the local gate runners in the sibling projects).
#
# readonly, and deliberately NOT exported. A gate whose failure code can be
# reassigned — by a config file, by the environment, by anything — is not a
# gate. `readonly` makes an assignment a hard shell error rather than a silent
# redefinition, and keeping them out of the environment means no child process
# inherits a name that could be used to describe its own success.
# ---------------------------------------------------------------------------
EX_OK=0            # success
EX_FAIL=1          # generic failure / automated verification failed
EX_USAGE=64        # bad invocation or bad configuration argument
EX_VERIFY=65       # a verification assertion failed
EX_NOINPUT=66      # a required file, milestone, or result bundle is missing
EX_UNAVAILABLE=69  # a prerequisite is missing (tool, project, git repo)
EX_SOFTWARE=70     # internal inconsistency, including "ran 0 tests"
EX_CANTCREAT=73    # an output file or directory could not be created
EX_TEMPFAIL=75     # managed checkout/device or desktop lease is busy
readonly EX_OK EX_FAIL EX_USAGE EX_VERIFY EX_NOINPUT EX_UNAVAILABLE \
         EX_SOFTWARE EX_CANTCREAT EX_TEMPFAIL

# ---------------------------------------------------------------------------
# Repository root resolution.
#
# IOSAI_ROOT is derived from this file's own location, never from $PWD, so the
# scripts work when invoked from a subdirectory, from a parent directory, from
# a git hook, or from a linked worktree. It does not require a git repository.
# ---------------------------------------------------------------------------
_iosai_lib_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
IOSAI_ROOT="$(cd -- "${_iosai_lib_dir}/../.." && pwd -P)"
unset _iosai_lib_dir

IOSAI_ARTIFACTS_DIR="${IOSAI_ROOT}/.artifacts"
IOSAI_CONFIG_FILE="${IOSAI_ROOT}/Config/project.env"
IOSAI_CONFIG_EXAMPLE="${IOSAI_ROOT}/Config/project.env.example"
# Reset any ambient attempt to choose another cache owner. Immutable candidate
# gates may set this again only after validating their explicit publishing-root
# argument; ordinary callers always key caches to their own physical checkout.
IOSAI_CACHE_OWNER_PATH=""
IOSAI_PLATFORM_PROFILE=""

# Every key the template understands, and the ONLY keys its parser accepts.
# Used by configure-project.sh to write a complete file, by verify-template.sh
# to assert the example documents all of them, and by env_file_validate to
# reject anything else. A key here must also have an assignment branch in
# env_file_load.
IOSAI_CONFIG_KEYS="WATCH_APP_MODE COMPANION_PROFILE APP_PLATFORM PROJECT_NAME BUNDLE_IDENTIFIER PROJECT_PATH WORKSPACE_PATH \
SCHEME APP_TARGET CONFIGURATION_DEBUG CONFIGURATION_RELEASE BUILD_DESTINATION \
TEST_DESTINATION SIMULATOR_MODE SIMULATOR_DEVICE_TYPE SIMULATOR_RUNTIME \
DERIVED_DATA_PATH FAST_TEST_ARGUMENTS \
MILESTONE_TEST_ARGUMENTS RELEASE_TEST_ARGUMENTS DISTRIBUTION_CHANNEL \
SUPPORT_SITE_URL SUPPORT_EMAIL DEVELOPER_NAME \
TEMPLATE_REPOSITORY ENABLE_SWIFTLINT ENABLE_SWIFTFORMAT ENABLE_SHELLCHECK"

# The published legal and support site. Apple requires a working privacy policy
# URL and support URL for every App Store app, and Terms and Privacy links inside
# any app selling a subscription, so these are configuration rather than prose:
# Web/ is checked against them, and the Cloudflare Pages project name is the first
# label of SUPPORT_SITE_URL's host, which is what keeps the configured URL and the
# deployed URL from drifting apart.
#
# The canonical page paths — /privacy, /terms, /support — are fixed by this
# template rather than configured. A per-product path set would multiply what every
# gate, prompt, and audit has to know and buys nothing, since the site is generated
# from the same scaffold every time. verify-site.sh names the files directly; there
# is deliberately no constant here holding a list nothing reads.

# Apple's Licensed Application End User License Agreement. Every product ships
# under it — the template chooses no other licence — so the /terms page states it
# controls and links here, and verify-site.sh checks that the link survived.
IOSAI_APPLE_EULA_URL="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

# The deliberately small solo-workflow lifecycle. Tooling validates tokens and
# dependencies, but does not impose a transition-ranking engine.
IOSAI_MILESTONE_STATUSES="PLANNED IN_PROGRESS REVIEW DONE BLOCKED"

# Milestone ID grammar. Deliberately permissive: accepts M00 and M03 (the
# zero-padded form this template's examples use) as well as M1, M1B and
# M7.9H.4 (forms already in use in the sibling projects).
IOSAI_MILESTONE_ID_PATTERN='^M[0-9]+[0-9A-Za-z.]*$'

# Locale grammar for the localization branches and worktrees. Lowercase only:
# the branch, the worktree directory, and the site route are all filesystem
# paths, and macOS usually cannot tell `pt-BR` from `pt-br`. The application's
# own resources keep the identifier's own casing; only these paths are lowercased.
IOSAI_LOCALE_PATTERN='^[a-z]{2,3}(-[a-z0-9]{2,8})*$'

# ---------------------------------------------------------------------------
# Logging. Colour only on a TTY, and never when NO_COLOR is set.
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    _C_RESET="$(printf '\033[0m')"
    _C_RED="$(printf '\033[31m')"
    _C_GREEN="$(printf '\033[32m')"
    _C_YELLOW="$(printf '\033[33m')"
    _C_BLUE="$(printf '\033[34m')"
    _C_BOLD="$(printf '\033[1m')"
else
    _C_RESET=""; _C_RED=""; _C_GREEN=""; _C_YELLOW=""; _C_BLUE=""; _C_BOLD=""
fi

log_info()  { printf '%s\n' "$*"; }
log_step()  { printf '%s==>%s %s\n' "${_C_BLUE}${_C_BOLD}" "$_C_RESET" "$*"; }
log_ok()    { printf '%s  ok%s    %s\n' "$_C_GREEN" "$_C_RESET" "$*"; }
log_warn()  { printf '%s  warn%s  %s\n' "$_C_YELLOW" "$_C_RESET" "$*" >&2; }
log_error() { printf '%s  FAIL%s  %s\n' "$_C_RED" "$_C_RESET" "$*" >&2; }

# A check that was not run. Never counts as a pass.
log_skip()  { printf '  skip   %s\n' "$*"; }

# die <exit-code> <message...>
die() {
    local code="$1"
    shift
    log_error "$@"
    exit "$code"
}

# hint <message...> — an actionable next step printed after a failure message.
hint() { printf '         %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Small utilities
# ---------------------------------------------------------------------------

# shell_quote <string> — render a single argument so it can be pasted back
# into a shell verbatim. Used to record exact commands as evidence.
shell_quote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

# render_command <arg...> — the whole command line, safely quoted.
render_command() {
    local out="" a
    for a in "$@"; do
        out="${out} $(shell_quote "$a")"
    done
    printf '%s\n' "${out# }"
}

# abs_path <path> — absolute form of a path, resolved against IOSAI_ROOT when
# relative. Does not require the path to exist.
abs_path() {
    local p="$1"
    case "$p" in
        /*) printf '%s\n' "$p" ;;
        *)  printf '%s\n' "${IOSAI_ROOT}/${p}" ;;
    esac
}

# physical_path <existing-path> — absolute, symlink-resolved path. Fails if the
# path does not exist.
physical_path() {
    local p
    p="$(abs_path "$1")"
    if [ -d "$p" ]; then
        (cd -- "$p" && pwd -P)
    elif [ -e "$p" ]; then
        local d b
        d="$(dirname -- "$p")"
        b="$(basename -- "$p")"
        printf '%s/%s\n' "$(cd -- "$d" && pwd -P)" "$b"
    else
        return 1
    fi
}

# sanitize_component <string> — reduce to [A-Za-z0-9._-] so the value is safe
# as a single path component even when the source contains spaces.
sanitize_component() {
    printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/-/g'
}

utc_stamp() { date -u +%Y%m%dT%H%M%SZ; }

# require_tools <tool...> — preflight gate. Runs before anything mutates state.
# Never installs anything.
require_tools() {
    local tool missing=""
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing="${missing} ${tool}"
        fi
    done
    if [ -n "$missing" ]; then
        log_error "missing required tool(s):${missing}"
        for tool in $missing; do
            case "$tool" in
                xcodebuild|xcrun|xcresulttool)
                    hint "${tool}: install Xcode, then run 'sudo xcode-select --switch /Applications/Xcode.app'" ;;
                jq)     hint "jq: 'brew install jq' (jq also ships with recent macOS at a system path)" ;;
                shasum) hint "shasum: part of a base macOS Perl install; a broken PATH is the usual cause" ;;
                swiftlint)   hint "swiftlint: 'brew install swiftlint', or set ENABLE_SWIFTLINT=\"false\"" ;;
                swiftformat) hint "swiftformat: 'brew install swiftformat', or set ENABLE_SWIFTFORMAT=\"false\"" ;;
                shellcheck)  hint "shellcheck: 'brew install shellcheck', or set ENABLE_SHELLCHECK=\"false\"" ;;
                *)      hint "${tool}: not found on PATH" ;;
            esac
        done
        exit "$EX_UNAVAILABLE"
    fi
}

# ---------------------------------------------------------------------------
# Bounded parallel execution.
#
# Independent work may run concurrently, but only at a width this machine can
# actually carry. Everything here is a performance knob and nothing else: the
# same defect must produce the same verdict at one worker or at eight, so no
# scheduling decision may reach a result. Callers get that property by counting
# and reporting per item, never per worker.
# ---------------------------------------------------------------------------

# The automatic width is capped rather than scaled without limit. Each worker
# runs its own tree of short-lived processes against its own throwaway
# repository, so past a point more workers buy contention instead of throughput,
# and an unbounded default would make a large machine thrash on memory. An
# explicit request may go higher; IOSAI_JOBS_LIMIT is only there so a mistyped
# width cannot fork-bomb the machine.
IOSAI_JOBS_AUTO_MAX=8
IOSAI_JOBS_LIMIT=64

# iosai_cpu_count — logical CPUs, or 1 when the machine will not say.
#
# Tools are resolved with `command -v`, never an absolute path. A missing tool
# degrades to serial execution instead of failing: refusing to run because a CPU
# could not be counted would turn a performance knob into a prerequisite.
iosai_cpu_count() {
    local n=""
    if command -v sysctl >/dev/null 2>&1; then
        n="$(sysctl -n hw.logicalcpu 2>/dev/null || true)"
    fi
    if ! printf '%s' "$n" | grep -Eq '^[1-9][0-9]*$'; then
        if command -v getconf >/dev/null 2>&1; then
            n="$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)"
        fi
    fi
    printf '%s' "$n" | grep -Eq '^[1-9][0-9]*$' || n=1
    printf '%s\n' "$n"
}

# iosai_memory_gib — physical memory in whole GiB, or 0 when unavailable.
iosai_memory_gib() {
    local bytes=""
    if command -v sysctl >/dev/null 2>&1; then
        bytes="$(sysctl -n hw.memsize 2>/dev/null || true)"
    fi
    printf '%s' "$bytes" | grep -Eq '^[1-9][0-9]*$' || bytes=0
    printf '%s\n' "$((bytes / 1073741824))"
}

# iosai_resolve_jobs <requested> — echo a usable worker count, or refuse.
#
# "auto" (and an empty request) inspects the machine. Half the logical CPUs
# leaves room for the subprocesses each worker spawns; the memory term is what
# keeps a small Mac from swapping, and a machine that will not report its memory
# lets the CPU term decide alone. A 1 is a legitimate answer on a small machine,
# and forcing 1 is how a developer reproduces a failure serially.
#
# Anything that is neither "auto" nor a plain positive integer is refused rather
# than coerced: silently reading "2.5" or "" as some default would hide a broken
# invocation, and this value decides how the suite runs.
iosai_resolve_jobs() {
    local requested="${1:-auto}" cpu mem jobs
    case "$requested" in
        ""|auto)
            cpu="$(iosai_cpu_count)"
            mem="$(iosai_memory_gib)"
            jobs=$((cpu / 2))
            if [ "$mem" -gt 0 ] && [ $((mem / 4)) -lt "$jobs" ]; then
                jobs=$((mem / 4))
            fi
            [ "$jobs" -ge 1 ] || jobs=1
            [ "$jobs" -le "$IOSAI_JOBS_AUTO_MAX" ] || jobs="$IOSAI_JOBS_AUTO_MAX"
            printf '%s\n' "$jobs"
            return 0
            ;;
    esac
    if ! printf '%s' "$requested" | grep -Eq '^[1-9][0-9]*$'; then
        log_error "invalid worker count: ${requested}"
        hint "use 'auto', or a whole number from 1 to ${IOSAI_JOBS_LIMIT}"
        hint "1 forces serial execution"
        exit "$EX_USAGE"
    fi
    if [ "$requested" -gt "$IOSAI_JOBS_LIMIT" ]; then
        log_error "worker count above the permitted maximum: ${requested}"
        hint "the maximum is ${IOSAI_JOBS_LIMIT}; a larger value is a typo, not a machine"
        exit "$EX_USAGE"
    fi
    printf '%s\n' "$requested"
}

# iosai_run_jobs <jobs> <command...> — run <command> <item> once for every item
# read from stdin, one item per line, with at most <jobs> running at a time.
# Returns the pool's status.
#
# `xargs -P` is the whole scheduler, deliberately. The compatibility contract at
# the top of this file pins macOS bash 3.2, which has no `wait -n`, so matching
# this dynamic balancing by hand would mean a PID table plus a liveness poll —
# more code, and more of it load-bearing. `-n1` together with `-I{}` is what
# guarantees exactly one item per invocation: a batched invocation would hand a
# command an argument it never expected to receive.
iosai_run_jobs() {
    local jobs="${1:-}"
    shift || true
    printf '%s' "$jobs" | grep -Eq '^[1-9][0-9]*$' \
        || die "$EX_USAGE" "iosai_run_jobs needs a positive worker count"
    [ $# -gt 0 ] || die "$EX_USAGE" "iosai_run_jobs needs a command to run"
    require_tools xargs
    xargs -n1 -P"$jobs" -I{} "$@" {}
}

# ---------------------------------------------------------------------------
# Configuration file handling.
#
# Config/project.env is NOT sourced, NOT eval'd, and NOT allowed to introduce a
# name of its own choosing. A strict line parser validates the structure, then
# an explicit dispatcher assigns the documented keys and nothing else. The same
# parser backs verify-template.sh's "the example configuration is structurally
# valid" check.
#
# Accepted lines: blank, optionally-indented `#` comment, or
#   KEY="value"
# at column 0, where KEY is one of IOSAI_CONFIG_KEYS — exactly, case included —
# appears at most once in the file, and value contains no double quote, no `$`
# and no backtick. Values are literal: shell expansion is deliberately
# impossible. Relative paths resolve against the repository root.
#
# Three properties this format is required to have, because the gates depend on
# them:
#
#   1. Loading a configuration cannot execute code. There is no eval and no
#      indirect assignment, so the only names that can be written are the ones
#      spelled out in env_file_load's case statement.
#   2. A configuration cannot reach the parser's or a gate's internals. Exit
#      codes, IOSAI_* state, and bash's own control variables (BASH_ENV, ENV,
#      PATH, IFS …) are rejected by name, independently of the allowlist.
#   3. Values are not exported. xcodebuild treats environment variables as
#      build-setting overrides, so exporting PROJECT_NAME or DERIVED_DATA_PATH into
#      a build would silently change it. Every script loads the configuration
#      itself instead of inheriting it.
# ---------------------------------------------------------------------------

# Names that must never be accepted, whatever the allowlist says. Checked
# separately so the failure message names the actual hazard.
IOSAI_CONFIG_FORBIDDEN_KEYS="BASH_ENV ENV BASHOPTS SHELLOPTS CDPATH GLOBIGNORE \
IFS PATH PS4 PROMPT_COMMAND SHELL BASH_XTRACEFD TMPDIR HOME"

# iosai_config_key_known <key>
iosai_config_key_known() {
    local key="$1" known
    for known in $IOSAI_CONFIG_KEYS; do
        [ "$key" = "$known" ] && return 0
    done
    return 1
}

# iosai_config_key_forbidden <key> — an environment-control or internal name.
iosai_config_key_forbidden() {
    local key="$1" bad
    for bad in $IOSAI_CONFIG_FORBIDDEN_KEYS; do
        [ "$key" = "$bad" ] && return 0
    done
    case "$key" in
        EX_*|IOSAI_*|BASH_*|LD_*|DYLD_*|GIT_*|LC_*|LANG|FUNCNAME) return 0 ;;
    esac
    return 1
}

# env_file_validate <file> — structural and key validation. Prints every
# problem with its file and line, and never loads anything.
env_file_validate() {
    local file="$1"
    [ -f "$file" ] || die "$EX_NOINPUT" "configuration file not found: ${file}"

    local lineno=0 problems=0 line stripped key seen=""
    while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        # Tolerate CRLF and trailing whitespace.
        stripped="$(printf '%s' "$line" | tr -d '\r' | sed 's/[[:space:]]*$//')"
        case "$stripped" in "") continue ;; esac
        if printf '%s' "$stripped" | grep -Eq '^[[:space:]]*#'; then
            continue
        fi
        if ! printf '%s' "$stripped" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*="[^"$`]*"$'; then
            log_error "${file}:${lineno}: not a valid KEY=\"value\" assignment"
            hint "the assignment value is redacted; diagnostics report only path, line, and rule"
            hint "values must be double-quoted literals without \" \$ or \` characters"
            problems=$((problems + 1))
            continue
        fi

        key="${stripped%%=*}"

        if iosai_config_key_forbidden "$key"; then
            log_error "${file}:${lineno}: refusing the environment-control or internal name '${key}'"
            hint "configuration may not reach bash's own behaviour, this tooling's"
            hint "internals, or a gate's exit codes. remove the line."
            problems=$((problems + 1))
            continue
        fi

        if ! iosai_config_key_known "$key"; then
            log_error "${file}:${lineno}: unknown configuration key '${key}'"
            hint "only the documented keys are accepted; see Config/project.env.example"
            problems=$((problems + 1))
            continue
        fi

        if line_in_list "$key" "$seen"; then
            log_error "${file}:${lineno}: duplicate key '${key}'"
            hint "a key may appear once; two values for one key is ambiguous, not a merge"
            problems=$((problems + 1))
            continue
        fi
        seen="${seen}${key}
"
    done < "$file"

    if [ "$problems" -gt 0 ]; then
        return "$EX_VERIFY"
    fi
    return 0
}

# env_file_load <file> — validate, then assign the documented keys.
#
# The case statement below is the complete list of names this function can
# write. Adding a key means adding it to IOSAI_CONFIG_KEYS, to
# Config/project.env.example, and here — verify-template.sh checks the first
# two agree, and the dispatcher's default branch catches the third.
env_file_load() {
    local file="$1"
    env_file_validate "$file" || exit "$EX_VERIFY"

    local line stripped key value
    while IFS= read -r line || [ -n "$line" ]; do
        stripped="$(printf '%s' "$line" | tr -d '\r' | sed 's/[[:space:]]*$//')"
        case "$stripped" in "") continue ;; esac
        if printf '%s' "$stripped" | grep -Eq '^[[:space:]]*#'; then
            continue
        fi
        key="${stripped%%=*}"
        value="${stripped#*=}"
        value="${value#\"}"
        value="${value%\"}"
        case "$key" in
            WATCH_APP_MODE)                   WATCH_APP_MODE="$value" ;;
            COMPANION_PROFILE)                COMPANION_PROFILE="$value" ;;
            APP_PLATFORM)                     APP_PLATFORM="$value" ;;
            PROJECT_NAME)                     PROJECT_NAME="$value" ;;
            BUNDLE_IDENTIFIER)                BUNDLE_IDENTIFIER="$value" ;;
            PROJECT_PATH)                     PROJECT_PATH="$value" ;;
            WORKSPACE_PATH)                   WORKSPACE_PATH="$value" ;;
            SCHEME)                           SCHEME="$value" ;;
            APP_TARGET)                       APP_TARGET="$value" ;;
            CONFIGURATION_DEBUG)              CONFIGURATION_DEBUG="$value" ;;
            CONFIGURATION_RELEASE)            CONFIGURATION_RELEASE="$value" ;;
            BUILD_DESTINATION)                BUILD_DESTINATION="$value" ;;
            TEST_DESTINATION)                 TEST_DESTINATION="$value" ;;
            SIMULATOR_MODE)                   SIMULATOR_MODE="$value" ;;
            SIMULATOR_DEVICE_TYPE)            SIMULATOR_DEVICE_TYPE="$value" ;;
            SIMULATOR_RUNTIME)                SIMULATOR_RUNTIME="$value" ;;
            FAST_TEST_ARGUMENTS)              FAST_TEST_ARGUMENTS="$value" ;;
            MILESTONE_TEST_ARGUMENTS)         MILESTONE_TEST_ARGUMENTS="$value" ;;
            RELEASE_TEST_ARGUMENTS)           RELEASE_TEST_ARGUMENTS="$value" ;;
            DERIVED_DATA_PATH)                DERIVED_DATA_PATH="$value" ;;
            DISTRIBUTION_CHANNEL)             DISTRIBUTION_CHANNEL="$value" ;;
            SUPPORT_SITE_URL)                 SUPPORT_SITE_URL="$value" ;;
            SUPPORT_EMAIL)                    SUPPORT_EMAIL="$value" ;;
            DEVELOPER_NAME)                   DEVELOPER_NAME="$value" ;;
            TEMPLATE_REPOSITORY)              TEMPLATE_REPOSITORY="$value" ;;
            ENABLE_SWIFTLINT)                 ENABLE_SWIFTLINT="$value" ;;
            ENABLE_SWIFTFORMAT)               ENABLE_SWIFTFORMAT="$value" ;;
            ENABLE_SHELLCHECK)                ENABLE_SHELLCHECK="$value" ;;
            *)
                die "$EX_SOFTWARE" \
                    "internal error: '${key}' passed validation but has no assignment branch in env_file_load" ;;
        esac
    done < "$file"
}

# validate_optional_tool_flags — optional checks must be explicitly on or off.
#
# Treating every value except "true" as disabled made a typo such as "ture" look
# exactly like an intentional opt-out. Validate these values on every configuration
# load, before repository mode is resolved, so template and product repositories fail
# closed in the same way. An absent key keeps the documented backwards-compatible
# default of false; an explicitly empty or misspelled value is invalid.
validate_optional_tool_flags() {
    local key value
    for key in ENABLE_SWIFTLINT ENABLE_SWIFTFORMAT ENABLE_SHELLCHECK; do
        case "$key" in
            ENABLE_SWIFTLINT)   value="${ENABLE_SWIFTLINT-false}" ;;
            ENABLE_SWIFTFORMAT) value="${ENABLE_SWIFTFORMAT-false}" ;;
            ENABLE_SHELLCHECK)  value="${ENABLE_SHELLCHECK-false}" ;;
        esac
        case "$value" in
            true|false) : ;;
            *)
                log_error "Config/project.env: ${key} must be \"true\" or \"false\", found: ${value}"
                hint "fix the spelling instead of silently disabling the optional check"
                exit "$EX_VERIFY"
                ;;
        esac
    done
}

# clear_project_config_environment — configuration comes from the committed
# file, never from the caller's shell. In particular, an omitted key must not be
# supplied by an exported variable left over from another repository.
clear_project_config_environment() {
    local key
    for key in $IOSAI_CONFIG_KEYS; do
        unset "$key"
    done
    unset IOSAI_REPO_MODE IOSAI_SELFTEST
    return 0
}

# env_file_keys <file> — the keys present in a config file, one per line.
env_file_keys() {
    grep -E '^[A-Za-z_][A-Za-z0-9_]*="' "$1" 2>/dev/null | sed 's/=.*$//' || true
}

# load_project_config [--required]
# Loads Config/project.env when it exists. With --required, a missing file is
# a hard failure carrying the exact command needed to create it.
load_project_config() {
    local required="no"
    [ "${1:-}" = "--required" ] && required="yes"

    clear_project_config_environment

    if [ -f "$IOSAI_CONFIG_FILE" ]; then
        env_file_load "$IOSAI_CONFIG_FILE"
        IOSAI_CONFIG_PRESENT=1
        validate_optional_tool_flags
        platform_config_validate
        simulator_config_validate
        # Cache configuration is a filesystem trust boundary, not merely a
        # string consumed later by xcodebuild. Reject it on every config load so
        # even static/status commands fail closed on an unsafe location.
        derived_data_path >/dev/null

        # Site values follow the same rule, and for the same reason: on every
        # load, in both repository modes. Putting this in the product-mode branch
        # instead meant the universal template — and any product before M00 — could
        # carry SUPPORT_SITE_URL="http://..." with nothing saying so, and the first
        # complaint came from a later check that had noticed something else. A
        # malformed value is a typo whatever the repository is.
        #
        # Only a value that is SET is checked. Empty is how every product starts
        # and stays legal — see validate_configuration_semantics for why nothing
        # automated ever demands these keys be filled in.
        if [ -n "${SUPPORT_SITE_URL:-}" ]; then
            validate_support_site_url "$SUPPORT_SITE_URL" || exit "$EX_VERIFY"
        fi
        if [ -n "${SUPPORT_EMAIL:-}" ]; then
            validate_support_email "$SUPPORT_EMAIL" || exit "$EX_VERIFY"
        fi
    else
        IOSAI_CONFIG_PRESENT=0
        if [ "$required" = "yes" ]; then
            log_error "no configuration at Config/project.env"
            hint "create it with:"
            hint "  ./Scripts/configure-project.sh --project App/YourApp.xcodeproj --scheme YourApp"
            hint "see Config/project.env.example for every supported key"
            exit "$EX_UNAVAILABLE"
        fi
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Repository mode: template or product.
#
# The universal template repository has no application target, so it carries
# TEMPLATE_REPOSITORY="true" and its integration gate runs repository-level checks
# only. Every product repository defaults to product mode. The combination of
# TEMPLATE_REPOSITORY="true" with a configured project is a configuration error
# — the mode is never chosen silently.
# ---------------------------------------------------------------------------
resolve_repo_mode() {
    # `${VAR-default}`, not `${VAR:-default}`: an EMPTY value must reach the
    # true/false validation below rather than silently taking the default.
    # `TEMPLATE_REPOSITORY=""` used to resolve to product mode without a word,
    # while `"TRUE"` and `"ture"` were rejected — the same class of typo, two
    # different outcomes. Only an ABSENT key defaults.
    local flag="${TEMPLATE_REPOSITORY-false}"
    local container="no"
    if [ -n "${PROJECT_PATH:-}" ] || [ -n "${WORKSPACE_PATH:-}" ]; then
        container="yes"
    fi

    case "$flag" in
        true|false) : ;;
        *)
            log_error "TEMPLATE_REPOSITORY must be \"true\" or \"false\", found: ${flag}"
            hint "edit Config/project.env"
            exit "$EX_VERIFY"
            ;;
    esac

    if [ "$flag" = "true" ] && [ "$container" = "yes" ]; then
        log_error "contradictory configuration: TEMPLATE_REPOSITORY=\"true\" with an Xcode project configured"
        hint "PROJECT_PATH=${PROJECT_PATH:-} WORKSPACE_PATH=${WORKSPACE_PATH:-}"
        hint "a repository is either the universal template or a product, never both"
        hint "for a product repository set TEMPLATE_REPOSITORY=\"false\" in Config/project.env"
        hint "(./Scripts/configure-project.sh does this automatically)"
        exit "$EX_VERIFY"
    fi

    if [ "$flag" = "true" ]; then
        printf 'template\n'
    else
        validate_configuration_semantics
        printf 'product\n'
    fi
}

# validate_configuration_semantics — names alone do not make two build
# configurations different. A release gate that builds Debug twice and labels
# the second invocation "Release" has not exercised shipping settings.
validate_configuration_semantics() {
    local debug="${CONFIGURATION_DEBUG:-Debug}"
    local release="${CONFIGURATION_RELEASE:-Release}"
    if [ "$debug" = "$release" ]; then
        log_error "Debug and Release configurations must be distinct"
        hint "CONFIGURATION_DEBUG=${debug}"
        hint "CONFIGURATION_RELEASE=${release}"
        hint "the release build must use a shipping configuration, not Debug twice"
        exit "$EX_VERIFY"
    fi

    # Site values are NOT checked here. A malformed one is refused on every
    # configuration load, in both repository modes — see load_project_config.
    #
    # An ABSENT one is not checked anywhere, by design. Requiring the site keys in
    # product mode would fail every gate between M00, which flips
    # TEMPLATE_REPOSITORY to "false", and the Legal and Support milestone that
    # fills them in. Requiring them of a release candidate instead — which was
    # tried — punished a product that hosts its policy on a company domain and
    # never uses Web/ at all, and duplicated REL-503 and REL-1004, which a person
    # must evidence and cannot mark inapplicable.
    return 0
}

# ---------------------------------------------------------------------------
# Distribution channel.
#
# Release requirements are generated from this, so that an internal-only product
# is never asked to attest to App Store deliverables it does not have, and an
# App Store product can never quietly skip them. The default is the strict one.
# ---------------------------------------------------------------------------
resolve_distribution_channel() {
    local channel="${DISTRIBUTION_CHANNEL:-app-store}"
    case "$channel" in
        app-store|internal) printf '%s\n' "$channel" ;;
        *)
            log_error "DISTRIBUTION_CHANNEL must be \"app-store\" or \"internal\", found: ${channel}"
            hint "edit Config/project.env, or re-run ./Scripts/configure-project.sh --distribution"
            exit "$EX_VERIFY"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# The published legal and support site.
#
# Three values describe it, and each is validated where a bad one is cheapest to
# fix — at configuration time — rather than at deploy time, when the failure
# arrives from Cloudflare in someone else's vocabulary.
# ---------------------------------------------------------------------------

# validate_support_site_url <value> — an https origin and nothing else.
#
# A path, query, or fragment would make the derived /privacy, /terms and /support
# URLs wrong in a way nothing downstream could detect, and a trailing slash would
# produce "https://x.pages.dev//privacy". http:// is refused outright: App
# Transport Security blocks it, and a privacy policy delivered over cleartext is
# not a privacy policy.
#
# The host's FIRST LABEL becomes the Cloudflare Pages project name, and Cloudflare
# accepts only alphanumerics and dashes there. Refusing it here is the difference
# between a configuration error and a deploy that fails after the developer has
# already written the pages.
validate_support_site_url() {
    local value="$1" host label
    case "$value" in
        https://*) : ;;
        http://*)
            log_error "SUPPORT_SITE_URL must use https, found: ${value}"
            hint "App Transport Security blocks cleartext, and the App Store"
            hint "privacy policy and support URLs are fetched over https"
            return "$EX_USAGE" ;;
        *)
            log_error "SUPPORT_SITE_URL must be an https URL, found: ${value}"
            hint 'example: SUPPORT_SITE_URL="https://yourapp.pages.dev"'
            return "$EX_USAGE" ;;
    esac

    host="${value#https://}"
    case "$host" in
        */*)
            log_error "SUPPORT_SITE_URL must be an origin with no path or trailing slash, found: ${value}"
            hint "the /privacy, /terms and /support paths are appended by this template"
            return "$EX_USAGE" ;;
        *\?*|*\#*)
            log_error "SUPPORT_SITE_URL must carry no query or fragment, found: ${value}"
            return "$EX_USAGE" ;;
        "")
            log_error "SUPPORT_SITE_URL has no host: ${value}"
            return "$EX_USAGE" ;;
    esac

    if ! printf '%s' "$host" | grep -Eq '^[a-z0-9][a-z0-9.-]*[a-z0-9]$'; then
        log_error "SUPPORT_SITE_URL host is not a plain lowercase hostname: ${host}"
        hint "example: yourapp.pages.dev"
        return "$EX_USAGE"
    fi

    label="${host%%.*}"
    if ! printf '%s' "$label" | grep -Eq '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
        log_error "SUPPORT_SITE_URL cannot name a Cloudflare Pages project: ${label}"
        hint "the first host label becomes the Pages project name, and Cloudflare"
        hint "accepts alphanumerics and dashes there only"
        return "$EX_USAGE"
    fi
    return 0
}

# site_project_name — the Cloudflare Pages project this site deploys to.
#
# Derived, never configured. A second key holding the same fact is a second thing
# to keep in sync, and the first time it drifted the site would deploy to a
# project whose URL nothing in the repository names.
site_project_name() {
    local host="${SUPPORT_SITE_URL#https://}"
    printf '%s\n' "${host%%.*}"
}

# validate_support_email <value> — one address, no display name, no list.
validate_support_email() {
    local value="$1"
    if ! printf '%s' "$value" | grep -Eq '^[^[:space:]@,;<>]+@[^[:space:]@,;<>]+\.[A-Za-z]{2,}$'; then
        log_error "SUPPORT_EMAIL must be a single plain address, found: ${value}"
        hint 'example: SUPPORT_EMAIL="you@example.com"'
        hint "no display name, no angle brackets, and no second address"
        return "$EX_USAGE"
    fi
    return 0
}

# assert_single_project_container — at most one project container is configured.
#
# Extracted from require_project_configured so the cheap gate can apply it too.
# `make static` used to pass a configuration with BOTH PROJECT_PATH and
# WORKSPACE_PATH set, which every build gate then refused with exit 64 — the exact
# late-discovery pattern the rest of verify-static.sh's product block exists to
# prevent. Deliberately says nothing about a container being ABSENT: that is only
# an error for a gate that needs something to build.
assert_single_project_container() {
    local container_count=0
    [ -n "${PROJECT_PATH:-}" ] && container_count=$((container_count + 1))
    [ -n "${WORKSPACE_PATH:-}" ] && container_count=$((container_count + 1))
    if [ "$container_count" -gt 1 ]; then
        log_error "PROJECT_PATH and WORKSPACE_PATH are mutually exclusive; both are set"
        hint "PROJECT_PATH=${PROJECT_PATH:-}"
        hint "WORKSPACE_PATH=${WORKSPACE_PATH:-}"
        hint "use --workspace only when a .xcworkspace is what Xcode opens; clear the other"
        exit "$EX_USAGE"
    fi
    return 0
}

# require_project_configured — assert this repository can be built and tested.
require_project_configured() {
    local container_count=0
    [ -n "${PROJECT_PATH:-}" ] && container_count=$((container_count + 1))
    [ -n "${WORKSPACE_PATH:-}" ] && container_count=$((container_count + 1))

    if [ "$container_count" -eq 0 ]; then
        log_error "no Xcode project or workspace is configured"
        hint "this repository is in product mode but has nothing to build."
        hint "add your Xcode project under App/, then run:"
        hint "  ./Scripts/configure-project.sh --project App/YourApp.xcodeproj --scheme YourApp \\"
        hint "      --simulator-device-type '<installed-device-type-id>' \\"
        hint "      --simulator-runtime '<installed-platform-runtime-id>'"
        hint "if this IS the universal template repository, set TEMPLATE_REPOSITORY=\"true\"."
        exit "$EX_UNAVAILABLE"
    fi
    assert_single_project_container

    local configured container
    configured="${PROJECT_PATH:-${WORKSPACE_PATH:-}}"
    validate_project_container_path "$configured"
    container="$(project_container_path)"
    if [ ! -e "$container" ]; then
        die "$EX_NOINPUT" "configured project container does not exist: ${container}"
    fi

    [ -n "${SCHEME:-}" ] || die "$EX_UNAVAILABLE" "SCHEME is not set in Config/project.env"
    if [ "${SIMULATOR_MODE-explicit}" != managed ]; then
        [ -n "${BUILD_DESTINATION:-}" ] || die "$EX_UNAVAILABLE" "BUILD_DESTINATION is not set in Config/project.env"
        [ -n "${TEST_DESTINATION:-}" ] || die "$EX_UNAVAILABLE" "TEST_DESTINATION is not set in Config/project.env"
    fi
    assert_no_symlinked_app_inputs
    assert_no_nested_app_repositories || exit "$EX_VERIFY"
    validate_build_defining_references "$container"
    return 0
}

assert_no_symlinked_app_inputs() {
    local links
    if ! links="$(find "${IOSAI_ROOT}/App" -type l -print 2>&1)"; then
        log_error "could not inspect App/ for symlinked build inputs"
        printf '%s\n' "$links" | sed 's/^/           /' >&2
        exit "$EX_VERIFY"
    fi
    if [ -n "$links" ]; then
        log_error "symlinked application input(s) are outside the candidate trust boundary:"
        printf '%s\n' "$links" | sed "s|^${IOSAI_ROOT}/|           |" >&2
        hint "commit the actual bytes under App/; strict gates do not build through symlinks"
        exit "$EX_VERIFY"
    fi
    return 0
}

# assert_no_nested_app_repositories — App/ holds this repository's own files.
#
# Elsewhere a nested checkout is somebody else's working tree and the scans skip it
# (see repo_files). Under App/ the same skip was a hole: Xcode creates a Git
# repository when a new project is saved into App/ with "Create Git repository" left
# on, every application source beneath it dropped out of the credential and
# conflict-marker scans, and `make static` reported them clean. Nothing later could
# verify them either: a commit records only a pointer to the inner repository (a
# gitlink), and a candidate snapshot never contains its files.
#
# So both shapes are refused: a `.git` file or directory beneath App/, and a gitlink
# in the index — the form the problem takes inside a candidate snapshot, where the
# inner `.git` is absent and only an empty directory remains. The directories
# repo_files prunes are pruned here too: they are ignored build output, editor state,
# or vendored trees, never committed, and a SwiftPM `.build/checkouts` clone is not
# the developer's repository.
#
# Prints every problem and returns 1; returns 0 when App/ is plain. A question that
# cannot be answered is a refusal, never a clean result.
assert_no_nested_app_repositories() {
    local app="${IOSAI_ROOT}/App" listing stage gitlinks problems=0
    [ -d "$app" ] || return 0

    if ! listing="$(find "$app" \
            \( -name 'DerivedData' -o -name 'build' -o -name '*.xcresult' \
               -o -name '*.xcarchive' -o -name 'node_modules' -o -name '.build' \
               -o -name '.swiftpm' -o -name 'xcuserdata' -o -name '.idea' -o -name 'out' \
               -o -name 'Pods' -o -name 'Carthage' \) -prune -o \
            -name '.git' -prune -print 2>&1)"; then
        log_error "could not inspect App/ for nested Git repositories; refusing to assume there are none"
        printf '%s\n' "$listing" | sed 's/^/           /' >&2
        return 1
    fi
    if [ -n "$listing" ]; then
        log_error "App/ contains another Git repository, so the files beneath it are not this repository's:"
        printf '%s\n' "$listing" | sed -e 's|/\.git$||' -e "s|^${IOSAI_ROOT}/|           |" >&2
        problems=$((problems + 1))
    fi

    if in_git_repo; then
        if ! stage="$(git -C "$IOSAI_ROOT" ls-files --stage -- App 2>&1)"; then
            log_error "could not read the index under App/; refusing to assume it records no submodule"
            printf '%s\n' "$stage" | sed 's/^/           /' >&2
            return 1
        fi
        gitlinks="$(printf '%s\n' "$stage" \
            | awk -F '\t' '{ split($1, meta, " "); if (meta[1] == "160000") print $2 }')"
        if [ -n "$gitlinks" ]; then
            log_error "App/ records a submodule, so a commit holds a pointer instead of its files:"
            printf '%s\n' "$gitlinks" | sed 's/^/           /' >&2
            problems=$((problems + 1))
        fi
    fi

    [ "$problems" -gt 0 ] || return 0
    hint "a commit records only a pointer to another repository, and a candidate snapshot"
    hint "never contains its files, so no gate could verify them. this repository tracks"
    hint "App/ itself: keep the files, delete the inner .git (after 'git rm --cached <path>'"
    hint "if a submodule was recorded), then 'git add' them here. when Xcode offers to"
    hint "create a Git repository for a project saved into App/, decline it."
    return 1
}

# validate_project_container_path <configured-path>
# Product containers are committed build inputs. A portable configuration uses
# a relative path under App/, and its physical path may not cross a symlink.
validate_project_container_path() {
    local configured="${1:-}" absolute physical app_physical
    [ -n "$configured" ] || die "$EX_UNAVAILABLE" "project container path is empty"
    case "$configured" in
        /*) die "$EX_USAGE" "project/workspace path must be repository-relative, found absolute path: ${configured}" ;;
        ../*|*/../*|*/..|..)
            die "$EX_USAGE" "project/workspace path may not escape through '..': ${configured}" ;;
        App/*) : ;;
        *) die "$EX_USAGE" "project/workspace must live under App/: ${configured}" ;;
    esac

    absolute="$(abs_path "$configured")"
    assert_no_symlink_ancestry "$absolute" || exit "$EX_USAGE"
    physical="$(physical_path "$absolute")" \
        || die "$EX_NOINPUT" "configured project container does not exist: ${configured}"
    app_physical="$(physical_path "${IOSAI_ROOT}/App")" \
        || die "$EX_NOINPUT" "App/ directory does not exist"
    case "$physical" in
        "${app_physical}"/*) : ;;
        *) die "$EX_USAGE" "project/workspace resolves outside App/: ${configured} -> ${physical}" ;;
    esac
    return 0
}

# validate_build_defining_references <container>
# Xcode's project formats are broad, but the common external-reference forms are
# explicit. Reject those instead of allowing a committed project to compile
# files from a developer's machine outside the candidate snapshot.
validate_build_defining_references() {
    # A workspace is only an index. Its projects must pass the same boundary as
    # a directly configured project, including nested workspace/group references.
    local -a IOSAI_REFERENCE_STACK=()
    _validate_build_container "$1"
}

_validate_build_container() {
    local container="$1" pbx workspace bad="" scan_rc=0
    local prior
    assert_no_symlink_ancestry "$container" || return "$EX_VERIFY"
    for prior in ${IOSAI_REFERENCE_STACK[@]+"${IOSAI_REFERENCE_STACK[@]}"}; do
        [ "$prior" != "$container" ] || die "$EX_VERIFY" "cyclic workspace reference: ${container}"
    done
    local -a IOSAI_REFERENCE_STACK=( ${IOSAI_REFERENCE_STACK[@]+"${IOSAI_REFERENCE_STACK[@]}"} "$container" )
    case "$container" in
        *.xcodeproj)
            pbx="${container}/project.pbxproj"
            assert_no_symlink_ancestry "$pbx" || return "$EX_VERIFY"
            [ -f "$pbx" ] || die "$EX_VERIFY" "project metadata is missing: ${pbx}"
            bad="$(grep -nE 'sourceTree"?[[:space:]]*=[[:space:]]*"?<absolute>"?|path"?[[:space:]]*=[[:space:]]*"?(/|\.\./|[^";]*/\.\./)' "$pbx" 2>&1)" || scan_rc=$?
            ;;
        *.xcworkspace)
            workspace="${container}/contents.xcworkspacedata"
            assert_no_symlink_ancestry "$workspace" || return "$EX_VERIFY"
            [ -f "$workspace" ] || die "$EX_VERIFY" "workspace metadata is missing: ${workspace}"
            require_tools xmllint
            # Do not fetch external entities or accept an XML document whose
            # interpretation depends on a DTD outside the committed candidate.
            scan_rc=0
            grep -q '<!DOCTYPE' "$workspace" || scan_rc=$?
            [ "$scan_rc" -eq 1 ] || die "$EX_VERIFY" "workspace DTD or unreadable metadata: ${workspace}"
            xmllint --nonet --noout "$workspace" 2>/dev/null \
                || die "$EX_VERIFY" "invalid workspace XML: ${workspace}"
            [ "$(xmllint --nonet --xpath 'count(/Workspace)' "$workspace")" = 1 ] \
                || die "$EX_VERIFY" "workspace XML has no Workspace root: ${workspace}"
            _validate_workspace_children "$workspace" /Workspace "$(dirname -- "$container")" "$(dirname -- "$container")" || return "$EX_VERIFY"
            return ;;
    esac
    if [ "$scan_rc" -gt 1 ]; then
        log_error "could not inspect the configured project for external build references"
        printf '%s\n' "$bad" | sed 's/^/           /' >&2
        exit "$EX_VERIFY"
    fi
    if [ -n "$bad" ]; then
        log_error "build-defining reference escapes the candidate repository:"
        printf '%s\n' "$bad" | sed 's/^/           /' >&2
        exit "$EX_VERIFY"
    fi
    return 0
}

# Resolve locations using the XML hierarchy, not a line-based extraction: groups
# change the base directory, and entities/whitespace must have XML semantics.
_validate_workspace_children() {
    local xml="$1" parent="$2" group_root="$3" container_root="$4"
    local count index node kind location path base resolved namespace
    count="$(xmllint --nonet --xpath "count(${parent}/*)" "$xml")" \
        || die "$EX_VERIFY" "could not read workspace children: ${xml}"
    for ((index=1; index<=count; index++)); do
        node="${parent}/*[${index}]"
        kind="$(xmllint --nonet --xpath "name(${node})" "$xml")" \
            || die "$EX_VERIFY" "could not read workspace entry: ${xml}"
        location="$(xmllint --nonet --xpath "string(${node}/@location)" "$xml")" \
            || die "$EX_VERIFY" "could not read workspace location: ${xml}"
        namespace="$(xmllint --nonet --xpath "namespace-uri(${node})" "$xml")" \
            || die "$EX_VERIFY" "could not read workspace namespace: ${xml}"
        [ -z "$namespace" ] || die "$EX_VERIFY" "unsupported workspace namespace: ${xml}"
        case "$kind" in Group|FileRef) : ;; *) die "$EX_VERIFY" "unsupported workspace entry: ${kind}" ;; esac
        case "$location" in
            group:*) base="$group_root"; path="${location#group:}" ;;
            container:*) base="$container_root"; path="${location#container:}" ;;
            *) die "$EX_VERIFY" "unsupported or external workspace location: ${location}" ;;
        esac
        case "$path" in
            /*|..|../*|*/../*|*/..|*$'\n'*|*$'\r'*)
                die "$EX_VERIFY" "workspace reference escapes the candidate repository: ${location}" ;;
        esac
        [ -n "$path" ] || [ "$kind" = Group ] \
            || die "$EX_VERIFY" "empty workspace file reference: ${xml}"
        assert_no_symlink_ancestry "${base}/${path}" || return "$EX_VERIFY"
        resolved="$(physical_path "${base}/${path}")" \
            || die "$EX_VERIFY" "workspace reference is missing: ${location}"
        if [ "$resolved" != "${IOSAI_ROOT}/App" ]; then
            assert_path_inside "$resolved" "${IOSAI_ROOT}/App" \
                || die "$EX_VERIFY" "workspace reference escapes App/: ${location}"
        fi
        if [ "$kind" = Group ]; then
            _validate_workspace_children "$xml" "$node" "$resolved" "$container_root" || return "$EX_VERIFY"
        else
            case "$resolved" in
                *.xcodeproj|*.xcworkspace) _validate_build_container "$resolved" || return "$EX_VERIFY" ;;
                *) [ -f "$resolved" ] || die "$EX_VERIFY" "unsupported workspace reference: ${location}" ;;
            esac
        fi
    done
}

project_container_path() {
    if [ -n "${PROJECT_PATH:-}" ]; then
        abs_path "$PROJECT_PATH"
    else
        abs_path "${WORKSPACE_PATH:-}"
    fi
}

# xcb_container_args — sets the global array XCB_CONTAINER_ARGS.
# Bash functions cannot return arrays, so this assigns rather than prints.
xcb_container_args() {
    if [ -n "${PROJECT_PATH:-}" ]; then
        XCB_CONTAINER_ARGS=(-project "$(abs_path "$PROJECT_PATH")")
    else
        XCB_CONTAINER_ARGS=(-workspace "$(abs_path "${WORKSPACE_PATH:-}")")
    fi
}

# split_args <string> — split a configured *_TEST_ARGUMENTS value on
# whitespace into the global array SPLIT_ARGS. Deliberately simple: arguments
# containing spaces are not supported, which is documented in
# Config/project.env.example.
split_args() {
    SPLIT_ARGS=()
    local raw="${1:-}" token
    [ -n "$raw" ] || return 0
    # Word splitting is the intent here.
    # shellcheck disable=SC2086
    for token in $raw; do
        SPLIT_ARGS[${#SPLIT_ARGS[@]}]="$token"
    done
    return 0
}

# token_in_list <token> <whitespace-separated-list>
token_in_list() {
    local needle="$1" item
    for item in $2; do
        [ "$needle" = "$item" ] && return 0
    done
    return 1
}

# line_in_list <line> <newline-separated-list> — exact whole-line membership.
#
# Pure shell on purpose. `printf '%s\n' "$list" | grep -Fxq "$line"` is a race under
# `set -o pipefail`: grep -q exits at its first match, Bash's printf can still have a
# write pending, takes SIGPIPE, and the pipeline reports 141 — "absent" for a line
# that is present, or an abort under `set -e`. An audit measured 9 such wrong answers
# in 80,000 checks on a loaded machine, and one of them failed `make self-test` with
# "does not document the key" for a key the example file contained. The quoted
# operands are literal inside the `case` pattern, so no glob character in either can
# widen the match. verify-template.sh refuses the racy pipeline form outright.
line_in_list() {
    local line="${1:-}" list="${2:-}"
    [ -n "$line" ] || return 1
    case "
${list}
" in
        *"
${line}
"*) return 0 ;;
    esac
    return 1
}

# ---------------------------------------------------------------------------
# Test scope for the complete-suite gates.
#
# A positive allowlist, not a blocklist. Every argument below changes HOW the
# suite runs; none of them can change WHICH tests run, and none of them can change
# whether a failure counts. xcodebuild has several ways to narrow a run —
# -only-testing, -skip-testing, -testPlan, -only-test-configuration,
# -skip-test-configuration — and a blocklist that misses one turns "the complete
# suite passed" into a false statement. So anything not named here is refused.
# The repetition family is refused separately, by
# assert_test_args_report_failures, because that rule applies to the milestone
# gate as well.
# ---------------------------------------------------------------------------
IOSAI_TEST_ARG_ALLOWLIST="-parallel-testing-enabled -parallel-testing-worker-count \
-maximum-concurrent-test-simulator-destinations -maximum-parallel-testing-workers \
-test-timeouts-enabled -default-test-execution-time-allowance \
-maximum-test-execution-time-allowance -enableCodeCoverage -quiet -verbose \
-disableAutomaticPackageResolution -skipPackageUpdates -skipMacroValidation"

# Allowlisted arguments that consume the token after them.
IOSAI_TEST_ARG_WITH_VALUE="-parallel-testing-enabled -parallel-testing-worker-count \
-maximum-concurrent-test-simulator-destinations -maximum-parallel-testing-workers \
-test-timeouts-enabled -default-test-execution-time-allowance \
-maximum-test-execution-time-allowance -enableCodeCoverage"

# assert_test_args_report_failures <label> <arg...> — refuse xcodebuild's
# test-repetition family, before xcodebuild is invoked.
#
# These do not change WHICH tests run, so they are a different rule from the
# allowlist above and they need their own function: the milestone gate
# deliberately permits a narrowed suite (see validate_milestone_test_scope_contract
# and AI/WORKFLOW.md) but must still refuse these.
#
# What they change is whether a test that failed is ultimately reported as failed.
# An audit reproduced the consequence against real Xcode: with
# MILESTONE_TEST_ARGUMENTS="-retry-tests-on-failure", a test that failed on its
# first execution and passed on the retry produced `total=4 passed=4 failed=0`
# from the .xcresult summary, exit 0, a published VERIFIED_COMMIT, and a report
# stating "PASSED milestone verification". Every strict gate's counts are supposed
# to describe the run, not a rerun of the parts that went wrong.
#
# `-run-tests-until-failure` is here for the same reason plus one more: with
# `-test-iterations` refused it carries no iteration bound, so a passing suite
# would repeat until something eventually failed.
#
# Matched with globs rather than token_in_list because `-test-iterations=2` and
# `-test-iterations:2` are the same argument, and both dash spellings are listed
# for the same reason `--only-testing*` already is.
#
# The same repetition written into a committed test plan ("testRepetitionMode")
# never reaches an argument list at all; verify-static.sh's test repetition scan
# refuses that half of the rule.
assert_test_args_report_failures() {
    local label="$1"
    shift
    local a

    for a in "$@"; do
        case "$a" in
            -retry-tests-on-failure*|--retry-tests-on-failure*|\
            -test-iterations*|--test-iterations*|\
            -run-tests-until-failure*|--run-tests-until-failure*)
                log_error "${label} may not change whether a failing test is reported as a failure: found ${a}"
                hint "a retried or repeated test reports failed=0 for a suite that failed on its"
                hint "first execution, and every gate that records counts reads them from"
                hint "the .xcresult as the account of what ran."
                hint "narrowing WHICH tests run is a separate, contract-bound decision and is"
                hint "still available; this is not."
                hint "remove it from Config/project.env, and fix the unreliable test instead."
                exit "$EX_USAGE" ;;
        esac
    done
    return 0
}

# assert_test_args_allowed <label> <arg...> — refuse anything that could narrow
# the suite, before xcodebuild is invoked.
assert_test_args_allowed() {
    local label="$1"
    shift
    local a expect_value="no" pending=""

    # The repetition family is refused for every gate that reports counts, so it
    # lives in its own function and is applied here too. Safe before the loop: an
    # allowlisted argument's VALUE can never match those patterns, because a value
    # beginning with `-` is already rejected below.
    assert_test_args_report_failures "$label" "$@"

    for a in "$@"; do
        if [ "$expect_value" = "yes" ]; then
            case "$a" in
                -*) log_error "${label}: ${pending} expects a value, found ${a}"
                    exit "$EX_USAGE" ;;
                *)  expect_value="no"; pending=""; continue ;;
            esac
        fi

        case "$a" in
            -only-testing*|--only-testing*|-skip-testing*|--skip-testing*|\
            -testPlan*|--testPlan*|-only-test-configuration*|-skip-test-configuration*|\
            -testLanguage*|-testRegion*)
                log_error "${label} may not change which tests run: found ${a}"
                hint "the integration and release gates run every test in the shared scheme by"
                hint "design — 'only the tests related to this change' is exactly the gap"
                hint "through which a regression crosses the integration boundary."
                hint "remove it from Config/project.env; narrow FAST_TEST_ARGUMENTS instead."
                exit "$EX_USAGE" ;;
        esac

        if token_in_list "$a" "$IOSAI_TEST_ARG_ALLOWLIST"; then
            if token_in_list "$a" "$IOSAI_TEST_ARG_WITH_VALUE"; then
                expect_value="yes"
                pending="$a"
            fi
            continue
        fi

        log_error "${label}: ${a} is not an allowed argument for a complete-suite gate"
        hint "allowed: ${IOSAI_TEST_ARG_ALLOWLIST}"
        hint "this is an allowlist on purpose: an argument nobody vetted may be able"
        hint "to reduce the suite, and then the gate's claim is false."
        exit "$EX_USAGE"
    done

    if [ "$expect_value" = "yes" ]; then
        log_error "${label}: ${pending} expects a value, but the argument list ends"
        exit "$EX_USAGE"
    fi
    return 0
}

# ---------------------------------------------------------------------------
# DerivedData: disposable build cache, deliberately outside the repository.
#
# The default is keyed by a hash of this checkout's absolute path, so parallel
# worktrees never share a cache (which would make concurrent milestone work
# interfere) while a single worktree reuses its cache across runs for fast
# incremental builds. .artifacts/ holds evidence; DerivedData holds nothing
# worth keeping.
# ---------------------------------------------------------------------------
# derived_data_default_path — the computed per-worktree cache, ignoring any
# configured override. This is the ONLY DerivedData path this tooling will ever
# delete, so it is resolved independently of configuration.
derived_data_default_path() {
    require_tools shasum
    local owner name hash
    owner="${IOSAI_CACHE_OWNER_PATH:-$IOSAI_ROOT}"
    name="$(sanitize_component "$(basename -- "$owner")")"
    hash="$(printf '%s' "$owner" | shasum -a 256 | cut -c1-12)"
    printf '%s\n' "/private/tmp/${name}-${hash}/DerivedData"
}

# derived_data_owned_root — the checkout-specific root this repository owns.
# A configured cache may choose a child of this root, but may never turn an
# arbitrary parent into an implicitly trusted cache location.
derived_data_owned_root() {
    dirname -- "$(derived_data_default_path)"
}

# assert_owned_cache_root <root> — the cache root must actually belong to this
# user, not merely sit at the expected path.
#
# The root's parent is /private/tmp, which is world-writable (mode 1777), and the
# root's own name is derived from the checkout path — so any local account can
# compute it and create it before the first build. A real directory somebody else
# made passes both assert_path_inside and assert_no_symlink_ancestry, so neither
# of those establishes the "owned" in "checkout-owned cache". This does, and it
# matters because a substituted build cache reaches the Release build the release
# gate certifies.
#
# A no-op while the root does not exist: creating it is ensure_derived_data_root's
# job, and a path that is only being resolved for reporting (--print, status
# output, a removed worktree's former cache) must not be required to exist.
assert_owned_cache_root() {
    local root="${1:-}"
    [ -n "$root" ] || die "$EX_USAGE" "cache root check requires a path"
    [ -e "$root" ] || [ -L "$root" ] || return 0

    assert_no_symlink_ancestry "$root" || return "$EX_USAGE"
    if [ ! -d "$root" ]; then
        log_error "the build cache root exists but is not a directory: ${root}"
        return "$EX_USAGE"
    fi
    # `-O` is the test a squatter cannot pass: a directory another account created
    # is owned by that account, and nothing this process does changes that.
    if [ ! -O "$root" ]; then
        log_error "the build cache root is not owned by this user: ${root}"
        hint "its parent is world-writable, so another local account can create it first."
        hint "inspect it, then remove or rename it and re-run; a fresh root is made 0700."
        return "$EX_USAGE"
    fi
    # Owned but group- or world-writable is still a shared directory. BSD
    # `find -perm +022` matches when ANY of those write bits is set; this template
    # is macOS-only, so the `+` form is the correct one.
    if [ -n "$(find "$root" -maxdepth 0 -perm +022 -print 2>/dev/null)" ]; then
        log_error "the build cache root is writable by other users: ${root}"
        hint "another account could substitute build products underneath it."
        hint "fix with: chmod go-w $(shell_quote "$root")"
        return "$EX_USAGE"
    fi
    return 0
}

# validate_derived_data_path <absolute-or-configured-path> — accept only a
# strict child of the checkout-specific owned root, with no symlink anywhere in
# either ancestry. This rejects /, home, repository paths, their parents, broad
# temporary roots, and an attacker-controlled symlink without enumerating every
# spelling of those locations.
validate_derived_data_path() {
    local configured="${1:-}" path root
    [ -n "$configured" ] || return 0
    path="$(abs_path "$configured")"
    root="$(derived_data_owned_root)"

    if ! assert_path_inside "$path" "$root"; then
        log_error "DERIVED_DATA_PATH must be a strict child of this checkout's owned cache root"
        hint "owned cache root: ${root}"
        hint "leave DERIVED_DATA_PATH empty to use its DerivedData/ child"
        return "$EX_USAGE"
    fi
    if ! assert_no_symlink_ancestry "$root" || ! assert_no_symlink_ancestry "$path"; then
        log_error "DERIVED_DATA_PATH may not pass through a symlink"
        return "$EX_USAGE"
    fi
    # Checked on every configuration load, so `make static`, the optional
    # pre-commit hook, and the status commands all fail closed on a cache root
    # this user does not own — not just the commands that would build into it.
    if ! assert_owned_cache_root "$root"; then
        log_error "the build cache root is not usable"
        return "$EX_USAGE"
    fi
    return 0
}

# derived_data_path — what the build should use. Both the default and any
# configured override pass through the same ownership and symlink checks.
derived_data_path() {
    local path
    if [ -n "${DERIVED_DATA_PATH:-}" ]; then
        path="$(abs_path "$DERIVED_DATA_PATH")"
    else
        path="$(derived_data_default_path)"
    fi
    if [ -n "${IOSAI_PLATFORM_PROFILE:-}" ]; then path="${path}-${IOSAI_PLATFORM_PROFILE}"; fi
    validate_derived_data_path "$path" || exit "$EX_USAGE"
    printf '%s\n' "$path"
}

# ensure_derived_data_root <build-cache-path> — create the cache the build will
# use, having proved the root it sits under belongs to this user.
#
# The root is created mode 0700 in a single mkdir so there is never a moment when
# a group/world-writable directory exists under a world-writable parent. Callers
# used to run a bare `mkdir -p "$derived"`, which created the root with whatever
# the umask happened to be and asserted nothing about an existing one.
ensure_derived_data_root() {
    local path="${1:-}" root
    [ -n "$path" ] || die "$EX_USAGE" "build cache creation requires a path"
    root="$(derived_data_owned_root)"

    assert_owned_cache_root "$root" || exit "$EX_USAGE"
    if [ ! -d "$root" ]; then
        assert_no_symlink_ancestry "$(dirname -- "$root")" || exit "$EX_USAGE"
        mkdir -m 0700 -p -- "$root" \
            || die "$EX_CANTCREAT" "cannot create the build cache root: ${root}"
    fi
    # Again after creation: the check above ran on a path that did not exist yet.
    assert_owned_cache_root "$root" || exit "$EX_USAGE"

    if [ "$path" != "$root" ] && ! assert_path_inside "$path" "$root"; then
        die "$EX_USAGE" "build cache escapes its owned root: ${path}"
    fi
    mkdir -p -- "$path" || die "$EX_CANTCREAT" "cannot create the build cache: ${path}"
    assert_no_symlink_ancestry "$path" || exit "$EX_USAGE"
    return 0
}

# iosai_canonical_roots — the only directories anything here may delete inside.
# Both are owned by this checkout: one holds its evidence, the other its cache.
# A configured path is never a root, because configuration is not ownership.
iosai_canonical_roots() {
    printf '%s\n' "$IOSAI_ARTIFACTS_DIR"
    printf '%s\n' "$(derived_data_owned_root)"
}

# ---------------------------------------------------------------------------
# Artifacts
# ---------------------------------------------------------------------------

# ensure_artifact_directory <absolute-directory> — create an output directory
# only beneath this checkout's artifact root. Every existing component is
# checked both before and after mkdir so a symlink is never accepted as a
# directory merely because `mkdir -p` follows it.
ensure_artifact_directory() {
    local dir="${1:-}" root="$IOSAI_ARTIFACTS_DIR" dir_phys root_phys
    if [ "$dir" != "$root" ] && ! assert_path_inside "$dir" "$root"; then
        die "$EX_USAGE" "artifact directory escapes .artifacts/: ${dir}"
    fi
    assert_no_symlink_ancestry "$root" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$dir" || exit "$EX_USAGE"
    mkdir -p -- "$dir"
    assert_no_symlink_ancestry "$root" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$dir" || exit "$EX_USAGE"
    [ -d "$root" ] && [ -d "$dir" ] \
        || die "$EX_USAGE" "artifact output is not a real directory: ${dir}"
    root_phys="$(physical_path "$root")" \
        || die "$EX_USAGE" "cannot resolve artifact root: ${root}"
    dir_phys="$(physical_path "$dir")" \
        || die "$EX_USAGE" "cannot resolve artifact directory: ${dir}"
    if [ "$dir_phys" != "$root_phys" ]; then
        case "$dir_phys" in
            "${root_phys}"/*) : ;;
            *) die "$EX_USAGE" "artifact directory resolves outside .artifacts/: ${dir}" ;;
        esac
    fi
}

# atomic_replace_file_no_follow <temporary> <target> <allowed-root> — publish a
# completed same-directory regular file with rename(2). Perl's rename
# maps directly to the filesystem operation: unlike a convenience `mv`, it does
# not reinterpret a destination symlink to a directory as a directory operand.
# An existing symlink is refused; one raced into place is replaced, never
# followed. Readers see either the old complete file or the new complete file.
atomic_replace_file_no_follow() {
    local tmp="${1:-}" target="${2:-}" root="${3:-}" parent
    [ -n "$tmp" ] && [ -n "$target" ] && [ -n "$root" ] \
        || die "$EX_USAGE" "atomic publication requires a temporary, target, and allowed root"
    assert_path_inside "$tmp" "$root" \
        || die "$EX_USAGE" "publication temporary escapes its allowed root: ${tmp}"
    assert_path_inside "$target" "$root" \
        || die "$EX_USAGE" "publication target escapes its allowed root: ${target}"
    parent="$(dirname -- "$target")"
    [ "$(dirname -- "$tmp")" = "$parent" ] \
        || die "$EX_USAGE" "atomic publication temporary is not beside its target"
    assert_no_symlink_ancestry "$root" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$parent" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$target" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$tmp" || { rm -f -- "$tmp"; exit "$EX_USAGE"; }
    [ -f "$tmp" ] && [ ! -L "$tmp" ] \
        || { rm -f -- "$tmp"; die "$EX_USAGE" "publication temporary is not a regular file"; }
    require_tools perl
    if ! perl -e 'rename($ARGV[0], $ARGV[1]) or die "rename failed: $!\n"' -- "$tmp" "$target"; then
        rm -f -- "$tmp"
        die "$EX_CANTCREAT" "cannot atomically publish: ${target}"
    fi
    assert_no_symlink_ancestry "$target" || exit "$EX_USAGE"
    [ -f "$target" ] && [ ! -L "$target" ] \
        || die "$EX_USAGE" "atomic publication target is not a regular file: ${target}"
}

# atomic_write_line_no_follow <target> <line> <allowed-root> — write a pointer
# through a private same-directory temporary file, then publish it atomically.
atomic_write_line_no_follow() {
    local target="${1:-}" line="${2:-}" root="${3:-}"
    local parent base tmp
    [ -n "$target" ] && [ -n "$root" ] \
        || die "$EX_USAGE" "atomic pointer write requires a target and allowed root"
    parent="$(dirname -- "$target")"
    base="$(basename -- "$target")"
    [ -d "$parent" ] || die "$EX_USAGE" "pointer parent is not a directory: ${parent}"
    tmp="$(mktemp "${parent}/.${base}.tmp.XXXXXX")" \
        || die "$EX_CANTCREAT" "cannot create an atomic pointer temporary file"
    if ! printf '%s\n' "$line" > "$tmp"; then
        rm -f -- "$tmp"
        die "$EX_CANTCREAT" "cannot write pointer temporary file"
    fi
    atomic_replace_file_no_follow "$tmp" "$target" "$root"
}

# artifacts_run_dir <gate> — a fresh timestamped evidence directory, plus an
# atomically replaced, no-follow latest.txt pointer.
artifacts_run_dir() {
    local gate="${1:-}" gate_dir dir pointer
    [ -n "$gate" ] || die "$EX_USAGE" "artifact gate name is empty"
    case "$gate" in
        /*|.|..|*/../*|../*|*/..|*/./*|./*|*//* )
            die "$EX_USAGE" "invalid artifact gate path: ${gate}" ;;
    esac
    printf '%s' "$gate" | grep -Eq '^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$' \
        || die "$EX_USAGE" "invalid artifact gate path: ${gate}"

    gate_dir="${IOSAI_ARTIFACTS_DIR}/${gate}"
    dir="${gate_dir}/$(utc_stamp)-$$"
    pointer="${gate_dir}/latest.txt"
    ensure_artifact_directory "$gate_dir"
    assert_no_symlink_ancestry "$dir" || exit "$EX_USAGE"
    [ ! -e "$dir" ] && [ ! -L "$dir" ] \
        || die "$EX_USAGE" "artifact run directory already exists: ${dir}"
    mkdir -- "$dir"
    ensure_artifact_directory "$dir"
    atomic_write_line_no_follow "$pointer" "$dir" "$IOSAI_ARTIFACTS_DIR"
    printf '%s\n' "$dir"
}

# artifact_output_path <configured-path> — `.artifacts/...` always names the
# persistent evidence root, even while source is executing from an immutable
# candidate worktree elsewhere.
artifact_output_path() {
    local path="$1"
    case "$path" in
        .artifacts) printf '%s\n' "$IOSAI_ARTIFACTS_DIR" ;;
        .artifacts/*) printf '%s/%s\n' "$IOSAI_ARTIFACTS_DIR" "${path#.artifacts/}" ;;
        *) abs_path "$path" ;;
    esac
}

# assert_no_symlink_ancestry <absolute-path> — refuse a path any component of
# which is a symlink.
#
# Checking only the final component is not enough: if `.artifacts` is a symlink
# to somewhere else, or a parent directory is, then resolving the target lands
# outside the root that was supposed to contain it — and the containment check
# then passes on the resolved path while the deletion happens elsewhere.
assert_no_symlink_ancestry() {
    local path="${1:-}" current
    case "$path" in
        /*) : ;;
        *)  log_error "internal error: expected an absolute path, got: ${path}"
            return "$EX_USAGE" ;;
    esac

    current="$path"
    while [ -n "$current" ] && [ "$current" != "/" ]; do
        if [ -L "$current" ]; then
            log_error "refusing to act through a symlink: ${current}"
            hint "a symlinked component would let this operation leave its own root."
            hint "replace it with a real directory, or point the setting elsewhere."
            return "$EX_USAGE"
        fi
        current="$(dirname -- "$current")"
    done
    return 0
}

# assert_path_inside <absolute-path> <absolute-root> — textual containment that
# refuses `..` traversal. Used before a path exists, where physical resolution
# cannot help.
assert_path_inside() {
    local path="${1:-}" root="${2:-}"
    case "$path" in /*) : ;; *) return 1 ;; esac
    case "$root" in /*) : ;; *) return 1 ;; esac
    case "$path" in *"/../"*|*"/..") return 1 ;; esac
    case "$path" in "${root}"/*) return 0 ;; esac
    return 1
}

# safe_remove_path <path> <allowed-root> — the only deletion primitive in this
# template.
#
# Three conditions, all required: the allowed root is one of this checkout's
# canonical roots, neither path passes through a symlink, and the target is
# strictly inside the root once resolved. The allowed root used to be whatever
# the caller passed, so a configured DerivedData path made its own parent
# permissible and an arbitrary directory could be deleted.
safe_remove_path() {
    local target="${1:-}" allowed="${2:-}"

    [ -n "$target" ]  || die "$EX_USAGE" "refusing to delete: empty path"
    [ -n "$allowed" ] || die "$EX_USAGE" "refusing to delete: no allowed root given"

    case "$target" in
        /*) : ;;
        *)  die "$EX_USAGE" "refusing to delete a relative path: ${target}" ;;
    esac
    case "$allowed" in
        /*) : ;;
        *)  die "$EX_USAGE" "refusing a relative allowed root: ${allowed}" ;;
    esac

    case "$target" in
        /|/tmp|/tmp/|/private|/private/|/private/tmp|/private/tmp/|/Users|/Users/|/Users/Shared|/Users/Shared/)
            die "$EX_USAGE" "refusing to delete a protected system path: ${target}" ;;
    esac
    if [ "$target" = "${HOME:-/nonexistent}" ]; then
        die "$EX_USAGE" "refusing to delete the home directory: ${target}"
    fi
    if [ "$target" = "$IOSAI_ROOT" ]; then
        die "$EX_USAGE" "refusing to delete the repository root: ${target}"
    fi

    # The allowed root must be a root this checkout owns, not merely a directory
    # somebody named.
    local root canonical="no"
    while IFS= read -r root; do
        [ -n "$root" ] || continue
        [ "$allowed" = "$root" ] && canonical="yes"
    done <<EOF
$(iosai_canonical_roots)
EOF
    if [ "$canonical" != "yes" ]; then
        log_error "refusing to delete inside a root this repository does not own: ${allowed}"
        hint "deletion is confined to:"
        iosai_canonical_roots | sed 's/^/           /' >&2
        exit "$EX_USAGE"
    fi

    assert_no_symlink_ancestry "$allowed" || exit "$EX_USAGE"
    assert_no_symlink_ancestry "$target"  || exit "$EX_USAGE"

    if [ ! -e "$target" ]; then
        return 0
    fi

    local target_phys allowed_phys
    target_phys="$(physical_path "$target")" || die "$EX_USAGE" "cannot resolve: ${target}"
    allowed_phys="$(physical_path "$allowed")" || die "$EX_USAGE" "allowed root does not exist: ${allowed}"

    if [ "$target_phys" = "$allowed_phys" ]; then
        die "$EX_USAGE" "refusing to delete the allowed root itself: ${target_phys}"
    fi
    case "$target_phys" in
        "${allowed_phys}"/*) : ;;
        *) die "$EX_USAGE" "refusing to delete outside ${allowed_phys}: ${target_phys}" ;;
    esac

    rm -rf -- "$target_phys"
    return 0
}

# ---------------------------------------------------------------------------
# Git state
# ---------------------------------------------------------------------------
# Every git command here is anchored to IOSAI_ROOT with `git -C`, after
# iosai_enter_root removes inherited repository-local Git environment variables.
#
# The scripts resolve their paths from this file's location, so they can be
# invoked from anywhere — but an unqualified `git` obeys $PWD instead. Run from
# inside another repository, the hook installer configured the CALLER's
# repository while printing the target's path. Filesystem and git must agree on
# which repository this is.
in_git_repo() { git -C "$IOSAI_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; }

git_root() {
    in_git_repo || die "$EX_UNAVAILABLE" "not inside a git repository (run 'git init' first)"
    git -C "$IOSAI_ROOT" rev-parse --show-toplevel
}

git_has_commits() { git -C "$IOSAI_ROOT" rev-parse --verify --quiet HEAD >/dev/null 2>&1; }

# iosai_enter_root — make $PWD agree with the repository the scripts operate on.
# Called by every entry point, so a relative path a user passes resolves against
# the same repository the gate reports on.
iosai_enter_root() {
    local git_variables variable resolved_root
    cd -- "$IOSAI_ROOT" || die "$EX_UNAVAILABLE" "cannot enter the repository root: ${IOSAI_ROOT}"

    # `git -C` does not override GIT_DIR, GIT_WORK_TREE or GIT_INDEX_FILE. A hook
    # or wrapper can export them, making Git inspect a clean foreign checkout
    # while Xcode builds this one's uncommitted files. Use Git's own list so
    # object-directory and other repository-local overrides are cleared too.
    require_tools git
    git_variables="$(git rev-parse --local-env-vars)" \
        || die "$EX_VERIFY" "could not determine repository-local Git environment variables"
    while IFS= read -r variable; do
        case "$variable" in
            GIT_*) unset "$variable" \
                || die "$EX_VERIFY" "could not clear repository-local Git variable ${variable}" ;;
            *) die "$EX_VERIFY" "invalid repository-local Git variable name" ;;
        esac
    done <<EOF
$git_variables
EOF

    # Copies without Git remain usable for setup/configuration. When Git exists,
    # refuse a parent checkout or core.worktree redirection as well.
    if in_git_repo; then
        resolved_root="$(git -C "$IOSAI_ROOT" rev-parse --show-toplevel)" \
            || die "$EX_VERIFY" "could not resolve this Git worktree"
        resolved_root="$(physical_path "$resolved_root")" \
            || die "$EX_VERIFY" "could not resolve the physical Git worktree"
        [ "$resolved_root" = "$IOSAI_ROOT" ] \
            || die "$EX_VERIFY" "Git worktree root does not match the script checkout"
    fi
    return 0
}

# iosai_project_marker_present — is this an initialized product repository?
iosai_project_marker_present() {
    [ -e "${IOSAI_ROOT}/.iosai-project" ] || [ -L "${IOSAI_ROOT}/.iosai-project" ]
}

# iosai_primary_branch — the one branch milestones are developed and committed on.
#
# Milestones are sequential and live on this branch; a branch outside it exists
# only for post-milestone localization. initialize-project.sh records the name in
# `.iosai-project`, so a product that renamed its primary branch is read here
# rather than assumed.
#
#   prints the name, returns 0   marker present, holding exactly one valid field
#   returns 1, prints nothing    no marker: the uninitialized template repository
#   die EX_NOINPUT               marker present but unreadable, not a regular file,
#                                empty, or holding more than one primary_branch line
#
# An absent marker records no primary branch, so there is nothing to assert and a
# caller must not invent one — a gate that guessed the branch it was supposed to
# require would be enforcing nothing. A marker that exists and cannot be read is
# the opposite case and fails closed: this template is routinely used from
# /Users/Shared, where a second account can own repository files, and "could not
# determine" is never an answer.
#
# The field must occur exactly once. First-occurrence-wins would let a second,
# contradictory line decide nothing while looking decisive — the same reasoning
# machine_field_count is built on.
iosai_primary_branch() {
    local marker="${IOSAI_ROOT}/.iosai-project" count value
    iosai_project_marker_present || return 1

    [ -f "$marker" ] && [ ! -L "$marker" ] \
        || die "$EX_NOINPUT" ".iosai-project is not a regular file; the project marker cannot be trusted"
    [ -r "$marker" ] \
        || die "$EX_NOINPUT" ".iosai-project cannot be read; the primary branch could not be determined"

    count="$(awk 'index($0, "primary_branch=") == 1 { n++ } END { print n + 0 }' "$marker")"
    if [ "$count" -eq 0 ]; then
        log_error ".iosai-project records no primary branch"
        hint "expected exactly one line: primary_branch=<name>"
        hint "initialize-project.sh writes it; add it by hand if this repository predates it."
        exit "$EX_NOINPUT"
    fi
    if [ "$count" -gt 1 ]; then
        log_error ".iosai-project holds ${count} primary_branch lines; exactly one is allowed"
        hint "two answers to the same question is ambiguity, not a merge"
        exit "$EX_NOINPUT"
    fi

    value="$(awk 'index($0, "primary_branch=") == 1 { print substr($0, length("primary_branch=") + 1); exit }' "$marker")"
    [ -n "$value" ] \
        || die "$EX_NOINPUT" ".iosai-project records an empty primary branch name"
    printf '%s\n' "$value"
    return 0
}

# git_operation_in_progress — echoes the operation name, or nothing.
git_operation_in_progress() {
    local p git_path
    for p in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG; do
        git_path="$(git -C "$IOSAI_ROOT" rev-parse --git-path "$p")" || {
            log_error "could not inspect Git operation state"
            return "$EX_VERIFY"
        }
        if [ -e "$git_path" ]; then
            printf '%s\n' "$p"
            return 0
        fi
    done
    return 0
}

# milestone_checkout_is_clean [context-message]
#
# "Every byte that could affect the result already belongs to HEAD." Normal
# milestone verification runs directly in the primary checkout, and
# assert_immutable_candidate_root asks the same question of a candidate snapshot,
# so the optional first argument replaces only the dirty-tree headline; every
# detail line and every fail-closed rule is shared.
#
# Every Git query below FAILS CLOSED. This function is always called as the left
# operand of an `||` list, so `set -e` is inactive for its whole body: a query
# whose status was discarded returned an empty string, an empty string read as
# "nothing to report", and a dirty tree earned a PASSED verdict and a
# VERIFIED_COMMIT. An unreadable index is enough to trigger it — and this template
# is routinely used from /Users/Shared, where a second account can own .git/index.
# "Could not determine" is a verification failure, never a clean tree.
milestone_checkout_is_clean() {
    local context="${1:-normal milestone verification requires a clean working tree}"
    local problems=0 op state hidden ignored tracked_flags

    if ! op="$(git_operation_in_progress)"; then
        problems=$((problems + 1))
    elif [ -n "$op" ]; then
        log_error "a Git operation is in progress (${op})"
        problems=$((problems + 1))
    fi

    if ! state="$(git -C "$IOSAI_ROOT" status --porcelain --untracked-files=all 2>&1)"; then
        log_error "could not read the working tree state; refusing to assume it is clean"
        printf '%s\n' "$state" | sed 's/^/           /' >&2
        problems=$((problems + 1))
    elif [ -n "$state" ]; then
        log_error "$context"
        printf '%s\n' "$state" | sed 's/^/           /' >&2
        problems=$((problems + 1))
    fi

    if ! tracked_flags="$(git -C "$IOSAI_ROOT" ls-files -v 2>&1)"; then
        log_error "could not read tracked file state; refusing to assume nothing is hidden"
        printf '%s\n' "$tracked_flags" | sed 's/^/           /' >&2
        problems=$((problems + 1))
    else
        hidden="$(printf '%s\n' "$tracked_flags" | grep -E '^[a-zS]' || true)"
        if [ -n "$hidden" ]; then
            log_error "tracked input is hidden by assume-unchanged or skip-worktree"
            printf '%s\n' "$hidden" | sed 's/^/           /' >&2
            problems=$((problems + 1))
        fi
    fi

    # An absent pathspec is not an error for ls-files, so this stays quiet on a
    # repository that legitimately lacks one of these directories.
    if ! ignored="$(git -C "$IOSAI_ROOT" ls-files --others --ignored --exclude-standard -- \
            App Config Scripts AI .githooks 2>&1)"; then
        log_error "could not inspect ignored build inputs; refusing to assume there are none"
        printf '%s\n' "$ignored" | sed 's/^/           /' >&2
        problems=$((problems + 1))
    else
        # Finder writes .DS_Store into every directory a person opens, and these are
        # the directories a person opens. It holds window size and icon positions:
        # no target compiles it, no gate reads it, and the repository root — where
        # the same file lands first — is already outside this scan. Reporting it as
        # a build input meant a developer met this failure for a reason that was
        # never true, and a failure that is usually noise is a failure that gets
        # waved through when it is not.
        #
        # The tolerance is this exact name and nothing else: any other ignored file
        # under these directories still refuses, and a checkout whose .gitignore
        # does NOT cover .DS_Store still fails it — as untracked bytes, in the
        # working-tree check above. The file is never invisible to the gate; it is
        # only excluded from the one question it cannot be an answer to.
        #
        # Xcode does the same thing one level down, and M00 is where it starts:
        # opening the project writes the developer's window layout
        # (UserInterfaceState.xcuserstate) and scheme-list order
        # (xcschemes/xcschememanagement.plist) into
        # <container>/xcuserdata/<user>.xcuserdatad/, a breakpoint or a watch
        # expression adds xcdebugger/*.xcbkptlist or *.xcexplist beside them, the
        # Find navigator records its search scopes in IDEFindNavigatorScopes.plist,
        # and a running Xcode rewrites the window state every few minutes. xcodebuild
        # reads none of it for a build or a test. Refusing it failed the documented
        # `make milestone ID=<ID>` for every developer who had ever opened the
        # project — before the build, or after a whole build and test run when Xcode
        # rewrote the file mid-gate — and two products built on this workflow worked
        # around it on nearly every milestone by moving the developer's files aside
        # or by switching to candidate mode, which ordinary work must never need.
        #
        # The same rule as .DS_Store: exact file shapes, and only inside an
        # xcuserdata/<user>.xcuserdatad directory. A user scheme
        # (xcschemes/<name>.xcscheme) can replace what a shared scheme builds, and
        # WorkspaceSettings.xcsettings can move the build location, so both still
        # refuse, as does any other ignored file.
        ignored="$(printf '%s\n' "$ignored" \
            | grep -Ev '(^|/)\.DS_Store$|(^|/)xcuserdata/[^/]+\.xcuserdatad/(UserInterfaceState\.xcuserstate|IDEFindNavigatorScopes\.plist|xcschemes/xcschememanagement\.plist|xcdebugger/[^/]+\.(xcbkptlist|xcexplist))$' \
            || true)"
        if [ -n "$ignored" ]; then
            log_error "ignored source, configuration, test, or policy input could affect verification"
            printf '%s\n' "$ignored" | sed 's/^/           /' >&2
            problems=$((problems + 1))
        fi
    fi

    [ "$problems" -eq 0 ]
}

# resolve_explicit_candidate <full-sha> — validate a public strict-gate
# candidate. Symbolic refs and abbreviated object names are deliberately
# rejected: the command line itself must name the immutable object the report
# will certify.
resolve_explicit_candidate() {
    local supplied="${1:-}" resolved
    [ -n "$supplied" ] || die "$EX_USAGE" "--candidate requires a full commit SHA"
    printf '%s' "$supplied" | grep -Eq '^[0-9a-f]+$' \
        || die "$EX_USAGE" "--candidate must be a full lowercase hexadecimal commit SHA"
    resolved="$(git -C "$IOSAI_ROOT" rev-parse --verify --quiet "${supplied}^{commit}" 2>/dev/null || true)"
    [ -n "$resolved" ] || die "$EX_VERIFY" "candidate is not a commit in this repository: ${supplied}"
    [ "$supplied" = "$resolved" ] \
        || die "$EX_USAGE" "--candidate must be the full commit SHA, not a ref or abbreviation: ${supplied}"
    printf '%s\n' "$resolved"
}

# assert_immutable_candidate_root <candidate>
# The inner strict-gate process must be a detached worktree at the exact
# candidate with a read-only source root. Evidence is written to the caller's
# separate .artifacts directory, never into this snapshot.
assert_immutable_candidate_root() {
    local candidate="$1" actual probe
    actual="$(git -C "$IOSAI_ROOT" rev-parse HEAD 2>/dev/null)" \
        || die "$EX_VERIFY" "immutable candidate snapshot has no readable HEAD"
    [ "$actual" = "$candidate" ] \
        || die "$EX_VERIFY" "immutable candidate mismatch: expected ${candidate}, found ${actual}"
    # HEAD POINTING AT the candidate is not the tree BEING the candidate. These two
    # checks used to be the whole test — a matching HEAD and an unwritable root —
    # and a read-only checkout can satisfy both while holding modified tracked
    # files, assume-unchanged inputs, or ignored build inputs. An audit reproduced
    # the consequence: exit 0, a readiness verdict, and a report asserting
    # `**VERIFIED_COMMIT:**` plus "read-only detached worktree materialised from the
    # candidate commit" for a source carrying a line that commit does not contain.
    # A gate's own description of what it verified has to be true.
    milestone_checkout_is_clean "immutable candidate source is not this commit's content" \
        || die "$EX_VERIFY" "immutable candidate source is not the candidate's content"
    probe="${IOSAI_ROOT}/.iosai-write-probe-$$"
    # `2>/dev/null` must come FIRST: bash applies redirections left to right, so
    # `: > "$probe" 2>/dev/null` fails the truncation before stderr is silenced,
    # and a passing gate printed a raw "Permission denied" from the probe it was
    # expecting to fail. A green gate that prints filesystem errors teaches
    # people to ignore filesystem errors.
    if : 2>/dev/null > "$probe"; then
        rm -f -- "$probe"
        die "$EX_VERIFY" "candidate source root is writable; refusing a mutable verification run"
    fi
    return 0
}

# iosai_release_candidate_snapshot — undo everything run_in_immutable_candidate
# created. Safe to call twice, and safe to call from a signal handler.
#
# IOSAI_CANDIDATE_SNAPSHOT / IOSAI_CANDIDATE_PARENT are globals rather than
# locals so the trap can still read them under `set -u`.
IOSAI_CANDIDATE_SNAPSHOT=""
IOSAI_CANDIDATE_PARENT=""
iosai_release_candidate_snapshot() {
    local snapshot="${IOSAI_CANDIDATE_SNAPSHOT:-}" parent="${IOSAI_CANDIDATE_PARENT:-}"
    IOSAI_CANDIDATE_SNAPSHOT=""
    IOSAI_CANDIDATE_PARENT=""
    [ -n "$snapshot" ] || return 0

    # Restore write permission first: the tree was made read-only, so neither
    # `git worktree remove` nor a human's `rm -rf` can clean it up until this
    # runs. That is what turned an interrupted gate into a directory the owner
    # could not delete.
    chmod -R u+w "$snapshot" 2>/dev/null || true
    git -C "$IOSAI_ROOT" worktree remove --force "$snapshot" >/dev/null 2>&1 || true
    # Belt and braces, and deliberately narrow: only ever the `source` child of
    # the mktemp directory this function created, never a caller-supplied path.
    if [ -n "$parent" ] && [ "$snapshot" = "${parent}/source" ] && [ -d "$snapshot" ]; then
        rm -rf -- "$snapshot" 2>/dev/null || true
    fi
    # Prune the registration even when the directory removal above lost a race;
    # a registered worktree whose directory is gone is exactly what prune is for.
    git -C "$IOSAI_ROOT" worktree prune >/dev/null 2>&1 || true
    [ -n "$parent" ] && rmdir "$parent" 2>/dev/null
    return 0
}

# _iosai_candidate_signal_cleanup <signal> — clean up, then re-raise with the
# default handler so the caller still sees a normal signal death.
_iosai_candidate_signal_cleanup() {
    local sig="$1"
    iosai_release_candidate_snapshot
    trap - EXIT INT TERM HUP
    kill -s "$sig" $$ 2>/dev/null || exit "$EX_FAIL"
}

# run_in_immutable_candidate <candidate> <gate> <evidence-root> <script> [args]
# Materialises the exact commit in a detached worktree, removes write permission
# from the whole source tree, runs the gate there, then restores permission only
# so Git can remove the temporary worktree. No mutable-checkout fingerprint is
# the primary trust guarantee.
#
# Cleanup is a trap, not a straight line. The window between `chmod -R a-w` and
# the removal spans the whole gate — minutes, because template mode runs the
# self-test — and an interrupt in that window used to leave a mode-0555 worktree
# registered in the repository forever: `git worktree list` reported it as a real
# worktree, `git worktree list` showed it as a live checkout, and
# `rm -rf` on it failed.
run_in_immutable_candidate() {
    local candidate="$1" gate="$2" evidence_root="$3" script_rel="$4"
    shift 4
    local rc=0 actual

    require_tools git mktemp chmod
    git -C "$IOSAI_ROOT" cat-file -e "${candidate}^{commit}" 2>/dev/null \
        || die "$EX_VERIFY" "candidate is not a commit in this repository: ${candidate}"

    IOSAI_CANDIDATE_PARENT="$(mktemp -d -t "iosai-${gate}-candidate")"
    IOSAI_CANDIDATE_SNAPSHOT="${IOSAI_CANDIDATE_PARENT}/source"
    trap 'iosai_release_candidate_snapshot' EXIT
    trap '_iosai_candidate_signal_cleanup INT'  INT
    trap '_iosai_candidate_signal_cleanup TERM' TERM
    trap '_iosai_candidate_signal_cleanup HUP'  HUP

    if ! git -C "$IOSAI_ROOT" worktree add --quiet --detach \
            "$IOSAI_CANDIDATE_SNAPSHOT" "$candidate"; then
        die "$EX_VERIFY" "could not materialise candidate ${candidate} in a detached worktree"
    fi
    actual="$(git -C "$IOSAI_CANDIDATE_SNAPSHOT" rev-parse HEAD 2>/dev/null || true)"
    if [ "$actual" != "$candidate" ]; then
        die "$EX_VERIFY" "materialised candidate mismatch: expected ${candidate}, found ${actual:-unreadable}"
    fi

    chmod -R a-w "$IOSAI_CANDIDATE_SNAPSHOT"
    "${IOSAI_CANDIDATE_SNAPSHOT}/${script_rel}" \
        --immutable-evidence-root "$evidence_root" "$@" || rc=$?

    local snapshot="$IOSAI_CANDIDATE_SNAPSHOT"
    iosai_release_candidate_snapshot
    if [ -e "$snapshot" ]; then
        log_error "verification finished, but the temporary candidate worktree could not be removed: ${snapshot}"
        hint "recover with: chmod -R u+w $(shell_quote "$snapshot") && git worktree prune"
        [ "$rc" -ne 0 ] || rc="$EX_SOFTWARE"
    fi
    # The EXIT/signal traps stay installed. They are a no-op now that the state
    # they act on is cleared, and removing them here would silently discard a
    # trap the caller had already set.
    return "$rc"
}

# ---------------------------------------------------------------------------
# xcodebuild
# ---------------------------------------------------------------------------

# run_xcodebuild <label> <run-dir> -- <xcodebuild arg...>
# Tees the complete log into the evidence directory and records the exact
# command. Returns xcodebuild's own exit status, not tee's.
run_xcodebuild() {
    local label="$1" run_dir="$2"
    shift 2
    [ "${1:-}" = "--" ] && shift

    require_tools xcodebuild
    ensure_artifact_directory "$run_dir"
    local log="${run_dir}/${label}.log" command="${run_dir}/${label}.command" log_tmp
    # Every path-bearing option is checked at EVERY occurrence, not just the one
    # this function's caller passed. A later duplicate wins on the xcodebuild
    # command line, so a selector smuggled in through a configured *_TEST_ARGUMENTS
    # value could otherwise redirect output the gate believed it owned.
    #
    # -derivedDataPath is validated against the checkout's owned cache root rather
    # than .artifacts/: it is a build cache, not evidence, and it legitimately
    # lives outside the repository. It used to be the one path-bearing option that
    # was not re-checked here at all.
    local arg pending="" output_path output_paths="" cache_root
    for arg in "$@"; do
        case "$pending" in
            simulator_destination)
                if [ "$arg" != "$(platform_simulator_destination "$IOSAI_SIMULATOR_UDID")" ] \
                   && ! { [ "$label" = clean-release ] && [ "$arg" = "$(platform_device_destination)" ]; }; then
                    die "$EX_USAGE" "managed run cannot target another destination: $arg"
                fi
                pending=""
                continue ;;
            explicit_destination)
                platform_validate_destination "$arg"
                pending=""
                continue ;;
            artifact)
                output_path="$(artifact_output_path "$arg")"
                assert_path_inside "$output_path" "$IOSAI_ARTIFACTS_DIR" \
                    || die "$EX_USAGE" "xcodebuild output escapes .artifacts/: ${output_path}"
                ensure_artifact_directory "$(dirname -- "$output_path")"
                assert_no_symlink_ancestry "$output_path" || exit "$EX_USAGE"
                output_paths="${output_paths}${output_path}
"
                pending=""
                continue ;;
            cache)
                output_path="$(abs_path "$arg")"
                cache_root="$(derived_data_owned_root)"
                assert_path_inside "$output_path" "$cache_root" \
                    || die "$EX_USAGE" "xcodebuild -derivedDataPath escapes this checkout's owned cache root: ${output_path}"
                assert_no_symlink_ancestry "$output_path" || exit "$EX_USAGE"
                pending=""
                continue ;;
        esac
        case "$arg" in
            -destination)
                if [ "${SIMULATOR_MODE-explicit}" = managed ]; then pending=simulator_destination; else pending=explicit_destination; fi ;;
            -destination=*)
                [ "${SIMULATOR_MODE-explicit}" != managed ] \
                    || die "$EX_USAGE" 'managed runs require the bound -destination argument'
                platform_validate_destination "${arg#-destination=}" ;;
            -resultBundlePath)              pending="artifact" ;;
            -derivedDataPath)               pending="cache" ;;
        esac
    done
    [ -z "$pending" ] \
        || die "$EX_USAGE" "xcodebuild option is missing its value"
    atomic_write_line_no_follow "$command" "$(render_command xcodebuild "$@")" "$IOSAI_ARTIFACTS_DIR"

    log_step "xcodebuild ${label}"
    log_info "         $(cat "$command")"

    local rc=0
    log_tmp="$(mktemp "${run_dir}/.${label}.log.tmp.XXXXXX")" \
        || die "$EX_CANTCREAT" "cannot create xcodebuild log temporary"
    set +e
    xcodebuild "$@" 2>&1 | tee "$log_tmp"
    rc=${PIPESTATUS[0]}
    set -e
    atomic_replace_file_no_follow "$log_tmp" "$log" "$IOSAI_ARTIFACTS_DIR"
    while IFS= read -r output_path; do
        [ -n "$output_path" ] || continue
        assert_no_symlink_ancestry "$output_path" || exit "$EX_USAGE"
        if [ -e "$output_path" ]; then
            local output_phys root_phys
            output_phys="$(physical_path "$output_path")" \
                || die "$EX_USAGE" "cannot resolve xcodebuild output: ${output_path}"
            root_phys="$(physical_path "$IOSAI_ARTIFACTS_DIR")" \
                || die "$EX_USAGE" "cannot resolve artifact root"
            case "$output_phys" in
                "${root_phys}"/*) : ;;
                *) die "$EX_USAGE" "xcodebuild output resolves outside .artifacts/: ${output_path}" ;;
            esac
        fi
    done <<EOF
$output_paths
EOF

    if [ "$rc" -eq 0 ]; then
        log_ok "${label} (log: ${log#"${IOSAI_ROOT}/"})"
    else
        log_error "${label} failed with exit ${rc} (log: ${log#"${IOSAI_ROOT}/"})"
    fi
    return "$rc"
}

# assert_result_bundle <bundle> <label> [counts-file] [allow-skipped|reject-skipped]
#
# Counts come out of the .xcresult bundle, never from scraping the log. A run
# that executed zero tests is a failure (EX_SOFTWARE), not a pass — that is the
# single most common way a green gate lies.
#
# Every count must be present and numeric, and the counts must add up. A summary
# carrying only totalTestCount used to be read as "passed=0 failed=0", which
# reports a green suite from a bundle that said nothing about outcomes.
assert_result_bundle() {
    local bundle="$1" label="$2" counts_file="${3:-}"
    local skipped_policy="${4:-allow-skipped}"

    case "$skipped_policy" in
        allow-skipped|reject-skipped) : ;;
        *) die "$EX_SOFTWARE" "${label}: unknown skipped-test policy: ${skipped_policy}" ;;
    esac

    require_tools xcrun jq
    [ -d "$bundle" ] || die "$EX_NOINPUT" "${label}: result bundle not found: ${bundle}"

    local json tool_rc=0
    json="$(xcrun xcresulttool get test-results summary --path "$bundle" --compact 2>/dev/null)" || tool_rc=$?
    if [ "$tool_rc" -ne 0 ]; then
        log_error "${label}: xcresulttool failed with exit ${tool_rc}"
        hint "bundle: ${bundle}"
        hint "parseable output from a failed evidence command is not authoritative"
        exit "$EX_UNAVAILABLE"
    fi
    if [ -z "$json" ]; then
        log_error "${label}: could not read a test summary from ${bundle}"
        hint "this check cannot be skipped: without counts there is no evidence."
        hint "verify the Xcode command line tools with 'xcrun xcresulttool version'"
        exit "$EX_UNAVAILABLE"
    fi

    # `jq '… | numbers'` prints nothing for a missing field, a null, or a string,
    # so a count that is not a number cannot be defaulted to zero here.
    local total passed failed skipped expected missing="" field value
    for field in totalTestCount passedTests failedTests skippedTests; do
        value="$(printf '%s' "$json" | jq -r --arg f "$field" '.[$f] | numbers' 2>/dev/null || true)"
        if ! printf '%s' "$value" | grep -Eq '^[0-9]+$'; then
            missing="${missing} ${field}"
            continue
        fi
        case "$field" in
            totalTestCount) total="$value" ;;
            passedTests)    passed="$value" ;;
            failedTests)    failed="$value" ;;
            skippedTests)   skipped="$value" ;;
        esac
    done

    if [ -n "$missing" ]; then
        log_error "${label}: result bundle summary is missing or non-numeric:${missing}"
        hint "bundle: ${bundle}"
        hint "a summary without every count is not evidence about a test run, and this"
        hint "check will not substitute zero for an answer the bundle did not give."
        exit "$EX_SOFTWARE"
    fi

    # An expected failure is a recorded outcome, so it counts toward the total.
    # Absent is legitimate and means none.
    expected="$(printf '%s' "$json" | jq -r '.expectedFailures | numbers' 2>/dev/null || true)"
    printf '%s' "$expected" | grep -Eq '^[0-9]+$' || expected=0

    local summary="${label}: total=${total} passed=${passed} failed=${failed} skipped=${skipped} expectedFailures=${expected}"
    if [ -n "$counts_file" ]; then
        report_line "$counts_file" "$summary"
    fi

    if [ "$total" -eq 0 ]; then
        log_error "${summary}"
        die "$EX_SOFTWARE" "${label}: zero tests executed — a run that tests nothing is not a pass"
    fi

    local accounted=$((passed + failed + skipped + expected))
    if [ "$accounted" -ne "$total" ]; then
        log_error "${summary}"
        log_error "${label}: counts do not add up — ${passed}+${failed}+${skipped}+${expected} = ${accounted}, total = ${total}"
        hint "an internally inconsistent summary cannot establish what ran. re-run the"
        hint "suite; if a genuine bundle really reports this, it is a finding about this"
        hint "gate — not a reason to accept the numbers."
        exit "$EX_SOFTWARE"
    fi

    if [ "$failed" -gt 0 ]; then
        log_error "${summary}"
        die "$EX_VERIFY" "${label}: ${failed} test(s) failed"
    fi

    if [ "$skipped_policy" = "reject-skipped" ] && [ "$skipped" -gt 0 ]; then
        log_error "${summary}"
        die "$EX_VERIFY" "${label}: ${skipped} test(s) skipped in a mandatory suite"
    fi

    # The human-facing line goes to stderr because callers capture stdout to get the
    # summary; without this the "ok" line would vanish from the console.
    log_ok "$summary" >&2
    printf '%s\n' "$summary"
    return 0
}

# app_target_build_setting <setting-name>
#
# Resolves a build setting for THE application target: exactly one target of
# product type com.apple.product-type.application in the configured scheme.
#
# Counting distinct values was not the same test. With APP_TARGET set, the filter
# matched on target name alone, so a same-named extension or aggregate target
# could supply the release version; and two matching targets that happened to
# agree on the value passed as "unambiguous" while the identity of the product
# was still unknown. The candidate's identity has to come from the app.
app_target_build_setting() {
    local setting="$1"
    require_tools xcodebuild jq
    xcb_container_args

    local json xcode_rc=0
    json="$(xcodebuild -showBuildSettings -json \
        ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
        -scheme "$SCHEME" \
        -configuration "${CONFIGURATION_RELEASE:-Release}" \
        -destination "$(platform_device_destination)" 2>/dev/null)" || xcode_rc=$?

    if [ "$xcode_rc" -ne 0 ]; then
        log_error "xcodebuild -showBuildSettings failed with exit ${xcode_rc}"
        hint "scheme: ${SCHEME}; configuration: ${CONFIGURATION_RELEASE:-Release}"
        hint "parseable output from a failed evidence command is not authoritative"
        exit "$EX_VERIFY"
    fi

    if [ -z "$json" ]; then
        log_error "could not read build settings for scheme '${SCHEME}'"
        hint "run: xcodebuild -showBuildSettings -scheme '${SCHEME}' ..."
        exit "$EX_VERIFY"
    fi

    # Select by product type, platform, and optional name, never the watch stub.
    local entries count value
    if ! entries="$(printf '%s' "$json" | platform_application_entries)"; then
        die "$EX_VERIFY" "could not parse xcodebuild settings JSON"
    fi
    if ! count="$(printf '%s' "$entries" | jq -r 'length' 2>/dev/null)"; then
        die "$EX_VERIFY" "could not count application targets in build settings"
    fi

    if [ "${count:-0}" -eq 0 ]; then
        log_error "no application target found for scheme '${SCHEME}'"
        hint "looked for exactly one target with PRODUCT_TYPE com.apple.product-type.application"
        if [ -n "${APP_TARGET:-}" ]; then
            hint "APP_TARGET is '${APP_TARGET}' — check that it names the app target itself,"
            hint "not an extension, a test target, or an aggregate target"
        else
            hint "if the scheme builds several products, set APP_TARGET in Config/project.env"
        fi
        exit "$EX_VERIFY"
    fi
    if [ "$count" -gt 1 ]; then
        log_error "${count} application targets match; the candidate's identity would be a guess"
        printf '%s' "$entries" | jq -r '.[].target' 2>/dev/null | sed 's/^/           /' >&2 || true
        hint "set APP_TARGET in Config/project.env to name the single application target"
        exit "$EX_VERIFY"
    fi

    if ! value="$(printf '%s' "$entries" | jq -r --arg s "$setting" '.[0].buildSettings[$s] // empty' \
        2>/dev/null)"; then
        die "$EX_VERIFY" "could not read ${setting} from application target build settings"
    fi
    if [ -z "$value" ]; then
        log_error "${setting} is not set on the application target"
        hint "target: $(printf '%s' "$entries" | jq -r '.[0].target' 2>/dev/null || printf '?')"
        hint "set ${setting} in Xcode; release identity is never inferred"
        exit "$EX_VERIFY"
    fi

    printf '%s\n' "$value"
    return 0
}

# ---------------------------------------------------------------------------
# Milestones — the bold-label parsing contract.
#
# Milestone files carry single-line fields at column 0, exactly:
#   **Label:** value
# This is the whole machine-readable contract. It is documented in
# AI/WORKFLOW.md; there is no Markdown parser here by design.
# ---------------------------------------------------------------------------

validate_milestone_id() {
    local id="${1:-}"
    [ -n "$id" ] || die "$EX_USAGE" "milestone ID is required (for example: M00)"
    if ! printf '%s' "$id" | grep -Eq "$IOSAI_MILESTONE_ID_PATTERN"; then
        log_error "invalid milestone ID: ${id}"
        hint "expected M followed by digits, optionally extended: M00, M03, M1B, M7.9H.4"
        exit "$EX_USAGE"
    fi
    return 0
}

# milestone_file_for_id <ID> — the single matching AI/milestones/<ID>-*.md.
milestone_file_for_id() {
    local id="$1"
    validate_milestone_id "$id"

    local dir="${IOSAI_ROOT}/AI/milestones"
    local matches count
    matches="$(find "$dir" -maxdepth 1 -type f -name "${id}-*.md" 2>/dev/null | sort || true)"

    if [ -z "$matches" ]; then
        log_error "no milestone file for ${id}"
        hint "expected AI/milestones/${id}-<slug>.md"
        hint "create one from AI/templates/milestone-template.md"
        exit "$EX_NOINPUT"
    fi
    count="$(printf '%s\n' "$matches" | wc -l | tr -d ' ')"
    if [ "$count" -gt 1 ]; then
        log_error "ambiguous milestone ID ${id}: ${count} files match"
        printf '%s\n' "$matches" | sed "s|^${IOSAI_ROOT}/|           |" >&2
        exit "$EX_NOINPUT"
    fi
    printf '%s\n' "$matches"
    return 0
}

# milestone_field <file> <Label> — the value of a `**Label:** value` line.
#
# The line must start at column zero. Matching is done with awk's index() rather
# than a regex or sed substitution, because labels legitimately contain characters
# that would otherwise need escaping.
#
# A line inside a fenced code block is an example, never a value. The milestone
# template shows `**Audit prompt:**` and `**Milestone test arguments:**` inside
# fences, and a milestone written from it verbatim used to be read as the Final
# Product Polish milestone because the first column-zero match won, fence or not.
# A fence opens and closes on a line that starts with ``` or ~~~ after at most three
# spaces of indentation, as Markdown defines it.
milestone_field() {
    local file="$1" label="$2"
    [ -f "$file" ] || return 0
    awk -v marker="**${label}:**" '
        /^ ? ? ?(```|~~~)/ { fenced = !fenced; next }
        fenced { next }
        index($0, marker) == 1 {
            value = substr($0, length(marker) + 1)
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            print value
            exit
        }
    ' "$file"
}

# machine_field_count <file> <Label> — exact column-zero occurrences. Consumers
# that make security decisions cannot accept "first occurrence wins": a second
# contradictory field makes the record ambiguous and therefore invalid. Fenced
# examples are skipped exactly as milestone_field skips them, so the two always
# agree on which lines are fields.
machine_field_count() {
    local file="$1" label="$2"
    [ -f "$file" ] || { printf '0\n'; return 0; }
    awk -v marker="**${label}:**" '
        /^ ? ? ?(```|~~~)/ { fenced = !fenced; next }
        fenced { next }
        index($0, marker) == 1 { count++ }
        END { print count + 0 }' "$file"
}

milestone_status_is_valid() {
    local status="${1:-}" known
    for known in $IOSAI_MILESTONE_STATUSES; do
        [ "$status" = "$known" ] && return 0
    done
    return 1
}

# milestone_ids — every milestone ID present, in filename order.
milestone_ids() {
    find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
        | sort \
        | while IFS= read -r f; do
            basename -- "$f" | sed 's/-.*$//; s/\.md$//'
          done
}

# ---------------------------------------------------------------------------
# One schema, used by every consumer.
#
# project-status.sh and verify-milestone.sh used to check overlapping subsets of
# the contract, so an incomplete milestone once validated
# cleanly, a duplicate ID passed, and two files sharing an ID prefix failed only
# much later inside `next`. Everything the tooling requires of a milestone or of
# PROJECT_STATUS.md is defined here and checked in one place.
# ---------------------------------------------------------------------------

IOSAI_PROJECT_PHASES="template discovery contracts implementation stabilization \
release-preparation released"

# Newline-separated: two of these labels contain a space.
IOSAI_MILESTONE_REQUIRED_FIELDS="ID
Status
Depends on
Validation
Handoff"

IOSAI_MILESTONE_REQUIRED_SECTIONS="## Objective
## Scope
## Non-goals
## Acceptance criteria"

IOSAI_STATUS_REQUIRED_FIELDS="Phase
Current milestone
Completed milestones
Next milestone
Blockers
Important decisions"

# Every session reads AI/PROJECT_STATUS.md third, and a compact status field that
# grows monotonically stops being compact. Without a limit the decisions field
# becomes a paragraph of accumulated audit findings and carried-forward
# consequences — which is a log, not a state. The budget is per single-line field and
# deliberately generous: enough for the current decisions and the links that carry
# their reasoning, not enough to accumulate a history the audit records already
# hold.
#
# Measured in BYTES, because `wc -c` is what every shell here has and `wc -m`
# depends on the locale. The difference only matters for non-ASCII text, where a
# byte budget is slightly stricter than a character one — which is the safe
# direction for a limit whose whole purpose is to stay small.
IOSAI_STATUS_FIELD_MAX_BYTES=600

# section_body <file> <heading> — the lines under a heading, up to the next one.
section_body() {
    awk -v want="$2" '
        /^## / { inside = ($0 == want) ? 1 : 0; next }
        inside { print }
    ' "$1"
}

# section_has_content <file> <heading> — anything other than blanks and comments.
section_has_content() {
    local body
    body="$(section_body "$1" "$2" | grep -vE '^[[:space:]]*$' | grep -vE '^[[:space:]]*<!--' || true)"
    [ -n "$body" ]
}

# milestone_rows — one tab-separated row per milestone. The third column remains
# reserved for compatibility with the graph helpers; ownership is not tracked.
milestone_rows() {
    local f id status deps title
    find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
        | sort | while IFS= read -r f; do
        [ -n "$f" ] || continue
        id="$(milestone_field "$f" 'ID')"
        [ -n "$id" ] || id="$(basename -- "$f" .md | sed 's/-.*$//')"
        status="$(milestone_field "$f" 'Status')"
        deps="$(milestone_field "$f" 'Depends on')"
        title="$(grep -m1 '^# ' "$f" 2>/dev/null | sed 's/^# //' || true)"
        [ -n "$title" ] || title="$(basename -- "$f" .md)"
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$id" "${status:-<missing>}" "-" "${deps:-none}" "$title" "$f"
    done
}

# dep_list <deps-field> — dependency IDs, one per line.
# Accepts "M01, M02", "M01 M02", and "none".
dep_list() {
    local raw="${1:-}"
    case "$raw" in
        ""|none|None|NONE|-) return 0 ;;
    esac
    printf '%s' "$raw" | tr ',' ' ' | tr -s ' ' '\n' \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$' || true
}

# milestone_status_is_complete <status> — only these satisfy a dependency.
milestone_status_is_complete() {
    case "${1:-}" in
        DONE) return 0 ;;
        *) return 1 ;;
    esac
}

# milestone_reaches <target-id> <start-id> <rows> — is target a transitive
# dependency of start?
milestone_reaches() {
    local target="$1" start="$2" rows="$3"
    local frontier="$start" visited="" node deps dep next

    while [ -n "$frontier" ]; do
        next=""
        while IFS= read -r node; do
            [ -n "$node" ] || continue
            line_in_list "$node" "$visited" && continue
            visited="${visited}${node}
"
            # Reads its whole input: an awk that exits at the first match lets the
            # producer take SIGPIPE, and pipefail then reports a failed lookup.
            deps="$(printf '%s\n' "$rows" | awk -F'\t' -v n="$node" '$1 == n && !found {print $4; found = 1}')"
            while IFS= read -r dep; do
                [ -n "$dep" ] || continue
                [ "$dep" = "$target" ] && return 0
                next="${next}${dep}
"
            done <<INNER
$(dep_list "$deps")
INNER
        done <<OUTER
$frontier
OUTER
        frontier="$(printf '%s' "$next" | grep -v '^$' || true)"
    done
    return 1
}

# milestone_validate_file <file> — the per-file half of the schema. Prints every
# problem; returns non-zero when there is one.
milestone_validate_file() {
    local file="$1" rel problems=0
    rel="$(relpath "$file")"

    if [ ! -f "$file" ]; then
        log_error "milestone file not found: ${rel}"
        return 1
    fi

    local label value
    while IFS= read -r label; do
        [ -n "$label" ] || continue
        value="$(milestone_field "$file" "$label")"
        if [ -z "$value" ]; then
            log_error "${rel}: no '**${label}:**' line"
            problems=$((problems + 1))
        fi
    done <<EOF
$IOSAI_MILESTONE_REQUIRED_FIELDS
EOF

    local status declared_id filename_id
    status="$(milestone_field "$file" 'Status')"
    if [ -n "$status" ] && ! milestone_status_is_valid "$status"; then
        log_error "${rel}: invalid status '${status}'"
        hint "allowed: ${IOSAI_MILESTONE_STATUSES}"
        problems=$((problems + 1))
    fi

    # The filename carries the ID for every path-based lookup, so the two must
    # agree or the tooling and the reader are looking at different milestones.
    declared_id="$(milestone_field "$file" 'ID')"
    filename_id="$(basename -- "$file" .md | sed 's/-.*$//')"
    if [ -n "$declared_id" ] && [ "$declared_id" != "$filename_id" ]; then
        log_error "${rel}: declares **ID:** ${declared_id} but is filed as ${filename_id}-*"
        problems=$((problems + 1))
    fi
    if [ -n "$declared_id" ] && ! printf '%s' "$declared_id" | grep -Eq "$IOSAI_MILESTONE_ID_PATTERN"; then
        log_error "${rel}: **ID:** ${declared_id} is not a valid milestone ID"
        hint "expected M followed by digits, optionally extended: M00, M03, M1B, M7.9H.4"
        problems=$((problems + 1))
    fi

    local section
    while IFS= read -r section; do
        [ -n "$section" ] || continue
        if ! grep -Fq "$section" "$file"; then
            log_error "${rel}: missing section: ${section}"
            problems=$((problems + 1))
        elif ! section_has_content "$file" "$section"; then
            log_error "${rel}: section is empty: ${section}"
            problems=$((problems + 1))
        fi
    done <<EOF
$IOSAI_MILESTONE_REQUIRED_SECTIONS
EOF

    # An audit milestone names its method and its record together, and the method is
    # either the Final Product Polish orchestrator or one of the six domain prompts.
    # The milestone gate derives the coverage domain from the prompt's filename, so a
    # misspelled prompt (audit-ux.md) used to select a domain no row belongs to, and
    # an empty `## Coverage` section then passed as "COMPLETE".
    local audit_prompt audit_record audit_name
    audit_prompt="$(milestone_field "$file" 'Audit prompt')"
    audit_record="$(milestone_field "$file" 'Audit record')"
    if [ -n "$audit_prompt" ] || [ -n "$audit_record" ]; then
        case "$audit_prompt" in
            AI/prompts/final-polish.md|AI/prompts/audit-functional.md|\
            AI/prompts/audit-ui-ux.md|AI/prompts/audit-content.md|\
            AI/prompts/audit-accessibility.md|AI/prompts/audit-product.md|\
            AI/prompts/audit-release.md) : ;;
            "")
                log_error "${rel}: **Audit record:** needs the **Audit prompt:** that produces it"
                problems=$((problems + 1)) ;;
            *)
                log_error "${rel}: **Audit prompt:** '${audit_prompt}' is not an audit method"
                hint "use AI/prompts/final-polish.md, or AI/prompts/audit-<domain>.md for one of:"
                hint "functional, ui-ux, content, accessibility, product, release"
                problems=$((problems + 1)) ;;
        esac
        audit_name="${audit_record#AI/audits/}"
        case "$audit_record" in
            AI/audits/*.md) : ;;
            *) audit_name="" ;;
        esac
        case "$audit_name" in
            ''|.*|*/*|*..*)
                log_error "${rel}: **Audit record:** must name one file AI/audits/<name>.md, found: ${audit_record:-(missing)}"
                problems=$((problems + 1)) ;;
        esac
    fi

    local criteria
    criteria="$(section_body "$file" '## Acceptance criteria' \
        | grep -cE '^[[:space:]]*-[[:space:]]*\[[ xX]\]' || true)"
    if [ "${criteria:-0}" -eq 0 ]; then
        log_error "${rel}: no checkbox acceptance criteria under '## Acceptance criteria'"
        hint "write them as observable checkboxes, for example:"
        hint "  - [ ] Launching with no saved data shows the empty state, not a spinner"
        problems=$((problems + 1))
    fi

    [ "$problems" -eq 0 ]
}

# milestone_display_title <file> — the human title without its leading milestone ID.
milestone_display_title() {
    local file="$1" id heading
    id="$(milestone_field "$file" 'ID')"
    heading="$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# //' || true)"
    case "$heading" in
        "$id — "*) printf '%s\n' "${heading#"$id — "}" ;;
        "$id - "*) printf '%s\n' "${heading#"$id - "}" ;;
        *)          printf '%s\n' "$heading" ;;
    esac
}

# validate_generated_final_milestones — one consolidated final milestone in a
# generated plan. Later appended work preserves that milestone as history.
validate_generated_final_milestones() {
    [ -f "${IOSAI_ROOT}/.iosai-project" ] || return 0
    local rows file id status title count=0 non_m00=0 final_file="" final_id="" problems=0
    rows="$(milestone_rows)"
    while IFS="$(printf '\t')" read -r id status _reserved _deps _title file; do
        [ -n "${file:-}" ] || continue
        [ "$id" = M00 ] || non_m00=$((non_m00 + 1))
        title="$(milestone_display_title "$file")"
        if [ "$title" = 'Final Product Polish' ]; then
            count=$((count + 1)); final_file="$file"; final_id="$id"
        fi
    done <<EOF
$rows
EOF
    [ "$non_m00" -gt 0 ] || return 0
    if [ "$count" -ne 1 ]; then
        log_error "generated plan requires exactly one Final Product Polish milestone, found ${count}"
        hint "see AI/prompts/migrate-final-polish.md for an unstarted older plan"
        return 1
    fi
    if [ "$(milestone_field "$final_file" 'Audit prompt')" != AI/prompts/final-polish.md ] \
       || [ "$(milestone_field "$final_file" 'Audit record')" != "AI/audits/${final_id}-final-polish.md" ]; then
        log_error "$(relpath "$final_file"): Final Product Polish must name its orchestrator and consolidated audit record"
        problems=$((problems + 1))
    fi
    if ! grep -Fq 'make release CANDIDATE=<verified-full-SHA>' "$final_file"; then
        log_error "$(relpath "$final_file"): Final Product Polish names no exact-SHA release gate"
        problems=$((problems + 1))
    fi
    printf '%s' "$final_id" | grep -Eq '^M[0-9]+$' || return 1
    local first_number previous_number expected_previous actual_previous
    first_number="$((10#${final_id#M}))"
    previous_number="$(printf '%s\n' "$rows" | awk -F '\t' -v first="$first_number" '
        BEGIN { highest = -1 }
        { value=$1; sub(/^M/, "", value)
          if (value ~ /^[0-9]+$/ && value+0 < first && value+0 > highest) highest=value+0 }
        END { print highest }')"
    if [ "$first_number" -ne "$((previous_number + 1))" ]; then
        log_error "$(relpath "$final_file"): final milestone ID must immediately follow the last earlier milestone"
        problems=$((problems + 1))
    fi
    expected_previous="$(printf '%s\n' "$rows" | while IFS="$(printf '\t')" read -r id _s _r _d _t file; do
        [ -n "${file:-}" ] || continue
        printf '%s' "$id" | grep -Eq '^M[0-9]+$' || continue
        [ "$((10#${id#M}))" -lt "$first_number" ] || continue
        printf '%s\n' "$id"
    done | sort)"
    actual_previous="$(dep_list "$(milestone_field "$final_file" 'Depends on')" | sort)"
    if [ -z "$expected_previous" ] || [ "$actual_previous" != "$expected_previous" ]; then
        log_error "$(relpath "$final_file"): Final Product Polish must depend on every earlier milestone"
        problems=$((problems + 1))
    fi
    [ "$problems" -eq 0 ]
}

# validate_milestone_test_scope_contract <milestone-file> <configured-args>
# A narrowed suite is allowed only when the contract binds itself to the exact
# configured selector and carries a durable reason. Conversely, a reason on a
# full-scheme run is stale policy and is rejected rather than silently reused.
validate_milestone_test_scope_contract() {
    local file="$1" configured_args="${2:-}"
    local declared rationale problems=0
    declared="$(milestone_field "$file" 'Milestone test arguments')"
    rationale="$(milestone_field "$file" 'Test scope rationale')"

    if [ -z "$configured_args" ]; then
        if [ -n "$declared" ] && [ "$declared" != "none" ]; then
            log_error "$(relpath "$file"): full-scheme configuration allows no test selector"
            problems=$((problems + 1))
        fi
        if [ -n "$rationale" ] && [ "$rationale" != "none" ]; then
            log_error "$(relpath "$file"): full-scheme configuration allows no test-scope rationale"
            hint "remove stale narrowed-scope rationale when MILESTONE_TEST_ARGUMENTS is empty"
            problems=$((problems + 1))
        fi
    else
        if [ "$declared" != "$configured_args" ]; then
            log_error "$(relpath "$file"): declared milestone test arguments do not match Config/project.env"
            hint "declared:   ${declared:-<absent>}"
            hint "configured: ${configured_args}"
            problems=$((problems + 1))
        fi
        if ! field_is_answered "$rationale"; then
            log_error "$(relpath "$file"): narrowed milestone tests require an answered '**Test scope rationale:**'"
            problems=$((problems + 1))
        fi
    fi

    [ "$problems" -eq 0 ]
}

# milestones_validate_all — every file, plus the cross-file rules: unique IDs,
# unambiguous filenames, known dependencies, no cycles, and M00 reachability.
milestones_validate_all() {
    local rows problems=0
    rows="$(milestone_rows)"
    if [ -z "$rows" ]; then
        log_warn "no milestone files to validate"
        return 0
    fi

    local id status _reserved deps title file
    while IFS="$(printf '\t')" read -r id status _reserved deps title file; do
        [ -n "${file:-}" ] || continue
        milestone_validate_file "$file" || problems=$((problems + 1))
    done <<EOF
$rows
EOF

    # Declared IDs must be unique, and no two files may share an ID prefix —
    # milestone_file_for_id resolves by prefix, so an ambiguous pair makes every
    # ID-based command unreliable.
    local ids duplicates
    ids="$(printf '%s\n' "$rows" | cut -f1)"
    duplicates="$(printf '%s\n' "$ids" | sort | uniq -d)"
    if [ -n "$duplicates" ]; then
        while IFS= read -r id; do
            [ -n "$id" ] || continue
            log_error "milestone ID ${id} is declared by more than one file:"
            printf '%s\n' "$rows" | awk -F'\t' -v want="$id" '$1 == want {print $6}' \
                | sed "s|^${IOSAI_ROOT}/|           |" >&2
            problems=$((problems + 1))
        done <<EOF
$duplicates
EOF
    fi

    local prefix count
    while IFS= read -r prefix; do
        [ -n "$prefix" ] || continue
        count="$(find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name "${prefix}-*.md" \
            2>/dev/null | wc -l | tr -d ' ')"
        if [ "${count:-0}" -gt 1 ]; then
            log_error "ambiguous milestone ID ${prefix}: ${count} files share that prefix"
            hint "every ID-based command resolves AI/milestones/${prefix}-*.md; keep one"
            problems=$((problems + 1))
        fi
    done <<EOF
$(find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
    | while IFS= read -r f; do basename -- "$f" .md | sed 's/-.*$//'; done | sort -u)
EOF

    # Dependencies: known, not self, and acyclic.
    local dep
    while IFS="$(printf '\t')" read -r id status _reserved deps title file; do
        [ -n "${file:-}" ] || continue
        while IFS= read -r dep; do
            [ -n "$dep" ] || continue
            if [ "$dep" = "$id" ]; then
                log_error "$(relpath "$file"): depends on itself"
                problems=$((problems + 1))
                continue
            fi
            if ! line_in_list "$dep" "$ids"; then
                log_error "$(relpath "$file"): depends on unknown milestone '${dep}'"
                problems=$((problems + 1))
            fi
        done <<INNER
$(dep_list "$deps")
INNER
    done <<EOF
$rows
EOF

    local edges unresolved
    edges="$(printf '%s\n' "$rows" | while IFS="$(printf '\t')" read -r id _s _o deps _t _f; do
        local d printed=0
        while IFS= read -r d; do
            [ -n "$d" ] || continue
            printf '%s\t%s\n' "$id" "$d"
            printed=1
        done <<INNER
$(dep_list "$deps")
INNER
        [ "$printed" -eq 1 ] || printf '%s\t\n' "$id"
    done)"

    unresolved="$(printf '%s\n' "$edges" | awk -F'\t' '
        { node[$1] = 1; if ($2 != "") { dep[$1] = dep[$1] " " $2 } }
        END {
            changed = 1
            while (changed) {
                changed = 0
                for (n in node) {
                    if (n in done) continue
                    ok = 1
                    split(dep[n], d, " ")
                    for (i in d) {
                        if (d[i] == "") continue
                        if (!(d[i] in node)) continue      # unknown IDs already reported
                        if (!(d[i] in done)) { ok = 0; break }
                    }
                    if (ok) { done[n] = 1; changed = 1 }
                }
            }
            for (n in node) if (!(n in done)) print n
        }' | sort)"

    if [ -n "$unresolved" ]; then
        log_error "dependency cycle detected among: $(printf '%s' "$unresolved" | tr '\n' ' ')"
        hint "a milestone graph must be acyclic or nothing can ever start"
        problems=$((problems + 1))
    fi

    # M00 proves the harness works, so every other milestone depends on it —
    # directly or through the graph. Skipped entirely if there is no M00.
    if line_in_list "M00" "$ids"; then
        while IFS="$(printf '\t')" read -r id status _reserved deps title file; do
            [ -n "${file:-}" ] || continue
            [ "$id" = "M00" ] && continue
            if ! milestone_reaches "M00" "$id" "$rows"; then
                log_error "$(relpath "$file"): does not depend on M00, directly or transitively"
                hint "M00 is what proves the verification harness works; everything after it"
                hint "inherits that proof. add M00 to '**Depends on:**', or to a dependency."
                problems=$((problems + 1))
            fi
        done <<EOF
$rows
EOF
    fi

    validate_generated_final_milestones || problems=$((problems + 1))

    [ "$problems" -eq 0 ]
}

# project_status_validate — keep only the compact continuity fields machine-readable.
project_status_validate() {
    local file="${IOSAI_ROOT}/AI/PROJECT_STATUS.md" problems=0

    if [ ! -f "$file" ]; then
        log_error "AI/PROJECT_STATUS.md is missing"
        return 1
    fi

    local label value length
    while IFS= read -r label; do
        [ -n "$label" ] || continue
        value="$(milestone_field "$file" "$label")"
        if [ -z "$value" ]; then
            log_error "AI/PROJECT_STATUS.md: no '**${label}:**' line"
            hint "every new session reads these compact continuity fields"
            problems=$((problems + 1))
            continue
        fi
        # A budget for a field a human and an agent both re-read every session, and
        # the fix is always the same one — the reasoning belongs in the record that
        # holds it.
        length="$(printf '%s' "$value" | wc -c | tr -d ' ')"
        if [ "$length" -gt "$IOSAI_STATUS_FIELD_MAX_BYTES" ]; then
            log_error "AI/PROJECT_STATUS.md: '**${label}:**' is ${length} bytes; the limit is ${IOSAI_STATUS_FIELD_MAX_BYTES}"
            hint "this field is compact state, not a log. move the reasoning into the"
            hint "audit or handoff record it belongs to and link that record here."
            problems=$((problems + 1))
        fi
    done <<EOF
$IOSAI_STATUS_REQUIRED_FIELDS
EOF

    local phase
    phase="$(milestone_field "$file" 'Phase')"
    if [ -n "$phase" ] && ! token_in_list "$phase" "$IOSAI_PROJECT_PHASES"; then
        log_error "AI/PROJECT_STATUS.md: **Phase:** '${phase}' is not one of the documented tokens"
        hint "allowed: ${IOSAI_PROJECT_PHASES}"
        hint "narrative belongs in the body, not in a machine-read field"
        problems=$((problems + 1))
    fi

    [ "$problems" -eq 0 ]
}

# ---------------------------------------------------------------------------
# The placeholder allowlist.
#
# An exception list is a contract too, and this one used to accept shell globs:
# `App/*.swift` exempted every shipped Swift file from the placeholder scan, so
# unfinished copy could pass a green static gate and a green release gate. Entries
# are now exact, non-shipping, reasoned, and dated.
#
#   <exact repository-relative path> | <reason> | <expiry YYYY-MM-DD>
# ---------------------------------------------------------------------------

IOSAI_PLACEHOLDER_ALLOWLIST="Config/placeholder-allowlist.txt"

# Path components that mark a file as non-shipping.
IOSAI_NONSHIPPING_COMPONENTS="Tests UITests Fixtures Documentation"

# placeholder_allowlist_paths — the exempt paths, one per line.
placeholder_allowlist_paths() {
    local file="${IOSAI_ROOT}/${IOSAI_PLACEHOLDER_ALLOWLIST}"
    [ -f "$file" ] || return 0
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in ""|\#*) continue ;; esac
        printf '%s\n' "${line%%|*}" | sed 's/[[:space:]]*$//'
    done < "$file"
    return 0
}

# placeholder_allowlist_validate — prints every problem; non-zero if any.
placeholder_allowlist_validate() {
    local file="${IOSAI_ROOT}/${IOSAI_PLACEHOLDER_ALLOWLIST}" problems=0 lineno=0
    [ -f "$file" ] || return 0

    local today line path reason expiry rest component nonshipping
    today="$(date -u +%Y-%m-%d)"

    while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        case "$line" in ""|\#*) continue ;; esac

        case "$line" in
            *"|"*"|"*) : ;;
            *)  log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: expected 'path | reason | expiry'"
                hint "offending line: ${line}"
                problems=$((problems + 1))
                continue ;;
        esac

        path="$(printf '%s' "${line%%|*}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        rest="${line#*|}"
        reason="$(printf '%s' "${rest%%|*}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        expiry="$(printf '%s' "${rest#*|}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

        case "$path" in
            *"*"*|*"?"*|*"["*|*"]"*)
                log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: '${path}' is a pattern, not a path"
                hint "a glob can exempt an entire product's sources from the scan"
                problems=$((problems + 1))
                continue ;;
        esac
        if [ "$path" = "Config/project.env" ]; then
            log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: Config/project.env can never be exempt"
            hint "the live build configuration must be real, not a sketch"
            problems=$((problems + 1))
            continue
        fi

        nonshipping="no"
        for component in $IOSAI_NONSHIPPING_COMPONENTS; do
            case "/${path}/" in *"/${component}/"*) nonshipping="yes" ;; esac
        done
        # "Preview Content" contains a space, so it is checked separately.
        case "/${path}/" in *"/Preview Content/"*) nonshipping="yes" ;; esac
        if [ "$nonshipping" != "yes" ]; then
            log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: '${path}' looks like shipping source"
            hint "only non-shipping paths may be exempt — a component of Tests/, UITests/,"
            hint "Fixtures/, Documentation/, or Preview Content/."
            hint "placeholder copy a user can reach is never an acceptable exception."
            problems=$((problems + 1))
            continue
        fi

        if ! field_is_answered "$reason"; then
            log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: '${path}' has no reason"
            problems=$((problems + 1))
        fi
        if ! printf '%s' "$expiry" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
            log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: '${expiry}' is not an expiry date (YYYY-MM-DD)"
            problems=$((problems + 1))
        elif ! printf '%s\n%s\n' "$today" "$expiry" | sort -c 2>/dev/null; then
            log_error "${IOSAI_PLACEHOLDER_ALLOWLIST}:${lineno}: the exemption for '${path}' expired on ${expiry}"
            hint "finish the text, or renew the entry deliberately with a new date"
            problems=$((problems + 1))
        fi
    done < "$file"

    [ "$problems" -eq 0 ]
}

# ---------------------------------------------------------------------------
# The credential scans and their exemption list.
#
# verify-static.sh refuses a committed file whose NAME is credential or signing
# material, and a file whose CONTENT carries a private key, a provider token, or
# credentials inside a URL. The lists live here because the exemption list below is
# validated against them: a rule a scan does not have cannot be excused, and a name
# no pattern matches has nothing to be excused from.
#
# Some legitimate committed files only look like secrets. Firebase's
# GoogleService-Info.plist carries an AIza… client key that Google designs to ship
# inside the app, an app that pins its server certificate bundles a public .cer, and
# a sign-in form's model is naturally called Credentials.swift. Before the list
# existed each of them failed `make static`, and therefore every strict gate, with a
# hint to "exempt the single file" that pointed at no mechanism at all — the only
# way through was weakening the scan, which AGENTS.md A5 forbids.
#
#   <exact repository-relative path> | <rule> | <reason> | <expiry YYYY-MM-DD>
#
# An entry excuses ONE path from ONE rule. The file is still scanned for every other
# rule, and the same bytes anywhere else still fail. A private key, a provider secret
# token, or signing material can never be listed.
# ---------------------------------------------------------------------------

IOSAI_CREDENTIAL_ALLOWLIST="Config/credential-scan-allowlist.txt"

# One pattern per line, matched as a `case` pattern against a file's basename and
# never pathname-expanded — see secret_name_matches.
IOSAI_SECRET_NAME_PATTERNS="*.p12
*.pem
*.cer
*.certSigningRequest
*.mobileprovision
*.provisionprofile
*.p8
*.jks
*.keystore
*.key
*.pfx
*.pkcs12
*.der
*.p7b
*.keychain
*.keychain-db
id_rsa*
id_dsa*
id_ecdsa*
id_ed25519*
.netrc
.env
.env.*
.dev.vars
.npmrc
.pypirc
.credentials
.credentials.*
.secrets
.secrets.*
credentials
credentials.*
Credentials
Credentials.*
secrets
secrets.*
Secrets
Secrets.*
*Credentials*.plist
*credentials*.plist
AuthKey_*.p8"

# Names no entry may excuse: private keys, keystores, signing identities, and
# provisioning material. Several are binary, so no content scan could notice a key
# inside one, and none of them is ever a legitimate committed file in an app.
IOSAI_SECRET_NAME_NOT_EXEMPTABLE="*.p12
*.pfx
*.pkcs12
*.p8
AuthKey_*.p8
*.jks
*.keystore
*.keychain
*.keychain-db
*.key
*.mobileprovision
*.provisionprofile
*.certSigningRequest
id_rsa*
id_dsa*
id_ecdsa*
id_ed25519*"

# Content classes, each with one pattern in verify-static.sh, and the subset a file
# may be excused from. Every other class is a real secret wherever it appears.
IOSAI_SECRET_CLASSES="private-key openssh-private-key aws-access-key anthropic-key
github-token slack-token google-api-key stripe-secret-key npm-token
url-credentials"
IOSAI_SECRET_CLASSES_EXEMPTABLE="google-api-key url-credentials"

# secret_name_matches <basename> <newline-separated-patterns>
#
# The pattern stays unquoted in the `case` arm on purpose: that makes it a pattern,
# and a `case` pattern is matched, never pathname-expanded, so repository contents
# cannot rewrite which names are checked.
secret_name_matches() {
    local base="$1" pattern
    while IFS= read -r pattern; do
        [ -n "$pattern" ] || continue
        case "$base" in
            $pattern) return 0 ;;
        esac
    done <<EOF
${2:-}
EOF
    return 1
}

# credential_allowlist_scan — print "<path><TAB><rule>" for every valid entry, and
# every problem on stderr. Returns non-zero when there is any problem.
#
# One parser serves both consumers, so the entries verify-static.sh honours are
# exactly the ones verify-template.sh calls valid: validation discards the list,
# and application discards the problems, which template validation has already
# reported as a failure of the same run.
credential_allowlist_scan() {
    local file="${IOSAI_ROOT}/${IOSAI_CREDENTIAL_ALLOWLIST}" problems=0 lineno=0
    [ -f "$file" ] || return 0

    local today line path rule reason expiry rest base seen="" entry valid
    today="$(date -u +%Y-%m-%d)"

    while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        case "$line" in ""|\#*) continue ;; esac

        case "$line" in
            *"|"*"|"*"|"*) : ;;
            *)  log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: expected 'path | rule | reason | expiry'"
                problems=$((problems + 1))
                continue ;;
        esac

        path="$(printf '%s' "${line%%|*}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        rest="${line#*|}"
        rule="$(printf '%s' "${rest%%|*}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        rest="${rest#*|}"
        reason="$(printf '%s' "${rest%%|*}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        expiry="$(printf '%s' "${rest#*|}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        valid="yes"

        case "$path" in
            "")
                log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: an entry needs a path"
                valid="no" ;;
            *"*"*|*"?"*|*"["*|*"]"*)
                log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' is a pattern, not a path"
                hint "an exemption names exactly one file; a glob could excuse a whole tree"
                valid="no" ;;
            /*|..|../*|*/../*|*/..|./*)
                log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' is not a plain repository-relative path"
                valid="no" ;;
        esac

        base="${path##*/}"
        case "$rule" in
            filename)
                if [ -n "$path" ] && secret_name_matches "$base" "$IOSAI_SECRET_NAME_NOT_EXEMPTABLE"; then
                    log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' is a private key or signing material and can never be exempted"
                    hint "move it out of the repository; a key that reached a working tree is exposed"
                    valid="no"
                elif [ -n "$path" ] && ! secret_name_matches "$base" "$IOSAI_SECRET_NAME_PATTERNS"; then
                    log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' matches no credential filename pattern; there is nothing to exempt"
                    valid="no"
                fi ;;
            "")
                log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: an entry needs a rule"
                valid="no" ;;
            *)
                if token_in_list "$rule" "$IOSAI_SECRET_CLASSES_EXEMPTABLE"; then
                    :
                elif token_in_list "$rule" "$IOSAI_SECRET_CLASSES"; then
                    log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: the ${rule} rule can never be exempted"
                    hint "a private key or provider secret is a secret wherever it appears:"
                    hint "move it out of the repository and rotate it"
                    valid="no"
                else
                    log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: unknown rule '${rule}'"
                    hint "use filename, or one of: ${IOSAI_SECRET_CLASSES_EXEMPTABLE}"
                    valid="no"
                fi ;;
        esac

        if ! field_is_answered "$reason"; then
            log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' has no reason"
            valid="no"
        fi
        if ! printf '%s' "$expiry" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
            log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${expiry}' is not an expiry date (YYYY-MM-DD)"
            valid="no"
        elif ! printf '%s\n%s\n' "$today" "$expiry" | sort -c 2>/dev/null; then
            log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: the exemption for '${path}' expired on ${expiry}"
            hint "remove the file, or renew the entry deliberately with a new date"
            valid="no"
        fi

        entry="${path}	${rule}"
        if [ "$valid" = "yes" ] && line_in_list "$entry" "$seen"; then
            log_error "${IOSAI_CREDENTIAL_ALLOWLIST}:${lineno}: '${path}' is listed twice for ${rule}"
            valid="no"
        fi

        if [ "$valid" = "yes" ]; then
            seen="${seen}${entry}
"
            printf '%s\n' "$entry"
        else
            problems=$((problems + 1))
        fi
    done < "$file"

    [ "$problems" -eq 0 ]
}

# credential_exempt <relative-path> <rule> <entries> — is this exact pair excused?
credential_exempt() {
    line_in_list "${1}	${2}" "${3:-}"
}

# ---------------------------------------------------------------------------
# Release coverage.
#
# The six Final Product Polish domains own one machine-readable inventory. All
# applicable coverage is completed in the committed consolidated record before
# readiness. The subsequent human distribution checklist does not defer audit work.
# ---------------------------------------------------------------------------

IOSAI_RELEASE_COVERAGE_FILE="${IOSAI_ROOT}/Config/release-requirements.v3.tsv"
IOSAI_RELEASE_COVERAGE_SCHEMA="release-requirements/3"

# field_is_answered <value> — non-empty, and not left as a placeholder.
field_is_answered() {
    local value="${1:-}"
    [ -n "$value" ] || return 1
    case "$value" in
        *TBD*|*FIXME*|*REPLACE_ME*|-|none|None|NONE) return 1 ;;
    esac
    return 0
}

# validate_release_coverage_schema — validate the maintained audit inventory.
validate_release_coverage_schema() {
    local file="$IOSAI_RELEASE_COVERAGE_FILE"
    [ -f "$file" ] || { log_error "release coverage schema is missing: $(relpath "$file")"; return 1; }

    awk -F '\t' -v expected="$IOSAI_RELEASE_COVERAGE_SCHEMA" '
        BEGIN { problems = 0 }
        NR == 1 {
            if ($0 != "# schema: " expected) {
                print "release coverage header is invalid: " $0 > "/dev/stderr"
                problems++
            }
            next
        }
        NR == 2 {
            if ($0 != "# id\tchannel\tdomains\tallow_inapplicable\tdescription") {
                print "release coverage columns are invalid: " $0 > "/dev/stderr"
                problems++
            }
            next
        }
        /^#/ || /^[[:space:]]*$/ { next }
        {
            if (NF != 5) {
                print "release coverage line " NR " has " NF " fields; expected 5" > "/dev/stderr"
                problems++
                next
            }
            if ($1 !~ /^REL-[0-9]+$/) {
                print "release coverage line " NR " has invalid ID: " $1 > "/dev/stderr"
                problems++
            }
            if (seen[$1]++) {
                print "release coverage duplicates ID: " $1 > "/dev/stderr"
                problems++
            }
            if ($2 != "all" && $2 != "app-store" && $2 != "internal") {
                print "release coverage " $1 " has invalid channel: " $2 > "/dev/stderr"
                problems++
            }
            count = split($3, domains, ",")
            delete domain_seen
            if (count < 1) {
                print "release coverage " $1 " has no audit domain" > "/dev/stderr"
                problems++
            }
            for (i = 1; i <= count; i++) {
                if (domains[i] != "functional" && domains[i] != "ui-ux" &&
                    domains[i] != "content" && domains[i] != "accessibility" &&
                    domains[i] != "product" && domains[i] != "release") {
                    print "release coverage " $1 " has invalid audit domain: " domains[i] > "/dev/stderr"
                    problems++
                }
                if (domain_seen[domains[i]]++) {
                    print "release coverage " $1 " duplicates audit domain: " domains[i] > "/dev/stderr"
                    problems++
                }
            }
            if ($4 != "yes" && $4 != "no") {
                print "release coverage " $1 " has invalid inapplicable policy: " $4 > "/dev/stderr"
                problems++
            }
            if ($5 == "") {
                print "release coverage " $1 " has no description" > "/dev/stderr"
                problems++
            }
        }
        END {
            exit(problems == 0 ? 0 : 1)
        }
    ' "$file"
}

# release_coverage_rows <domain> <channel> — rows owned by an audit domain and
# applicable to the configured distribution channel.
release_coverage_rows() {
    local domain="$1" channel="$2"
    validate_release_coverage_schema || return "$EX_VERIFY"
    awk -F '\t' -v domain="$domain" -v channel="$channel" '
        !/^#/ && NF == 5 && ($2 == "all" || $2 == channel) {
            count = split($3, domains, ",")
            for (i = 1; i <= count; i++) {
                if (domains[i] == domain) { print; break }
            }
        }
    ' "$IOSAI_RELEASE_COVERAGE_FILE"
}

release_coverage_ids() {
    release_coverage_rows "$1" "$2" | cut -f1
}

release_coverage_allows_inapplicable() {
    local id="$1" domain="$2" channel="$3"
    # Narrow platform exception; the inventory remains mandatory for iOS.
    case "$(app_platform):$id" in
        watchOS:REL-208|watchOS:REL-209)
            if [ "${WATCH_APP_MODE-watch-only}" = companion ]; then
                release_coverage_rows "$domain" "$channel" | awk -F '\t' -v id="$id" '$1 == id { found=1 } END { if (!found) exit 1; print "no" }'
                return $?
            fi
            release_coverage_rows "$domain" "$channel" | awk -F '\t' -v id="$id" \
                '$1 == id { found=1 } END { if (!found) exit 1; print "yes" }'
            return $? ;;
    esac
    # Reads every row: stopping at the match could SIGPIPE the producer, and pipefail
    # would then turn a permitted INAPPLICABLE into a refused one.
    release_coverage_rows "$domain" "$channel" \
        | awk -F '\t' -v id="$id" '$1 == id && !found { print $4; found = 1 } END { if (!found) exit 1 }'
}

coverage_evidence_value_valid() {
    local value="${1:-}"
    field_is_answered "$value" || return 1
    printf '%s' "$value" \
        | grep -Eiq '^(skipped|not[ -]?run|not[ -]?performed|n/?a|none|empty|unknown)([ :._-].*)?$' \
        && return 1
    return 0
}

coverage_inapplicable_reason_valid() {
    local value="${1:-}"
    coverage_evidence_value_valid "$value" || return 1
    printf '%s' "$value" | grep -Eiq \
        '((environment|device|simulator|hardware|service|account|credential|network|tool).*(unavailable|not available|missing|inaccessible|offline)|(unavailable|not available|missing|inaccessible|offline).*(environment|device|simulator|hardware|service|account|credential|network|tool))' \
        && return 1
    return 0
}

# validate_domain_audit_coverage <record> <domain> <channel>
#
# Coverage rows use one stable, grep-friendly form:
#   - REL-101 | OUTCOME=VERIFIED | EVIDENCE=<command, environment, or observation>
#   - REL-103 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=<product-specific reason>
validate_domain_audit_coverage() {
    local file="$1" domain="$2" channel="$3" heading="${4:-## Coverage}"
    local problems=0 required coverage_block malformed present id count line row_id outcome evidence allowed reason

    if [ ! -f "$file" ]; then
        log_error "domain audit record is missing: $(relpath "$file")"
        return 1
    fi
    if [ "$(machine_field_count "$file" 'Coverage result')" -ne 1 ] \
       || [ "$(milestone_field "$file" 'Coverage result')" != "COMPLETE" ]; then
        log_error "$(relpath "$file"): **Coverage result:** must be COMPLETE"
        problems=$((problems + 1))
    fi
    if [ "$(machine_field_count "$file" 'Open P0/P1')" -ne 1 ] \
       || [ "$(milestone_field "$file" 'Open P0/P1')" != "0" ]; then
        log_error "$(relpath "$file"): **Open P0/P1:** must be 0"
        problems=$((problems + 1))
    fi

    required="$(release_coverage_ids "$domain" "$channel")" || return 1
    if [ "$(grep -Fxc "$heading" "$file" || true)" -ne 1 ]; then
        log_error "$(relpath "$file"): requires exactly one ${heading} section"
        problems=$((problems + 1))
    fi
    coverage_block="$(awk -v heading="$heading" '
        $0 == heading { inside=1; found=1; next }
        /^## / && inside { exit }
        inside { print }
        END { if (!found) exit 1 }
    ' "$file" 2>/dev/null)" || {
        log_error "$(relpath "$file"): missing ## Coverage section"
        problems=$((problems + 1))
        coverage_block=""
    }
    malformed="$(printf '%s\n' "$coverage_block" | grep -E '^- REL-' \
        | grep -Ev '^- REL-[0-9]+ \| OUTCOME=[A-Z]+ \| EVIDENCE=.+$' || true)"
    if [ -n "$malformed" ]; then
        log_error "$(relpath "$file"): malformed row in ## Coverage"
        printf '%s\n' "$malformed" | sed 's/^/           /' >&2
        problems=$((problems + 1))
    fi
    present="$(printf '%s\n' "$coverage_block" \
        | grep -E '^- REL-[0-9]+ \| OUTCOME=[A-Z]+ \| EVIDENCE=.+$' \
        | sed -E 's/^- (REL-[0-9]+).*/\1/' || true)"

    while IFS= read -r id; do
        [ -n "$id" ] || continue
        count="$(printf '%s\n' "$present" | grep -Fxc "$id" || true)"
        [ "$count" -eq 1 ] || {
            log_error "$(relpath "$file"): coverage requires ${id} exactly once, found ${count}"
            problems=$((problems + 1))
        }
    done <<EOF
$required
EOF

    while IFS= read -r id; do
        [ -n "$id" ] || continue
        if ! line_in_list "$id" "$required"; then
            log_error "$(relpath "$file"): ${id} is not assigned to ${domain} for ${channel}"
            problems=$((problems + 1))
        fi
    done <<EOF
$(printf '%s\n' "$present" | sort -u)
EOF

    while IFS= read -r line; do
        [ -n "$line" ] || continue
        row_id="$(printf '%s' "$line" | sed -E 's/^- (REL-[0-9]+).*/\1/')"
        outcome="$(printf '%s' "$line" | sed -E 's/.*\| OUTCOME=([A-Z]+) \| EVIDENCE=.*/\1/')"
        evidence="$(printf '%s' "$line" | sed -E 's/.*\| EVIDENCE=//; s/^[[:space:]]*//; s/[[:space:]]*$//')"
        case "$outcome" in
            VERIFIED)
                if ! coverage_evidence_value_valid "$evidence"; then
                    log_error "$(relpath "$file"): ${row_id} VERIFIED requires concrete evidence"
                    problems=$((problems + 1))
                fi ;;
            INAPPLICABLE)
                allowed="$(release_coverage_allows_inapplicable "$row_id" "$domain" "$channel" 2>/dev/null || printf 'no')"
                case "$evidence" in reason=*) reason="${evidence#reason=}" ;; *) reason="" ;; esac
                if [ "$allowed" != "yes" ]; then
                    log_error "$(relpath "$file"): ${row_id} does not permit INAPPLICABLE"
                    problems=$((problems + 1))
                elif ! coverage_inapplicable_reason_valid "$reason"; then
                    log_error "$(relpath "$file"): ${row_id} INAPPLICABLE requires EVIDENCE=reason=<specific reason>"
                    hint "an unavailable required environment blocks the audit; it is not INAPPLICABLE"
                    problems=$((problems + 1))
                fi ;;
            *)
                log_error "$(relpath "$file"): ${row_id} has unsupported coverage outcome ${outcome}"
                hint "allowed outcomes are VERIFIED and permitted INAPPLICABLE"
                problems=$((problems + 1)) ;;
        esac
    done <<EOF
$(printf '%s\n' "$coverage_block" \
    | grep -E '^- REL-[0-9]+ \| OUTCOME=[A-Z]+ \| EVIDENCE=.*$' || true)
EOF

    [ "$problems" -eq 0 ]
}

# validate_final_polish_coverage <record> <milestone-id> <channel>
# One record contains all six ordered domain sections, each with complete coverage.
validate_final_polish_coverage() {
    local file="$1" id="$2" channel="$3" domain headings expected problems=0
    if [ "$file" != "${IOSAI_ROOT}/AI/audits/${id}-final-polish.md" ] \
       || [ ! -f "$file" ] || ! assert_no_symlink_ancestry "$file"; then
        log_error "missing or unsafe consolidated Final Product Polish record: ${file}"
        return 1
    fi
    local field value wanted
    for field in 'Policy status' Milestone 'Distribution channel'; do
        case "$field" in
            'Policy status') wanted=current ;;
            Milestone) wanted="$id" ;;
            'Distribution channel') wanted="$channel" ;;
        esac
        value="$(milestone_field "$file" "$field")"
        if [ "$(machine_field_count "$file" "$field")" -ne 1 ] || [ "$value" != "$wanted" ]; then
            log_error "$(relpath "$file"): ${field} must be ${wanted}"
            problems=$((problems + 1))
        fi
    done
    headings="$(grep '^## Coverage:' "$file" || true)"
    expected="$(printf '## Coverage: %s\n' functional ui-ux content accessibility product release)"
    if [ "$headings" != "$expected" ]; then
        log_error "$(relpath "$file"): requires the six ordered domain coverage sections"
        problems=$((problems + 1))
    fi
    for domain in functional ui-ux content accessibility product release; do
        validate_domain_audit_coverage "$file" "$domain" "$channel" "## Coverage: ${domain}" \
            || problems=$((problems + 1))
    done
    [ "$problems" -eq 0 ]
}

# validate_release_revalidation_audits <milestone> <channel> <milestone-rows>
#
# A later candidate must declare every affected audit domain and point at the
# corresponding targeted audit record. Each record carries the same complete,
# typed coverage contract as an initial final-domain audit and belongs to a DONE
# milestone in the appended sequence.
validate_release_revalidation_audits() {
    local milestone="$1" channel="$2" rows="$3"
    local domains domain normalized="" seen="" record_rel record_name record record_id record_status problems=0

    domains="$(milestone_field "$milestone" 'Revalidated domains')"
    if ! field_is_answered "$domains"; then
        log_error "$(relpath "$milestone"): **Revalidated domains:** is required"
        return 1
    fi

    while IFS= read -r domain; do
        domain="$(printf '%s' "$domain" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        [ -n "$domain" ] || continue
        case "$domain" in
            functional|ui-ux|content|accessibility|product|release) : ;;
            *)
                log_error "$(relpath "$milestone"): invalid revalidated domain: ${domain}"
                problems=$((problems + 1))
                continue ;;
        esac
        if line_in_list "$domain" "$seen"; then
            log_error "$(relpath "$milestone"): duplicate revalidated domain: ${domain}"
            problems=$((problems + 1))
            continue
        fi
        seen="${seen}${domain}
"
        normalized="${normalized}${normalized:+,}${domain}"

        record_rel="$(milestone_field "$milestone" "${domain} revalidation record")"
        case "$record_rel" in
            AI/audits/*.md) : ;;
            *)
                log_error "$(relpath "$milestone"): **${domain} revalidation record:** must name AI/audits/*.md"
                problems=$((problems + 1))
                continue ;;
        esac
        record_name="${record_rel#AI/audits/}"
        case "$record_name" in
            ''|.*|*/*|*..*)
                log_error "$(relpath "$milestone"): unsafe targeted audit record path: ${record_rel}"
                problems=$((problems + 1))
                continue ;;
        esac
        record="${IOSAI_ROOT}/${record_rel}"
        if [ ! -f "$record" ] || [ -L "$record" ]; then
            log_error "$(relpath "$milestone"): targeted audit record is missing or unsafe: ${record_rel}"
            problems=$((problems + 1))
            continue
        fi
        if ! validate_domain_audit_coverage "$record" "$domain" "$channel"; then
            log_error "${record_rel}: targeted ${domain} audit coverage is incomplete"
            problems=$((problems + 1))
        fi

        record_id="$(milestone_field "$record" Milestone)"
        record_status="$(printf '%s\n' "$rows" | awk -F '\t' -v id="$record_id" '$1 == id && !found { print $2; found = 1 }')"
        if [ -z "$record_id" ] || [ "$record_status" != "DONE" ]; then
            log_error "${record_rel}: owning milestone ${record_id:-(missing)} is ${record_status:-(missing)}, expected DONE"
            problems=$((problems + 1))
        fi
    done <<EOF
$(printf '%s' "$domains" | tr ',' '\n')
EOF

    if [ -z "$normalized" ]; then
        log_error "$(relpath "$milestone"): no valid revalidated domain was declared"
        problems=$((problems + 1))
    fi

    [ "$problems" -eq 0 ]
}

# validate_release_workflow_readiness <channel> — release verification is valid
# only from the REVIEW commit of Final Product Polish (or a later readiness
# revalidation), with all six domains complete in the consolidated record.
validate_release_workflow_readiness() {
    local channel="$1" rows file title status active_file="" active_count=0 problems=0
    rows="$(milestone_rows)"

    while IFS="$(printf '\t')" read -r _id status _reserved _deps _title file; do
        [ -n "${file:-}" ] || continue
        title="$(milestone_display_title "$file")"
        if [ "$status" = "REVIEW" ] \
           && { [ "$title" = "Final Product Polish" ] \
                || [ "$title" = "Release Readiness Revalidation" ]; }; then
            active_file="$file"
            active_count=$((active_count + 1))
        fi
    done <<EOF
$rows
EOF

    if [ "$active_count" -ne 1 ]; then
        log_error "release verification requires exactly one readiness milestone in REVIEW, found ${active_count}"
        hint "run it from Final Product Polish or Release Readiness Revalidation"
        return 1
    fi

    if [ "$(milestone_display_title "$active_file")" = "Release Readiness Revalidation" ]; then
        validate_release_revalidation_audits "$active_file" "$channel" "$rows" \
            || problems=$((problems + 1))
    fi

    local dep dep_status
    while IFS= read -r dep; do
        [ -n "$dep" ] || continue
        dep_status="$(printf '%s\n' "$rows" | awk -F '\t' -v d="$dep" '$1 == d && !found { print $2; found = 1 }')"
        if [ "$dep_status" != "DONE" ]; then
            log_error "$(relpath "$active_file"): dependency ${dep} is ${dep_status:-(missing)}, expected DONE"
            problems=$((problems + 1))
        fi
    done <<EOF
$(dep_list "$(milestone_field "$active_file" 'Depends on')")
EOF

    local blockers
    blockers="$(milestone_field "${IOSAI_ROOT}/AI/PROJECT_STATUS.md" 'Blockers')"
    case "$blockers" in
        none|None|NONE|'none.'|'None.') : ;;
        *)
            log_error "release readiness has an open project blocker: ${blockers:-(unrecorded)}"
            problems=$((problems + 1)) ;;
    esac

    local found="" record record_id
    while IFS="$(printf '\t')" read -r _id status _reserved _deps _title file; do
        [ -n "${file:-}" ] || continue
        if [ "$(milestone_display_title "$file")" = 'Final Product Polish' ]; then
            if [ -n "$found" ]; then
                log_error "release workflow has more than one Final Product Polish milestone"
                problems=$((problems + 1))
                continue
            fi
            found="$file"
            if [ "$file" != "$active_file" ] && [ "$status" != DONE ]; then
                log_error "$(relpath "$file"): original Final Product Polish must be DONE before revalidation"
                problems=$((problems + 1))
            fi
        fi
    done <<EOF
$rows
EOF
    if [ -z "$found" ]; then
        log_error "release workflow is missing Final Product Polish"
        return 1
    fi
    record="$(milestone_field "$found" 'Audit record')"
    record_id="$(milestone_field "$found" ID)"
    if [ "$(milestone_display_title "$active_file")" = 'Release Readiness Revalidation' ] \
       && [ "${WATCH_APP_MODE-watch-only}" = companion ] \
       && grep -Eq '^- REL-20[89] \| OUTCOME=INAPPLICABLE \|' "${IOSAI_ROOT}/${record}"; then
        validate_watch_companion_transition "$found" "$active_file" "${IOSAI_ROOT}/${record}" "$record_id" "$channel" \
            || problems=$((problems + 1))
    else
        validate_final_polish_coverage "${IOSAI_ROOT}/${record}" "$record_id" "$channel" \
            || problems=$((problems + 1))
    fi

    [ "$problems" -eq 0 ]
}

# The original Watch-only audit describes its own verified configuration. Adding
# an iPhone companion requires six CURRENT domain records (validated above), while
# preserving the historical rating-row applicability. Never apply this context to
# current revalidation records or infer it just from an INAPPLICABLE explanation.
validate_watch_companion_transition() (
    local original="$1" current="$2" record="$3" id="$4" channel="$5"
    local domain domains handoff sha config
    domains="$(milestone_field "$current" 'Revalidated domains' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    for domain in functional ui-ux content accessibility product release; do
        if ! line_in_list "$domain" "$domains"; then
            log_error 'Watch-to-companion transition requires all six current audit domains'
            return 1
        fi
    done
    handoff="${IOSAI_ROOT}/$(milestone_field "$original" Handoff)"
    [ -f "$handoff" ] && [ ! -L "$handoff" ] || return 1
    sha="$(awk -F '|' '$2 ~ /^[[:space:]]*Verified SHA[[:space:]]*$/ {
        value=$3; gsub(/[`[:space:]]/, "", value); print value
    }' "$handoff")"
    if ! printf '%s\n' "$sha" | grep -Eq '^[0-9a-f]{40}$' \
       || [ "$(printf '%s\n' "$sha" | wc -l | tr -d ' ')" != 1 ] \
       || ! git cat-file -e "${sha}^{commit}" 2>/dev/null; then
        log_error 'historical Watch audit needs one available full Verified SHA in its handoff'
        return 1
    fi
    config="$(mktemp "${TMPDIR:-/tmp}/iosai-historical-config.XXXXXX")" || return 1
    trap 'rm -f "$config"' EXIT
    git show "${sha}:Config/project.env" > "$config" || return 1
    APP_PLATFORM=iOS
    WATCH_APP_MODE=watch-only
    COMPANION_PROFILE=''
    env_file_load "$config"
    if [ "$(app_platform)" != watchOS ] || [ "$WATCH_APP_MODE" != watch-only ]; then
        log_error 'historical rating exceptions require a verified Watch-only configuration'
        return 1
    fi
    validate_final_polish_coverage "$record" "$id" "$channel"
)

# prepare_human_release_checklist <sha> <channel> <candidate-id>
# Human work follows automated readiness. Pending rows are reported, never passed;
# existing evidence is preserved and validated against this exact candidate.
prepare_human_release_checklist() {
    local sha="$1" channel="$2" candidate="$3" file parent tmp
    parent="${IOSAI_ARTIFACTS_DIR}/release-checklists/${sha}"
    file="${parent}/checklist.md"
    ensure_artifact_directory "$parent"
    assert_no_symlink_ancestry "$file" || return 1
    if [ ! -e "$file" ]; then
        tmp="$(mktemp "${parent}/.checklist.tmp.XXXXXX")" || return 1
        {
            printf '# Human release checklist\n\n'
            printf '**Schema:** human-release/1\n'
            printf '**Candidate commit:** %s\n' "$sha"
            printf '**Candidate:** %s\n' "$candidate"
            printf '**Distribution channel:** %s\n\n' "$channel"
            printf 'READY_FOR_HUMAN is not publication approval. Complete these steps in order.\n'
            printf 'For VERIFIED, replace - with who=<person>; date=<UTC date>; result=<observation>.\n'
            printf 'Preserve this checklist with the release report in a committed release record.\n\n'
            printf '## Human work\n\n'
            printf '1. Subjective review of this candidate on a real device.\n'
            printf '2. Product > Archive in Xcode from this candidate; validate in Organizer.\n'
            printf '3. Developer decides whether to distribute through the configured channel.\n\n'
            printf -- '- HUMAN-01 | OUTCOME=PENDING | EVIDENCE=-\n'
            printf -- '- HUMAN-02 | OUTCOME=PENDING | EVIDENCE=-\n'
            printf -- '- HUMAN-03 | OUTCOME=PENDING | EVIDENCE=-\n'
        } > "$tmp"
        atomic_replace_file_no_follow "$tmp" "$file" "$IOSAI_ARTIFACTS_DIR"
    fi
    [ -f "$file" ] || return 1
    awk -v sha="$sha" -v channel="$channel" -v candidate="$candidate" '
        BEGIN { expected["**Schema:**"]="human-release/1";
                expected["**Candidate commit:**"]=sha;
                expected["**Candidate:**"]=candidate;
                expected["**Distribution channel:**"]=channel }
        /^\*\*/ {
            key=$0; sub(/ .*/, "", key)
            # Labels can contain spaces, so split at the closing bold marker.
            end=index($0, ":** ")
            if (!end) { bad=1; next }
            key=substr($0,1,end+2); value=substr($0,end+4)
            if (!(key in expected) || value != expected[key] || seen[key]++) bad=1
        }
        /^- / {
            n=split($0, parts, " \\| ")
            id=parts[1]; sub(/^- /,"",id)
            if (n != 3 || id !~ /^HUMAN-0[123]$/ || rows[id]++) { bad=1; next }
            if (parts[2] == "OUTCOME=PENDING") {
                if (parts[3] != "EVIDENCE=-") bad=1
                pending++
            } else if (parts[2] == "OUTCOME=VERIFIED") {
                if (parts[3] !~ /^EVIDENCE=who=[^;]+; date=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]; result=.+$/ ||
                    parts[3] ~ /TBD|FIXME|REPLACE_ME|<|>/) bad=1
            } else bad=1
        }
        END {
            for (key in expected) if (seen[key] != 1) bad=1
            for (i=1;i<=3;i++) if (rows["HUMAN-0" i] != 1) bad=1
            if (bad) { print "human checklist is invalid or bound to another candidate" > "/dev/stderr"; exit 1 }
            print pending+0
        }
    ' "$file"
}

# ---------------------------------------------------------------------------
# Reports
# ---------------------------------------------------------------------------

# report_header <file> <title> — begins a report with the bold-label front
# matter this template uses everywhere.
#
# When a strict gate is executing from an immutable candidate worktree, the
# reader's repository is the PUBLISHING checkout, not the temporary snapshot
# IOSAI_ROOT points at. The header used to name a `/private/var/folders/...`
# path that no longer exists by the time anybody opens the report, and record
# `**Branch:** HEAD` because the snapshot is detached. IOSAI_EVIDENCE_ROOT is
# set by those gates and is preferred here.
IOSAI_EVIDENCE_ROOT=""
report_header() {
    local file="$1" title="$2" parent tmp repo branch
    parent="$(dirname -- "$file")"
    ensure_artifact_directory "$parent"
    repo="${IOSAI_EVIDENCE_ROOT:-$IOSAI_ROOT}"
    tmp="$(mktemp "${parent}/.report.tmp.XXXXXX")" \
        || die "$EX_CANTCREAT" "cannot create report temporary"
    {
        printf '# %s\n\n' "$title"
        printf '**Generated:** %s\n' "$(utc_stamp)"
        printf '**Repository:** `%s`\n' "$repo"
        # Only when the verified source really is a separate read-only snapshot.
        # A gate that runs in its own checkout sets IOSAI_EVIDENCE_ROOT to that
        # same path, and this line then claimed a candidate worktree that never
        # existed — the clean-HEAD milestone report said so on every run.
        if [ -n "$IOSAI_EVIDENCE_ROOT" ] && [ "$IOSAI_EVIDENCE_ROOT" != "$IOSAI_ROOT" ]; then
            printf '**Verified source:** `%s` (read-only candidate worktree)\n' "$IOSAI_ROOT"
        fi
        printf '**Mode:** %s\n' "${IOSAI_REPO_MODE:-unknown}"
        if in_git_repo && git_has_commits; then
            printf '**HEAD:** `%s`\n' "$(git -C "$IOSAI_ROOT" rev-parse HEAD)"
            branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'HEAD')"
            printf '**Branch:** %s\n' "$branch"
        else
            printf '**HEAD:** (no commits)\n'
        fi
        printf '\n'
    } > "$tmp"
    atomic_replace_file_no_follow "$tmp" "$file" "$IOSAI_ARTIFACTS_DIR"
}

report_line() {
    local file="$1" line="$2" parent
    parent="$(dirname -- "$file")"
    ensure_artifact_directory "$parent"
    assert_path_inside "$file" "$IOSAI_ARTIFACTS_DIR" \
        || die "$EX_USAGE" "report target escapes .artifacts/: ${file}"
    assert_no_symlink_ancestry "$file" || exit "$EX_USAGE"
    if [ ! -e "$file" ]; then
        atomic_write_line_no_follow "$file" "$line" "$IOSAI_ARTIFACTS_DIR"
        return 0
    fi
    if [ ! -f "$file" ] || [ -L "$file" ]; then
        die "$EX_USAGE" "report target is not a regular file: ${file}"
    fi
    printf '%s\n' "$line" >> "$file"
    assert_no_symlink_ancestry "$file" || exit "$EX_USAGE"
}

# report_verdict_guard <report> — a failing exit never leaves a report without a
# verdict.
#
# Each gate writes a `**Verdict:**` line on the failure paths it anticipates, but a
# `die` inside a shared helper exits without one: the closing candidate-integrity
# recheck, a result bundle whose counts refuse, a configuration refusal after the
# report was opened. An audit watched the milestone report stop after its command
# list when Xcode rewrote a file mid-gate, so a reader had to learn from the console
# that the run had failed. This EXIT trap writes the missing verdict with the raw
# exit code, and the console still states the reason.
#
# Not for verify-release.sh, whose own trap maps every exit to the verdict token
# and exit code the release contract fixes.
IOSAI_GUARDED_REPORT=""
_iosai_report_verdict_on_exit() {
    local status=$?
    trap - EXIT
    simulator_release
    if [ "$status" -ne 0 ] && [ -n "$IOSAI_GUARDED_REPORT" ] \
       && [ -f "$IOSAI_GUARDED_REPORT" ] && [ ! -L "$IOSAI_GUARDED_REPORT" ] \
       && ! grep -q '^\*\*Verdict:\*\*' "$IOSAI_GUARDED_REPORT" 2>/dev/null; then
        # In a subshell: report_line dies on a path it cannot trust, and a second
        # failure inside an exit handler must not replace the gate's own exit code.
        ( report_line "$IOSAI_GUARDED_REPORT" ""
          report_line "$IOSAI_GUARDED_REPORT" "## Result"
          report_line "$IOSAI_GUARDED_REPORT" ""
          report_line "$IOSAI_GUARDED_REPORT" "**Verdict:** FAILED (exit ${status}; the console output states the reason)"
        ) >/dev/null 2>&1 || true
    fi
    exit "$status"
}
report_verdict_guard() {
    IOSAI_GUARDED_REPORT="${1:-}"
    trap _iosai_report_verdict_on_exit EXIT
}

# ---------------------------------------------------------------------------
# Repository-wide scanning helpers.
#
# These walk the filesystem rather than using `git ls-files`: the template
# repository has no commits, and a localization worktree may hold new untracked
# sources that still have to pass every check.
# ---------------------------------------------------------------------------

# repo_files [find-expression...] — every candidate file, excluding version
# control, evidence, and build output.
#
# The prune list names the ignored build-output and editor-state directories
# (assert_no_nested_app_repositories prunes the same ones): a directory that holds
# generated output or editor state is not repository content, and walking it
# made the secret and placeholder scans read IDE caches for no benefit.
#
# Vendored dependency trees (Pods/, Carthage/) are pruned for the same reason,
# and for a second one: they routinely ship .pem/.key/.der test fixtures of their
# own, so scanning them reported somebody else's test certificate as this
# project's leaked credential and failed every gate. What a dependency vendors is
# not this repository's secret to find.
#
# A supplied expression is GROUPED before -print. Without the parentheses,
# `repo_files -name '*.md' -o -name '*.sh'` binds as
# `(… -prune) -o (-type f -a -name '*.md') -o (-name '*.sh') -o (-name X -a -print)`
# because -o outranks the implicit -a — so only the last alternative printed
# anything. The merge-conflict scan built that way silently checked one file.
#
# A NESTED CHECKOUT is another repository's working tree, not this one's content: a
# Claude Code worktree under .claude/worktrees/, a git submodule, or a cloned
# dependency. Each has its own `.git` file or directory, and every one of them is
# excluded together with everything beneath it. Walking them meant an unrelated
# checkout's uncommitted work — a merge in progress, a scratch .env — failed this
# checkout's `make static`, and with it the first stage of every strict gate, while
# `git status` here was clean. That checkout runs its own gates.
#
# App/ is the exception. It holds this repository's own build inputs, so a `.git`
# beneath it — Xcode creates one when a new project is saved into App/ with "Create
# Git repository" left on — never takes the application's sources out of a scan.
# They are still listed here, and assert_no_nested_app_repositories refuses the
# nested repository itself.
#
# find cannot prune a directory because of what it contains, so the `.git` entries
# are printed as markers and the files beneath their parents are dropped afterwards.
# The walk's own status is checked BEFORE filtering: a walk that failed returns
# that failure and prints no partial list.
repo_files() {
    local listing rc=0
    if [ "$#" -gt 0 ]; then
        listing="$(find "$IOSAI_ROOT" \
            -name '.git' -prune -print -o \
            \( -name '.artifacts' -o -name 'DerivedData' \
               -o -name 'build' -o -name '*.xcresult' -o -name '*.xcarchive' \
               -o -name 'node_modules' -o -name '.build' -o -name '.swiftpm' \
               -o -name 'xcuserdata' -o -name '.idea' -o -name 'out' \
               -o -name 'Pods' -o -name 'Carthage' \) -prune -o \
            -type f \( "$@" \) -print)" || rc=$?
    else
        listing="$(find "$IOSAI_ROOT" \
            -name '.git' -prune -print -o \
            \( -name '.artifacts' -o -name 'DerivedData' \
               -o -name 'build' -o -name '*.xcresult' -o -name '*.xcarchive' \
               -o -name 'node_modules' -o -name '.build' -o -name '.swiftpm' \
               -o -name 'xcuserdata' -o -name '.idea' -o -name 'out' \
               -o -name 'Pods' -o -name 'Carthage' \) -prune -o \
            -type f -print)" || rc=$?
    fi
    [ "$rc" -eq 0 ] || return "$rc"
    [ -n "$listing" ] || return 0
    printf '%s\n' "$listing" | awk -v root="$IOSAI_ROOT" '
        $0 == "" || $0 == root "/.git" { next }
        /\/\.git$/ {
            dir = substr($0, 1, length($0) - 4)
            if (index(dir, root "/App/") != 1) nested[++nested_count] = dir
            next
        }
        { files[++file_count] = $0 }
        END {
            for (i = 1; i <= file_count; i++) {
                keep = 1
                for (j = 1; j <= nested_count; j++) {
                    if (index(files[i], nested[j]) == 1) { keep = 0; break }
                }
                if (keep) print files[i]
            }
        }'
}

# relpath <absolute-path> — repository-relative form, for readable output.
relpath() { printf '%s\n' "${1#"${IOSAI_ROOT}/"}"; }

# ---------------------------------------------------------------------------
# Batched content scanning.
#
# Every content scan used to run one grep per (file x pattern). On the template
# itself that is 57 files and nobody notices; on a 1,067-file application it was
# 11,726 processes and 44 seconds — and verify-static.sh is both `make static` and
# the optional pre-commit hook, against a workflow that asks for a commit whenever
# a coherent recovery point exists. A 46-second commit is how a developer learns to
# uninstall the hook. Batched, the same corpus and the same patterns take about a
# second.
#
# Nothing about the answer changes. The same files are read, the same extended
# regular expressions are applied, an unreadable file is still the caller's problem
# to report, and a scanner that could not answer still FAILS CLOSED rather than
# reporting "found nothing".
# ---------------------------------------------------------------------------

# How many paths are handed to one grep. Function arguments are in-process and
# unbounded, but each grep is an exec, so the batch keeps the argument list well
# under ARG_MAX on a very large repository while leaving the process count
# proportional to the number of patterns rather than the number of files.
IOSAI_SCAN_BATCH=400

# scan_matching_files <extended-regexp> — file list on stdin, one path per line;
# prints the paths that match.
#
# Returns 0 whether or not anything matched — "nothing matched" is an answer.
# Returns 2 when grep itself failed on any batch, which means the scan could not
# answer and the caller must treat it as a failure, never as a clean result.
#
# -l rather than -n: the overwhelmingly common answer is that nothing matched, and
# -l settles that in one process per batch. Line numbers are resolved afterwards,
# only for the few files that did match, by scan_matching_lines.
scan_matching_files() {
    local pattern="$1" rc=0 batch_rc f
    local batch
    batch=()
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        batch[${#batch[@]}]="$f"
        if [ "${#batch[@]}" -ge "$IOSAI_SCAN_BATCH" ]; then
            batch_rc=0
            grep -I -l -E -e "$pattern" -- "${batch[@]}" || batch_rc=$?
            [ "$batch_rc" -le 1 ] || rc=2
            batch=()
        fi
    done
    if [ "${#batch[@]}" -gt 0 ]; then
        batch_rc=0
        grep -I -l -E -e "$pattern" -- "${batch[@]}" || batch_rc=$?
        [ "$batch_rc" -le 1 ] || rc=2
    fi
    return "$rc"
}

# scan_matching_lines <extended-regexp> <file> — the matching line numbers, one
# per line.
#
# `cut` keeps only grep's numeric prefix, so the matching line and any secret
# bytes in it never enter a variable, a diagnostic, or shell tracing. A single file
# operand means grep does not prefix the filename, so a path containing a colon
# cannot confuse the split. Returns 2 when grep failed.
scan_matching_lines() {
    local pattern="$1" file="$2" rc=0
    grep -I -E -n -e "$pattern" -- "$file" 2>/dev/null | cut -d: -f1 || rc=$?
    [ "$rc" -le 1 ] || return 2
    return 0
}

# Loading simulator isolation functions never contacts Xcode.
# shellcheck source=simulator.sh
. "${IOSAI_ROOT}/Scripts/lib/simulator.sh"

# shellcheck source=platform.sh
. "${IOSAI_ROOT}/Scripts/lib/platform.sh"

# Companion verification is additive: the original platform suite always runs first.
. "${IOSAI_ROOT}/Scripts/lib/companion.sh"
