#!/usr/bin/env bash
# initialize-project.sh — turn a fresh template copy into a new project repo.
#
# This is intentionally destructive to template-only memory, and only that
# memory: it requires an explicit confirmation, a clean single-worktree source,
# no application files, and no previous initialization marker. It replaces the
# reachable Git history, removes remotes and template audit/status records, then
# leaves the developer in the primary checkout before product work begins.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/initialize-project.sh --confirm-new-project --owner NAME --email ADDRESS [options]

Replaces template repository memory with one new project root commit. Run once,
before adding an Xcode project or editing product contracts.

Required:
  --confirm-new-project    acknowledge replacement of template Git/audit history
  --owner NAME             project owner and Git author name
  --email ADDRESS          Git author email for the new repository

Options:
  --primary-branch NAME      new primary branch (default: main)
  --integration-branch NAME  compatibility alias for --primary-branch
  -h, --help                 this message

Every milestone is then developed in this checkout, on that branch. The command
refuses reruns, other worktrees, in-progress Git operations, symlinks in reset
targets, dirty committed copies, and any product file under App/. It never pushes
or creates a remote.
EOF
}

opt_confirm="no"
opt_owner=""
opt_email=""
opt_integration="main"

while [ $# -gt 0 ]; do
    case "$1" in
        --confirm-new-project) opt_confirm="yes"; shift ;;
        --owner) [ $# -gt 1 ] || die "$EX_USAGE" "--owner requires a value"; opt_owner="$2"; shift 2 ;;
        --email) [ $# -gt 1 ] || die "$EX_USAGE" "--email requires a value"; opt_email="$2"; shift 2 ;;
        --primary-branch|--integration-branch) [ $# -gt 1 ] || die "$EX_USAGE" "$1 requires a value"; opt_integration="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "$EX_USAGE" "unknown initialization argument: $1" ;;
    esac
done

[ "$opt_confirm" = "yes" ] || die "$EX_USAGE" "initialization requires --confirm-new-project"
field_is_answered "$opt_owner" || die "$EX_USAGE" "--owner must name the project owner"
case "$opt_owner" in *'|'*) die "$EX_USAGE" "--owner may not contain a Markdown table delimiter" ;; esac
[ "$(printf '%s\n' "$opt_owner" | wc -l | tr -d ' ')" -eq 1 ] \
    || die "$EX_USAGE" "--owner must fit on one line"
printf '%s' "$opt_email" | grep -Eq '^[^[:space:]@]+@[^[:space:]@]+$' \
    || die "$EX_USAGE" "--email must be a nonblank email address"
git check-ref-format --branch "$opt_integration" >/dev/null 2>&1 \
    || die "$EX_USAGE" "invalid primary branch name: ${opt_integration}"

in_git_repo || die "$EX_UNAVAILABLE" "initialize a Git repository in this template copy first"
[ ! -e "${IOSAI_ROOT}/.iosai-project" ] && [ ! -L "${IOSAI_ROOT}/.iosai-project" ] \
    || die "$EX_VERIFY" "this repository is already initialized (.iosai-project exists)"

op="$(git_operation_in_progress)" \
    || die "$EX_VERIFY" "could not establish initialization Git state"
[ -z "$op" ] || die "$EX_VERIFY" "a Git operation is in progress (${op})"

worktree_list="$(git -C "$IOSAI_ROOT" worktree list --porcelain)" \
    || die "$EX_VERIFY" "could not inspect worktrees before initialization"
worktree_count="$(printf '%s\n' "$worktree_list" | awk '/^worktree / { n++ } END { print n + 0 }')"
[ "$worktree_count" -eq 1 ] \
    || die "$EX_VERIFY" "initialization requires exactly one worktree; found ${worktree_count}"

# Inspect even an unborn repository: an unreadable/corrupt index is an error,
# not evidence that there are no changes to preserve.
initial_state="$(git -C "$IOSAI_ROOT" status --porcelain --untracked-files=all)" \
    || die "$EX_VERIFY" "could not read the working tree state; initialization changed nothing"
head_rc=0
initial_head="$(git -C "$IOSAI_ROOT" rev-parse --verify --quiet HEAD)" || head_rc=$?
case "$head_rc" in
    0) : ;;
    1) initial_head="" ;; # An unborn repository is supported.
    *) die "$EX_VERIFY" "could not inspect HEAD before initialization" ;;
esac
if [ -n "$initial_head" ] && [ -n "$initial_state" ]; then
    die "$EX_VERIFY" "the template copy has uncommitted changes; initialization requires a clean tree"
fi

