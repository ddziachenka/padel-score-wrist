#!/usr/bin/env bash
# verify-fast.sh — the development loop: Debug build plus the fast test subset.
#
# This is the only gate that is allowed to be narrow. It exists for feedback
# speed and proves nothing about release readiness. A milestone is not complete
# because this passed.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

log_step "Fast verification"

load_project_config --required
IOSAI_REPO_MODE="$(resolve_repo_mode)"
export IOSAI_REPO_MODE

if [ "$IOSAI_REPO_MODE" = "template" ]; then
    log_error "this is the universal template repository: there is no application to build"
    hint "TEMPLATE_REPOSITORY=\"true\" in Config/project.env."
    hint "for repository-level checks run: make static"
    hint "to turn this into a product repository, add an Xcode project and run"
    hint "  ./Scripts/configure-project.sh --project App/YourApp.xcodeproj --scheme YourApp"
    exit "$EX_UNAVAILABLE"
fi

require_project_configured
require_tools xcodebuild xcrun jq

# This development-only loop intentionally operates on the mutable working tree.
# It makes no commit-level claim and performs no Git-state preflight.

run_dir="$(artifacts_run_dir fast)"
report="${run_dir}/report.md"
counts="${run_dir}/counts.txt"
derived="$(derived_data_path)"
result_bundle="${run_dir}/fast.xcresult"

report_header "$report" "Fast verification"
report_verdict_guard "$report"
report_line "$report" "**Gate:** fast (development loop — not a completeness gate)"
report_line "$report" "**DerivedData:** \`${derived}\`"
report_line "$report" ""

xcb_container_args
simulator_gate_begin "$report"
ensure_derived_data_root "$derived"

# --- build ------------------------------------------------------------------
if ! run_xcodebuild build "$run_dir" -- \
    build \
    -quiet \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_DEBUG:-Debug}" \
    -destination "$BUILD_DESTINATION" \
    -derivedDataPath "$derived"
then
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**Verdict:** FAILED (Debug build)"
    report_line "$report" ""
    report_line "$report" "See \`build.log\` in this directory."
    log_error "fast verification FAILED: Debug build"
    log_info "report: $(relpath "$report")"
    exit "$EX_FAIL"
fi

validate_watch_build "${CONFIGURATION_DEBUG:-Debug}" "$BUILD_DESTINATION" "$derived" "$report" \
    || exit "$EX_FAIL"

# --- test -------------------------------------------------------------------
split_args "${FAST_TEST_ARGUMENTS:-}"
if [ "${#SPLIT_ARGS[@]}" -eq 0 ]; then
    log_info "FAST_TEST_ARGUMENTS is empty — running every test in the scheme."
    log_info "Set it in Config/project.env to narrow this loop, e.g."
    log_info "  FAST_TEST_ARGUMENTS=\"-only-testing:YourAppTests\""
fi

test_rc=0
run_xcodebuild test "$run_dir" -- \
    test \
    -quiet \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_DEBUG:-Debug}" \
    -destination "$TEST_DESTINATION" \
    -derivedDataPath "$derived" \
    -resultBundlePath "$result_bundle" \
    ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"} || test_rc=$?

# Counts come from the result bundle, never from the log. A run that executed
# zero tests fails here even if xcodebuild exited 0.
counts_line=""
if [ -d "$result_bundle" ]; then
    counts_line="$(assert_result_bundle "$result_bundle" "fast tests" "$counts" | tail -n1)" || exit $?
elif [ "$test_rc" -ne 0 ]; then
    log_error "tests failed before a result bundle was written"
else
    die "$EX_SOFTWARE" "no result bundle at ${result_bundle}; cannot claim tests passed"
fi

report_line "$report" "## Result"
report_line "$report" ""
if [ "$test_rc" -eq 0 ]; then
    report_line "$report" "**Verdict:** PASSED"
else
    report_line "$report" "**Verdict:** FAILED (tests)"
fi
report_line "$report" ""
report_line "$report" "| Step | Result |"
report_line "$report" "| --- | --- |"
report_line "$report" "| Debug build | passed |"
report_line "$report" "| Fast tests | ${counts_line:-see test.log} |"
report_line "$report" ""
report_line "$report" "**Test scope:** \`${FAST_TEST_ARGUMENTS:-(every test in the scheme)}\`"
report_line "$report" ""
report_line "$report" "## Scope guard"
report_line "$report" ""
report_line "$report" "This gate is narrow by design. It does not run static checks, does not"
report_line "$report" "build Release, and does not establish milestone or release readiness."
report_line "$report" "Use an explicit milestone or integration candidate gate for that."

printf '\n'
log_info "report: $(relpath "$report")"
if [ "$test_rc" -ne 0 ]; then
    log_error "fast verification FAILED"
    exit "$EX_FAIL"
fi
log_ok "fast verification PASSED"
