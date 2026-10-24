#!/usr/bin/env bash
# verify-milestone.sh — verify clean current HEAD or reproduce an explicit candidate.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/verify-milestone.sh <MILESTONE_ID> [--candidate <FULL_SHA>]

With no candidate, verifies the current clean HEAD directly and records its branch.
With --candidate, materialises the exact historical commit in a detached read-only
worktree for immutable reproduction.

  MILESTONE_ID   e.g. M03 — must match AI/milestones/<ID>-*.md
  --candidate    optional full commit SHA for reproduction/history mode

Normal mode refuses uncommitted or hidden build inputs and an active Git operation.
EOF
}

MILESTONE_ID=""
opt_candidate=""
opt_immutable_evidence_root=""
while [ $# -gt 0 ]; do
    case "$1" in
        --candidate)
            [ $# -gt 1 ] || die "$EX_USAGE" "--candidate requires a value"
            opt_candidate="$2"; shift 2 ;;
        --immutable-evidence-root)
            [ $# -gt 1 ] || die "$EX_USAGE" "internal immutable evidence root requires a value"
            opt_immutable_evidence_root="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        -*) die "$EX_USAGE" "unknown milestone verification argument: $1" ;;
        *)
            [ -z "$MILESTONE_ID" ] || die "$EX_USAGE" "unexpected argument: $1"
            MILESTONE_ID="$1"; shift ;;
    esac
done

[ -n "$MILESTONE_ID" ] || {
    log_error "a milestone ID is required"
    hint "usage: ./Scripts/verify-milestone.sh <MILESTONE_ID> [--candidate <FULL_SHA>]"
    hint "available: $(milestone_ids | tr '\n' ' ')"
    exit "$EX_USAGE"
}
# Explicit candidate outer process: resolve once, then execute the candidate's
# committed gate implementation from the read-only snapshot.
if [ -z "$opt_immutable_evidence_root" ] && [ -n "$opt_candidate" ]; then
    git_has_commits || die "$EX_UNAVAILABLE" "this repository has no commits; there is no milestone candidate"
    opt_candidate="$(resolve_explicit_candidate "$opt_candidate")"
    outer_rc=0
    run_in_immutable_candidate "$opt_candidate" milestone "$IOSAI_ROOT" \
        "Scripts/verify-milestone.sh" \
        "$MILESTONE_ID" --candidate "$opt_candidate" || outer_rc=$?
    exit "$outer_rc"
fi

