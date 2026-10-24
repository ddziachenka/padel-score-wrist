#!/usr/bin/env bash
# verify-release.sh — strict verification of a fully audited release candidate.
#
#   exit 0   VERDICT=READY_FOR_HUMAN
#   exit 65  VERDICT=NOT_READY
#   exit 1   VERDICT=VERIFICATION_FAILED
#   exit 69  VERDICT=NOT_APPLICABLE_TEMPLATE_MODE
#
# The gate verifies; it never uploads, submits, pushes, or approves publication.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/verify-release.sh --candidate <FULL_SHA> [options]

Verdicts:
  READY_FOR_HUMAN       exit 0; workflow coverage, builds, tests, and release
                               configuration passed for this exact candidate
  NOT_READY                    exit 65; the candidate is invalid or the required
                               audit workflow is incomplete
  VERIFICATION_FAILED          exit 1; build, test, configuration, or policy failed
  NOT_APPLICABLE_TEMPLATE_MODE exit 69; no product exists

  --candidate SHA            exact commit to verify and bind release evidence to
  --print-candidate          resolve and print release identity, then exit
  -h, --help                 this message

The gate runs only from Final Product Polish or Release Readiness Revalidation
after every required domain audit is complete. It does not archive, upload, submit,
push, publish, or decide whether the candidate is distributed.
EOF
}

