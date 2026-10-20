#!/usr/bin/env bash
# install-git-hooks.sh — optionally enable the fast pre-commit convenience.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/install-git-hooks.sh [--force | --uninstall]

Optional developer convenience. Installation sets core.hooksPath=.githooks so
the versioned pre-commit hook runs ./Scripts/verify-static.sh (no simulator).

  --force      replace a core.hooksPath that points somewhere else
  --uninstall  unset core.hooksPath only when it currently equals .githooks;
               custom hook paths are left untouched
  -h, --help   this message

There is no pre-push hook. Push is storage/synchronization only and does not
run or imply verification. Lifecycle verification remains explicit whether or
not this optional hook is installed.
EOF
}

opt_force="no"
opt_uninstall="no"
while [ $# -gt 0 ]; do
    case "$1" in
        --force) opt_force="yes"; shift ;;
        --uninstall) opt_uninstall="yes"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "$EX_USAGE" "unknown hook-installer argument: $1" ;;
    esac
done
[ "$opt_force" = "no" ] || [ "$opt_uninstall" = "no" ] \
    || die "$EX_USAGE" "--force and --uninstall are mutually exclusive"

in_git_repo || die "$EX_UNAVAILABLE" "initialize a Git repository before configuring optional hooks"
current="$(git -C "$IOSAI_ROOT" config --get core.hooksPath 2>/dev/null || true)"

if [ "$opt_uninstall" = "yes" ]; then
    if [ -z "$current" ]; then
        log_ok "optional hooks are already disabled (core.hooksPath is unset)"
        exit 0
    fi
    if [ "$current" != ".githooks" ]; then
        log_skip "core.hooksPath points to '${current}', not this template; left unchanged"
        exit 0
    fi
    git -C "$IOSAI_ROOT" config --unset core.hooksPath
    [ -z "$(git -C "$IOSAI_ROOT" config --get core.hooksPath 2>/dev/null || true)" ] \
        || die "$EX_VERIFY" "core.hooksPath remained set after uninstall"
    log_ok "optional pre-commit hook disabled"
    exit 0
fi

hook="${IOSAI_ROOT}/.githooks/pre-commit"
[ -f "$hook" ] || die "$EX_NOINPUT" ".githooks/pre-commit is missing"
[ -x "$hook" ] || die "$EX_NOINPUT" ".githooks/pre-commit is not executable"

if [ -n "$current" ] && [ "$current" != ".githooks" ] && [ "$opt_force" = "no" ]; then
    log_error "core.hooksPath is already set to '${current}'"
    hint "leave the custom hooks in place, or re-run with --force to replace them."
    exit "$EX_USAGE"
fi

git -C "$IOSAI_ROOT" config core.hooksPath .githooks
verified="$(git -C "$IOSAI_ROOT" config --get core.hooksPath 2>/dev/null || true)"
[ "$verified" = ".githooks" ] \
    || die "$EX_VERIFY" "core.hooksPath is '${verified:-unset}' after configuration"

log_ok "optional pre-commit hook enabled"
log_info "  git commit -> ./Scripts/verify-static.sh (no simulator)"
log_info "  git push   -> no hook; storage/synchronization only"
log_info "Disable it with: ./Scripts/install-git-hooks.sh --uninstall"