verification_mode="current-head"
invocation_branch="$(git -C "$IOSAI_ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || printf 'detached')"
if [ -n "$opt_immutable_evidence_root" ]; then
    verification_mode="explicit-candidate"
    case "$opt_immutable_evidence_root" in
        /*) : ;;
        *) die "$EX_USAGE" "immutable evidence root must be absolute" ;;
    esac
    git -C "$opt_immutable_evidence_root" cat-file -e "${opt_candidate}^{commit}" 2>/dev/null \
        || die "$EX_VERIFY" "immutable evidence root does not contain candidate ${opt_candidate}"
    assert_immutable_candidate_root "$opt_candidate"
    IOSAI_ARTIFACTS_DIR="${opt_immutable_evidence_root}/.artifacts"
    IOSAI_EVIDENCE_ROOT="$opt_immutable_evidence_root"
    IOSAI_CACHE_OWNER_PATH="$(physical_path "$opt_immutable_evidence_root")" \
        || die "$EX_VERIFY" "cannot resolve immutable cache owner root"
    invocation_branch="$(git -C "$opt_immutable_evidence_root" symbolic-ref --quiet --short HEAD 2>/dev/null || printf 'detached')"
else
    git_has_commits || die "$EX_UNAVAILABLE" "this repository has no milestone candidate"

    # Milestones are sequential: each one is developed in the primary checkout, on
    # the primary branch, and committed there. A worktree and a branch outside it may
    # isolate parallel localization, an independent read-only review, or a bounded
    # experiment, but never milestone implementation or verification — so being in
    # the wrong place is settled here, before the tree is inspected. On a secondary
    # worktree the tree may be dirty as well,
    # and burying "you are on the wrong branch" under a git status dump would hide
    # the one line that says what to do.
    #
    # `die` inside a command substitution exits only the subshell, so the status is
    # captured and re-raised rather than trusted to propagate: 1 is "no marker",
    # anything else is the marker being unreadable and is never read as absent.
    primary_branch=""
    primary_branch_rc=0
    primary_branch="$(iosai_primary_branch)" || primary_branch_rc=$?
    case "$primary_branch_rc" in
        0)
            if [ "$invocation_branch" = "detached" ]; then
                log_error "milestone verification runs on the primary branch: ${primary_branch}"
                hint "HEAD is detached at $(git -C "$IOSAI_ROOT" rev-parse --short HEAD)"
                hint "check out the primary branch before verifying: git switch ${primary_branch}"
                exit "$EX_VERIFY"
            fi
            if [ "$invocation_branch" != "$primary_branch" ]; then
                log_error "milestone verification runs on the primary branch: ${primary_branch}"
                hint "HEAD is on '${invocation_branch}'"
                hint "every milestone is developed in the primary checkout and committed to"
                hint "${primary_branch}. secondary worktrees may isolate localization,"
                hint "read-only review, or bounded experiments, but milestone work and"
                hint "verification never run in one."
                hint "switch back with: git switch ${primary_branch}"
                exit "$EX_VERIFY"
            fi ;;
        1)
            # An uninitialized template repository records no primary branch, so
            # there is nothing to assert. A gate that invented the name it was
            # supposed to require would be enforcing nothing.
            log_skip "no .iosai-project marker: the primary-branch check does not apply" ;;
        *)  exit "$primary_branch_rc" ;;
    esac

    milestone_checkout_is_clean || exit "$EX_VERIFY"
    opt_candidate="$(git -C "$IOSAI_ROOT" rev-parse HEAD)"
    IOSAI_EVIDENCE_ROOT="$IOSAI_ROOT"
    IOSAI_CACHE_OWNER_PATH="$(physical_path "$IOSAI_ROOT")" \
        || die "$EX_VERIFY" "cannot resolve milestone checkout"
fi

verify_source_unchanged() {
    if [ "$verification_mode" = "explicit-candidate" ]; then
        assert_immutable_candidate_root "$opt_candidate"
    else
        local current
        current="$(git -C "$IOSAI_ROOT" rev-parse HEAD)" \
            || die "$EX_VERIFY" "milestone checkout lost HEAD during verification"
        [ "$current" = "$opt_candidate" ] \
            || die "$EX_VERIFY" "HEAD changed during milestone verification"
        milestone_checkout_is_clean \
            || die "$EX_VERIFY" "checkout changed during milestone verification"
    fi
}

milestone_file="$(milestone_file_for_id "$MILESTONE_ID")"
FAILURES=0
fail() { log_error "$@"; FAILURES=$((FAILURES + 1)); }

# The repository mode is resolved BEFORE the report header is written. The header
# prints `**Mode:** ${IOSAI_REPO_MODE:-unknown}`, so resolving it afterwards made
# every milestone report record `unknown` — and, worse, an inherited exported
# value would have been printed verbatim. load_project_config clears that
# inherited state, so the order is load, resolve, then write.
load_project_config
IOSAI_REPO_MODE="$(resolve_repo_mode)"
export IOSAI_REPO_MODE

log_step "Milestone ${MILESTONE_ID} candidate verification"
log_info "  candidate: ${opt_candidate}"
log_info "  branch:    ${invocation_branch}"
log_info "  mode:      ${verification_mode}"
log_info "  repository: ${IOSAI_REPO_MODE}"
log_info "  contract:  $(relpath "$milestone_file")"

run_dir="$(artifacts_run_dir "milestone/${MILESTONE_ID}")"
report="${run_dir}/report.md"
counts="${run_dir}/counts.txt"

report_header "$report" "Milestone ${MILESTONE_ID} verification"
report_verdict_guard "$report"
report_line "$report" "**Gate:** milestone finalization"
report_line "$report" "**Policy version:** solo-workflow/2"
report_line "$report" "**Milestone:** ${MILESTONE_ID}"
report_line "$report" "**CANDIDATE_COMMIT:** \`${opt_candidate}\`"
# `**Branch:**` is written once, by report_header, from the publishing checkout.
# It used to be written here as well, so every milestone report carried the field
# twice — and a duplicated machine-read field is exactly the ambiguity this
# toolchain rejects everywhere else.
report_line "$report" "**Verification mode:** ${verification_mode}"
report_line "$report" "**Verification started:** $(utc_stamp)"
if [ "$verification_mode" = "explicit-candidate" ]; then
    report_line "$report" "**Candidate source:** detached read-only worktree materialised from the candidate commit"
else
    report_line "$report" "**Candidate source:** clean current HEAD in the active checkout"
fi
report_line "$report" "**Contract:** \`$(relpath "$milestone_file")\`"
report_line "$report" ""

# ---------------------------------------------------------------------------
# 1. Contract and dependency reality.
# ---------------------------------------------------------------------------
log_step "Contract structure"
status="$(milestone_field "$milestone_file" 'Status')"
if ! milestone_validate_file "$milestone_file"; then
    fail "the milestone contract does not satisfy the schema"
fi
if [ "$FAILURES" -gt 0 ]; then
    report_line "$report" "**Verdict:** FAILED (milestone contract)"
    log_error "milestone contract is incomplete"
    hint "start from AI/templates/milestone-template.md; every field there is required."
    exit "$EX_VERIFY"
fi
log_ok "contract is complete (status: ${status})"
if [ "$status" != "REVIEW" ]; then
    report_line "$report" "**Verdict:** FAILED (milestone must be in REVIEW)"
    die "$EX_VERIFY" "milestone ${MILESTONE_ID} must be in REVIEW before verification"
fi

milestone_rows_cache="$(milestone_rows)"
dep_problems=0
while IFS= read -r dep; do
    [ -n "$dep" ] || continue
    # The awk reads every row. Exiting at the match let printf take SIGPIPE, and
    # under `set -e` the 141 from pipefail aborted this gate for a satisfied
    # dependency — measured 7 times in 80,000 lookups on a loaded machine.
    dep_status="$(printf '%s\n' "$milestone_rows_cache" \
        | awk -F'\t' -v d="$dep" '$1 == d && !found {print $2; found = 1}')"
    if [ -z "$dep_status" ]; then
        log_error "depends on '${dep}', which has no milestone file"
        dep_problems=$((dep_problems + 1))
    elif ! milestone_status_is_complete "$dep_status"; then
        log_error "depends on ${dep}, whose status is '${dep_status}'"
        hint "only DONE satisfies a dependency"
        dep_problems=$((dep_problems + 1))
    fi
done <<EOF
$(dep_list "$(milestone_field "$milestone_file" 'Depends on')")
EOF
if [ "$dep_problems" -gt 0 ]; then
    report_line "$report" "**Verdict:** FAILED (milestone dependencies)"
    log_error "milestone ${MILESTONE_ID}: dependencies are not satisfied"
    exit "$EX_VERIFY"
fi
log_ok "dependencies satisfied"

audit_prompt="$(milestone_field "$milestone_file" 'Audit prompt')"
if [ -n "$audit_prompt" ]; then
    audit_record="$(milestone_field "$milestone_file" 'Audit record')"
    audit_domain="$(basename "$audit_prompt" .md)"
    audit_domain="${audit_domain#audit-}"
    # milestone_validate_file above already refused anything else; this keeps the
    # coverage check itself from ever reading a domain that owns no rows, where an
    # empty `## Coverage` section would otherwise be "complete".
    case "$audit_prompt:$audit_domain" in
        AI/prompts/final-polish.md:final-polish) : ;;
        AI/prompts/audit-*:functional|AI/prompts/audit-*:ui-ux|AI/prompts/audit-*:content|\
        AI/prompts/audit-*:accessibility|AI/prompts/audit-*:product|AI/prompts/audit-*:release) : ;;
        *)
            report_line "$report" "**Verdict:** FAILED (unsupported audit prompt)"
            die "$EX_VERIFY" "milestone ${MILESTONE_ID}: unsupported audit prompt: ${audit_prompt}" ;;
    esac
    audit_channel="$(resolve_distribution_channel)"
    coverage_rc=0
    validate_release_coverage_schema || coverage_rc=$?
    if [ "$audit_prompt" = AI/prompts/final-polish.md ]; then
        validate_final_polish_coverage "${IOSAI_ROOT}/${audit_record}" "$MILESTONE_ID" "$audit_channel" || coverage_rc=$?
    else
        validate_domain_audit_coverage "${IOSAI_ROOT}/${audit_record}" "$audit_domain" "$audit_channel" || coverage_rc=$?
    fi
    if [ "$coverage_rc" -ne 0 ]; then
        report_line "$report" "**Verdict:** FAILED (domain audit coverage)"
        log_error "milestone ${MILESTONE_ID}: domain audit coverage is incomplete"
        exit "$EX_VERIFY"
    fi
    report_line "$report" "**Audit coverage:** COMPLETE (${audit_domain}, ${audit_channel})"
    log_ok "domain audit coverage complete (${audit_domain}, ${audit_channel})"
fi

# ---------------------------------------------------------------------------
# 2. Universal static checks and report identity.
# ---------------------------------------------------------------------------
printf '\n'
static_rc=0
if [ "$verification_mode" = "explicit-candidate" ]; then
    "${_script_dir}/verify-static.sh" \
        --immutable-cache-owner "$opt_immutable_evidence_root" \
        --candidate "$opt_candidate" || static_rc=$?
else
    "${_script_dir}/verify-static.sh" || static_rc=$?
fi
if [ "$static_rc" -ne 0 ]; then
    report_line "$report" "**Verdict:** FAILED (static verification)"
    log_error "milestone ${MILESTONE_ID}: static verification failed"
    # See verify-integration.sh: one flat exit 1 for any static failure; the precise
    # code stays available from `make static` itself.
    exit "$EX_FAIL"
fi

# A narrowed milestone suite is a supported, contract-bound decision; a retried or
# repeated one is not. Whether the argument is permitted at all is settled BEFORE
# the contract is asked to declare it, and before anything is built: a gate that
# discovered this after a Debug build would have spent the build to reach the same
# refusal. See assert_test_args_report_failures for what this protects.
split_args "${MILESTONE_TEST_ARGUMENTS:-}"
assert_test_args_report_failures "MILESTONE_TEST_ARGUMENTS" \
    ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}

# The configuration and repository mode were resolved before the report header.
if ! validate_milestone_test_scope_contract "$milestone_file" "${MILESTONE_TEST_ARGUMENTS:-}"; then
    report_line "$report" "**Verdict:** FAILED (milestone test-scope contract)"
    log_error "milestone ${MILESTONE_ID}: test-scope contract does not match configuration"
    exit "$EX_VERIFY"
fi

report_line "$report" "**Declared status:** ${status}"
report_line "$report" ""

# ---------------------------------------------------------------------------
# 3. Build and test.
# ---------------------------------------------------------------------------
if [ "$IOSAI_REPO_MODE" = "template" ]; then
    printf '\n'
    log_step "Build and tests"
    log_info "  Repository mode is 'template': no application target exists."
    if [ "$MILESTONE_ID" = "M00" ]; then
        report_line "$report" "## Result"
        report_line "$report" ""
        report_line "$report" "**Verdict:** NOT VERIFIED (M00 is incomplete in template mode)"
        log_error "milestone M00 cannot be verified in template mode"
        log_info "report: $(relpath "$report")"
        exit "$EX_UNAVAILABLE"
    fi

    verify_source_unchanged

    # A template-mode pass covers the repository, not an application. Saying so in
    # the report is the whole point: a bare "PASSED milestone verification" reads
    # as though an iOS app had been built and tested, and nothing here did either.
    report_line "$report" "## Scope of this verification"
    report_line "$report" ""
    report_line "$report" "This repository is in template mode: it has no application target."
    report_line "$report" ""
    report_line "$report" "| Check | Result |"
    report_line "$report" "| --- | --- |"
    report_line "$report" "| Milestone contract schema | passed |"
    report_line "$report" "| Milestone dependencies | passed |"
    report_line "$report" "| Static and template verification | passed |"
    report_line "$report" "| Application build | NOT RUN — no application target |"
    report_line "$report" "| Application tests | NOT RUN — no application target |"
    report_line "$report" ""
    report_line "$report" "No application was built and no application test executed, so this"
    report_line "$report" "report establishes nothing about product behavior. It covers only the"
    report_line "$report" "template-scope checks listed above."
    report_line "$report" ""
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**VERIFIED_COMMIT:** \`${opt_candidate}\`"
    report_line "$report" "**Verdict:** PASSED milestone verification (template scope: no application build or tests)"
    report_line "$report" "**Verification completed:** $(utc_stamp)"
    log_info "report: $(relpath "$report")"
    log_ok "PASSED milestone verification for ${opt_candidate}"
    log_info "  template scope only: no application was built and no application test ran"
    printf 'VERIFIED_COMMIT=%s\n' "$opt_candidate"
    exit 0
fi

require_project_configured
require_tools xcodebuild xcrun jq

derived="$(derived_data_path)"
result_bundle="${run_dir}/milestone.xcresult"
xcb_container_args
simulator_gate_begin "$report"
ensure_derived_data_root "$derived"

printf '\n'
if ! run_xcodebuild build "$run_dir" -- \
    build \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_DEBUG:-Debug}" \
    -destination "$BUILD_DESTINATION" \
    -derivedDataPath "$derived"
then
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**Verdict:** FAILED (Debug build)"
    log_error "milestone ${MILESTONE_ID} FAILED: Debug build"
    log_info "report: $(relpath "$report")"
    exit "$EX_FAIL"
fi

validate_watch_build "${CONFIGURATION_DEBUG:-Debug}" "$BUILD_DESTINATION" "$derived" "$report" \
    || exit "$EX_FAIL"

split_args "${MILESTONE_TEST_ARGUMENTS:-}"
if [ "${#SPLIT_ARGS[@]}" -eq 0 ]; then
    log_info "test scope: every test in scheme '${SCHEME}' (the default)"
    scope="(every test in the scheme)"
else
    log_warn "test scope is narrowed by MILESTONE_TEST_ARGUMENTS: ${MILESTONE_TEST_ARGUMENTS}"
    scope="${MILESTONE_TEST_ARGUMENTS}"
fi

test_rc=0
run_xcodebuild test "$run_dir" -- \
    test \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_DEBUG:-Debug}" \
    -destination "$TEST_DESTINATION" \
    -derivedDataPath "$derived" \
    -resultBundlePath "$result_bundle" \
    ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"} || test_rc=$?

counts_line=""
if [ -d "$result_bundle" ]; then
    counts_line="$(assert_result_bundle "$result_bundle" "milestone tests" "$counts" reject-skipped | tail -n1)" || exit $?
elif [ "$test_rc" -ne 0 ]; then
    log_error "tests failed before a result bundle was written"
else
    die "$EX_SOFTWARE" "no result bundle at ${result_bundle}; cannot claim tests passed"
fi

report_line "$report" "## Verification record"
report_line "$report" ""
report_line "$report" "| Check | Result |"
report_line "$report" "| --- | --- |"
report_line "$report" "| Static verification | passed |"
report_line "$report" "| Debug build | passed |"
report_line "$report" "| Milestone tests | ${counts_line:-see test.log} |"
report_line "$report" ""
report_line "$report" "**Test scope:** ${scope}"
scope_rationale="$(milestone_field "$milestone_file" 'Test scope rationale')"
if [ -n "$scope_rationale" ]; then
    report_line "$report" "**Test scope rationale:** ${scope_rationale}"
fi
report_line "$report" ""
report_line "$report" "## Exact commands"
report_line "$report" ""
report_line "$report" '```sh'
for c in "${run_dir}"/*.command; do
    [ -f "$c" ] || continue
    report_line "$report" "$(cat "$c")"
done
report_line "$report" '```'

if [ "$test_rc" -ne 0 ]; then
    report_line "$report" ""
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**Verdict:** FAILED (milestone tests)"
    log_error "milestone ${MILESTONE_ID} FAILED"
    log_info "report: $(relpath "$report")"
    exit "$EX_FAIL"
fi

if [ -n "${COMPANION_PROFILE:-}" ]; then
    simulator_release
    verify_companion_profile milestone "$run_dir" "$report" || exit "$EX_FAIL"
fi

verify_source_unchanged
report_line "$report" ""
report_line "$report" "## Result"
report_line "$report" ""
report_line "$report" "**VERIFIED_COMMIT:** \`${opt_candidate}\`"
report_line "$report" "**Verdict:** PASSED milestone verification"
report_line "$report" "**Verification completed:** $(utc_stamp)"

printf '\n'
log_info "report: $(relpath "$report")"
log_ok "PASSED milestone verification for ${opt_candidate}"
printf 'VERIFIED_COMMIT=%s\n' "$opt_candidate"