opt_print_candidate="no"
opt_candidate=""
opt_immutable_evidence_root=""
while [ $# -gt 0 ]; do
    case "$1" in
        --candidate)
            [ $# -gt 1 ] || die "$EX_USAGE" "--candidate requires a value"
            opt_candidate="$2"; shift 2 ;;
        --print-candidate) opt_print_candidate="yes"; shift ;;
        --require-manual-evidence)
            die "$EX_USAGE" "--require-manual-evidence was removed; release always requires complete workflow readiness" ;;
        --immutable-evidence-root)
            [ $# -gt 1 ] || die "$EX_USAGE" "internal immutable evidence root requires a value"
            opt_immutable_evidence_root="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "unknown argument: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
    esac
done
[ -n "$opt_candidate" ] || die "$EX_USAGE" "--candidate requires a full commit SHA"

# Outer process: resolve the explicit candidate, then execute its committed gate
# from a read-only detached worktree. Mutable checkout state is not an input.
if [ -z "$opt_immutable_evidence_root" ]; then
    git_has_commits || die "$EX_UNAVAILABLE" "this repository has no commits; there is nothing to release"
    resolved_candidate=""
    if ! resolved_candidate="$(resolve_explicit_candidate "$opt_candidate")"; then
        printf 'VERDICT=NOT_READY\n'
        exit "$EX_VERIFY"
    fi
    opt_candidate="$resolved_candidate"
    outer_args=()
    if [ "$opt_print_candidate" = "yes" ]; then
        outer_args[${#outer_args[@]}]="--print-candidate"
    fi
    outer_rc=0
    run_in_immutable_candidate "$opt_candidate" release "$IOSAI_ROOT" \
        "Scripts/verify-release.sh" --candidate "$opt_candidate" \
        ${outer_args[@]+"${outer_args[@]}"} || outer_rc=$?
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

VERDICT=""

# ---------------------------------------------------------------------------
# One exit path.
#
# Every failure has to arrive as a verdict and an exit code that agree with the
# contract at the top of this file. The trap below catches every remaining path
# that exits without saying what happened and maps it to
# VERIFICATION_FAILED / 1.
# ---------------------------------------------------------------------------
VERDICT_EMITTED="no"
RELEASE_REPORT=""

emit_verdict() {
    VERDICT_EMITTED="yes"
    printf 'VERDICT=%s\n' "$1"
}

release_exit_trap() {
    local status=$?
    trap - EXIT
    simulator_release
    [ "$VERDICT_EMITTED" = "yes" ] && exit "$status"

    if [ -n "$RELEASE_REPORT" ] && [ -f "$RELEASE_REPORT" ]; then
        report_line "$RELEASE_REPORT" "## Result"
        report_line "$RELEASE_REPORT" ""
        report_line "$RELEASE_REPORT" "**VERDICT:** VERIFICATION_FAILED"
        report_line "$RELEASE_REPORT" "**Raw exit code:** ${status}"
        report_line "$RELEASE_REPORT" ""
        report_line "$RELEASE_REPORT" "A check exited without reporting a verdict; see the console output above."
        log_info "report: $(relpath "$RELEASE_REPORT")"
    fi

    if [ "$status" -eq 0 ]; then
        log_error "internal inconsistency: this gate exited 0 without stating a verdict"
        emit_verdict VERIFICATION_FAILED
        exit "$EX_SOFTWARE"
    fi

    log_error "automated verification failed (raw exit ${status})"
    emit_verdict VERIFICATION_FAILED
    exit "$EX_FAIL"
}
trap release_exit_trap EXIT

log_step "Release verification"

load_project_config --required
IOSAI_REPO_MODE="$(resolve_repo_mode)"

if [ "$IOSAI_REPO_MODE" = "template" ]; then
    log_error "this is the universal template repository; it has no release"
    hint "TEMPLATE_REPOSITORY=\"true\" in Config/project.env."
    hint "release verification applies to a product repository with an app target."
    hint "for repository-level checks run: make static"
    emit_verdict NOT_APPLICABLE_TEMPLATE_MODE
    exit "$EX_UNAVAILABLE"
fi

require_project_configured
require_tools xcodebuild xcrun jq git

distribution_channel="$(resolve_distribution_channel)"

# The evidence directory and report are created before policy preflight so every
# failure after candidate materialisation leaves a report for the auditor.
run_dir="$(artifacts_run_dir release)"
report="${run_dir}/report.md"
counts="${run_dir}/counts.txt"
derived="$(derived_data_path)"
result_bundle="${run_dir}/release.xcresult"

report_header "$report" "Release verification"
report_line "$report" "**Gate:** release (strictest local verification)"
report_line "$report" "**Policy version:** solo-workflow/2"
report_line "$report" "**CANDIDATE_COMMIT:** \`${opt_candidate}\`"
report_line "$report" "**Candidate source:** read-only detached worktree materialised from the candidate commit"
report_line "$report" "**Distribution:** ${distribution_channel}"
RELEASE_REPORT="$report"

# ===========================================================================
# PHASE 0 — preflight. Cheap, and fails fast on a policy that can never pass.
# ===========================================================================
log_step "Phase 0: preflight"
log_ok "distribution channel: ${distribution_channel}"

if ! validate_release_coverage_schema; then
    log_error "canonical release coverage is invalid"
    emit_verdict VERIFICATION_FAILED
    exit "$EX_FAIL"
fi
log_ok "coverage schema: ${IOSAI_RELEASE_COVERAGE_SCHEMA}"

# --- immutable candidate state ---------------------------------------------
assert_immutable_candidate_root "$opt_candidate"
head_sha="$opt_candidate"
# An explicit width, not `--short`. core.abbrev defaults to "auto", so the
# abbreviation grows with the object count — 7 in a young repository, 8 or more
# later. A stable candidate ID must not change as repository history grows.
head_short="$(printf '%s' "$head_sha" | cut -c1-12)"
log_ok "candidate commit ${head_sha}"

# --- candidate identity -----------------------------------------------------
# Version and build must resolve uniquely for the application target. An
# ambiguous or missing value is never guessed at.
log_step "Resolving release candidate identity"
marketing_version="$(app_target_build_setting MARKETING_VERSION)" || {
    emit_verdict VERIFICATION_FAILED
    exit "$EX_FAIL"
}
current_project_version="$(app_target_build_setting CURRENT_PROJECT_VERSION)" || {
    emit_verdict VERIFICATION_FAILED
    exit "$EX_FAIL"
}

candidate_id="${marketing_version} (${current_project_version}) ${head_short}"

log_ok "candidate: ${candidate_id}"

if [ "$opt_print_candidate" = "yes" ]; then
    # A query, not a verdict-bearing run: exempt it from the trap explicitly.
    VERDICT_EMITTED="yes"
    printf 'MARKETING_VERSION=%s\n' "$marketing_version"
    printf 'CURRENT_PROJECT_VERSION=%s\n' "$current_project_version"
    printf 'CANDIDATE_COMMIT=%s\n' "$head_sha"
    printf 'CANDIDATE=%s\n' "$candidate_id"
    exit 0
fi

if ! validate_release_workflow_readiness "$distribution_channel"; then
    report_line "$report" "**Candidate:** ${candidate_id}"
    report_line "$report" ""
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**VERDICT:** NOT_READY"
    report_line "$report" "**Failed step:** release workflow readiness"
    log_error "NOT READY — final audit coverage or readiness state is incomplete"
    log_info "report: $(relpath "$report")"
    emit_verdict NOT_READY
    exit "$EX_VERIFY"
fi
log_ok "final audit coverage complete"

# --- bundle identifier consistency -----------------------------------------
if [ -n "${BUNDLE_IDENTIFIER:-}" ]; then
    actual_bundle_id="$(app_target_build_setting PRODUCT_BUNDLE_IDENTIFIER)" || {
        emit_verdict VERIFICATION_FAILED
        exit "$EX_FAIL"
    }
    if [ "$actual_bundle_id" != "$BUNDLE_IDENTIFIER" ]; then
        log_error "bundle identifier mismatch"
        hint "Config/project.env: ${BUNDLE_IDENTIFIER}"
        hint "Release build:      ${actual_bundle_id}"
        hint "the App Store record and the build must agree before shipping"
        emit_verdict VERIFICATION_FAILED
        exit "$EX_FAIL"
    fi
    log_ok "bundle identifier ${actual_bundle_id}"
fi

report_line "$report" "**Candidate:** ${candidate_id}"
report_line "$report" "**MARKETING_VERSION:** ${marketing_version}"
report_line "$report" "**CURRENT_PROJECT_VERSION:** ${current_project_version}"
report_line "$report" "**Audit coverage:** COMPLETE"
report_line "$report" ""

# ===========================================================================
# PHASE 1 — automated verification. Any failure here is exit 1.
# ===========================================================================
printf '\n'
log_step "Phase 1: automated verification"

fail_automated() {
    report_line "$report" "## Result"
    report_line "$report" ""
    report_line "$report" "**VERDICT:** VERIFICATION_FAILED"
    report_line "$report" "**Failed step:** $1"
    report_line "$report" ""
    report_line "$report" "Logs for every step are in this directory."
    printf '\n'
    log_error "FAILED — automated verification: $1"
    log_info "report: $(relpath "$report")"
    emit_verdict VERIFICATION_FAILED
    exit "$EX_FAIL"
}

# --- static -----------------------------------------------------------------
if ! "${_script_dir}/verify-static.sh" \
        --immutable-cache-owner "$opt_immutable_evidence_root" \
        --candidate "$opt_candidate"; then
    fail_automated "static verification"
fi

# --- release configuration checks -------------------------------------------
printf '\n'
log_step "Release configuration"
config_problems=0

# The shipped-source file list both endpoint scans below work from. Enumerated
# once, with its status checked: piping a failed `find` into a loop and ending in
# `|| true` reported "no cleartext endpoints" from a scan that never ran.
shipped_sources=""
endpoint_scan_incomplete="no"
if [ ! -d "${IOSAI_ROOT}/App" ]; then
    log_error "App/ does not exist in the candidate; shipped sources cannot be scanned"
    config_problems=$((config_problems + 1))
    endpoint_scan_incomplete="yes"
elif ! shipped_sources="$(find "${IOSAI_ROOT}/App" -type f \( -name '*.swift' \
        -o -name '*.plist' -o -name '*.json' -o -name '*.xcconfig' \) 2>&1)"; then
    log_error "could not scan shipped sources for network endpoints:"
    printf '%s\n' "$shipped_sources" | sed 's/^/           /' >&2
    hint "the scan is inconclusive, so release verification fails rather than passing"
    shipped_sources=""
    config_problems=$((config_problems + 1))
    endpoint_scan_incomplete="yes"
fi

# Insecure transport. Namespace and localhost URLs are excluded — they are not
# network endpoints.
insecure=""
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ ! -r "$f" ]; then
        log_error "could not scan $(relpath "$f") for cleartext endpoints: not readable"
        config_problems=$((config_problems + 1))
        endpoint_scan_incomplete="yes"
        continue
    fi
    grep_rc=0
    endpoints="$(grep -oE 'http://[A-Za-z0-9._:/-]+' "$f" 2>/dev/null)" || grep_rc=$?
    if [ "$grep_rc" -gt 1 ]; then
        log_error "could not scan $(relpath "$f") for cleartext endpoints (scanner exited ${grep_rc})"
        config_problems=$((config_problems + 1))
        endpoint_scan_incomplete="yes"
        continue
    fi
    [ -n "$endpoints" ] || continue

    # Consume the complete extraction, without a grep -q consumer that can cause
    # upstream SIGPIPE. Exit 1 means no remaining endpoints; other failures are
    # inconclusive and must never be reported as a clean scan.
    grep_rc=0
    endpoints="$(printf '%s\n' "$endpoints" \
        | grep -vE 'http://(localhost|127\.0\.0\.1|\[::1\]|(www\.)?(apple\.com/DTDs|w3\.org|schemas\.|purl\.org))')" || grep_rc=$?
    if [ "$grep_rc" -gt 1 ]; then
        log_error "could not filter cleartext endpoints in $(relpath "$f") (scanner exited ${grep_rc})"
        config_problems=$((config_problems + 1))
        endpoint_scan_incomplete="yes"
        continue
    fi
    if [ -n "$endpoints" ]; then
        insecure="${insecure}${f}
"
    fi
done <<EOF
$shipped_sources
EOF
if [ -n "$insecure" ]; then
    log_error "cleartext http:// endpoint(s) in shipped sources:"
    printf '%s\n' "$insecure" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    hint "App Transport Security blocks these; use https://"
    config_problems=$((config_problems + 1))
elif [ "$endpoint_scan_incomplete" = "yes" ]; then
    log_error "cleartext endpoint scan incomplete — no clean result is claimed"
else
    log_ok "no cleartext http:// endpoints"
fi

# Debug or staging hosts left wired up. Same enumerated list, same fail-closed
# treatment of an unreadable input.
debug_hosts=""
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ ! -r "$f" ]; then
        log_error "could not scan $(relpath "$f") for debug endpoints: not readable"
        config_problems=$((config_problems + 1))
        endpoint_scan_incomplete="yes"
        continue
    fi
    grep_rc=0
    grep -Eq 'ngrok\.io|\.ngrok-free\.|staging\.[A-Za-z0-9.-]+|DEBUG_ENDPOINT|\.local:[0-9]+' \
        "$f" 2>/dev/null || grep_rc=$?
    if [ "$grep_rc" -gt 1 ]; then
        log_error "could not scan $(relpath "$f") for debug endpoints (scanner exited ${grep_rc})"
        config_problems=$((config_problems + 1))
        endpoint_scan_incomplete="yes"
        continue
    fi
    if [ "$grep_rc" -eq 0 ]; then
        debug_hosts="${debug_hosts}${f}
"
    fi
done <<EOF
$shipped_sources
EOF
if [ -n "$debug_hosts" ]; then
    log_error "possible debug or staging endpoint in shipped sources:"
    printf '%s\n' "$debug_hosts" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    hint "a release build must point only at production"
    config_problems=$((config_problems + 1))
elif [ "$endpoint_scan_incomplete" = "yes" ]; then
    log_error "debug endpoint scan incomplete — no clean result is claimed"
else
    log_ok "no debug or staging endpoints"
fi

# NOTHING ABOUT THE PUBLISHED SITE IS CHECKED HERE, DELIBERATELY.
#
# Two checks were tried in this spot and both were wrong. Scanning Web/ for
# placeholder copy failed every candidate whose site was still the shipped
# scaffold, including a product that hosts its policy on a company domain and
# never publishes Web/ at all. Requiring SUPPORT_SITE_URL to be set punished the
# same product for the same reason.
#
# Both were also duplicates. The final content and release audits own REL-503,
# REL-1004, REL-506, REL-1008, and REL-801 in the maintained coverage inventory.
# Their committed records are validated before this gate starts expensive work.
#
# Deciding whether a URL resolves needs the network, and deciding whether a policy
# describes this app needs a reader. verify-site.sh checks offline what is knowable
# offline, and runs on every `make static` rather than only here.

[ "$config_problems" -eq 0 ] || fail_automated "release configuration checks"

# --- clean Debug build ------------------------------------------------------
xcb_container_args
simulator_gate_begin "$report"
ensure_derived_data_root "$derived"
printf '\n'

run_xcodebuild clean-debug "$run_dir" -- \
    clean build \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_DEBUG:-Debug}" \
    -destination "$BUILD_DESTINATION" \
    -derivedDataPath "$derived" \
    || fail_automated "clean ${CONFIGURATION_DEBUG:-Debug} build"

