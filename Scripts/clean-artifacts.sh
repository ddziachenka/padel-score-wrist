#!/usr/bin/env bash
# clean-artifacts.sh — remove local verification evidence under .artifacts/.
#
# Deletion is confined to known subdirectories of .artifacts/ and goes through
# safe_remove_path, which refuses anything outside that root. DerivedData lives
# outside the repository and is NOT touched here — use clean-derived-data.sh.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

# The complete set of directories the gates write. Nothing outside this list is
# ever removed, so a stray file under .artifacts/ survives and stays visible.
#
# Kept in step with the gates deliberately: `template`, `static` and the obsolete
# `push` gate were listed here but no gate has ever written them — verify-template
# and verify-static are console-only, and the push gate is gone. Naming a directory
# nothing produces advertises evidence that does not exist. A leftover directory
# from an older version is now reported as a stray rather than deleted, which is
# the safer direction.
KNOWN_SUBDIRS="fast milestone integration release config-backups"

usage() {
    cat <<'EOF'
Usage: ./Scripts/clean-artifacts.sh [--dry-run] [--all]

Removes local verification evidence from .artifacts/.

  --dry-run   list what would be removed, delete nothing
  --all       also remove config backups
  -h, --help  this message

Removed by default:
  .artifacts/fast/
  .artifacts/milestone/
  .artifacts/integration/
  .artifacts/release/

Kept unless --all is given:
  .artifacts/config-backups/     previous Config/project.env versions

Never touched:
  .artifacts/.gitkeep
  Anything under .artifacts/ that is not in the list above — it is reported
  instead of removed, so a stray file stays visible.
  DerivedData (outside the repository — see ./Scripts/clean-derived-data.sh)
EOF
}

opt_dry_run="no"
opt_all="no"
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) opt_dry_run="yes"; shift ;;
        --all)     opt_all="yes"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "unknown argument: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
    esac
done

if [ ! -d "$IOSAI_ARTIFACTS_DIR" ]; then
    log_ok "nothing to clean (.artifacts/ does not exist)"
    exit 0
fi

# A symlinked .artifacts/ — or a symlinked ancestor — would put "inside the
# artifacts root" somewhere else entirely, which is how a cleanup deletes
# evidence it does not own.
if ! assert_no_symlink_ancestry "$IOSAI_ARTIFACTS_DIR"; then
    hint ".artifacts/ must be a real directory inside this checkout"
    exit "$EX_USAGE"
fi

removed=0
kept=0
for sub in $KNOWN_SUBDIRS; do
    case "$sub" in
        config-backups)
            if [ "$opt_all" = "no" ]; then
                if [ -e "${IOSAI_ARTIFACTS_DIR}/${sub}" ]; then
                    log_skip ".artifacts/${sub}/ (use --all to remove)"
                    kept=$((kept + 1))
                fi
                continue
            fi ;;
    esac

    target="${IOSAI_ARTIFACTS_DIR}/${sub}"
    [ -e "$target" ] || continue

    if [ "$opt_dry_run" = "yes" ]; then
        size="$(du -sh -- "$target" 2>/dev/null | cut -f1 || printf '?')"
        log_info "  would remove .artifacts/${sub}/ (${size})"
        removed=$((removed + 1))
        continue
    fi

    safe_remove_path "$target" "$IOSAI_ARTIFACTS_DIR"
    log_ok "removed .artifacts/${sub}/"
    removed=$((removed + 1))
done

# Keep the directory tracked even when empty, without following a forged marker.
if [ ! -e "${IOSAI_ARTIFACTS_DIR}/.gitkeep" ]; then
    atomic_write_line_no_follow "${IOSAI_ARTIFACTS_DIR}/.gitkeep" "" "$IOSAI_ARTIFACTS_DIR"
else
    assert_no_symlink_ancestry "${IOSAI_ARTIFACTS_DIR}/.gitkeep" || exit "$EX_USAGE"
    [ -f "${IOSAI_ARTIFACTS_DIR}/.gitkeep" ] \
        || die "$EX_USAGE" ".artifacts/.gitkeep is not a regular file"
fi

if [ "$removed" -eq 0 ]; then
    log_ok "nothing to remove"
elif [ "$opt_dry_run" = "yes" ]; then
    log_info ""
    log_info "dry run — nothing was deleted"
fi
[ "$kept" -eq 0 ] || log_info "kept ${kept} directory/ies (pass --all to include them)"

# Report anything unexpected rather than silently deleting it. Entries that ARE
# in the known set are excluded: a dry run listing a directory it just said it
# would remove as "not in the known set" contradicts itself.
unexpected=""
while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    name="$(basename -- "$entry")"
    [ "$name" = ".gitkeep" ] && continue
    if token_in_list "$name" "$KNOWN_SUBDIRS"; then
        continue
    fi
    unexpected="${unexpected}${entry}
"
done <<EOF
$(find "$IOSAI_ARTIFACTS_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | sort || true)
EOF
unexpected="$(printf '%s' "$unexpected" | grep -v '^$' || true)"

if [ -n "$unexpected" ]; then
    printf '\n'
    log_info "still present under .artifacts/ (not in the known set, so left alone):"
    printf '%s\n' "$unexpected" | sed "s|^${IOSAI_ROOT}/|  |"
fi
