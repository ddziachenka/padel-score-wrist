#!/usr/bin/env bash
# clean-derived-data.sh — remove THIS worktree's disposable build cache.
#
# DerivedData is a build cache and nothing more: it holds no verification
# evidence, so removing it costs only rebuild time. Evidence lives in
# .artifacts/ and is removed separately by clean-artifacts.sh.
#
# Only the cache belonging to the current worktree is removed. Sibling worktrees
# get their own path (the default is keyed by a hash of the checkout path), so a
# concurrent milestone build is never disturbed.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/clean-derived-data.sh [--dry-run] [--print]

Removes the DerivedData directory used by this worktree.

  --dry-run   show the resolved path and size, delete nothing
  --print     print the resolved path and exit
  -h, --help  this message

Only the computed per-worktree cache is ever deleted:
    /private/tmp/<repository-name>-<hash-of-worktree-path>/DerivedData

A configured DERIVED_DATA_PATH is accepted only when it is a strict, no-symlink
child of this checkout's owned cache root. The cleanup command still removes
only the computed default; custom cache cleanup is left to its owning operator.

No path is acted on through a symlink, at any level of its ancestry.
EOF
}

opt_dry_run="no"
opt_print="no"
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) opt_dry_run="yes"; shift ;;
        --print)   opt_print="yes"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "unknown argument: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
    esac
done

load_project_config

path="$(derived_data_path)"
default_path="$(derived_data_default_path)"

if [ "$opt_print" = "yes" ]; then
    printf '%s\n' "$path"
    exit 0
fi

# --- guards -----------------------------------------------------------------
#
# Only the computed per-worktree cache is ever deleted. A configured
# DERIVED_DATA_PATH is reported and left alone: this script cannot know what
# else lives at a path somebody chose, and the previous version proved the point
# by deleting an unrelated directory that merely ended in "DerivedData".
if [ "$path" != "$default_path" ]; then
    log_warn "DERIVED_DATA_PATH is configured, so this script will not delete it"
    log_info "  configured: ${path}"
    log_info "  computed:   ${default_path}"
    hint "custom cache cleanup is an explicit operator action; no recursive deletion"
    hint "command is generated from configuration."
    hint "or clear DERIVED_DATA_PATH in Config/project.env to use the computed default."
    exit "$EX_USAGE"
fi

if ! assert_no_symlink_ancestry "$path"; then
    exit "$EX_USAGE"
fi

if [ ! -e "$path" ]; then
    log_ok "nothing to clean (no cache at ${path})"
    exit 0
fi
if [ ! -d "$path" ]; then
    die "$EX_USAGE" "not a directory: ${path}"
fi

size="$(du -sh -- "$path" 2>/dev/null | cut -f1 || printf '?')"

if [ "$opt_dry_run" = "yes" ]; then
    log_info "would remove ${path} (${size})"
    log_info "dry run — nothing was deleted"
    exit 0
fi

# The parent of the computed default belongs to this worktree alone, and is one
# of the canonical roots safe_remove_path accepts.
safe_remove_path "$path" "$(dirname -- "$path")"

log_ok "removed ${path} (${size})"
log_info "the next build will be a full rebuild; nothing else was affected."
log_info "verification evidence under .artifacts/ was not touched."