validate_watch_build "${CONFIGURATION_DEBUG:-Debug}" "$BUILD_DESTINATION" "$derived" "$report" \
    || fail_automated "Watch-only Debug packaging"

# --- clean Release build, for the device SDK --------------------------------
# The shipping configuration is built for the platform it ships on. This step used
# to reuse BUILD_DESTINATION, which is a simulator, so a Release build could pass
# while code that exists only for devices — a path behind
# `#if !targetEnvironment(simulator)`, a device-only binary framework, a device
# architecture link error — had never been compiled, and the first build to meet it
# was the developer's Product > Archive after READY_FOR_HUMAN. Code signing is
# disabled because it belongs to that manual Archive and the developer's own
# identity; everything else about the shipping build is exercised here.
run_xcodebuild clean-release "$run_dir" -- \
    clean build \
    ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
    -scheme "$SCHEME" \
    -configuration "${CONFIGURATION_RELEASE:-Release}" \
    -destination "$(platform_device_destination)" \
    -derivedDataPath "$derived" \
    CODE_SIGNING_ALLOWED=NO \
    || fail_automated "clean ${CONFIGURATION_RELEASE:-Release} device build"

validate_watch_build "${CONFIGURATION_RELEASE:-Release}" "$(platform_device_destination)" "$derived" "$report" \
    || fail_automated "Watch-only Release packaging"