# Product bytes prove this is not a fresh template. Refuse instead of deleting
# a project somebody may have already started.
unexpected_app="$(find "${IOSAI_ROOT}/App" -mindepth 1 ! -name '.gitkeep' -print -quit)" \
    || die "$EX_VERIFY" "could not inspect App/ before initialization"
[ -z "$unexpected_app" ] \
    || die "$EX_VERIFY" "App/ already contains product files; initialization must run before Xcode work"

# The same reasoning, for the other directory this script deletes from. A drafted
# milestone proves product work has already begun, and the reset below removes
# every non-M00 file in AI/milestones — which in a copy with no commits leaves no
# HEAD to restore it from. An audit reproduced that: `git init`, one drafted
# milestone, `make initialize` exits 0 reporting success, and the draft is gone
# with no reference to it anywhere in Git.
#
# AI/audits and AI/handoffs need no equivalent guard: verify-template.sh runs
# before any mutation and requires exactly one `**Policy status:**` line in every
# file under both, so a developer's own note there is already refused while the
# tree is still pristine.
unexpected_milestone="$(find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f \
    -name '*.md' ! -name 'M00-*.md' -print -quit)" \
    || die "$EX_VERIFY" "could not inspect milestones before initialization"
if [ -n "$unexpected_milestone" ]; then
    log_error "AI/milestones already holds drafted work: $(relpath "$unexpected_milestone")"
    hint "initialization replaces template memory and removes every non-M00 milestone."
    hint "run it before milestone work, or move the drafts aside and restore them after."
    exit "$EX_VERIFY"
fi

for required in AGENTS.md AI/WORKFLOW.md AI/PROJECT_STATUS.md \
                Scripts/configure-project.sh; do
    [ -f "${IOSAI_ROOT}/${required}" ] || die "$EX_NOINPUT" "fresh template input is missing: ${required}"
done
# M00 by ID, not by slug: naming it is the project's business, and this script is
# what carries it across initialization.
m00_file="$(find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name 'M00-*.md' -print -quit)" \
    || die "$EX_VERIFY" "could not inspect M00 before initialization"
[ -n "$m00_file" ] \
    || die "$EX_NOINPUT" "fresh template input is missing: AI/milestones/M00-<slug>.md"

assert_reset_directory_safe() {
    local relative="$1" dir="${IOSAI_ROOT}/${1}" links
    [ -d "$dir" ] || die "$EX_NOINPUT" "missing reset directory: ${relative}"
    assert_no_symlink_ancestry "$dir" || exit "$EX_USAGE"
    links="$(find "$dir" -mindepth 1 -type l -print -quit)" \
        || die "$EX_VERIFY" "could not inspect reset directory: ${relative}"
    [ -z "$links" ] \
        || die "$EX_USAGE" "refusing symlink inside reset directory: ${relative}"
}

reset_record_directory() {
    local relative="$1" dir="${IOSAI_ROOT}/${1}"
    find "$dir" -mindepth 1 -delete
    atomic_write_line_no_follow "${dir}/.gitkeep" "" "$dir"
}

write_status() {
    local target="${IOSAI_ROOT}/AI/PROJECT_STATUS.md" tmp
    assert_no_symlink_ancestry "$target" || exit "$EX_USAGE"
    tmp="$(mktemp "${IOSAI_ROOT}/AI/.project-status.tmp.XXXXXX")"
    cat > "$tmp" <<EOF
# Project status

**Phase:** discovery
**Current milestone:** none
**Completed milestones:** none
**Next milestone:** M00
**Blockers:** complete PRODUCT_BRIEF.md and approve PRODUCT.md, ARCHITECTURE.md, and DESIGN.md
**Important decisions:** initialized by ${opt_owner} on primary branch ${opt_integration}; every milestone is developed and verified there; optional worktrees may isolate parallel localization, independent review, or bounded experiments
EOF
    atomic_replace_file_no_follow "$tmp" "$target" "$IOSAI_ROOT"
}

