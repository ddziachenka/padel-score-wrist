#!/usr/bin/env bash
# project-status.sh — derive milestone truth without maintaining a dashboard.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/project-status.sh <command>

  summary     print the compact project fields and derived milestone list
  next        resume unfinished work, otherwise select a dependency-ready PLANNED milestone
  worktrees   list this repository's Git worktrees
  validate    validate milestone contracts, dependencies, and PROJECT_STATUS
  continuity <FULL_SHA>
              confirm that HEAD differs from a verified commit only in continuity
              records (Markdown under AI/) and that the checkout is clean
EOF
}

# iosai_status_release_scratch — remove the one temporary directory this script
# created, and nothing else.
#
# safe_remove_path is deliberately not used: it accepts only this checkout's two
# canonical roots (.artifacts and the owned DerivedData root) and would refuse a
# mktemp path, which is correct. So the guards are spelled out here instead, and
# they are exactly these: both variables set, both absolute, the basename the shape
# mktemp was asked for, both paths resolvable, the target still a directory, and the
# target strictly inside the temporary root mktemp chose once both sides are
# resolved. A broad temporary root can never satisfy that containment test, because
# a root is never strictly inside itself, and no deletion command is ever printed
# for a human to paste.
#
# Containment is tested on the RESOLVED paths rather than by refusing symlinked
# ancestry, because on macOS `/var` is itself a symlink to `/private/var` and
# `mktemp -t` hands back a path underneath it: a symlink-ancestry test refuses every
# temporary directory this function exists to remove, and the scratch then leaks on
# every run. There is no attacker input to defend against here — both variables are
# reset on entry and the only writer is cmd_next_id, immediately after its own
# mktemp — so resolving first is safe as well as necessary.
#
# The containment test used to be described in this comment but not performed.
IOSAI_SCRATCH=""
IOSAI_SCRATCH_ROOT=""
iosai_status_release_scratch() {
    local scratch="${IOSAI_SCRATCH:-}" root="${IOSAI_SCRATCH_ROOT:-}"
    local scratch_phys root_phys
    IOSAI_SCRATCH=""
    IOSAI_SCRATCH_ROOT=""
    [ -n "$scratch" ] && [ -n "$root" ] || return 0
    case "$scratch" in /*) : ;; *) return 0 ;; esac
    case "$root" in /*) : ;; *) return 0 ;; esac
    case "${scratch##*/}" in
        iosai-status*) : ;;
        *) return 0 ;;
    esac
    [ -d "$scratch" ] || return 0
    scratch_phys="$(physical_path "$scratch" 2>/dev/null)" || return 0
    root_phys="$(physical_path "$root" 2>/dev/null)" || return 0
    assert_path_inside "$scratch_phys" "$root_phys" || return 0
    rm -rf -- "$scratch_phys" 2>/dev/null || true
    return 0
}

# Re-raise with the default handler so an interrupted run still dies like one.
_iosai_status_signal_cleanup() {
    local sig="$1"
    iosai_status_release_scratch
    trap - EXIT INT TERM HUP
    kill -s "$sig" $$ 2>/dev/null || exit "$EX_FAIL"
}

cmd_next_id() {
    local rows index id status _reserved deps _title _file dep dep_status blocked active active_count current
    rows="$(milestone_rows)"
    [ -n "$rows" ] || return 0

    current="$(milestone_field "${IOSAI_ROOT}/AI/PROJECT_STATUS.md" 'Current milestone')"
    if [ "$(printf '%s\n' "$rows" | awk -F'\t' -v id="$current" '$1 == id {print $2}')" = BLOCKED ]; then
        return 0
    fi
    active="$(printf '%s\n' "$rows" | awk -F'\t' '$2 == "IN_PROGRESS" || $2 == "REVIEW"')"
    active_count="$(printf '%s\n' "$active" | awk 'NF {n++} END {print n+0}')"
    [ "$active_count" -le 1 ] || die "$EX_VERIFY" "multiple unfinished active milestones; reconcile current work before selecting another"

    IOSAI_SCRATCH="$(mktemp -d -t iosai-status)"
    IOSAI_SCRATCH_ROOT="$(dirname -- "$IOSAI_SCRATCH")"
    # Installed inside this function on purpose: cmd_next_id runs in a command
    # substitution, so this is that subshell's own EXIT trap. A trap installed at
    # top level would never see IOSAI_SCRATCH and the directory leaked on every
    # run. The EXIT handler does not call exit, so the original status survives.
    trap 'iosai_status_release_scratch' EXIT
    trap '_iosai_status_signal_cleanup INT'  INT
    trap '_iosai_status_signal_cleanup TERM' TERM
    trap '_iosai_status_signal_cleanup HUP'  HUP
    index="${IOSAI_SCRATCH}/status-index"
    printf '%s\n' "$rows" | while IFS="$(printf '\t')" read -r id status _r _d _t _f; do
        printf '%s\t%s\n' "$id" "$status"
    done > "$index"

    # An interrupted or reopened milestone keeps ownership of the session. If
    # its dependencies are unfinished, report that instead of starting new work.
    local candidates="$rows"
    [ "$active_count" -eq 0 ] || candidates="$active"
    while IFS="$(printf '\t')" read -r id status _reserved deps _title _file; do
        case "$status" in PLANNED|IN_PROGRESS|REVIEW) : ;; *) continue ;; esac
        blocked="no"
        while IFS= read -r dep; do
            [ -n "$dep" ] || continue
            dep_status="$(awk -F'\t' -v d="$dep" '$1 == d {print $2; exit}' "$index")"
            if [ "$dep_status" != "DONE" ]; then
                blocked="yes"
                break
            fi
        done <<EOF