# --- complete test suite ----------------------------------------------------
split_args "${RELEASE_TEST_ARGUMENTS:-}"
assert_test_args_allowed "RELEASE_TEST_ARGUMENTS" ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}

log_info ""
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
if [ -d "$result_bundle" ]; then
    counts_line="$(assert_result_bundle "$result_bundle" "complete suite" "$counts" reject-skipped | tail -n1)" \
        || fail_automated "test suite (see counts above)"
elif [ "$test_rc" -ne 0 ]; then
    fail_automated "test suite"
else
    log_error "no result bundle at ${result_bundle}"
    fail_automated "test suite produced no result bundle"
fi
[ "$test_rc" -eq 0 ] || fail_automated "test suite"

# This gate deliberately stops before `xcodebuild archive`; distribution artifacts
# and publication are outside verification and require the configured signing context.

# --- the candidate must still be the content that was verified ---------------
printf '\n'
log_step "Candidate integrity"
assert_immutable_candidate_root "$head_sha"

human_pending="$(prepare_human_release_checklist "$head_sha" "$distribution_channel" "$candidate_id")" || {
    report_line "$report" "**VERDICT:** NOT_READY"
    report_line "$report" "**Failed step:** candidate-bound human checklist"
    emit_verdict NOT_READY
    exit "$EX_VERIFY"
}
human_checklist="${IOSAI_ARTIFACTS_DIR}/release-checklists/${head_sha}/checklist.md"
log_ok "all release checks passed"
report_line "$report" "**Human checklist:** ${human_checklist}"
report_line "$report" "**Pending human steps:** ${human_pending}"
report_line "$report" "Manual sequence: subjective review; Product > Archive and Organizer validation; developer distribution decision."
report_line "$report" "Archive this commit. A checkout that has since moved on by continuity records alone archives the same bytes, which ./Scripts/project-status.sh continuity ${head_sha} confirms."