# The seed is RENDERED by configure-project.sh, not copied from a committed
# Config/project.env.template. That file was a second hand-maintained copy of the
# same key set, so adding a configuration key meant four coordinated edits. The
# renderer is the one this repository already trusts to write a real
# configuration; using it here means the seed cannot drift from what
# configure-project.sh produces, because it IS what configure-project.sh produces.
#
# `--print` returns before configure-project.sh does its own validation, so the
# rendered bytes are validated here before anything is published.
write_seed_config() {
    local target="${IOSAI_ROOT}/Config/project.env" tmp
    assert_no_symlink_ancestry "$target" || exit "$EX_USAGE"
    tmp="$(mktemp "${IOSAI_ROOT}/Config/.project.env.tmp.XXXXXX")"
    if ! "${IOSAI_ROOT}/Scripts/configure-project.sh" --template-mode --print > "$tmp"; then
        rm -f -- "$tmp"
        die "$EX_SOFTWARE" "could not render the unconfigured project configuration"
    fi
    if ! env_file_validate "$tmp" >/dev/null 2>&1; then
        env_file_validate "$tmp" || true
        rm -f -- "$tmp"
        die "$EX_SOFTWARE" "the rendered project configuration is not structurally valid"
    fi
    atomic_replace_file_no_follow "$tmp" "$target" "$IOSAI_ROOT"
}

# The template's own README describes the template: how to initialize a copy, how
# to update the template itself, what its gates are for. A project made from the
# template inherited that document verbatim, so the first thing a new repository
# said about itself was somebody else's title. verify-template.sh already exempts
# README.md's structure in a derived project (IOSAI_TEMPLATE_ONLY_HEADING_DOCS);
# this writes the short stub that exemption was for. It is a starting point, not a
# contract — replace it as the product takes shape.
#
# The stub keeps the three prompts that drive the application lifecycle, because this
# function is what deletes the only other copy of them: the template README is read
# before initialization, and all three prompts are needed after it. Without them here the
# developer has to go back to the template repository to remember how to work. The
# first initializes, and the second carries every implementation, audit, and release
# readiness milestone end-to-end. AI/WORKFLOW.md stays the normative contract; this
# is the quick start.
#
# Only the title interpolates, so the body is a QUOTED heredoc: an unquoted one
# would run the ``` fences and the backticked commands as command substitution.
write_project_readme() {
    local target="${IOSAI_ROOT}/README.md" tmp
    assert_no_symlink_ancestry "$target" || exit "$EX_USAGE"
    tmp="$(mktemp "${IOSAI_ROOT}/.README.md.tmp.XXXXXX")"
    {
        printf "# %s's Apple platform project\n" "$opt_owner"
        cat <<'PRODUCT_README'

Describe the product here. Until then, the working documents are the truth:

- [AI/PRODUCT_BRIEF.md](AI/PRODUCT_BRIEF.md) — fill this in first
- [AI/PROJECT_STATUS.md](AI/PROJECT_STATUS.md) — where the work currently stands
- [AI/WORKFLOW.md](AI/WORKFLOW.md) — roles, milestones, verification, and release
- [AGENTS.md](AGENTS.md) — what an AI session reads before it does anything

Run `make help` for every local command. All verification runs on this Mac;
a push is backup and synchronization and verifies nothing.

## AI development workflow

The detailed source of truth is [AI/WORKFLOW.md](AI/WORKFLOW.md).

### 1. Initialize the product

After filling `AI/PRODUCT_BRIEF.md`:

```text
Initialize the product from AI/PRODUCT_BRIEF.md.
Stop when my approval is required.
```

### 2. Execute a milestone

Start a fresh Claude or Codex session for each milestone, and repeat this until the
project is finished:

```text
Execute the next ready milestone end-to-end.
```

Choose iOS or watchOS Watch-only in the product brief. Configuration defaults to
iOS; use `configure-project.sh --platform watchOS` for a modern Watch-only project.
Create the project in Xcode, retain its packaging container and include real Watch
tests in the shared scheme. Use one managed Watch simulator, without pairing.

One session owns exactly one milestone through implementation, tests, self-review,
fixes, verification, `DONE`, then stops.

The first milestone, M00, needs one thing from you before it starts: create the
Xcode project or workspace under `App/` in Xcode, with a shared scheme and at least
one real test target. If Xcode offers to create a Git repository for it, decline:
this repository already tracks `App/`. The M00 session connects it to this repository
and proves the build and test harness, and it stops and asks you if `App/` is still
empty.

### 3. Run Final Product Polish

When the last generated milestone is next-ready, start one fresh session with:

```text
Run the final product polish workflow end-to-end.
```

That session runs functional, UI/UX, content, accessibility, product, and release
domains in order; fixes blocking findings; performs one targeted re-audit; verifies
the milestone and exact release candidate; stops at `READY_FOR_HUMAN`; and starts no
next milestone. You then review, archive in Xcode, and distribute yourself.

That finishes the plan, not the project. When you want something more later, ask for it
to be appended as a new milestone: it gets the next sequential ID, is built on the
primary branch like every earlier one, and prompt 2 runs it. Everything
already finished stays as history. A later P0/P1 against original acceptance may
reopen that milestone only for correction while preserving its earlier evidence; new
scope is always appended. A code change after `READY_FOR_HUMAN` also means that
verdict now describes an older commit, so a fresh candidate needs its own appended
release readiness milestone.
[AI/WORKFLOW.md](AI/WORKFLOW.md) is the contract for all of it.

### Afterwards, if the app ships more than one language

The milestones build and verify English alone. Once `READY_FOR_HUMAN` is reached and
you have reviewed the finished build on a real device, you decide which languages to
add; each is then translated in its own Git worktree, in parallel, and the finished
branches are combined back into `main`. [AI/WORKFLOW.md](AI/WORKFLOW.md) and the
localization prompts under `AI/prompts/` are the contract. Nothing routes to them —
you send them yourself — and none of it reopens a milestone.
PRODUCT_README
    } > "$tmp"
    atomic_replace_file_no_follow "$tmp" "$target" "$IOSAI_ROOT"
}

