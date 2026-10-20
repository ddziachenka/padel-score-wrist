#!/usr/bin/env bash
# remove-worktree.sh — remove one worktree that git actually knows about.
#
# Only paths listed by `git worktree list --porcelain` can be removed, and
# uncommitted or unpushed work is refused unless --force is given explicitly.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/remove-worktree.sh <LOCALE|PATH> [options]

Removes a git worktree belonging to this repository.

Arguments:
  LOCALE         e.g. de — resolves to the worktree on branch localization/de
  PATH           the worktree path exactly as `git worktree list` reports it

Options:
  --force           remove even when the worktree has uncommitted changes
  --delete-branch   also delete the worktree's branch (refused if unmerged)
  --list            list this repository's worktrees and exit
  -h, --help        this message

This script never deletes a directory git does not track as a worktree, and
never discards uncommitted work unless --force is given.
EOF
}

opt_target=""
opt_force="no"
opt_delete_branch="no"

while [ $# -gt 0 ]; do
    case "$1" in
        --force)         opt_force="yes"; shift ;;
        --delete-branch) opt_delete_branch="yes"; shift ;;
        --list)
            in_git_repo || die "$EX_UNAVAILABLE" "not inside a git repository"
            git -C "$IOSAI_ROOT" worktree list
            exit 0 ;;
        -h|--help) usage; exit 0 ;;
        -*) log_error "unknown option: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
        *)
            if [ -z "$opt_target" ]; then
                opt_target="$1"
            else
                log_error "unexpected argument: $1"
                exit "$EX_USAGE"
            fi
            shift ;;
    esac
done

if [ -z "$opt_target" ]; then
    log_error "a locale or worktree path is required"
    hint "list them with: ./Scripts/remove-worktree.sh --list"
    exit "$EX_USAGE"
fi

in_git_repo || die "$EX_UNAVAILABLE" "not inside a git repository"

# --- resolve the target strictly through git --------------------------------
known="$(git -C "$IOSAI_ROOT" worktree list --porcelain | awk '/^worktree /{print substr($0, 10)}')"
[ -n "$known" ] || die "$EX_NOINPUT" "git reports no worktrees for this repository"

# awk drains its input; `head -n1` could leave printf with a pending write, and
# the SIGPIPE that pipefail reports would abort this script under `set -e`.
main_worktree="$(printf '%s\n' "$known" | awk 'NR == 1')"

# Decide what kind of target this is BEFORE matching, so user input never
# reaches a regular expression. Interpolating it into `grep -E` meant `.` or `.*`
# matched a worktree the caller did not name.
target_kind="path"
case "$opt_target" in
    /*|*/*) : ;;
    *)  if printf '%s' "$opt_target" | grep -Eq "$IOSAI_MILESTONE_ID_PATTERN"; then
            log_error "milestone worktrees no longer exist: ${opt_target}"
            hint "every milestone is developed in the primary checkout, so there is no"
            hint "per-milestone worktree to remove."
            hint "pass a locale (de, pt-br), or remove a worktree left over from before"
            hint "this change by its path."
            exit "$EX_USAGE"
        elif printf '%s' "$opt_target" | grep -q '[A-Z]'; then
            log_error "locale identifiers are lowercase here: ${opt_target}"
            hint "use '$(printf '%s' "$opt_target" | tr '[:upper:]' '[:lower:]')', not '${opt_target}'."
            exit "$EX_USAGE"
        elif printf '%s' "$opt_target" | grep -Eq "$IOSAI_LOCALE_PATTERN"; then
            target_kind="locale"
        else
            log_error "not a locale or a path: ${opt_target}"
            hint "expected a lowercased locale (de, ja, pt-br) or a worktree path as"
            hint "\`git worktree list\` reports it."
            hint "list them with: ./Scripts/remove-worktree.sh --list"
            exit "$EX_USAGE"
        fi ;;
esac

# A locale resolves through its BRANCH, not through a path suffix. `de` matching
# any path ending `-de` would also match `../repo-pt-de`, and more to the point
# `br` would match `../repo-pt-br` — a language nobody named. The branch is the
# thing the convention actually fixes, so it is the thing matched.
want_branch="refs/heads/localization/${opt_target}"

resolved=""
matches=0
wt=""
if [ "$target_kind" = "locale" ]; then
    while IFS= read -r line; do
        case "$line" in
            "worktree "*) wt="${line#worktree }" ;;
            "branch ${want_branch}")
                resolved="$wt"; matches=$((matches + 1)) ;;
        esac
    done <<EOF
$(git -C "$IOSAI_ROOT" worktree list --porcelain)
EOF
else
    while IFS= read -r wt; do
        [ -n "$wt" ] || continue
        if [ "$wt" = "$(abs_path "$opt_target")" ]; then
            resolved="$wt"; matches=$((matches + 1))
        fi
    done <<EOF
$known
EOF
fi

if [ "$matches" -eq 0 ]; then
    log_error "no worktree of this repository matches: ${opt_target}"
    hint "git tracks these worktrees:"
    printf '%s\n' "$known" | sed 's/^/           /' >&2
    hint "only a path git reports here can be removed."
    exit "$EX_NOINPUT"
fi
if [ "$matches" -gt 1 ]; then
    die "$EX_NOINPUT" "'${opt_target}' matches ${matches} worktrees; pass the full path instead"
fi
if [ "$resolved" = "$main_worktree" ]; then
    log_error "refusing to remove the main worktree: ${resolved}"
    hint "that is the primary checkout, where every milestone is developed"
    exit "$EX_USAGE"