report_line "$report" "## Release verification"
report_line "$report" ""
report_line "$report" "| Check | Result |"
report_line "$report" "| --- | --- |"
report_line "$report" "| Candidate source immutable during the run | passed |"
report_line "$report" "| Final audit coverage | passed |"
report_line "$report" "| Static verification | passed |"
report_line "$report" "| Release configuration | passed |"
report_line "$report" "| Clean ${CONFIGURATION_DEBUG:-Debug} build | passed |"
report_line "$report" "| Clean ${CONFIGURATION_RELEASE:-Release} build, generic $(app_platform) device, unsigned | passed |"
report_line "$report" "| Complete test suite | ${counts_line:-see test.log} |"
report_line "$report" ""
report_line "$report" "## Exact commands"
report_line "$report" ""
report_line "$report" '```sh'
for c in "${run_dir}"/*.command; do
    [ -f "$c" ] || continue
    report_line "$report" "$(cat "$c")"
done
report_line "$report" '```'
report_line "$report" "## Result"
report_line "$report" ""
if [ -n "${COMPANION_PROFILE:-}" ]; then
    simulator_release
    verify_companion_profile release "$run_dir" "$report" || { emit_verdict VERIFICATION_FAILED; exit "$EX_FAIL"; }
    assert_immutable_candidate_root "$opt_candidate"
fi

report_line "$report" "**VERIFIED_COMMIT:** \`${head_sha}\`"
report_line "$report" "**Audit coverage:** COMPLETE"
report_line "$report" "**VERDICT:** READY_FOR_HUMAN"
report_line "$report" ""
report_line "$report" "Nothing was archived, uploaded, submitted, pushed, or published."

printf '\n'
log_ok "READY FOR HUMAN"
log_info "human checklist: ${human_checklist} (${human_pending} pending)"
log_info "candidate: ${candidate_id}"
log_info "commit:    ${head_sha}"
log_info "report:    $(relpath "$report")"
log_info "No archive was created and nothing was uploaded, submitted, or published."
log_info "Before archiving from a later checkout: ./Scripts/project-status.sh continuity ${head_sha}"
emit_verdict READY_FOR_HUMAN
exit 0