# The template commit is the one piece of provenance this repository keeps. The
# history reset below prunes the commit itself and removes the remote that named it,
# yet M00's handoff must cite it as the evidence for every harness behaviour the
# template's own self-test proved. Nothing recorded it, so M00 asked for a SHA the
# repository could no longer produce. An unborn copy has no commit to name and says
# so rather than inventing one.
write_marker() {
    local target="${IOSAI_ROOT}/.iosai-project" tmp
    tmp="$(mktemp "${IOSAI_ROOT}/.iosai-project.tmp.XXXXXX")"
    {
        printf 'ios-ai-project/2\n'
        printf 'owner=%s\n' "$opt_owner"
        printf 'primary_branch=%s\n' "$opt_integration"
        printf 'template_commit=%s\n' "${initial_head:-unknown}"
    } > "$tmp"
    atomic_replace_file_no_follow "$tmp" "$target" "$IOSAI_ROOT"
}

# ---------------------------------------------------------------------------
# Failure after the reset used to leave a rewritten working tree with no word
# about how to get back. The reset itself is safe — every guard above refuses a
# dirty tree, product files under App/, or a previous initialization — so there
# is nothing irreplaceable to lose, but "records deleted, exit 65, no next step"
# is the least experienced moment in the whole workflow to be silent.
init_mutation_started="no"
init_history_replaced="no"
initialization_exit_hint() {
    local status=$?
    trap - EXIT
    [ "$status" -eq 0 ] && exit 0

    if [ "$init_history_replaced" = "yes" ]; then
        printf '\n'
        log_error "the Git history was replaced but initialization did not finish cleanly"
        hint "the new root commit exists; inspect it with:"
        hint "  git log --oneline && git status && git remote -v"
        hint "confirm the branch name and that no remote remains before starting M00."
    elif [ "$init_mutation_started" = "yes" ]; then
        printf '\n'
        log_error "initialization stopped after it had already rewritten template records"
        # Split on whether a HEAD exists, because the recovery differs completely
        # and the unborn branch used to get the committed branch's advice: it
        # asserted "recoverable from HEAD" in a repository that had no commit at
        # all, and offered `git clean -fd`, which there removes every top-level
        # path — Scripts/, AI/, Config/, the Makefile, the whole copy.
        if git_has_commits; then
            hint "no commit was made, so every original file is still recoverable from HEAD."
            hint "restore this template copy with:"
            hint "  git checkout -- . && git clean -fd"
            hint "then fix the reported problem and re-run."
        else
            hint "this copy has no commits, so Git cannot restore the records that were"
            hint "already rewritten. do not run a clean or a checkout here: everything in"
            hint "this directory is untracked, and both would remove the copy itself."
            hint "start again from a fresh template copy, and commit it before initializing."
        fi
    fi
    exit "$status"
}
trap initialization_exit_hint EXIT

# Validate the copy BEFORE touching it. A template that is already broken is
# caught while the tree is still pristine; the post-reset run further down stays,
# because only it can catch a reset that produced something invalid (a rendered
# seed missing a key, for example).
log_step "validating the template copy before changing it"
"${IOSAI_ROOT}/Scripts/verify-template.sh"

log_step "resetting template-only project memory"
assert_reset_directory_safe AI/audits
assert_reset_directory_safe AI/handoffs

