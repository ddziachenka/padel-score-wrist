#!/usr/bin/env bash
# create-worktree.sh — start one language's localization worktree.
#
# Convention:
#   branch    localization/<locale>
#   worktree  ../<repository-directory>-<locale>   (a sibling of this checkout)
#
# Milestones are sequential: they are developed in the primary checkout, on the
# primary branch, and committed there. Translating the finished product is the one
# activity in this workflow that runs in parallel, so it is the one activity that
# gets a branch and a worktree of its own — which is what this script creates.
#
# Never overwrites an existing branch or worktree, and never forces anything.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/create-worktree.sh <LOCALE> [options]

Creates the localization worktree and branch for one language.

Arguments:
  LOCALE         the locale identifier, lowercased: de, ja, pt-br, zh-hans

Options:
  --base REF     commit or branch to cut the language from
                 (default: the primary branch recorded in .iosai-project)
  --path PATH    worktree location (default: ../<repo-dir>-<locale>)
  -h, --help     this message

Examples:
  ./Scripts/create-worktree.sh de
  ./Scripts/create-worktree.sh pt-br --base <full-sha>

Localization begins after the English candidate reached READY_FOR_HUMAN.
EOF
}

opt_locale=""
opt_base=""
opt_path=""

while [ $# -gt 0 ]; do
    case "$1" in
        --base) [ $# -gt 1 ] || die "$EX_USAGE" "--base requires a value"; opt_base="$2"; shift 2 ;;
        --path) [ $# -gt 1 ] || die "$EX_USAGE" "--path requires a value"; opt_path="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        -*) log_error "unknown option: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
        *)
            if [ -z "$opt_locale" ]; then
                opt_locale="$1"
            else
                log_error "unexpected argument: $1"
                hint "one language per worktree; run this again for the next one"
                exit "$EX_USAGE"
            fi
            shift ;;
    esac
done

if [ -z "$opt_locale" ]; then
    log_error "a locale identifier is required"
    hint "usage: ./Scripts/create-worktree.sh <LOCALE>"
    hint "for example: de, ja, pt-br"
    exit "$EX_USAGE"
fi

# --- validate the locale ----------------------------------------------------
#
# A milestone ID names itself first, rather than being reported as a badly spelled
# locale. Checked before the case rule below because `create-worktree.sh M03` would
# otherwise be advised to try `m03` — nonsense advice for a caller whose real
# problem is that per-milestone worktrees no longer exist.
if printf '%s' "$opt_locale" | grep -Eq "$IOSAI_MILESTONE_ID_PATTERN"; then
    log_error "milestone worktrees no longer exist: ${opt_locale}"
    hint "every milestone is developed in the primary checkout and committed to the"
    hint "primary branch. this script creates a localization worktree:"
    hint "  ./Scripts/create-worktree.sh de"
    exit "$EX_USAGE"
fi

# The branch, the worktree directory, and the site route all use the identifier
# lowercased. Git refs are files, and a macOS filesystem usually cannot tell `pt-BR`
# from `pt-br` — so accepting both spellings would mean two names for one branch, and
# whichever the developer typed second would silently find the first. The refusal is
# deliberate rather than a quiet rewrite of what was typed: the application's own
# resources keep the identifier's own casing, and only these paths are lowercased.
if printf '%s' "$opt_locale" | grep -q '[A-Z]'; then
    lowered="$(printf '%s' "$opt_locale" | tr '[:upper:]' '[:lower:]')"
    log_error "locale identifiers are lowercase here: ${opt_locale}"
    hint "use '${lowered}', not '${opt_locale}'."
    hint "the branch, the worktree directory, and the site route are all filesystem"
    hint "paths, and macOS usually cannot tell them apart."
    hint "the application's own resources keep the identifier's own casing."
    hint "re-run: ./Scripts/create-worktree.sh ${lowered}"
    exit "$EX_USAGE"
fi

if ! printf '%s' "$opt_locale" | grep -Eq "$IOSAI_LOCALE_PATTERN"; then
    log_error "not a locale identifier: ${opt_locale}"
    hint "expected a language, optionally with subtags: de, ja, pt-br, zh-hans, es-419"
    exit "$EX_USAGE"
fi

branch="localization/${opt_locale}"

# Belt and braces. Unreachable if the grammar above is right, and one process is
# a cheap price for never handing git a ref name it would have to interpret.
git check-ref-format --branch "$branch" >/dev/null 2>&1 \
    || die "$EX_USAGE" "not a usable branch name: ${branch}"

if ! in_git_repo; then
    log_error "not inside a git repository"
    hint "run 'git init' and create an initial commit first"
    exit "$EX_UNAVAILABLE"
fi

if ! git_has_commits; then
    log_error "this repository has no commits yet"
    hint "a worktree has to be based on a commit, so create the initial commit first:"
    hint "  git add -A && git commit -m 'Initial commit'"
    exit "$EX_UNAVAILABLE"
fi