$(dep_list "$deps")
EOF
        if [ "$blocked" = "no" ]; then
            printf '%s\n' "$id"
            return 0
        fi
    done <<EOF
$candidates
EOF
}

cmd_summary() {
    local status_file="${IOSAI_ROOT}/AI/PROJECT_STATUS.md" label
    log_step "Project status"
    for label in Phase 'Current milestone' 'Completed milestones' 'Next milestone' Blockers 'Important decisions'; do
        printf '  %-22s %s\n' "${label}:" "$(milestone_field "$status_file" "$label")"
    done

    printf '\n'
    log_step "Milestones"
    printf '  %-10s %-14s %-22s %s\n' "ID" "STATUS" "DEPENDS ON" "TITLE"
    local id status _reserved deps title _file
    while IFS="$(printf '\t')" read -r id status _reserved deps title _file; do
        [ -n "${id:-}" ] || continue
        printf '  %-10s %-14s %-22s %s\n' "$id" "$status" "$deps" "$title"
    done <<EOF
$(milestone_rows)
EOF

    printf '\n'
    cmd_next
}

cmd_next() {
    local id file title rows pending
    id="$(cmd_next_id)"
    log_step "Next milestone"
    if [ -z "$id" ]; then
        # cmd_next_id returns nothing for three different situations, and they are not
        # the same news: a repository with no milestone files, a plan whose every
        # milestone is DONE, and a plan that still has work in it but nothing ready.
        # Reporting the second one as "none" read as a fault in a finished project and
        # left what comes next undiscoverable — the milestone list is append-only, so
        # new work after the plan is finished is a new milestone rather than a reopened
        # one. The discriminator is computed here from milestone_rows rather than by
        # calling cmd_next_id again: that function creates a scratch directory, and
        # this is not a second question about dependencies.
        rows="$(milestone_rows)"
        if [ -z "$rows" ]; then
            printf '  none — this repository has no milestone files\n'
            return 0
        fi
        pending="$(printf '%s\n' "$rows" | awk -F'\t' '$2 != "DONE" { print }')"
        if [ -z "$pending" ]; then
            printf '  none — every milestone is DONE and this plan is finished\n'
            printf '  new work:  append one milestone with the next sequential ID and\n'
            printf '             status PLANNED, depending on the milestone that\n'
            printf '             finished last, then run it like any other\n'
            printf '  history:   completed milestones and audits stay DONE; none is\n'
            printf '             reopened, renumbered, or reused to hold new work\n'
            printf '  candidate: a code or configuration change after a release\n'
            printf '             candidate needs a new one — append a Release\n'
            printf '             Readiness Revalidation milestone when you want it\n'
            return 0
        fi
        printf '  none — current work is BLOCKED or no milestone has completed dependencies\n'
        return 0
    fi
    file="$(milestone_file_for_id "$id")"
    title="$(grep -m1 '^# ' "$file" | sed 's/^# //')"
    printf '  %s\n' "$title"
    printf '  file:      %s\n' "$(relpath "$file")"
    # One session carries this milestone to DONE, so the whole shape is printed
    # here. Printing only "start" and "validate" left the end of the session —
    # self-review, the handoff, and DONE — to be remembered rather than read.
    printf '  state:     %s\n' "$(milestone_field "$file" Status)"
    printf '  resume:    preserve existing work and evidence; REVIEW resumes verification\n'
    printf '  start:     set **Status:** IN_PROGRESS when implementing or correcting\n'
    printf '  build:     implement, test, self-review, fix what it finds\n'
    printf '  validate:  set **Status:** REVIEW, commit, then: make milestone ID=%s\n' "$id"
    printf '  finish:    write the handoff, set **Status:** DONE, update AI/PROJECT_STATUS.md, commit\n'
    printf '  confirm:   ./Scripts/project-status.sh continuity <verified-full-SHA>\n'
    printf '  then:      stop — a new session takes the next milestone\n'
}