milestone_dir="${IOSAI_ROOT}/AI/milestones"
assert_reset_directory_safe AI/milestones
assert_no_symlink_ancestry "${IOSAI_ROOT}/AI/PROJECT_STATUS.md" || exit "$EX_USAGE"
assert_no_symlink_ancestry "${IOSAI_ROOT}/Config/project.env" || exit "$EX_USAGE"
assert_no_symlink_ancestry "${IOSAI_ROOT}/README.md" || exit "$EX_USAGE"
if [ -e "$IOSAI_ARTIFACTS_DIR" ] || [ -L "$IOSAI_ARTIFACTS_DIR" ]; then
    [ -d "$IOSAI_ARTIFACTS_DIR" ] || die "$EX_USAGE" ".artifacts is not a directory"
    assert_reset_directory_safe .artifacts
fi

# An unborn copy is a supported starting point, but the reset below is the one
# moment in this workflow that Git cannot undo there. Say so before doing it,
# rather than reporting success afterwards.
if [ -z "$initial_head" ]; then
    log_warn "this copy has no commits, so the record reset below cannot be undone from Git"
    hint "committing the template copy first makes every step here recoverable."
fi

init_mutation_started="yes"
reset_record_directory AI/audits
reset_record_directory AI/handoffs

# Keep M00 under whatever slug this copy gives it. Matching the template's own
# filename literally would have deleted a project's renamed M00 — and the guard
# above has already refused every other milestone file, so this removes nothing
# a developer wrote.
find "$milestone_dir" -mindepth 1 -maxdepth 1 -type f \
    ! -name 'M00-*.md' -delete

if [ ! -d "$IOSAI_ARTIFACTS_DIR" ]; then
    assert_no_symlink_ancestry "$IOSAI_ARTIFACTS_DIR" || exit "$EX_USAGE"
    mkdir -- "$IOSAI_ARTIFACTS_DIR"
fi
assert_no_symlink_ancestry "$IOSAI_ARTIFACTS_DIR" || exit "$EX_USAGE"
while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    [ "$(basename -- "$entry")" = ".gitkeep" ] && continue
    safe_remove_path "$entry" "$IOSAI_ARTIFACTS_DIR"
done <<EOF
$(find "$IOSAI_ARTIFACTS_DIR" -mindepth 1 -maxdepth 1 -print)
EOF
atomic_write_line_no_follow "${IOSAI_ARTIFACTS_DIR}/.gitkeep" "" "$IOSAI_ARTIFACTS_DIR"

write_seed_config
write_project_readme
write_status
write_marker

"${IOSAI_ROOT}/Scripts/verify-template.sh"
"${IOSAI_ROOT}/Scripts/project-status.sh" validate

log_step "replacing reachable template Git history"
temp_branch="project-initialization-$$"
git check-ref-format --branch "$temp_branch" >/dev/null 2>&1 \
    || die "$EX_SOFTWARE" "could not form the temporary initialization branch"
git -C "$IOSAI_ROOT" symbolic-ref HEAD "refs/heads/${temp_branch}"
git -C "$IOSAI_ROOT" read-tree --empty
git -C "$IOSAI_ROOT" config user.name "$opt_owner"
git -C "$IOSAI_ROOT" config user.email "$opt_email"
git -C "$IOSAI_ROOT" add -A
git -C "$IOSAI_ROOT" commit -m "Initial project repository"
init_history_replaced="yes"

while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    [ "$ref" = "refs/heads/${temp_branch}" ] && continue
    git -C "$IOSAI_ROOT" update-ref -d "$ref"
done <<EOF
$(git -C "$IOSAI_ROOT" for-each-ref --format='%(refname)')
EOF

while IFS= read -r remote; do
    [ -n "$remote" ] || continue
    git -C "$IOSAI_ROOT" remote remove "$remote"
done <<EOF
$(git -C "$IOSAI_ROOT" remote)
EOF

git -C "$IOSAI_ROOT" branch -M "$opt_integration"
git -C "$IOSAI_ROOT" reflog expire --expire=now --all
git -C "$IOSAI_ROOT" gc --prune=now --quiet

reachable="$(git -C "$IOSAI_ROOT" rev-list --all --count)"
[ "$reachable" -eq 1 ] \
    || die "$EX_SOFTWARE" "initialization left ${reachable} reachable commits; expected one"
[ -z "$(git -C "$IOSAI_ROOT" remote)" ] \
    || die "$EX_SOFTWARE" "initialization left a remote configured"

log_ok "new project repository initialized"
log_info "PRIMARY_BRANCH=${opt_integration}"
log_info "PRIMARY_CHECKOUT=${IOSAI_ROOT}"
log_info "REACHABLE_COMMITS=${reachable}"
log_info "TEMPLATE_COMMIT=${initial_head:-unknown}"

log_info "NEXT_COMMAND=fill in AI/PRODUCT_BRIEF.md, send the product initialization prompt and approve its proposal, then start M00 in this checkout"
