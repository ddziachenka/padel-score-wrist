#!/usr/bin/env bash
# verify-integration.sh — verify an explicit immutable integration candidate.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/verify-integration.sh --candidate <FULL_SHA>

Materialises the exact commit in a detached read-only worktree and runs the
integration boundary: static verification, a Debug build, and the complete
shared-scheme test suite including UI tests. In template mode it runs static
verification and the template's complete self-test instead of Xcode.

A pass verifies only this exact combined SHA. Run it when the finished localization
branches are combined, which is the one place this workflow produces separate
streams. The command never pushes.
EOF
}

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
        *) die "$EX_USAGE" "unknown integration verification argument: $1" ;;
    esac
done
[ -n "$opt_candidate" ] || die "$EX_USAGE" "--candidate requires a full commit SHA"

if [ -z "$opt_immutable_evidence_root" ]; then
    git_has_commits || die "$EX_UNAVAILABLE" "this repository has no commits; there is no integration candidate"
    opt_candidate="$(resolve_explicit_candidate "$opt_candidate")"
    outer_rc=0
    run_in_immutable_candidate "$opt_candidate" integration "$IOSAI_ROOT" \
        "Scripts/verify-integration.sh" --candidate "$opt_candidate" || outer_rc=$?
    exit "$outer_rc"
fi

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

log_step "Integration candidate verification"
log_info "  candidate: ${opt_candidate}"

load_project_config
IOSAI_REPO_MODE="$(resolve_repo_mode)"

run_dir="$(artifacts_run_dir integration)"
report="${run_dir}/report.md"
counts="${run_dir}/counts.txt"

report_header "$report" "Integration verification"
report_verdict_guard "$report"
report_line "$report" "**Gate:** integration"
report_line "$report" "**Policy version:** solo-workflow/2"
report_line "$report" "**CANDIDATE_COMMIT:** \`${opt_candidate}\`"
report_line "$report" "**Candidate source:** detached read-only worktree materialised from the candidate commit"
report_line "$report" ""

printf '\n'
static_rc=0
"${_script_dir}/verify-static.sh" \
        --immutable-cache-owner "$opt_immutable_evidence_root" \
        --candidate "$opt_candidate" || static_rc=$?
if [ "$static_rc" -ne 0 ]; then
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**Verdict:** FAILED (static verification)"
    log_error "integration verification FAILED: static verification"
    log_info "report: $(relpath "$report")"
    # Every static failure is reported as exit 1 here, which AI/WORKFLOW.md documents
    # as "automated build/test/static failure". Static verification itself keeps the
    # precise code (64 unsafe configuration, 65 assertion, 66 missing input) — run
    # `make static` directly when the distinction matters. Propagating only some of
    # those codes through this gate would make the boundary's exit surface depend on
    # which check failed, which is harder to rely on than one flat answer.
    exit "$EX_FAIL"
fi

if [ "$IOSAI_REPO_MODE" = "template" ]; then
    printf '\n'
    log_info "Template mode: the complete self-test stands in for the application"
    log_info "suite. It builds and removes its own fixtures and takes several"
    log_info "minutes; that is this gate working, not a hang."
    if ! "${_script_dir}/self-test.sh"; then
        report_line "$report" "## Result"
        report_line "$report" ""
        report_line "$report" "**Verdict:** FAILED (template self-test)"
        log_error "integration verification FAILED: template self-test"
        log_info "report: $(relpath "$report")"
        exit "$EX_FAIL"
    fi

    assert_immutable_candidate_root "$opt_candidate"
    report_line "$report" "## Checks performed"
    report_line "$report" ""
    report_line "$report" "| Check | Result |"
    report_line "$report" "| --- | --- |"
    report_line "$report" "| Candidate source immutable | passed |"
    report_line "$report" "| Static verification | passed |"
    report_line "$report" "| Template self-test | passed |"
    report_line "$report" "| Debug build | not applicable — no application target |"
    report_line "$report" "| Complete test suite | not applicable — no application target |"
    report_line "$report" ""
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**VERIFIED_COMMIT:** \`${opt_candidate}\`"
    report_line "$report" "**Verdict:** PASSED integration verification"

    log_info "report: $(relpath "$report")"
    log_ok "PASSED integration verification for ${opt_candidate}"
    printf 'VERIFIED_COMMIT=%s\n' "$opt_candidate"
    exit 0
fi

require_project_configured
require_tools xcodebuild xcrun jq

split_args "${RELEASE_TEST_ARGUMENTS:-}"
assert_test_args_allowed "RELEASE_TEST_ARGUMENTS" ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}

derived="$(derived_data_path)"
result_bundle="${run_dir}/integration.xcresult"
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
    log_error "integration verification FAILED: Debug build"
    log_info "report: $(relpath "$report")"
    exit "$EX_FAIL"
fi

log_info ""
validate_watch_build "${CONFIGURATION_DEBUG:-Debug}" "$BUILD_DESTINATION" "$derived" "$report" \
    || exit "$EX_FAIL"

log_info "Running the complete test suite in scheme '${SCHEME}', UI tests included."

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
bundle_rc=0
if [ -d "$result_bundle" ]; then
    counts_line="$(assert_result_bundle "$result_bundle" "complete suite" "$counts" reject-skipped | tail -n1)" || bundle_rc=$?
elif [ "$test_rc" -eq 0 ]; then
    log_error "no result bundle at ${result_bundle}"
    bundle_rc="$EX_SOFTWARE"
fi

if [ "$test_rc" -ne 0 ] || [ "$bundle_rc" -ne 0 ]; then
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**Verdict:** FAILED (complete test suite)"
    report_line "$report" ""
    report_line "$report" "${counts_line:-see test.log}"
    log_error "integration verification FAILED: complete test suite"
    log_info "report: $(relpath "$report")"
    [ "$bundle_rc" -eq "$EX_SOFTWARE" ] && exit "$EX_SOFTWARE"
    exit "$EX_FAIL"
fi

if [ -n "${COMPANION_PROFILE:-}" ]; then
    simulator_release
    verify_companion_profile integration "$run_dir" "$report" || exit "$EX_FAIL"
fi

assert_immutable_candidate_root "$opt_candidate"

report_line "$report" "## Checks performed"
report_line "$report" ""
report_line "$report" "| Check | Result |"
report_line "$report" "| --- | --- |"
report_line "$report" "| Candidate source immutable | passed |"
report_line "$report" "| Static verification | passed |"
report_line "$report" "| Debug build | passed |"
report_line "$report" "| Complete test suite | ${counts_line:-see test.log} |"
report_line "$report" ""
report_line "$report" "**Test scope:** every test in scheme \`${SCHEME}\`, including UI tests."
report_line "$report" ""
report_line "$report" "## Exact commands"
report_line "$report" ""
report_line "$report" '```sh'
for c in "${run_dir}"/*.command; do
    [ -f "$c" ] || continue
    report_line "$report" "$(cat "$c")"
done
report_line "$report" '```'
report_line "$report" ""
report_line "$report" "## Result"
report_line "$report" ""
report_line "$report" "**VERIFIED_COMMIT:** \`${opt_candidate}\`"
report_line "$report" "**Verdict:** PASSED integration verification"
report_line "$report" ""
report_line "$report" "This exact combined SHA passed integration verification. The command did"
report_line "$report" "not push, publish, or contact a remote."

printf '\n'
log_info "report: $(relpath "$report")"
log_ok "PASSED integration verification for ${opt_candidate}"
printf 'VERIFIED_COMMIT=%s\n' "$opt_candidate"