fi
if [ "$resolved" = "$IOSAI_ROOT" ]; then
    log_error "refusing to remove the worktree you are currently in: ${resolved}"
    hint "cd to the main checkout first"
    exit "$EX_USAGE"
fi

branch="$(git -C "$resolved" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '%s' 'HEAD')"
# The cache is keyed by a hash of the worktree's PHYSICAL path, so the reported
# location has to be resolved the same way the worktree itself resolved it.
# Hashing the raw path printed a directory that never existed whenever the
# worktree path crossed a symlink.
cache_owner_before="$IOSAI_CACHE_OWNER_PATH"
IOSAI_CACHE_OWNER_PATH="$(physical_path "$resolved" 2>/dev/null || printf '%s' "$resolved")"
removed_cache_path="$(derived_data_default_path)"
IOSAI_CACHE_OWNER_PATH="$cache_owner_before"

# --- refuse to discard work silently ----------------------------------------
#
# Every question here fails closed. `git status ... || true` read an unreadable
# worktree index as "no changes", and the script then told the developer "the
# worktree is clean" about a worktree it had never inspected; only Git's own refusal
# inside `git worktree remove` stood between that and the uncommitted files. --force
# skips these checks, because discarding is exactly what it asks for.
if [ "$opt_force" = "no" ]; then
    if ! dirty="$(git -C "$resolved" status --porcelain 2>&1)"; then
        log_error "could not read the state of worktree ${resolved}; refusing to assume it is clean"
        printf '%s\n' "$dirty" | sed 's/^/           /' >&2
        hint "repair the worktree, or re-run with --force to discard it anyway."
        exit "$EX_VERIFY"
    fi
    if [ -n "$dirty" ]; then
        log_error "worktree has uncommitted changes: ${resolved}"
        printf '%s\n' "$dirty" | sed 's/^/           /' >&2
        hint "commit or stash them, or re-run with --force to discard them."
        exit "$EX_VERIFY"
    fi
fi

if [ "$branch" != "HEAD" ] && [ "$opt_force" = "no" ]; then
    # for-each-ref prints an empty upstream for a branch that has none and exits
    # non-zero only when it could not answer, so absence and failure stay distinct.
    if ! upstream="$(git -C "$IOSAI_ROOT" for-each-ref --format='%(upstream:short)' \
            "refs/heads/${branch}" 2>&1)"; then
        log_error "could not determine the upstream of branch '${branch}'"
        printf '%s\n' "$upstream" | sed 's/^/           /' >&2
        hint "re-run with --force to remove the checkout anyway; the branch is kept."
        exit "$EX_VERIFY"
    fi
    if [ -n "$upstream" ] \
       && ! git -C "$IOSAI_ROOT" rev-parse --verify --quiet "${upstream}^{commit}" >/dev/null 2>&1; then
        log_warn "branch '${branch}' tracks ${upstream}, which no longer exists here, so unpushed commits cannot be counted"
        hint "the worktree is clean, so this removes the checkout only — branch '${branch}' is kept either way."
    elif [ -n "$upstream" ]; then
        if ! ahead="$(git -C "$IOSAI_ROOT" rev-list --count "${upstream}..refs/heads/${branch}" 2>&1)"; then
            log_error "could not count the commits of '${branch}' missing from ${upstream}"
            printf '%s\n' "$ahead" | sed 's/^/           /' >&2
            hint "re-run with --force to remove the checkout anyway; the branch is kept."
            exit "$EX_VERIFY"
        fi
        if [ "$ahead" != "0" ]; then
            log_error "branch '${branch}' has ${ahead} commit(s) not present on ${upstream}"
            hint "push them, or re-run with --force if they are genuinely disposable."
            exit "$EX_VERIFY"
        fi
    else
        log_warn "branch '${branch}' has no upstream, so unpushed commits cannot be counted"
        hint "a local-only repository is normal here. the worktree is clean, so this"
        hint "removes the checkout only — branch '${branch}' is kept either way."
    fi
fi

# --- remove -----------------------------------------------------------------
log_step "removing worktree ${resolved}"
if [ "$opt_force" = "yes" ]; then
    git -C "$IOSAI_ROOT" worktree remove --force -- "$resolved"
else
    git -C "$IOSAI_ROOT" worktree remove -- "$resolved"
fi
log_ok "worktree removed (branch '${branch}' still exists)"

branch_delete_failed="no"
if [ "$opt_delete_branch" = "yes" ] && [ "$branch" != "HEAD" ]; then
    if git -C "$IOSAI_ROOT" branch -d -- "$branch" 2>/dev/null; then
        log_ok "branch deleted: ${branch}"
    else
        log_warn "branch '${branch}' is not fully merged and was kept"
        hint "delete it deliberately with: git branch -D $(shell_quote "$branch")"
        branch_delete_failed="yes"
    fi
fi

log_info ""
log_info "No PROJECT_STATUS update is needed; a localization worktree is never milestone state."
log_info "The removed worktree's separate DerivedData cache may remain at:"
log_info "  ${removed_cache_path}"
log_info "Built-in cleanup must be run from the worktree before removing it. The"
log_info "checkout no longer exists, so this script does not act on that cache or"
log_info "generate a deletion command; /private/tmp is cleared by the system."

# An explicitly requested operation that was refused is a partial failure, and
# exiting 0 told automation the cleanup finished when a branch still exists.
if [ "$branch_delete_failed" = "yes" ]; then
    printf '\n'
    log_error "worktree removed, but --delete-branch was refused: '${branch}' is not merged"
    exit "$EX_VERIFY"
fi
