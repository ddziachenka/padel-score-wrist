#!/usr/bin/env bash
# verify-template.sh — validate the template itself.
#
# Checks the scaffolding, not the product: required files, executable scripts,
# shell syntax, optional hook definition, ignore rules, configuration structure, and the
# required headings in every core document.
#
# Runs with no Xcode project and no git repository, so it is the first thing to
# run in a fresh copy of the template.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

FAILURES=0
fail() { log_error "$@"; FAILURES=$((FAILURES + 1)); }

# ---------------------------------------------------------------------------
REQUIRED_FILES="
AGENTS.md
CLAUDE.md
README.md
Makefile
.gitignore
AI/PRODUCT_BRIEF.md
AI/PRODUCT.md
AI/ARCHITECTURE.md
AI/DESIGN.md
AI/WORKFLOW.md
AI/PROJECT_STATUS.md
AI/templates/milestone-template.md
AI/templates/handoff-template.md
AI/templates/audit-template.md
AI/templates/domain-audit-template.md
AI/templates/release-audit-template.md
AI/templates/project-status-template.md
AI/prompts/initialize-product.md
AI/prompts/execute-next-milestone.md
AI/prompts/review-milestone.md
AI/prompts/migrate-final-polish.md
AI/prompts/final-polish.md
AI/templates/final-polish-audit-template.md
AI/prompts/add-localization-worktree.md
AI/prompts/integrate-localization-worktrees.md
AI/prompts/polish-localizations.md
AI/prompts/final-release-readiness.md
AI/prompts/audit-functional.md
AI/prompts/audit-ui-ux.md
AI/prompts/audit-content.md
AI/prompts/audit-accessibility.md
AI/prompts/audit-product.md
AI/prompts/audit-release.md
Config/project.env.example
Config/release-requirements.v3.tsv
Config/placeholder-allowlist.txt
Config/credential-scan-allowlist.txt
Scripts/lib/common.sh
Scripts/lib/simulator.sh
Scripts/lib/platform.sh
Scripts/lib/lease.pl
Scripts/simulator.sh
.githooks/pre-commit
"

REQUIRED_DIRS="
AI/milestones
AI/templates
AI/prompts
AI/audits
AI/handoffs
Config
Scripts
Scripts/lib
.githooks
App
.artifacts
"

REQUIRED_SCRIPTS="
Scripts/simulator.sh
Scripts/configure-project.sh
Scripts/initialize-project.sh
Scripts/install-git-hooks.sh
Scripts/verify-template.sh
Scripts/verify-static.sh
Scripts/verify-fast.sh
Scripts/verify-milestone.sh
Scripts/verify-integration.sh
Scripts/verify-release.sh
Scripts/create-worktree.sh
Scripts/remove-worktree.sh
Scripts/project-status.sh
Scripts/clean-artifacts.sh
Scripts/clean-derived-data.sh
Scripts/self-test.sh
"

# file<TAB>heading — a document that has lost its structure has lost its
# contract, so these are checked rather than trusted.
#
# README.md's rows describe THIS template's own front page, so they are enforced
# only in the universal template — see IOSAI_TEMPLATE_ONLY_HEADING_DOCS below.
# Every other document here is a workflow or product contract that a product
# repository keeps.
REQUIRED_HEADINGS="
AGENTS.md	## Start every session
AGENTS.md	## Obligations
AGENTS.md	## Sources of truth
CLAUDE.md	## Session roles
CLAUDE.md	## Checkouts and Git
README.md	## Core model
README.md	## The three prompts you need
README.md	## Daily development
README.md	## Milestones and review
README.md	## Release
README.md	## Updating this template
AI/WORKFLOW.md	## The workflow
AI/WORKFLOW.md	## Sessions
AI/WORKFLOW.md	## Independent review
AI/WORKFLOW.md	## Final Product Polish and release readiness
AI/WORKFLOW.md	## Git and recovery
AI/WORKFLOW.md	## Milestones
AI/WORKFLOW.md	## Verification levels
AI/WORKFLOW.md	## Conditional integration
AI/WORKFLOW.md	## Release
AI/PRODUCT_BRIEF.md	## The idea
AI/PRODUCT_BRIEF.md	## Users and problem
AI/PRODUCT_BRIEF.md	## MVP scope
AI/PRODUCT_BRIEF.md	## Non-goals
AI/PRODUCT_BRIEF.md	## Unresolved decisions
AI/PRODUCT.md	## Approved decisions
AI/PRODUCT.md	## Assumptions
AI/PRODUCT.md	## Unresolved decisions
AI/PRODUCT.md	## Non-goals
AI/PRODUCT.md	## Human approval points
AI/ARCHITECTURE.md	## Selected technologies
AI/ARCHITECTURE.md	## Dependency boundaries
AI/ARCHITECTURE.md	## State ownership
AI/ARCHITECTURE.md	## Testing strategy
AI/ARCHITECTURE.md	## Rejected alternatives
AI/ARCHITECTURE.md	## Unresolved decisions
AI/DESIGN.md	## Information architecture
AI/DESIGN.md	## Interface states
AI/DESIGN.md	## Legal and support
AI/DESIGN.md	## Review request
AI/DESIGN.md	## Visual direction
AI/DESIGN.md	## Craftsmanship and signature experience
AI/DESIGN.md	## Accessibility
AI/DESIGN.md	## Localization
AI/DESIGN.md	## Prohibited patterns
AI/templates/release-audit-template.md	## Verdict
AI/templates/release-audit-template.md	## Findings
AI/templates/release-audit-template.md	## Distribution readiness
"

# Documents whose required headings belong to the universal template alone.
#
# A product repository's README is its app's front page — the first thing a
# developer replaces and the first thing anyone reads on GitHub. Requiring
# `## Updating this template` there made `make static` fail the moment somebody
# wrote their own, and because verify-static.sh runs this file first, that took the
# optional pre-commit hook and the first stage of every strict gate with it. The
# reported reason was a missing heading, which does not explain the policy.
#
# `.iosai-project` is the discriminator: initialize-project.sh writes it, the
# universal template does not carry it, and initialization refuses to run at all
# when it already exists — so it cannot appear here.
IOSAI_TEMPLATE_ONLY_HEADING_DOCS="README.md"

FORBIDDEN_LIVE_PATHS="
AI/OPERATING_MANUAL.md
AI/LOCAL_VERIFICATION_POLICY.md
AI/RELEASE_CRITERIA.md
AI/UX_CONTRACT.md
AI/DESIGN_SYSTEM.md
AI/roles
AI/checklists
AI/decisions
AI/templates/decision-record-template.md
AI/prompts/integrate-milestone.md
"