op="$(git_operation_in_progress)"
if [ -n "$op" ]; then
    log_error "a git operation is in progress (${op})"
    hint "finish or abort it before creating a worktree"
    exit "$EX_VERIFY"
fi

if git -C "$IOSAI_ROOT" show-ref --verify --quiet "refs/heads/${branch}"; then
    log_error "branch already exists: ${branch}"
    hint "this script never reuses or moves an existing branch."
    hint "if that branch already holds this language's work, attach a worktree to it:"
    hint "  git worktree add $(shell_quote "../$(basename -- "$IOSAI_ROOT")-${opt_locale}") $(shell_quote "$branch")"
    exit "$EX_VERIFY"
fi

# --- resolve base -----------------------------------------------------------
#
# A language is cut from the commit that finished the last milestone, which is the
# tip of the primary branch. `die` inside a command substitution would only exit
# the subshell, so the status is captured and re-raised rather than trusted to
# propagate: 0 is a recorded branch, 1 is no marker at all, anything else is the
# marker being unreadable and must not be read as "uninitialized".
if [ -n "$opt_base" ]; then
    base="$opt_base"
else
    primary=""
    primary_rc=0
    primary="$(iosai_primary_branch)" || primary_rc=$?
    case "$primary_rc" in
        0)  git -C "$IOSAI_ROOT" show-ref --verify --quiet "refs/heads/${primary}" \
                || die "$EX_NOINPUT" "the primary branch recorded in .iosai-project does not exist: ${primary}"
            base="$primary" ;;
        1)  base="$(git -C "$IOSAI_ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
            [ -n "$base" ] \
                || die "$EX_VERIFY" "no primary branch is recorded and HEAD is detached; pass --base"
            log_warn "no .iosai-project marker: basing this language on the current branch '${base}'" ;;
        *)  exit "$primary_rc" ;;
    esac
fi
base_sha="$(git -C "$IOSAI_ROOT" rev-parse --verify --quiet "${base}^{commit}" 2>/dev/null || true)"
if [ -z "$base_sha" ]; then
    die "$EX_NOINPUT" "cannot resolve base ref: ${base}"
fi

# --- resolve worktree path --------------------------------------------------
if [ -n "$opt_path" ]; then
    worktree_path="$(abs_path "$opt_path")"
else
    worktree_path="$(dirname -- "$IOSAI_ROOT")/$(basename -- "$IOSAI_ROOT")-${opt_locale}"
fi

if [ -e "$worktree_path" ]; then
    log_error "path already exists: ${worktree_path}"
    hint "this script never overwrites an existing directory."
    hint "remove it with ./Scripts/remove-worktree.sh, or pass --path."
    exit "$EX_VERIFY"
fi

# Listed first and checked as a whole: a `grep -q` reading git's output could stop
# before git finished writing, and pipefail would then call a tracked path untracked.
worktree_listing="$(git -C "$IOSAI_ROOT" worktree list --porcelain)" \
    || die "$EX_VERIFY" "could not list this repository's worktrees"
if line_in_list "worktree ${worktree_path}" "$worktree_listing"; then
    die "$EX_VERIFY" "git already tracks a worktree at ${worktree_path}"
fi

# --- create -----------------------------------------------------------------
log_step "creating the ${opt_locale} localization worktree"
log_info "  locale:    ${opt_locale}"
log_info "  branch:    ${branch}"
log_info "  base:      ${base} (${base_sha})"
log_info "  path:      ${worktree_path}"

git -C "$IOSAI_ROOT" worktree add -b "$branch" -- "$worktree_path" "$base_sha"

log_ok "worktree created"

# --- localization comes after the milestones --------------------------------
#
# Translating earlier means translating strings that are still about to change.
# The prompt confirms the candidate-bound readiness handoff. This helper still
# reports unfinished milestones rather than refusing because a later product version
# may legitimately add a language after new milestones were appended.
#
# Refusing would also be wrong on its own terms. A product whose languages were
# integrated and whose next version is under way has milestones that are not DONE
# by design, and adding a language to it is exactly what AI/WORKFLOW.md expects.
not_done="$(milestone_rows | awk -F'\t' '$2 != "DONE" { printf "  %s  %s\n", $1, $2 }')"
if [ -n "$not_done" ]; then
    log_warn "these milestones are not DONE:"
    printf '%s\n' "$not_done" >&2
fi
log_info "localization requires an English candidate with READY_FOR_HUMAN;"
log_info "AI/prompts/add-localization-worktree.md validates that committed handoff."

log_info ""
log_info "Next:"
log_info "  cd $(shell_quote "$worktree_path")"
log_info "  send AI/prompts/add-localization-worktree.md for this language, in this worktree only"
log_info ""
log_info "Localization is not a milestone: it writes no **Status:** line, no record"
log_info "under AI/audits/ or AI/handoffs/, and never runs make milestone."
log_info "Everything that session changes lives inside this worktree; it never edits"
log_info "the primary checkout or another language's worktree."
log_info "Hooks are inherited automatically."
log_info "DerivedData is keyed per worktree, so this language will not share a build"
log_info "cache with any other."