# cmd_continuity <verified-full-SHA> — does HEAD still carry exactly the build inputs
# that were verified?
#
# The DONE status line, the handoff, AI/PROJECT_STATUS.md and any audit written about
# a verified commit are committed AFTER it, and AI/WORKFLOW.md is explicit that those
# continuity records do not create a new candidate while any code or configuration
# change does. Nothing told the two apart: a DONE commit that also touched App/ looked
# exactly like one that did not, and the release checklist's "Archive from this
# candidate" could not be confirmed from a checkout that had since moved on by a
# Markdown commit. So every path that differs between the verified commit and HEAD
# must be Markdown under AI/, the verified commit must be an ancestor of HEAD, and the
# checkout must pass the same cleanliness question the milestone gate asks, because a
# build from this checkout — the developer's Archive included — would carry its
# uncommitted bytes too. Every query fails closed.
cmd_continuity() {
    local supplied="${1:-}" verified head changed outside
    [ -n "$supplied" ] || die "$EX_USAGE" "continuity requires the verified full commit SHA"
    in_git_repo || die "$EX_UNAVAILABLE" "not inside a git repository"
    git_has_commits || die "$EX_UNAVAILABLE" "this repository has no commits"
    verified="$(resolve_explicit_candidate "$supplied")"
    head="$(git -C "$IOSAI_ROOT" rev-parse --verify HEAD)" \
        || die "$EX_VERIFY" "could not read HEAD"

    log_step "Continuity since ${verified}"
    if ! git -C "$IOSAI_ROOT" merge-base --is-ancestor "$verified" "$head" 2>/dev/null; then
        log_error "the verified commit is not an ancestor of HEAD (${head})"
        hint "continuity records follow the commit they describe; this HEAD is not built on it"
        exit "$EX_VERIFY"
    fi
    # core.quotePath=false so an ordinary non-ASCII filename is compared as itself;
    # a name Git still has to quote cannot match the pattern below, and is refused.
    if ! changed="$(git -c core.quotePath=false -C "$IOSAI_ROOT" diff --name-only --no-renames \
            "$verified" "$head" -- 2>&1)"; then
        log_error "could not compare the verified commit with HEAD; refusing to assume nothing changed"
        printf '%s\n' "$changed" | sed 's/^/           /' >&2
        exit "$EX_VERIFY"
    fi
    changed="$(printf '%s\n' "$changed" | grep -v '^$' || true)"
    outside="$(printf '%s\n' "$changed" | grep -v '^$' | grep -Ev '^AI/.+\.md$' || true)"
    if [ -n "$outside" ]; then
        log_error "HEAD changed more than continuity records since the verified commit:"
        printf '%s\n' "$outside" | sed 's/^/           /' >&2
        hint "only Markdown under AI/ — the DONE status line, the handoff, AI/PROJECT_STATUS.md,"
        hint "and the audit records — may follow a verified commit. anything else makes HEAD a"
        hint "new candidate, which needs its own milestone verification, and its own release"
        hint "verification before it ships."
        exit "$EX_VERIFY"
    fi
    milestone_checkout_is_clean "the checkout carries changes that a build from it would include" \
        || exit "$EX_VERIFY"

    log_ok "HEAD ${head} carries exactly the build inputs of ${verified}"
    if [ -n "$changed" ]; then
        log_info "  continuity records changed since then:"
        printf '%s\n' "$changed" | sed 's/^/    /'
    else
        log_info "  HEAD is the verified commit itself"
    fi
}

cmd_worktrees() {
    log_step "Worktrees"
    if ! in_git_repo; then
        log_warn "not inside a Git repository"
        return 0
    fi
    git -C "$IOSAI_ROOT" worktree list
    printf '\n  The primary checkout is where every milestone is developed. A worktree is\n'
    printf '  one language after the release candidate, on branch localization/<locale>.\n'
}

cmd_validate() {
    local problems=0
    log_step "Validating milestones"
    milestones_validate_all || problems=$((problems + 1))
    printf '\n'
    log_step "Validating AI/PROJECT_STATUS.md"
    project_status_validate || problems=$((problems + 1))
    if [ "$problems" -gt 0 ]; then
        log_error "project memory does not satisfy solo-workflow/2"
        exit "$EX_VERIFY"
    fi
    log_ok "milestones, dependencies, and compact project status are valid"
}

case "${1:-}" in
    summary) cmd_summary ;;
    next) cmd_next ;;
    worktrees) cmd_worktrees ;;
    validate) cmd_validate ;;
    continuity)
        [ "$#" -le 2 ] || die "$EX_USAGE" "continuity takes exactly one verified full commit SHA"
        cmd_continuity "${2:-}" ;;
    -h|--help) usage ;;
    "") usage; exit "$EX_USAGE" ;;
    *) log_error "unknown command: $1"; usage >&2; exit "$EX_USAGE" ;;
esac