# Ignore rules that must be present, or evidence and secrets end up committed.
#
# The last two are not about secrets. `wrangler` writes .wrangler/ beside the
# site it publishes, and npm writes node_modules/; milestone_checkout_is_clean
# refuses any untracked file at all, so a product repository that dropped these
# rules would find every gate blocked the first time it deployed Web/.
REQUIRED_IGNORES="
.artifacts/*
!.artifacts/.gitkeep
*.xcresult
*.xcarchive
DerivedData/
*.mobileprovision
*.p12
*.key
*.pfx
.wrangler/
node_modules/
"

log_step "Template structure"

# Template validation is read-only. Initialization owns creation of the evidence
# root; a validator must report missing structure rather than repairing what it
# was asked to inspect.
if [ ! -d "$IOSAI_ARTIFACTS_DIR" ]; then
    fail "missing directory: .artifacts/"
elif [ ! -e "${IOSAI_ARTIFACTS_DIR}/.gitkeep" ]; then
    fail "missing file: .artifacts/.gitkeep"
else
    assert_no_symlink_ancestry "${IOSAI_ARTIFACTS_DIR}/.gitkeep" || exit "$EX_USAGE"
    [ -f "${IOSAI_ARTIFACTS_DIR}/.gitkeep" ] \
        || die "$EX_USAGE" ".artifacts/.gitkeep is not a regular file"
fi

while IFS= read -r forbidden; do
    [ -n "$forbidden" ] || continue
    if [ -e "${IOSAI_ROOT}/${forbidden}" ] || [ -L "${IOSAI_ROOT}/${forbidden}" ]; then
        fail "obsolete live workflow path remains: ${forbidden}"
    fi
done <<EOF
$FORBIDDEN_LIVE_PATHS
EOF

for d in $REQUIRED_DIRS; do
    [ -d "${IOSAI_ROOT}/${d}" ] || fail "missing directory: ${d}/"
done

for f in $REQUIRED_FILES; do
    if [ ! -f "${IOSAI_ROOT}/${f}" ]; then
        fail "missing file: ${f}"
    elif [ ! -s "${IOSAI_ROOT}/${f}" ]; then
        fail "empty file: ${f}"
    fi
done

# M00 must exist, but its slug is the project's to choose.
#
# This was `AI/milestones/M00-template-bootstrap.md` in REQUIRED_FILES, which meant
# every repository made from this template had to keep the template's own filename
# forever: renaming it to a product slug failed `make static`, and therefore the
# optional pre-commit hook and every strict gate's first stage. Nothing else needed
# the exact name — milestone_file_for_id resolves `M00-*.md`, and
# milestones_validate_all already refuses two files sharing that prefix.
m00_files="$(find "${IOSAI_ROOT}/AI/milestones" -maxdepth 1 -type f -name 'M00-*.md' \
    2>/dev/null | sort || true)"
if [ -z "$m00_files" ]; then
    fail "no M00 milestone: expected AI/milestones/M00-<slug>.md"
    hint "M00 is what proves the verification harness works; every other milestone"
    hint "depends on it. create one from AI/templates/milestone-template.md."
else
    while IFS= read -r m00_file; do
        [ -n "$m00_file" ] || continue
        [ -s "$m00_file" ] || fail "empty file: $(relpath "$m00_file")"
    done <<EOF
$m00_files
EOF
fi

for s in $REQUIRED_SCRIPTS; do
    if [ ! -f "${IOSAI_ROOT}/${s}" ]; then
        fail "missing script: ${s}"
    elif [ ! -x "${IOSAI_ROOT}/${s}" ]; then
        fail "script is not executable: ${s} (fix: chmod +x ${s})"
    fi
done

for h in pre-commit; do
    if [ ! -x "${IOSAI_ROOT}/.githooks/${h}" ]; then
        fail "hook is not executable: .githooks/${h} (fix: chmod +x .githooks/${h})"
    fi
done

[ "$FAILURES" -eq 0 ] && log_ok "required files, directories, and permissions"

# ---------------------------------------------------------------------------
log_step "Shell syntax"
syntax_failures=0
for f in "${IOSAI_ROOT}"/Scripts/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.sh \
         "${IOSAI_ROOT}"/.githooks/pre-commit; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" 2>/dev/null; then
        fail "shell syntax error: $(relpath "$f")"
        bash -n "$f" 2>&1 | sed 's/^/           /' >&2 || true
        syntax_failures=$((syntax_failures + 1))
    fi
done
if ! perl -c "${IOSAI_ROOT}/Scripts/lib/lease.pl" >/dev/null 2>&1; then
    fail "Perl syntax/prerequisite error: Scripts/lib/lease.pl"
    syntax_failures=$((syntax_failures + 1))
fi
[ "$syntax_failures" -eq 0 ] && log_ok "bash -n clean across Scripts/ and .githooks/"

# ---------------------------------------------------------------------------
log_step "No cloud CI"
# All verification is local by design. A workflow directory here would mean
# somebody expects a remote runner to do this work; it must not exist.
if [ -e "${IOSAI_ROOT}/.github" ]; then
    fail ".github/ exists — this template runs every check locally and has no CI"
    hint "review and remove .github/ deliberately; this template has no cloud CI"
    if [ -d "${IOSAI_ROOT}/.github/workflows" ]; then
        fail ".github/workflows/ exists — GitHub Actions are explicitly out of scope"
    fi
else
    log_ok "no .github/ directory"
fi

# ---------------------------------------------------------------------------
log_step "Optional hook definition"
for h in pre-commit; do
    hook="${IOSAI_ROOT}/.githooks/${h}"
    [ -f "$hook" ] || continue
    referenced="$(grep -oE 'Scripts/verify-[a-z-]+\.sh' "$hook" | sort -u || true)"
    if [ -z "$referenced" ]; then
        fail ".githooks/${h} references no verification script"
        continue
    fi
    while IFS= read -r ref; do
        [ -n "$ref" ] || continue
        if [ ! -x "${IOSAI_ROOT}/${ref}" ]; then
            fail ".githooks/${h} references ${ref}, which is missing or not executable"
        fi
    done <<EOF
$referenced
EOF
    # A hook that pushes would recurse forever. Only a command at the start of a
    # line counts; the hooks legitimately mention `git push` in prose and output.
    if grep -Eq '^[[:space:]]*(git|/usr/bin/git)[[:space:]]+push([[:space:]]|$)' "$hook"; then
        fail ".githooks/${h} runs 'git push' — that would recurse"
    fi
done
log_ok "the optional pre-commit hook references an executable static check"
if [ -e "${IOSAI_ROOT}/.githooks/pre-push" ]; then
    fail ".githooks/pre-push exists — push must remain storage/synchronization only"
fi
if [ -e "${IOSAI_ROOT}/Scripts/verify-push.sh" ]; then
    fail "Scripts/verify-push.sh exists — use explicit verify-integration.sh candidates"
fi

# ---------------------------------------------------------------------------
log_step "Ignore rules"
if [ ! -f "${IOSAI_ROOT}/.gitignore" ]; then
    fail ".gitignore is missing"
else
    while IFS= read -r pattern; do
        [ -n "$pattern" ] || continue
        if ! grep -Fxq "$pattern" "${IOSAI_ROOT}/.gitignore"; then
            fail ".gitignore is missing the required pattern: ${pattern}"
        fi
    done <<EOF
$REQUIRED_IGNORES
EOF
    # Reproducible configuration must stay tracked. Fixed-string matching: some of
    # these names contain glob metacharacters that are not valid regex.
    for keeper in 'Config/project.env' 'xcshareddata' '*.xctestplan' '*.storekit'; do
        if grep -Fxq "$keeper" "${IOSAI_ROOT}/.gitignore" \
           || grep -Fxq "/${keeper}" "${IOSAI_ROOT}/.gitignore"; then
            fail ".gitignore ignores ${keeper}, which is required for reproducible configuration"
        fi
    done
    log_ok "artifact and secret patterns present; reproducible configuration not ignored"
fi

# ---------------------------------------------------------------------------
log_step "Configuration"
if [ ! -f "$IOSAI_CONFIG_EXAMPLE" ]; then
    fail "Config/project.env.example is missing"
else
    if env_file_validate "$IOSAI_CONFIG_EXAMPLE" >/dev/null 2>&1; then
        log_ok "Config/project.env.example parses"
    else
        fail "Config/project.env.example is not structurally valid"
        env_file_validate "$IOSAI_CONFIG_EXAMPLE" || true
    fi
    example_keys="$(env_file_keys "$IOSAI_CONFIG_EXAMPLE")"
    for key in $IOSAI_CONFIG_KEYS; do
        if ! line_in_list "$key" "$example_keys"; then
            fail "Config/project.env.example does not document the key: ${key}"
        fi
    done
    # No simulator may be baked in as a default.
    for baked in BUILD_DESTINATION TEST_DESTINATION; do
        value="$(grep -m1 "^${baked}=" "$IOSAI_CONFIG_EXAMPLE" | sed 's/^[^=]*=//; s/^"//; s/"$//' || true)"
        if [ -n "$value" ]; then
            fail "Config/project.env.example hard-codes ${baked}=\"${value}\""
            hint "destinations belong in comments as examples only"
        fi
    done
fi

# The unconfigured seed initialize-project.sh writes is RENDERED, not copied from
# a committed Config/project.env.template. That file was a second hand-maintained
# copy of the same key set: adding one key meant editing IOSAI_CONFIG_KEYS,
# env_file_load, the example, and the seed, and only three of those four were
# checked against each other. Checking the renderer instead exercises the code path
# initialization actually runs — a static file could be complete while the command
# that produces the real seed was not.
# The scratch file goes to the system temp directory, never into IOSAI_ROOT: this
# gate also runs from the read-only detached worktree that the milestone,
# integration and release gates materialise, where any write into the source would
# fail — and being read-only there is itself a tested property.
config_seed="$(mktemp "${TMPDIR:-/tmp}/iosai-seed-check.XXXXXX")" \
    || die "$EX_CANTCREAT" "cannot create a scratch file to render the initialization seed"
seed_rc=0
"${IOSAI_ROOT}/Scripts/configure-project.sh" --template-mode --print > "$config_seed" 2>/dev/null \
    || seed_rc=$?
if [ "$seed_rc" -ne 0 ]; then
    fail "configure-project.sh --template-mode --print failed with exit ${seed_rc}"
    hint "this is the seed initialize-project.sh writes; it must render cleanly"
elif env_file_validate "$config_seed" >/dev/null 2>&1; then
    seed_keys="$(env_file_keys "$config_seed")"
    for key in $IOSAI_CONFIG_KEYS; do
        if ! line_in_list "$key" "$seed_keys"; then
            fail "the rendered initialization seed is missing the key: ${key}"
            hint "add an assignment for it to configure-project.sh's rendered template"
        fi
    done
    if [ "$(grep -m1 '^TEMPLATE_REPOSITORY=' "$config_seed")" != 'TEMPLATE_REPOSITORY="true"' ]; then
        fail "the rendered initialization seed must be in template mode"
    else
        log_ok "the rendered initialization seed is a complete template-mode configuration"
    fi
else
    fail "the rendered initialization seed is not structurally valid"
    env_file_validate "$config_seed" || true
fi
rm -f -- "$config_seed"

# The exception list is a contract too — validated whether or not a placeholder
# exists today, so a bad entry fails when it is written rather than when it is
# first relied upon.
if placeholder_allowlist_validate; then
    log_ok "Config/placeholder-allowlist.txt entries are exact, non-shipping, reasoned, and unexpired"
else
    fail "Config/placeholder-allowlist.txt has invalid entries"
fi

# The credential-scan exemptions get the same treatment, for the same reason: an
# entry that excuses a private key, a whole tree, or a rule the scan does not have
# is refused when it is written, not when a secret first walks through it.
if credential_allowlist_scan >/dev/null; then
    log_ok "Config/credential-scan-allowlist.txt entries are exact, single-rule, reasoned, and unexpired"
else
    fail "Config/credential-scan-allowlist.txt has invalid entries"
fi

if [ -f "$IOSAI_CONFIG_FILE" ]; then
    if env_file_validate "$IOSAI_CONFIG_FILE" >/dev/null 2>&1; then
        log_ok "Config/project.env parses"
    else
        fail "Config/project.env is not structurally valid"
        env_file_validate "$IOSAI_CONFIG_FILE" || true
    fi
else
    log_skip "Config/project.env (not created yet — run ./Scripts/configure-project.sh)"
fi

if validate_release_coverage_schema; then
    log_ok "${IOSAI_RELEASE_COVERAGE_SCHEMA} is unique, typed, domain-owned, and channel-valid"
else
    fail "Config/release-requirements.v3.tsv is invalid"
fi

# ---------------------------------------------------------------------------
log_step "Document structure"
is_derived_project="no"
if [ -e "${IOSAI_ROOT}/.iosai-project" ] || [ -L "${IOSAI_ROOT}/.iosai-project" ]; then
    is_derived_project="yes"
fi
missing_headings=0
while IFS="$(printf '\t')" read -r doc heading; do
    [ -n "${doc:-}" ] || continue
    [ -n "${heading:-}" ] || continue
    if [ "$is_derived_project" = "yes" ] \
       && token_in_list "$doc" "$IOSAI_TEMPLATE_ONLY_HEADING_DOCS"; then
        continue
    fi
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq "$heading" "$path"; then
        fail "${doc} is missing the required heading: ${heading}"
        missing_headings=$((missing_headings + 1))
    fi
done <<EOF
$REQUIRED_HEADINGS
EOF
# Reported once per document, after the loop: each of these documents contributes
# several rows, and one skip line per row would say the same thing five times.
if [ "$is_derived_project" = "yes" ]; then
    for doc in $IOSAI_TEMPLATE_ONLY_HEADING_DOCS; do
        log_skip "${doc} structure (a project made from the template; its ${doc} is its own)"
    done
fi
[ "$missing_headings" -eq 0 ] && log_ok "core documents keep their required sections"

# ---------------------------------------------------------------------------
log_step "Superseded vocabulary"
# Instructions that were retired must not come back in a live document. The
# absence of these strings was asserted only by the self-test, which is the
# slowest gate there is — so a document could be edited, committed, and pushed
# with a superseded instruction in it, and every fast check passed. The strings
# are cheap to look for, so they are looked for here, on every `make static` and
# every optional pre-commit.
#
# AI/audits/ and AI/handoffs/ are deliberately NOT scanned. A superseded record
# keeps its original text — that is what '**Policy status:** superseded' certifies
# — and rewriting history to satisfy a grep would destroy the evidence the record
# exists to hold. Scripts/ is not scanned either, so this list cannot match itself.
#
# The second group retires the mandatory two-session milestone model: a Builder
# used to stop at REVIEW so that a separate independent Reviewer could set DONE.
# One session now carries one milestone to DONE, without exception, so each of
# these claims is unconditionally false rather than merely narrowed. Generic
# vocabulary — 'reviewer', 'review', 'independent review' — is deliberately NOT
# listed: an optional extra review and the independent release audit are still
# real, supported concepts, and banning the words would forbid describing them.
#
# The third group retires automatic archiving. Archive creation and distribution
# are outside verification, so these keys and flags configure nothing and their
# absence from Config/ is enforced by the allowlist in common.sh instead. Generic
# distribution vocabulary remains available. Config/ is not scanned, so the live
# configuration and its example are unaffected.
#
# The final-audit architecture is enforced structurally below rather than by banned
# prose. That lets the migration prompt describe older separate audit milestones
# while preserving recorded history for a project-specific migration decision.
#
# The fifth group is one entry, and it retires an artifact this template never named
# but repeatedly asked for. Telling a localization session to translate "App Store
# metadata kept in this repository" made it invent a file to hold it, and a product
# repository ended up with AI/STORE_TEXT.md and ten locale variants beside it. The
# listing belongs to App Store Connect, so no live document may name that file. Only
# the bare stem is listed: it matches STORE_TEXT.md and STORE_TEXT.<locale>.md alike,
# and 'App Store', 'StoreKit', 'metadata', 'screenshots', and 'localization' all keep
# legitimate uses and stay legal. A product repository that keeps its own store copy
# for its own separate workflow is not this list's business — Config/, Web/, and
# Scripts/ are not scanned, and no path guard forbids the file existing. What is
# forbidden is a live workflow document, or the generated seed README, routing work to
# it, which is what turned it into template behavior in the first place.
#
# The sixth group is two sentences, and it retires the claim that the generated plan
# closes the project. Final Product Polish ends the plan initialization generates;
# new scope that appears afterwards is appended as a new milestone, and completed
# evidence stays as history; the separately documented P0/P1 correction exception
# preserves that evidence when it returns a milestone to IN_PROGRESS. Both retired
# sentences said otherwise as an absolute:
# one made Final Product Polish the only milestone that could ever run the release
# gate, which a Release Readiness Revalidation milestone contradicts, and the other told
# the routing prompt that nothing follows it at all. Their replacements are required
# phrases in the final-milestone contract below. Only these two ASCII sentences are
# listed: the readiness prompt's own em-dashed version of the second claim is retired by
# a positive required phrase instead, because a truncation short enough to match it
# would also match ordinary product prose in a derived repository.
#
# Worktree entries retire the absolute claim that localization is the only valid
# worktree use. Milestone work still stays in the primary checkout; independent
# read-only review and bounded experiments may use optional worktrees too.
# Matching is per line, so each entry must be a phrase that fits on one.
SUPERSEDED_STRINGS="make push-check
push-check:
ready-for-integration
CANDIDATE=<sha>
release-requirements/2
release-requirements.v2.tsv
release-coverage.v1.tsv
release-coverage/1
READY_FOR_DISTRIBUTION
RELEASE_ARCHIVE_REQUIRED
ENABLE_ARCHIVE
ARCHIVE_WAIVER_REASON
--enable-archive
--no-archive-required
--archive-waiver-reason
Builder cannot set
The Builder never sets
Only an independent Reviewer sets
Do not combine Builder and Reviewer
stop for a fresh Reviewer session
stops for an independent Reviewer
not perform the independent review yourself
independent review is required
Independent review: required
Builder stops at REVIEW
make worktree ID=
--worktree-path
requires a milestone ID and cannot create
a bare locale is not a milestone ID
integrate-branches.md
worktree is for post-milestone localization only
Worktrees exist for one thing
A long review or an experiment is not a reason to cut one
STORE_TEXT
No other milestone runs the release gate
it is the last milestone, and none follows it"

# A strict superset of the two document sets the self-test used to scan separately:
# the product contracts are live normative documents too, and the Makefile is where
# a retired target would come back.
live_documents=""
for candidate_doc in "${IOSAI_ROOT}/README.md" "${IOSAI_ROOT}/AGENTS.md" \
                     "${IOSAI_ROOT}/CLAUDE.md" "${IOSAI_ROOT}/Makefile" \
                     "${IOSAI_ROOT}/AI/WORKFLOW.md" "${IOSAI_ROOT}/AI/PRODUCT.md" \
                     "${IOSAI_ROOT}/AI/ARCHITECTURE.md" "${IOSAI_ROOT}/AI/DESIGN.md" \
                     "${IOSAI_ROOT}/AI/PRODUCT_BRIEF.md" "${IOSAI_ROOT}/AI/PROJECT_STATUS.md" \
                     "${IOSAI_ROOT}"/AI/prompts/*.md \
                     "${IOSAI_ROOT}"/AI/templates/*.md \
                     "${IOSAI_ROOT}"/AI/milestones/*.md; do
    [ -f "$candidate_doc" ] || continue
    live_documents="${live_documents}${candidate_doc}
"
done

superseded_hits=0
while IFS= read -r superseded_string; do
    [ -n "$superseded_string" ] || continue
    while IFS= read -r live_doc; do
        [ -n "$live_doc" ] || continue
        # -F: every one of these is a literal, and 'CANDIDATE=<sha>' would
        # otherwise be read as a regular expression by a later editor's mistake.
        if grep -Fq -- "$superseded_string" "$live_doc"; then
            fail "$(relpath "$live_doc") names the superseded '${superseded_string}'"
            superseded_hits=$((superseded_hits + 1))
        fi
    done <<INNER
$live_documents
INNER
done <<EOF
$SUPERSEDED_STRINGS
EOF
if [ "$superseded_hits" -eq 0 ]; then
    log_ok "no live document names a superseded command, state, or schema"
else
    hint "these were replaced by the current policy in AI/WORKFLOW.md."
    hint "historical records under AI/audits/ and AI/handoffs/ keep their original"
    hint "text and are not scanned; a live document must state current policy."
fi

# ---------------------------------------------------------------------------
log_step "Record classification"
# Every audit and handoff must say, in one machine-readable field, whether it is
# current policy or a superseded historical record. A reader — human or agent —
# otherwise has to infer it from prose, and an old handoff's spent instructions
# read as live ones. `current` needs nothing but the marker; no owners, approvals,
# or lifecycle states.
policy_failures=0
for record in "${IOSAI_ROOT}"/AI/audits/*.md "${IOSAI_ROOT}"/AI/handoffs/*.md; do
    [ -f "$record" ] || continue
    rel="$(relpath "$record")"
    status_count="$(machine_field_count "$record" 'Policy status')"
    if [ "$status_count" -ne 1 ]; then
        if [ "$status_count" -eq 0 ]; then
            fail "${rel}: no '**Policy status:**' field"
            hint "add '**Policy status:** current' or '**Policy status:** superseded'"
        else
            fail "${rel}: ${status_count} '**Policy status:**' fields; exactly one is allowed"
            hint "two answers to the same question is ambiguity, not a merge"
        fi
        policy_failures=$((policy_failures + 1))
        continue
    fi
    policy_status="$(milestone_field "$record" 'Policy status')"
    case "$policy_status" in
        current)
            # A current record may not also carry supersession markers.
            if grep -Fq 'HISTORICAL RECORD' "$record" \
               || [ "$(machine_field_count "$record" 'Superseded by')" -ne 0 ]; then
                fail "${rel}: declares 'current' but also carries supersession markers"
                hint "a record is either current policy or superseded, never both"
                policy_failures=$((policy_failures + 1))
            fi ;;
        superseded)
            if ! grep -Fq 'HISTORICAL RECORD' "$record"; then
                fail "${rel}: declares 'superseded' without the HISTORICAL RECORD banner"
                hint "a reader needs the banner before the body, not only a metadata line"
                policy_failures=$((policy_failures + 1))
            fi
            if ! grep -Fq 'solo-workflow/2' "$record"; then
                fail "${rel}: superseded record does not name the current normative policy"
                hint "state which policy replaced it, so the reader knows where to look"
                policy_failures=$((policy_failures + 1))
            fi ;;
        *)
            fail "${rel}: '**Policy status:** ${policy_status}' is neither current nor superseded"
            policy_failures=$((policy_failures + 1)) ;;
    esac
done
[ "$policy_failures" -eq 0 ] \
    && log_ok "every audit and handoff declares current or superseded policy status"

# ---------------------------------------------------------------------------
log_step "Merge conflict markers"
# Every text file a project actually edits, not just the four extensions the
# ungrouped expression used to collapse to. `=======` is deliberately not a
# marker here: it is also a Markdown setext underline, and a check that fires on
# valid documents gets disabled.
#
# Enumerated with its status checked before anything is scanned: piping
# `repo_files` straight into the loop and ending in `|| true` made a failed walk
# — one unreadable directory — indistinguishable from a clean tree.
conflict_incomplete="no"
conflict_candidates=""
if ! conflict_candidates="$(repo_files -name '*.md' -o -name '*.sh' -o -name '*.env' \
        -o -name '*.swift' -o -name '*.h' -o -name '*.m' -o -name '*.mm' \
        -o -name '*.json' -o -name '*.plist' -o -name '*.xcconfig' \
        -o -name '*.pbxproj' -o -name '*.xctestplan' -o -name '*.storekit' \
        -o -name '*.entitlements' -o -name 'Makefile' \
        -o -name 'pre-commit' 2>&1)"; then
    fail "could not scan the repository for merge conflict markers"
    printf '%s\n' "$conflict_candidates" | sed 's/^/           /' >&2
    hint "the scan is inconclusive; fix the unreadable path and re-run"
    conflict_candidates=""
    conflict_incomplete="yes"
fi
conflicts=""
conflict_readable=""
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ ! -r "$f" ]; then
        fail "could not scan $(relpath "$f") for merge conflict markers: not readable"
        conflict_incomplete="yes"
        continue
    fi
    conflict_readable="${conflict_readable}${f}
"
done <<EOF
$conflict_candidates
EOF
conflict_readable="$(printf '%s' "$conflict_readable" | grep -v '^$' || true)"
if [ -n "$conflict_readable" ]; then
    conflict_scan_rc=0
    conflicts="$(printf '%s\n' "$conflict_readable" \
        | scan_matching_files '^(<{7}|>{7})( |$)')" || conflict_scan_rc=$?
    if [ "$conflict_scan_rc" -ne 0 ]; then
        fail "could not scan the repository for merge conflict markers (scanner failed)"
        conflict_incomplete="yes"
        conflicts=""
    fi
fi
conflicts="$(printf '%s' "$conflicts" | grep -v '^$' || true)"
if [ -n "$conflicts" ]; then
    fail "unresolved merge conflict markers:"
    printf '%s\n' "$conflicts" | sed "s|^${IOSAI_ROOT}/|           |" >&2
elif [ "$conflict_incomplete" = "yes" ]; then
    log_error "conflict-marker scan incomplete — no clean result is claimed"
else
    log_ok "no conflict markers"
fi

# ---------------------------------------------------------------------------
log_step "Report field quoting"
# A backtick inside a DOUBLE-quoted report_line argument is command substitution,
# not Markdown. `"**VERIFIED_COMMIT:** `${sha}`"` runs the SHA as a command and
# publishes an empty field, so the report states the gate passed without saying
# what it passed on. Single-quoted arguments are the legitimate ``` fences and are
# stripped before the check.
backtick_failures=0
for f in "${IOSAI_ROOT}"/Scripts/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.sh; do
    [ -f "$f" ] || continue
    unescaped="$(awk '
        /report_line/ {
            line = $0
            gsub(/'"'"'[^'"'"']*'"'"'/, "", line)
            if (line ~ /[^\\]`/) printf "%d: %s\n", FNR, $0
        }' "$f")"
    if [ -n "$unescaped" ]; then
        fail "unescaped backtick in a double-quoted report_line argument: $(relpath "$f")"
        printf '%s\n' "$unescaped" | sed 's/^/           /' >&2
        hint "write \\\` so the value reaches the report instead of being executed"
        backtick_failures=$((backtick_failures + 1))
    fi
done
[ "$backtick_failures" -eq 0 ] && log_ok "report fields quote their backticks"

# ---------------------------------------------------------------------------
log_step "Pipeline early exit"
# A pipe into a reader that stops early is a race under `set -o pipefail`. grep -q,
# head, and an awk program that exits at a match leave the producer with a write
# pending; the producer takes SIGPIPE, and pipefail reports 141 for a lookup that
# succeeded — "absent" for a key that is present, or an abort under `set -e`. An
# audit measured 9 wrong answers in 80,000 such checks on a loaded machine, and one
# of them failed `make self-test` by reporting that the configuration example did
# not document a key it plainly documents.
#
# So the scripts are read for the shape itself. A reader stops early when it is grep
# with -q, -m, or -l (or a long spelling of one), head, or an awk program whose main
# rules contain `exit` — an exit inside END runs after the input is drained, so it is
# not one. The one permitted producer is `printf '%s' "$VALUE"`: one value with no
# newline in the format leaves no line before its end, so the reader cannot finish
# while a write is still pending. Anything else uses line_in_list from common.sh, or
# a reader that drains its input.
#
# Logical lines are joined across backslash continuations and a trailing pipe.
# Comment lines and trailing comments are skipped, and so are the bodies of quoted
# here-documents, which are literal text that never runs. self-test.sh is excluded
# because it plants this exact shape on purpose, to prove this guard fires.
read -r -d '' PIPE_EXIT_AWK <<'AWK' || true
function stops_early(cmd,   q, rest, prog) {
    sub(/^[[:space:]]+/, "", cmd)
    if (cmd ~ /^head([[:space:]]|$)/) return 1
    if (cmd ~ /^grep[[:space:]]/) {
        sub(/[|;&].*$/, "", cmd)
        if (cmd ~ /[[:space:]]-[A-Za-z]*[qml]/) return 1
        if (cmd ~ /[[:space:]]--(quiet|silent|max-count|files-with-matches)/) return 1
        return 0
    }
    if (cmd ~ /^awk[[:space:]]/) {
        q = index(cmd, "'")
        if (q == 0) return 0
        rest = substr(cmd, q + 1)
        q = index(rest, "'")
        if (q == 0) return 0
        prog = substr(rest, 1, q - 1)
        sub(/END[[:space:]]*\{.*$/, "", prog)
        return (prog ~ /(^|[^A-Za-z0-9_])exit([^A-Za-z0-9_]|$)/) ? 1 : 0
    }
    return 0
}
function single_value(before) {
    return (before ~ /printf[[:space:]]+'%s'[[:space:]]+"\$\{?[A-Za-z_][A-Za-z0-9_]*\}?"[[:space:]]*$/)
}
# A pipe only counts outside quotes. `$(` opens a fresh quoting context, so the pipe
# inside "$(producer | reader)" is still found, and a parenthesis is matched to the
# frame that opened it.
function scan(line, lineno,   i, n, c, in_s, in_d, depth, frame, shown) {
    n = length(line)
    in_s = 0; in_d = 0; depth = 0
    for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (in_s) { if (c == "'") in_s = 0; continue }
        if (c == "\\") { i++; continue }
        if (c == "'" && !in_d) { in_s = 1; continue }
        if (c == "\"") { in_d = !in_d; continue }
        if (c == "$" && substr(line, i + 1, 1) == "(") {
            frame[++depth] = in_d ? "D1" : "D0"
            in_d = 0; i++
            continue
        }
        if (c == "(" && !in_d) { frame[++depth] = "P"; continue }
        if (c == ")" && !in_d && depth > 0) {
            if (frame[depth] == "D1") in_d = 1
            depth--
            continue
        }
        if (c != "|" || in_d) continue
        if (substr(line, i + 1, 1) == "|") { i++; continue }
        if (stops_early(substr(line, i + 1)) && !single_value(substr(line, 1, i - 1))) {
            shown = line
            gsub(/[[:space:]]+/, " ", shown)
            printf "%s:%d: %s\n", FILENAME, lineno, shown
            bad = 1
        }
    }
}
FNR == 1 {
    if (logical != "") scan(logical, start)
    logical = ""; in_doc = 0; pending = ""
}
{
    raw = $0
    if (in_doc) {
        t = raw
        sub(/^\t+/, "", t)
        if (t == doc_tag) in_doc = 0
        next
    }
    if (logical == "" && raw ~ /^[[:space:]]*#/) next
    line = raw
    sub(/[[:space:]]#.*$/, "", line)
    if (match(line, /<<-?[[:space:]]*['"][A-Za-z_][A-Za-z0-9_]*['"]/)) {
        pending = substr(line, RSTART, RLENGTH)
        sub(/^<<-?[[:space:]]*['"]/, "", pending)
        sub(/['"]$/, "", pending)
    }
    if (logical == "") start = FNR
    more = 0
    if (line ~ /\\$/) { sub(/\\$/, "", line); more = 1 }
    else if (line ~ /(^|[^|])\|[[:space:]]*$/) more = 1
    logical = logical " " line
    if (!more) { scan(logical, start); logical = "" }
    if (pending != "") { in_doc = 1; doc_tag = pending; pending = "" }
}
END {
    if (logical != "") scan(logical, start)
    exit (bad ? 1 : 0)
}
AWK

pipe_exit_hits=""
pipe_exit_failures=0
for f in "${IOSAI_ROOT}"/Scripts/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.sh \
         "${IOSAI_ROOT}"/.githooks/*; do
    [ -f "$f" ] || continue
    case "${f##*/}" in self-test.sh) continue ;; esac
    pipe_exit_rc=0
    pipe_exit_out="$(awk "$PIPE_EXIT_AWK" "$f")" || pipe_exit_rc=$?
    case "$pipe_exit_rc" in
        0) : ;;
        1) pipe_exit_hits="${pipe_exit_hits}${pipe_exit_out}
" ;;
        *)
            fail "could not scan $(relpath "$f") for early-exit pipelines (scanner exited ${pipe_exit_rc})"
            pipe_exit_failures=$((pipe_exit_failures + 1)) ;;
    esac
done
pipe_exit_hits="$(printf '%s' "$pipe_exit_hits" | grep -v '^$' || true)"
if [ -n "$pipe_exit_hits" ]; then
    fail "a pipe feeds a reader that stops early, which pipefail turns into a random failure:"
    printf '%s\n' "$pipe_exit_hits" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    hint "use line_in_list from Scripts/lib/common.sh for a membership test, or a reader"
    hint "that drains its input (awk without exit, sed -n 1p); printf '%s' of one value"
    hint "is the only producer that may feed grep -q"
elif [ "$pipe_exit_failures" -eq 0 ]; then
    log_ok "no pipe feeds a reader that stops before its input ends"
fi

# ---------------------------------------------------------------------------
log_step "Prompt preflight"
# AGENTS.md mandates the same state reconstruction at the start of every session.
# A pasted prompt must reconstruct the same repository state as AGENTS.md.
PROMPT_PREFLIGHT="git status
AGENTS.md
AI/WORKFLOW.md
AI/PROJECT_STATUS.md"

preflight_failures=0
for p in "${IOSAI_ROOT}"/AI/prompts/*.md; do
    [ -f "$p" ] || continue
    rel="$(relpath "$p")"
    actual="$(awk '/^[0-9]+\. / && n < 4 { print; n++ }' "$p")"
    position=1
    while IFS= read -r want; do
        [ -n "$want" ] || continue
        line="$(printf '%s\n' "$actual" | sed -n "${position}p")"
        case "$line" in
            *"$want"*) : ;;
            *)  fail "${rel}: preflight item ${position} should reference '${want}'"
                hint "found: ${line:-(nothing)}"
                preflight_failures=$((preflight_failures + 1)) ;;
        esac
        position=$((position + 1))
    done <<EOF
$PROMPT_PREFLIGHT
EOF
done
[ "$preflight_failures" -eq 0 ] && log_ok "every prompt opens with the canonical preflight, in order"

# ---------------------------------------------------------------------------
log_step "Final Product Polish contract"
# Product initialization generates one last milestone. Its one Builder session runs
# six domain methods in a fixed order, repairs blocking findings, performs one targeted
# re-audit, writes one consolidated record, and runs both milestone and release gates
# against the same candidate. These checks run on every static gate; self-test mutates
# each load-bearing part to prove the guard fires.
#
# What the phrase checks prove is that the documents STATE these rules. No grep can
# prove that a session obeyed one, so every message below says what was read, never
# what was done. Two rules cannot be proved more strongly than that and must not
# pretend otherwise: convergence — nothing here can observe a session looping — and
# the absence of automatic publication, whose real guarantee is that no gate contacts
# App Store Connect at all (AI/WORKFLOW.md) plus obligation A13.
#
# Every phrase is one line on purpose. Matching is per line, exactly as in the
# superseded-vocabulary guard above: a phrase that wrapped at 80 columns would be
# searched for and never found, and this section would pass while proving nothing.

# Model-driven generation is anchored by one exact `<title> -> <prompt>` row. The
# orchestrator's ordered domain list is checked separately below.
FINAL_SEQUENCE="Final Product Polish -> AI/prompts/final-polish.md"
FINAL_DOMAIN_SEQUENCE="AI/prompts/audit-functional.md
AI/prompts/audit-ui-ux.md
AI/prompts/audit-content.md
AI/prompts/audit-accessibility.md
AI/prompts/audit-product.md
AI/prompts/audit-release.md"

# file<TAB>phrase — the one line each document must carry for the rule it owns.
# No entry contains a backtick: this is a double-quoted shell string, and one would
# be read as command substitution.
#
FINAL_REQUIRED_PHRASES="
AI/WORKFLOW.md	P2 never blocks
AI/WORKFLOW.md	one full pass per domain and one targeted re-audit
AI/WORKFLOW.md	FUTURE_PRODUCT_IDEA
AI/WORKFLOW.md	never P0 or P1
AI/WORKFLOW.md	it is not implemented in this milestone
AI/WORKFLOW.md	Product initialization appends exactly one
AI/WORKFLOW.md	One Builder session owns that milestone
AI/WORKFLOW.md	The milestone writes one consolidated
AI/WORKFLOW.md	stops without starting another milestone or audit cycle
AI/WORKFLOW.md	A completed milestone is history: new work is appended as a new milestone.
AI/WORKFLOW.md	never reopened, renumbered, or reused for new scope.
AI/WORKFLOW.md	The sole correction exception is a later P0/P1
AI/WORKFLOW.md	needs another audit gets a new targeted audit milestone.
AI/WORKFLOW.md	evidence for its candidate SHA and no other.
AI/WORKFLOW.md	configuration change invalidates that verdict
AI/prompts/execute-next-milestone.md	When the selected milestone is
AI/prompts/execute-next-milestone.md	final-polish.md
AI/prompts/execute-next-milestone.md	Append the next sequential milestone rather than reopening a finished one for new
AI/prompts/final-release-readiness.md	make release CANDIDATE=
AI/prompts/final-release-readiness.md	READY_FOR_HUMAN
AI/prompts/final-release-readiness.md	Nothing is uploaded, submitted, archived, or published
AI/prompts/final-release-readiness.md	start no next milestone and no second audit
AI/prompts/final-release-readiness.md	When it closes a later Release Readiness Revalidation milestone
AI/prompts/final-polish.md	one targeted re-audit
AI/prompts/final-polish.md	fix every valid P0 and P1 in this session
AI/prompts/final-polish.md	P2 is non-blocking
AI/prompts/final-polish.md	AI/audits/<ID>-final-polish.md
AI/prompts/final-polish.md	make milestone ID=<ID>
AI/prompts/final-polish.md	make release CANDIDATE=<verified-full-SHA>
AI/prompts/final-polish.md	milestone and no second audit cycle.
AI/prompts/audit-product.md	FUTURE_PRODUCT_IDEA
AI/prompts/initialize-product.md	next sequential ID rather than a hard-coded one
AI/prompts/initialize-product.md	this milestone depends on every implementation
AI/prompts/initialize-product.md	one Builder session end-to-end like every other milestone
AI/prompts/initialize-product.md	./Scripts/project-status.sh validate
AI/prompts/review-milestone.md	Never repair the implementation during this review
AI/templates/final-polish-audit-template.md	## Functional Correctness / Bug Hunt
AI/templates/final-polish-audit-template.md	## Release / App Store / Privacy / Monetization
AI/templates/final-polish-audit-template.md	## Targeted re-audit
AI/templates/final-polish-audit-template.md	## Verification and release
"

CHECKOUT_REQUIRED_PHRASES="
AGENTS.md	Optional worktrees
AI/WORKFLOW.md	Optional worktrees are useful
AI/WORKFLOW.md	Run the gate whenever independently developed
AI/WORKFLOW.md	never carry milestone implementation
"

# Each audit states the same rule about a capability the product does not have: it
# is INAPPLICABLE with a reason — the release checklist's own evidence vocabulary —
# and deliberately NOT "skipped", which A9 and log_skip reserve for a check that did
# not run and therefore did not pass. Single-quoted so the backticks stay literal.
FINAL_AUDIT_PROMPTS="
AI/prompts/audit-functional.md
AI/prompts/audit-ui-ux.md
AI/prompts/audit-content.md
AI/prompts/audit-accessibility.md
AI/prompts/audit-product.md
AI/prompts/audit-release.md
"
AUDIT_INAPPLICABLE_PHRASE='`INAPPLICABLE` with a reason, not as a finding'
AUDIT_INVENTORY_PHRASE='minimum maintained coverage, not the limit of what to inspect'
AUDIT_NO_REPAIR_PHRASE='Never repair the implementation during this review'

final_failures=0
generator="${IOSAI_ROOT}/AI/prompts/initialize-product.md"

# A missing generator is already a missing REQUIRED_FILE; nothing below it could be
# evaluated, and a second report of the same absence would not help.
if [ -f "$generator" ]; then
    # `|| true`: no matching line at all is a reportable finding below, not a
    # pipeline error that aborts the whole gate under `set -e` and `pipefail`.
    found_sequence="$(grep -F -- ' -> AI/prompts/' "$generator" \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' || true)"
    if [ "$found_sequence" != "$FINAL_SEQUENCE" ]; then
        fail "AI/prompts/initialize-product.md does not state the one final milestone"
        hint "expected exactly one '<title> -> <prompt>' line:"
        printf '%s\n' "$FINAL_SEQUENCE" | sed 's/^/           /' >&2
        hint "found:"
        printf '%s\n' "${found_sequence:-(no such line at all)}" | sed 's/^/           /' >&2
        final_failures=$((final_failures + 1))
    fi
fi

# The orchestrator must name every domain once and in the required order.
final_polish="${IOSAI_ROOT}/AI/prompts/final-polish.md"
if [ -f "$final_polish" ]; then
    found_domains="$(grep -oE 'AI/prompts/audit-(functional|ui-ux|content|accessibility|product|release)\.md' \
        "$final_polish" || true)"
    if [ "$found_domains" != "$FINAL_DOMAIN_SEQUENCE" ]; then
        fail "AI/prompts/final-polish.md does not state the six audit domains in order"
        hint "expected:"
        printf '%s\n' "$FINAL_DOMAIN_SEQUENCE" | sed 's/^/           /' >&2
        hint "found:"
        printf '%s\n' "${found_domains:-(no domain prompts)}" | sed 's/^/           /' >&2
        final_failures=$((final_failures + 1))
    fi
fi

# Only the generator and orchestrator may name the whole domain set. A specialist
# prompt, milestone template, or ordinary routing document that quietly starts
# orchestrating several domains would create an unbounded second path.
for final_doc in "${IOSAI_ROOT}/README.md" "${IOSAI_ROOT}/AGENTS.md" \
                 "${IOSAI_ROOT}/CLAUDE.md" "${IOSAI_ROOT}/AI/WORKFLOW.md" \
                 "${IOSAI_ROOT}"/AI/prompts/*.md \
                 "${IOSAI_ROOT}"/AI/templates/*.md \
                 "${IOSAI_ROOT}"/AI/milestones/*.md; do
    [ -f "$final_doc" ] || continue
    [ "$final_doc" = "$generator" ] && continue
    [ "$final_doc" = "$final_polish" ] && continue
    # Most documents name none, which is the common case and not an error.
    named="$(grep -oE 'audit-(functional|ui-ux|content|accessibility|product|release)\.md' \
        "$final_doc" | sort -u | tr '\n' ' ' | sed 's/ $//' || true)"
    case "$named" in
        *' '*)
            fail "$(relpath "$final_doc") names more than one domain audit prompt: ${named}"
            hint "only initialize-product.md and final-polish.md list the whole set"
            final_failures=$((final_failures + 1)) ;;
    esac
done

# Release verification belongs to the orchestrator or a later readiness revalidation,
# never to an individual domain method. The same loop keeps the Builder/Reviewer
# repair boundary explicit.
while IFS= read -r audit_prompt; do
    [ -n "$audit_prompt" ] || continue
    path="${IOSAI_ROOT}/${audit_prompt}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$AUDIT_INAPPLICABLE_PHRASE" "$path"; then
        fail "${audit_prompt} does not state: ${AUDIT_INAPPLICABLE_PHRASE}"
        hint "an absent capability is INAPPLICABLE with a reason, never a finding —"
        hint "and never 'skipped', which A9 reserves for a check that did not run"
        final_failures=$((final_failures + 1))
    fi
    if ! grep -Fq -- "$AUDIT_INVENTORY_PHRASE" "$path"; then
        fail "${audit_prompt} does not state: ${AUDIT_INVENTORY_PHRASE}"
        hint "Config/release-requirements.v3.tsv is the floor for each audit, not its ceiling"
        final_failures=$((final_failures + 1))
    fi
    if ! grep -Fq 'Config/release-requirements.v3.tsv' "$path"; then
        fail "${audit_prompt} names no maintained inventory for its domain"
        final_failures=$((final_failures + 1))
    fi
    if grep -Fq 'make release CANDIDATE=' "$path"; then
        fail "${audit_prompt} runs release verification"
        hint "only final-polish.md, or a later readiness revalidation, runs 'make release'"
        hint "an individual domain method returns to its one orchestrating milestone"
        final_failures=$((final_failures + 1))
    fi
    if grep -Fq -- "$AUDIT_NO_REPAIR_PHRASE" "$path"; then
        fail "${audit_prompt} carries the Reviewer's no-repair instruction"
        hint "a Builder domain audit fixes what it finds; that sentence belongs to"
        hint "review-milestone.md, which is the optional independent review"
        final_failures=$((final_failures + 1))
    fi
done <<EOF
$FINAL_AUDIT_PROMPTS
EOF

while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the final audit rule: ${phrase}"
        hint "it must appear on one line; check that an edit did not wrap it"
        final_failures=$((final_failures + 1))
    fi
done <<EOF
$FINAL_REQUIRED_PHRASES
EOF

while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the checkout and integration rule: ${phrase}"
        final_failures=$((final_failures + 1))
    fi
done <<EOF
$CHECKOUT_REQUIRED_PHRASES
EOF

# Ordinary milestone routing must hand the last milestone to the orchestrator.
next_prompt="${IOSAI_ROOT}/AI/prompts/execute-next-milestone.md"
if [ -f "$next_prompt" ]; then
    if ! grep -Fq 'final-polish.md' "$next_prompt"; then
        fail "AI/prompts/execute-next-milestone.md does not route to final-polish.md"
        final_failures=$((final_failures + 1))
    fi
    if ! grep -Fq 'Audit prompt:' "$next_prompt"; then
        fail "AI/prompts/execute-next-milestone.md does not read Final Product Polish's Audit prompt field"
        final_failures=$((final_failures + 1))
    fi
fi

# READY_FOR_HUMAN is a release verdict from verify-release.sh, not another milestone
# state. A document that writes it into a **Status:** field is proposing a state
# machine this repository does not have.
for final_doc in "${IOSAI_ROOT}"/AI/prompts/*.md "${IOSAI_ROOT}"/AI/templates/*.md \
                 "${IOSAI_ROOT}"/AI/milestones/*.md; do
    [ -f "$final_doc" ] || continue
    if grep -Fq -- '**Status:** READY_FOR_HUMAN' "$final_doc"; then
        fail "$(relpath "$final_doc") uses READY_FOR_HUMAN as a milestone status"
        hint "it is a release verdict; the five states are listed in AI/WORKFLOW.md"
        final_failures=$((final_failures + 1))
    fi
done

# Prompts, not role definitions with a directory each. A find that failed is reported
# as a failure: a scan that could not run is not a clean result.
if ! prompt_subdirs="$(find "${IOSAI_ROOT}/AI/prompts" -mindepth 1 -type d 2>&1)"; then
    fail "could not list AI/prompts/ — no clean result is claimed"
    printf '%s\n' "$prompt_subdirs" | sed 's/^/           /' >&2
    final_failures=$((final_failures + 1))
elif [ -n "$prompt_subdirs" ]; then
    fail "AI/prompts/ contains a subdirectory — domain methods stay prompt files, not a hierarchy"
    printf '%s\n' "$prompt_subdirs" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    final_failures=$((final_failures + 1))
fi

if ! validate_generated_final_milestones; then
    fail "generated final milestone contract is invalid"
    final_failures=$((final_failures + 1))
fi

[ "$final_failures" -eq 0 ] \
    && log_ok "the one Final Product Polish milestone, ordered domains, convergence, record, and release boundary are stated"

# A concrete audit result must never ship in the universal template, but that is
# deliberately NOT checked here. Nothing in a record's structure distinguishes a real
# product audit from the valid-record probes this repository's own regression suite
# writes into AI/audits/, and a product repository legitimately keeps its own
# domain and optional audit records. What is committed to the template is a
# property of the template's tree, so self-test asserts it against tracked files.

# ---------------------------------------------------------------------------
log_step "Review request contract"
# Whether to ask for a rating is decided once, here, for every iOS product this template
# generates; what initialization decides is the moment. An app that never asks is
# rated by the people annoyed enough to go looking for the App Store page, and an app
# that asks badly is the reason the pattern has a bad name — so the moment is a
# product decision, and the ways of asking that are never acceptable are a universal
# rule that survives into every product.
#
# Two documents carry the rule, each checked by the shortest phrase that cannot
# survive it being dropped. Short on purpose: matching is per line exactly as above,
# and an anchor long enough to wrap at 80 columns would be searched for and never
# found. AI/DESIGN.md's `## Review request` section is a REQUIRED_HEADINGS row rather
# than an entry here, so a product repository must keep the section too — which is
# what "every product" means — and the prohibited-pattern bullets live under that
# file's existing `## Prohibited patterns` heading for the same reason.
REVIEW_REQUEST_PHRASES="
AI/prompts/initialize-product.md	owns the review request
AI/prompts/initialize-product.md	watchOS does not generate Review Request
AI/DESIGN.md	watchOS has no required rating request
AI/DESIGN.md	sentiment gate
"

review_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the review request rule: ${phrase}"
        hint "one implementation milestone owns the review request, and the rating"
        hint "prompt is never gated by how the person says they feel about the app"
        review_failures=$((review_failures + 1))
    fi
done <<EOF
$REVIEW_REQUEST_PHRASES
EOF

[ "$review_failures" -eq 0 ] \
    && log_ok "the iOS review request and watchOS exception are stated"

# ---------------------------------------------------------------------------
log_step "Legal and support contract"
# Apple requires a working privacy policy URL and support URL of every App Store
# app, and Terms and Privacy links inside any app selling a subscription. This
# template used to state that only as three release rows — REL-406, REL-503,
# REL-1004 — with nothing anywhere that ever produced the pages those rows
# describe. A product reached its release audit owing three
# answers it had no way to give, and the site got improvised at submission or not
# written at all.
#
# So the site is a deliverable of the template now: Web/ holds it, three keys in
# Config/project.env identify it, one generated implementation milestone fills it
# in, and verify-site.sh checks it on every `make static`. What is asserted here is
# that the DOCUMENTS still carry the rule, because that is the part a rewrite can
# quietly drop while every script keeps passing.
#
# AI/DESIGN.md's `## Legal and support` section is a REQUIRED_HEADINGS row rather
# than an entry here, so a product repository must keep the section too — which is
# what "every product" means — and the prohibited-pattern bullets live under that
# file's existing `## Prohibited patterns` heading for the same reason.
#
# Every phrase is one line, matched exactly as in the guards above: an anchor long
# enough to wrap at 80 columns would be searched for and never found, and this
# section would pass while proving nothing.
LEGAL_SUPPORT_PHRASES="
AI/prompts/initialize-product.md	owns the legal and support links
AI/DESIGN.md	Apple Standard EULA
AI/DESIGN.md	reachable only from the paywall
AI/ARCHITECTURE.md	Published site (Cloudflare Pages)
"

legal_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the legal and support rule: ${phrase}"
        hint "one implementation milestone owns the privacy, terms, and support"
        hint "links, and all three are reachable without paying for anything"
        legal_failures=$((legal_failures + 1))
    fi
done <<EOF
$LEGAL_SUPPORT_PHRASES
EOF

# The site is part of the template's tree, not something a product invents. A
# missing page here is a template that can no longer generate a compliant product,
# and it is cheaper to say so than to let verify-site.sh report it once per
# product repository.
for site_file in \
    Web/README.md \
    Web/wrangler.jsonc \
    Web/public/index.html \
    Web/public/privacy/index.html \
    Web/public/terms/index.html \
    Web/public/support/index.html \
    Web/public/styles.css \
    Web/public/_headers
do
    if [ ! -f "${IOSAI_ROOT}/${site_file}" ]; then
        fail "the published site scaffold is missing: ${site_file}"
        legal_failures=$((legal_failures + 1))
    fi
done

[ "$legal_failures" -eq 0 ] \
    && log_ok "the privacy, terms, and support links are mandated once, and the site ships with the template"

# ---------------------------------------------------------------------------
log_step "Premium override contract"
# A developer who cannot reach the paid build on a real device improvises the way
# in, and what gets improvised is a check in a view, a second source of truth, or a
# toggle that survives into Release. So the override's shape is decided once here —
# one name, one defaults key, resolved through the entitlement owner, wrapped in
# `#if DEBUG` — and verify-static.sh proves the containment in every repository.
#
# AI/DESIGN.md is anchored on its PROHIBITED-PATTERN bullet, never on the paragraph
# under `## Purchases and paywalls`. That section is one the file tells a product
# selling nothing to delete, this loop runs in product repositories too, and
# anchoring there would fail `make static` in exactly the products that correctly
# have no override — the same mistake as requiring `## Updating this template` of a
# product README, recorded above. `## Prohibited patterns` is a required heading and
# costs a free app nothing: "never do this" is true whether or not it sells.
#
# Short anchors, per the review request contract above: matching is per line, and a
# phrase long enough to wrap at 80 columns is searched for and never found.
PREMIUM_OVERRIDE_PHRASES="
AI/ARCHITECTURE.md	compiled out of Release
AI/DESIGN.md	A premium override that ships
AI/prompts/audit-release.md	the one sanctioned construct
AI/prompts/initialize-product.md	delivers the override
"

override_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the premium override rule: ${phrase}"
        hint "the milestone that delivers the entitlement source of truth delivers"
        hint "the override with it, and it is compiled out of the shipped build"
        override_failures=$((override_failures + 1))
    fi
done <<EOF
$PREMIUM_OVERRIDE_PHRASES
EOF

[ "$override_failures" -eq 0 ] \
    && log_ok "the premium override is mandated once, and is compiled out of Release"

# ---------------------------------------------------------------------------
log_step "Price presentation contract"
# A paywall is where a product is most tempted to lie, and the lies are cheap: a
# crossed-out "regular price" nothing ever charged, a saving nobody computed, an
# introductory price that never says what follows it. None of them looks wrong to the
# developer who wrote them, because they read their own paywall in their own
# storefront with the numbers they already believe. So the rule is fixed once here —
# every price comes from StoreKit, a comparison is derived from the real products,
# and an offer states what is charged when it ends — REL-408 is what a person then
# confirms, and verify-static.sh refuses a price literal in any repository.
#
# AI/DESIGN.md is anchored on a PROHIBITED-PATTERN bullet, for the reason recorded
# under the premium override above: a product that sells nothing deletes
# `## Purchases and paywalls`, this loop runs in product repositories too, and
# anchoring there would fail `make static` in exactly the free products that owe none
# of this. AI/PRODUCT.md's `### Free versus paid` is deletable for the same reason and
# carries no anchor either.
#
# Short anchors, one line each, no backticks — as in the three loops above.
PRICE_PRESENTATION_PHRASES="
AI/ARCHITECTURE.md	computed, never authored
AI/DESIGN.md	An invented reference price
AI/prompts/audit-release.md	the products the store actually returns
AI/prompts/initialize-product.md	delivers its price presentation
"

price_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the price presentation rule: ${phrase}"
        hint "every price comes from StoreKit and a comparison is computed from the"
        hint "real products, so no reference price is invented to decorate an offer"
        price_failures=$((price_failures + 1))
    fi
done <<EOF
$PRICE_PRESENTATION_PHRASES
EOF

[ "$price_failures" -eq 0 ] \
    && log_ok "prices come from StoreKit, and a comparison is derived from real products"

# ---------------------------------------------------------------------------
log_step "Product craftsmanship contract"
# An application can pass every gate in this repository and still feel like nobody
# decided anything: correct states, correct tests, default hierarchy, no feedback, no
# reason to open it twice. Nothing above catches that, because none of it is a defect
# in the sense the other guards understand — which is exactly why the questions have to
# be asked before the milestones exist rather than noticed after the release audit.
#
# So four documents own one rule each, and this loop asserts they still state them:
# initialization considers mechanics specific to THIS product and one signature moment
# before proposing contracts, PRODUCT records the ideas it did not select instead of
# quietly widening scope with them, DESIGN prohibits decoration used as a substitute for
# resolving a screen, and WORKFLOW puts the craftsmanship pass inside the Builder's own
# self-review. None of them adds a role, a session, a milestone state, or a document.
#
# The last anchor is the opposite kind of rule: specialized iOS skills make this work
# better when a session has them, so the template says to use them — and says, on one
# line a rewrite cannot lose, that none is a prerequisite. A template that quietly grew
# a dependency on an optional skill would fail on the first machine without it, with a
# reason nobody could read from the failure.
#
# AI/DESIGN.md's `## Craftsmanship and signature experience` is a REQUIRED_HEADINGS row
# rather than an entry here, so a product repository keeps the section too, and the
# prohibited-pattern anchor lives under that file's existing `## Prohibited patterns`
# heading for the reason recorded under the premium override above: a section a product
# may delete cannot hold an anchor. AI/PRODUCT.md's row is under `## Approved
# decisions`, which is a required heading and is never deleted.
#
# Short anchors, one line each, no backticks — as in the loops above.
CRAFTSMANSHIP_PHRASES="
AI/prompts/initialize-product.md	Signature Experience
AI/prompts/initialize-product.md	mechanics that genuinely fit the approved MVP
AI/PRODUCT.md	FUTURE_PRODUCT_IDEA
AI/DESIGN.md	Decoration standing in for resolution
AI/WORKFLOW.md	craftsmanship pass
AI/WORKFLOW.md	is not a dependency of this template
"

craft_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the craftsmanship rule: ${phrase}"
        hint "initialization considers this product's own mechanics and one signature"
        hint "moment, and the Builder's self-review covers craft in the same session"
        craft_failures=$((craft_failures + 1))
    fi
done <<EOF
$CRAFTSMANSHIP_PHRASES
EOF

[ "$craft_failures" -eq 0 ] \
    && log_ok "product mechanics, the signature experience, and the craftsmanship pass are stated"

# ---------------------------------------------------------------------------
log_step "Decision autonomy contract"
# Two failure modes sit on one axis, and the template used to state only half of the
# rule that separates them. A session that stops to ask which state container to use
# spends the developer's attention on something the contracts already settle; a session
# that picks the monetization model itself takes a decision that was never its to take.
# The old text said to decide implementation questions yourself and then listed the
# reasons to stop, which left both halves underspecified: it never said to choose the
# option you would recommend and proceed, and it never said what a question looks like
# when one is genuinely warranted.
#
# So the rule now has a shape as well as a boundary, and this loop asserts that the
# documents still state both. The routine categories are the session's to settle; the
# stop list is for genuine product decisions; and a question that does reach the
# developer carries two to four options with exactly one marked Recommended and makes no
# progress until one is chosen. AGENTS carries it as an obligation, AI/WORKFLOW.md as
# the normative section, the two lifecycle prompts at the point of use, the product
# audit where its own corrections turn strategic, and AI/PRODUCT.md where a marked
# option must not be read as a settled one.
#
# No new stage, state, role, or document came with any of it, and none of that needs a
# rule here: AI/decisions and AI/templates/decision-record-template.md are already in
# FORBIDDEN_LIVE_PATHS above, and the five milestone states are fixed in
# Scripts/lib/common.sh. Scripts/self-test.sh asserts that this guard fires, per anchor.
#
# Every anchor carries its cardinality on purpose. A bare "marked Recommended" would be
# satisfied by prose offering a dozen options, and "wait" alone by prose that never says
# progress stops — the two ways this policy decays into a formality. README.md is
# deliberately absent: a derived project replaces that file with its own product guide,
# for the same reason its heading rows are exempted above.
#
# Short anchors, one line each, no backticks — as in the loops above.
DECISION_PHRASES="
AGENTS.md	A16 Decide reversible choices yourself
AGENTS.md	two to four options, one marked Recommended
AI/WORKFLOW.md	any other reversible implementation choice
AI/WORKFLOW.md	two to four genuine options
AI/WORKFLOW.md	exactly one marked Recommended
AI/WORKFLOW.md	wait for that choice before continuing
AI/prompts/execute-next-milestone.md	choose the option you would recommend
AI/prompts/execute-next-milestone.md	exactly one option marked Recommended
AI/prompts/initialize-product.md	Options column offers two to four
AI/prompts/audit-product.md	precise question with two to four options
AI/PRODUCT.md	A recommendation is not a resolution
"

decision_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the decision autonomy rule: ${phrase}"
        hint "a reversible implementation choice is decided and recommended rather than"
        hint "asked about; a genuine product decision is asked once, with a marked option"
        decision_failures=$((decision_failures + 1))
    fi
done <<EOF
$DECISION_PHRASES
EOF

[ "$decision_failures" -eq 0 ] \
    && log_ok "routine choices are the session's, and a real question carries a recommendation"

# ---------------------------------------------------------------------------
log_step "Visual craftsmanship contract"
# The craftsmanship contract above establishes that a product should feel made rather
# than assembled. It never says how a moment worth building properly actually gets built,
# and that gap has two opposite failure modes. One is a product assembled entirely from
# default controls because nothing told the session that a bespoke illustration, a piece
# of motion, or a haptic was ever an option. The other is worse and far more likely from
# a model asked to make something feel premium: artwork on every screen, a spring on
# every transition, and a generated illustration filling space that a clearer hierarchy
# would have filled better.
#
# So the anchors below come in matched pairs, and the pairing is the point. The capability
# is stated (initialization names this product's own delight opportunities; DESIGN carries
# a medium order and an asset bar; WORKFLOW says such work is judged running) and every
# statement of it is bounded in the same document (the opportunities are not features,
# native comes first, one strong asset beats several decorative ones). The two audits get
# the same treatment from the other side: the UI/UX audit may not turn a clean native
# screen into a finding, and the product audit may not score a product higher for holding
# more artwork. A guard that asserted only the first half of any of those pairs would
# ratchet this template toward decoration, which is the outcome it exists to prevent.
#
# The remaining two anchors protect the template FROM a change rather than requiring one,
# for the reason recorded under the craftsmanship loop above. An optional design or
# image-generation capability must stay optional: the moment a missing one can block a
# milestone, every machine and every agent without it fails for a reason no message
# explains, and Claude and Codex are both meant to remain valid here. The runtime anchor
# is the honesty half of that — an asset in the catalogue is not an asset that works on
# the screen, and a session that cannot see the difference has not checked.
#
# Every AI/DESIGN.md anchor sits under `## Craftsmanship and signature experience`, which
# is a REQUIRED_HEADINGS row, for the reason the premium override records: a section a
# product repository may delete cannot hold an anchor. `## Motion and haptics` carries the
# motion rules but no anchor, because it is not a required heading.
#
# Short anchors, one line each, no backticks — as in the loops above.
VISUAL_CRAFT_PHRASES="
AI/prompts/initialize-product.md	Delight Opportunities
AI/DESIGN.md	They are opportunities, not features
AI/DESIGN.md	Native first, and a bespoke asset only where native cannot express it
AI/DESIGN.md	One strong asset is worth more than several decorative ones
AI/WORKFLOW.md	a design, image-generation, animation, or runtime-inspection tool
AI/WORKFLOW.md	is never a reason to block a milestone
AI/WORKFLOW.md	not finished because the asset exists in the asset catalogue
AI/prompts/audit-ui-ux.md	custom imagery is not a finding
AI/prompts/audit-product.md	not better because it has more custom visuals
AI/prompts/audit-accessibility.md	decorative artwork announced as content
"

visual_failures=0
while IFS="$(printf '\t')" read -r doc phrase; do
    [ -n "${doc:-}" ] || continue
    [ -n "${phrase:-}" ] || continue
    path="${IOSAI_ROOT}/${doc}"
    [ -f "$path" ] || continue   # already reported as a missing file
    if ! grep -Fq -- "$phrase" "$path"; then
        fail "${doc} does not state the visual craftsmanship rule: ${phrase}"
        hint "a bespoke visual, motion, or haptic moment is considered where it earns its"
        hint "place, native first, judged running — and no tool for it is ever required"
        visual_failures=$((visual_failures + 1))
    fi
done <<EOF
$VISUAL_CRAFT_PHRASES
EOF

[ "$visual_failures" -eq 0 ] \
    && log_ok "bespoke visual and motion work is conditional, native-first, and judged running"

# ---------------------------------------------------------------------------
log_step "No automatic distribution"
# Archiving, exporting, uploading, notarizing, and submitting are the developer's
# steps after READY_FOR_HUMAN (AI/WORKFLOW.md, Release). The release gate's own
# regression case can only observe an archive its stub xcodebuild is asked for, and an
# audit put `xcodebuild archive` back into verify-release.sh with nothing noticing:
# template-check, static, and every self-test case still passed. So the scripts are
# read for the commands themselves, here, on every `make static` and optional
# pre-commit.
#
# Comment lines are skipped, and so is anything after a `#` that follows whitespace,
# because the scripts legitimately explain what they do not do. This file is excluded
# because it necessarily contains the patterns it looks for, and self-test.sh because
# its stub and its regression cases have to name them too.
DISTRIBUTION_COMMAND_RE='(^|[^A-Za-z0-9_-])(-archivePath|-exportArchive|-exportOptionsPlist|-exportPath|altool|notarytool|iTMSTransporter)([^A-Za-z0-9_-]|$)|(xcodebuild|run_xcodebuild)[^#]*[[:space:]]archive([[:space:]]|$)|^[[:space:]]*archive([[:space:]]|$)'
distribution_hits=""
distribution_failures=0
for f in "${IOSAI_ROOT}"/Scripts/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.sh \
         "${IOSAI_ROOT}"/.githooks/* "${IOSAI_ROOT}/Makefile"; do
    [ -f "$f" ] || continue
    case "${f##*/}" in verify-template.sh|self-test.sh) continue ;; esac
    hits_rc=0
    hits="$(awk -v re="$DISTRIBUTION_COMMAND_RE" '
        /^[[:space:]]*#/ { next }
        {
            line = $0
            sub(/[[:space:]]#.*$/, "", line)
            if (line ~ re) printf "%d: %s\n", FNR, $0
        }
    ' "$f")" || hits_rc=$?
    if [ "$hits_rc" -ne 0 ]; then
        fail "could not scan $(relpath "$f") for distribution commands (scanner exited ${hits_rc})"
        distribution_failures=$((distribution_failures + 1))
        continue
    fi
    if [ -n "$hits" ]; then
        distribution_hits="${distribution_hits}$(relpath "$f")
$(printf '%s\n' "$hits" | sed 's/^/  /')
"
    fi
done
if [ -n "$distribution_hits" ]; then
    fail "a script archives, exports, uploads, or notarizes — distribution is the developer's step:"
    printf '%s' "$distribution_hits" | sed 's/^/           /' >&2
    hint "no gate archives, uploads, submits, or publishes; see AI/WORKFLOW.md, Release"
elif [ "$distribution_failures" -eq 0 ]; then
    log_ok "no script archives, exports, uploads, or notarizes"
fi

# ---------------------------------------------------------------------------
log_step "Portability"
# An absolute tool path breaks on a machine that installed things elsewhere.
# This file is excluded because it necessarily contains the patterns it searches for.
hardcoded="$(grep -rn -E --exclude='verify-template.sh' '(/usr/local/bin|/opt/homebrew/bin|/usr/bin/jq)' \
    "${IOSAI_ROOT}/Scripts" "${IOSAI_ROOT}/.githooks" "${IOSAI_ROOT}/Makefile" 2>/dev/null || true)"
if [ -n "$hardcoded" ]; then
    fail "absolute tool paths found — resolve tools with 'command -v' instead:"
    printf '%s\n' "$hardcoded" | sed "s|^${IOSAI_ROOT}/|           |" >&2
else
    log_ok "no absolute tool paths in scripts, hooks, or Makefile"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$FAILURES" -gt 0 ]; then
    log_error "template validation FAILED — ${FAILURES} problem(s)"
    exit "$EX_VERIFY"
fi
log_ok "template validation PASSED"
