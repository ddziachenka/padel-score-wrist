#!/usr/bin/env bash
# self-test.sh — the template's own regression suite.
#
# Every case here corresponds to a way this tooling was once wrong: a
# configuration that could execute code, a "complete suite" that had been
# narrowed, incomplete audit coverage that reported release readiness, a cleanup that
# deleted data outside the repository, a report that copied a credential.
#
# WHY FIXTURES, NOT THE REAL REPOSITORY
# A gate that is only ever seen to pass has not been tested. These cases need a
# repository that is broken on purpose, a remote that can be pushed to, and a
# build that fails on command — none of which belong in the checkout you work in.
# Each case therefore builds a throwaway copy under a temporary directory, with a
# local bare remote and stub xcodebuild/xcresulttool on PATH, and asserts exit
# codes, verdict tokens, and side effects: whether the remote ref moved, whether a
# sentinel file survived, whether a secret appeared in output.
#
# NO XCODE IS INVOLVED, and nothing here claims otherwise. The stubs prove the
# gates' own logic — argument handling, result-bundle parsing, verdict mapping.
# They cannot prove that a real build behaves as expected. See "Xcode validation
# boundary" in AI/WORKFLOW.md.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/self-test.sh [options]

Runs the template's own regression suite against throwaway fixtures.

  --case NAME   run only cases whose name contains NAME
  --jobs N      worker count, or 'auto' (default). 1 runs serially with live
                output; IOSAI_TEST_JOBS sets the same value from the environment
  --list        list the case names and exit
  --keep        keep the fixture directory for inspection
  -h, --help    this message

Cases are independent and run concurrently by default, each in its own process and
its own temporary repository. The worker count changes only how long the suite
takes: the same defect fails the same way at any width, and IOSAI_TEST_JOBS=1
reproduces a failure serially. A case whose assertion observes state the machine
shares is run alone; that is the only reason a case is not run concurrently.

Exit codes:
  0   every case passed
  64  a bad argument, including an unusable worker count
  65  at least one case failed
  69  a prerequisite is missing

No Xcode is required: xcodebuild and xcresulttool are stubbed. The suite therefore
proves the gates' logic, not that a real build works.
EOF
}

opt_case=""
opt_keep="no"
opt_list="no"
opt_jobs=""
# --run-one, --root and --stream are how the parent invokes itself for a single
# case. They are not part of the documented surface, but they are validated as
# strictly as everything else: a worker that could be pointed at an arbitrary
# directory would be a way around the cleanup ownership rules.
opt_run_one=""
opt_root=""
opt_stream="no"
while [ $# -gt 0 ]; do
    case "$1" in
        --case) [ $# -gt 1 ] || die "$EX_USAGE" "--case requires a value"; opt_case="$2"; shift 2 ;;
        --jobs) [ $# -gt 1 ] && [ -n "$2" ] || die "$EX_USAGE" "--jobs requires a value"; opt_jobs="$2"; shift 2 ;;
        --list) opt_list="yes"; shift ;;
        --keep) opt_keep="yes"; shift ;;
        --run-one) [ $# -gt 1 ] || die "$EX_USAGE" "--run-one requires a case name"; opt_run_one="$2"; shift 2 ;;
        --root) [ $# -gt 1 ] || die "$EX_USAGE" "--root requires a directory"; opt_root="$2"; shift 2 ;;
        --stream) opt_stream="yes"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "unknown argument: $1"; hint "run with --help"; exit "$EX_USAGE" ;;
    esac
done

require_tools git shasum sed awk grep find tar perl xargs

CASES="companion_profiles
watch_companion_readiness
config_parser
watch_platform
watch_coverage
watch_builds
watch_plist_paths
watch_simulator
simulator_isolation
simulator_leases
push_is_synchronization
dirty_checkout_isolation
mid_gate_mutation
immutable_candidate
repository_boundary
workspace_reference_closure
resume_milestone
site_extractor_failure
supported_appearances
human_checklist_binding
hostile_environment
git_environment_isolation
test_scope_arguments
test_repetition_config
result_bundle_counts
tool_status
configuration_semantics
milestone_scope
report_labels
release_verdict_matrix
release_endpoint_failures
release_coverage_schema
domain_audit_coverage
status_schema
release_distribution_boundary
automatic_distribution_guard
artifact_outputs
destructive_paths
secret_handling
integration_recovery
milestone_schema
conflict_markers
placeholder_allowlist
placeholder_shipping
template_readonly
milestone_lifecycle
milestone_current_head
milestone_branch_gate
continuity_records
project_initialization
initialization_failure_closed
documentation_consistency
candidate_worktree_cleanup
optional_hooks
worktree_targets
app_target_identity
distribution_channel
cwd_independence
secret_pattern_isolation
git_state_failure_closed
xcode_user_state
scanner_failure_closed
pipeline_early_exit
credential_allowlist
nested_checkout_scans
nested_app_repository
fenced_milestone_fields
project_phase_parity
record_policy_status
milestone_report_hygiene
status_scratch_cleanup
record_templates
static_configuration_validation
product_repository_identity
vendored_dependencies
batched_scanning
candidate_identity_stability
release_workflow_readiness
derived_data_argument
live_doc_vocabulary
workflow_contract
final_audit_milestones_contract
release_revalidation
review_request_contract
legal_support_contract
premium_override_contract
price_presentation_contract
product_craftsmanship_contract
visual_craftsmanship_contract
decision_autonomy_contract
localization_workflow_contract
store_listing_out_of_scope
retired_release_interfaces
parallel_worker_count
parallel_scheduler
parallel_case_isolation
parallel_failure_surfaced
parallel_serial_equivalence
parallel_cleanup_confined"

if [ "$opt_list" = "yes" ]; then
    printf '%s\n' "$CASES"
    exit 0
fi

# ---------------------------------------------------------------------------
# Harness
# ---------------------------------------------------------------------------
SELF="${_script_dir}/self-test.sh"
# The parent's temporary root, and the only path anything here deletes. A worker
# leaves it empty: a worker owns one subtree of the root and removes nothing.
SELFTEST_ROOT=""
POOL_PID=""
CASES_RUN=0
CHECKS_PASSED=0
CHECKS_FAILED=0
FAILED_CASES=""
CURRENT_CASE=""

# cleanup_fixture_cache_roots — remove the build-cache roots the gates made for
# fixtures under SELFTEST_ROOT.
#
# A gate keys its DerivedData to the physical path of the checkout it serves and
# puts it at /private/tmp/<name>-<hash>/, outside every temporary root on purpose:
# that checkout-owned location is what the release gate trusts. So each stubbed gate
# run in a fixture left one such directory behind after the fixture itself was gone,
# and an audit counted 232 of them after a day of runs. The owners are exactly the
# checkouts under the root, each found by its Scripts/lib/common.sh; the root is
# computed with the gates' own function, and removed only when it has that exact
# /private/tmp/<name>-<12 hex> shape, is a real directory rather than a symlink, and
# belongs to this user.
cleanup_fixture_cache_roots() {
    local lib owner physical root
    [ -n "$SELFTEST_ROOT" ] && [ -d "$SELFTEST_ROOT" ] || return 0
    while IFS= read -r lib; do
        [ -n "$lib" ] || continue
        owner="${lib%/Scripts/lib/common.sh}"
        physical="$(cd -- "$owner" 2>/dev/null && pwd -P)" || continue
        root="$(IOSAI_CACHE_OWNER_PATH="$physical" derived_data_owned_root 2>/dev/null)" || continue
        printf '%s' "$root" | grep -Eq '^/private/tmp/[A-Za-z0-9._-]+-[0-9a-f]{12}$' || continue
        [ -d "$root" ] && [ ! -L "$root" ] && [ -O "$root" ] || continue
        chmod -R u+w "$root" 2>/dev/null || true
        rm -rf -- "$root" 2>/dev/null || true
    done <<EOF
$(find "$SELFTEST_ROOT" -path '*/Scripts/lib/common.sh' -type f 2>/dev/null)
EOF
    return 0
}

cleanup() {
    # Stop every worker before removing anything. The pool is started in its own
    # process group precisely so this can be a single signal: a worker still alive
    # while the root is being deleted would recreate paths underneath it, and an
    # interrupted parallel run would leave a half-removed tree for the next one.
    if [ -n "$POOL_PID" ]; then
        kill -TERM -"$POOL_PID" 2>/dev/null \
            || kill -TERM "$POOL_PID" 2>/dev/null \
            || true
        wait "$POOL_PID" 2>/dev/null || true
        POOL_PID=""
    fi

    [ -n "$SELFTEST_ROOT" ] || return 0
    if [ "$opt_keep" = "yes" ]; then
        printf '\nfixtures kept: %s\n' "$SELFTEST_ROOT"
        return 0
    fi
    # Before the fixtures go: their paths are what the cache roots are keyed to.
    cleanup_fixture_cache_roots
    # Fixtures are ours and live under a temp root; remove them with plain rm
    # rather than safe_remove_path, which deliberately refuses roots this
    # repository does not own.
    #
    # Write access is restored first because one fixture under this root is made
    # read-only on purpose: the case that forges an immutable candidate holds its
    # tree at a-w for the length of a gate run. An interrupt inside that window
    # would otherwise leave a tree its owner could not delete, which is the same
    # defect the candidate snapshot handler in common.sh exists to prevent.
    if [ -d "$SELFTEST_ROOT" ]; then
        chmod -R u+w "$SELFTEST_ROOT" 2>/dev/null || true
        rm -rf -- "$SELFTEST_ROOT"
    fi
    return 0
}

# _selftest_signal_cleanup <signal> — clean up, then re-raise with the default
# handler so the caller still sees a normal signal death. The same shape as the
# candidate snapshot's handler in common.sh, and for the same reason: an EXIT trap
# alone does not run when an untrapped fatal signal arrives, so a cancelled run
# would leave its temporary tree and its workers behind.
_selftest_signal_cleanup() {
    local sig="$1"
    cleanup
    trap - EXIT INT TERM HUP
    kill -s "$sig" $$ 2>/dev/null || exit "$EX_FAIL"
}

check() {
    local outcome="$1" detail="$2"
    if [ "$outcome" = "pass" ]; then
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        printf '    %sok%s   %s\n' "$_C_GREEN" "$_C_RESET" "$detail"
    else
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        printf '    %sFAIL%s %s\n' "$_C_RED" "$_C_RESET" "$detail" >&2
        case "$FAILED_CASES" in
            *"${CURRENT_CASE} "*) : ;;
            *) FAILED_CASES="${FAILED_CASES}${CURRENT_CASE} " ;;
        esac
        selftest_reprint_last_capture
    fi
}

# selftest_reprint_last_capture — after a failed check, the end of the output the
# case captured most recently, once per captured file.
#
# A case's gate output lives in its fixture directory, and the run deletes that
# directory unless --keep was given in advance. A one-off failure then left nothing
# to diagnose but the check's own line: an audit saw "expected exit 0, got 1" from
# a gate whose reason was gone, and only a re-run with --keep showed it. The tail
# goes into the case's own output, which the driver reprints for every failing case.
SELFTEST_REPRINTED=""
selftest_reprint_last_capture() {
    local last=""
    [ -n "${SELFTEST_DIR:-}" ] && [ -f "${SELFTEST_DIR}/.last-capture" ] || return 0
    last="$(cat "${SELFTEST_DIR}/.last-capture" 2>/dev/null || true)"
    [ -n "$last" ] && [ -f "$last" ] || return 0
    [ "$last" != "$SELFTEST_REPRINTED" ] || return 0
    SELFTEST_REPRINTED="$last"
    printf '         last captured output, %s (final 25 lines):\n' "${last#"${SELFTEST_DIR}/"}" >&2
    tail -n 25 "$last" | sed 's/^/           | /' >&2
}

expect_exit() {
    local want="$1" got="$2" label="$3"
    if [ "$got" = "$want" ]; then
        check pass "${label} (exit ${got})"
    else
        check fail "${label}: expected exit ${want}, got ${got}"
    fi
}

expect_contains() {
    local haystack="$1" needle="$2" label="$3"
    case "$haystack" in
        *"$needle"*) check pass "${label}" ;;
        *) check fail "${label}: output does not contain '${needle}'" ;;
    esac
}

expect_absent() {
    local haystack="$1" needle="$2" label="$3"
    case "$haystack" in
        *"$needle"*) check fail "${label}: output contains '${needle}' and must not" ;;
        *) check pass "${label}" ;;
    esac
}

expect_same() {
    local a="$1" b="$2" label="$3"
    if [ "$a" = "$b" ]; then check pass "$label"; else
        check fail "${label}: '${a}' != '${b}'"
    fi
}

# run_capture <file> <command...> — run, capture combined output, echo the status.
#
# The file's path is recorded beside the case's fixtures (a file, because callers run
# this in a command substitution, where a variable would not survive) so that a
# failed check can reprint the end of it.
run_capture() {
    local out="$1"; shift
    local rc=0
    "$@" >"$out" 2>&1 || rc=$?
    if [ -n "${SELFTEST_DIR:-}" ] && [ -d "$SELFTEST_DIR" ]; then
        printf '%s\n' "$out" > "${SELFTEST_DIR}/.last-capture" 2>/dev/null || true
    fi
    printf '%s\n' "$rc"
}

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

# fixture_copy <dest> — a throwaway copy of THIS working tree (not HEAD, so a
# change under test is exercised before it is committed).
#
# .wrangler and node_modules are excluded for cost, not correctness. Both are
# git-ignored, so neither can affect a gate's result, and both are large: this
# function runs once per case, so copying a dependency tree into every fixture
# would slow the suite by minutes without testing anything. Excluding them keeps
# a developer who has published Web/ locally from paying for it here.
fixture_copy() {
    local dest="$1" source_commit="" source relative
    mkdir -p "$dest"
    # Product-owned contracts are not universal-template fixtures. Use the
    # explicitly recorded initial template tree, then overlay the CURRENT tooling.
    # Assertions are unchanged; only synthetic inputs are separated from real app data.
    if [ -f "${IOSAI_ROOT}/.iosai-project" ]; then
        source_commit="$(sed -n 's/^tooling_fixture_source_commit=//p' "${IOSAI_ROOT}/.iosai-project")"
    fi
    if [ -n "$source_commit" ]; then
        [[ "$source_commit" =~ ^[0-9a-f]{40}$ ]] \
            || die "$EX_USAGE" 'tooling fixture source must be one full commit'
        git -C "$IOSAI_ROOT" cat-file -e "${source_commit}^{commit}" \
            || die "$EX_NOINPUT" 'recorded template fixture source is unavailable'
        git -C "$IOSAI_ROOT" archive "$source_commit" | tar -xf - -C "$dest"
        # The first local import contained a product brief handoff. A fresh
        # universal fixture has no completed product handoff (M00 recorded this).
        rm -f "${dest}/AI/handoffs/product-brief.md"
        mkdir -p "${dest}/Scripts/lib" "${dest}/.githooks"
        for source in "${IOSAI_ROOT}"/Scripts/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.sh "${IOSAI_ROOT}"/Scripts/lib/*.pl; do
            [ -f "$source" ] || continue
            relative="${source#${IOSAI_ROOT}/}"
            cp -p "$source" "${dest}/${relative}"
        done
        for relative in Makefile .gitignore Config/project.env.example Config/release-requirements.v3.tsv .githooks/pre-commit; do
            [ -f "${IOSAI_ROOT}/${relative}" ] || continue
            cp -p "${IOSAI_ROOT}/${relative}" "${dest}/${relative}"
        done
        "${dest}/Scripts/configure-project.sh" --template-mode --print > "${dest}/Config/project.env"
    else
        ( cd "$IOSAI_ROOT" && tar -cf - --exclude='./.git' --exclude='./.artifacts' --exclude='./.iosai-local' \
            --exclude='./.wrangler' --exclude='./Web/.wrangler' \
            --exclude='./node_modules' --exclude='./Web/node_modules' . ) \
            | ( cd "$dest" && tar -xf - )
    fi
    chmod -R u+w "$dest"
    mkdir -p "${dest}/.artifacts"
    : > "${dest}/.artifacts/.gitkeep"
    return 0
}

# fixture_plant_records <dir> — one classified audit and one classified handoff.
#
# The initialization cases need a record that either survives a refusal or is
# removed by a successful run, and the template deliberately ships none: a new
# product must inherit no audit of someone else's work. So the fixture supplies
# its own instead of naming a file from this repository's history, which is
# exactly the coupling that used to break these assertions whenever the record
# set changed. `**Policy status:** current` is what verify-template.sh requires
# of every file under either directory.
fixture_plant_records() {
    local dir="$1"
    printf '**Policy status:** current\n\n# Fixture audit probe\n' \
        > "${dir}/AI/audits/fixture-probe-audit.md"
    printf '**Policy status:** current\n\n# Fixture handoff probe\n' \
        > "${dir}/AI/handoffs/fixture-probe-handoff.md"
    return 0
}

# fixture_git <dir> — a repository with one commit and no configured hooks.
fixture_commit_unchecked() {
    local dir="$1" message="$2" tree parent commit
    git -C "$dir" add -A
    tree="$(git -C "$dir" write-tree)"
    parent="$(git -C "$dir" rev-parse --verify HEAD 2>/dev/null || true)"
    if [ -n "$parent" ]; then
        commit="$(printf '%s\n' "$message" | git -C "$dir" commit-tree "$tree" -p "$parent")"
    else
        commit="$(printf '%s\n' "$message" | git -C "$dir" commit-tree "$tree")"
    fi
    git -C "$dir" update-ref HEAD "$commit"
    return 0
}

fixture_git() {
    local dir="$1"
    git -C "$dir" init -q .
    git -C "$dir" symbolic-ref HEAD refs/heads/main
    git -C "$dir" config user.email "selftest@example.invalid"
    git -C "$dir" config user.name "Self Test"
    # Fixture setup sometimes needs an intentionally invalid commit. Construct
    # it with Git plumbing; hooks remain unset unless a hook-specific case opts in.
    fixture_commit_unchecked "$dir" "fixture"
    return 0
}

fixture_candidate() {
    git -C "$1" rev-parse HEAD
}

fixture_milestone() {
    local repo="$1" milestone="$2"; shift 2
    "${repo}/Scripts/verify-milestone.sh" "$milestone" \
        --candidate "$(fixture_candidate "$repo")" "$@"
}

fixture_integration() {
    local repo="$1"; shift
    "${repo}/Scripts/verify-integration.sh" \
        --candidate "$(fixture_candidate "$repo")" "$@"
}

fixture_release() {
    local repo="$1"; shift
    case " $* " in
        *" --print-candidate "*|*" --require-manual-evidence "*) : ;;
        *)
            if ! grep -Eq '^TEMPLATE_REPOSITORY="?true"?$' "${repo}/Config/project.env"; then
                fixture_prepare_release_ready "$repo"
            fi
            ;;
    esac
    "${repo}/Scripts/verify-release.sh" \
        --candidate "$(fixture_candidate "$repo")" "$@"
}

fixture_release_raw() {
    local repo="$1"; shift
    "${repo}/Scripts/verify-release.sh" \
        --candidate "$(fixture_candidate "$repo")" "$@"
}

# fixture_bare_remote <dir> — a local bare remote, wired as origin.
fixture_bare_remote() {
    local repo="$1" bare="${1}-remote.git"
    git init -q --bare "$bare"
    git -C "$repo" remote add origin "$bare"
    printf '%s\n' "$bare"
}

# fixture_stubs <bin-dir> — stub xcodebuild and xcrun on PATH.
#
# Deliberately OUTSIDE the fixture repository: an untracked file inside a fixture
# would make every strict gate correctly refuse the tree, and the case under test
# would never run.
#
# Env knobs a case can set:
#   STUB_SETTINGS_JSON  file to emit for -showBuildSettings -json
#   STUB_SETTINGS_STATUS exit status after emitting build-settings JSON
#   STUB_SUMMARY_JSON   the test-results summary the result bundle reports
#   STUB_XCRUN_STATUS   exit status after emitting result-summary JSON
#   STUB_BUILD_FAIL     non-empty: the build action fails
#   STUB_TEST_FAIL      non-empty: the test action fails
#   STUB_MUTATE_FILE    non-empty: append to this file mid-run (a build phase
#                       rewriting a tracked input)
fixture_stubs() {
    local bin="$1"
    mkdir -p "$bin"

    cat > "${bin}/settings.json" <<'JSON'
[
  {
    "target": "Fixture",
    "action": "build",
    "buildSettings": {
      "PRODUCT_TYPE": "com.apple.product-type.application",
      "MARKETING_VERSION": "1.0.0",
      "CURRENT_PROJECT_VERSION": "1",
      "PRODUCT_BUNDLE_IDENTIFIER": "com.example.fixture"
    }
  },
  {
    "target": "FixtureTests",
    "action": "build",
    "buildSettings": {
      "PRODUCT_TYPE": "com.apple.product-type.bundle.unit-test",
      "MARKETING_VERSION": "9.9.9",
      "CURRENT_PROJECT_VERSION": "99"
    }
  }
]
JSON

    cat > "${bin}/summary.json" <<'JSON'
{"totalTestCount":3,"passedTests":3,"failedTests":0,"skippedTests":0,"expectedFailures":0}
JSON

    cat > "${bin}/xcodebuild" <<'STUB'
#!/usr/bin/env bash
# Stub xcodebuild. Proves argument handling and result-bundle plumbing only.
set -euo pipefail
stub_dir="$(cd -- "$(dirname -- "$0")" && pwd -P)"

case " $* " in
    *" -showBuildSettings "*)
        cat "${STUB_SETTINGS_JSON:-${stub_dir}/settings.json}"
        exit "${STUB_SETTINGS_STATUS:-0}" ;;
esac

bundle=""
archive_path=""
prev=""
for a in "$@"; do
    [ "$prev" = "-resultBundlePath" ] && bundle="$a"
    [ "$prev" = "-archivePath" ] && archive_path="$a"
    prev="$a"
done

# Every invocation is recorded beside the stub, outside the fixture, so a case can
# assert what a gate actually asked xcodebuild to do rather than what its report
# says it did.
printf '%s\n' "$*" >> "${stub_dir}/invocations.log"

action="build"
for a in "$@"; do
    case "$a" in
        test|build|clean|archive) [ "$a" = "clean" ] || action="$a" ;;
    esac
done

# A build phase that rewrites a tracked input, which is exactly what the
# candidate-integrity check exists to catch. In a read-only candidate snapshot the
# write is refused, and the build fails the way a real build phase would: loudly,
# naming the file, so a case can tell that refusal apart from any other failure.
# `2>/dev/null` comes first because Bash applies redirections left to right.
if [ -n "${STUB_MUTATE_FILE:-}" ]; then
    if ! printf '// rewritten by a build phase at run time\n' 2>/dev/null >> "$STUB_MUTATE_FILE"; then
        printf 'stub: build phase could not write %s\n' "$STUB_MUTATE_FILE" >&2
        exit 65
    fi
fi

case "$action" in
    build)
        [ -z "${STUB_BUILD_FAIL:-}" ] || { printf 'stub: build failed\n' >&2; exit 65; }
        printf 'stub: BUILD SUCCEEDED\n' ;;
    test)
        if [ -n "$bundle" ]; then
            mkdir -p "$bundle"
            cp -- "${STUB_SUMMARY_JSON:-${stub_dir}/summary.json}" "${bundle}/summary.json"
        fi
        if [ -n "${STUB_TEST_FAIL:-}" ]; then
            printf 'stub: TEST FAILED\n' >&2
            exit 65
        fi
        printf 'stub: TEST SUCCEEDED\n' ;;
    archive)
        # A real archive leaves an .xcarchive behind, and so does this one. Treating
        # `archive` as a plain build made "created no xcarchive" a check that could
        # not fail: an audit put `xcodebuild archive` back into the release gate and
        # the whole suite still passed.
        mkdir -p "${archive_path:-${stub_dir}/Default.xcarchive}"
        printf 'stub: ARCHIVE SUCCEEDED\n' ;;
esac
exit 0
STUB

    cat > "${bin}/xcrun" <<'STUB'
#!/usr/bin/env bash
# Stub xcrun: only the xcresulttool summary call the gates make.
set -uo pipefail
if [ "${1:-}" = "xcresulttool" ]; then
    path=""
    prev=""
    for a in "$@"; do
        [ "$prev" = "--path" ] && path="$a"
        prev="$a"
    done
    if [ -n "$path" ] && [ -f "${path}/summary.json" ]; then
        cat "${path}/summary.json"
        exit "${STUB_XCRUN_STATUS:-0}"
    fi
    exit 1
fi
exit 0
STUB

    chmod +x "${bin}/xcodebuild" "${bin}/xcrun"
    printf '%s\n' "$bin"
}

# fixture_product <dir> — a product-mode fixture: fake project container, config,
# internal distribution, stubs, git, and a bare remote.
fixture_product() {
    local dir="$1" work="$2"
    mkdir -p "$work"
    fixture_copy "$dir"

    mkdir -p "${dir}/App/Fixture.xcodeproj" "${dir}/App/Fixture"
    printf '// fixture project\n' > "${dir}/App/Fixture.xcodeproj/project.pbxproj"
    printf 'let fixture = 1\n' > "${dir}/App/Fixture/Fixture.swift"

    cat > "${dir}/Config/project.env" <<'CONFIG'
PROJECT_NAME="Fixture"
BUNDLE_IDENTIFIER="com.example.fixture"

PROJECT_PATH="App/Fixture.xcodeproj"
WORKSPACE_PATH=""
SCHEME="Fixture"
APP_TARGET=""

CONFIGURATION_DEBUG="Debug"
CONFIGURATION_RELEASE="Release"

BUILD_DESTINATION="platform=iOS Simulator,name=Fixture Device"
TEST_DESTINATION="platform=iOS Simulator,name=Fixture Device"

FAST_TEST_ARGUMENTS=""
MILESTONE_TEST_ARGUMENTS=""
RELEASE_TEST_ARGUMENTS=""

DERIVED_DATA_PATH=""

DISTRIBUTION_CHANNEL="internal"

TEMPLATE_REPOSITORY="false"

ENABLE_SWIFTLINT="false"
ENABLE_SWIFTFORMAT="false"
ENABLE_SHELLCHECK="false"
CONFIG

    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** REVIEW/' \
        "${dir}/AI/milestones/M00-template-bootstrap.md" \
        > "${dir}/AI/milestones/M00-template-bootstrap.md.tmp"
    mv "${dir}/AI/milestones/M00-template-bootstrap.md.tmp" \
        "${dir}/AI/milestones/M00-template-bootstrap.md"

    STUB_BIN="$(fixture_stubs "${work}/bin")"
    fixture_git "$dir"
    return 0
}

# fixture_template <dir> — a template-mode fixture with git and a bare remote.
fixture_template() {
    local dir="$1" work="${2:-}"
    [ -z "$work" ] || mkdir -p "$work"
    fixture_copy "$dir"
    fixture_git "$dir"
    return 0
}

# ---------------------------------------------------------------------------
# Cases
# ---------------------------------------------------------------------------

# Modern Watch-only build fixture. Its Xcode stub produces actual plist files in
# the owned cache, so packaging tests exercise the same parser/path boundary as a
# real build. Mutations change outputs, not the validator's implementation.
fixture_watch() {
    local fx="$1" work="$2"
    fixture_product "$fx" "$work"
    sed -e 's/platform=iOS Simulator/platform=watchOS Simulator/g' \
        -e 's/com.example.fixture/com.example.fixture.watchkitapp/g' \
        "${fx}/Config/project.env" > "${work}/watch.env"
    cat "${work}/watch.env" > "${fx}/Config/project.env"
    printf '\nAPP_PLATFORM="watchOS"\n' >> "${fx}/Config/project.env"
    mv "${STUB_BIN}/xcodebuild" "${STUB_BIN}/xcodebuild-base"
    cat > "${STUB_BIN}/xcodebuild" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
derived=""; configuration=Release; destination=""; prev=""
for arg in "$@"; do
    case "$prev" in
        -derivedDataPath) derived="$arg" ;;
        -configuration) configuration="$arg" ;;
        -destination) destination="$arg" ;;
    esac
    prev="$arg"
done
# Identity queries need no output paths. Post-build queries receive DerivedData.
products="${derived:-/unused}/${configuration}-watch-fixture"
settings="$(jq -n --arg dir "$products" --arg destination "$destination" '
 [ {target:"Watch",buildSettings:{PRODUCT_TYPE:"com.apple.product-type.application",
     PLATFORM_NAME:(if ($destination | contains("Simulator")) then "watchsimulator" else "watchos" end),
     SUPPORTED_PLATFORMS:"watchos watchsimulator",MARKETING_VERSION:"1.0.0",CURRENT_PROJECT_VERSION:"1",
     PRODUCT_BUNDLE_IDENTIFIER:"com.example.fixture.watchkitapp",TARGET_BUILD_DIR:$dir,
     INFOPLIST_PATH:"Watch.app/Info.plist",FULL_PRODUCT_NAME:"Watch.app"}},
   {target:"Container",buildSettings:{PRODUCT_TYPE:"com.apple.product-type.application.watchapp2-container",
     SUPPORTED_PLATFORMS:"iphoneos iphonesimulator",MARKETING_VERSION:"1.0.0",CURRENT_PROJECT_VERSION:"1",
     PRODUCT_BUNDLE_IDENTIFIER:"com.example.fixture",TARGET_BUILD_DIR:$dir,
     INFOPLIST_PATH:"Container.app/Info.plist",FULL_PRODUCT_NAME:"Container.app"}} ]')"
case "${STUB_WATCH_FAULT:-}" in
    extension) settings="$(printf '%s' "$settings" | jq '.[0].buildSettings.PRODUCT_TYPE="com.apple.product-type.watchkit2-extension"')" ;;
    companion) settings="$(printf '%s' "$settings" | jq '.[1].buildSettings.PRODUCT_TYPE="com.apple.product-type.application"')" ;;
    duplicate) settings="$(printf '%s' "$settings" | jq '. + [.[0]]')" ;;
    no-container) settings="$(printf '%s' "$settings" | jq '[.[0]]')" ;;
esac
case " $* " in
    *" -showBuildSettings "*) printf '%s\n' "$settings"; exit "${STUB_SETTINGS_STATUS:-0}" ;;
esac
"${here}/xcodebuild-base" "$@"
case " $* " in
    *" build "*)
        [ -n "$derived" ] || exit 65
        mkdir -p "${products}/Watch.app" "${products}/Container.app/Watch/Watch.app"
        app='{"WKWatchOnly":true,"CFBundlePackageType":"APPL","CFBundleSupportedPlatforms":["WatchOS"],"CFBundleIdentifier":"com.example.fixture.watchkitapp","CFBundleShortVersionString":"1.0.0","CFBundleVersion":"1"}'
        container='{"CFBundleIdentifier":"com.example.fixture","CFBundleShortVersionString":"1.0.0","CFBundleVersion":"1"}'
        case "$destination" in
            *"platform=watchOS Simulator"*) app="$(printf '%s' "$app" | jq '.CFBundleSupportedPlatforms=["WatchSimulator"]')" ;;
        esac
        case "${STUB_WATCH_FAULT:-}" in
            not-only) app="$(printf '%s' "$app" | jq '.WKWatchOnly=false')" ;;
            companion-key) app="$(printf '%s' "$app" | jq '.WKCompanionAppBundleIdentifier="com.example.phone"')" ;;
            wrong-version) container="$(printf '%s' "$container" | jq '.CFBundleVersion="2"')" ;;
            bad-id) app="$(printf '%s' "$app" | jq '.CFBundleIdentifier="com.example.wrong"')" ;;
            wrong-platform) app="$(printf '%s' "$app" | jq '.CFBundleSupportedPlatforms=["iPhoneOS"]')" ;;
        esac
        printf '%s' "$app" | plutil -convert xml1 -o "${products}/Watch.app/Info.plist" -
        printf '%s' "$container" | plutil -convert xml1 -o "${products}/Container.app/Info.plist" -
        cp "${products}/Watch.app/Info.plist" "${products}/Container.app/Watch/Watch.app/Info.plist"
        case "${STUB_WATCH_FAULT:-}" in
            missing-plist) rm "${products}/Watch.app/Info.plist" ;;
            bad-plist) printf 'broken' > "${products}/Watch.app/Info.plist" ;;
            missing-embed) rm "${products}/Container.app/Watch/Watch.app/Info.plist" ;;
            stale-embed) printf '%s' "$app" | jq '.CFBundleVersion="0"' | plutil -convert xml1 -o "${products}/Container.app/Watch/Watch.app/Info.plist" - ;;
        esac ;;
esac
STUB
    chmod +x "${STUB_BIN}/xcodebuild"
    fixture_commit_unchecked "$fx" 'Watch-only fixture'
}

case_companion_profiles() {
    local fx="${SELFTEST_DIR}/companion-config" work="${SELFTEST_DIR}/companion-work" rc
    fixture_product "$fx" "$work"
    cat > "${fx}/Config/companion.env" <<'PROFILE'
APP_PLATFORM="iOS"
SCHEME="FixturePhone"
APP_TARGET="FixturePhone"
SIMULATOR_MODE="explicit"
COMPANION_PROFILE=""
PROFILE
    rc="$(run_capture "${work}/profiles" bash -c '
        . "$1/Scripts/lib/common.sh"; load_project_config --required
        simulator_state_dir
        COMPANION_PROFILE=Config/companion.env; load_companion_profile
        app_platform; simulator_state_dir; simulator_device_name
    ' _ "$fx")"
    expect_exit 0 "$rc" 'explicit iOS companion profile loads'
    expect_contains "$(cat "${work}/profiles")" '/.iosai-local/companion' 'companion binding is separate'
    expect_contains "$(cat "${work}/profiles")" 'companion-' 'companion simulator name is distinct'
    expect_contains "$(cat "${work}/profiles")" 'iOS' 'companion runs on iOS'
    rc="$(run_capture "${work}/recursive" bash -c '
        . "$1/Scripts/lib/common.sh"; load_project_config --required
        printf "\nCOMPANION_PROFILE=\"Config/companion.env\"\n" >> "$1/Config/companion.env"
        COMPANION_PROFILE=Config/companion.env; load_companion_profile
    ' _ "$fx")"
    expect_exit 65 "$rc" 'recursive or duplicate companion profile is rejected'
    sed '/^COMPANION_PROFILE=/d; /^MILESTONE_TEST_ARGUMENTS=/d' "${fx}/Config/companion.env" > "${work}/clean-profile"
    cp "${work}/clean-profile" "${fx}/Config/companion.env"
    printf 'COMPANION_PROFILE=""\nMILESTONE_TEST_ARGUMENTS="-only-testing:OneTest"\n' >> "${fx}/Config/companion.env"
    rc="$(run_capture "${work}/narrow" bash -c '
        . "$1/Scripts/lib/common.sh"; load_project_config --required
        COMPANION_PROFILE=Config/companion.env; load_companion_profile
    ' _ "$fx")"
    expect_exit 64 "$rc" 'narrowed companion test scope is refused'
    rc="$(run_capture "${work}/rating" bash -c '
        . "$1/Scripts/lib/common.sh"; APP_PLATFORM=watchOS; WATCH_APP_MODE=companion
        release_coverage_allows_inapplicable REL-208 product app-store
        release_coverage_allows_inapplicable REL-209 release app-store
    ' _ "$fx")"
    expect_exit 0 "$rc" 'companion applicability query works'
    expect_same "$(printf 'no\nno')" "$(cat "${work}/rating")" 'iOS companion removes Watch-only rating exemption'
    rm "${fx}/Config/companion.env"
    printf '\nAPP_PLATFORM="watchOS"\nWATCH_APP_MODE="companion"\nCOMPANION_PROFILE="Config/companion.env"\n' >> "${fx}/Config/project.env"
    rc="$(run_capture "${work}/missing" bash -c '. "$1/Scripts/lib/common.sh"; load_project_config --required' _ "$fx")"
    expect_exit 66 "$rc" 'missing companion profile cannot silently skip the iOS suite'
}

case_watch_platform() {
    local fx="${SELFTEST_DIR}/watch-config" work="${SELFTEST_DIR}/watch-config-work" rc value before
    fixture_product "$fx" "$work"
    rc="$(run_capture "${work}/legacy" bash -c '. "$1/Scripts/lib/common.sh"; load_project_config --required; app_platform' _ "$fx")"
    expect_exit 0 "$rc" 'older configuration loads without APP_PLATFORM'
    expect_same iOS "$(cat "${work}/legacy")" 'absent platform means iOS'
    cat > "${work}/platform-settings.json" <<'JSON'
[{"target":"Phone","buildSettings":{"PRODUCT_TYPE":"com.apple.product-type.application","PLATFORM_NAME":"iphoneos","SUPPORTED_PLATFORMS":"iphoneos watchos"}}]
JSON
    rc="$(run_capture "${work}/resolved-platform" bash -c '. "$1/Scripts/lib/common.sh"; APP_PLATFORM=watchOS; platform_application_entries < "$2"' _ "$fx" "${work}/platform-settings.json")"
    expect_exit 0 "$rc" 'resolved platform settings can be inspected'
    expect_same '[]' "$(cat "${work}/resolved-platform")" 'iOS build cannot masquerade as Watch through supported platforms'
    before="$(cat "${fx}/Config/project.env")"
    rc="$(APP_PLATFORM=watchOS run_capture "${work}/ambient" bash -c '. "$1/Scripts/lib/common.sh"; load_project_config --required; app_platform' _ "$fx")"
    expect_same iOS "$(cat "${work}/ambient")" 'ambient platform cannot override an absent committed key'
    printf '\nAPP_PLATFORM=""\n' >> "${fx}/Config/project.env"
    rc="$(run_capture "${work}/empty-key" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" 'explicitly empty committed platform is rejected'
    printf '%s\n' "$before" > "${fx}/Config/project.env"
    for value in '' macOS WATCHOS; do
        rc="$(run_capture "${work}/invalid" "${fx}/Scripts/configure-project.sh" --force --project App/Fixture.xcodeproj --scheme Fixture --platform "$value" --simulator-mode explicit)"
        expect_exit 64 "$rc" 'invalid platform is refused before writing'
        expect_same "$before" "$(cat "${fx}/Config/project.env")" 'invalid platform preserves product configuration'
    done
    rc="$(run_capture "${work}/mismatch" "${fx}/Scripts/configure-project.sh" --force --project App/Fixture.xcodeproj --scheme Fixture --platform watchOS --simulator-mode explicit --test-destination 'platform=iOS Simulator,name=Phone')"
    expect_exit 64 "$rc" 'explicit destination cannot contradict platform'
    rc="$(run_capture "${work}/runtime" "${fx}/Scripts/configure-project.sh" --force --project App/Fixture.xcodeproj --scheme Fixture --platform watchOS --simulator-device-type com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-8-41mm --simulator-runtime com.apple.CoreSimulator.SimRuntime.iOS-26-5)"
    expect_exit 64 "$rc" 'Watch platform refuses iOS runtime'
    rc="$(run_capture "${work}/valid" "${fx}/Scripts/configure-project.sh" --force --project App/Fixture.xcodeproj --scheme Watch --platform watchOS --simulator-device-type com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-8-41mm --simulator-runtime com.apple.CoreSimulator.SimRuntime.watchOS-26-5)"
    expect_exit 0 "$rc" 'Watch configuration is generated'
    expect_contains "$(cat "${fx}/Config/project.env")" 'APP_PLATFORM="watchOS"' 'platform is persisted'
    for value in iOS watchOS; do
        rc="$(run_capture "${work}/policy" bash -c '. "$1/Scripts/lib/common.sh"; APP_PLATFORM="$2"; release_coverage_allows_inapplicable REL-208 product app-store; release_coverage_allows_inapplicable REL-209 release app-store; release_coverage_allows_inapplicable REL-201 product app-store' _ "$fx" "$value")"
        expect_exit 0 "$rc" 'platform applicability query succeeds'
        if [ "$value" = iOS ]; then
            expect_same "$(printf 'no\nno\nno')" "$(cat "${work}/policy")" 'iOS rating and journey requirements stay mandatory'
        else
            expect_same "$(printf 'yes\nyes\nno')" "$(cat "${work}/policy")" 'only the two watch rating rows gain an exception'
        fi
    done
    # A documentation exception cannot disappear while the iOS mandate survives.
    sed '/watchOS does not generate Review Request/d' "${fx}/AI/prompts/initialize-product.md" > "${work}/prompt"
    cp "${work}/prompt" "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/docs" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" 'removing the watchOS generation exception fails template validation'
}

case_watch_coverage() {
    local fx="${SELFTEST_DIR}/watch-coverage" work="${SELFTEST_DIR}/watch-coverage-work" rc platform domain record
    fixture_product "$fx" "$work"
    for domain in product release; do
        fixture_write_audit_record "$fx" M01 "$domain" app-store
        record="${fx}/AI/audits/M01-${domain}.md"
        sed -E 's/^- (REL-208|REL-209) \| OUTCOME=VERIFIED \| EVIDENCE=.*/- \1 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Watch-only product has no required rating flow/' "$record" > "${work}/valid"
        cp "${work}/valid" "$record"
        for platform in iOS watchOS; do
            rc="$(run_capture "${work}/coverage" bash -c '. "$1/Scripts/lib/common.sh"; APP_PLATFORM="$2"; validate_domain_audit_coverage "$3" "$4" app-store' _ "$fx" "$platform" "$record" "$domain")"
            if [ "$platform" = watchOS ]; then
                expect_exit 0 "$rc" "$domain accepts reasoned watch rating exceptions"
            else
                expect_exit 1 "$rc" "$domain refuses the same rating exceptions on iOS"
            fi
        done
        sed 's/reason=Watch-only product has no required rating flow/reason=required hardware is unavailable/' "${work}/valid" > "$record"
        rc="$(run_capture "${work}/hardware" bash -c '. "$1/Scripts/lib/common.sh"; APP_PLATFORM=watchOS; validate_domain_audit_coverage "$2" "$3" app-store' _ "$fx" "$record" "$domain")"
        expect_exit 1 "$rc" "$domain refuses hardware absence as an exception"
        sed 's/reason=Watch-only product has no required rating flow/reason=/' "${work}/valid" > "$record"
        rc="$(run_capture "${work}/empty" bash -c '. "$1/Scripts/lib/common.sh"; APP_PLATFORM=watchOS; validate_domain_audit_coverage "$2" "$3" app-store' _ "$fx" "$record" "$domain")"
        expect_exit 1 "$rc" "$domain requires an explicit exception reason"
    done
}

case_watch_builds() {
    local fx="${SELFTEST_DIR}/watch-build" work="${SELFTEST_DIR}/watch-build-work" rc fault gate report
    fixture_watch "$fx" "$work"
    for gate in fast milestone integration release; do
        case "$gate" in
            fast) rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/$gate" "${fx}/Scripts/verify-fast.sh")" ;;
            milestone) rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/$gate" fixture_milestone "$fx" M00)" ;;
            integration) rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/$gate" fixture_integration "$fx")" ;;
            release) rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/$gate" fixture_release "$fx")" ;;
        esac
        expect_exit 0 "$rc" "Watch-only $gate gate passes"
        expect_contains "$(cat "${work}/$gate")" 'platform=watchOS Simulator' "$gate uses the Watch simulator"
    done
    expect_contains "$(cat "${work}/release")" 'generic/platform=watchOS' 'release builds for physical watchOS'
    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_contains "$report" '**Release Watch app:** com.example.fixture.watchkitapp 1.0.0 (1)' 'release records the Watch identity'
    expect_contains "$report" '**Release packaging container:** com.example.fixture 1.0.0 (1)' 'release records packaging identity'
    for fault in extension companion duplicate no-container not-only companion-key wrong-version bad-id wrong-platform missing-plist bad-plist missing-embed stale-embed; do
        rc="$(PATH="${STUB_BIN}:$PATH" STUB_WATCH_FAULT="$fault" run_capture "${work}/fault" "${fx}/Scripts/verify-fast.sh")"
        expect_exit 1 "$rc" "Watch build rejects $fault"
    done
    # Named container cannot become the app identity, even with a valid version.
    printf 'APP_TARGET="Container"\n' >> "${fx}/Config/project.env"
    # Replace rather than duplicate the existing optional APP_TARGET assignment.
    sed '/^APP_TARGET=""$/d' "${fx}/Config/project.env" > "${work}/target"
    cp "${work}/target" "${fx}/Config/project.env"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/container" bash -c '. "$1/Scripts/lib/common.sh"; load_project_config --required; app_target_build_setting MARKETING_VERSION' _ "$fx")"
    expect_exit 65 "$rc" 'APP_TARGET cannot select the packaging container'
}

case_watch_plist_paths() {
    local fx="${SELFTEST_DIR}/watch-plist-paths" work="${SELFTEST_DIR}/watch-plist-paths-work"
    local root plist alias rc path spelling
    mkdir -p "${fx}/Scripts/lib" "$work"
    # Only library fixtures are needed: no Xcode, simulator, project or Git writes.
    cp "${IOSAI_ROOT}/Scripts/lib/common.sh" "${IOSAI_ROOT}/Scripts/lib/platform.sh" \
        "${IOSAI_ROOT}/Scripts/lib/simulator.sh" "${fx}/Scripts/lib/"
    root="$(bash -c '. "$1/Scripts/lib/common.sh"; path="$(derived_data_default_path)"; ensure_derived_data_root "$path"; derived_data_owned_root' _ "$fx")"
    plist="${root}/DerivedData/Watch.app/Info.plist"
    mkdir -p "$(dirname "$plist")"
    printf '{"fixture":"owned"}' | plutil -convert xml1 -o "$plist" -
    alias="${plist#/private}"
    rc="$(run_capture "${work}/canonical" bash -c '. "$1/Scripts/lib/common.sh"; platform_built_plist "$2"' _ "$fx" "$plist")"
    expect_exit 0 "$rc" 'canonical owned Watch plist is readable'
    rc="$(run_capture "${work}/tmp-alias" bash -c '. "$1/Scripts/lib/common.sh"; platform_built_plist "$2"' _ "$fx" "$alias")"
    expect_exit 0 "$rc" 'Xcode /tmp spelling of the owned Watch plist is readable'
    expect_same "$(cat "${work}/canonical")" "$(cat "${work}/tmp-alias")" 'system alias reads the same owned plist'

    # Normalizing the system prefix must not resolve any later symlink or `..`.
    ln -s "${root}/DerivedData/Watch.app" "${root}/DerivedData/linked-app"
    ln -s "$plist" "${root}/DerivedData/linked.plist"
    for spelling in canonical tmp; do
        for path in \
            "${root}/DerivedData/linked-app/Info.plist" \
            "${root}/DerivedData/linked.plist" \
            "${root}/DerivedData/../DerivedData/Watch.app/Info.plist" \
            "${root}-sibling/Info.plist"; do
            [ "$spelling" != tmp ] || path="${path#/private}"
            rc="$(run_capture "${work}/rejected" bash -c '. "$1/Scripts/lib/common.sh"; platform_built_plist "$2"' _ "$fx" "$path")"
            expect_exit 64 "$rc" "$spelling plist path refuses symlinks, traversal and sibling roots: $path"
            expect_absent "$(cat "${work}/rejected")" '"fixture":"owned"' 'rejected path does not expose plist contents'
        done
    done
    ln -s "$root" "${work}/arbitrary-alias"
    rc="$(run_capture "${work}/arbitrary-alias.txt" bash -c '. "$1/Scripts/lib/common.sh"; platform_built_plist "$2"' _ "$fx" "${work}/arbitrary-alias/DerivedData/Watch.app/Info.plist")"
    expect_exit 64 "$rc" 'an arbitrary alias to the owned root is refused'
}

case_watch_simulator() {
    local fx="${SELFTEST_DIR}/watch-sim" work="${SELFTEST_DIR}/watch-sim-work" rc id token
    fixture_watch "$fx" "$work"
    cat >> "${fx}/Config/project.env" <<'CONFIG'
SIMULATOR_MODE="managed"
SIMULATOR_DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-8-41mm"
SIMULATOR_RUNTIME="com.apple.CoreSimulator.SimRuntime.watchOS-26-5"
CONFIG
    mv "${STUB_BIN}/xcrun" "${STUB_BIN}/xcrun-base"
    cat > "${STUB_BIN}/xcrun" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
[ "$1" = simctl ] || exec "${here}/xcrun-base" "$@"
shift
printf '%s\n' "$*" >> "${here}/simcalls"
case "$1" in
    list) cat "${here}/inventory.json" ;;
    create)
        id="$(uuidgen)"
        jq --arg name "$2" --arg type "$3" --arg runtime "$4" --arg id "$id" '.devices[$runtime] = [{name:$name,deviceTypeIdentifier:$type,udid:$id,isAvailable:true,state:"Shutdown"}]' "${here}/inventory.json" > "${here}/next.json"
        mv "${here}/next.json" "${here}/inventory.json"
        printf '%s\n' "$id" ;;
    *) exit 64 ;;
esac
STUB
    chmod +x "${STUB_BIN}/xcrun"
    cat > "${STUB_BIN}/inventory.json" <<'JSON'
{"devicetypes":[{"identifier":"com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-8-41mm"}],"runtimes":[{"identifier":"com.apple.CoreSimulator.SimRuntime.watchOS-26-5","isAvailable":true,"supportedDeviceTypes":[]}],"devices":{}}
JSON
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/incompatible" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 69 "$rc" 'installed but incompatible Watch type/runtime refuses setup'
    expect_absent "$(cat "${STUB_BIN}/simcalls")" create 'incompatibility is diagnosed before device creation'
    jq '.runtimes[0].supportedDeviceTypes=.devicetypes' "${STUB_BIN}/inventory.json" > "${work}/inventory"
    cp "${work}/inventory" "${STUB_BIN}/inventory.json"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/setup" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 0 "$rc" 'managed Watch is prepared'
    id="$(jq -r .udid "${work}/setup")"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/reuse" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 0 "$rc" 'managed Watch setup is repeatable'
    expect_same "$id" "$(jq -r .udid "${work}/reuse")" 'existing Watch UDID is retained'
    expect_same "platform=watchOS Simulator,id=$id" "$(jq -r .destination "${work}/reuse")" 'context uses Watch platform and owned UDID'
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/env" "${fx}/Scripts/simulator.sh" run -- printenv IOSAI_SIMULATOR_DESTINATION)"
    expect_exit 0 "$rc" 'reserved tool gets Watch context'
    expect_same "platform=watchOS Simulator,id=$id" "$(cat "${work}/env")" 'exported destination matches JSON context'
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/lease" "${fx}/Scripts/simulator.sh" acquire --pid "$$")"
    expect_exit 0 "$rc" 'Watch session can be reserved'
    token="$(jq -r .token "${work}/lease")"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/busy" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 75 "$rc" 'Watch gate respects an active lease'
    "${fx}/Scripts/simulator.sh" release "$token" >/dev/null
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/fast" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 0 "$rc" 'managed Watch gate uses the same owned device'
    fixture_commit_unchecked "$fx" 'Managed Watch fixture'
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release" fixture_release "$fx")"
    expect_exit 0 "$rc" 'managed Watch release permits its physical device build'
    expect_contains "$(cat "${work}/release")" "platform=watchOS Simulator,id=$id" 'managed release tests the owned Watch'
    expect_contains "$(cat "${work}/release")" 'generic/platform=watchOS' 'managed release builds the Watch device SDK'
    cp "${fx}/Config/project.env" "${work}/before-escape"
    sed 's/^FAST_TEST_ARGUMENTS=.*/FAST_TEST_ARGUMENTS="-destination platform=iOS,other-device"/' "${fx}/Config/project.env" > "${work}/escape"
    cp "${work}/escape" "${fx}/Config/project.env"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/escape-log" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 64 "$rc" 'Watch gate rejects a redirected managed destination'
    cp "${work}/before-escape" "${fx}/Config/project.env"
    jq '.runtime="com.apple.CoreSimulator.SimRuntime.iOS-26-5"' "${fx}/.iosai-local/simulator.json" > "${work}/changed-binding"
    cp "${work}/changed-binding" "${fx}/.iosai-local/simulator.json"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/binding" "${fx}/Scripts/simulator.sh" context)"
    expect_exit 65 "$rc" 'a stale binding from another platform is refused'
    expect_same "$(cat "${work}/changed-binding")" "$(cat "${fx}/.iosai-local/simulator.json")" 'stale binding is preserved for diagnosis'
}

case_simulator_isolation() {
    require_tools jq perl
    local fx="${SELFTEST_DIR}/sim-a" other="${SELFTEST_DIR}/sim-b" work="${SELFTEST_DIR}/sim-work"
    fixture_product "$fx" "$work"
    local stub="$STUB_BIN" rc first second token candidate out
    cat >> "${fx}/Config/project.env" <<'CONFIG'
SIMULATOR_MODE="managed"
SIMULATOR_DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-17"
SIMULATOR_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
CONFIG
    fixture_copy "$other"
    cp "${fx}/Config/project.env" "${other}/Config/project.env"
    mv "${stub}/xcrun" "${stub}/xcrun-result"
    cat > "${stub}/xcrun" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
if [ "$1" != simctl ]; then exec "${here}/xcrun-result" "$@"; fi
shift
printf '%s\n' "$*" >> "${here}/calls"
case "$1" in
    list) cat "${here}/inventory.json" ;;
    create)
        id="$(uuidgen)"
        jq --arg name "$2" --arg type "$3" --arg runtime "$4" --arg id "$id" \
            '.devices[$runtime] += [{udid:$id,name:$name,deviceTypeIdentifier:$type,isAvailable:true,state:"Shutdown"}]' \
            "${here}/inventory.json" > "${here}/next.json"
        mv "${here}/next.json" "${here}/inventory.json"
        printf '%s\n' "$id" ;;
    boot|shutdown)
        state=Booted; [ "$1" != shutdown ] || state=Shutdown
        jq --arg id "$2" --arg state "$state" \
            '.devices |= with_entries(.value |= map(if .udid == $id then .state=$state else . end))' \
            "${here}/inventory.json" > "${here}/next.json"
        mv "${here}/next.json" "${here}/inventory.json" ;;
    io) : > "$4" ;;
    bootstatus|install|launch) : ;;
    *) exit 64 ;;
esac
STUB
    chmod +x "${stub}/xcrun"
    cat > "${stub}/inventory.json" <<'JSON'
{"devicetypes":[{"identifier":"com.apple.CoreSimulator.SimDeviceType.iPhone-17"}],"runtimes":[{"identifier":"com.apple.CoreSimulator.SimRuntime.iOS-26-5","isAvailable":true,"supportedDeviceTypes":[{"identifier":"com.apple.CoreSimulator.SimDeviceType.iPhone-17"}]}],"devices":{"com.apple.CoreSimulator.SimRuntime.iOS-26-5":[]}}
JSON
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/missing" "${fx}/Scripts/simulator.sh" context)"
    expect_exit 69 "$rc" 'unprepared managed context fails without creating a simulator'
    expect_absent "$(cat "${stub}/calls")" create 'gates/context do not provision devices'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/setup" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 0 "$rc" 'setup prepares a managed simulator'
    first="$(jq -r .udid "${work}/setup")"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/again" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 0 "$rc" 'setup is idempotent'
    expect_same "$first" "$(jq -r .udid "${work}/again")" 'setup preserves the existing device'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/other" "${other}/Scripts/simulator.sh" setup)"
    expect_exit 0 "$rc" 'another checkout gets a simulator'
    second="$(jq -r .udid "${work}/other")"
    if [ "$first" != "$second" ]; then check pass 'checkout UDIDs are different'; else check fail 'checkout UDIDs collide'; fi
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/boot" "${fx}/Scripts/simulator.sh" boot)"
    expect_exit 0 "$rc" 'owned device boots'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/status" "${fx}/Scripts/simulator.sh" status)"
    expect_exit 0 "$rc" 'status is valid JSON'
    expect_same Booted "$(jq -r .state "${work}/status")" 'status describes the owned device'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/shot" "${fx}/Scripts/simulator.sh" screenshot "${work}/screen.png")"
    expect_exit 0 "$rc" 'screenshot uses the owned device'
    expect_contains "$(cat "${stub}/calls")" "io $first screenshot" 'screenshot targets the exact UDID'

    rc="$(PATH="${stub}:$PATH" run_capture "${work}/lease" "${fx}/Scripts/simulator.sh" acquire --pid "$$")"
    expect_exit 0 "$rc" 'an agent can reserve its whole device session'
    token="$(jq -r .token "${work}/lease")"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/busy" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 75 "$rc" 'a gate cannot enter an active device session'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/other-boot" "${other}/Scripts/simulator.sh" boot)"
    expect_exit 0 "$rc" 'another checkout keeps working while the first is reserved'
    "${fx}/Scripts/simulator.sh" release "$token" >/dev/null
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/fast" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 0 "$rc" 'managed fast gate passes after release'
    expect_contains "$(cat "${work}/fast")" "id=$first" 'gate uses the bound destination'

    rc="$(PATH="${stub}:$PATH" STUB_BUILD_FAIL=1 run_capture "${work}/build-failure" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 1 "$rc" 'a failed build preserves its failure code'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/released" "${fx}/Scripts/simulator.sh" acquire --pid "$$")"
    expect_exit 0 "$rc" 'gate failure releases its checkout/device leases'
    "${fx}/Scripts/simulator.sh" release "$(jq -r .token "${work}/released")" >/dev/null
    PATH="${stub}:$PATH" "${fx}/Scripts/simulator.sh" run -- bash -c \
        'touch "$1"; sleep 1' _ "${work}/run-ready" > "${work}/interrupted" 2>&1 &
    local runner=$! attempt=0
    while [ ! -f "${work}/run-ready" ] && [ "$attempt" -lt 100 ]; do
        sleep 0.1; attempt=$((attempt + 1))
    done
    kill -TERM "$runner"
    rc=0; wait "$runner" || rc=$?
    expect_exit 143 "$rc" 'interrupted synchronous tool reports its signal'
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/after-signal" "${fx}/Scripts/simulator.sh" acquire --pid "$$")"
    expect_exit 0 "$rc" 'interrupted tool releases leases after the child finishes'
    "${fx}/Scripts/simulator.sh" release "$(jq -r .token "${work}/after-signal")" >/dev/null
    cp "${fx}/Config/project.env" "${work}/config"
    sed 's/^FAST_TEST_ARGUMENTS=.*/FAST_TEST_ARGUMENTS="-destination platform=iOS,other-device"/' \
        "${work}/config" > "${fx}/Config/project.env"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/escape" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 64 "$rc" 'extra test arguments cannot redirect the managed destination'
    cp "${work}/config" "${fx}/Config/project.env"
    rc="$(run_capture "${work}/configure" "${fx}/Scripts/configure-project.sh" --force \
        --project App/Fixture.xcodeproj --scheme Fixture --distribution internal \
        --simulator-device-type com.apple.CoreSimulator.SimDeviceType.iPhone-17 \
        --simulator-runtime com.apple.CoreSimulator.SimRuntime.iOS-26-5)"
    expect_exit 0 "$rc" 'new product configuration defaults to managed mode'
    expect_contains "$(cat "${fx}/Config/project.env")" 'SIMULATOR_MODE="managed"' 'managed default is persisted'
    cp "${work}/config" "${fx}/Config/project.env"
    cp "${fx}/.iosai-local/simulator.json" "${work}/binding"
    rc="$(run_capture "${work}/clean-artifacts" "${fx}/Scripts/clean-artifacts.sh")"
    expect_exit 0 "$rc" 'artifact cleanup succeeds with local simulator state'
    rc="$(run_capture "${work}/clean-cache" "${fx}/Scripts/clean-derived-data.sh")"
    expect_exit 0 "$rc" 'cache cleanup succeeds with local simulator state'
    expect_same "$(cat "${work}/binding")" "$(cat "${fx}/.iosai-local/simulator.json")" 'both cleanup commands preserve the binding'
    mv "${fx}/.iosai-local" "${work}/local-state"
    ln -s "${work}/local-state" "${fx}/.iosai-local"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/symlink" "${fx}/Scripts/simulator.sh" setup)"
    expect_exit 64 "$rc" 'setup refuses symlinked local simulator state'
    rm "${fx}/.iosai-local"
    mv "${work}/local-state" "${fx}/.iosai-local"

    # The publishing checkout owns local state even when source is a read-only SHA.
    fixture_commit_unchecked "$fx" 'Managed simulator fixture'
    candidate="$(git -C "$fx" rev-parse HEAD)"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/candidate" "${fx}/Scripts/verify-milestone.sh" M00 --candidate "$candidate")"
    expect_exit 0 "$rc" 'immutable milestone resolves caller-owned simulator state'
    expect_contains "$(cat "${work}/candidate")" "id=$first" 'immutable candidate keeps the caller UDID'
    expect_contains "$(cat "${work}/candidate")" "VERIFIED_COMMIT=${candidate}" 'candidate evidence names the exact SHA'

    # A copied manifest must never grant a second checkout the first device.
    cp "${other}/.iosai-local/simulator.json" "${work}/other-binding"
    cp "${fx}/.iosai-local/simulator.json" "${other}/.iosai-local/simulator.json"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/copied" "${other}/Scripts/simulator.sh" context)"
    expect_exit 65 "$rc" 'copied local state cannot cross checkout ownership'
    cp "${work}/other-binding" "${other}/.iosai-local/simulator.json"
    cp "${stub}/inventory.json" "${work}/inventory"
    jq --arg id "$first" '.devices |= with_entries(.value |= map(select(.udid != $id)))' \
        "${work}/inventory" > "${stub}/inventory.json"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/deleted" "${fx}/Scripts/verify-fast.sh")"
    expect_exit 69 "$rc" 'deleted device fails without selecting the other project device'
    cp "${work}/inventory" "${stub}/inventory.json"
    jq '.runtimes[0].isAvailable=false' "${work}/inventory" > "${stub}/inventory.json"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/runtime" "${fx}/Scripts/simulator.sh" context)"
    expect_exit 69 "$rc" 'unavailable runtime fails before using a device'
    cp "${work}/inventory" "${stub}/inventory.json"
    jq '.runtime="com.apple.CoreSimulator.SimRuntime.iOS-99-0"' "${fx}/.iosai-local/simulator.json" > "${work}/mismatch"
    cp "${work}/mismatch" "${fx}/.iosai-local/simulator.json"
    rc="$(PATH="${stub}:$PATH" run_capture "${work}/mismatch-out" "${fx}/Scripts/simulator.sh" context)"
    expect_exit 65 "$rc" 'binding/runtime mismatch is refused'
    expect_absent "$(cat "${stub}/calls")" 'shutdown all' 'no global shutdown is issued'
    expect_absent "$(cat "${stub}/calls")" 'erase' 'no erase is issued'
}

case_simulator_leases() {
    require_tools jq perl
    local work="${SELFTEST_DIR}/leases" helper="${IOSAI_ROOT}/Scripts/lib/lease.pl"
    mkdir -p "$work"
    local key="self-test:${work}" rc token child a b
    # Competing acquire calls have exactly one winner, even with the same owner PID.
    (set +e; perl "$helper" acquire "$$" "$work" "$key" > "${work}/a" 2>&1; echo "$?" > "${work}/a.rc") & a=$!
    (set +e; perl "$helper" acquire "$$" "$work" "$key" > "${work}/b" 2>&1; echo "$?" > "${work}/b.rc") & b=$!
    wait "$a" || true; wait "$b" || true
    expect_same '0 75 ' "$(cat "${work}/a.rc" "${work}/b.rc" | sort -n | tr '\n' ' ')" 'concurrent lease acquisition has exactly one winner'
    if [ "$(cat "${work}/a.rc")" = 0 ]; then token="$(jq -r .token "${work}/a")"; else token="$(jq -r .token "${work}/b")"; fi
    rc="$(TZ=Pacific/Honolulu LC_ALL=C run_capture "${work}/timezone" perl "$helper" acquire "$$" "$work" "$key")"
    expect_exit 75 "$rc" 'a different timezone cannot steal a live lease'
    perl "$helper" release "$token" >/dev/null
    sleep 30 & child=$!
    perl "$helper" acquire "$child" "$work" "$key" > "${work}/child"
    kill -TERM "$child"; wait "$child" 2>/dev/null || true
    rc="$(run_capture "${work}/recovered" perl "$helper" acquire "$$" "$work" "$key")"
    expect_exit 0 "$rc" 'a terminated owner is recovered without a timeout'
    token="$(jq -r .token "${work}/recovered")"
    perl "$helper" release "$token" >/dev/null
    rc="$(run_capture "${work}/dead" perl "$helper" acquire "$child" "$work" "$key")"
    expect_exit 64 "$rc" 'a dead PID cannot acquire a lease'
    # Test atomic acquisition of the desktop plus a checkout with private test keys.
    perl "$helper" acquire "$$" "$work" "${key}:desktop" > "${work}/desktop"
    token="$(jq -r .token "${work}/desktop")"
    rc="$(run_capture "${work}/blocked" perl "$helper" acquire "$$" other "${key}:checkout" "${key}:desktop")"
    expect_exit 75 "$rc" 'desktop contention rejects the entire resource set'
    rc="$(run_capture "${work}/free" perl "$helper" acquire "$$" other "${key}:checkout")"
    expect_exit 0 "$rc" 'failed multi-resource acquire leaves no partial checkout lease'
    perl "$helper" release "$(jq -r .token "${work}/free")" >/dev/null
    perl "$helper" release "$token" >/dev/null
}

case_config_parser() {
    local fx="${SELFTEST_DIR}/config-parser"
    local work="${SELFTEST_DIR}/config-parser-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local marker="${work}/EXECUTED"
    printf 'touch "%s"\n' "$marker" > "${work}/probe.sh"
    chmod +x "${work}/probe.sh"

    printf '  # comment indented by two spaces\n' >> "${fx}/Config/project.env"
    local comment_rc
    comment_rc="$(run_capture "${work}/comment.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$comment_rc" "a configuration comment may be indented by two spaces"
    git -C "$fx" checkout -q -- Config/project.env

    local name line rc out
    # The retired_* probes are the archive keys that configured the automatic
    # `xcodebuild archive` step this template no longer performs. The allowlist is
    # what retires them: absent from IOSAI_CONFIG_KEYS, a leftover line in someone's
    # Config/project.env is refused by name rather than silently ignored, which is
    # the difference between a stale setting and a setting that quietly does nothing.
    for name in ex_fail bash_env lowercase unknown duplicate internal_root \
                retired_enable_archive retired_archive_required \
                retired_archive_waiver retired_archive_path; do
        case "$name" in
            ex_fail)       line='EX_FAIL="0"' ;;
            bash_env)      line="BASH_ENV=\"${work}/probe.sh\"" ;;
            lowercase)     line='scheme="sneaky"' ;;
            unknown)       line='NOT_A_REAL_KEY="x"' ;;
            duplicate)     line='SCHEME="second"' ;;
            internal_root) line="IOSAI_ROOT=\"${fx}\"" ;;
            retired_enable_archive)   line='ENABLE_ARCHIVE="true"' ;;
            retired_archive_required) line='RELEASE_ARCHIVE_REQUIRED="true"' ;;
            retired_archive_waiver)   line='ARCHIVE_WAIVER_REASON="stale"' ;;
            retired_archive_path)     line='ARCHIVE_PATH=".artifacts/release/X.xcarchive"' ;;
        esac
        git -C "$fx" checkout -q -- Config/project.env
        printf '%s\n' "$line" >> "${fx}/Config/project.env"
        rc="$(run_capture "${work}/out.txt" "${fx}/Scripts/verify-static.sh")"
        out="$(cat "${work}/out.txt")"
        expect_exit 65 "$rc" "config rejects ${name}"
        expect_contains "$out" "Config/project.env:" "config names the offending file and line for ${name}"
    done
    git -C "$fx" checkout -q -- Config/project.env

    if [ -e "$marker" ]; then
        check fail "BASH_ENV was executed by a child process"
    else
        check pass "no configuration value was executed"
    fi
}

case_push_is_synchronization() {
    local fx="${SELFTEST_DIR}/push-sync"
    local work="${SELFTEST_DIR}/push-sync-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local bare; bare="$(fixture_bare_remote "$fx")"

    # This commit is deliberately unverified and statically invalid. Transport
    # still succeeds because push is storage/synchronization, not certification.
    printf 'TBD placeholder\n<<<<<<< HEAD\n' > "${fx}/App/Broken.swift"
    fixture_commit_unchecked "$fx" "deliberately unverified fixture commit"

    local rc out after expected
    expected="$(fixture_candidate "$fx")"
    rc="$(run_capture "${work}/push.txt" git -C "$fx" push origin main)"
    out="$(cat "${work}/push.txt")"
    after="$(git -C "$bare" rev-parse --verify --quiet refs/heads/main || printf 'absent')"

    expect_exit 0 "$rc" "an unverified commit may be synchronized"
    expect_same "$expected" "$after" "the bare remote ref moved to the unverified commit"
    expect_absent "$out" "verify-integration" "push ran no lifecycle gate"
    expect_absent "$out" "BUILD SUCCEEDED" "push ran no application build"
    if [ ! -d "${fx}/.artifacts/integration" ]; then
        check pass "push wrote no integration evidence"
    else
        check fail "push wrote integration evidence"
    fi
}

case_dirty_checkout_isolation() {
    local fx="${SELFTEST_DIR}/dirty-isolation"
    local work="${SELFTEST_DIR}/dirty-isolation-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local candidate file="App/Fixture/Fixture.swift"
    candidate="$(fixture_candidate "$fx")"
    git -C "$fx" update-index --assume-unchanged "$file"
    printf 'let hiddenLocalOnly = 2\n' > "${fx}/${file}"
    printf 'App/LocalFix.swift\n' >> "${fx}/.gitignore"
    printf 'let localOnly = 1\n' > "${fx}/App/LocalFix.swift"
    printf 'ordinary untracked bytes\n' > "${fx}/UNTRACKED.local"

    local rc out
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/integration.txt" \
        "${fx}/Scripts/verify-integration.sh" --candidate "$candidate")"
    out="$(cat "${work}/integration.txt")"
    expect_exit 0 "$rc" "dirty, ignored, and index-hidden invoking bytes cannot affect a candidate"
    expect_contains "$out" "VERIFIED_COMMIT=${candidate}" "the exact committed candidate is verified"
    expect_same 'let hiddenLocalOnly = 2' "$(tr -d '\n' < "${fx}/${file}")" \
        "verification did not alter invoking-checkout bytes"
    git -C "$fx" update-index --no-assume-unchanged "$file"
}

case_mid_gate_mutation() {
    local fx="${SELFTEST_DIR}/mid-gate"
    local work="${SELFTEST_DIR}/mid-gate-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    local rc out
    local before after
    before="$(shasum -a 256 "${fx}/App/Fixture/Fixture.swift" | awk '{print $1}')"
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_MUTATE_FILE="App/Fixture/Fixture.swift" \
        run_capture "${work}/out.txt" fixture_integration "$fx")"
    out="$(cat "${work}/out.txt")"
    after="$(shasum -a 256 "${fx}/App/Fixture/Fixture.swift" | awk '{print $1}')"

    # The refusal has to be the snapshot's: a build phase that writes into the source
    # finds it read-only, and the build fails on that write. A bare `rc != 0` also
    # passed for a missing stub, a static failure, or a broken fixture.
    expect_exit 1 "$rc" "the gate rejects a run whose build phase tried to rewrite a source"
    expect_contains "$out" "stub: build phase could not write App/Fixture/Fixture.swift" \
        "the write was refused by the read-only candidate snapshot"
    expect_contains "$out" "integration verification FAILED: Debug build" \
        "the rejection is the build that attempted the write"
    expect_same "$before" "$after" "the invoking checkout was never mutated"
    expect_absent "$out" "VERIFIED_COMMIT=" "no commit was reported as verified"
}

case_immutable_candidate() {
    local fx="${SELFTEST_DIR}/immutable-candidate"
    local work="${SELFTEST_DIR}/immutable-candidate-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    local first second short rc out latest report
    first="$(fixture_candidate "$fx")"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/missing.txt" \
        "${fx}/Scripts/verify-integration.sh")"
    expect_exit 64 "$rc" "missing integration candidate is a usage error"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/milestone-missing.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "milestone candidate is optional in clean current-HEAD mode"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release-missing.txt" \
        "${fx}/Scripts/verify-release.sh")"
    expect_exit 64 "$rc" "missing release candidate is a usage error"
    expect_absent "$(cat "${work}/release-missing.txt")" 'VERDICT=' \
        "an invalid release invocation prints no verdict token, as AI/WORKFLOW.md says"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ref.txt" \
        "${fx}/Scripts/verify-integration.sh" --candidate HEAD)"
    expect_exit 64 "$rc" "symbolic candidate refs are rejected"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/milestone-ref.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00 --candidate HEAD)"
    expect_exit 64 "$rc" "milestone rejects a symbolic candidate ref"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release-ref.txt" \
        "${fx}/Scripts/verify-release.sh" --candidate HEAD)"
    expect_exit 65 "$rc" "release rejects a symbolic candidate as NOT_READY"
    expect_contains "$(cat "${work}/release-ref.txt")" 'VERDICT=NOT_READY' \
        "the invalid release candidate has the policy verdict"
    short="$(git -C "$fx" rev-parse --short "$first")"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/short.txt" \
        "${fx}/Scripts/verify-integration.sh" --candidate "$short")"
    expect_exit 64 "$rc" "abbreviated candidate SHAs are rejected"
    # The release gate answers the same mistake with its policy verdict, and
    # AI/WORKFLOW.md's exit table now says so rather than promising 64.
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release-short.txt" \
        "${fx}/Scripts/verify-release.sh" --candidate "$short")"
    expect_exit 65 "$rc" "release refuses an abbreviated candidate as NOT_READY"
    expect_contains "$(cat "${work}/release-short.txt")" 'VERDICT=NOT_READY' \
        "the abbreviated release candidate carries the documented verdict"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/unknown.txt" \
        "${fx}/Scripts/verify-integration.sh" --candidate 0000000000000000000000000000000000000000)"
    expect_exit 65 "$rc" "an unknown full SHA is a verification error"

    printf 'let secondCandidate = 2\n' > "${fx}/App/Fixture/Fixture.swift"
    fixture_commit_unchecked "$fx" "second candidate"
    second="$(fixture_candidate "$fx")"
    printf 'dirty invoking bytes\n' >> "${fx}/App/Fixture/Fixture.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/non-head.txt" \
        "${fx}/Scripts/verify-integration.sh" --candidate "$first")"
    out="$(cat "${work}/non-head.txt")"
    expect_exit 0 "$rc" "a non-HEAD candidate verifies from a dirty checkout"
    expect_contains "$out" "VERIFIED_COMMIT=${first}" "console names the exact non-HEAD candidate"
    expect_absent "$out" "VERIFIED_COMMIT=${second}" "invoking HEAD is not substituted"
    latest="$(cat "${fx}/.artifacts/integration/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:** \`${first}\`" "report names the supplied candidate"
    expect_contains "$report" "**VERIFIED_COMMIT:** \`${first}\`" "success evidence is exact-SHA bound"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/milestone-non-head.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00 --candidate "$first")"
    out="$(cat "${work}/milestone-non-head.txt")"
    expect_exit 0 "$rc" "milestone verification accepts the explicit non-HEAD candidate"
    expect_contains "$out" "VERIFIED_COMMIT=${first}" "milestone success names the exact non-HEAD candidate"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release-non-head.txt" \
        "${fx}/Scripts/verify-release.sh" --candidate "$first" --print-candidate)"
    out="$(cat "${work}/release-non-head.txt")"
    expect_exit 0 "$rc" "release identity resolves for the explicit non-HEAD candidate"
    expect_contains "$out" "CANDIDATE_COMMIT=${first}" "release identity names the exact non-HEAD candidate"

    # A PASSING gate must be quiet. The read-only probe deliberately fails, and
    # for a while the shell printed that failure because the redirections were
    # ordered `> "$probe" 2>/dev/null` — the truncation error escaped before
    # stderr was silenced. A green run that prints filesystem errors teaches
    # people to read past filesystem errors.
    local clean="${SELFTEST_DIR}/immutable-quiet"
    local clean_work="${SELFTEST_DIR}/immutable-quiet-work"
    fixture_product "$clean" "$clean_work"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${clean_work}/quiet.txt" fixture_integration "$clean")"
    out="$(cat "${clean_work}/quiet.txt")"
    expect_exit 0 "$rc" "a healthy product repository passes integration verification"
    expect_absent "$out" "Permission denied" "a passing gate prints no raw filesystem error"
    expect_absent "$out" "iosai-write-probe" "the write probe leaves no diagnostic behind"

    # ---- A matching HEAD is not the same as BEING that commit ----------------
    #
    # assert_immutable_candidate_root tested two things: HEAD equals the candidate,
    # and the source root is unwritable. A read-only checkout satisfies both while
    # holding modified tracked files. An audit built exactly that, passed a separate
    # writable clone as the evidence root, and got a successful readiness verdict,
    # and a report asserting **VERIFIED_COMMIT** together with "read-only detached
    # worktree materialised from the candidate commit" — for a source carrying a
    # line that commit does not contain. A gate's account of what it verified has to
    # be true, so the source must now also be clean.
    local forged="${SELFTEST_DIR}/forged-candidate-source"
    local forged_evidence="${SELFTEST_DIR}/forged-candidate-evidence"
    local forged_work="${SELFTEST_DIR}/forged-candidate-work"
    local forged_sha gate
    mkdir -p "$forged_work"
    fixture_product "$forged" "$forged_work"
    forged_sha="$(fixture_candidate "$forged")"
    git clone -q "$forged" "$forged_evidence"
    printf 'let notInTheCandidate = true\n' >> "${forged}/App/Fixture/Fixture.swift"
    chmod -R a-w "$forged"
    for gate in verify-release verify-integration; do
        rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${forged_work}/${gate}.txt" \
            "${forged}/Scripts/${gate}.sh" --candidate "$forged_sha" \
            --immutable-evidence-root "$forged_evidence")"
        out="$(cat "${forged_work}/${gate}.txt")"
        if [ "$rc" = "0" ]; then
            check fail "${gate}.sh certified a source that is not the candidate"
        else
            check pass "${gate}.sh refuses a source that is not the candidate (exit ${rc})"
        fi
        # The REASON, not merely a non-zero exit. A release run with no completed
        # final workflow is NOT_READY anyway, so "it refused" would have passed against
        # the defect this case exists to catch — it did, when this assertion was
        # only about the exit code.
        expect_contains "$out" "not this commit's content" \
            "${gate}.sh refuses because the source is not the candidate's content"
        expect_absent "$out" "READY_FOR_HUMAN" "${gate}.sh claims no readiness for unverified bytes"
        expect_absent "$out" "VERIFIED_COMMIT" "${gate}.sh publishes no verified SHA for unverified bytes"
    done
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${forged_work}/milestone.txt" \
        "${forged}/Scripts/verify-milestone.sh" M00 --candidate "$forged_sha" \
        --immutable-evidence-root "$forged_evidence")"
    out="$(cat "${forged_work}/milestone.txt")"
    if [ "$rc" = "0" ]; then
        check fail "verify-milestone.sh certified a source that is not the candidate"
    else
        check pass "verify-milestone.sh refuses a source that is not the candidate (exit ${rc})"
    fi
    expect_contains "$out" "not this commit's content" \
        "verify-milestone.sh refuses because the source is not the candidate's content"
    expect_absent "$out" "VERIFIED_COMMIT" \
        "verify-milestone.sh publishes no verified SHA for unverified bytes"
    # Restore write access so the suite's own cleanup can remove the fixture.
    chmod -R u+w "$forged"
}

case_repository_boundary() {
    local work="${SELFTEST_DIR}/repository-boundary-work"
    mkdir -p "$work"
    local outside="${work}/External.xcodeproj"
    mkdir -p "$outside"
    printf '// external\n' > "${outside}/project.pbxproj"

    local kind fx value rc out
    for kind in absolute parent symlink source_symlink workspace_reference; do
        fx="${SELFTEST_DIR}/repository-${kind}"
        fixture_product "$fx" "${work}/${kind}"
        case "$kind" in
            absolute)
                value="$outside"
                sed "s|^PROJECT_PATH=.*|PROJECT_PATH=\"${value}\"|" "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
                mv "${fx}/Config/project.env.new" "${fx}/Config/project.env" ;;
            parent)
                mkdir -p "${SELFTEST_DIR}/External.xcodeproj"
                printf '// parent external\n' > "${SELFTEST_DIR}/External.xcodeproj/project.pbxproj"
                sed 's|^PROJECT_PATH=.*|PROJECT_PATH="../External.xcodeproj"|' "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
                mv "${fx}/Config/project.env.new" "${fx}/Config/project.env" ;;
            symlink)
                rm -rf "${fx}/App/Fixture.xcodeproj"
                ln -s "$outside" "${fx}/App/Fixture.xcodeproj" ;;
            source_symlink)
                ln -s "${outside}/project.pbxproj" "${fx}/App/Fixture/External.swift" ;;
            workspace_reference)
                rm -rf "${fx}/App/Fixture.xcodeproj"
                mkdir -p "${fx}/App/Fixture.xcworkspace"
                printf '<Workspace><FileRef location="absolute:%s"></FileRef></Workspace>\n' "$outside" \
                    > "${fx}/App/Fixture.xcworkspace/contents.xcworkspacedata"
                sed -e 's|^PROJECT_PATH=.*|PROJECT_PATH=""|' \
                    -e 's|^WORKSPACE_PATH=.*|WORKSPACE_PATH="App/Fixture.xcworkspace"|' \
                    "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
                mv "${fx}/Config/project.env.new" "${fx}/Config/project.env" ;;
        esac
        fixture_commit_unchecked "$fx" "configure ${kind} boundary attack"
        rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/${kind}.txt" fixture_integration "$fx")"
        out="$(cat "${work}/${kind}.txt")"
        if [ "$rc" = "0" ]; then
            check fail "${kind} project boundary attack passed"
        else
            check pass "${kind} project boundary attack rejected (exit ${rc})"
        fi
        expect_absent "$out" "VERIFIED_COMMIT=" "${kind} attack produced no verified label"
    done
}

# Workspace manifests must transitively enforce the project boundary.
case_workspace_reference_closure() {
    local fx="${SELFTEST_DIR}/workspace-closure" work="${SELFTEST_DIR}/workspace-closure-work"
    local workspace project rc probe
    fixture_product "$fx" "$work"
    workspace="${fx}/App/Fixture.xcworkspace"
    project="${fx}/App/Modules & Shared/Inner.xcodeproj"
    mkdir -p "$workspace" "$project"
    workspace="$(cd "$workspace" && pwd -P)"
    printf '// contained project\n' > "${project}/project.pbxproj"
    cat > "${workspace}/contents.xcworkspacedata" <<'XML'
<?xml version="1.0"?>
<Workspace version="1.0"><Group location="group:Modules &amp; Shared"><FileRef location="group:Inner.xcodeproj"/></Group></Workspace>
XML
    cp "${workspace}/contents.xcworkspacedata" "${work}/workspace.base"
    rc="$(run_capture "${work}/clean.txt" bash -c '. "$1"; validate_build_defining_references "$2"' _ \
        "${fx}/Scripts/lib/common.sh" "$workspace")"
    expect_exit 0 "$rc" "nested workspace groups resolve XML entities and paths with spaces"
    for probe in absolute parent quoted malformed namespace dtd cycle missing unknown; do
        cp "${work}/workspace.base" "${workspace}/contents.xcworkspacedata"
        printf '// contained project\n' > "${project}/project.pbxproj"
        case "$probe" in
            absolute) printf 'path = /tmp/uncommitted.swift; sourceTree = "<absolute>";\n' > "${project}/project.pbxproj" ;;
            parent) printf 'path = ../../outside.swift; sourceTree = "<group>";\n' > "${project}/project.pbxproj" ;;
            quoted) printf '"path" = "/tmp/uncommitted.swift"; "sourceTree" = "<absolute>";\n' > "${project}/project.pbxproj" ;;
            malformed) printf '<Workspace><FileRef\n' > "${workspace}/contents.xcworkspacedata" ;;
            namespace) printf '<Workspace xmlns="urn:unknown"><FileRef location="absolute:/tmp/Outside.xcodeproj"/></Workspace>\n' > "${workspace}/contents.xcworkspacedata" ;;
            dtd) printf '<!DOCTYPE Workspace SYSTEM "file:///tmp/external.dtd"><Workspace/>\n' > "${workspace}/contents.xcworkspacedata" ;;
            cycle) printf '<Workspace><FileRef location="group:Fixture.xcworkspace"/></Workspace>\n' > "${workspace}/contents.xcworkspacedata" ;;
            missing) printf '<Workspace><FileRef location="group:Missing.xcodeproj"/></Workspace>\n' > "${workspace}/contents.xcworkspacedata" ;;
            unknown) printf '<Workspace><FileRef location="absolute:/tmp/Outside.xcodeproj"/></Workspace>\n' > "${workspace}/contents.xcworkspacedata" ;;
        esac
        rc="$(run_capture "${work}/${probe}.txt" bash -c '. "$1"; validate_build_defining_references "$2"' _ \
            "${fx}/Scripts/lib/common.sh" "$workspace")"
        expect_exit 65 "$rc" "${probe} workspace reference fails closed"
    done
    cp "${work}/workspace.base" "${workspace}/contents.xcworkspacedata"
    printf 'path = /tmp/uncommitted.swift; sourceTree = "<absolute>";\n' > "${project}/project.pbxproj"
    sed -e 's|^PROJECT_PATH=.*|PROJECT_PATH=""|' -e 's|^WORKSPACE_PATH=.*|WORKSPACE_PATH="App/Fixture.xcworkspace"|' \
        "${fx}/Config/project.env" > "${work}/config.new"
    cp "${work}/config.new" "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" "workspace refers transitively to external source"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/gate.txt" fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "the actual milestone gate rejects the transitive external source"
    expect_absent "$(cat "${work}/gate.txt")" 'VERIFIED_COMMIT=' "external source receives no verified identity"
}

case_resume_milestone() {
    local fx="${SELFTEST_DIR}/resume" work="${SELFTEST_DIR}/resume-work" rc state
    fixture_template "$fx" "$work"
    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** DONE/' "${fx}/AI/milestones/M00-template-bootstrap.md" > "${work}/M00.done"
    cp "${work}/M00.done" "${fx}/AI/milestones/M00-template-bootstrap.md"
    append_only_write_milestone "${fx}/AI/milestones/M01-new.md" M01 PLANNED M00 'New work'
    for state in IN_PROGRESS REVIEW; do
        append_only_write_milestone "${fx}/AI/milestones/M02-active.md" M02 "$state" M00 'Interrupted work'
        rc="$(run_capture "${work}/${state}.txt" "${fx}/Scripts/project-status.sh" next)"
        expect_exit 0 "$rc" "${state} milestone can resume"
        expect_contains "$(cat "${work}/${state}.txt")" 'M02 — Interrupted work' "${state} resumes before an earlier ready PLANNED milestone"
        expect_absent "$(cat "${work}/${state}.txt")" 'M01 — New work' "no second milestone starts during ${state}"
    done
    append_only_write_milestone "${fx}/AI/milestones/M02-active.md" M02 IN_PROGRESS M01 'Interrupted work'
    rc="$(run_capture "${work}/dependency.txt" "${fx}/Scripts/project-status.sh" next)"
    expect_exit 0 "$rc" "unfinished active dependency is reported"
    expect_contains "$(cat "${work}/dependency.txt")" 'none —' "active work with incomplete dependencies cannot be bypassed"
    append_only_write_milestone "${fx}/AI/milestones/M02-active.md" M02 IN_PROGRESS M00 'Interrupted work'
    append_only_write_milestone "${fx}/AI/milestones/M01-new.md" M01 REVIEW M00 'Second active work'
    rc="$(run_capture "${work}/ambiguous.txt" "${fx}/Scripts/project-status.sh" next)"
    expect_exit 65 "$rc" "multiple active milestones fail closed"
    append_only_write_milestone "${fx}/AI/milestones/M01-new.md" M01 PLANNED M00 'New work'
    append_only_write_milestone "${fx}/AI/milestones/M02-active.md" M02 BLOCKED M00 'Human decision'
    sed 's/^\*\*Current milestone:\*\* .*/**Current milestone:** M02/' "${fx}/AI/PROJECT_STATUS.md" > "${work}/status.new"
    cp "${work}/status.new" "${fx}/AI/PROJECT_STATUS.md"
    rc="$(run_capture "${work}/blocked.txt" "${fx}/Scripts/project-status.sh" next)"
    expect_exit 0 "$rc" "blocked current work is reported"
    expect_contains "$(cat "${work}/blocked.txt")" 'none — current work is BLOCKED' "a restart never resolves a human blocker"
}

case_site_extractor_failure() {
    local fx="${SELFTEST_DIR}/site-extractor" work="${SELFTEST_DIR}/site-extractor-work" rc
    fixture_template "$fx" "$work"
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-site.sh")"
    expect_exit 0 "$rc" "valid site links pass the real extractor"
    cp "${fx}/Web/public/index.html" "${work}/index.base"
    printf '\n<a href="/missing-route/">Broken fixture link</a>\n' >> "${fx}/Web/public/index.html"
    rc="$(run_capture "${work}/broken.txt" "${fx}/Scripts/verify-site.sh")"
    expect_exit 65 "$rc" "a broken link fails with the real extractor"
    cp "${work}/index.base" "${fx}/Web/public/index.html"
    mkdir -p "${work}/fault-bin"
    cat > "${work}/fault-bin/grep" <<'STUB'
#!/usr/bin/env bash
if [ "${1:-}" = -o ] && [ "${2:-}" = 'href="/[^"]*"' ]; then exit 2; fi
exec /usr/bin/grep "$@"
STUB
    chmod +x "${work}/fault-bin/grep"
    rc="$(PATH="${work}/fault-bin:$PATH" run_capture "${work}/fault.txt" "${fx}/Scripts/verify-site.sh")"
    expect_exit 65 "$rc" "href extractor exit 2 is a failed scan"
    expect_contains "$(cat "${work}/fault.txt")" 'could not scan internal links' "the failed scanner is identified"
    expect_absent "$(cat "${work}/fault.txt")" 'every internal link resolves' "failed extraction never claims a clean link set"
}

case_supported_appearances() {
    local fx="${SELFTEST_DIR}/appearances" work="${SELFTEST_DIR}/appearances-work" record rc
    fixture_product "$fx" "$work"
    fixture_write_polish_record "$fx" M01 internal
    record="$(cd "$fx" && pwd -P)/AI/audits/M01-final-polish.md"
    cp "$record" "${work}/record.base"
    sed 's/^- REL-702 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-702 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=AI\/DESIGN.md approves dark-only appearance/' \
        "${work}/record.base" > "$record"
    rc="$(run_capture "${work}/dark.txt" bash -c '. "$1"; validate_final_polish_coverage "$2" M01 internal' _ "${fx}/Scripts/lib/common.sh" "$record")"
    expect_exit 0 "$rc" "approved dark-only product can complete all supported appearance coverage"
    sed 's/^- REL-701 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-701 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=AI\/DESIGN.md approves light-only appearance/' \
        "${work}/record.base" > "$record"
    rc="$(run_capture "${work}/light.txt" bash -c '. "$1"; validate_final_polish_coverage "$2" M01 internal' _ "${fx}/Scripts/lib/common.sh" "$record")"
    expect_exit 0 "$rc" "approved light-only product can complete supported appearance coverage"
    sed 's/^- REL-702 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-702 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=required simulator is unavailable/' \
        "${work}/record.base" > "$record"
    rc="$(run_capture "${work}/unavailable.txt" bash -c '. "$1"; validate_final_polish_coverage "$2" M01 internal' _ "${fx}/Scripts/lib/common.sh" "$record")"
    expect_exit 1 "$rc" "an unavailable environment still blocks appearance coverage"
    expect_contains "$(cat "${work}/unavailable.txt")" 'REL-702 INAPPLICABLE requires' "the refusal is for missing appearance evidence"
    sed 's/^- REL-604 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-604 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=dark-only product/' \
        "${work}/record.base" > "$record"
    rc="$(run_capture "${work}/contrast.txt" bash -c '. "$1"; validate_final_polish_coverage "$2" M01 internal' _ "${fx}/Scripts/lib/common.sh" "$record")"
    expect_exit 1 "$rc" "contrast cannot be waived in a supported appearance"
    expect_contains "$(cat "${work}/contrast.txt")" 'REL-604 does not permit INAPPLICABLE' "the refusal enforces mandatory contrast"
}

case_human_checklist_binding() {
    local fx="${SELFTEST_DIR}/human-checklist" work="${SELFTEST_DIR}/human-checklist-work" rc sha file probe
    fixture_product "$fx" "$work"
    sha="$(fixture_candidate "$fx")"
    file="${fx}/.artifacts/release-checklists/${sha}/checklist.md"
    rc="$(run_capture "${work}/new.txt" bash -c '. "$1"; prepare_human_release_checklist "$2" internal "1.0 (1) fixture"' _ "${fx}/Scripts/lib/common.sh" "$sha")"
    expect_exit 0 "$rc" "human checklist is created for the exact candidate"
    expect_same 3 "$(cat "${work}/new.txt")" "all human steps begin pending"
    cp "$file" "${work}/base"
    for probe in sha channel duplicate missing empty unknown; do
        case "$probe" in
            sha) sed 's/^\*\*Candidate commit:\*\* .*/**Candidate commit:** 0000000000000000000000000000000000000000/' "${work}/base" > "$file" ;;
            channel) sed 's/^\*\*Distribution channel:\*\* .*/**Distribution channel:** app-store/' "${work}/base" > "$file" ;;
            duplicate) cat "${work}/base" > "$file"; printf -- '- HUMAN-01 | OUTCOME=PENDING | EVIDENCE=-\n' >> "$file" ;;
            missing) grep -v '^- HUMAN-02' "${work}/base" > "$file" ;;
            empty) sed 's/OUTCOME=PENDING/OUTCOME=VERIFIED/g' "${work}/base" > "$file" ;;
            unknown) sed 's/OUTCOME=PENDING/OUTCOME=APPROVED/g' "${work}/base" > "$file" ;;
        esac
        cp "$file" "${work}/mutated"
        rc="$(run_capture "${work}/${probe}.txt" bash -c '. "$1"; prepare_human_release_checklist "$2" internal "1.0 (1) fixture"' _ "${fx}/Scripts/lib/common.sh" "$sha")"
        expect_exit 1 "$rc" "${probe} human checklist evidence fails validation"
        expect_same "$(cat "${work}/mutated")" "$(cat "$file")" "invalid ${probe} evidence is preserved, never overwritten"
    done
    sed 's/OUTCOME=PENDING | EVIDENCE=-/OUTCOME=VERIFIED | EVIDENCE=who=Fixture human; date=2026-09-28; result=fixture observation/g' "${work}/base" > "$file"
    rc="$(run_capture "${work}/complete.txt" bash -c '. "$1"; prepare_human_release_checklist "$2" internal "1.0 (1) fixture"' _ "${fx}/Scripts/lib/common.sh" "$sha")"
    expect_exit 0 "$rc" "completed human evidence is accepted for the same candidate"
    expect_same 0 "$(cat "${work}/complete.txt")" "completed evidence reports no pending steps"
}

case_hostile_environment() {
    local work="${SELFTEST_DIR}/hostile-environment-work"
    mkdir -p "$work"

    local fx="${SELFTEST_DIR}/hostile-product" rc out
    fixture_product "$fx" "${work}/product"
    rc="$(PATH="${STUB_BIN}:$PATH" TEMPLATE_REPOSITORY=true PROJECT_PATH="/outside/Hostile.xcodeproj" \
        IOSAI_SELFTEST=1 run_capture "${work}/product.txt" fixture_integration "$fx")"
    out="$(cat "${work}/product.txt")"
    expect_exit 0 "$rc" "hostile ambient project configuration is ignored"
    expect_contains "$out" "VERIFIED_COMMIT=" "committed product configuration still verifies"

    fx="${SELFTEST_DIR}/hostile-incomplete"
    fixture_template "$fx" "${work}/incomplete"
    printf 'SCHEME="Fixture"\n' > "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" "remove mode and container configuration"
    rc="$(TEMPLATE_REPOSITORY=true IOSAI_SELFTEST=1 \
        run_capture "${work}/incomplete.txt" fixture_integration "$fx")"
    if [ "$rc" = "0" ]; then
        check fail "ambient template mode repaired an incomplete committed configuration"
    else
        check pass "incomplete committed configuration stayed invalid under hostile ambient values (exit ${rc})"
    fi

    fx="${SELFTEST_DIR}/hostile-selftest"
    fixture_template "$fx" "${work}/selftest"
    printf '#!/usr/bin/env bash\nexit 1\n' > "${fx}/Scripts/self-test.sh"
    chmod +x "${fx}/Scripts/self-test.sh"
    fixture_commit_unchecked "$fx" "make mandatory self-test fail"
    rc="$(IOSAI_SELFTEST=1 run_capture "${work}/selftest.txt" fixture_integration "$fx")"
    out="$(cat "${work}/selftest.txt")"
    if [ "$rc" = "0" ]; then
        check fail "forged self-test state bypassed the mandatory suite"
    else
        check pass "forged self-test state did not bypass the mandatory suite (exit ${rc})"
    fi
    expect_contains "$out" "integration verification FAILED: template self-test" "self-test failure remained visible"
}

case_git_environment_isolation() {
    local fx="${SELFTEST_DIR}/git-env-product" work="${SELFTEST_DIR}/git-env-work"
    local other="${SELFTEST_DIR}/git-env-other" rc out sha foreign_sha gate
    fixture_product "$fx" "$work"
    git clone -q --no-hardlinks "$fx" "$other"
    git -C "$other" config user.name 'Self Test'
    git -C "$other" config user.email selftest@example.invalid
    printf 'foreign repository\n' > "${other}/foreign.txt"
    fixture_commit_unchecked "$other" "distinguish the foreign repository"
    foreign_sha="$(fixture_candidate "$other")"
    sha="$(fixture_candidate "$fx")"

    printf '// uncommitted source\n' >> "${fx}/App/Fixture/Fixture.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/control.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "the dirty-source control refuses milestone verification"
    rc="$(PATH="${STUB_BIN}:$PATH" GIT_DIR="${other}/.git" GIT_WORK_TREE="$other" \
        GIT_INDEX_FILE="${other}/.git/index" run_capture "${work}/dirty.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/dirty.txt")"
    expect_exit 65 "$rc" "foreign Git context cannot hide this checkout's dirty source"
    expect_contains "$out" 'App/Fixture/Fixture.swift' "the refusal names the actual dirty file"
    expect_absent "$out" 'VERIFIED_COMMIT=' "dirty source receives no verified commit"
    git -C "$fx" checkout -q -- App/Fixture/Fixture.swift

    rc="$(PATH="${STUB_BIN}:$PATH" GIT_DIR="${other}/.git" GIT_WORK_TREE="$other" \
        GIT_INDEX_FILE="${other}/.git/index" run_capture "${work}/clean.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/clean.txt")"
    expect_exit 0 "$rc" "a clean checkout works under inherited Git variables"
    expect_contains "$out" "VERIFIED_COMMIT=${sha}" "the gate certifies its own checkout"
    expect_absent "$out" "$foreign_sha" "foreign identity never reaches the report"

    # These candidates do not exist in the foreign repository. The outer and
    # detached inner gate processes must both use the requested checkout.
    fixture_prepare_release_ready "$fx"
    sha="$(fixture_candidate "$fx")"
    for gate in integration release; do
        rc="$(PATH="${STUB_BIN}:$PATH" GIT_DIR="${other}/.git" GIT_WORK_TREE="$other" \
            GIT_COMMON_DIR="${other}/.git" GIT_INDEX_FILE="${other}/.git/index" \
            run_capture "${work}/${gate}.txt" "${fx}/Scripts/verify-${gate}.sh" --candidate "$sha")"
        out="$(cat "${work}/${gate}.txt")"
        expect_exit 0 "$rc" "${gate} materializes its own candidate under inherited Git variables"
        expect_contains "$out" "$sha" "${gate} records the requested full SHA"
        expect_absent "$out" "$foreign_sha" "${gate} never certifies the foreign HEAD"
    done
    rc="$(PATH="${STUB_BIN}:$PATH" GIT_DIR="${other}/.git" GIT_WORK_TREE="$other" \
        GIT_INDEX_FILE="${other}/.git/index" run_capture "${work}/candidate.txt" \
        "${fx}/Scripts/verify-milestone.sh" M01 --candidate "$sha")"
    expect_exit 0 "$rc" "explicit milestone reproduction also ignores foreign Git context"
    expect_contains "$(cat "${work}/candidate.txt")" "VERIFIED_COMMIT=${sha}" \
        "explicit milestone reproduction records its own candidate"
    expect_same "$foreign_sha" "$(fixture_candidate "$other")" "the foreign repository is untouched"
    rc="$(run_capture "${work}/foreign-status.txt" git -C "$other" status --porcelain)"
    expect_exit 0 "$rc" "the foreign repository's cleanliness can still be read"
    expect_same "" "$(cat "${work}/foreign-status.txt")" "the foreign index and worktree remain clean"

    git -C "$fx" config core.worktree "$other"
    rc="$(run_capture "${work}/redirect.txt" "${fx}/Scripts/verify-static.sh")"
    git -C "$fx" config --unset core.worktree
    expect_exit 65 "$rc" "a configured worktree redirection is refused"
    expect_contains "$(cat "${work}/redirect.txt")" 'Git worktree root does not match' \
        "the refusal identifies the mismatched checkout"
}

# A pipe into a reader that stops early is a race under `set -o pipefail`: the
# producer can still have a write pending, takes SIGPIPE, and pipefail reports 141
# for a lookup that succeeded. An audit measured 9 wrong answers in 80,000 such
# checks, and one failed this suite with "does not document the key" for a key the
# configuration example documents. verify-template.sh now refuses the shape, and
# line_in_list replaces it; both are held here.
case_pipeline_early_exit() {
    local fx="${SELFTEST_DIR}/pipeline-exit"
    local work="${SELFTEST_DIR}/pipeline-exit-work"
    local rc out probe
    mkdir -p "$work"
    fixture_copy "$fx"
    probe="${fx}/Scripts/probe-pipelines.sh"

    # The shipped scripts are clean, or nothing below proves anything.
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped scripts contain no early-exit pipeline"
    expect_contains "$(cat "${work}/clean.txt")" "no pipe feeds a reader that stops before its input ends" \
        "the guard ran over the shipped scripts"

    # One planted line per shape, at known line numbers.
    cat > "$probe" <<'PROBE'
#!/usr/bin/env bash
set -euo pipefail
list="first
second"
if printf '%s\n' "$list" | grep -Fxq first; then :; fi
head_line="$(printf '%s\n' "$list" | head -n1)"
awk_line="$(printf '%s\n' "$list" \
    | awk '$1 == "first" { print; exit }')"
git -C . worktree list --porcelain | grep -q worktree || true
quiet="$(printf '%s\n' "$list" | grep --quiet second || true)"
PROBE
    rc="$(run_capture "${work}/planted.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/planted.txt")"
    expect_exit 65 "$rc" "an early-exit pipeline in a script fails template validation"
    expect_contains "$out" "Scripts/probe-pipelines.sh:5:" "grep -q fed by a multi-line printf is refused"
    expect_contains "$out" "Scripts/probe-pipelines.sh:6:" "head fed by a pipe is refused"
    expect_contains "$out" "Scripts/probe-pipelines.sh:7:" \
        "an awk that exits at a match is refused across a line continuation"
    expect_contains "$out" "Scripts/probe-pipelines.sh:9:" "grep -q fed by another command is refused"
    expect_contains "$out" "Scripts/probe-pipelines.sh:10:" "a long-option quiet grep is refused"

    # The forms that cannot race stay legal, so the guard is not "refuse every pipe".
    cat > "$probe" <<'PROBE'
#!/usr/bin/env bash
set -euo pipefail
list="first
second"
value="first"
if printf '%s' "$value" | grep -Eq '^first$'; then :; fi
found="$(printf '%s\n' "$list" | awk '$1 == "first" && !seen { print; seen = 1 } END { if (!seen) exit 1 }')"
count="$(printf '%s\n' "$list" | grep -c first || true)"
top="$(printf '%s\n' "$list" | sed -n 1p)"
echo "| head -n1 inside a quoted string is not a pipe"
cat <<'TEXT'
printf '%s\n' "$list" | grep -q first
TEXT
# printf '%s\n' "$list" | grep -q first (a comment)
PROBE
    rc="$(run_capture "${work}/safe.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "draining readers, one printf value, quotes, here-documents and comments pass"
    rm -f "$probe"

    # line_in_list is the replacement, so its answer has to be exact.
    out="$(bash -c '. "$1"
        list="alpha
beta.gamma
*"
        line_in_list beta.gamma "$list" && printf "exact "
        line_in_list beta "$list" || printf "whole-line "
        line_in_list "b*" "$list" || printf "literal-glob "
        line_in_list "*" "$list" && printf "literal-star "
        line_in_list "" "$list" || printf "no-empty-line "
        line_in_list alpha "" || printf "empty-list "' _ "${fx}/Scripts/lib/common.sh" 2>&1)"
    expect_same "exact whole-line literal-glob literal-star no-empty-line empty-list " "$out" \
        "line_in_list matches whole lines literally and never an empty line"
}

# Some committed files only look like secrets: Firebase's GoogleService-Info.plist
# carries a client key Google designs to ship in the app, and a sign-in model is
# naturally called Credentials.swift. Each used to fail every gate with a hint to
# "exempt the single file" that named no mechanism. The exemption list excuses one
# exact path from one rule, and refuses any entry that could excuse more.
case_credential_allowlist() {
    local fx="${SELFTEST_DIR}/credential-allowlist"
    local work="${SELFTEST_DIR}/credential-allowlist-work"
    local rc out key token allowlist i line label message entry
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    allowlist="${fx}/Config/credential-scan-allowlist.txt"
    cp "$allowlist" "${work}/allowlist.base"

    # Assembled at run time so this file is not itself secret-shaped.
    key="AIza"; i=0
    while [ "$i" -lt 35 ]; do key="${key}B"; i=$((i + 1)); done
    token="ghp_"; i=0
    while [ "$i" -lt 36 ]; do token="${token}C"; i=$((i + 1)); done

    mkdir -p "${fx}/App/Demo/Login"
    printf '<plist><dict><key>API_KEY</key><string>%s</string></dict></plist>\n' "$key" \
        > "${fx}/App/Demo/GoogleService-Info.plist"
    printf 'struct Credentials { let email: String }\n' > "${fx}/App/Demo/Login/Credentials.swift"

    rc="$(run_capture "${work}/unlisted.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/unlisted.txt")"
    expect_exit 65 "$rc" "an unlisted client key and credential-named file fail static verification"
    expect_contains "$out" "App/Demo/GoogleService-Info.plist:1: google-api-key" "the client key is reported"
    expect_contains "$out" "App/Demo/Login/Credentials.swift: filename" "the credential-named file is reported"
    expect_contains "$out" "Config/credential-scan-allowlist.txt" \
        "the refusal names the list that can excuse a legitimate file"

    printf '%s\n' \
        'App/Demo/GoogleService-Info.plist | google-api-key | Firebase client key restricted to the bundle ID | 2099-01-01' \
        'App/Demo/Login/Credentials.swift | filename | sign-in form model that holds no secret | 2099-01-01' \
        >> "$allowlist"
    rc="$(run_capture "${work}/listed.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/listed.txt")"
    expect_exit 0 "$rc" "listed exact files pass static verification"
    expect_contains "$out" "App/Demo/GoogleService-Info.plist: google-api-key" "the excused client key is named"
    expect_contains "$out" "App/Demo/Login/Credentials.swift: filename" "the excused file name is named"

    # One path, one rule: every other rule and every other path still applies.
    printf '<!-- %s -->\n' "$token" >> "${fx}/App/Demo/GoogleService-Info.plist"
    rc="$(run_capture "${work}/second-rule.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "an excused file is still scanned for every other rule"
    expect_contains "$(cat "${work}/second-rule.txt")" "App/Demo/GoogleService-Info.plist:2: github-token" \
        "the provider token inside the excused file is reported"
    printf '<plist><dict><key>API_KEY</key><string>%s</string></dict></plist>\n' "$key" \
        > "${fx}/App/Demo/GoogleService-Info.plist"
    cp "${fx}/App/Demo/GoogleService-Info.plist" "${fx}/App/Demo/Copy-Info.plist"
    rc="$(run_capture "${work}/other-path.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "the same key at an unlisted path still fails"
    expect_contains "$(cat "${work}/other-path.txt")" "App/Demo/Copy-Info.plist:1: google-api-key" \
        "the unlisted copy is reported"
    rm -f "${fx}/App/Demo/Copy-Info.plist"

    # An entry that could excuse too much is refused when it is written, and an
    # invalid entry is never honoured by the scan.
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        label="${line%%::*}"; line="${line#*::}"
        message="${line%%::*}"; entry="${line#*::}"
        cp "${work}/allowlist.base" "$allowlist"
        printf '%s\n' "$entry" >> "$allowlist"
        rc="$(run_capture "${work}/invalid.txt" "${fx}/Scripts/verify-template.sh")"
        out="$(cat "${work}/invalid.txt")"
        expect_exit 65 "$rc" "template validation refuses ${label}"
        expect_contains "$out" "$message" "the refusal of ${label} says why"
    done <<'ENTRIES'
a glob::is a pattern, not a path::App/Demo/*.plist | google-api-key | glob | 2099-01-01
a private key rule::the private-key rule can never be exempted::App/Demo/key.txt | private-key | wrong | 2099-01-01
a provider token rule::the github-token rule can never be exempted::App/Demo/key.txt | github-token | wrong | 2099-01-01
an unknown rule::unknown rule 'made-up'::App/Demo/key.txt | made-up | wrong | 2099-01-01
signing material by name::can never be exempted::App/Demo/release.p12 | filename | wrong | 2099-01-01
a name no pattern matches::matches no credential filename pattern::App/Demo/Notes.swift | filename | wrong | 2099-01-01
an entry without a reason::has no reason::App/Demo/GoogleService-Info.plist | google-api-key |  | 2099-01-01
an expired entry::expired on 2001-01-01::App/Demo/GoogleService-Info.plist | google-api-key | lapsed | 2001-01-01
an absolute path::is not a plain repository-relative path::/tmp/x.plist | google-api-key | outside | 2099-01-01
a missing field::expected 'path | rule | reason | expiry'::App/Demo/x.plist | google-api-key | reason only
ENTRIES

    cp "${work}/allowlist.base" "$allowlist"
    printf '%s\n' \
        'App/Demo/Login/Credentials.swift | filename | sign-in form model | 2099-01-01' \
        'App/Demo/Login/Credentials.swift | filename | sign-in form model | 2099-01-01' >> "$allowlist"
    rc="$(run_capture "${work}/duplicate.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "template validation refuses a duplicate entry"
    expect_contains "$(cat "${work}/duplicate.txt")" "is listed twice for filename" "the duplicate is named"

    cp "${work}/allowlist.base" "$allowlist"
    printf '%s\n' 'App/Demo/GoogleService-Info.plist | google-api-key | lapsed | 2001-01-01' >> "$allowlist"
    rc="$(run_capture "${work}/expired-scan.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "an expired entry excuses nothing"
    expect_contains "$(cat "${work}/expired-scan.txt")" "App/Demo/GoogleService-Info.plist:1: google-api-key" \
        "the client key behind an expired entry is still reported"

    cp "${work}/allowlist.base" "$allowlist"
    rm -f "${fx}/App/Demo/GoogleService-Info.plist" "${fx}/App/Demo/Login/Credentials.swift"
}

# A nested checkout is another repository's working tree: a Claude Code worktree
# under .claude/worktrees/, a submodule, a cloned dependency. Repository-wide scans
# used to walk into them, so another checkout's uncommitted work failed this one's
# static verification while its own `git status` was clean.
case_nested_checkout_scans() {
    local fx="${SELFTEST_DIR}/nested-checkout"
    local work="${SELFTEST_DIR}/nested-checkout-work"
    local rc out token nested i
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    token="ghp_"; i=0
    while [ "$i" -lt 36 ]; do token="${token}C"; i=$((i + 1)); done

    nested="${fx}/.claude/worktrees/nested"
    printf '.claude/worktrees/\nvendor-repo/\n' >> "${fx}/.git/info/exclude"
    git -C "$fx" worktree add -q -b claude/nested "$nested" HEAD
    printf '<<<<<<< HEAD\nmine\n=======\ntheirs\n>>>>>>> other\n' > "${nested}/AI/notes.md"
    printf 'token: %s\n' "$token" > "${nested}/leak.md"
    printf 'API=1\n' > "${nested}/.env"
    mkdir -p "${fx}/vendor-repo"
    git -C "${fx}/vendor-repo" init -q
    printf 'token: %s\n' "$token" > "${fx}/vendor-repo/leak.md"
    expect_same "" "$(git -C "$fx" status --porcelain)" \
        "the nested checkouts leave this checkout's own status clean"

    rc="$(run_capture "${work}/nested.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/nested.txt")"
    expect_exit 0 "$rc" "another checkout's work inside this one does not fail its static verification"
    expect_absent "$out" ".claude/worktrees" "no file of the nested worktree is reported"
    expect_absent "$out" "vendor-repo" "no file of the embedded repository is reported"

    # Positive control: the same bytes in this checkout still fail.
    cp "${nested}/AI/notes.md" "${fx}/AI/notes-here.md"
    cp "${nested}/leak.md" "${fx}/leak-here.md"
    rc="$(run_capture "${work}/here.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/here.txt")"
    expect_exit 65 "$rc" "the same content in this checkout fails static verification"
    expect_contains "$out" "AI/notes-here.md" "conflict markers in this checkout are still found"
    expect_contains "$out" "leak-here.md:1: github-token" "a token in this checkout is still found"
    rm -f "${fx}/AI/notes-here.md" "${fx}/leak-here.md"

    git -C "$fx" worktree remove --force "$nested"
}

# App/ is the one place a nested repository is refused rather than skipped. Xcode
# creates one when a new project is saved into App/ with "Create Git repository" left
# on, and the scans used to skip every application source beneath it while `make
# static` reported the tree clean. Committed, it becomes a gitlink: a pointer whose
# files no candidate snapshot contains, so no gate could have verified them.
case_nested_app_repository() {
    local fx="${SELFTEST_DIR}/nested-app" work="${SELFTEST_DIR}/nested-app-work"
    local rc out token i inner candidate
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    token="ghp_"; i=0
    while [ "$i" -lt 36 ]; do token="${token}D"; i=$((i + 1)); done

    rc="$(run_capture "${work}/baseline.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the product fixture passes static verification to begin with"

    # 1. The shape Xcode leaves behind, before anything is committed.
    inner="${fx}/App/Inner"
    mkdir -p "${inner}/Inner"
    git -C "$inner" init -q
    printf 'let token = "%s"\n' "$token" > "${inner}/Inner/Keys.swift"
    rc="$(run_capture "${work}/inner.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/inner.txt")"
    expect_exit 65 "$rc" "a Git repository nested under App/ fails static verification"
    expect_contains "$out" "App/ contains another Git repository" "the refusal names the shape"
    if line_in_list '           App/Inner' "$out"; then
        check pass "the refusal names the nested repository itself"
    else
        check fail "the refusal does not list App/Inner as the nested repository"
    fi
    expect_contains "$out" "App/Inner/Inner/Keys.swift:1: github-token" \
        "the application's files are still scanned beneath the nested .git"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/fast.txt" "${fx}/Scripts/verify-fast.sh")"
    out="$(cat "${work}/fast.txt")"
    expect_exit 65 "$rc" "a build gate refuses the nested repository as well"
    expect_contains "$out" "App/ contains another Git repository" "the build gate names the same cause"
    rm -rf "$inner"

    # Control: a SwiftPM dependency clone inside an ignored .build directory is a
    # build product, not the developer's repository, and is not reported.
    mkdir -p "${fx}/App/Packages/Kit/.build/checkouts/Dep"
    git -C "${fx}/App/Packages/Kit/.build/checkouts/Dep" init -q
    rc="$(run_capture "${work}/swiftpm.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/swiftpm.txt")"
    expect_exit 0 "$rc" "a SwiftPM checkout under an ignored .build directory passes"
    expect_absent "$out" "another Git repository" "nothing is reported for the build product"
    rm -rf "${fx}/App/Packages"

    # 2. Committed, it is a gitlink. The candidate snapshot holds an empty directory
    #    where the files should be, so only the index can say what happened.
    mkdir -p "${inner}/Inner"
    git -C "$inner" init -q
    printf 'let inner = 1\n' > "${inner}/Inner/Inner.swift"
    git -C "$inner" add -A
    git -C "$inner" -c user.name="Self Test" -c user.email="selftest@example.invalid" \
        commit -q -m "inner repository"
    fixture_commit_unchecked "$fx" "commit the nested repository as a gitlink" 2>/dev/null
    expect_same "160000" "$(git -C "$fx" ls-files --stage -- App/Inner | awk '{ print $1 }')" \
        "the fixture recorded App/Inner as a gitlink"
    candidate="$(fixture_candidate "$fx")"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/candidate.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00 --candidate "$candidate")"
    out="$(cat "${work}/candidate.txt")"
    expect_exit 1 "$rc" "a candidate recording a gitlink under App/ fails verification"
    expect_contains "$out" "App/ records a submodule" "the snapshot's refusal names the gitlink"
    expect_absent "$out" "VERIFIED_COMMIT" "no commit is verified while its files live elsewhere"

    # In the working tree too, once the inner .git is gone and only the pointer remains.
    rm -rf "${inner}/.git"
    rc="$(run_capture "${work}/gitlink.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/gitlink.txt")"
    expect_exit 65 "$rc" "a recorded gitlink under App/ fails static verification"
    expect_contains "$out" "App/ records a submodule" "the refusal names the recorded pointer"
}

# Machine-read fields are lines outside fenced code blocks, and an audit milestone's
# prompt is one of the real audit methods. The milestone template shows its optional
# fields inside fences, and a milestone written from it verbatim used to be verified
# as Final Product Polish; a misspelled domain prompt selected a domain that owns no
# rows, so an empty coverage section passed as complete.
case_fenced_milestone_fields() {
    local fx="${SELFTEST_DIR}/fenced-fields"
    local work="${SELFTEST_DIR}/fenced-fields-work"
    local rc out ms
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    ms="${fx}/AI/milestones"
    sed 's/^\*\*Status:\*\* REVIEW$/**Status:** DONE/' "${ms}/M00-template-bootstrap.md" > "${work}/M00.done"
    cp "${work}/M00.done" "${ms}/M00-template-bootstrap.md"
    printf '**Policy status:** current\n\n# M00 fixture handoff\n\nBootstrap complete.\n' \
        > "${fx}/AI/handoffs/M00-handoff.md"

    sed -e 's/MNN/M01/g' -e 's/^\*\*Depends on:\*\* none$/**Depends on:** M00/' \
        -e 's/^\*\*Status:\*\* PLANNED$/**Status:** REVIEW/' \
        "${fx}/AI/templates/milestone-template.md" > "${ms}/M01-feature.md"
    if ! grep -q '^\*\*Audit prompt:\*\* AI/prompts/final-polish.md$' "${ms}/M01-feature.md"; then
        check fail "the template no longer shows a fenced Audit prompt; this case proves nothing"
        return 0
    fi
    fixture_commit_unchecked "$fx" "M01 written from the template verbatim"

    expect_same "" "$(milestone_field "${ms}/M01-feature.md" 'Audit prompt')" \
        "a field shown inside a fence is not read as the milestone's field"
    expect_same "0" "$(machine_field_count "${ms}/M01-feature.md" 'Audit prompt')" \
        "a fenced example is not counted as a field either"
    expect_same "REVIEW" "$(milestone_field "${ms}/M01-feature.md" 'Status')" \
        "a real field outside the fences is still read"
    rc="$(run_capture "${work}/verbatim-validate.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 0 "$rc" "a milestone carrying the template's fenced examples validates"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/verbatim.txt" \
        "${fx}/Scripts/verify-milestone.sh" M01)"
    out="$(cat "${work}/verbatim.txt")"
    expect_exit 0 "$rc" "it is verified as an ordinary milestone"
    expect_absent "$out" "Final Product Polish record" "it is not mistaken for Final Product Polish"
    expect_absent "$out" "allows no test selector" "a fenced test-argument example is not read as a selector"

    append_only_write_milestone "${ms}/M01-feature.md" M01 REVIEW M00 'UX revalidation audit' \
        '**Audit prompt:** AI/prompts/audit-ux.md
**Audit record:** AI/audits/M01-ux.md'
    printf '# M01 audit\n\n**Policy status:** current\n**Coverage result:** COMPLETE\n**Open P0/P1:** 0\n\n## Coverage\n\nNo rows.\n' \
        > "${fx}/AI/audits/M01-ux.md"
    fixture_commit_unchecked "$fx" "misspelled audit domain"
    rc="$(run_capture "${work}/ux-validate.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "a misspelled domain prompt fails milestone validation"
    expect_contains "$(cat "${work}/ux-validate.txt")" "is not an audit method" "the refusal names the prompt"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ux-milestone.txt" \
        "${fx}/Scripts/verify-milestone.sh" M01)"
    out="$(cat "${work}/ux-milestone.txt")"
    expect_exit 65 "$rc" "the milestone gate refuses a misspelled domain prompt"
    expect_absent "$out" "domain audit coverage complete" "an empty coverage section is never called complete"
    expect_absent "$out" "VERIFIED_COMMIT=" "no commit is verified"
    rm -f "${fx}/AI/audits/M01-ux.md"

    append_only_write_milestone "${ms}/M01-feature.md" M01 REVIEW M00 'Targeted UI audit' \
        '**Audit prompt:** AI/prompts/audit-ui-ux.md
**Audit record:** AI/audits/../escape.md'
    fixture_commit_unchecked "$fx" "audit record path outside AI/audits"
    rc="$(run_capture "${work}/escape.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "an audit record path that leaves AI/audits/ is refused"
    expect_contains "$(cat "${work}/escape.txt")" "must name one file AI/audits/<name>.md" \
        "the refusal names the record rule"

    append_only_write_milestone "${ms}/M01-feature.md" M01 REVIEW M00 'Targeted UI audit' \
        '**Audit prompt:** AI/prompts/audit-ui-ux.md'
    fixture_commit_unchecked "$fx" "audit prompt without a record"
    rc="$(run_capture "${work}/no-record.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "an audit prompt without its record is refused"

    # Positive control: a well-formed targeted audit still verifies.
    append_only_write_milestone "${ms}/M01-feature.md" M01 REVIEW M00 'Targeted UI audit' \
        '**Audit prompt:** AI/prompts/audit-ui-ux.md
**Audit record:** AI/audits/M01-ui-ux.md'
    fixture_write_audit_record "$fx" M01 ui-ux internal
    fixture_commit_unchecked "$fx" "well-formed targeted audit"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/targeted.txt" \
        "${fx}/Scripts/verify-milestone.sh" M01)"
    out="$(cat "${work}/targeted.txt")"
    expect_exit 0 "$rc" "a well-formed targeted audit milestone verifies"
    expect_contains "$out" "domain audit coverage complete (ui-ux, internal)" \
        "its coverage is checked against its own domain"
}

case_test_scope_arguments() {
    local fx="${SELFTEST_DIR}/test-scope"
    local work="${SELFTEST_DIR}/test-scope-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    # Each iteration starts from the pristine config and ends by dropping its own
    # commit. Editing in place and reverting left a stale value behind, which made
    # later iterations pass for the wrong reason.
    cp "${fx}/Config/project.env" "${work}/project.env.pristine"

    set_release_args() {
        sed "s|^RELEASE_TEST_ARGUMENTS=.*|RELEASE_TEST_ARGUMENTS=\"${1}\"|" \
            "${work}/project.env.pristine" > "${fx}/Config/project.env"
        # Committed because the immutable candidate reads committed configuration.
        fixture_commit_unchecked "$fx" "set RELEASE_TEST_ARGUMENTS"
    }

    local arg rc out
    for arg in "-only-testing:FixtureTests" "-skip-testing:CriticalUITests" \
               "-testPlan Smoke" "-only-test-configuration A" \
               "-skip-test-configuration B" "-retry-tests-on-failure" \
               "-test-iterations 3" "-someUnvettedFlag"; do
        set_release_args "$arg"
        rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/out.txt" fixture_integration "$fx")"
        out="$(cat "${work}/out.txt")"
        # Exit 1: static verification now refuses the value, and every static failure
        # reaches this boundary as "automated build/test/static failure". Static run on
        # its own still reports 64 for it — case_static_configuration_validation
        # asserts that. What matters at this boundary is that the value is refused and
        # that nothing was built first.
        expect_exit 1 "$rc" "integration rejects RELEASE_TEST_ARGUMENTS=\"${arg}\""
        # Three refusal messages are legitimate: the scope-changing blocklist, the
        # repetition family (assert_test_args_report_failures), and the allowlist
        # catching an argument nobody vetted. All three name the setting.
        expect_contains "$out" "RELEASE_TEST_ARGUMENTS" \
            "the refusal of '${arg}' names the setting"
        expect_absent "$out" "BUILD SUCCEEDED" "rejected '${arg}' before xcodebuild ran"
        git -C "$fx" reset --hard -q HEAD~1
    done

    # A safe argument still works, so the allowlist is not simply "reject everything".
    set_release_args "-parallel-testing-enabled NO"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/safe.txt" fixture_integration "$fx")"
    out="$(cat "${work}/safe.txt")"
    expect_exit 0 "$rc" "integration accepts a non-scope-affecting argument"
    expect_contains "$out" "VERIFIED_COMMIT=" "and reaches a verified verdict"

    # ---- MILESTONE_TEST_ARGUMENTS -------------------------------------------
    #
    # The milestone gate deliberately permits a NARROWED suite — AI/WORKFLOW.md binds
    # the contract to the exact selector and requires a rationale — so the
    # complete-suite allowlist above must NOT be applied to it wholesale. What it must
    # still refuse is xcodebuild's repetition family. An audit set
    # MILESTONE_TEST_ARGUMENTS="-retry-tests-on-failure" against real Xcode, and a test
    # that failed on its first execution and passed on the retry produced
    # `total=4 passed=4 failed=0` from the .xcresult, exit 0, a published
    # VERIFIED_COMMIT, and a report stating "PASSED milestone verification". The same
    # test without the argument produced failed=1 and failed the gate.
    #
    # STUB_BIN is on PATH for the rejections too: without it, "no BUILD SUCCEEDED"
    # would hold because xcodebuild was absent rather than because the gate refused.
    cp "${fx}/AI/milestones/M00-template-bootstrap.md" "${work}/m00.pristine"

    set_milestone_args() {
        sed "s|^MILESTONE_TEST_ARGUMENTS=.*|MILESTONE_TEST_ARGUMENTS=\"${1}\"|" \
            "${work}/project.env.pristine" > "${fx}/Config/project.env"
        cp "${work}/m00.pristine" "${fx}/AI/milestones/M00-template-bootstrap.md"
        # A non-empty value must be declared by the contract, or
        # validate_milestone_test_scope_contract refuses it for THAT reason and the
        # assertion below would pass for the wrong cause.
        if [ -n "$1" ]; then
            printf '\n**Milestone test arguments:** %s\n**Test scope rationale:** narrowed deliberately by this fixture\n' \
                "$1" >> "${fx}/AI/milestones/M00-template-bootstrap.md"
        fi
        fixture_commit_unchecked "$fx" "set MILESTONE_TEST_ARGUMENTS"
    }

    for arg in "-retry-tests-on-failure" "-test-iterations 2" \
               "-retry-tests-on-failure -test-iterations 2" \
               "-run-tests-until-failure" "-test-iterations=2"; do
        set_milestone_args "$arg"
        # `make static` is the daily command and the optional pre-commit hook, so it
        # keeps the precise unsafe-configuration code.
        rc="$(run_capture "${work}/ms-static.txt" "${fx}/Scripts/verify-static.sh")"
        out="$(cat "${work}/ms-static.txt")"
        expect_exit 64 "$rc" "static rejects MILESTONE_TEST_ARGUMENTS=\"${arg}\""
        expect_contains "$out" "MILESTONE_TEST_ARGUMENTS" \
            "the static refusal of '${arg}' names the setting"
        expect_contains "$out" "whether a failing test is reported as a failure" \
            "the static refusal of '${arg}' names the invariant it protects"
        # The milestone boundary flattens every static failure to exit 1, exactly as it
        # does for RELEASE_TEST_ARGUMENTS above; the template-mode check further down
        # exercises the gate's own refusal and its precise code. What matters here is
        # that the value is refused and that nothing was built.
        rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ms-milestone.txt" \
            "${fx}/Scripts/verify-milestone.sh" M00)"
        out="$(cat "${work}/ms-milestone.txt")"
        expect_exit 1 "$rc" "milestone verification rejects MILESTONE_TEST_ARGUMENTS=\"${arg}\""
        expect_absent "$out" "BUILD SUCCEEDED" "rejected '${arg}' before xcodebuild ran"
        expect_absent "$out" "VERIFIED_COMMIT" "no commit is verified for '${arg}'"
        git -C "$fx" reset --hard -q HEAD~1
    done

    # Contract-bound narrowing is the case the policy supports, and it still works —
    # otherwise this fix would have removed a documented feature.
    set_milestone_args "-only-testing:FixtureTests"
    rc="$(run_capture "${work}/ms-narrow-static.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "static accepts a contract-bound -only-testing milestone selector"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ms-narrow.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/ms-narrow.txt")"
    expect_exit 0 "$rc" "milestone verification accepts a contract-bound -only-testing selector"
    expect_contains "$out" "VERIFIED_COMMIT=" "and reaches a verified verdict"
    git -C "$fx" reset --hard -q HEAD~1

    # And the default — every test in the scheme — is untouched.
    set_milestone_args ""
    rc="$(run_capture "${work}/ms-empty-static.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "static accepts an empty MILESTONE_TEST_ARGUMENTS"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ms-empty.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/ms-empty.txt")"
    expect_exit 0 "$rc" "an empty MILESTONE_TEST_ARGUMENTS remains the accepted default"
    expect_contains "$out" "every test in scheme" "the default scope is reported"
    git -C "$fx" reset --hard -q HEAD~1

    # The generator refuses it as well, so a value every gate rejects never reaches
    # Config/project.env in the first place.
    rc="$(run_capture "${work}/ms-configure.txt" "${fx}/Scripts/configure-project.sh" --simulator-mode explicit \
        --print --project App/Fixture.xcodeproj --scheme Fixture \
        --build-destination 'platform=iOS Simulator,name=Fixture Device' \
        --test-destination 'platform=iOS Simulator,name=Fixture Device' \
        --milestone-test-args '-retry-tests-on-failure')"
    expect_exit 64 "$rc" "configure-project refuses to write a retrying milestone argument"
    rc="$(run_capture "${work}/ms-configure-ok.txt" "${fx}/Scripts/configure-project.sh" --simulator-mode explicit \
        --print --project App/Fixture.xcodeproj --scheme Fixture \
        --build-destination 'platform=iOS Simulator,name=Fixture Device' \
        --test-destination 'platform=iOS Simulator,name=Fixture Device' \
        --milestone-test-args '-only-testing:FixtureTests')"
    expect_exit 0 "$rc" "configure-project still writes a narrowing milestone selector"

    # The milestone gate holds this line itself, not merely through its static stage.
    # Static inspects MILESTONE_TEST_ARGUMENTS in product mode only, so a template-mode
    # repository reaches the gate's own check — and reaches it with the precise exit 64,
    # before the template-mode verdict and before the scope-contract check.
    local tpl="${SELFTEST_DIR}/test-scope-template"
    local tpl_work="${SELFTEST_DIR}/test-scope-template-work"
    fixture_template "$tpl" "$tpl_work"
    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** REVIEW/' \
        "${tpl}/AI/milestones/M00-template-bootstrap.md" > "${tpl_work}/m00.md"
    cp "${tpl_work}/m00.md" "${tpl}/AI/milestones/M00-template-bootstrap.md"
    sed 's|^MILESTONE_TEST_ARGUMENTS=.*|MILESTONE_TEST_ARGUMENTS="-retry-tests-on-failure"|' \
        "${tpl}/Config/project.env" > "${tpl_work}/project.env"
    cp "${tpl_work}/project.env" "${tpl}/Config/project.env"
    fixture_commit_unchecked "$tpl" "template-mode repetition argument"
    rc="$(run_capture "${tpl_work}/milestone.txt" "${tpl}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${tpl_work}/milestone.txt")"
    expect_exit 64 "$rc" "the milestone gate's own check refuses the repetition family"
    expect_contains "$out" "MILESTONE_TEST_ARGUMENTS" "the milestone refusal names the setting"
    expect_absent "$out" "cannot be verified in template mode" \
        "the refusal precedes the template-mode verdict"
}

# The repetition family refused above as ARGUMENTS can be written into the project
# instead. An audit reproduced it against real Xcode: a committed test plan with
# "testRepetitionMode" : "retryOnFailure" and a test that failed its first attempt
# gave total=2 passed=2 failed=0, exit 0, and a published VERIFIED_COMMIT, with
# nothing on the command line at all. make static now reads the committed setting.
case_test_repetition_config() {
    local fx="${SELFTEST_DIR}/test-repetition"
    local work="${SELFTEST_DIR}/test-repetition-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local plan="${fx}/App/Fixture.xctestplan" rc out mode

    # $1: the default mode, or empty for none at all; $2: a per-configuration mode.
    write_test_plan() {
        {
            printf '{\n  "configurations" : [\n    {\n      "id" : "A",\n'
            printf '      "name" : "Configuration 1",\n      "options" : {\n'
            [ -z "${2:-}" ] || printf '        "testRepetitionMode" : "%s"\n' "$2"
            printf '      }\n    }\n  ],\n  "defaultOptions" : {\n'
            [ -z "${1:-}" ] || printf '    "maximumTestRepetitions" : 3,\n    "testRepetitionMode" : "%s"\n' "$1"
            printf '  },\n  "testTargets" : [\n    {\n      "target" : {\n'
            printf '        "containerPath" : "container:Fixture.xcodeproj",\n'
            printf '        "identifier" : "FIXTURETESTS",\n        "name" : "FixtureTests"\n'
            printf '      }\n    }\n  ],\n  "version" : 1\n}\n'
        } > "$plan"
    }

    rc="$(run_capture "${work}/no-plan.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a project with no test plan passes"
    expect_contains "$(cat "${work}/no-plan.txt")" "no test plans or schemes" \
        "a scan with nothing to read says so rather than claiming a clean result"

    write_test_plan ""
    rc="$(run_capture "${work}/plain.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a test plan that sets no repetition passes"
    expect_contains "$(cat "${work}/plain.txt")" "no committed test plan or scheme repeats a failing test" \
        "the scan reports what it read"
    write_test_plan none
    rc="$(run_capture "${work}/none.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "testRepetitionMode none is Xcode's own off and passes"

    for mode in retryOnFailure untilFailure fixedIterations; do
        write_test_plan "$mode"
        rc="$(run_capture "${work}/${mode}.txt" "${fx}/Scripts/verify-static.sh")"
        out="$(cat "${work}/${mode}.txt")"
        expect_exit 65 "$rc" "static refuses a test plan whose default repetition is ${mode}"
        expect_contains "$out" "App/Fixture.xctestplan: testRepetitionMode ${mode}" \
            "the ${mode} refusal names the file and the mode"
        expect_absent "$out" "no committed test plan or scheme repeats" \
            "the ${mode} refusal claims no clean result"
    done

    # A configuration-level setting is the same setting, one level down.
    write_test_plan "" retryOnFailure
    rc="$(run_capture "${work}/per-configuration.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a per-configuration retry setting is refused too"

    # A mention the scan cannot read is refused rather than assumed off.
    write_test_plan ""
    awk '/^  "version" : 1$/ { print "  \"testRepetitionMode\" : 2," } { print }' \
        "$plan" > "${plan}.new"
    mv "${plan}.new" "$plan"
    grep -q '"testRepetitionMode" : 2,' "$plan" \
        || check fail "the unreadable-form plan was not written; the check below proves nothing"
    rc="$(run_capture "${work}/unreadable-value.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a repetition setting in an unreadable form is refused"
    expect_contains "$(cat "${work}/unreadable-value.txt")" "in a form this scan cannot read" \
        "the refusal says the value could not be read"

    # Schemes are read as well, so an attribute there is not the way around the rule.
    rm -f "$plan"
    mkdir -p "${fx}/App/Fixture.xcodeproj/xcshareddata/xcschemes"
    printf '<Scheme>\n   <TestAction\n      testRepetitionMode = "retryOnFailure">\n   </TestAction>\n</Scheme>\n' \
        > "${fx}/App/Fixture.xcodeproj/xcshareddata/xcschemes/Fixture.xcscheme"
    rc="$(run_capture "${work}/scheme.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a scheme attribute that retries failing tests is refused"
    expect_contains "$(cat "${work}/scheme.txt")" "Fixture.xcscheme: testRepetitionMode retryOnFailure" \
        "the scheme refusal names the file and the mode"
    rm -f "${fx}/App/Fixture.xcodeproj/xcshareddata/xcschemes/Fixture.xcscheme"

    # A test plan that cannot be read is an incomplete scan, never a clean one.
    write_test_plan none
    chmod 000 "$plan"
    rc="$(run_capture "${work}/locked.txt" "${fx}/Scripts/verify-static.sh")"
    chmod 644 "$plan"
    out="$(cat "${work}/locked.txt")"
    expect_exit 65 "$rc" "an unreadable test plan fails the scan closed"
    expect_contains "$out" "could not scan App/Fixture.xctestplan for test repetition" \
        "the refusal names the file it could not read"
    expect_absent "$out" "no committed test plan or scheme repeats" \
        "an incomplete scan claims no clean result"

    # And the strict gates refuse it through their static stage, before any build.
    write_test_plan retryOnFailure
    fixture_commit_unchecked "$fx" "commit a retrying test plan"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/milestone.txt" fixture_milestone "$fx" M00)"
    out="$(cat "${work}/milestone.txt")"
    expect_exit 1 "$rc" "milestone verification refuses a committed retrying test plan"
    expect_absent "$out" "BUILD SUCCEEDED" "the retrying test plan is refused before xcodebuild runs"
    expect_absent "$out" "VERIFIED_COMMIT" "no commit is verified with a retrying test plan"
}

case_result_bundle_counts() {
    local fx="${SELFTEST_DIR}/counts"
    local work="${SELFTEST_DIR}/counts-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local summaries="${work}/summaries"
    mkdir -p "$summaries"

    printf '%s\n' '{"totalTestCount":1}' > "${summaries}/total-only.json"
    printf '%s\n' '{"totalTestCount":5,"passedTests":1,"failedTests":0,"skippedTests":0,"expectedFailures":0}' > "${summaries}/inconsistent.json"
    printf '%s\n' '{"totalTestCount":0,"passedTests":0,"failedTests":0,"skippedTests":0,"expectedFailures":0}' > "${summaries}/zero.json"
    printf '%s\n' '{"totalTestCount":"3","passedTests":"3","failedTests":"0","skippedTests":"0"}' > "${summaries}/strings.json"
    printf '%s\n' '{"totalTestCount":3,"passedTests":2,"failedTests":1,"skippedTests":0,"expectedFailures":0}' > "${summaries}/failing.json"
    printf '%s\n' '{"totalTestCount":3,"passedTests":0,"failedTests":0,"skippedTests":3,"expectedFailures":0}' > "${summaries}/all-skipped.json"
    printf '%s\n' '{"totalTestCount":3,"passedTests":2,"failedTests":0,"skippedTests":1,"expectedFailures":0}' > "${summaries}/mixed-skipped.json"
    printf '%s\n' '{"totalTestCount":3,"passedTests":2,"failedTests":0,"skippedTests":0,"expectedFailures":1}' > "${summaries}/consistent.json"

    local name rc out
    for name in total-only inconsistent zero strings; do
        rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/${name}.json" \
            run_capture "${work}/out.txt" fixture_integration "$fx")"
        out="$(cat "${work}/out.txt")"
        expect_exit 70 "$rc" "a ${name} summary is refused as evidence"
        expect_absent "$out" "VERIFIED_COMMIT=" "no verified commit claimed for ${name}"
    done

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/failing.json" \
        run_capture "${work}/out.txt" fixture_integration "$fx")"
    expect_exit 1 "$rc" "a summary reporting a failed test rejects integration"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/all-skipped.json" \
        run_capture "${work}/all-skipped.txt" fixture_integration "$fx")"
    out="$(cat "${work}/all-skipped.txt")"
    expect_exit 1 "$rc" "an all-skipped suite rejects integration verification"
    expect_absent "$out" "VERIFIED_COMMIT=" "no verified commit claimed for all-skipped"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/mixed-skipped.json" \
        run_capture "${work}/mixed-skipped.txt" fixture_integration "$fx")"
    out="$(cat "${work}/mixed-skipped.txt")"
    expect_exit 1 "$rc" "a mandatory mixed-skipped summary rejects integration"
    expect_absent "$out" "VERIFIED_COMMIT=" "no verified commit claimed for mixed-skipped"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/mixed-skipped.json" \
        run_capture "${work}/fast.txt" "${fx}/Scripts/verify-fast.sh")"
    out="$(cat "${work}/fast.txt")"
    expect_exit 0 "$rc" "the fast feedback gate permits and records skipped tests"
    expect_contains "$out" "skipped=1" "fast output makes its skipped count visible"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${summaries}/consistent.json" \
        run_capture "${work}/out.txt" fixture_integration "$fx")"
    out="$(cat "${work}/out.txt")"
    expect_exit 0 "$rc" "consistent counts including an expected failure pass"
    expect_contains "$out" "expectedFailures=1" "the counts are reported in full"
}

case_tool_status() {
    local fx="${SELFTEST_DIR}/tool-status"
    local work="${SELFTEST_DIR}/tool-status-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    local rc out
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_XCRUN_STATUS=42 \
        run_capture "${work}/xcresult.txt" fixture_integration "$fx")"
    out="$(cat "${work}/xcresult.txt")"
    expect_exit 1 "$rc" "valid result JSON with a failing xcresulttool is refused"
    expect_contains "$out" "xcresulttool failed with exit 42" "xcresulttool status is preserved"
    expect_absent "$out" "VERIFIED_COMMIT=" "failed result tooling cannot verify a commit"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SETTINGS_STATUS=42 \
        run_capture "${work}/settings.txt" fixture_release "$fx" --print-candidate)"
    out="$(cat "${work}/settings.txt")"
    expect_exit 1 "$rc" "valid build-settings JSON with failing xcodebuild is refused"
    expect_contains "$out" "showBuildSettings failed with exit 42" "build-settings status is preserved"
    expect_contains "$out" "VERDICT=VERIFICATION_FAILED" "failed settings tooling maps to an automated failure"
}

case_configuration_semantics() {
    local fx="${SELFTEST_DIR}/configuration-semantics"
    local work="${SELFTEST_DIR}/configuration-semantics-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out

    sed 's|^CONFIGURATION_RELEASE=.*|CONFIGURATION_RELEASE="Debug"|' \
        "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
    mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" "make debug and release configurations identical"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/integration.txt" fixture_integration "$fx")"
    out="$(cat "${work}/integration.txt")"
    expect_exit 65 "$rc" "integration verification rejects identical Debug/Release configuration"
    expect_contains "$out" "must be distinct" "the configuration failure names the semantic requirement"

    rc="$(run_capture "${work}/configure.txt" "${fx}/Scripts/configure-project.sh" --simulator-mode explicit \
        --print --project App/Fixture.xcodeproj --scheme Fixture \
        --build-destination 'platform=iOS Simulator,name=Fixture Device' \
        --test-destination 'platform=iOS Simulator,name=Fixture Device' \
        --configuration-debug Debug --configuration-release Debug)"
    expect_exit 64 "$rc" "configure-project refuses to generate identical configurations"

    # An EMPTY mode flag must be rejected, not defaulted. `${VAR:-false}` used to
    # substitute the default for a value that was present but blank, so
    # TEMPLATE_REPOSITORY="" silently chose a mode while "TRUE" and "ture" — the
    # same class of typo — were rejected outright.
    local blank="${SELFTEST_DIR}/configuration-blank-mode"
    local blank_work="${SELFTEST_DIR}/configuration-blank-mode-work"
    fixture_template "$blank" "$blank_work"
    local spelling
    for spelling in '' 'TRUE' 'ture' 'yes' '1'; do
        printf 'TEMPLATE_REPOSITORY="%s"\n' "$spelling" > "${blank}/Config/project.env"
        rc="$(run_capture "${blank_work}/mode.txt" "${blank}/Scripts/verify-static.sh")"
        out="$(cat "${blank_work}/mode.txt")"
        expect_exit 65 "$rc" "TEMPLATE_REPOSITORY=\"${spelling}\" is rejected"
        expect_contains "$out" 'TEMPLATE_REPOSITORY must be "true" or "false"' \
            "TEMPLATE_REPOSITORY=\"${spelling}\" names the allowed values"
    done
    # An ABSENT key still defaults to product mode, which is the strict one.
    printf 'PROJECT_NAME="Fixture"\n' > "${blank}/Config/project.env"
    rc="$(run_capture "${blank_work}/absent.txt" "${blank}/Scripts/verify-static.sh")"
    out="$(cat "${blank_work}/absent.txt")"
    expect_contains "$out" "Repository mode: product" "an absent TEMPLATE_REPOSITORY still defaults to product mode"

    # A rejected configuration must never replace a working one. The generator
    # used to write first and validate second, so a value containing " $ or `
    # left the repository holding a file every gate refuses.
    local atomic="${SELFTEST_DIR}/configuration-atomic"
    local atomic_work="${SELFTEST_DIR}/configuration-atomic-work"
    fixture_product "$atomic" "$atomic_work"
    local before_sum after_sum
    before_sum="$(shasum -a 256 "${atomic}/Config/project.env" | cut -d' ' -f1)"
    rc="$(run_capture "${atomic_work}/dollar.txt" "${atomic}/Scripts/configure-project.sh" --simulator-mode explicit \
        --force --project App/Fixture.xcodeproj --scheme Fixture \
        --build-destination 'platform=iOS Simulator,name=Fixture Device' \
        --test-destination 'platform=iOS Simulator,name=Fixture Device' \
        --name 'Cost $5')"
    out="$(cat "${atomic_work}/dollar.txt")"
    after_sum="$(shasum -a 256 "${atomic}/Config/project.env" | cut -d' ' -f1)"
    expect_exit 65 "$rc" "a value containing a dollar sign is refused"
    expect_contains "$out" "nothing was written" "the refusal says the file was not touched"
    expect_same "$before_sum" "$after_sum" "a rejected configuration left the previous one byte-identical"
    rc="$(run_capture "${atomic_work}/still-valid.txt" "${atomic}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the repository still validates after a refused configuration"
    if ls "${atomic}/Config/".project.env.staged.* >/dev/null 2>&1; then
        check fail "a staging file was left behind in Config/"
    else
        check pass "no staging file was left behind in Config/"
    fi

    local custom="${SELFTEST_DIR}/configuration-custom"
    local custom_work="${SELFTEST_DIR}/configuration-custom-work"
    fixture_product "$custom" "$custom_work"
    sed -e 's|^CONFIGURATION_DEBUG=.*|CONFIGURATION_DEBUG="Development"|' \
        -e 's|^CONFIGURATION_RELEASE=.*|CONFIGURATION_RELEASE="Shipping"|' \
        -e 's|^DISTRIBUTION_CHANNEL=.*|DISTRIBUTION_CHANNEL="app-store"|' \
        "${custom}/Config/project.env" > "${custom}/Config/project.env.new"
    mv "${custom}/Config/project.env.new" "${custom}/Config/project.env"
    fixture_commit_unchecked "$custom" "use distinct custom build configurations"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${custom_work}/release.txt" \
        fixture_release "$custom")"
    out="$(cat "${custom_work}/release.txt")"
    expect_exit 0 "$rc" "distinct custom configurations reach complete release verification"
    expect_contains "$out" "'-configuration' 'Shipping'" "the shipping configuration reaches the release build commands"
}

case_milestone_scope() {
    local fx="${SELFTEST_DIR}/milestone-scope"
    local work="${SELFTEST_DIR}/milestone-scope-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local config="${fx}/Config/project.env"
    local milestone="${fx}/AI/milestones/M00-template-bootstrap.md"
    cp "$config" "${work}/config.base"
    cp "$milestone" "${work}/milestone.base"

    set_milestone_scope() {
        local args="$1" declared="$2" rationale="$3"
        sed "s|^MILESTONE_TEST_ARGUMENTS=.*|MILESTONE_TEST_ARGUMENTS=\"${args}\"|" \
            "${work}/config.base" > "$config"
        cp "${work}/milestone.base" "$milestone"
        printf '\n**Milestone test arguments:** %s\n' "$declared" >> "$milestone"
        printf '**Test scope rationale:** %s\n' "$rationale" >> "$milestone"
        fixture_commit_unchecked "$fx" "set milestone scope contract"
    }

    local rc
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/full.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 0 "$rc" "full-scheme milestone needs no scope-rationale fields"

    set_milestone_scope '-only-testing:FixtureTests' none none
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/mismatch.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "a narrowed suite with mismatched declared arguments fails"

    set_milestone_scope '-only-testing:FixtureTests' '-only-testing:FixtureTests' none
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/empty-reason.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "a narrowed suite without an answered rationale fails"

    set_milestone_scope '-only-testing:FixtureTests' '-only-testing:FixtureTests' 'This bootstrap fixture exercises only its contract target.'
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/narrowed.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 0 "$rc" "an exact narrowed scope with a durable rationale passes"

    set_milestone_scope '' '-only-testing:FixtureTests' 'This reason is now stale.'
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/stale.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "a stale narrowed-scope record fails when config returns to full scheme"
}

case_report_labels() {
    local fx="${SELFTEST_DIR}/report-labels"
    local work="${SELFTEST_DIR}/report-labels-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc latest report

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_BUILD_FAIL=1 \
        run_capture "${work}/push-failed.txt" fixture_integration "$fx")"
    expect_exit 1 "$rc" "failed integration verification writes a failed report"
    latest="$(cat "${fx}/.artifacts/integration/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "failed integration report identifies the candidate"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "failed integration report makes no verified claim"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/push-passed.txt" \
        fixture_integration "$fx")"
    expect_exit 0 "$rc" "successful integration verification completes"
    latest="$(cat "${fx}/.artifacts/integration/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "successful integration report keeps candidate identity"
    expect_contains "$report" "**VERIFIED_COMMIT:**" "successful integration report adds the verified field"

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_BUILD_FAIL=1 \
        run_capture "${work}/milestone-failed.txt" fixture_milestone "$fx" M00)"
    expect_exit 1 "$rc" "failed milestone verification writes a failed report"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "failed milestone report identifies the candidate"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "failed milestone report makes no verified claim"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/milestone-passed.txt" \
        fixture_milestone "$fx" M00)"
    expect_exit 0 "$rc" "successful milestone verification completes"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "successful milestone report keeps candidate identity"
    expect_contains "$report" "**VERIFIED_COMMIT:**" "successful milestone report adds the verified field"

    # A gate that fails through a shared helper after opening its report used to stop
    # the report wherever it was, with no verdict at all. Result-bundle counts that
    # refuse are one such path in the milestone gate.
    printf '%s\n' '{"totalTestCount":3,"passedTests":2,"failedTests":1,"skippedTests":0,"expectedFailures":0}' \
        > "${work}/failing-summary.json"
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_SUMMARY_JSON="${work}/failing-summary.json" \
        run_capture "${work}/milestone-counts.txt" fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "refused result-bundle counts fail milestone verification"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**Verdict:** FAILED" "a milestone report whose counts refused still states a verdict"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "and it claims no verified commit"

    # A configuration refusal after the integration report opened is another.
    sed 's/^SCHEME=.*/SCHEME=""/' "${fx}/Config/project.env" > "${work}/no-scheme.env"
    cp "${work}/no-scheme.env" "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" "drop the scheme"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/integration-no-scheme.txt" \
        fixture_integration "$fx")"
    expect_exit 69 "$rc" "an integration candidate with no scheme is refused"
    latest="$(cat "${fx}/.artifacts/integration/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**Verdict:** FAILED (exit 69" \
        "an integration report that died in a shared helper still states a verdict and its exit"
    git -C "$fx" reset -q --hard HEAD~1

    rc="$(PATH="${STUB_BIN}:$PATH" STUB_BUILD_FAIL=1 \
        run_capture "${work}/release-failed.txt" fixture_release "$fx")"
    expect_exit 1 "$rc" "a failed release gate writes a failed report"
    latest="$(cat "${fx}/.artifacts/release/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "failed release report identifies the candidate"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "failed release report makes no verified claim"

    rm "${fx}/AI/audits/M01-final-polish.md"
    fixture_commit_unchecked "$fx" "remove required audit evidence"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release-blocked.txt" \
        fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "incomplete audit coverage blocks release readiness"
    latest="$(cat "${fx}/.artifacts/release/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**CANDIDATE_COMMIT:**" "blocked release report identifies the candidate"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "blocked release report makes no total-success claim"

}

case_release_verdict_matrix() {
    local fx="${SELFTEST_DIR}/release-matrix"
    local work="${SELFTEST_DIR}/release-matrix-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    local rc out previous_report_dir="" latest report
    assert_new_release_report() {
        local verdict="$1" label="$2"
        if ! latest="$(cat "${fx}/.artifacts/release/latest.txt")"; then
            check fail "${label}: no report pointer was published"
            return
        fi
        if [ -z "$latest" ] || [ "$latest" = "$previous_report_dir" ]; then
            check fail "${label}: no new report directory was published"
        else
            check pass "${label}: a new report directory was published"
        fi
        previous_report_dir="$latest"
        if [ ! -s "${latest}/report.md" ]; then
            check fail "${label}: the new run has no report"
            return
        fi
        report="$(cat "${latest}/report.md")"
        expect_contains "$report" "**VERDICT:** ${verdict}" "${label}: report records its verdict"
        expect_contains "$report" "$(fixture_candidate "$fx")" "${label}: report records its candidate"
    }
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/early.txt" fixture_release_raw "$fx")"
    out="$(cat "${work}/early.txt")"
    expect_exit 65 "$rc" "a candidate before the final audit sequence is not ready"
    expect_contains "$out" "VERDICT=NOT_READY" "the early release attempt has the policy verdict"
    assert_new_release_report NOT_READY early

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/first.txt" fixture_release "$fx")"
    out="$(cat "${work}/first.txt")"
    expect_exit 0 "$rc" "a complete final workflow reaches release readiness"
    expect_contains "$out" "VERDICT=READY_FOR_HUMAN" "the full workflow passing is the success verdict"
    assert_new_release_report READY_FOR_HUMAN first

    # Dirty invoking bytes stay outside the immutable candidate being verified.
    printf '// uncommitted\n' >> "${fx}/App/Fixture/Fixture.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/dirty.txt" \
        fixture_release "$fx")"
    out="$(cat "${work}/dirty.txt")"
    expect_exit 0 "$rc" "a dirty invoking checkout does not contaminate candidate verification"
    expect_contains "$out" "VERDICT=READY_FOR_HUMAN" "the committed candidate remains ready"
    expect_absent "$out" "VERDICT=VERIFICATION_FAILED" "dirty checkout is not treated as candidate failure"
    assert_new_release_report READY_FOR_HUMAN dirty
    git -C "$fx" checkout -q -- App/Fixture/Fixture.swift

    # Build failure.
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_BUILD_FAIL=1 \
        run_capture "${work}/build.txt" fixture_release "$fx")"
    out="$(cat "${work}/build.txt")"
    expect_exit 1 "$rc" "a failed build is exit 1"
    expect_contains "$out" "VERDICT=VERIFICATION_FAILED" "failed build states the automated verdict"
    assert_new_release_report VERIFICATION_FAILED build

    # Test failure.
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_TEST_FAIL=1 \
        run_capture "${work}/test.txt" fixture_release "$fx")"
    expect_exit 1 "$rc" "a failed suite is exit 1"

    assert_new_release_report VERIFICATION_FAILED test

    # An invalid candidate is refused before a verdict exists, so `make release`
    # must expand the code it actually returned. Its legend named only 65/1/69 and
    # glossed 65 as "manual or policy evidence is incomplete" — printed verbatim
    # beneath a FAIL line saying the commit is not in this repository.
    local abbrev legend
    abbrev="$(git -C "$fx" rev-parse --short HEAD)"
    rc="$(cd "$fx" && PATH="${STUB_BIN}:$PATH" make release CANDIDATE="$abbrev" \
        >"${work}/legend.txt" 2>&1; printf '%s' "$?")"
    legend="$(cat "${work}/legend.txt")"
    expect_exit 2 "$rc" "make reports its own exit code for a refused candidate"
    expect_contains "$legend" "must be the full commit SHA" "an abbreviated candidate is refused"
    expect_contains "$legend" "VERDICT=NOT_READY" "an invalid candidate has the readiness verdict"
    expect_contains "$legend" "64 = " "the make legend expands the exit code it can return"
    expect_contains "$legend" "could not be resolved" "the legend describes exit 65 as a readiness failure"

    local template_fx="${SELFTEST_DIR}/release-template-mode"
    fixture_template "$template_fx" "${work}/template"
    rc="$(run_capture "${work}/template.txt" fixture_release "$template_fx")"
    out="$(cat "${work}/template.txt")"
    expect_exit 69 "$rc" "release remains not applicable in template mode"
    expect_contains "$out" "VERDICT=NOT_APPLICABLE_TEMPLATE_MODE" "template mode states its release verdict"
}

case_release_endpoint_failures() {
    local fx="${SELFTEST_DIR}/endpoint-product" work="${SELFTEST_DIR}/endpoint-work"
    local rc out mode sha
    fixture_product "$fx" "$work"
    fixture_prepare_release_ready "$fx"
    printf 'let endpoint = "http://api.example.net/v1"\n' > "${fx}/App/Fixture/Fixture.swift"
    fixture_commit_unchecked "$fx" "plant an insecure endpoint"
    sha="$(fixture_candidate "$fx")"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/control.txt" \
        "${fx}/Scripts/verify-release.sh" --candidate "$sha")"
    expect_exit 1 "$rc" "the readable HTTP control fails release verification"
    expect_contains "$(cat "${work}/control.txt")" 'cleartext http:// endpoint(s)' \
        "the control fails for the planted HTTP endpoint"

    local real_grep
    real_grep="$(command -v grep)"
    cat > "${STUB_BIN}/grep" <<'STUB'
#!/usr/bin/env bash
if [ "${STUB_ENDPOINT_FAILURE:-}" = extract ] && [ "${1:-}" = -oE ] \
    && [ "${2:-}" = 'http://[A-Za-z0-9._:/-]+' ]; then
    exit 2
fi
if [ "${STUB_ENDPOINT_FAILURE:-}" = filter ] && [ "${1:-}" = -vE ]; then
    case "${2:-}" in *'http://'*) exit 2 ;; esac
fi
exec "${STUB_REAL_GREP:?}" "$@"
STUB
    chmod +x "${STUB_BIN}/grep"
    for mode in extract filter; do
        rc="$(PATH="${STUB_BIN}:$PATH" STUB_REAL_GREP="$real_grep" STUB_ENDPOINT_FAILURE="$mode" \
            run_capture "${work}/${mode}.txt" "${fx}/Scripts/verify-release.sh" --candidate "$sha")"
        out="$(cat "${work}/${mode}.txt")"
        expect_exit 1 "$rc" "a failed HTTP ${mode} blocks release verification"
        expect_contains "$out" 'scanner exited 2' "${mode} failure is reported as a scanner error"
        expect_contains "$out" 'VERDICT=VERIFICATION_FAILED' "${mode} failure has no ready verdict"
        expect_absent "$out" 'no cleartext http:// endpoints' "${mode} failure cannot claim a clean scan"
        expect_absent "$out" 'BUILD SUCCEEDED' "${mode} failure stops before building"
    done
    rm -f "${STUB_BIN}/grep"

    # Both legitimate empty outcomes must pass: no HTTP matches, and only
    # deliberately excluded namespace/loopback URLs. A large positive result
    # must also stay positive when a pipeline would have suffered SIGPIPE.
    for mode in https excluded many; do
        case "$mode" in
            https) printf 'let endpoint = "https://api.example.net/v1"\n' ;;
            excluded) printf 'let urls = ["http://localhost:8080", "http://www.w3.org/2000/svg", "http://www.apple.com/DTDs/PropertyList-1.0.dtd"]\n' ;;
            many) awk 'BEGIN { for (i=0; i<5000; i++) print "// http://api.example.net/" i }' ;;
        esac > "${fx}/App/Fixture/Fixture.swift"
        fixture_commit_unchecked "$fx" "endpoint ${mode} control"
        rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/${mode}.txt" fixture_release_raw "$fx")"
        if [ "$mode" = many ]; then
            expect_exit 1 "$rc" "a large list of HTTP endpoints is still rejected"
            expect_contains "$(cat "${work}/${mode}.txt")" 'cleartext http:// endpoint(s)' \
                "the large control fails for its HTTP endpoints"
        else
            expect_exit 0 "$rc" "the ${mode} control still reaches release readiness"
            expect_contains "$(cat "${work}/${mode}.txt")" 'VERDICT=READY_FOR_HUMAN' \
                "the ${mode} control completes the full gate"
        fi
    done
}

case_release_coverage_schema() {
    local fx="${SELFTEST_DIR}/release-coverage-schema"
    local work="${SELFTEST_DIR}/release-coverage-schema-work"
    local schema rc rows widest
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    schema="${fx}/Config/release-requirements.v3.tsv"

    rc="$(run_capture "${work}/valid.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the canonical release coverage schema validates"
    rows="$(grep -v '^#' "$schema" || true)"
    expect_contains "$(head -n1 "$schema")" 'release-requirements/3' \
        "the coverage inventory declares schema version 3"
    widest="$(awk -F '\t' '!/^#/ && NF > 0 { if (NF > m) m = NF } END { print m + 0 }' "$schema")"
    expect_same "5" "$widest" "every coverage row has exactly five columns"
    expect_absent "$rows" 'REL-1104' "the distribution operation is not application coverage"
    expect_contains "$rows" $'REL-209\t' "the product manual rate entry point remains covered"

    cp "$schema" "${work}/schema.base"
    printf 'REL-9001\tall\tfunctional,unknown\tno\tinvalid domain\n' >> "$schema"
    rc="$(run_capture "${work}/domain.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "an unknown coverage domain fails closed"
    expect_contains "$(cat "${work}/domain.txt")" 'invalid audit domain: unknown' "the invalid domain is named"

    cp "${work}/schema.base" "$schema"
    printf 'REL-9002\tall\tfunctional\tsometimes\tinvalid inapplicable policy\n' >> "$schema"
    rc="$(run_capture "${work}/inapplicable.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "an invalid inapplicable policy fails closed"

    cp "${work}/schema.base" "$schema"
    printf 'REL-101\tall\tfunctional\tno\tduplicate\n' >> "$schema"
    rc="$(run_capture "${work}/duplicate.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a duplicate coverage ID fails closed"
    expect_contains "$(cat "${work}/duplicate.txt")" 'duplicates ID: REL-101' "the duplicate ID is named"
}

case_domain_audit_coverage() {
    local fx="${SELFTEST_DIR}/domain-audit-coverage"
    local work="${SELFTEST_DIR}/domain-audit-coverage-work"
    local record rc out
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    fixture_prepare_release_ready "$fx"
    record="$(cd "$fx" && pwd -P)/AI/audits/M01-final-polish.md"
    cp "$record" "${work}/record.base"

    awk '!/^- REL-101 /' "${work}/record.base" > "$record"
    fixture_commit_unchecked "$fx" "remove one coverage result"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/missing.txt" fixture_release_raw "$fx")"
    out="$(cat "${work}/missing.txt")"
    expect_exit 65 "$rc" "missing audit coverage blocks readiness"
    expect_contains "$out" 'VERDICT=NOT_READY' "missing coverage has the NOT_READY verdict"

    cp "${work}/record.base" "$record"
    sed 's/^- REL-101 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-101 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=this check was skipped/' \
        "$record" > "${work}/invalid-na.md"
    cp "${work}/invalid-na.md" "$record"
    fixture_commit_unchecked "$fx" "mark mandatory coverage inapplicable"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/invalid-na.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "INAPPLICABLE is refused when the inventory disallows it"

    cp "${work}/record.base" "$record"
    sed 's/^- REL-103 | OUTCOME=VERIFIED | EVIDENCE=.*/- REL-103 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=required device is unavailable/' \
        "$record" > "${work}/unavailable.md"
    cp "${work}/unavailable.md" "$record"
    fixture_commit_unchecked "$fx" "claim an unavailable environment is inapplicable"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/unavailable.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "an unavailable required environment cannot become INAPPLICABLE"

    cp "${work}/record.base" "$record"
    sed 's/^\*\*Open P0\/P1:\*\* 0$/**Open P0\/P1:** 1/' "$record" > "${work}/open.md"
    cp "${work}/open.md" "$record"
    fixture_commit_unchecked "$fx" "open a priority blocker"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/open.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "an open P0 or P1 blocks readiness"

    local mfx="${SELFTEST_DIR}/domain-audit-milestone"
    local mwork="${SELFTEST_DIR}/domain-audit-milestone-work"
    local milestone
    mkdir -p "$mwork"
    fixture_product "$mfx" "$mwork"
    sed 's/^\*\*Status:\*\* REVIEW$/**Status:** DONE/' \
        "${mfx}/AI/milestones/M00-template-bootstrap.md" > "${mwork}/M00.done"
    cp "${mwork}/M00.done" "${mfx}/AI/milestones/M00-template-bootstrap.md"
    append_only_write_milestone "${mfx}/AI/milestones/M01-final-functional.md" M01 PLANNED M00 'Targeted functional audit' \
        '**Audit prompt:** AI/prompts/audit-functional.md
**Audit record:** AI/audits/M01-functional.md'
    milestone="${mfx}/AI/milestones/M01-final-functional.md"
    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** REVIEW/' "$milestone" > "${mwork}/M01.review"
    cp "${mwork}/M01.review" "$milestone"
    fixture_write_audit_record "$mfx" M01 functional internal
    printf '**Policy status:** current\n\n# M00 fixture handoff\n\nBootstrap complete.\n' \
        > "${mfx}/AI/handoffs/M00-handoff.md"
    {
        printf '# Project status\n\n'
        printf '**Phase:** release-preparation\n'
        printf '**Current milestone:** M01\n'
        printf '**Completed milestones:** M00\n'
        printf '**Next milestone:** M01\n'
        printf '**Blockers:** none\n'
        printf '**Important decisions:** none\n'
    } > "${mfx}/AI/PROJECT_STATUS.md"
    fixture_commit_unchecked "$mfx" "prepare one final domain audit"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${mwork}/complete.txt" fixture_milestone "$mfx" M01)"
    expect_exit 0 "$rc" "a final audit milestone accepts complete domain coverage"
    expect_contains "$(cat "${mwork}/complete.txt")" 'audit coverage complete' \
        "milestone verification reports the coverage result"

    record="${mfx}/AI/audits/M01-functional.md"
    awk '!/^- REL-101 /' "$record" > "${mwork}/missing.md"
    cp "${mwork}/missing.md" "$record"
    fixture_commit_unchecked "$mfx" "remove milestone audit coverage"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${mwork}/missing.txt" fixture_milestone "$mfx" M01)"
    expect_exit 65 "$rc" "milestone verification rejects incomplete domain coverage"
}

case_status_schema() {
    local fx="${SELFTEST_DIR}/status-schema"
    local work="${SELFTEST_DIR}/status-schema-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local status="${fx}/AI/PROJECT_STATUS.md" label
    cp "$status" "${work}/status.base"
    local rc

    for label in Phase 'Current milestone' 'Completed milestones' 'Next milestone' Blockers 'Important decisions'; do
        awk -v marker="**${label}:**" 'index($0, marker) != 1 { print }' \
            "${work}/status.base" > "$status"
        rc="$(run_capture "${work}/missing.txt" "${fx}/Scripts/project-status.sh" validate)"
        expect_exit 65 "$rc" "missing compact status field '${label}' fails validation"
    done

    cp "${work}/status.base" "$status"
    rc="$(run_capture "${work}/valid.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 0 "$rc" "the six-field compact status validates"

    # A compact field that grows without bound stops being compact. The decisions
    # field had reached ~490 words — five audits and seven findings in one paragraph
    # — in the file every session reads third. The budget is what stops a state
    # field from silently becoming a log again.
    local over under
    over="$(awk 'BEGIN{ s=""; for (i = 0; i < 601; i++) s = s "x"; print s }')"
    under="$(awk 'BEGIN{ s=""; for (i = 0; i < 600; i++) s = s "x"; print s }')"
    awk -v v="$over" 'index($0, "**Important decisions:**") == 1 {
            print "**Important decisions:** " v; next } { print }' \
        "${work}/status.base" > "$status"
    rc="$(run_capture "${work}/over.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "an over-budget compact status field fails validation"
    expect_contains "$(cat "${work}/over.txt")" "the limit is" "the refusal states the budget"

    awk -v v="$under" 'index($0, "**Important decisions:**") == 1 {
            print "**Important decisions:** " v; next } { print }' \
        "${work}/status.base" > "$status"
    rc="$(run_capture "${work}/under.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 0 "$rc" "a field exactly at the budget is accepted"

    cp "${work}/status.base" "$status"
}

# Superseded instructions must not come back into a live document. The absence of
# these strings used to be asserted only here, in the slowest gate there is, so a
# document could be edited and committed with a retired instruction in it while
# `make static` and the optional pre-commit both passed. verify-template.sh now
# enforces the list; this case asserts that GUARD rather than the strings.
case_live_doc_vocabulary() {
    local fx="${SELFTEST_DIR}/live-doc-vocabulary"
    local work="${SELFTEST_DIR}/live-doc-vocabulary-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out superseded label
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a live document set free of superseded vocabulary passes"

    # The second group is the retired two-session milestone model: a Builder that
    # stopped at REVIEW so a separate independent Reviewer could set DONE. The third
    # is the archive configuration the release gate no longer has. The worktree
    # entries retire localization-only isolation. The last two are the retired claims that the
    # generated plan closes the project: that one milestone alone could ever run the
    # release gate, and that nothing at all follows the last one. The milestone list is
    # append-only, so both were absolutes the workflow no longer holds.
    for superseded in 'make push-check' 'ready-for-integration' 'CANDIDATE=<sha>' \
                      'release-requirements/2' 'release-requirements.v2.tsv' \
                      'release-coverage.v1.tsv' 'release-coverage/1' 'READY_FOR_DISTRIBUTION' \
                      'RELEASE_ARCHIVE_REQUIRED' 'ENABLE_ARCHIVE' \
                      'ARCHIVE_WAIVER_REASON' '--enable-archive' \
                      '--no-archive-required' '--archive-waiver-reason' \
                      'Builder cannot set' 'The Builder never sets' \
                      'Only an independent Reviewer sets' \
                      'Do not combine Builder and Reviewer' \
                      'stop for a fresh Reviewer session' \
                      'stops for an independent Reviewer' \
                      'not perform the independent review yourself' \
                      'independent review is required' \
                      'Independent review: required' \
                      'Builder stops at REVIEW' \
                      'make worktree ID=' '--worktree-path' \
                      'requires a milestone ID and cannot create' \
                      'a bare locale is not a milestone ID' \
                      'integrate-branches.md' \
                      'worktree is for post-milestone localization only' \
                      'Worktrees exist for one thing' \
                      'A long review or an experiment is not a reason to cut one' \
                      'STORE_TEXT' \
                      'No other milestone runs the release gate' \
                      'it is the last milestone, and none follows it'; do
        cp "${fx}/README.md" "${work}/README.base"
        printf '\n%s\n' "$superseded" >> "${fx}/README.md"
        label="$(printf '%s' "$superseded" | tr -d '\n')"
        rc="$(run_capture "${work}/hit.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "a live document naming '${label}' is refused"
        out="$(cat "${work}/hit.txt")"
        expect_contains "$out" "README.md names the superseded" "the refusal names the document"
        cp "${work}/README.base" "${fx}/README.md"
    done

    # The store-listing artifact, in each of the shapes a product repository actually
    # grew: the base file, a locale variant, and a live document routing work to it.
    # The bare stem in the guard is what catches all three; an entry spelled
    # 'STORE_TEXT.md' would miss the locale variants, which is how ten of them
    # appeared beside the original.
    local reintroduced
    for reintroduced in 'Draft the listing copy in AI/STORE_TEXT.md before the release audit.' \
                        'Each language gets its own AI/STORE_TEXT.<locale>.md beside the English one.' \
                        'Translate AI/STORE_TEXT.ru.md when you add Russian.'; do
        cp "${fx}/AI/WORKFLOW.md" "${work}/WORKFLOW.base"
        printf '\n%s\n' "$reintroduced" >> "${fx}/AI/WORKFLOW.md"
        rc="$(run_capture "${work}/store-text.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "a live document reintroducing the listing file is refused: '${reintroduced}'"
        expect_contains "$(cat "${work}/store-text.txt")" "AI/WORKFLOW.md names the superseded" \
            "the refusal names the document"
        cp "${work}/WORKFLOW.base" "${fx}/AI/WORKFLOW.md"
    done

    # The guard bans the retired mandatory model, not the current consolidated
    # final milestone. An optional extra review, the independent release audit, and
    # the six domains themselves are all supported concepts.
    # The last five prove the store-listing entry is a filename ban and not an ASO
    # semantic parser: every word it sits next to has legitimate uses that survive.
    local supported
    for supported in 'One session carries one milestone from IN_PROGRESS to DONE, then stops.' \
                     'An additional independent review is optional and never blocks DONE.' \
                     'An optional independent release audit may run before submission.' \
                     'Ask a Reviewer for a second opinion whenever you want one.' \
                     'Final Product Polish is one milestone with six ordered domains.' \
                     'All six audit domains write one consolidated final-polish record.' \
                     'The final milestone establishes exact release readiness.' \
                     'Only the developer decides whether to submit to the App Store.' \
                     'StoreKit purchases and restore are tested like any other behavior.' \
                     'Inspect the Simulator screenshots for clipping in the longest language.' \
                     'The privacy manifest is metadata the release audit reads.' \
                     'Application localization happens after READY_FOR_HUMAN, one language per worktree.' \
                     'Create the German worktree with ./Scripts/create-worktree.sh de.' \
                     'Remove it again with ./Scripts/remove-worktree.sh de when you are done.' \
                     'An independent read-only review may use an optional worktree.' \
                     'A bounded experiment may use an optional worktree.' \
                     'New work after the plan is finished is appended as a new milestone.' \
                     'A Release Readiness Revalidation milestone establishes the next candidate.'; do
        cp "${fx}/README.md" "${work}/README.base"
        printf '\n%s\n' "$supported" >> "${fx}/README.md"
        rc="$(run_capture "${work}/allowed.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 0 "$rc" "current policy wording is accepted: '${supported}'"
        cp "${work}/README.base" "${fx}/README.md"
    done

    # Positive policy is guarded too: merely banning the old localization-only
    # sentence would allow the optional review/experiment allowance to disappear.
    cp "${fx}/AI/WORKFLOW.md" "${work}/WORKFLOW.base"
    grep -vF 'Optional worktrees are useful' "${work}/WORKFLOW.base" \
        > "${fx}/AI/WORKFLOW.md"
    rc="$(run_capture "${work}/worktree-positive.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/worktree-positive.txt")"
    expect_exit 65 "$rc" "dropping the optional worktree allowance is refused"
    expect_contains "$out" 'does not state the checkout and integration rule' \
        "the refusal names the positive checkout contract"
    cp "${work}/WORKFLOW.base" "${fx}/AI/WORKFLOW.md"

    # The Makefile is a live document too: the retired target must not come back.
    cp "${fx}/Makefile" "${work}/Makefile.base"
    printf '\npush-check:\n\t@true\n' >> "${fx}/Makefile"
    rc="$(run_capture "${work}/makefile.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a resurrected push-check make target is refused"
    cp "${work}/Makefile.base" "${fx}/Makefile"

    # Historical records keep their original text. A superseded audit or handoff
    # describes the policy that was in force when it was written, and rewriting it
    # to satisfy a grep would destroy the evidence it exists to hold.
    printf '# Old record\n\n**Policy status:** superseded\n\nHISTORICAL RECORD — superseded by `solo-workflow/2`.\n\nIt told you to run `make push-check` before every push.\n' \
        > "${fx}/AI/audits/historical-vocabulary.md"
    rc="$(run_capture "${work}/historical.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a superseded record keeps its original instructions"
    rm -f "${fx}/AI/audits/historical-vocabulary.md"
}

# The release gate succeeds only from a complete final workflow. Both a missing
# audit record and incomplete row coverage must block before a verified SHA is claimed.
case_release_workflow_readiness() {
    local fx="${SELFTEST_DIR}/release-workflow-readiness"
    local work="${SELFTEST_DIR}/release-workflow-readiness-work"
    local rc out report record
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/early.txt" fixture_release_raw "$fx")"
    out="$(cat "${work}/early.txt")"
    expect_exit 65 "$rc" "release refuses a candidate before the final audits"
    expect_contains "$out" 'VERDICT=NOT_READY' "an unfinished workflow reports NOT_READY"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ready.txt" fixture_release "$fx")"
    out="$(cat "${work}/ready.txt")"
    expect_exit 0 "$rc" "a complete consolidated audit fixture reaches human review readiness"
    expect_contains "$out" 'VERDICT=READY_FOR_HUMAN' "the full workflow has the sole success verdict"
    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_contains "$report" '**Audit coverage:** COMPLETE' "the candidate report records complete audit coverage"
    expect_contains "$report" '**VERDICT:** READY_FOR_HUMAN' "the candidate report records the success verdict"

    record="${fx}/AI/audits/M01-final-polish.md"
    rm "$record"
    fixture_commit_unchecked "$fx" "remove a completed domain audit record"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/missing-record.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "a missing domain audit record blocks readiness"
    expect_contains "$(cat "${work}/missing-record.txt")" 'VERDICT=NOT_READY' \
        "missing final audit evidence reports NOT_READY"
}

case_retired_release_interfaces() {
    local fx="${SELFTEST_DIR}/retired-release-interfaces"
    local work="${SELFTEST_DIR}/retired-release-interfaces-work"
    local rc out
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    rc="$(run_capture "${work}/flag.txt" fixture_release_raw "$fx" --require-manual-evidence)"
    out="$(cat "${work}/flag.txt")"
    expect_exit 64 "$rc" "the retired release flag is rejected explicitly"
    expect_contains "$out" 'was removed' "the retired flag explains the replacement workflow"

    rc="$(run_capture "${work}/make-variable.txt" make -s -C "$fx" release \
        REQUIRE_MANUAL=1 CANDIDATE="$(fixture_candidate "$fx")")"
    out="$(cat "${work}/make-variable.txt")"
    if [ "$rc" = "0" ]; then
        check fail "the retired release make variable was accepted"
    else
        check pass "the retired release make variable is rejected (exit ${rc})"
    fi
    expect_contains "$out" 'was removed' "the retired make variable explains the replacement workflow"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/identity.txt" \
        fixture_release_raw "$fx" --print-candidate)"
    out="$(cat "${work}/identity.txt")"
    expect_exit 0 "$rc" "candidate identity remains available without readiness"
    expect_absent "$out" 'CHECKLIST' "candidate identity exposes no checklist path"

    # --untracked so a new file is searched before it is committed, and the status is
    # read rather than discarded: `|| true` turned a failed search (not a repository,
    # a bad pathspec) into "no hits".
    local token hits
    for token in READY_FOR_DISTRIBUTION REQUIRE_MANUAL --require-manual-evidence; do
        rc="$(run_capture "${work}/retired-${token#--}.txt" \
            git -C "$IOSAI_ROOT" grep --untracked -l -F -e "$token" -- . \
            ':!Scripts/self-test.sh' ':!Scripts/verify-template.sh' \
            ':!Scripts/verify-release.sh' ':!Makefile')"
        hits="$(cat "${work}/retired-${token#--}.txt")"
        case "$rc" in
            1) check pass "${token} appears only in its compatibility error or regression guard" ;;
            0) check fail "${token} still appears in: ${hits}" ;;
            *) check fail "the search for ${token} failed with exit ${rc}: ${hits}" ;;
        esac
    done
}

case_release_distribution_boundary() {
    local fx="${SELFTEST_DIR}/release-distribution-boundary"
    local work="${SELFTEST_DIR}/release-distribution-boundary-work"
    local rc out report
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release.txt" fixture_release "$fx")"
    out="$(cat "${work}/release.txt")"
    expect_exit 0 "$rc" "release verifies the candidate without performing distribution"
    expect_contains "$out" 'VERDICT=READY_FOR_HUMAN' "the verified candidate is ready for distribution"
    expect_contains "$out" "'-configuration' 'Release'" "the Release build still runs"

    if find "$fx" -name '*.xcarchive' -print -quit | grep -q .; then
        check fail "release verification created an xcarchive"
    else
        check pass "release verification created no xcarchive"
    fi
    # What the gate asked xcodebuild to do, read from the stub's own record and from
    # the exact commands the gate published.
    local release_run
    release_run="$(cat "${fx}/.artifacts/release/latest.txt")"
    if grep -Eq '(^| )archive( |$)' "${STUB_BIN}/invocations.log" 2>/dev/null; then
        check fail "release verification asked xcodebuild to archive"
    else
        check pass "release verification never asked xcodebuild to archive"
    fi
    if grep -lF "'archive'" "${release_run}"/*.command >/dev/null 2>&1; then
        check fail "a published release command archives"
    else
        check pass "no published release command archives"
    fi
    # The shipping configuration is built for the platform it ships on; signing is the
    # developer's, at the manual Archive. Debug keeps the configured destination.
    expect_contains "$(cat "${release_run}/clean-release.command")" \
        "'-destination' 'generic/platform=iOS'" "the Release build targets a generic iOS device"
    expect_contains "$(cat "${release_run}/clean-release.command")" "'CODE_SIGNING_ALLOWED=NO'" \
        "the Release build leaves code signing to the developer's Archive"
    expect_contains "$(cat "${release_run}/clean-debug.command")" \
        "'-destination' 'platform=iOS Simulator,name=Fixture Device'" \
        "the Debug build keeps the configured build destination"
    # The control that makes the two absence checks above mean something: asked to
    # archive, the stub leaves an .xcarchive and a record, exactly as xcodebuild would.
    "${STUB_BIN}/xcodebuild" archive -scheme Fixture -archivePath "${work}/control.xcarchive" \
        >/dev/null 2>&1 || true
    if [ -d "${work}/control.xcarchive" ] \
       && grep -Eq '(^| )archive( |$)' "${STUB_BIN}/invocations.log" 2>/dev/null; then
        check pass "the stub makes an archive visible, so the absence checks can fail"
    else
        check fail "the stub hides an archive, so the absence checks prove nothing"
    fi
    local checklist="${fx}/.artifacts/release-checklists/$(fixture_candidate "$fx")/checklist.md"
    expect_contains "$(cat "$checklist")" "$(fixture_candidate "$fx")" "human checklist binds the full candidate SHA"
    expect_contains "$(cat "$checklist")" 'OUTCOME=PENDING' "human work is outstanding, never claimed complete"

    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_contains "$report" 'Nothing was archived, uploaded, submitted, pushed, or published.' \
        "the report states the distribution boundary"
    expect_absent "$report" '| Archive |' "the verification table contains no archive operation"
    expect_contains "$report" 'Organizer' "the report identifies the manual Archive validation"
    expect_contains "$report" '**Pending human steps:** 3' "all three human steps are reported as pending"
    cp "$checklist" "${work}/checklist.base"
    sed 's/^\*\*Candidate commit:\*\* .*/**Candidate commit:** 0000000000000000000000000000000000000000/' \
        "${work}/checklist.base" > "$checklist"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/mismatch.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "release refuses an existing checklist bound to another candidate"
    expect_contains "$(cat "${work}/mismatch.txt")" 'VERDICT=NOT_READY' "checklist mismatch is not release readiness"
    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_absent "$report" '**VERIFIED_COMMIT:**' "a mismatched checklist produces no total-success claim"

}

# Archive, export, notarization and upload are the developer's steps after
# READY_FOR_HUMAN. An audit put `xcodebuild archive` back into the release gate and
# nothing noticed: template-check, static, and every case in this suite still passed.
# verify-template.sh now reads the scripts for those commands on every static run;
# this case puts each shape of one back and requires the refusal.
case_automatic_distribution_guard() {
    local fx="${SELFTEST_DIR}/distribution-guard"
    local work="${SELFTEST_DIR}/distribution-guard-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local target="${fx}/Scripts/verify-release.sh" pristine="${work}/verify-release.pristine"
    local anchor rc out variant step
    cp "$target" "$pristine"

    rc="$(run_capture "${work}/control.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the template's own scripts carry no distribution step"
    expect_contains "$(cat "${work}/control.txt")" "no script archives, exports, uploads, or notarizes" \
        "the guard reports what it read"

    anchor="$(grep -n '^# This gate deliberately stops before' "$pristine" | head -1 | cut -d: -f1)"
    if [ -z "$anchor" ]; then
        check fail "the release gate's archive anchor moved; the variants below cannot be placed"
        return 0
    fi
    for variant in single-line continuation export notarize upload transporter; do
        case "$variant" in
            single-line)
                step='run_xcodebuild archive "$run_dir" -- archive -scheme "$SCHEME" -archivePath "${run_dir}/App.xcarchive"' ;;
            continuation)
                step='run_xcodebuild pack "$run_dir" -- \
    archive \
    -scheme "$SCHEME"' ;;
            export)
                step='xcodebuild -exportArchive -archivePath "$archive" -exportOptionsPlist "$options"' ;;
            notarize)
                step='xcrun notarytool submit "$package" --wait' ;;
            upload)
                step='xcrun altool --upload-app -f "$package"' ;;
            transporter)
                step='iTMSTransporter -m upload -assetFile "$package"' ;;
        esac
        { head -n $((anchor - 1)) "$pristine"; printf '%s\n' "$step"; tail -n +"$anchor" "$pristine"; } > "$target"
        rc="$(run_capture "${work}/${variant}.txt" "${fx}/Scripts/verify-template.sh")"
        out="$(cat "${work}/${variant}.txt")"
        expect_exit 65 "$rc" "template-check refuses a ${variant} distribution step"
        expect_contains "$out" "distribution is the developer's step" \
            "the ${variant} refusal names the boundary"
        expect_contains "$out" "Scripts/verify-release.sh" "the ${variant} refusal names the script"
    done

    # Prose about the boundary stays legal, so the guard is never satisfied by deleting
    # the explanations that send the developer to the manual Archive.
    cp "$pristine" "$target"
    printf '\n# the developer runs xcodebuild archive by hand; no gate ever does\n' >> "$target"
    rc="$(run_capture "${work}/prose.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a comment describing the manual archive is not a distribution step"
    cp "$pristine" "$target"
}

case_artifact_outputs() {
    local fx="${SELFTEST_DIR}/artifact outputs"
    local work="${SELFTEST_DIR}/artifact-outputs-work"
    local outside="${SELFTEST_DIR}/artifact-output-sentinels"
    mkdir -p "$work" "$outside"
    fixture_template "$fx" "$work"
    printf 'IRREPLACEABLE\n' > "${outside}/sentinel.txt"
    local before after rc out pointer
    before="$(shasum -a 256 "${outside}/sentinel.txt" | awk '{print $1}')"

    # Root component: .artifacts itself may not redirect evidence.
    mv "${fx}/.artifacts" "${fx}/.artifacts-real"
    ln -s "$outside" "${fx}/.artifacts"
    rc="$(run_capture "${work}/root.txt" bash -c \
        '. "$1"; utc_stamp() { printf fixture-stamp; }; artifacts_run_dir integration' \
        _ "${fx}/Scripts/lib/common.sh")"
    out="$(cat "${work}/root.txt")"
    expect_exit 64 "$rc" "a symlinked artifact root is refused"
    expect_contains "$out" "symlink" "root refusal names the trust-boundary violation"
    rm -f "${fx}/.artifacts"
    mv "${fx}/.artifacts-real" "${fx}/.artifacts"

    # Gate ancestor, including a nested milestone component.
    ln -s "$outside" "${fx}/.artifacts/integration"
    rc="$(run_capture "${work}/gate.txt" bash -c \
        '. "$1"; utc_stamp() { printf fixture-stamp; }; artifacts_run_dir integration' \
        _ "${fx}/Scripts/lib/common.sh")"
    expect_exit 64 "$rc" "a symlinked gate directory is refused"
    rm -f "${fx}/.artifacts/integration"

    mkdir -p "${fx}/.artifacts/milestone"
    ln -s "$outside" "${fx}/.artifacts/milestone/M00"
    rc="$(run_capture "${work}/nested.txt" bash -c \
        '. "$1"; utc_stamp() { printf fixture-stamp; }; artifacts_run_dir milestone/M00' \
        _ "${fx}/Scripts/lib/common.sh")"
    expect_exit 64 "$rc" "a symlinked nested gate component is refused"
    rm -f "${fx}/.artifacts/milestone/M00"

    # Fresh run directory: force the exact timestamp/PID component to a link.
    mkdir -p "${fx}/.artifacts/integration"
    rc="$(run_capture "${work}/run.txt" bash -c \
        '. "$1"; utc_stamp() { printf fixture-stamp; }; ln -s "$2" "${IOSAI_ARTIFACTS_DIR}/integration/fixture-stamp-$$"; artifacts_run_dir integration' \
        _ "${fx}/Scripts/lib/common.sh" "$outside")"
    expect_exit 64 "$rc" "a symlinked final run directory is refused"
    find "${fx}/.artifacts/integration" -maxdepth 1 -type l -delete

    # Final pointer: an existing symlink is refused and its referent survives.
    ln -s "${outside}/sentinel.txt" "${fx}/.artifacts/integration/latest.txt"
    rc="$(run_capture "${work}/pointer.txt" bash -c \
        '. "$1"; utc_stamp() { printf pointer-stamp; }; artifacts_run_dir integration' \
        _ "${fx}/Scripts/lib/common.sh")"
    expect_exit 64 "$rc" "a symlinked latest pointer is refused"
    rm -f "${fx}/.artifacts/integration/latest.txt"

    # A non-pointer final target is checked too; report generation cannot
    # truncate a linked external file.
    mkdir -p "${fx}/.artifacts/manual-report"
    ln -s "${outside}/sentinel.txt" "${fx}/.artifacts/manual-report/report.md"
    rc="$(run_capture "${work}/report-target.txt" bash -c \
        '. "$1"; report_header "${IOSAI_ARTIFACTS_DIR}/manual-report/report.md" "Fixture"' \
        _ "${fx}/Scripts/lib/common.sh")"
    expect_exit 64 "$rc" "a symlinked non-pointer artifact target is refused"
    rm -f "${fx}/.artifacts/manual-report/report.md"

    # A regular existing pointer is atomically replaced with a regular file.
    printf 'old-complete-pointer\n' > "${fx}/.artifacts/integration/latest.txt"
    rc="$(run_capture "${work}/success.txt" bash -c \
        '. "$1"; utc_stamp() { printf success-stamp; }; artifacts_run_dir integration' \
        _ "${fx}/Scripts/lib/common.sh")"
    expect_exit 0 "$rc" "a safe artifact run and atomic pointer replacement succeed"
    if [ -f "${fx}/.artifacts/integration/latest.txt" ] && [ ! -L "${fx}/.artifacts/integration/latest.txt" ]; then
        check pass "latest.txt is a regular no-follow pointer"
    else
        check fail "latest.txt is not a regular no-follow pointer"
    fi
    pointer="$(cat "${fx}/.artifacts/integration/latest.txt")"
    if [ -d "$pointer" ] && [ ! -L "$pointer" ]; then
        check pass "the completed pointer names the completed real run directory"
    else
        check fail "the completed pointer does not name a real run directory"
    fi

    after="$(shasum -a 256 "${outside}/sentinel.txt" | awk '{print $1}')"
    expect_same "$before" "$after" "artifact symlink attacks never modify the external sentinel"
}

case_destructive_paths() {
    local fx="${SELFTEST_DIR}/destructive"
    local work="${SELFTEST_DIR}/destructive-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local outside="${SELFTEST_DIR}/user docs"
    mkdir -p "${outside}/DerivedData" "${outside}/evidence"
    printf 'IRREPLACEABLE\n' > "${outside}/DerivedData/sentinel.txt"
    printf 'IRREPLACEABLE\n' > "${outside}/evidence/sentinel.txt"
    local before
    before="$(shasum -a 256 "${outside}/DerivedData/sentinel.txt" "${outside}/evidence/sentinel.txt" | awk '{print $1}' | tr '\n' ' ')"

    local rc out default_path owned_root name value
    default_path="$("${fx}/Scripts/clean-derived-data.sh" --print)"
    owned_root="$(dirname -- "$default_path")"

    # Every dangerous class is rejected when the configuration is loaded, so
    # no build command gets a chance to consume it.
    for name in root home repository repository_parent private_tmp tmp owned_root external; do
        case "$name" in
            root)              value="/" ;;
            home)              value="${HOME}" ;;
            repository)        value="$fx" ;;
            repository_parent) value="$(dirname -- "$fx")" ;;
            private_tmp)       value="/private/tmp" ;;
            tmp)               value="/tmp" ;;
            owned_root)        value="$owned_root" ;;
            external)          value="${outside}/DerivedData" ;;
        esac
        git -C "$fx" checkout -q -- Config/project.env
        sed "s|^DERIVED_DATA_PATH=\"\"|DERIVED_DATA_PATH=\"${value}\"|" \
            "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
        mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
        rc="$(run_capture "${work}/dd-${name}.txt" "${fx}/Scripts/clean-derived-data.sh" --print)"
        out="$(cat "${work}/dd-${name}.txt")"
        expect_exit 64 "$rc" "DerivedData rejects ${name}"
        expect_absent "$out" "rm -rf" "${name} refusal prints no recursive deletion command"
    done
    git -C "$fx" checkout -q -- Config/project.env

    # A strict child is build-safe but remains operator-owned for cleanup.
    value="${owned_root}/custom/DerivedData"
    sed "s|^DERIVED_DATA_PATH=\"\"|DERIVED_DATA_PATH=\"${value}\"|" \
        "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
    mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
    rc="$(run_capture "${work}/dd-allowed.txt" "${fx}/Scripts/clean-derived-data.sh" --print)"
    expect_exit 0 "$rc" "an override strictly inside the owned root is accepted for builds"
    out="$(cat "${work}/dd-allowed.txt")"
    expect_same "$value" "$out" "the allowed override resolves exactly"
    rc="$(run_capture "${work}/dd-clean-custom.txt" "${fx}/Scripts/clean-derived-data.sh")"
    out="$(cat "${work}/dd-clean-custom.txt")"
    expect_exit 64 "$rc" "cleanup refuses even an allowed custom override"
    expect_absent "$out" "rm -rf" "custom cleanup generates no recursive deletion advice"
    git -C "$fx" checkout -q -- Config/project.env

    # A path textually inside the owned root is still rejected through a link.
    mkdir -p "$owned_root"
    ln -s "$outside" "${owned_root}/linked"
    value="${owned_root}/linked/DerivedData"
    sed "s|^DERIVED_DATA_PATH=\"\"|DERIVED_DATA_PATH=\"${value}\"|" \
        "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
    mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
    rc="$(run_capture "${work}/dd-symlink.txt" "${fx}/Scripts/clean-derived-data.sh" --print)"
    expect_exit 64 "$rc" "a symlinked location inside the owned root is refused"
    rm -f "${owned_root}/linked"
    rmdir "$owned_root" 2>/dev/null || true
    git -C "$fx" checkout -q -- Config/project.env

    # The owned root's PARENT is /private/tmp, mode 1777, and the root's own name
    # is computed from the checkout path — so any local account can work out where
    # it will be and create it first. A real directory somebody else made passes
    # both the containment and the symlink checks, so ownership has to be asserted
    # on its own or "checkout-owned cache" is only a comment. It matters because a
    # substituted cache reaches the Release build the release gate certifies.
    mkdir -m 0777 -p "$owned_root"
    rc="$(run_capture "${work}/dd-shared-root.txt" "${fx}/Scripts/clean-derived-data.sh" --print)"
    out="$(cat "${work}/dd-shared-root.txt")"
    expect_exit 64 "$rc" "a group/world-writable cache root is refused"
    expect_contains "$out" "writable by other users" "the refusal names the ownership boundary"
    expect_absent "$out" "rm -rf" "the ownership refusal prints no recursive deletion command"

    # Not vacuous: the same root, made private, is accepted.
    chmod 0700 "$owned_root"
    rc="$(run_capture "${work}/dd-private-root.txt" "${fx}/Scripts/clean-derived-data.sh" --print)"
    expect_exit 0 "$rc" "a private cache root is accepted"
    rmdir "$owned_root" 2>/dev/null || true
    git -C "$fx" checkout -q -- Config/project.env

    # A symlinked artifacts root is refused.
    mv "${fx}/.artifacts" "${fx}/.artifacts-real"
    ln -s "${outside}/evidence" "${fx}/.artifacts"
    rc="$(run_capture "${work}/art.txt" "${fx}/Scripts/clean-artifacts.sh")"
    out="$(cat "${work}/art.txt")"
    expect_exit 64 "$rc" "a symlinked .artifacts/ is refused"
    expect_contains "$out" "symlink" "the refusal names the symlink"
    rm -f "${fx}/.artifacts"
    mv "${fx}/.artifacts-real" "${fx}/.artifacts"

    # safe_remove_path refuses a root this repository does not own.
    rc="$(run_capture "${work}/sr.txt" bash -c \
        ". '${fx}/Scripts/lib/common.sh'; safe_remove_path '${outside}/evidence' '${outside}'")"
    expect_exit 64 "$rc" "safe_remove_path refuses a non-canonical root"

    # The immutable integration snapshot inherits cache ownership only through
    # its validated evidence-root argument. A legitimate invoking-worktree
    # override must still reach the build rather than being re-keyed to the
    # temporary detached source directory.
    local product="${SELFTEST_DIR}/derived-product"
    local product_work="${SELFTEST_DIR}/derived-product-work"
    fixture_product "$product" "$product_work"
    owned_root="$(bash -c '. "$1"; derived_data_owned_root' _ "${product}/Scripts/lib/common.sh")"
    value="${owned_root}/custom/DerivedData"
    sed "s|^DERIVED_DATA_PATH=\"\"|DERIVED_DATA_PATH=\"${value}\"|" \
        "${product}/Config/project.env" > "${product}/Config/project.env.new"
    mv "${product}/Config/project.env.new" "${product}/Config/project.env"
    fixture_commit_unchecked "$product" "configured owned cache"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${product_work}/integration.txt" \
        fixture_integration "$product")"
    expect_exit 0 "$rc" "an owned override survives immutable-candidate verification"
    out="$(cat "${product_work}/integration.txt")"
    expect_contains "$out" "$value" "the immutable build receives the invoking worktree's owned cache"

    # A gate creates the cache root itself rather than inheriting whatever the
    # umask happened to be, so there is no window in which a world-writable
    # directory exists under a world-writable parent.
    if [ -d "$owned_root" ]; then
        if [ -z "$(find "$owned_root" -maxdepth 0 -perm +022 -print 2>/dev/null)" ]; then
            check pass "a gate creates the cache root without group or world write"
        else
            check fail "a gate created a group/world-writable cache root"
        fi
    else
        check fail "no cache root was created by the verification gate"
    fi

    local after
    after="$(shasum -a 256 "${outside}/DerivedData/sentinel.txt" "${outside}/evidence/sentinel.txt" | awk '{print $1}' | tr '\n' ' ')"
    expect_same "$before" "$after" "every external sentinel is byte-identical"
}

case_secret_handling() {
    local fx="${SELFTEST_DIR}/secrets"
    local work="${SELFTEST_DIR}/secrets-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    # Malformed configuration diagnostics must identify the rule without ever
    # copying the assignment value into terminal output.
    local parser_secret="CONFIG_VALUE_SENTINEL_7f92c14e"
    printf 'PROJECT_NAME=\"%s\n' "$parser_secret" >> "${fx}/Config/project.env"
    local rc out
    rc="$(run_capture "${work}/parser.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/parser.txt")"
    expect_exit 65 "$rc" "malformed secret-bearing configuration is rejected"
    expect_contains "$out" "Config/project.env:" "parser reports only the file and line boundary"
    expect_absent "$out" "$parser_secret" "parser diagnostics redact the complete configuration value"
    git -C "$fx" checkout -q -- Config/project.env

    # Filename coverage includes environment variants and credential bundles,
    # even when ignored or untracked.
    printf 'harmless fixture\n' > "${fx}/.env.production"
    printf 'harmless fixture\n' > "${fx}/App/ServiceCredentials.plist"
    rc="$(run_capture "${work}/names.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/names.txt")"
    expect_exit 65 "$rc" "credential filename variants fail static verification"
    expect_contains "$out" ".env.production" ".env.* variants are covered"
    expect_contains "$out" "ServiceCredentials.plist" "credential plist variants are covered"
    rm -f "${fx}/.env.production" "${fx}/App/ServiceCredentials.plist"

    # Assembled at run time so this script is not itself a secret-shaped file.
    local gh aws key_body private_header
    gh="ghp_$(printf 'A%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36)"
    aws="AKIA$(printf 'B%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)"
    key_body="MIIBOgIBAAJBAKj34GkxFhD90vcNLYLInFEX6Ppy1tPf9Cnzj4p4WGeKLs1Pt8Qu"
    private_header="-----BEGIN RSA PRIVATE"

    printf -- '%s KEY-----\n%s\n-----END RSA PRIVATE KEY-----\n' "$private_header" "$key_body" \
        > "${fx}/App/leaked.key"
    printf 'let token = "%s"\n' "$gh" > "${fx}/App/Token.swift"
    printf 'aws_access_key_id = %s\n' "$aws" > "${fx}/App/aws.conf"

    local rc out
    rc="$(run_capture "${work}/scan.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/scan.txt")"
    expect_exit 65 "$rc" "synthetic secrets fail static verification"
    expect_contains "$out" "leaked.key" "the private-key file is named"
    expect_contains "$out" "github-token" "the token class is named"
    expect_contains "$out" "aws-access-key" "the AWS class is named"
    expect_contains "$out" "App/Token.swift:1: github-token" "content findings include path, line, and class only"
    expect_absent "$out" "$gh" "the GitHub token's bytes are not printed"
    expect_absent "$out" "$aws" "the AWS key's bytes are not printed"
    expect_absent "$out" "$key_body" "the private key's bytes are not printed"
    rm -f "${fx}/App/leaked.key" "${fx}/App/Token.swift" "${fx}/App/aws.conf"

    # The former whole-file exemptions are scanned like every other file. A
    # secret-shaped comment in any one of them must remain visible by path and
    # class, without printing its bytes.
    printf '# %s\n' "$gh" >> "${fx}/Config/project.env.example"
    printf '\n<!-- %s -->\n' "$gh" >> "${fx}/AI/ARCHITECTURE.md"
    printf '\n# %s\n' "$gh" >> "${fx}/Scripts/verify-static.sh"
    printf '\n# %s\n' "$gh" >> "${fx}/Scripts/self-test.sh"
    rc="$(run_capture "${work}/former-exempt.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/former-exempt.txt")"
    expect_exit 65 "$rc" "every former whole-file exemption is scanned"
    expect_contains "$out" "Config/project.env.example" "configuration example is not a blind spot"
    expect_contains "$out" "AI/ARCHITECTURE.md" "privacy architecture is not a blind spot"
    expect_contains "$out" "Scripts/verify-static.sh" "scanner source is not a blind spot"
    expect_contains "$out" "Scripts/self-test.sh" "fixture source is not a blind spot"
    expect_absent "$out" "$gh" "former-exemption findings never print secret bytes"
    git -C "$fx" checkout -q -- Config/project.env.example AI/ARCHITECTURE.md \
        Scripts/verify-static.sh Scripts/self-test.sh

    # Integration has no remote interface and therefore cannot ingest or report
    # remote credentials. Its report remains candidate-only.
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/integration.txt" fixture_integration "$fx")"
    out="$(cat "${work}/integration.txt")"
    expect_exit 0 "$rc" "integration verification passes on the clean fixture"
    local reports
    reports="$(find "${fx}/.artifacts/integration" -name 'report.md' 2>/dev/null || true)"
    if [ -z "$reports" ]; then
        check fail "no integration report was written"
    else
        local report_text
        report_text="$(cat $reports)"
        expect_absent "$report_text" "**Remote:**" "integration evidence has no remote metadata"
        expect_contains "$report_text" "**CANDIDATE_COMMIT:**" "integration evidence records only candidate identity"
    fi
    expect_absent "$out" "remote-url" "the console exposes no obsolete remote interface"
}

case_integration_recovery() {
    local fx="${SELFTEST_DIR}/integration-recovery"
    local work="${SELFTEST_DIR}/integration-recovery-work"
    mkdir -p "$fx" "$work"
    git -C "$fx" init -q -b main
    git -C "$fx" config user.name "Fixture"
    git -C "$fx" config user.email "fixture@example.invalid"

    printf 'base\n' > "${fx}/base.txt"
    printf 'sentinel-clean\n' > "${fx}/sentinel.txt"
    git -C "$fx" add base.txt sentinel.txt
    git -C "$fx" commit -q -m base
    git -C "$fx" switch -q -c milestone
    printf 'milestone\n' > "${fx}/milestone.txt"
    git -C "$fx" add milestone.txt
    git -C "$fx" commit -q -m milestone
    git -C "$fx" switch -q main
    git -C "$fx" merge -q --no-ff milestone -m "merge milestone"
    local merge_commit
    merge_commit="$(git -C "$fx" rev-parse HEAD)"

    # Later committed work plus tracked and untracked local work must all
    # survive recovery from the earlier merge.
    printf 'later-commit\n' > "${fx}/later.txt"
    git -C "$fx" add later.txt
    git -C "$fx" commit -q -m later
    printf 'sentinel-dirty\n' >> "${fx}/sentinel.txt"
    printf 'untracked-local\n' > "${fx}/untracked.txt"

    local rc
    rc="$(run_capture "${work}/revert.txt" git -C "$fx" revert --no-edit -m 1 "$merge_commit")"
    expect_exit 0 "$rc" "mainline revert records auditable integration recovery"
    if grep -Fq 'sentinel-dirty' "${fx}/sentinel.txt"; then
        check pass "revert preserves unrelated tracked local work"
    else
        check fail "revert discarded unrelated tracked local work"
    fi
    if [ -f "${fx}/untracked.txt" ]; then
        check pass "revert preserves unrelated untracked local work"
    else
        check fail "revert discarded unrelated untracked local work"
    fi
    if [ -f "${fx}/later.txt" ] && [ ! -e "${fx}/milestone.txt" ]; then
        check pass "revert preserves later commits while undoing only the merge delta"
    else
        check fail "revert did not isolate the merge delta from later commits"
    fi

    # Localization fan-in is the one combined stream this workflow produces, so its
    # prompt is the one that has to verify the exact commit that combined them.
    local guidance
    guidance="$(cat "${IOSAI_ROOT}/AI/prompts/integrate-localization-worktrees.md")"
    expect_contains "$guidance" 'make integration CANDIDATE="$integration_sha"' \
        "the fan-in guidance verifies the exact combined commit"
    expect_absent "$guidance" "git reset --hard" \
        "the fan-in guidance contains no destructive reset recovery"
}

case_milestone_schema() {
    local fx="${SELFTEST_DIR}/schema"
    local work="${SELFTEST_DIR}/schema-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local M="${fx}/AI/milestones"

    local rc
    rc="$(run_capture "${work}/base.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 0 "$rc" "the shipped state validates"

    printf '# M07\n\n**Status:** planned\n' > "${M}/M07-thin.md"
    rc="$(run_capture "${work}/thin.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "a milestone missing its fields fails"
    rm -f "${M}/M07-thin.md"

    cp "${M}/M00-template-bootstrap.md" "${M}/M00-duplicate.md"
    rc="$(run_capture "${work}/ambig.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "two files sharing an ID prefix fail"
    rm -f "${M}/M00-duplicate.md"

    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** planned/' "${M}/M00-template-bootstrap.md" \
        > "${M}/M00.tmp" && mv "${M}/M00.tmp" "${M}/M00-template-bootstrap.md"
    rc="$(run_capture "${work}/lowercase.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "lowercase milestone state fails"
    git -C "$fx" checkout -q -- AI/milestones

    sed 's|^\*\*Phase:\*\* template$|**Phase:** somewhere in the middle|' \
        "${fx}/AI/PROJECT_STATUS.md" > "${fx}/AI/x" && mv "${fx}/AI/x" "${fx}/AI/PROJECT_STATUS.md"
    rc="$(run_capture "${work}/phase.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "a narrative **Phase:** fails"
    git -C "$fx" checkout -q -- AI/PROJECT_STATUS.md

    # A milestone must be REVIEW before any verification attempt.
    rc="$(run_capture "${work}/m00.txt" fixture_milestone "$fx" M00)"
    expect_exit 65 "$rc" "PLANNED M00 cannot be verified"
    expect_contains "$(cat "${work}/m00.txt")" "must be in REVIEW" "the REVIEW requirement is stated"
}

case_conflict_markers() {
    local fx="${SELFTEST_DIR}/conflicts"
    local work="${SELFTEST_DIR}/conflicts-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local f rc
    for f in "note.md" "script.sh" "settings.env" "App/Source.swift" \
             "App/Fixture.xcodeproj/project.pbxproj" "App/Info.plist"; do
        mkdir -p "${fx}/$(dirname -- "$f")"
        printf '<<<<<<< HEAD\nours\n' > "${fx}/${f}"
        rc="$(run_capture "${work}/out.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "a conflict marker in ${f} fails"
        expect_contains "$(cat "${work}/out.txt")" "$f" "the offending file is named"
        rm -f "${fx}/${f}"
    done

    # Seven '=' is a Markdown setext underline, not a conflict marker.
    printf 'A heading\n=======\n\ntext\n' > "${fx}/setext.md"
    rc="$(run_capture "${work}/setext.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a setext underline is not treated as a conflict"
    rm -f "${fx}/setext.md"
}

case_placeholder_allowlist() {
    local fx="${SELFTEST_DIR}/allowlist"
    local work="${SELFTEST_DIR}/allowlist-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local list="${fx}/Config/placeholder-allowlist.txt"
    cp "$list" "${work}/allowlist.bak"

    local entry rc
    for entry in 'App/*.swift | broad | 2099-01-01' \
                 'App/Unfinished.swift | shipping source | 2099-01-01' \
                 'Config/project.env | config | 2099-01-01' \
                 'App/AppTests/Fixtures/P.swift | expired | 2020-01-01' \
                 'App/AppTests/Fixtures/P.swift |  | 2099-01-01'; do
        cp "${work}/allowlist.bak" "$list"
        printf '%s\n' "$entry" >> "$list"
        rc="$(run_capture "${work}/out.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "allowlist rejects: ${entry}"
    done

    cp "${work}/allowlist.bak" "$list"
    printf 'App/AppTests/Fixtures/P.swift | fixture documents the scanner | 2099-01-01\n' >> "$list"
    rc="$(run_capture "${work}/valid.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "an exact, non-shipping, dated entry is accepted"

    # And the exemption actually applies to that one file, not to its neighbours.
    mkdir -p "${fx}/App/AppTests/Fixtures"
    printf 'let sample = "TBD"\n' > "${fx}/App/AppTests/Fixtures/P.swift"
    rc="$(run_capture "${work}/exempt.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the exempted fixture does not fail the placeholder scan"
    printf 'let copy = "TBD"\n' > "${fx}/App/Shipping.swift"
    rc="$(run_capture "${work}/shipping.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a placeholder in shipping source still fails"
}

case_placeholder_shipping() {
    local fx="${SELFTEST_DIR}/placeholder-shipping"
    local work="${SELFTEST_DIR}/placeholder-shipping-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc

    mkdir -p "${fx}/App/Content"
    printf 'let paywallCopy = "TBD"\n' > "${fx}/App/Content/Paywall.swift"
    rc="$(run_capture "${work}/content.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a placeholder under shipping Content/ fails"
    expect_contains "$(cat "${work}/content.txt")" "App/Content/Paywall.swift" "the shipping Content file is named"
    rm -f "${fx}/App/Content/Paywall.swift"

    mkdir -p "${fx}/App/Preview Content"
    printf 'let previewCopy = "TBD"\n' > "${fx}/App/Preview Content/Preview.swift"
    rc="$(run_capture "${work}/preview.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the exact Preview Content component remains non-shipping"
    rm -f "${fx}/App/Preview Content/Preview.swift"

    mkdir -p "${fx}/App/FixtureResources"
    printf '<plist><string>TBD</string></plist>\n' > "${fx}/App/FixtureResources/Info.plist"
    rc="$(run_capture "${work}/resource.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a placeholder in a shipping plist fails"
    expect_contains "$(cat "${work}/resource.txt")" "App/FixtureResources/Info.plist" "the shipping resource is named"
    rm -f "${fx}/App/FixtureResources/Info.plist"

    mkdir -p "${fx}/App/Fixture.xcodeproj"
    printf 'PRODUCT_NAME = TBD;\n' > "${fx}/App/Fixture.xcodeproj/project.pbxproj"
    rc="$(run_capture "${work}/project.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a placeholder in project metadata fails"
    expect_contains "$(cat "${work}/project.txt")" "App/Fixture.xcodeproj/project.pbxproj" "the project metadata is named"
}

case_template_readonly() {
    local fx="${SELFTEST_DIR}/template-readonly"
    local work="${SELFTEST_DIR}/template-readonly-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc

    if [ -w "${fx}/Config/project.env" ]; then
        check pass "throwaway fixtures are writable even when their source candidate is read-only"
    else
        check fail "throwaway fixture inherited an unusable read-only source mode"
    fi

    rm -f "${fx}/.artifacts/.gitkeep"
    rc="$(run_capture "${work}/marker.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "template validation reports a missing artifact marker"
    if [ ! -e "${fx}/.artifacts/.gitkeep" ]; then
        check pass "template validation did not recreate .artifacts/.gitkeep"
    else
        check fail "template validation mutated the missing artifact marker"
    fi

    rmdir "${fx}/.artifacts"
    rc="$(run_capture "${work}/root.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "template validation reports a missing artifact directory"
    if [ ! -e "${fx}/.artifacts" ]; then
        check pass "template validation did not recreate .artifacts/"
    else
        check fail "template validation mutated the missing artifact directory"
    fi

    local verifier
    verifier="$(cat "${fx}/Scripts/verify-template.sh")"
    expect_contains "$verifier" 'for f in "${IOSAI_ROOT}"/Scripts/*.sh' "shell syntax validation iterates the script glob"
    expect_contains "$verifier" 'bash -n "$f"' "each expanded script is parsed individually"
}

case_milestone_lifecycle() {
    local fx="${SELFTEST_DIR}/milestone-states"
    local work="${SELFTEST_DIR}/milestone-states-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local statuses rc token
    statuses="$(bash -c '. "$1"; printf "%s" "$IOSAI_MILESTONE_STATUSES"' _ "${fx}/Scripts/lib/common.sh")"
    expect_same "PLANNED IN_PROGRESS REVIEW DONE BLOCKED" "$statuses" "exactly five uppercase states exist"
    for token in PLANNED IN_PROGRESS REVIEW BLOCKED; do
        rc="$(bash -c '. "$1"; milestone_status_is_complete "$2"' _ \
            "${fx}/Scripts/lib/common.sh" "$token" >/dev/null 2>&1; printf '%s' "$?")"
        expect_exit 1 "$rc" "${token} does not satisfy a dependency"
    done
    rc="$(bash -c '. "$1"; milestone_status_is_complete DONE' _ \
        "${fx}/Scripts/lib/common.sh" >/dev/null 2>&1; printf '%s' "$?")"
    expect_exit 0 "$rc" "DONE alone satisfies a dependency"
    rc="$(bash -c '. "$1"; type milestone_status_can_advance' _ \
        "${fx}/Scripts/lib/common.sh" >/dev/null 2>&1; printf '%s' "$?")"
    expect_exit 1 "$rc" "there is no forward-rank transition engine"

    local milestone="${fx}/AI/milestones/M00-template-bootstrap.md"
    for token in planned ready done REVIEWING; do
        sed "s/^\*\*Status:\*\* .*/**Status:** ${token}/" "$milestone" > "${milestone}.tmp"
        mv "${milestone}.tmp" "$milestone"
        rc="$(run_capture "${work}/invalid.txt" "${fx}/Scripts/project-status.sh" validate)"
        expect_exit 65 "$rc" "invalid state '${token}' fails closed"
        git -C "$fx" checkout -q -- AI/milestones/M00-template-bootstrap.md
    done
}

case_milestone_current_head() {
    local fx="${SELFTEST_DIR}/current-head"
    local work="${SELFTEST_DIR}/current-head-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out before after sha latest report
    sha="$(fixture_candidate "$fx")"
    before="$(git -C "$fx" worktree list --porcelain | grep -c '^worktree ')"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/clean.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/clean.txt")"
    after="$(git -C "$fx" worktree list --porcelain | grep -c '^worktree ')"
    expect_exit 0 "$rc" "clean current HEAD milestone verification passes"
    expect_same "$before" "$after" "normal milestone verification creates no detached worktree"
    expect_contains "$out" "VERIFIED_COMMIT=${sha}" "normal mode verifies the exact HEAD SHA"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**Verification mode:** current-head" "report records current-head mode"
    expect_contains "$report" "**Branch:** main" "report records the branch"
    expect_contains "$report" "**Verification started:**" "report records a UTC start"
    expect_contains "$report" "**Verification completed:**" "report records a UTC completion"
    expect_contains "$report" "## Exact commands" "report records exact commands"
    expect_contains "$report" "total=3 passed=3 failed=0 skipped=0" "report records result-bundle counts"

    printf '// dirty\n' >> "${fx}/App/Fixture/Fixture.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/tracked.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "dirty tracked input blocks normal verification"
    git -C "$fx" checkout -q -- App/Fixture/Fixture.swift

    printf 'untracked\n' > "${fx}/UNTRACKED.input"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/untracked.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "untracked input blocks normal verification"
    rm -f "${fx}/UNTRACKED.input"

    printf 'App/Ignored.swift\n' >> "${fx}/.gitignore"
    fixture_commit_unchecked "$fx" "ignore a source input"
    printf 'let ignored = true\n' > "${fx}/App/Ignored.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ignored.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "relevant ignored input blocks normal verification"
    rm -f "${fx}/App/Ignored.swift"

    printf '%s\n' "$(git -C "$fx" rev-parse HEAD)" > "${fx}/.git/MERGE_HEAD"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/operation.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "an active Git operation blocks normal verification"
    rm -f "${fx}/.git/MERGE_HEAD"
}

# Milestones are sequential: each is developed in the primary checkout, on the
# primary branch, and committed there. A worktree and a branch outside it exist for
# post-milestone localization only, and a language is never verified as a milestone.
# `.iosai-project` is what records the branch name, so a product that renamed its
# primary branch is read rather than assumed — and a repository with no marker
# records nothing, which is a skip rather than an invented requirement.
case_milestone_branch_gate() {
    local fx="${SELFTEST_DIR}/branch-gate"
    local work="${SELFTEST_DIR}/branch-gate-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out reports_before reports_after

    # 1. No marker: nothing to assert, and the skip is reported rather than silent.
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/no-marker.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "a repository with no project marker still verifies"
    expect_contains "$(cat "${work}/no-marker.txt")" "primary-branch check does not apply" \
        "the skipped check is reported, not silent"

    # 2. Marker present, HEAD on the recorded branch.
    printf 'ios-ai-project/2\nowner=Fixture Owner\nprimary_branch=main\n' > "${fx}/.iosai-project"
    fixture_commit_unchecked "$fx" "record the primary branch"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/match.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "verification on the recorded primary branch passes"

    # 3. Marker present, HEAD elsewhere. A localization branch is the real case, and
    #    a refused run must publish no report and claim no verified commit.
    git -C "$fx" switch -q -c localization/de
    reports_before="$(find "${fx}/.artifacts/milestone/M00" -name 'report.md' 2>/dev/null | wc -l | tr -d ' ')"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/other.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/other.txt")"
    reports_after="$(find "${fx}/.artifacts/milestone/M00" -name 'report.md' 2>/dev/null | wc -l | tr -d ' ')"
    expect_exit 65 "$rc" "a milestone is not verified from a non-primary branch"
    expect_contains "$out" "milestone verification runs on the primary branch: main" \
        "the refusal names the branch it requires"
    expect_contains "$out" "localization/de" "the refusal names the branch it found"
    expect_absent "$out" "VERIFIED_COMMIT" "no commit is marked verified"
    expect_same "$reports_before" "$reports_after" "a refused run publishes no report"

    # 4. Candidate mode is branch-agnostic BY DESIGN and must stay so: reproducing an
    #    earlier commit is about that commit, never about where the caller stands.
    #    This is what proves the gate is confined to the no-candidate path.
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/candidate.txt" \
        fixture_milestone "$fx" M00)"
    # The mode banner prints before static, build and tests run, so it only says the
    # run started. The exit code and the verified commit say it finished.
    expect_exit 0 "$rc" "candidate mode still verifies from a non-primary branch"
    expect_contains "$(cat "${work}/candidate.txt")" "VERIFIED_COMMIT=$(fixture_candidate "$fx")" \
        "candidate mode verifies the requested commit from a non-primary branch"
    expect_contains "$(cat "${work}/candidate.txt")" "explicit-candidate" \
        "candidate mode still runs from a non-primary branch"
    expect_absent "$(cat "${work}/candidate.txt")" "runs on the primary branch" \
        "candidate mode carries no branch assertion"
    git -C "$fx" switch -q main

    # 5. A detached HEAD in the primary checkout is not the primary branch either.
    git -C "$fx" switch -q --detach
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/detached.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "a detached HEAD does not verify a milestone"
    expect_contains "$(cat "${work}/detached.txt")" "HEAD is detached" "the refusal says why"
    git -C "$fx" switch -q main

    # 6. A marker that answers the question with nothing is a missing record, not a
    #    reason to fall back to a guess: a gate that invented the branch it was
    #    supposed to require would be enforcing nothing.
    printf 'ios-ai-project/2\nowner=Fixture Owner\n' > "${fx}/.iosai-project"
    fixture_commit_unchecked "$fx" "drop the primary branch field"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/missing.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 66 "$rc" "a marker recording no primary branch is a missing record"
    expect_contains "$(cat "${work}/missing.txt")" "records no primary branch" \
        "the refusal names the field it needs"

    # 7. Two answers to the same question is ambiguity, not a merge.
    printf 'ios-ai-project/2\nprimary_branch=main\nprimary_branch=trunk\n' > "${fx}/.iosai-project"
    fixture_commit_unchecked "$fx" "two contradictory primary branches"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/two.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 66 "$rc" "two primary_branch lines are refused rather than resolved"

    # 8. A renamed primary branch is read from the marker, not assumed to be 'main'.
    printf 'ios-ai-project/2\nprimary_branch=trunk\n' > "${fx}/.iosai-project"
    fixture_commit_unchecked "$fx" "rename the primary branch"
    git -C "$fx" branch -q -M trunk
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/trunk.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "a product that renamed its primary branch verifies on that branch"
    git -C "$fx" branch -q -M main
    printf 'ios-ai-project/2\nprimary_branch=main\n' > "${fx}/.iosai-project"
    fixture_commit_unchecked "$fx" "restore the marker"

    # 9. The release gate is branch-agnostic by design and must carry no such check.
    git -C "$fx" switch -q -c localization/ja
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/release.txt" fixture_release "$fx")"
    # Absence of the branch message alone also held for any release failure.
    expect_exit 0 "$rc" "the release gate verifies a ready candidate from a non-primary branch"
    expect_contains "$(cat "${work}/release.txt")" "VERDICT=READY_FOR_HUMAN" \
        "the release verdict does not depend on the invoking branch"
    expect_absent "$(cat "${work}/release.txt")" "runs on the primary branch" \
        "the release gate carries no branch assertion"
    git -C "$fx" switch -q main
}

# The DONE line, the handoff and AI/PROJECT_STATUS.md follow the verified commit, and
# AI/WORKFLOW.md says those continuity records create no new candidate while code or
# configuration does. Nothing could tell the two apart, and the release checklist's
# "Archive from this candidate" could not be confirmed from a checkout that had moved
# on by a Markdown commit. `project-status.sh continuity` answers it, failing closed.
case_continuity_records() {
    local fx="${SELFTEST_DIR}/continuity"
    local work="${SELFTEST_DIR}/continuity-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local verified rc out path orphan mode
    verified="$(fixture_candidate "$fx")"
    cp "${fx}/AI/milestones/M00-template-bootstrap.md" "${work}/m00.pristine"

    rc="$(run_capture "${work}/same.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
    expect_exit 0 "$rc" "HEAD that is the verified commit passes"
    expect_contains "$(cat "${work}/same.txt")" "HEAD is the verified commit itself" \
        "the pass says nothing has followed the verified commit"

    # The continuity records a Builder commits after the verified commit.
    printf '**Policy status:** current\n\n# M00 handoff\n' > "${fx}/AI/handoffs/M00-handoff.md"
    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** DONE/' "${work}/m00.pristine" \
        > "${fx}/AI/milestones/M00-template-bootstrap.md"
    fixture_commit_unchecked "$fx" "record DONE"
    rc="$(run_capture "${work}/records.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
    out="$(cat "${work}/records.txt")"
    expect_exit 0 "$rc" "a commit of Markdown under AI/ alone keeps the verified build inputs"
    expect_contains "$out" "AI/handoffs/M00-handoff.md" "the continuity records that changed are listed"
    expect_contains "$out" "carries exactly the build inputs of ${verified}" \
        "the pass names the verified commit it compared against"

    # Anything else after the verified commit is a new candidate: code, configuration,
    # Markdown outside AI/, and a file under AI/ that is not Markdown.
    for path in App/Late.swift Config/project.env README.md AI/diagram.png; do
        printf '\n# changed after verification\n' >> "${fx}/${path}"
        fixture_commit_unchecked "$fx" "change ${path} after verification"
        rc="$(run_capture "${work}/outside.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
        out="$(cat "${work}/outside.txt")"
        expect_exit 65 "$rc" "a change to ${path} after the verified commit is refused"
        expect_contains "$out" "$path" "the refusal names ${path}"
        git -C "$fx" reset -q --hard HEAD~1
    done

    # A rename is two paths, and the one it leaves is outside AI/.
    git -C "$fx" mv App/.gitkeep AI/moved-from-app.md
    fixture_commit_unchecked "$fx" "rename out of App/"
    rc="$(run_capture "${work}/rename.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
    expect_exit 65 "$rc" "a rename out of App/ into AI/ Markdown is refused"
    expect_contains "$(cat "${work}/rename.txt")" "App/.gitkeep" "the refusal names the path that left App/"
    git -C "$fx" reset -q --hard HEAD~1

    # Uncommitted bytes would reach a build, and an Archive, made from this checkout.
    printf '\n<!-- uncommitted -->\n' >> "${fx}/AI/PRODUCT.md"
    rc="$(run_capture "${work}/dirty.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
    expect_exit 65 "$rc" "an uncommitted change is refused even where it is Markdown under AI/"
    git -C "$fx" checkout -q -- AI/PRODUCT.md

    # The verified commit must be what HEAD is built on.
    orphan="$(printf 'unrelated\n' | git -C "$fx" commit-tree "HEAD^{tree}")"
    rc="$(run_capture "${work}/orphan.txt" "${fx}/Scripts/project-status.sh" continuity "$orphan")"
    expect_exit 65 "$rc" "a verified commit that is not an ancestor of HEAD is refused"
    expect_contains "$(cat "${work}/orphan.txt")" "not an ancestor of HEAD" "the refusal says why"

    # Only a full SHA names the verified commit, exactly as at every gate.
    rc="$(run_capture "${work}/short.txt" "${fx}/Scripts/project-status.sh" continuity \
        "$(git -C "$fx" rev-parse --short "$verified")")"
    expect_exit 64 "$rc" "an abbreviated SHA is refused"
    rc="$(run_capture "${work}/ref.txt" "${fx}/Scripts/project-status.sh" continuity HEAD)"
    expect_exit 64 "$rc" "a symbolic ref is refused"
    rc="$(run_capture "${work}/unknown.txt" "${fx}/Scripts/project-status.sh" continuity \
        0000000000000000000000000000000000000000)"
    expect_exit 65 "$rc" "an unknown full SHA is refused"
    rc="$(run_capture "${work}/none.txt" "${fx}/Scripts/project-status.sh" continuity)"
    expect_exit 64 "$rc" "a missing SHA is a usage error"
    rc="$(run_capture "${work}/extra.txt" "${fx}/Scripts/project-status.sh" continuity "$verified" extra)"
    expect_exit 64 "$rc" "a second argument is a usage error"

    # A Git query that cannot answer is a refusal, never a pass.
    mode="$(stat -f '%Lp' "${fx}/.git/index")"
    chmod 000 "${fx}/.git/index"
    rc="$(run_capture "${work}/unreadable.txt" "${fx}/Scripts/project-status.sh" continuity "$verified")"
    chmod "$mode" "${fx}/.git/index"
    expect_exit 65 "$rc" "an unreadable index fails the continuity check closed"
    expect_absent "$(cat "${work}/unreadable.txt")" "carries exactly the build inputs" \
        "no continuity is claimed for a checkout that could not be read"
}

case_project_initialization() {
    local fx="${SELFTEST_DIR}/fresh project copy with spaces"
    local work="${SELFTEST_DIR}/initialization-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    # Committed before old_head is captured, so the removal assertions below
    # compare a real record set against .gitkeep rather than .gitkeep against
    # itself. The template ships no records of its own to reset.
    fixture_plant_records "$fx"
    # Branch memory the rewrite has to drop. Injected rather than named from this
    # repository's own history: a literal old branch name would both ship that
    # history in the template and go vacuous the moment the status file stopped
    # mentioning it, passing whether or not the field was ever rewritten.
    sed 's|^\*\*Important decisions:\*\* .*|**Important decisions:** work continues on branch FIXTURE_BRANCH_MEMORY_SENTINEL|' \
        "${fx}/AI/PROJECT_STATUS.md" > "${fx}/AI/PROJECT_STATUS.md.new"
    mv "${fx}/AI/PROJECT_STATUS.md.new" "${fx}/AI/PROJECT_STATUS.md"
    fixture_commit_unchecked "$fx" "plant fixture records and branch memory"
    local old_head bare rc out
    old_head="$(git -C "$fx" rev-parse HEAD)"
    expect_contains "$(cat "${fx}/AI/PROJECT_STATUS.md")" "FIXTURE_BRANCH_MEMORY_SENTINEL" \
        "the fixture carried branch memory into the run"
    bare="$(fixture_bare_remote "$fx")"
    git -C "$fx" branch template-history
    git -C "$fx" tag template-v1

    rc="$(run_capture "${work}/initialize.txt" "${fx}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Fixture Owner" --email fixture@example.invalid)"
    out="$(cat "${work}/initialize.txt")"
    expect_exit 0 "$rc" "a fresh committed copy initializes from a path with spaces"
    expect_contains "$out" "PRIMARY_CHECKOUT=$(physical_path "$fx")" "initialization reports the primary checkout"
    expect_contains "$out" "REACHABLE_COMMITS=1" "initialization reports one reachable project commit"
    # The history that held the template commit is pruned below and its remote
    # removed, yet M00's handoff has to cite that commit. The marker keeps it.
    expect_contains "$(cat "${fx}/.iosai-project")" "template_commit=${old_head}" \
        "the project marker records the exact template commit M00 cites"
    expect_contains "$out" "TEMPLATE_COMMIT=${old_head}" "initialization reports the template commit"
    expect_contains "$out" "product initialization prompt" \
        "the next step names product initialization before M00"
    expect_same "" "$(git -C "$fx" config --get core.hooksPath 2>/dev/null || true)" \
        "project initialization leaves core.hooksPath unset"
    expect_same "1" "$(git -C "$fx" rev-list --all --count)" "template history is replaced by one reachable root commit"
    expect_same "" "$(git -C "$fx" remote)" "template remotes are removed"
    expect_same "" "$(git -C "$fx" tag -l)" "template tags are removed"
    expect_same "main" \
        "$(git -C "$fx" for-each-ref --format='%(refname:short)' refs/heads | sort | tr '\n' ' ' | sed 's/ $//')" \
        "default initialization leaves only the primary branch"
    if git -C "$fx" cat-file -e "${old_head}^{commit}" 2>/dev/null; then
        check fail "the template commit remains in the object database after prune"
    else
        check pass "the template commit is unreachable and pruned"
    fi
    expect_same ".gitkeep" "$(find "${fx}/AI/audits" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//')" \
        "template audits are removed"
    expect_same ".gitkeep" "$(find "${fx}/AI/handoffs" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//')" \
        "template handoffs are removed"
    expect_same "M00-template-bootstrap.md" "$(find "${fx}/AI/milestones" -maxdepth 1 -type f -exec basename {} \; | sort)" \
        "only M00 remains"
    expect_absent "$(cat "${fx}/AI/PROJECT_STATUS.md")" "FIXTURE_BRANCH_MEMORY_SENTINEL" "fresh status contains no source-repository branch memory"
    expect_absent "$(cat "${fx}/AI/PROJECT_STATUS.md")" "$old_head" "fresh status contains no template SHA memory"
    expect_contains "$(cat "${fx}/Config/project.env")" 'TEMPLATE_REPOSITORY="true"' "fresh configuration remains template mode"

    # The seed is RENDERED by configure-project.sh, not copied from a committed
    # Config/project.env.template. The file is gone, so the check is that the
    # rendered configuration is complete rather than that a static file was copied.
    local seed_key
    if [ -e "${fx}/Config/project.env.template" ]; then
        check fail "the removed Config/project.env.template reappeared"
    else
        check pass "no parallel configuration seed file is left to drift"
    fi
    for seed_key in $IOSAI_CONFIG_KEYS; do
        if ! grep -Eq "^${seed_key}=\"" "${fx}/Config/project.env"; then
            check fail "the rendered seed is missing the key ${seed_key}"
        fi
    done
    check pass "the rendered seed carries every documented configuration key"

    # A project owns its README. The template's own guide describes the template —
    # how to initialize a copy, how to update the template itself — and a new
    # repository inherited it verbatim.
    local fresh_readme
    fresh_readme="$(cat "${fx}/README.md")"
    expect_absent "$fresh_readme" 'iOS AI project template' "an initialized project does not inherit the template's title"
    expect_absent "$fresh_readme" '## Updating this template' "an initialized project does not inherit template maintenance instructions"
    expect_contains "$fresh_readme" 'Fixture Owner' "the project README names its owner"
    expect_contains "$fresh_readme" 'AI/PRODUCT_BRIEF.md' "the project README points at the first thing to fill in"

    # Initialization is what deletes the template README, and all three prompts are
    # needed AFTER it runs. If they do not survive, the developer has to go back to
    # the template repository to remember how to drive their own project. The same
    # three literals are asserted against the template README in
    # case_documentation_consistency, so editing one copy without the other fails.
    expect_contains "$fresh_readme" 'Initialize the product from AI/PRODUCT_BRIEF.md.' \
        "the project README keeps the product initialization prompt"
    expect_contains "$fresh_readme" 'Stop when my approval is required.' \
        "the project README keeps the approval boundary of that prompt"
    expect_contains "$fresh_readme" 'Execute the next ready milestone end-to-end.' \
        "the project README keeps the milestone prompt"
    expect_contains "$fresh_readme" 'AI/WORKFLOW.md' \
        "the project README points at the normative workflow contract"

    expect_contains "$fresh_readme" 'Run the final product polish workflow end-to-end.' \
        "the project README preserves the third canonical prompt"
    expect_contains "$fresh_readme" 'Final Product Polish' \
        "the project README names the consolidated final milestone"
    # The template README that said Xcode work is the developer's is deleted here, so
    # the replacement has to say it, or the M00 session reads "add the project" as
    # its own job.
    expect_contains "$fresh_readme" 'create the' \
        "the project README tells the developer to create the Xcode project"
    expect_contains "$fresh_readme" 'Xcode project or workspace under `App/` in Xcode' \
        "the project README names where the developer's Xcode project goes"

    # Initialization produces an application repository, not an App Store listing.
    # A product built from an earlier template grew AI/STORE_TEXT.md and ten locale
    # variants because the workflow kept asking for store copy; a fresh repository
    # must contain no such file and must not promise one. The filesystem check is the
    # load-bearing half — a seed README that merely stays quiet about a file the
    # scripts still write would pass the string check and fail the developer.
    expect_absent "$fresh_readme" 'STORE_TEXT' \
        "the project README does not name a store-listing file"
    expect_absent "$fresh_readme" 'App Store metadata' \
        "the project README does not promise App Store metadata generation"
    local seeded_listing_files
    seeded_listing_files="$(find "$fx" -name '*STORE_TEXT*' -not -path '*/.git/*' 2>/dev/null || true)"
    if [ -n "$seeded_listing_files" ]; then
        check fail "initialization created a store-listing file: $(printf '%s' "$seeded_listing_files" | tr '\n' ' ')"
    else
        check pass "initialization creates no store-listing file anywhere in the project"
    fi

    # And the derived project must still validate with that README, including the
    # suite that asserts the TEMPLATE's README content.
    rc="$(run_capture "${work}/derived-template.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a derived project with its own README still passes template validation"
    rc="$(run_capture "${work}/derived-static.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a derived project with its own README still passes static verification"

    expect_same "1" "$(git -C "$fx" worktree list --porcelain | grep -c '^worktree ')" \
        "initialization creates no worktree"
    [ ! -e "${fx}/App/Fixture.xcodeproj" ] && check pass "initialization adds no Xcode project" \
        || check fail "initialization created product/Xcode bytes"

    local before_rerun after_rerun
    before_rerun="$(git -C "$fx" rev-parse HEAD):$(git -C "$fx" status --porcelain):$(git -C "$fx" worktree list --porcelain | shasum -a 256)"
    rc="$(run_capture "${work}/rerun.txt" "${fx}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Fixture Owner" --email fixture@example.invalid)"
    expect_exit 65 "$rc" "an initialization rerun is refused"
    after_rerun="$(git -C "$fx" rev-parse HEAD):$(git -C "$fx" status --porcelain):$(git -C "$fx" worktree list --porcelain | shasum -a 256)"
    expect_same "$before_rerun" "$after_rerun" "rerun refusal changes no repository or worktree state"

    local unborn="${SELFTEST_DIR}/unborn project copy"
    fixture_copy "$unborn"
    git -C "$unborn" init -q .
    git -C "$unborn" config user.name "Preflight User"
    git -C "$unborn" config user.email preflight@example.invalid
    rc="$(run_capture "${work}/unborn.txt" "${unborn}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Unborn Owner" --email unborn@example.invalid)"
    expect_exit 0 "$rc" "an unborn fresh repository initializes deterministically"
    expect_same "" "$(git -C "$unborn" config --get core.hooksPath 2>/dev/null || true)" \
        "unborn initialization also leaves hooks unset"
    expect_same "1" "$(git -C "$unborn" rev-list --all --count)" "unborn initialization creates one root commit"
    expect_same "1" "$(git -C "$unborn" worktree list --porcelain | grep -c '^worktree ')" \
        "unborn initialization also creates no worktree"
    expect_contains "$(cat "${unborn}/.iosai-project")" "template_commit=unknown" \
        "an unborn copy records that it has no template commit to name"

    # The retired M00-worktree options are refused, not silently ignored. Milestones
    # are developed in the primary checkout, so there is nothing for them to create —
    # and an option that was quietly dropped would leave a caller believing it worked.
    local retired="${SELFTEST_DIR}/retired option copy"
    local never="${SELFTEST_DIR}/never created worktree"
    local retired_head
    fixture_template "$retired" "$work"
    retired_head="$(git -C "$retired" rev-parse HEAD)"
    rc="$(run_capture "${work}/retired.txt" "${retired}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Retired Owner" --email retired@example.invalid \
        --worktree-path "$never")"
    expect_exit 64 "$rc" "the retired --worktree-path option is refused, not ignored"
    expect_contains "$(cat "${work}/retired.txt")" "unknown initialization argument" \
        "the refusal names the unknown argument"
    expect_same "$retired_head" "$(git -C "$retired" rev-parse HEAD)" \
        "a refused option leaves Git history untouched"
    [ ! -e "${retired}/.iosai-project" ] && check pass "a refused option initializes nothing" \
        || check fail "a refused option still wrote the project marker"
    [ ! -e "$never" ] && check pass "the retired option created no directory" \
        || check fail "the retired option still created a directory"

    rc="$(run_capture "${work}/retired-enter.txt" "${retired}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Retired Owner" --email retired@example.invalid --enter)"
    expect_exit 64 "$rc" "the retired --enter option is refused too"

    # Records survive a refusal that happens before the reset.
    local guarded="${SELFTEST_DIR}/guarded fresh copy"
    local guarded_head
    fixture_template "$guarded" "$work"
    fixture_plant_records "$guarded"
    fixture_commit_unchecked "$guarded" "plant fixture records"
    guarded_head="$(git -C "$guarded" rev-parse HEAD)"
    rc="$(run_capture "${work}/overwrite.txt" "${guarded}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Guarded|Owner" --email guarded@example.invalid)"
    expect_exit 64 "$rc" "an unusable owner is refused before reset"
    expect_same "$guarded_head" "$(git -C "$guarded" rev-parse HEAD)" "the refusal preserves Git history"
    [ -f "${guarded}/AI/audits/fixture-probe-audit.md" ] \
        && check pass "the refusal preserves audit memory before authorization completes" \
        || check fail "the refusal partially reset the repository"

    # An invalid template copy is now caught BEFORE anything is rewritten. This
    # used to empty AI/audits/ and AI/handoffs/, rewrite PROJECT_STATUS.md and
    # Config/project.env, and only then run verify-template.sh — so a broken copy
    # exited 65 having already discarded the records, with no next step printed.
    local broken="${SELFTEST_DIR}/broken fresh copy"
    local broken_head audits_before audits_after handoffs_before handoffs_after
    fixture_template "$broken" "$work"
    fixture_plant_records "$broken"
    printf 'BOGUS_UNKNOWN_KEY="x"\n' >> "${broken}/Config/project.env.example"
    fixture_commit_unchecked "$broken" "break a template-check input"
    broken_head="$(git -C "$broken" rev-parse HEAD)"
    # Compared before against after, never against a hardcoded list of filenames:
    # a project's record set grows every time an audit is added, and an
    # expected-literal list would fail on the next one for no reason of its own.
    # .gitkeep is excluded because it survives a reset by design — counting it
    # would make the emptiness guard below pass on a directory with no records.
    audits_before="$(find "${broken}/AI/audits" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' | sort | sed "s|^${broken}/||")"
    handoffs_before="$(find "${broken}/AI/handoffs" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' | sort | sed "s|^${broken}/||")"
    rc="$(run_capture "${work}/broken.txt" "${broken}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Broken Owner" --email broken@example.invalid)"
    out="$(cat "${work}/broken.txt")"
    expect_exit 65 "$rc" "an invalid template copy is refused"
    expect_same "$broken_head" "$(git -C "$broken" rev-parse HEAD)" \
        "the refusal leaves Git history untouched"
    [ -f "${broken}/AI/audits/fixture-probe-audit.md" ] \
        && check pass "validation runs before the reset, so existing records survive" \
        || check fail "records were reset before validation failed"
    audits_after="$(find "${broken}/AI/audits" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' | sort | sed "s|^${broken}/||")"
    handoffs_after="$(find "${broken}/AI/handoffs" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' | sort | sed "s|^${broken}/||")"
    if [ -z "$audits_before" ] || [ -z "$handoffs_before" ]; then
        check fail "the record directories were empty before the run; this check proves nothing"
    else
        check pass "the fixture carried real records into the run"
    fi
    expect_same "$audits_before" "$audits_after" "every audit record is intact after the refusal"
    expect_same "$handoffs_before" "$handoffs_after" "every handoff record is intact after the refusal"
    expect_same "" "$(git -C "$broken" status --porcelain)" \
        "the refusal leaves no uncommitted mutation behind"

    # The pre-flight makes a post-reset failure very hard to reach, which is the
    # point — but if one ever happens the script must still say how to recover, so
    # the guidance itself is guarded against silent deletion.
    expect_contains "$(cat "${broken}/Scripts/initialize-project.sh")" 'git clean -fd' \
        "initialization retains recovery guidance for a post-reset failure"

    # ---- Unsaved work is not deleted, and no false recovery is offered -------
    #
    # A template obtained as an archive and `git init`-ed has no commits, so the
    # dirty-tree guard at the top of the script — `git_has_commits && [ -n
    # "$(git status --porcelain)" ]` — was skipped in exactly the state where
    # nothing is recoverable. An audit reproduced the result: one drafted
    # milestone, `make initialize`, exit 0, "ok new project repository
    # initialized", and the draft gone with no reference to it anywhere in Git.
    #
    # The guard is the one App/ already had: product bytes prove work has begun,
    # so refuse rather than delete.
    local drafted="${SELFTEST_DIR}/drafted unborn copy"
    fixture_copy "$drafted"
    git -C "$drafted" init -q .
    # No commit: an unborn copy has nothing to commit to, which is the whole
    # point of this case. The probes are uncommitted bytes the guard must spare.
    fixture_plant_records "$drafted"
    cat > "${drafted}/AI/milestones/M07-draft.md" <<'DRAFT'
# M07 — Drafted before initialization
**ID:** M07
**Status:** PLANNED
**Depends on:** M00
**Validation:** make milestone ID=M07
**Handoff:** AI/handoffs/M07-handoff.md
## Objective
Work a developer or an agent already did.
## Scope
- Something real.
## Non-goals
- Nothing.
## Acceptance criteria
- [ ] It survives initialization, or initialization refuses to run.
DRAFT
    rc="$(run_capture "${work}/drafted.txt" "${drafted}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Drafted Owner" --email drafted@example.invalid)"
    out="$(cat "${work}/drafted.txt")"
    expect_exit 65 "$rc" "initialization refuses a copy that already holds milestone drafts"
    [ -f "${drafted}/AI/milestones/M07-draft.md" ] \
        && check pass "the drafted milestone survived the refusal" \
        || check fail "the drafted milestone was deleted"
    expect_contains "$out" "AI/milestones already holds drafted work" \
        "the refusal names the work it protected"
    expect_same "0" "$(git -C "$drafted" rev-list --all --count 2>/dev/null || printf '0')" \
        "the drafted-work refusal creates no commit"
    [ -f "${drafted}/AI/audits/fixture-probe-audit.md" ] \
        && check pass "existing records survive the drafted-work refusal" \
        || check fail "records were reset before the drafted-work guard ran"

    # The guard must not mistake a product-slugged M00 for drafted work: naming
    # M00 is the project's business (see case_product_repository_identity).
    local renamed="${SELFTEST_DIR}/renamed M00 unborn copy"
    fixture_copy "$renamed"
    git -C "$renamed" init -q .
    mv "${renamed}/AI/milestones/M00-template-bootstrap.md" \
       "${renamed}/AI/milestones/M00-product-bootstrap.md"
    rc="$(run_capture "${work}/renamed.txt" "${renamed}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Renamed Owner" --email renamed@example.invalid)"
    expect_exit 0 "$rc" "a product-slugged M00 is not mistaken for drafted work"
    expect_same "M00-product-bootstrap.md" \
        "$(find "${renamed}/AI/milestones" -maxdepth 1 -type f -exec basename {} \; | sort)" \
        "the renamed M00 is kept by initialization"

    # ---- Recovery guidance must be true in the state that prints it ----------
    #
    # The post-reset hint asserted "every original file is still recoverable from
    # HEAD" and offered `git checkout -- . && git clean -fd` unconditionally. In an
    # unborn copy there is no HEAD: checkout errors, and clean removes every
    # top-level path — Scripts/, AI/, Config/, the Makefile, the copy itself.
    local aborted="${SELFTEST_DIR}/aborted unborn copy"
    fixture_copy "$aborted"
    git -C "$aborted" init -q .
    # Fails only AFTER the reset. verify-template.sh checks that this script exists,
    # is executable and parses — never that it succeeds — so the pre-flight passes.
    printf '#!/usr/bin/env bash\nexit 1\n' > "${aborted}/Scripts/project-status.sh"
    chmod +x "${aborted}/Scripts/project-status.sh"
    rc="$(run_capture "${work}/aborted.txt" "${aborted}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Aborted Owner" --email aborted@example.invalid)"
    out="$(cat "${work}/aborted.txt")"
    if [ "$rc" = "0" ]; then
        check fail "the aborted fixture did not abort; the guidance checks below prove nothing"
    else
        check pass "initialization aborted after the reset in an unborn copy (exit ${rc})"
    fi
    expect_contains "$out" "cannot be undone from Git" \
        "an unborn copy is warned before the reset that it is unrecoverable"
    expect_absent "$out" "recoverable from HEAD" \
        "no HEAD-recoverability is claimed where there is no HEAD"
    expect_absent "$out" "git clean -fd" \
        "no destructive recovery command where every path is untracked"

    # The committed arm keeps its guidance, because there it is correct.
    local committed_abort="${SELFTEST_DIR}/aborted committed copy"
    fixture_template "$committed_abort" "$work"
    printf '#!/usr/bin/env bash\nexit 1\n' > "${committed_abort}/Scripts/project-status.sh"
    chmod +x "${committed_abort}/Scripts/project-status.sh"
    fixture_commit_unchecked "$committed_abort" "break post-reset validation"
    rc="$(run_capture "${work}/committed-abort.txt" \
        "${committed_abort}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner "Committed Owner" --email committed@example.invalid)"
    out="$(cat "${work}/committed-abort.txt")"
    expect_contains "$out" "recoverable from HEAD" \
        "a committed copy is still told it can restore from HEAD"
    expect_contains "$out" "git clean -fd" \
        "a committed copy still receives the recovery command that works there"
}

case_initialization_failure_closed() {
    local fx="${SELFTEST_DIR}/initialization-errors" work="${SELFTEST_DIR}/initialization-errors-work"
    local rc out mode sha refs before_index real_git real_find physical_fx
    fixture_template "$fx" "$work"
    fixture_plant_records "$fx"
    fixture_commit_unchecked "$fx" "records that initialization must preserve on refusal"
    sha="$(fixture_candidate "$fx")"
    refs="$(git -C "$fx" show-ref)"
    cp "${fx}/.git/index" "${work}/index.base"
    printf '\nUnsaved initialization sentinel\n' >> "${fx}/README.md"
    cp "${fx}/README.md" "${work}/README.before"

    for mode in corrupt unreadable; do
        cp "${work}/index.base" "${fx}/.git/index"
        if [ "$mode" = corrupt ]; then
            printf 'broken index\n' > "${fx}/.git/index"
        fi
        before_index="$(shasum -a 256 "${fx}/.git/index" | awk '{print $1}')"
        [ "$mode" != unreadable ] || chmod 000 "${fx}/.git/index"
        rc="$(run_capture "${work}/${mode}-status.txt" git -C "$fx" status --porcelain)"
        expect_exit 128 "$rc" "the ${mode} index actually prevents Git status"
        rc="$(run_capture "${work}/${mode}.txt" "${fx}/Scripts/initialize-project.sh" \
            --confirm-new-project --owner 'Fixture Owner' --email fixture@example.invalid)"
        chmod 0644 "${fx}/.git/index"
        out="$(cat "${work}/${mode}.txt")"
        expect_exit 65 "$rc" "initialization refuses a ${mode} index"
        expect_contains "$out" 'could not read the working tree state' "the ${mode} refusal explains uncertainty"
        expect_same "$(cat "${work}/README.before")" "$(cat "${fx}/README.md")" \
            "the ${mode} refusal preserves unsaved README work"
        expect_same "$sha" "$(fixture_candidate "$fx")" "the ${mode} refusal preserves HEAD"
        expect_same "$refs" "$(git -C "$fx" show-ref)" "the ${mode} refusal preserves refs"
        expect_same "$before_index" "$(shasum -a 256 "${fx}/.git/index" | awk '{print $1}')" \
            "the ${mode} refusal leaves the index content untouched"
        [ ! -e "${fx}/.iosai-project" ] && check pass "the ${mode} refusal writes no marker" \
            || check fail "the ${mode} refusal wrote a marker"
        [ -f "${fx}/AI/audits/fixture-probe-audit.md" ] \
            && [ -f "${fx}/AI/handoffs/fixture-probe-handoff.md" ] \
            && check pass "the ${mode} refusal preserves both record directories" \
            || check fail "the ${mode} refusal erased records"
    done
    cp "${work}/index.base" "${fx}/.git/index"
    git -C "$fx" checkout -q -- README.md

    # Other preflight queries must fail before the first reset too.
    mkdir -p "${work}/bin"
    real_git="$(command -v git)"
    real_find="$(command -v find)"
    physical_fx="$(physical_path "$fx")"
    cat > "${work}/bin/git" <<'STUB'
#!/usr/bin/env bash
case "${STUB_INIT_QUERY:-}:$*" in
    worktrees:*'worktree list --porcelain'*) exit 73 ;;
    operations:*'rev-parse --git-path'*) exit 73 ;;
    head:*'rev-parse --verify --quiet HEAD'*) exit 73 ;;
esac
exec "${STUB_REAL_GIT:?}" "$@"
STUB
    chmod +x "${work}/bin/git"
    cat > "${work}/bin/find" <<'STUB'
#!/usr/bin/env bash
if [ "${STUB_INIT_QUERY:-}" = app-scan ] && [ "${1:-}" = "${STUB_INIT_ROOT:?}/App" ]; then
    exit 73
fi
exec "${STUB_REAL_FIND:?}" "$@"
STUB
    chmod +x "${work}/bin/find"
    rc="$(STUB_INIT_QUERY=app-scan STUB_INIT_ROOT="$physical_fx" STUB_REAL_FIND="$real_find" \
        run_capture "${work}/find-control.txt" "${work}/bin/find" "${physical_fx}/App" \
        -mindepth 1 ! -name '.gitkeep' -print -quit)"
    expect_exit 73 "$rc" "the find fault targets the initializer's physical App path"
    for mode in worktrees operations head app-scan; do
        rc="$(PATH="${work}/bin:$PATH" STUB_REAL_GIT="$real_git" STUB_INIT_QUERY="$mode" \
            STUB_REAL_FIND="$real_find" STUB_INIT_ROOT="$physical_fx" \
            run_capture "${work}/${mode}.txt" "${fx}/Scripts/initialize-project.sh" \
            --confirm-new-project --owner 'Fixture Owner' --email fixture@example.invalid)"
        expect_exit 65 "$rc" "a failed ${mode} query refuses initialization"
        expect_contains "$(cat "${work}/${mode}.txt")" 'could not' "the failed ${mode} query is explained"
        expect_same "$sha" "$(fixture_candidate "$fx")" "the failed ${mode} query preserves HEAD"
        rc="$(run_capture "${work}/${mode}-after.txt" git -C "$fx" status --porcelain)"
        expect_exit 0 "$rc" "Git status still works after the failed ${mode} query"
        expect_same "" "$(cat "${work}/${mode}-after.txt")" "the failed ${mode} query leaves every file untouched"
    done
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/initialize-project.sh" \
        --confirm-new-project --owner 'Fixture Owner' --email fixture@example.invalid)"
    expect_exit 0 "$rc" "the restored clean copy still initializes normally"
}

case_documentation_consistency() {
    local readme makefile milestone_rule workflow agents handoff doc body token verdicts headings
    local template_readme="yes"
    readme="$(cat "${IOSAI_ROOT}/README.md")"
    makefile="$(cat "${IOSAI_ROOT}/Makefile")"
    agents="$(cat "${IOSAI_ROOT}/AGENTS.md")"
    workflow="$(cat "${IOSAI_ROOT}/AI/WORKFLOW.md")"
    handoff="$(cat "${IOSAI_ROOT}/AI/templates/handoff-template.md")"

    # A project made from the template owns its README — initialize-project.sh
    # replaces the template's own guide with a short product one, and
    # verify-template.sh already exempts README.md's structure there
    # (IOSAI_TEMPLATE_ONLY_HEADING_DOCS). These assertions are about the TEMPLATE's
    # guide, so they are skipped on the same discriminator. Without this, every
    # derived project failed this case the moment it ran `make integration`, which
    # executes this suite in template mode.
    if [ -e "${IOSAI_ROOT}/.iosai-project" ] || [ -L "${IOSAI_ROOT}/.iosai-project" ]; then
        template_readme="no"
    fi

    expect_contains "$agents" 'solo-workflow/2' "AGENTS declares the policy version"
    expect_contains "$workflow" 'solo-workflow/2' "WORKFLOW declares the policy version"

    for body in "$agents" "$workflow"; do
        expect_contains "$body" 'synchronization' "normative policy states synchronization semantics"
    done
    if [ "$template_readme" = "yes" ]; then
        expect_contains "$readme" 'solo-workflow/2' "README declares the policy version"
        expect_contains "$readme" 'synchronization' "README states synchronization semantics"
        expect_contains "$readme" 'make milestone ID=M03' "README documents clean-HEAD milestone verification"
        expect_contains "$readme" 'CANDIDATE=<full-SHA>' "README documents explicit historical candidates"

        # The three prompts that drive the lifecycle exist in two places: here, and
        # the stub initialize-project.sh writes over this file. Pinning both to the
        # same literals is the drift guard — case_project_initialization asserts the
        # other copy, so changing one alone fails the suite.
        expect_contains "$readme" 'Initialize the product from AI/PRODUCT_BRIEF.md.' \
            "README documents the product initialization prompt"
        expect_contains "$readme" 'Execute the next ready milestone end-to-end.' \
            "README documents the milestone prompt"
        expect_contains "$readme" 'Run the final product polish workflow end-to-end.' \
            "README documents the final polish prompt"
        expect_contains "$readme" 'Stop when my approval is required.' \
            "README preserves the initialization approval boundary"
        expect_contains "$readme" '## The three prompts you need' \
            "README states that three prompts drive the whole lifecycle"
    else
        check pass "README content assertions skipped (a project made from the template owns its README)"
    fi
    expect_contains "$workflow" '## Conditional integration' "integration is documented as conditional"

    # Integration substitutes the repository self-test in template mode, where there
    # is no application to build. WORKFLOW described only the product-mode path, so a
    # multi-minute template run looked like a hang or a wrong gate.
    expect_contains "$workflow" 'self-test' "WORKFLOW documents what integration runs in template mode"
    expect_contains "$workflow" 'no application target' "WORKFLOW says why template mode substitutes"

    # Fast tolerates skipped tests; the strict gates do not. Documenting only the
    # strict rule left the difference to be discovered from the source.
    expect_contains "$workflow" 'accepts skipped tests' "WORKFLOW documents the fast skipped-test policy"
    expect_contains "$workflow" 'reject a skipped mandatory test' "WORKFLOW documents the strict skipped-test policy"

    # The superseded-string family that used to be asserted here — 'make push-check',
    # 'push-check:', 'ready-for-integration', 'CANDIDATE=<sha>', 'release-requirements/2'
    # and 'release-requirements.v2.tsv' — is now enforced by verify-template.sh, so it
    # runs on every `make static` and every optional pre-commit rather than only in
    # this suite. case_live_doc_vocabulary asserts that GUARD, which is strictly more
    # than asserting the strings' absence once.

    # make help is the authoritative target list; a hand-copied inventory drifts.
    expect_contains "$agents" 'make help' "AGENTS points at the authoritative target list"
    milestone_rule="$(awk '/^milestone:/{inside=1} /^integration:/{inside=0} inside{print}' \
        "${IOSAI_ROOT}/Makefile")"
    expect_absent "$milestone_rule" 'ifndef CANDIDATE' "Make milestone no longer requires a candidate"
    expect_absent "$makefile" '--enter' "make initialize stays in the primary checkout"

    # The retired M00-worktree options are gone from the script itself, not only from
    # the Makefile that used to be able to pass them. Milestones are developed in the
    # primary checkout, so initialization has no worktree to create or enter.
    local init_text
    init_text="$(cat "${IOSAI_ROOT}/Scripts/initialize-project.sh")"
    expect_absent "$init_text" '--worktree-path' "initialization no longer creates a worktree"
    expect_absent "$init_text" 'opt_enter' "initialization no longer enters one"
    expect_contains "$makefile" 'LOCALE' "the worktree target takes a locale"
    expect_absent "$makefile" 'create-worktree.sh "$(ID)"' \
        "the worktree target no longer passes a milestone ID"
    if [ "$template_readme" = "yes" ]; then
        expect_contains "$readme" 'Setup and initialization never install it' "README rejects automatic hook installation"
    fi
    headings="$(grep '^## ' <<<"$handoff")"
    expect_same $'## Milestone\n## Summary\n## Changed files\n## Validation\n## Tests\n## Known issues\n## Next step' \
        "$headings" "handoff has exactly the seven useful sections"

    for doc in AI/OPERATING_MANUAL.md AI/LOCAL_VERIFICATION_POLICY.md \
               AI/RELEASE_CRITERIA.md AI/UX_CONTRACT.md AI/DESIGN_SYSTEM.md \
               AI/roles AI/checklists AI/decisions; do
        if [ -e "${IOSAI_ROOT}/${doc}" ]; then
            check fail "obsolete live path remains: ${doc}"
        else
            check pass "obsolete live path is absent: ${doc}"
        fi
    done

    # Every release verdict emitted by the gate remains documented.
    verdicts="$( { grep -oE 'emit_verdict [A-Z_]+' "${IOSAI_ROOT}/Scripts/verify-release.sh" \
                     | awk '{print $2}'
                   grep -oE 'VERDICT="[A-Z_]+"' "${IOSAI_ROOT}/Scripts/verify-release.sh" \
                     | sed 's/^VERDICT="//; s/"$//'
                 } | sort -u)"
    if [ -z "$verdicts" ]; then
        check fail "no release verdict tokens could be extracted from verify-release.sh"
    fi
    while IFS= read -r token; do
        [ -n "$token" ] || continue
        expect_contains "$workflow" "$token" "WORKFLOW documents verdict ${token}"
    done <<EOF
$verdicts
EOF

    expect_contains "$makefile" "READY_FOR_HUMAN" "make release names the sole success verdict"

    # The release exit table describes what the gate does with a bad candidate — the
    # policy verdict and exit 65 — instead of promising 64 with no verdict.
    expect_contains "$workflow" 'An abbreviated, symbolic, malformed, or unknown candidate is refused with' \
        "WORKFLOW documents the release gate's answer to a bad candidate"
    expect_absent "$workflow" 'candidate must be a full 40-character SHA |' \
        "WORKFLOW no longer promises exit 64 for a malformed release candidate"

    # No script scans Web/ for placeholders, so no document may say release does; the
    # final audit rows own unfinished pages.
    local web_readme
    web_readme="$(cat "${IOSAI_ROOT}/Web/README.md")"
    expect_absent "$web_readme" 'Release verification refuses a candidate whose site' \
        "Web/README.md does not claim an automated site placeholder scan"
    expect_contains "$web_readme" 'No script scans these pages for placeholders' \
        "Web/README.md says the final audit is what stops an unfinished page"

    # The human checklist is preserved in a release record the developer writes, from
    # the one template both that record and an optional audit use.
    expect_contains "$(cat "${IOSAI_ROOT}/AI/templates/release-audit-template.md")" \
        'developer release record' "the release template serves the developer's own release record"
    for token in READY_FOR_RELEASE_AUDIT APPROVED_FOR_RELEASE BLOCKED_INDEPENDENT_AUDIT \
                 AUTOMATED_VERIFICATION_FAILED; do
        expect_absent "$(cat "${IOSAI_ROOT}/Scripts/verify-release.sh")" "$token" \
            "release tooling removed obsolete verdict ${token}"
    done

    # ---- Exit-code vocabulary --------------------------------------------
    #
    # Every exit-code constant referenced anywhere must exist, or `die` with an
    # undefined one dies with "unbound variable" under set -u and loses the code
    # it meant to report. (Written without a literal example, because this case
    # scans its own file.)
    local defined missing="" name
    defined="$(sed -n '/^EX_[A-Z]*=/p' "${IOSAI_ROOT}/Scripts/lib/common.sh" | sed 's/=.*//')"
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        line_in_list "$name" "$defined" || missing="${missing} ${name}"
    done <<EOF
$(grep -rhoE '\bEX_[A-Z]+\b' "${IOSAI_ROOT}/Scripts" "${IOSAI_ROOT}/.githooks" | sort -u)
EOF
    if [ -n "$missing" ]; then
        check fail "exit-code constant(s) used but never defined:${missing}"
    else
        check pass "every EX_ constant referenced by a script or hook is defined"
    fi

    # The universal template ships no concrete audit or handoff record, so a new
    # product inherits none of the template's own development history — no SHA,
    # no verdict, no remediation state it cannot act on. This used to assert the
    # opposite, naming five historical records by filename; the classification
    # rule that reads these directories is proved generically against fixture
    # records in case_record_policy_status, so nothing is lost by inverting it.
    #
    # Skipped in a derived project, which legitimately accumulates its own
    # records — the same discriminator the README assertions above use.
    if [ "$template_readme" = "yes" ]; then
        for doc in AI/audits AI/handoffs; do
            expect_same ".gitkeep" \
                "$(find "${IOSAI_ROOT}/${doc}" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//')" \
                "${doc}/ ships only its .gitkeep"
        done
    fi

    # ---- Records: the templates and the rule that reads them ---------------
    #
    # case_record_templates proves the templates satisfy the gate. These assert the
    # documentation half, because the field was enforced by a script and mentioned
    # in no document at all.
    local record_template
    for record_template in handoff-template audit-template release-audit-template; do
        expect_contains "$(cat "${IOSAI_ROOT}/AI/templates/${record_template}.md")" \
            '**Policy status:**' "${record_template}.md declares its policy status"
    done
    expect_contains "$workflow" '## Records' "WORKFLOW documents where records live"
    expect_contains "$workflow" 'AI/audits/' "WORKFLOW names the audit location"
    expect_contains "$workflow" 'Policy status' "WORKFLOW documents the required record front matter"

    # The M00 reachability rule is enforced by milestones_validate_all and used to
    # appear only in a failure hint, so an agent writing the first milestone set met
    # it as a surprise.
    expect_contains "$workflow" 'reach it directly or through the graph' \
        "WORKFLOW documents the M00 dependency invariant"

    # make help is the authoritative map (AGENTS.md says so), and its sequence used
    # to run make initialize straight into make fast — which exits 69, because the
    # repository is still in template mode until the project is configured.
    local help_sequence
    help_sequence="$(awk '/^Typical sequence/{inside=1} inside' <<<"$(cd "$IOSAI_ROOT" && make help 2>/dev/null)")"
    expect_contains "$help_sequence" 'configure-project.sh' \
        "make help names the configuration step in its typical sequence"
    if [ -n "$help_sequence" ]; then
        local configure_line fast_line
        configure_line="$(printf '%s\n' "$help_sequence" | grep -n 'configure-project.sh' | head -1 | cut -d: -f1)"
        fast_line="$(printf '%s\n' "$help_sequence" | grep -n 'make fast' | head -1 | cut -d: -f1)"
        if [ -n "$configure_line" ] && [ -n "$fast_line" ] && [ "$configure_line" -lt "$fast_line" ]; then
            check pass "configuration comes before make fast in the printed sequence"
        else
            check fail "make help still sends the developer to make fast before configuring"
        fi
    fi

    # ---- Exit-code vocabulary, the other direction -------------------------
    #
    # The forward check above proves every constant a script uses exists. This one
    # proves the reverse: WORKFLOW documented exit 75 as "transient local condition"
    # and no script could ever return it, so a reader was told to expect a code that
    # did not occur.
    local documented code
    documented="$(awk -F'|' '/^\| *[0-9]+ *\|/ { gsub(/ /, "", $2); print $2 }' \
        "${IOSAI_ROOT}/AI/WORKFLOW.md" | sort -u)"
    if [ -z "$documented" ]; then
        check fail "no exit codes could be read from the WORKFLOW tables"
    fi
    while IFS= read -r code; do
        [ -n "$code" ] || continue
        if grep -rqE "^EX_[A-Z]+=${code}\$|^EX_[A-Z]+=${code}[[:space:]]" \
                "${IOSAI_ROOT}/Scripts/lib/common.sh"; then
            check pass "documented exit ${code} has a defined constant"
        else
            check fail "WORKFLOW documents exit ${code}, which no constant defines"
        fi
    done <<EOF
$documented
EOF

    # ---- Release coverage schema ------------------------------------------
    expect_contains "$workflow" 'allow_inapplicable' \
        "WORKFLOW documents the conditional coverage column"
    expect_contains "$workflow" 'VERIFIED' \
        "WORKFLOW documents the successful coverage outcome"

    # ---- No copied suite counts in live documents ---------------------------
    #
    # WORKFLOW and M00 asserted "45 cases and 546 checks" as measured fact while
    # the suite had grown to 52 and 636. Nothing noticed, because a count copied
    # into prose has no owner. The suite prints its own totals; documents describe
    # the shape and point at `--list`.
    #
    # Two details this check depends on. The corpus is FLATTENED first, because the
    # "546 checks" claim wrapped across two lines and a line-based scan matched
    # nothing at all. And the digit is anchored with `[0-9][0-9,]*`, not `[0-9,]+`,
    # because the latter matches the comma in "the complete diff, checks every
    # acceptance criterion" — correct prose that must not fail the suite.
    local flat_live_docs copied_count count_pattern live_docs_candidates
    live_docs_candidates="$(cat "${IOSAI_ROOT}/README.md" "${IOSAI_ROOT}/AGENTS.md" \
        "${IOSAI_ROOT}/CLAUDE.md" "${IOSAI_ROOT}/AI/WORKFLOW.md" \
        "${IOSAI_ROOT}"/AI/prompts/*.md "${IOSAI_ROOT}"/AI/templates/*.md \
        "${IOSAI_ROOT}"/AI/milestones/*.md)"
    flat_live_docs="$(printf '%s' "$live_docs_candidates" | tr '\n' ' ' | tr -s ' ')"
    for count_pattern in '[0-9][0-9,]* cases' '[0-9][0-9,]* checks'; do
        copied_count="$(printf '%s' "$flat_live_docs" | grep -oE "$count_pattern" | head -1 || true)"
        if [ -n "$copied_count" ]; then
            check fail "a live document states '${copied_count}'; let the suite report its own totals"
        else
            check pass "no live document copies a self-test ${count_pattern##* } count"
        fi
    done

    # ---- Script output is documentation too --------------------------------
    #
    # configure-project.sh's printed next steps told the developer to "verify the
    # milestone with an explicit candidate SHA" — the Reviewer-only reproduction
    # mode, which ordinary work must never need, and it omitted the REVIEW status
    # the gate requires in both modes. Every document said otherwise. This case
    # read eight document sources and no script output at all, which is exactly why
    # the stale hint outlived the policy change that made it wrong.
    #
    # self-test.sh is excluded because this case scans its own file: the phrase it
    # forbids necessarily appears here.
    #
    # The exclusion uses `if`, not `case`. Bash 3.2 mis-parses a `case` pattern's
    # closing `)` inside `$( )` as the end of the command substitution, and it does
    # so at RUNTIME — `bash -n` accepts the file. The first version of this check
    # was written with `case` and silently collected almost nothing, so
    # expect_absent passed on an empty haystack. Hence the emptiness guard below:
    # a scan that found nothing must never read as a clean result.
    local script_text script_file
    script_text="$(for script_file in "${IOSAI_ROOT}"/Scripts/*.sh \
            "${IOSAI_ROOT}"/Scripts/lib/*.sh "${IOSAI_ROOT}"/.githooks/*; do
        if [ "${script_file##*/}" = "self-test.sh" ]; then continue; fi
        cat "$script_file"
    done)"
    if [ ${#script_text} -lt 10000 ]; then
        check fail "the script corpus is implausibly small (${#script_text} bytes); the scan did not run"
    else
        check pass "the script corpus was collected (${#script_text} bytes)"
    fi
    expect_absent "$script_text" 'explicit candidate SHA' \
        "no script recommends an explicit candidate SHA for ordinary milestone work"

    local configure_text
    configure_text="$(cat "${IOSAI_ROOT}/Scripts/configure-project.sh")"
    expect_contains "$configure_text" 'make milestone ID=' \
        "configure-project.sh points at the documented clean-HEAD milestone command"
    expect_contains "$configure_text" 'set the milestone to REVIEW' \
        "configure-project.sh names the REVIEW precondition the gate enforces"
}

# One Builder session carries one milestone from selection to DONE: implement,
# test, self-review, fix what that review found, verify, hand off, stop. The
# policy it replaced stopped the Builder at REVIEW and required a second,
# independent session to set DONE. The whole change lives in prose, so nothing but
# prose can assert it — and prose is exactly what drifts back silently.
#
# The corpus is FLATTENED before matching, for the reason recorded in
# case_documentation_consistency: every phrase below is longer than the 80-column
# wrap these documents use, so a line-based scan would match none of them.
case_workflow_contract() {
    local workflow prompt corpus token
    workflow="$(cat "${IOSAI_ROOT}/AI/WORKFLOW.md")"
    prompt="$(cat "${IOSAI_ROOT}/AI/prompts/execute-next-milestone.md")"
    corpus="$(printf '%s\n%s' "$workflow" "$prompt" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 4000 ]; then
        check fail "the workflow corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the workflow corpus was collected (${#corpus} bytes)"

    # 1. One session selects and owns exactly one milestone.
    expect_contains "$corpus" 'One session carries one milestone' \
        "the workflow states that one session carries one milestone"
    expect_contains "$corpus" 'one milestone per session' \
        "the milestone prompt states one milestone per session"

    # 2. That session owns the whole loop, not only the implementation.
    expect_contains "$corpus" 'implements, tests, self-reviews, corrects, and verifies' \
        "the Builder role owns implementation, tests, self-review, correction, and verification"

    # 3. So implementation complete is not a stopping point, and
    # 4. DONE is — for this milestone only.
    expect_contains "$corpus" 'not the end of the session' \
        "implementation complete is documented as not the end of the session"
    expect_contains "$corpus" 'Do not start another milestone in the same session' \
        "starting another milestone in the same session is forbidden"

    # 5. Self-review is labelled honestly, and
    # 6. independent review is optional rather than a state transition.
    expect_contains "$corpus" 'Self-review is not independent review' \
        "self-review is never presented as independent review"
    expect_contains "$corpus" 'Independent review is optional' \
        "independent review is documented as optional"
    expect_contains "$corpus" 'never blocks' \
        "independent review is documented as never blocking DONE"

    # High risk raises the depth of the self-review inside the same session. The
    # list is asserted by its vocabulary rather than as a sentence: a silently
    # shortened list then fails loudly, and rewording around it does not.
    for token in StoreKit migration authentication concurrency permissions; do
        expect_contains "$corpus" "$token" \
            "the deeper-self-review list still names ${token}"
    done

    # 7. Release auditing was not folded into milestone completion.
    expect_contains "$corpus" 'is separate from milestone' \
        "release auditing remains separate from milestone completion"

    # 8. And one session per milestone never implied one worktree per milestone —
    # milestones are sequential in the primary checkout, on the primary branch.
    # Optional worktrees have bounded isolation uses, never milestone evidence, and
    # independently developed streams always converge through integration.
    expect_contains "$corpus" 'one branch and one checkout' \
        "milestone work remains one branch and one checkout"
    expect_contains "$corpus" 'no worktree is required' \
        "the milestone prompt states that no worktree is required"
    expect_contains "$corpus" \
        'genuinely parallel localization, independent read-only reviews, or bounded experiments' \
        "optional worktrees have the three sanctioned isolation uses"
    expect_contains "$corpus" \
        'never carry milestone implementation or milestone verification evidence' \
        "optional worktrees cannot carry milestone evidence"
    expect_contains "$corpus" 'whenever independently developed streams are combined' \
        "combined streams always require integration verification"
    expect_contains "$corpus" 'milestone work never runs in one' \
        "the milestone prompt forbids developing a milestone in a worktree"
    expect_contains "$corpus" 'on the primary branch, and committed there' \
        "the documents state where a milestone is developed and committed"
    expect_contains "$corpus" 'refuses to run anywhere else' \
        "the documents state that the gate enforces it"

    # The two sections carrying this policy are required headings, so a repository
    # that deletes the policy fails the fast gate instead of quietly keeping a
    # workflow document that no longer describes the workflow.
    local fx="${SELFTEST_DIR}/workflow-contract"
    local work="${SELFTEST_DIR}/workflow-contract-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc heading
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped workflow document satisfies the fast gate"
    for heading in '## Sessions' '## Independent review'; do
        cp "${fx}/AI/WORKFLOW.md" "${work}/WORKFLOW.base"
        grep -vF -- "$heading" "${work}/WORKFLOW.base" > "${fx}/AI/WORKFLOW.md"
        rc="$(run_capture "${work}/missing.txt" "${fx}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "removing '${heading}' from AI/WORKFLOW.md is refused"
        expect_contains "$(cat "${work}/missing.txt")" "$heading" \
            "the refusal names the missing heading"
        cp "${work}/WORKFLOW.base" "${fx}/AI/WORKFLOW.md"
    done
}

# One final milestone owns six ordered domain methods and a consolidated record.
# Mutation tests prove the generator, orchestrator, and candidate gates enforce it.
case_final_audit_milestones_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/WORKFLOW.md" \
        "${IOSAI_ROOT}/AI/prompts/final-polish.md" \
        "${IOSAI_ROOT}/AI/prompts/final-release-readiness.md" \
        "${IOSAI_ROOT}"/AI/prompts/audit-*.md | tr '\n' ' ' | tr -s ' ')"

    if [ ${#corpus} -lt 7000 ]; then
        check fail "the final-polish corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the final-polish corpus was collected (${#corpus} bytes)"
    expect_contains "$corpus" 'P2 never blocks' "P2 is stated to be non-blocking"
    expect_contains "$corpus" 'one targeted re-audit' "the bounded targeted re-audit is stated"
    expect_contains "$corpus" 'one consolidated' "one consolidated audit record is required"
    expect_contains "$corpus" 'Nothing in this workflow uploads, submits, archives, or publishes' \
        "the final milestone states that automation publishes nothing"
    expect_contains "$corpus" 'One Builder session owns that milestone' \
        "one Builder session owns all six domains"
    expect_contains "$corpus" 'FUTURE_PRODUCT_IDEA' \
        "out-of-scope product opportunities have their own classification"

    local fx="${SELFTEST_DIR}/final-audits"
    local work="${SELFTEST_DIR}/final-audits-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    local generator="${fx}/AI/prompts/initialize-product.md"
    local generator_base="${work}/initialize-product.base"
    local polish="${fx}/AI/prompts/final-polish.md"
    local polish_base="${work}/final-polish.base"
    local audit="${fx}/AI/prompts/audit-content.md"
    local audit_base="${work}/audit-content.base"
    cp "$generator" "$generator_base"
    cp "$polish" "$polish_base"
    cp "$audit" "$audit_base"

    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped Final Product Polish layer satisfies the fast gate"

    sed 's|Final Product Polish -> AI/prompts/final-polish.md|Final Product Polish -> AI/prompts/audit-functional.md|' \
        "$generator_base" > "$generator"
    rc="$(run_capture "${work}/wrong-final.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/wrong-final.txt")"
    expect_exit 65 "$rc" "mapping the final milestone to a domain prompt is refused"
    expect_contains "$out" "does not state the one final milestone" \
        "the refusal names the generation contract"
    cp "$generator_base" "$generator"

    printf '\nFinal Release Readiness -> AI/prompts/final-release-readiness.md\n' >> "$generator"
    rc="$(run_capture "${work}/extra-final.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "adding a second generated final milestone is refused"
    cp "$generator_base" "$generator"

    grep -vF 'this milestone depends on every implementation' "$generator_base" > "$generator"
    rc="$(run_capture "${work}/dependency.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the final milestone dependency boundary is refused"
    cp "$generator_base" "$generator"

    # template-check does not validate the milestone graph or the status fields, so
    # the generator has to run project-status.sh validate before asking for approval;
    # otherwise the developer approves a plan the first M00 gate rejects.
    sed 's|./Scripts/project-status.sh validate|make status|g' "$generator_base" > "$generator"
    rc="$(run_capture "${work}/graph-validation.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the generator's milestone-graph validation is refused"
    expect_contains "$(cat "${work}/graph-validation.txt")" "./Scripts/project-status.sh validate" \
        "the refusal names the validation the generator must run"
    cp "$generator_base" "$generator"

    sed -e 's|audit-functional\.md|IOSAI_SWAP|g' \
        -e 's|audit-content\.md|audit-functional.md|g' \
        -e 's|IOSAI_SWAP|audit-content.md|g' "$polish_base" > "$polish"
    rc="$(run_capture "${work}/order.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/order.txt")"
    expect_exit 65 "$rc" "reordering the six domains is refused"
    expect_contains "$out" "does not state the six audit domains in order" \
        "the refusal names the ordered-domain contract"
    cp "$polish_base" "$polish"

    grep -vF 'AI/prompts/audit-accessibility.md' "$polish_base" > "$polish"
    rc="$(run_capture "${work}/dropped-domain.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping a Final Product Polish domain is refused"
    cp "$polish_base" "$polish"

    grep -vF 'one targeted re-audit' "$polish_base" > "$polish"
    rc="$(run_capture "${work}/reaudit.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the bounded re-audit rule is refused"
    cp "$polish_base" "$polish"

    grep -vF 'AI/audits/<ID>-final-polish.md' "$polish_base" > "$polish"
    rc="$(run_capture "${work}/record.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the consolidated record path is refused"
    cp "$polish_base" "$polish"

    grep -vF 'make release CANDIDATE=<verified-full-SHA>' "$polish_base" > "$polish"
    rc="$(run_capture "${work}/release.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping exact-SHA release verification is refused"
    cp "$polish_base" "$polish"

    printf '\nThen verify with make release CANDIDATE=<verified-full-SHA>.\n' >> "$audit"
    rc="$(run_capture "${work}/domain-release.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/domain-release.txt")"
    expect_exit 65 "$rc" "a domain method that runs release verification is refused"
    expect_contains "$out" "runs release verification" "the refusal names the release boundary"
    cp "$audit_base" "$audit"

    printf '\nNever repair the implementation during this review.\n' >> "$audit"
    rc="$(run_capture "${work}/norepair.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a Builder domain carrying the Reviewer no-repair rule is refused"
    cp "$audit_base" "$audit"

    printf '\nAn extra independent review is optional here and never blocks DONE.\n' >> "$audit"
    rc="$(run_capture "${work}/optional.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "describing optional independent review remains allowed"
    cp "$audit_base" "$audit"

    mv "${fx}/AI/prompts/audit-accessibility.md" "${work}/accessibility.bak"
    rc="$(run_capture "${work}/missing.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "removing a required domain prompt is refused"
    expect_contains "$(cat "${work}/missing.txt")" "audit-accessibility.md" \
        "the refusal names the missing prompt"
    mv "${work}/accessibility.bak" "${fx}/AI/prompts/audit-accessibility.md"

    local milestone milestone_base="${work}/milestone.base"
    milestone="$(find "${fx}/AI/milestones" -maxdepth 1 -type f -name 'M00-*.md' | head -1)"
    cp "$milestone" "$milestone_base"
    sed 's/^\*\*Status:\*\* .*/**Status:** READY_FOR_HUMAN/' "$milestone_base" > "$milestone"
    rc="$(run_capture "${work}/state.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "promoting the release verdict to a milestone state is refused"
    cp "$milestone_base" "$milestone"

    mkdir -p "${fx}/AI/prompts/accessibility"
    rc="$(run_capture "${work}/hierarchy.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a per-domain prompt directory is refused"
    rmdir "${fx}/AI/prompts/accessibility"

    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every Final Product Polish fixture mutation was restored"

    # Generated contracts, not only prose, enforce the single final milestone.
    local plan="${SELFTEST_DIR}/generated-final-plan" plan_work="${SELFTEST_DIR}/generated-final-plan-work"
    fixture_template "$plan" "$plan_work"
    printf 'ios-ai-project/2\nowner=Fixture Owner\nprimary_branch=main\n' > "${plan}/.iosai-project"
    write_final_sequence_fixture "$plan" PLANNED
    rc="$(run_capture "${plan_work}/valid.txt" "${plan}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a generated single final milestone validates"
    local contract="${plan}/AI/milestones/M01-final-product-polish.md" mutation
    cp "$contract" "${plan_work}/contract.base"
    for mutation in prompt record dependency gate; do
        case "$mutation" in
            prompt) sed 's|AI/prompts/final-polish.md|AI/prompts/audit-product.md|' "${plan_work}/contract.base" > "$contract" ;;
            record) sed 's|AI/audits/M01-final-polish.md|AI/audits/M01-product.md|' "${plan_work}/contract.base" > "$contract" ;;
            dependency) sed 's/^\*\*Depends on:\*\* M00$/**Depends on:** none/' "${plan_work}/contract.base" > "$contract" ;;
            gate) grep -vF 'make release CANDIDATE=' "${plan_work}/contract.base" > "$contract" ;;
        esac
        rc="$(run_capture "${plan_work}/${mutation}.txt" "${plan}/Scripts/verify-template.sh")"
        expect_exit 65 "$rc" "a wrong generated ${mutation} contract is refused"
        cp "${plan_work}/contract.base" "$contract"
    done
    append_only_write_milestone "${plan}/AI/milestones/M02-follow-up.md" M02 PLANNED M01 'Follow-up improvement'
    rc="$(run_capture "${plan_work}/append.txt" "${plan}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "later appended work preserves the historical final milestone"
    rm "${plan}/AI/milestones/M02-follow-up.md"
    rm "$contract"
    write_final_sequence_fixture "$plan" PLANNED 2
    rc="$(run_capture "${plan_work}/gap.txt" "${plan}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "the final milestone cannot skip the next sequential ID"
    rm "${plan}/AI/milestones/M02-final-product-polish.md"
    write_final_sequence_fixture "$plan" PLANNED
    write_final_sequence_fixture "$plan" PLANNED 2
    rc="$(run_capture "${plan_work}/duplicate.txt" "${plan}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a duplicate generated final milestone is refused"
}


# append_only_write_milestone <path> <id> <status> <deps> <title> [extra-fields]
#
# One milestone contract in the shape common.sh requires: the five fields, the four
# sections, and at least one acceptance criterion. A function rather than five
# near-identical heredocs, so the values that differ are the only thing visible at
# each call site.
append_only_write_milestone() {
    local path="$1" id="$2" status="$3" deps="$4" title="$5" extra="${6:-}"
    {
        printf '# %s — %s\n\n' "$id" "$title"
        printf '**ID:** %s\n' "$id"
        printf '**Status:** %s\n' "$status"
        printf '**Depends on:** %s\n' "$deps"
        printf '**Validation:** make milestone ID=%s\n' "$id"
        printf '**Handoff:** AI/handoffs/%s-handoff.md\n' "$id"
        [ -z "$extra" ] || printf '%s\n' "$extra"
        printf '\n## Objective\n\nOne fixture outcome for the append-only history case.\n'
        printf '\n## Scope\n\n- Only what this contract declares.\n'
        printf '\n## Non-goals\n\n- Anything another milestone owns.\n'
        printf '\n## Acceptance criteria\n\n'
        printf -- '- [ ] The declared validation command passes at clean REVIEW HEAD.\n'
    } > "$path"
    return 0
}

# write_final_sequence_fixture <repository> <status> [first-number] — exact final tail.
write_final_sequence_fixture() {
    local dir="$1" status="$2" start="${3:-1}" id file
    id="$(printf 'M%02d' "$start")"
    file="${dir}/AI/milestones/${id}-final-product-polish.md"
    append_only_write_milestone "$file" "$id" "$status" M00 'Final Product Polish' \
        "**Audit prompt:** AI/prompts/final-polish.md
**Audit record:** AI/audits/${id}-final-polish.md"
    printf -- '- [ ] make release CANDIDATE=<verified-full-SHA> reports READY_FOR_HUMAN.\n' >> "$file"
}

fixture_write_audit_record() {
    local dir="$1" id="$2" domain="$3" channel="$4"
    local record="${dir}/AI/audits/${id}-${domain}.md"
    {
        printf '# %s final domain audit — %s\n\n' "$id" "$domain"
        printf '**Policy status:** current\n'
        printf '**Policy:** `solo-workflow/2`\n'
        printf '**Record type:** Builder domain audit\n'
        printf '**Milestone:** %s\n' "$id"
        printf '**Distribution:** %s\n' "$channel"
        printf '**Coverage result:** COMPLETE\n'
        printf '**Open P0/P1:** 0\n\n'
        printf '## Candidate context\n\nFixture application and stub environment.\n\n'
        printf '## Coverage\n\n'
        awk -F '\t' -v domain="$domain" -v channel="$channel" '
            !/^#/ && NF == 5 && ($2 == "all" || $2 == channel) {
                count = split($3, domains, ",")
                for (i = 1; i <= count; i++) {
                    if (domains[i] == domain) {
                        printf "- %s | OUTCOME=VERIFIED | EVIDENCE=fixture exercised %s in the stub environment\n", $1, $5
                        break
                    }
                }
            }
        ' "${dir}/Config/release-requirements.v3.tsv"
        printf '\n## Findings\n\n| ID | Severity | Location | Reproduction and required correction |\n'
        printf '| --- | --- | --- | --- |\n| — | — | — | No findings |\n\n'
        printf '## Fixes\n\nNone.\n\n## Deferred P2\n\nNone.\n\n'
        printf '## FUTURE_PRODUCT_IDEA\n\nNone.\n\n## Targeted re-audit\n\nNo fixes.\n\n'
        printf '## Validation\n\nFixture evidence.\n'
    } > "$record"
}

fixture_write_polish_record() {
    local dir="$1" id="$2" channel="$3" domain
    {
        printf '# Final Product Polish\n\n**Policy status:** current\n'
        printf '**Milestone:** %s\n**Distribution channel:** %s\n' "$id" "$channel"
        printf '**Coverage result:** COMPLETE\n**Open P0/P1:** 0\n'
        for domain in functional ui-ux content accessibility product release; do
            printf '\n## Coverage: %s\n\n' "$domain"
            awk -F '\t' -v domain="$domain" -v channel="$channel" '
                !/^#/ && NF==5 && ($2=="all" || $2==channel) {
                    n=split($3, domains, ",")
                    for(i=1;i<=n;i++) if(domains[i]==domain) {
                        printf "- %s | OUTCOME=VERIFIED | EVIDENCE=fixture exercised %s in stub environment\n", $1, $5
                        break
                    }
                }' "${dir}/Config/release-requirements.v3.tsv"
        done
    } > "${dir}/AI/audits/${id}-final-polish.md"
}

fixture_prepare_release_ready() {
    local dir="$1" channel id domain handoff status ready=yes
    channel="$(awk -F= '$1 == "DISTRIBUTION_CHANNEL" { gsub(/\"/, "", $2); print $2; exit }' \
        "${dir}/Config/project.env")"

    if [ ! -f "${dir}/AI/milestones/M01-final-product-polish.md" ] \
       || [ "$(milestone_field "${dir}/AI/milestones/M01-final-product-polish.md" Status)" != REVIEW ] \
       || [ "$(milestone_field "${dir}/AI/audits/M01-final-polish.md" 'Distribution channel')" != "$channel" ]; then
        ready=no
    fi
    [ "$ready" = "no" ] || return 0

    sed 's/^\*\*Status:\*\* .*/**Status:** DONE/' \
        "${dir}/AI/milestones/M00-template-bootstrap.md" \
        > "${dir}/AI/milestones/M00-template-bootstrap.md.new"
    mv "${dir}/AI/milestones/M00-template-bootstrap.md.new" \
        "${dir}/AI/milestones/M00-template-bootstrap.md"

    if [ ! -f "${dir}/AI/milestones/M01-final-product-polish.md" ]; then
        write_final_sequence_fixture "$dir" DONE
    fi
    sed 's/^\*\*Status:\*\* .*/**Status:** REVIEW/' \
        "${dir}/AI/milestones/M01-final-product-polish.md" \
        > "${dir}/AI/milestones/M01-final-product-polish.md.new"
    mv "${dir}/AI/milestones/M01-final-product-polish.md.new" \
        "${dir}/AI/milestones/M01-final-product-polish.md"

    fixture_write_polish_record "$dir" M01 "$channel"

    for id in M00; do
        handoff="${dir}/AI/handoffs/${id}-handoff.md"
        {
            printf '# %s fixture handoff\n\n' "$id"
            printf '**Policy status:** current\n\n'
            printf '## Milestone\n\n%s — fixture; status DONE.\n\n' "$id"
            printf '## Summary\n\nFixture completion.\n\n## Changed files\n\n- Fixture only.\n\n'
            printf '## Validation\n\nFixture evidence.\n\n## Tests\n\nStub suite.\n\n'
            printf '## Known issues\n\nNone.\n\n## Next step\n\nNext fixture milestone.\n'
        } > "$handoff"
    done

    status="${dir}/AI/PROJECT_STATUS.md"
    {
        printf '# Project status\n\n'
        printf '**Phase:** release-preparation\n'
        printf '**Current milestone:** M01\n'
        printf '**Completed milestones:** M00\n'
        printf '**Next milestone:** M01\n'
        printf '**Blockers:** none\n'
        printf '**Important decisions:** none\n'
    } > "$status"
    fixture_commit_unchecked "$dir" "prepare complete final audit coverage"
}

# A candidate changed after initial readiness needs a new readiness milestone.
# The earlier consolidated audit record remains historical input; the affected domain is
# re-audited in the appended sequence before the new exact candidate can pass.
fixture_companion_readiness() (
    cd "$1"
    bash -c '. ./Scripts/lib/common.sh; iosai_enter_root; env_file_load Config/project.env;
        WATCH_APP_MODE=companion; validate_release_workflow_readiness app-store'
)

case_watch_companion_readiness() {
    local fx="${SELFTEST_DIR}/watch-companion-readiness" work="${SELFTEST_DIR}/watch-companion-readiness-work"
    local rc historical domain
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    sed 's/^DISTRIBUTION_CHANNEL=.*/DISTRIBUTION_CHANNEL="app-store"/' "${fx}/Config/project.env" > "${work}/config"
    cp "${work}/config" "${fx}/Config/project.env"
    printf '\nAPP_PLATFORM="watchOS"\n' >> "${fx}/Config/project.env"
    fixture_prepare_release_ready "$fx"
    sed 's/^\*\*Status:\*\* REVIEW$/**Status:** DONE/' "${fx}/AI/milestones/M01-final-product-polish.md" > "${work}/original"
    cp "${work}/original" "${fx}/AI/milestones/M01-final-product-polish.md"
    sed -E 's/^- (REL-20[89]) \|.*/- \1 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Watch-only has no iPhone rating interface./' \
        "${fx}/AI/audits/M01-final-polish.md" > "${work}/audit"
    cp "${work}/audit" "${fx}/AI/audits/M01-final-polish.md"
    fixture_commit_unchecked "$fx" 'verified Watch-only configuration'
    historical="$(git -C "$fx" rev-parse HEAD)"
    printf '| Verified SHA | `%s` |\n' "$historical" > "${fx}/AI/handoffs/M01-handoff.md"
    append_only_write_milestone "${fx}/AI/milestones/M02-companion-audits.md" M02 DONE M01 'Companion domain audits'
    append_only_write_milestone "${fx}/AI/milestones/M03-readiness.md" M03 REVIEW M02 'Release Readiness Revalidation'
    printf '\n**Revalidated domains:** functional,ui-ux,content,accessibility,product,release\n' >> "${fx}/AI/milestones/M03-readiness.md"
    for domain in functional ui-ux content accessibility product release; do
        fixture_write_audit_record "$fx" M02 "$domain" app-store
        printf '**%s revalidation record:** AI/audits/M02-%s.md\n' "$domain" "$domain" >> "${fx}/AI/milestones/M03-readiness.md"
    done
    cp "${fx}/AI/milestones/M03-readiness.md" "${work}/current"
    rc="$(run_capture "${work}/ready.txt" fixture_companion_readiness "$fx")"
    expect_exit 0 "$rc" 'six current companion audits preserve verified historical Watch applicability'

    sed 's/^\*\*Revalidated domains:.*/**Revalidated domains:** functional/' "${work}/current" > "${fx}/AI/milestones/M03-readiness.md"
    rc="$(run_capture "${work}/partial.txt" fixture_companion_readiness "$fx")"
    expect_exit 1 "$rc" 'platform transition cannot inherit five unaudited domains'
    cp "${work}/current" "${fx}/AI/milestones/M03-readiness.md"

    cp "${fx}/AI/audits/M02-product.md" "${work}/product"
    sed -E 's/^- (REL-208) \|.*/- \1 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=old Watch-only exception./' "${work}/product" > "${fx}/AI/audits/M02-product.md"
    rc="$(run_capture "${work}/rating.txt" fixture_companion_readiness "$fx")"
    expect_exit 1 "$rc" 'current companion rating evidence remains mandatory'
    cp "${work}/product" "${fx}/AI/audits/M02-product.md"

    printf 'No verified source.\n' > "${fx}/AI/handoffs/M01-handoff.md"
    rc="$(run_capture "${work}/missing.txt" fixture_companion_readiness "$fx")"
    expect_exit 1 "$rc" 'historical platform exception cannot be inferred without a verified SHA'
    printf '| Verified SHA | `%s` |\n| Verified SHA | `%s` |\n' "$historical" "$historical" > "${fx}/AI/handoffs/M01-handoff.md"
    rc="$(run_capture "${work}/ambiguous.txt" fixture_companion_readiness "$fx")"
    expect_exit 1 "$rc" 'ambiguous historical source fails closed'

    printf '\nWATCH_APP_MODE="companion"\n' >> "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" 'companion configuration cannot justify a Watch-only exception'
    printf '| Verified SHA | `%s` |\n' "$(git -C "$fx" rev-parse HEAD)" > "${fx}/AI/handoffs/M01-handoff.md"
    rc="$(run_capture "${work}/wrong-platform.txt" fixture_companion_readiness "$fx")"
    expect_exit 1 "$rc" 'historical exception requires an actual Watch-only config at the recorded SHA'
}

case_release_revalidation() {
    local fx="${SELFTEST_DIR}/release-revalidation"
    local work="${SELFTEST_DIR}/release-revalidation-work"
    local ms rc out
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    fixture_prepare_release_ready "$fx"
    ms="${fx}/AI/milestones"

    sed 's/^\*\*Status:\*\* REVIEW$/**Status:** DONE/' \
        "${ms}/M01-final-product-polish.md" > "${work}/M01.done"
    cp "${work}/M01.done" "${ms}/M01-final-product-polish.md"
    printf '**Policy status:** current\n\n# M01 fixture handoff\n\nInitial candidate verified.\n' \
        > "${fx}/AI/handoffs/M01-handoff.md"
    printf 'let followUp = 1\n' > "${fx}/App/Fixture/FollowUp.swift"
    fixture_commit_unchecked "$fx" "change application after initial readiness"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/stale.txt" fixture_release_raw "$fx")"
    out="$(cat "${work}/stale.txt")"
    expect_exit 65 "$rc" "a changed candidate cannot inherit earlier readiness"
    expect_contains "$out" 'VERDICT=NOT_READY' "the changed candidate requires revalidation"

    append_only_write_milestone "${ms}/M02-targeted-functional-reaudit.md" \
        M02 DONE M01 'Targeted Functional Re-audit' \
        '**Audit prompt:** AI/prompts/audit-functional.md
**Audit record:** AI/audits/M02-functional.md'
    append_only_write_milestone "${ms}/M03-release-readiness-revalidation.md" \
        M03 REVIEW M02 'Release Readiness Revalidation'
    printf '\n**Revalidated domains:** functional\n' \
        >> "${ms}/M03-release-readiness-revalidation.md"
    printf '**functional revalidation record:** AI/audits/M02-functional.md\n' \
        >> "${ms}/M03-release-readiness-revalidation.md"
    fixture_write_audit_record "$fx" M02 functional internal
    printf '**Policy status:** current\n\n# M02 fixture handoff\n\nAffected functional domain re-audited.\n' \
        > "${fx}/AI/handoffs/M02-handoff.md"
    {
        printf '# Project status\n\n'
        printf '**Phase:** release-preparation\n'
        printf '**Current milestone:** M03\n'
        printf '**Completed milestones:** M00, M01, M02\n'
        printf '**Next milestone:** M03\n'
        printf '**Blockers:** none\n'
        printf '**Important decisions:** none\n'
    } > "${fx}/AI/PROJECT_STATUS.md"
    fixture_commit_unchecked "$fx" "record targeted audit and readiness revalidation"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ready.txt" fixture_release_raw "$fx")"
    out="$(cat "${work}/ready.txt")"
    expect_exit 0 "$rc" "an appended readiness revalidation establishes a new candidate"
    expect_contains "$out" 'VERDICT=READY_FOR_HUMAN' "revalidation emits the release success verdict"

    rm "${fx}/AI/audits/M02-functional.md"
    fixture_commit_unchecked "$fx" "remove targeted revalidation evidence"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/missing-targeted.txt" fixture_release_raw "$fx")"
    expect_exit 65 "$rc" "revalidation blocks when targeted domain evidence is missing"
    expect_contains "$(cat "${work}/missing-targeted.txt")" 'VERDICT=NOT_READY' \
        "missing targeted evidence has the readiness verdict"
}

# Asking the person to rate the app is decided once, by the template, for every
# product it generates — so it is a contract with the same standing as the paywall
# rules, not advice a session may skip. The parts are deliberately spread across the
# documents that own them: the moment is a product decision, the ways of asking are a
# design rule, the injected dependency is an architecture decision, the milestone is
# generated at initialization, and the shipped behavior is maintained audit coverage. This
# case asserts they are all still there, and that removing any of the three gated
# anchors is refused rather than silently accepted.
case_review_request_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/DESIGN.md" "${IOSAI_ROOT}/AI/PRODUCT.md" \
        "${IOSAI_ROOT}/AI/ARCHITECTURE.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-product.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 6000 ]; then
        check fail "the review-request corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the review-request corpus was collected (${#corpus} bytes)"

    expect_contains "$corpus" '## Review request' \
        "the design contract has a section for the request"
    expect_contains "$corpus" 'owns the review request' \
        "initialization generates one milestone for it"
    expect_contains "$corpus" 'sentiment gate' \
        "filtering who is shown the prompt is a prohibited pattern"
    expect_contains "$corpus" 'injected dependency' \
        "the request is asked for through something a unit test can substitute"

    # Product and release audits both own the behavior because the system prompt
    # itself is not deterministic.
    local rows
    rows="$(awk -F'\t' '$1 == "REL-208" || $1 == "REL-209" { print $1, $2, $3, $4 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-208 app-store product,release no' \
        "the qualifying moment is confirmed on every App Store candidate"
    expect_contains "$rows" 'REL-209 app-store product,release no' \
        "the manual rate entry point is confirmed on every App Store candidate"

    local fx="${SELFTEST_DIR}/review-request"
    local work="${SELFTEST_DIR}/review-request-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped review-request contract satisfies the fast gate"

    # ---- The design contract ----------------------------------------------
    local design="${fx}/AI/DESIGN.md"
    local design_base="${work}/DESIGN.base"
    cp "$design" "$design_base"

    grep -vF -- '## Review request' "$design_base" > "$design"
    rc="$(run_capture "${work}/section.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/section.txt")"
    expect_exit 65 "$rc" "a design contract with no review-request section is refused"
    expect_contains "$out" 'missing the required heading' \
        "the refusal names the section a product repository must keep too"
    cp "$design_base" "$design"

    grep -vF 'sentiment gate' "$design_base" > "$design"
    rc="$(run_capture "${work}/gate.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/gate.txt")"
    expect_exit 65 "$rc" "dropping the prohibition on sentiment-gated prompts is refused"
    expect_contains "$out" 'does not state the review request rule' \
        "the refusal names the rule rather than the line"
    cp "$design_base" "$design"

    # ---- The generated milestone -------------------------------------------
    local gen="${fx}/AI/prompts/initialize-product.md"
    local gen_base="${work}/initialize-product.base"
    cp "$gen" "$gen_base"

    grep -vF 'owns the review request' "$gen_base" > "$gen"
    rc="$(run_capture "${work}/mandate.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/mandate.txt")"
    expect_exit 65 "$rc" "initialization that generates no review-request milestone is refused"
    expect_contains "$out" 'owns the review request' "the refusal names the missing mandate"
    cp "$gen_base" "$gen"

    # The milestone is an ordinary implementation milestone, so it is described in
    # prose. Writing it into the final sequence's `<title> -> <prompt>` form would
    # make it a second generated final milestone, and the existing fixture comparison — not a
    # second rule added for this contract — is what refuses that.
    printf '\nReview Request -> AI/prompts/audit-product.md\n' >> "$gen"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting the review request to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "$gen_base" "$gen"

    # Every mutation above restored something; assert that rather than assume it.
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# Apple requires a working privacy policy URL and support URL of every App Store
# app, and Terms and Privacy links inside any app selling a subscription. The
# template used to carry that only as manual rows REL-406, REL-503 and REL-1004,
# with nothing that ever produced the pages they ask a person to confirm.
#
# Now the site is a deliverable: Web/ ships with the template, three configuration
# keys identify it, one generated milestone fills it in, and verify-site.sh checks
# it offline on every `make static`. This case asserts the whole chain, and — more
# usefully — that each guard actually FIRES, because a contract nothing enforces is
# the state this change exists to leave behind.
case_legal_support_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/DESIGN.md" "${IOSAI_ROOT}/AI/PRODUCT.md" \
        "${IOSAI_ROOT}/AI/ARCHITECTURE.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-release.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 6000 ]; then
        check fail "the legal-and-support corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the legal-and-support corpus was collected (${#corpus} bytes)"

    expect_contains "$corpus" '## Legal and support' \
        "the design contract has a section for the three links"
    expect_contains "$corpus" 'owns the legal and support links' \
        "initialization generates one milestone for them"
    expect_contains "$corpus" 'reachable only from the paywall' \
        "hiding the links behind a purchase is a prohibited pattern"
    expect_contains "$corpus" 'Apple Standard EULA' \
        "terms of use is Apple's licence for every product, not one a product writes"
    expect_contains "$corpus" 'Published site (Cloudflare Pages)' \
        "the site is recorded as a separate deployable, not part of the bundle"

    # Content and release audits own the in-app and published destinations.
    local rows
    rows="$(awk -F'\t' '$1 == "REL-506" || $1 == "REL-1008" { print $1, $2, $3, $4 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-506 app-store content,release no' \
        "the in-app links are confirmed on every App Store candidate"
    expect_contains "$rows" 'REL-1008 app-store content,release no' \
        "the published terms page is confirmed on every App Store candidate"

    local fx="${SELFTEST_DIR}/legal-support"
    local work="${SELFTEST_DIR}/legal-support-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped legal-and-support contract satisfies the fast gate"
    rc="$(run_capture "${work}/site-clean.txt" "${fx}/Scripts/verify-site.sh")"
    expect_exit 0 "$rc" "the shipped site scaffold passes its own checks"

    # ---- The design contract ----------------------------------------------
    local design="${fx}/AI/DESIGN.md"
    local design_base="${work}/DESIGN.base"
    cp "$design" "$design_base"

    grep -vF -- '## Legal and support' "$design_base" > "$design"
    rc="$(run_capture "${work}/section.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/section.txt")"
    expect_exit 65 "$rc" "a design contract with no legal-and-support section is refused"
    expect_contains "$out" 'missing the required heading' \
        "the refusal names the section a product repository must keep too"
    cp "$design_base" "$design"

    grep -vF 'reachable only from the paywall' "$design_base" > "$design"
    rc="$(run_capture "${work}/paywall.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/paywall.txt")"
    expect_exit 65 "$rc" "dropping the prohibition on paywall-only legal links is refused"
    expect_contains "$out" 'does not state the legal and support rule' \
        "the refusal names the rule rather than the line"
    cp "$design_base" "$design"

    # ---- The generated milestone -------------------------------------------
    local gen="${fx}/AI/prompts/initialize-product.md"
    local gen_base="${work}/initialize-product.base"
    cp "$gen" "$gen_base"

    grep -vF 'owns the legal and support links' "$gen_base" > "$gen"
    rc="$(run_capture "${work}/mandate.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/mandate.txt")"
    expect_exit 65 "$rc" "initialization that generates no legal-and-support milestone is refused"
    expect_contains "$out" 'owns the legal and support links' "the refusal names the missing mandate"
    cp "$gen_base" "$gen"

    # It is an ordinary implementation milestone, so it is described in prose.
    # Writing it into the final sequence's `<title> -> <prompt>` form would make it
    # a second generated final milestone, and the existing fixture comparison — not a second
    # rule added for this contract — is what refuses that.
    printf '\nLegal and Support -> AI/prompts/audit-release.md\n' >> "$gen"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting legal and support to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "$gen_base" "$gen"

    # ---- The site itself ----------------------------------------------------
    local terms="${fx}/Web/public/terms/index.html"
    local terms_base="${work}/terms.base"
    cp "$terms" "$terms_base"

    sed 's|https://www.apple.com/legal/internet-services/itunes/dev/stdeula/|https://example.com/|' \
        "$terms_base" > "$terms"
    rc="$(run_capture "${work}/eula.txt" "${fx}/Scripts/verify-site.sh")"
    out="$(cat "${work}/eula.txt")"
    expect_exit 65 "$rc" "a terms page that stopped linking to Apple's Standard EULA is refused"
    expect_contains "$out" "does not link to Apple's Standard EULA" \
        "the refusal names the missing licence link"
    cp "$terms_base" "$terms"

    local support="${fx}/Web/public/support/index.html"
    local support_base="${work}/support.base"
    cp "$support" "$support_base"

    sed 's|href="/privacy/"|href="/nowhere/"|' "$support_base" > "$support"
    rc="$(run_capture "${work}/link.txt" "${fx}/Scripts/verify-site.sh")"
    out="$(cat "${work}/link.txt")"
    expect_exit 65 "$rc" "a broken link between the published pages is refused"
    expect_contains "$out" 'which is not in the site' \
        "the refusal names the link that resolves to nothing"
    cp "$support_base" "$support"

    # A page deleted outright is a missing input, not a failed assertion, so it
    # exits 66 rather than 65 — the caller can tell "the site is wrong" from "the
    # site is not there".
    rm -f "${fx}/Web/public/privacy/index.html"
    rc="$(run_capture "${work}/missing.txt" "${fx}/Scripts/verify-site.sh")"
    out="$(cat "${work}/missing.txt")"
    expect_exit 66 "$rc" "a deleted privacy page is reported as a missing input"
    expect_contains "$out" 'Web/public/privacy/index.html is missing' \
        "the refusal names the page that is gone"
    git -C "$fx" checkout -q -- Web/public/privacy/index.html

    # The template itself must also refuse to ship without the scaffold: a product
    # generated from a template whose Web/ was deleted cannot be compliant.
    rc="$(run_capture "${work}/scaffold.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the restored scaffold satisfies the template gate"

    rm -rf "${fx}/Web/public/support"
    rc="$(run_capture "${work}/noscaffold.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/noscaffold.txt")"
    expect_exit 65 "$rc" "a template shipping without the support page is refused"
    expect_contains "$out" 'published site scaffold is missing' \
        "the refusal names the scaffold rather than a product's site"
    git -C "$fx" checkout -q -- Web/public/support

    # ---- Configuration ------------------------------------------------------
    #
    # The drift this exists to catch: a product changes SUPPORT_SITE_URL and the
    # pages keep pointing at the old origin, so the app ships links to a site that
    # answers for something else.
    local cfg="${fx}/Config/project.env"
    local cfg_base="${work}/project.env.base"
    cp "$cfg" "$cfg_base"

    sed 's|^SUPPORT_SITE_URL=.*|SUPPORT_SITE_URL="https://elsewhere.pages.dev"|' \
        "$cfg_base" > "$cfg"
    rc="$(run_capture "${work}/drift.txt" "${fx}/Scripts/verify-site.sh")"
    out="$(cat "${work}/drift.txt")"
    expect_exit 65 "$rc" "pages left pointing at a different origin than the configuration are refused"
    expect_contains "$out" 'not under https://elsewhere.pages.dev' \
        "the refusal names both the page's origin and the configured one"
    expect_contains "$out" 'does not name the Pages project' \
        "the Cloudflare project name is checked against the same source"
    cp "$cfg_base" "$cfg"

    # A malformed value is refused wherever it is read, immediately — unlike an
    # empty one, which stays legal until the Legal and Support milestone runs.
    sed 's|^SUPPORT_SITE_URL=.*|SUPPORT_SITE_URL="http://insecure.pages.dev"|' \
        "$cfg_base" > "$cfg"
    rc="$(run_capture "${work}/insecure.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/insecure.txt")"
    expect_exit 65 "$rc" "a cleartext site URL is refused by the static gate"
    expect_contains "$out" 'must use https' "the refusal explains why cleartext is not allowed"
    cp "$cfg_base" "$cfg"

    # An empty value is never demanded by a gate — verify-release.sh records why, and
    # the release cases reach READY_FOR_HUMAN with no site keys at all. The example
    # once claimed the opposite, so a developer reading it trusted a check that does
    # not exist. It must name the audit rows that actually owe the pages.
    local example
    example="$(cat "${IOSAI_ROOT}/Config/project.env.example")"
    expect_absent "$example" 'refuses an App Store candidate' \
        "the configuration example does not claim a gate enforces the site keys"
    expect_contains "$example" 'REL-503, REL-1004, and REL-1008 must be VERIFIED' \
        "the configuration example names the audit rows that owe the published pages"

    # ---- Everything restored ------------------------------------------------
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
    rc="$(run_capture "${work}/site-restored.txt" "${fx}/Scripts/verify-site.sh")"
    expect_exit 0 "$rc" "the site fixture was restored too"
}


# A developer who cannot reach the paid build on a real device improvises the way in,
# and the improvisation always ships something: a scattered isPremium check, a launch
# argument, a debug screen nobody removed. So the override is decided once — one type,
# one defaults key, resolved through the entitlement owner, wrapped in `#if DEBUG`.
#
# The half of this case that earns its keep is the SCANNER half. The Release build
# already refuses a reference to a DEBUG-only type from Release-compiled code, so a
# gate that only repeated that would be theatre. What compilation cannot catch is a
# raw `UserDefaults` read of the override's key sitting in unguarded code: it compiles
# in Release, ships a working override, and a configuration profile can set it. That
# is B9 below, and it is the reason verify-static.sh scans at all.
#
# The rest is false-positive control. A gate that fails a legitimate product gets
# deleted, and three of its shapes are subtle: `#if DEBUG && !targetEnvironment(...)`
# is a narrower guard and must pass, a doc comment naming the override is
# documentation and must pass, and a product that sells nothing has no override at
# all and must pass. `#if !RELEASE` must FAIL, because no Xcode configuration defines
# RELEASE by default — that region is exactly what compiles into the shipped build.
case_premium_override_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/ARCHITECTURE.md" "${IOSAI_ROOT}/AI/DESIGN.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-release.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 6000 ]; then
        check fail "the premium-override corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the premium-override corpus was collected (${#corpus} bytes)"

    expect_contains "$corpus" 'compiled out of Release' \
        "the architecture contract states the property the shipped build depends on"
    expect_contains "$corpus" 'A premium override that ships' \
        "shipping one is a prohibited pattern in every product, including free ones"
    expect_contains "$corpus" 'the one sanctioned construct' \
        "the release auditor is told not to file the mandated override as a finding"
    expect_contains "$corpus" 'delivers the override' \
        "the milestone that owns the entitlement source of truth owns the override"
    expect_contains "$corpus" 'resolves through the single entitlement owner' \
        "the override is one input to the source of truth, not a second answer"
    expect_contains "$corpus" 'never creates, alters, or finishes' \
        "the override never touches a real StoreKit transaction"
    expect_contains "$corpus" 'injected defaults suite' \
        "the product's tests are told what to cover, down to where the flag is read"
    expect_contains "$corpus" 'can never fail' \
        "the #if !DEBUG absence test that proves nothing is named and forbidden"

    # The scanner greps literal identifiers and the contract names them in prose:
    # two copies that can drift apart, leaving a gate that searches for a name no
    # product uses any more and passes everything forever. A check that cannot fail
    # is worse than no check, so the two are tied together here.
    local arch names_line ident
    arch="$(cat "${IOSAI_ROOT}/AI/ARCHITECTURE.md")"
    names_line="$(grep -m1 '^OVERRIDE_NAMES=' "${IOSAI_ROOT}/Scripts/verify-static.sh" || true)"
    for ident in DebugPremiumOverride forcePremium; do
        expect_contains "$arch" "$ident" \
            "the architecture contract names ${ident}, so a product knows what to build"
        expect_contains "$names_line" "$ident" \
            "the scanner looks for ${ident}, so the gate and the contract cannot drift"
    done

    # The prohibition this change had to coexist with, not relax. REL-1101 cannot
    # be marked inapplicable on either channel.
    local rows
    rows="$(awk -F'\t' '$1 == "REL-1101" { print $1, $2, $3, $4 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-1101 all release no' \
        "the row forbidding a reachable debug path is unchanged and still unwaivable"

    # The row the documents cite as what the override does NOT answer. If it were
    # ever renumbered the citation would go stale and mislead a release auditor.
    rows="$(awk -F'\t' '$1 == "REL-1007" { print $1, $2 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-1007 app-store' \
        "the review-notes row the override cannot satisfy still exists"

    # No release row was added. The legal-and-support change removed checks for
    # duplicating a manual row that already cannot be marked inapplicable; a second
    # debug-path row would be that mistake again.
    local schema
    schema="$(grep -v '^#' "${IOSAI_ROOT}/Config/release-requirements.v3.tsv" || true)"
    expect_absent "$schema" 'override' \
        "the override adds no release row; REL-1101 already cannot be waived"

    local fx="${SELFTEST_DIR}/premium-override"
    local work="${SELFTEST_DIR}/premium-override-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped premium-override contract satisfies the fast gate"

    # ---- Each document anchor fires ----------------------------------------
    local doc base
    for doc in AI/ARCHITECTURE.md AI/DESIGN.md AI/prompts/audit-release.md \
               AI/prompts/initialize-product.md
    do
        base="${work}/$(basename "$doc").base"
        cp "${fx}/${doc}" "$base"
    done

    grep -vF -- 'compiled out of Release' "${work}/ARCHITECTURE.md.base" \
        > "${fx}/AI/ARCHITECTURE.md"
    rc="$(run_capture "${work}/arch.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/arch.txt")"
    expect_exit 65 "$rc" "dropping the compiled-out rule from architecture is refused"
    expect_contains "$out" 'does not state the premium override rule' \
        "the refusal names the rule rather than the line"
    cp "${work}/ARCHITECTURE.md.base" "${fx}/AI/ARCHITECTURE.md"

    grep -vF -- 'A premium override that ships' "${work}/DESIGN.md.base" \
        > "${fx}/AI/DESIGN.md"
    rc="$(run_capture "${work}/design.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the prohibition on a shipping override is refused"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"

    grep -vF -- 'the one sanctioned construct' "${work}/audit-release.md.base" \
        > "${fx}/AI/prompts/audit-release.md"
    rc="$(run_capture "${work}/audit.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a release audit that would file the override as a finding is refused"
    cp "${work}/audit-release.md.base" "${fx}/AI/prompts/audit-release.md"

    grep -vF -- 'delivers the override' "${work}/initialize-product.md.base" \
        > "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/init.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "initialization that gives no milestone the override is refused"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    # The override is a rider on the entitlement milestone, not a second final one.
    # The EXISTING byte-compared generation table is what refuses that, not a rule
    # added here.
    printf '\nPremium Override -> AI/prompts/audit-release.md\n' \
        >> "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting the override to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every document mutation was restored"

    # ---- The scanner -------------------------------------------------------
    # The template fixture has no Swift sources at all, so the scan must say it did
    # not run rather than claim a clean result it never earned.
    rc="$(run_capture "${work}/none.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/none.txt")"
    expect_exit 0 "$rc" "a repository with no shipped Swift sources passes"
    expect_contains "$out" 'no shipped Swift sources' \
        "the scan reports a skip instead of a clean result it did not earn"

    local src="${fx}/App/Fixture/Premium.swift"
    mkdir -p "${fx}/App/Fixture"

    # B1 — the whole point: a legitimate product WITH an override passes.
    printf '#if DEBUG\nenum DebugPremiumOverride { static var isEnabled = false }\n#endif\n' > "$src"
    rc="$(run_capture "${work}/guarded.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "an override inside #if DEBUG passes"

    # B2 — no guard at all.
    printf 'enum DebugPremiumOverride { static var isEnabled = false }\n' > "$src"
    rc="$(run_capture "${work}/unguarded.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/unguarded.txt")"
    expect_exit 65 "$rc" "an unguarded override fails the static gate"
    expect_contains "$out" 'App/Fixture/Premium.swift:1' \
        "the refusal names the file and the line, not just the repository"

    # B3 — the branch a line-oriented grep would pass: #else of #if DEBUG ships.
    printf '#if DEBUG\nlet a = 1\n#else\nlet o = DebugPremiumOverride.isEnabled\n#endif\n' > "$src"
    rc="$(run_capture "${work}/elsebranch.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "an override in the #else branch of #if DEBUG fails"

    # B4 — the most dangerous near-miss: nothing defines RELEASE by default.
    printf '#if !RELEASE\nlet o = DebugPremiumOverride.isEnabled\n#endif\n' > "$src"
    rc="$(run_capture "${work}/notrelease.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/notrelease.txt")"
    expect_exit 65 "$rc" "#if !RELEASE is not accepted as a DEBUG guard"
    expect_contains "$out" 'not a guard' "the refusal explains why !RELEASE guards nothing"

    # B5 — a disjunction is wider than DEBUG.
    printf '#if DEBUG || INTERNAL\nlet o = DebugPremiumOverride.isEnabled\n#endif\n' > "$src"
    rc="$(run_capture "${work}/orcond.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "#if DEBUG || INTERNAL is not accepted as a DEBUG guard"

    # B6 — nesting must not false-fail.
    printf '#if DEBUG\n#if os(iOS)\nlet o = DebugPremiumOverride.isEnabled\n#endif\n#endif\n' > "$src"
    rc="$(run_capture "${work}/nested.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "an override nested inside #if DEBUG passes"

    # B7 — a conjunction is narrower than DEBUG, so it is still a guard.
    printf '#if DEBUG && !targetEnvironment(macCatalyst)\nlet o = DebugPremiumOverride.isEnabled\n#endif\n' > "$src"
    rc="$(run_capture "${work}/andcond.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a narrower #if DEBUG && ... guard passes"

    # B8 — documentation about the override is not the override.
    printf '/// DebugPremiumOverride never applies in Release.\n/*\n forcePremium is documented here.\n*/\nstruct Paywall {}\n' > "$src"
    rc="$(run_capture "${work}/comment.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a comment naming the override is documentation, not a finding"

    # B9 — the case compilation cannot catch, and the reason this scan exists.
    printf 'let on = UserDefaults.standard.bool(forKey: "forcePremium")\n' > "$src"
    rc="$(run_capture "${work}/rawkey.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "an unguarded read of the override key fails, which no Release build would"

    # B12 — containment cannot be proved in a file whose directives do not nest.
    printf '#if DEBUG\nlet o = DebugPremiumOverride.isEnabled\n' > "$src"
    rc="$(run_capture "${work}/unbalanced.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/unbalanced.txt")"
    expect_exit 65 "$rc" "an unbalanced #if is refused rather than read as guarded"
    expect_contains "$out" 'unbalanced conditional compilation' \
        "the refusal says the guard structure could not be determined"
    rm -f "$src"

    # B10 — a test bundle is not shipped and builds only in Debug, so a test that
    # drives the override is not asked to wrap itself.
    mkdir -p "${fx}/App/FixtureTests"
    printf 'let o = DebugPremiumOverride.isEnabled\n' > "${fx}/App/FixtureTests/OverrideTests.swift"
    rc="$(run_capture "${work}/tests.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a test target exercising the override is not a finding"
    rm -rf "${fx}/App/FixtureTests"

    # B11 — a product that sells nothing has no override, and owes none.
    rc="$(run_capture "${work}/free.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a product with no override at all passes"

    # A free product deletes AI/DESIGN.md's purchases section outright. The anchors
    # must survive that, or this contract would fail every legitimately free app —
    # which is why none of them lives in that section.
    awk '/^## Purchases and paywalls$/{s=1} /^## Review request$/{s=0} !s' \
        "${work}/DESIGN.md.base" > "${fx}/AI/DESIGN.md"
    rc="$(run_capture "${work}/nopurchases.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a product that deleted its purchases section still passes"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"

    rc="$(run_capture "${work}/final.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# A paywall is where a product is most tempted to lie, and the cheapest lies are a
# crossed-out price nothing ever charged and a saving nobody computed. Neither looks
# wrong to whoever wrote it: they read their own paywall, in their own storefront,
# with the numbers they already believe. So four documents carry the rule and two
# gates hold it — verify-template.sh proves the documents still state it, and
# verify-static.sh refuses a price written into the build.
#
# The half of this case that earns its keep is again the SCANNER half, and here the
# expensive mistake is the FALSE POSITIVE rather than the miss. `$0` and `$1` are
# Swift's closure shorthand and appear on every second screen, `$binding` is a
# property wrapper, and `%1$@` is how a localized format string with two arguments is
# written. A gate that failed any of them would be deleted inside a week and take the
# rule with it, so more of what follows proves tolerance than proves refusal.
case_price_presentation_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/ARCHITECTURE.md" "${IOSAI_ROOT}/AI/DESIGN.md" \
        "${IOSAI_ROOT}/AI/PRODUCT.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-release.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-content.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-product.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 8000 ]; then
        check fail "the price-presentation corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the price-presentation corpus was collected (${#corpus} bytes)"

    # The rule itself, stated where each part of it belongs.
    expect_contains "$corpus" 'twelve times the price StoreKit returned' \
        "the comparison is defined as arithmetic over a real product, not a figure"
    expect_contains "$corpus" 'can only understate the claim' \
        "the rounding direction is fixed, so a saving is never rounded up into a lie"
    expect_contains "$corpus" 'the price that applies when it ends' \
        "an introductory offer states what is charged afterwards"
    expect_contains "$corpus" 'most prominent number' \
        "the amount actually charged is what the screen leads with"
    expect_contains "$corpus" 'rather than a comparison it cannot justify' \
        "a product that fails to load loses the comparison, not the honest price"
    expect_contains "$corpus" 'against the real StoreKit values' \
        "the content audit reads the paywall copy against the store, not itself"
    expect_contains "$corpus" 'not actually the better value' \
        "the product audit checks that the recommended plan is the better one"
    expect_contains "$corpus" 'REL-408' \
        "the architecture contract names the manual row that answers what no test can"

    # The gate greps four phrases and this case asserts the same four in prose: two
    # copies that can drift apart, leaving a gate that searches for wording no
    # document uses any more and passes everything forever. Tying them together is
    # what makes a reworded anchor fail here instead of silently disarming the gate.
    local anchors phrase
    anchors="$(sed -n '/^PRICE_PRESENTATION_PHRASES=/,/^"$/p' \
        "${IOSAI_ROOT}/Scripts/verify-template.sh")"
    for phrase in 'computed, never authored' 'An invented reference price' \
                  'the products the store actually returns' \
                  'delivers its price presentation'
    do
        expect_contains "$anchors" "$phrase" \
            "the gate anchors on '${phrase}'"
        expect_contains "$corpus" "$phrase" \
            "the documents state '${phrase}', so the anchor cannot drift off them"
    done

    # The scanner's symbol list is the other copy that can drift: the fixtures below
    # are written with these symbols, so a list that lost one fails here.
    local symbols_line sym
    symbols_line="$(grep -m1 '^PRICE_SYMBOLS=' "${IOSAI_ROOT}/Scripts/verify-static.sh" || true)"
    for sym in '$' '€'; do
        expect_contains "$symbols_line" "$sym" \
            "the scanner looks for ${sym}, the symbol the fixtures below are written with"
    done

    # The comparison-price row and the two related coverage rows deliberately remain
    # distinct so their audit ownership stays explicit.
    local rows
    rows="$(awk -F'\t' '$1 == "REL-408" { print $1, $2, $3, $4 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-408 all content,product,release yes' \
        "the comparison is audited against real products, or is genuinely inapplicable"
    rows="$(awk -F'\t' '$1 == "REL-405" || $1 == "REL-407" { print $1, $2, $3, $4 }' \
        "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    expect_contains "$rows" 'REL-405 all content,product,release yes' \
        "the currency row is unchanged"
    expect_contains "$rows" 'REL-407 all ui-ux,product,release yes' \
        "the prohibited-pattern row is unchanged, and now covers two more bullets"

    local fx="${SELFTEST_DIR}/price-presentation"
    local work="${SELFTEST_DIR}/price-presentation-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped price-presentation contract satisfies the fast gate"

    # ---- Each document anchor fires ----------------------------------------
    local doc base
    for doc in AI/ARCHITECTURE.md AI/DESIGN.md AI/PRODUCT.md \
               AI/prompts/audit-release.md AI/prompts/initialize-product.md
    do
        base="${work}/$(basename "$doc").base"
        cp "${fx}/${doc}" "$base"
    done

    grep -vF -- 'computed, never authored' "${work}/ARCHITECTURE.md.base" \
        > "${fx}/AI/ARCHITECTURE.md"
    rc="$(run_capture "${work}/arch.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/arch.txt")"
    expect_exit 65 "$rc" "dropping the derived-comparison rule from architecture is refused"
    expect_contains "$out" 'does not state the price presentation rule' \
        "the refusal names the rule rather than the line"
    cp "${work}/ARCHITECTURE.md.base" "${fx}/AI/ARCHITECTURE.md"

    grep -vF -- 'An invented reference price' "${work}/DESIGN.md.base" \
        > "${fx}/AI/DESIGN.md"
    rc="$(run_capture "${work}/design.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "dropping the prohibition on an invented reference price is refused"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"

    grep -vF -- 'the products the store actually returns' \
        "${work}/audit-release.md.base" > "${fx}/AI/prompts/audit-release.md"
    rc="$(run_capture "${work}/audit.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a release audit that would take the paywall's own word for it is refused"
    cp "${work}/audit-release.md.base" "${fx}/AI/prompts/audit-release.md"

    grep -vF -- 'delivers its price presentation' \
        "${work}/initialize-product.md.base" > "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/init.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "initialization that gives no milestone the price presentation is refused"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every document mutation was restored"

    # A free product deletes AI/DESIGN.md's purchases section and AI/PRODUCT.md's
    # free-versus-paid subsection outright, so no anchor may live in either — this
    # contract would otherwise fail every legitimately free app.
    awk '/^## Purchases and paywalls$/{s=1} /^## Review request$/{s=0} !s' \
        "${work}/DESIGN.md.base" > "${fx}/AI/DESIGN.md"
    awk '/^### Free versus paid$/{s=1} /^### Review request$/{s=0} !s' \
        "${work}/PRODUCT.md.base" > "${fx}/AI/PRODUCT.md"
    rc="$(run_capture "${work}/free.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a product that sells nothing, and deleted both sections, still passes"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"
    cp "${work}/PRODUCT.md.base" "${fx}/AI/PRODUCT.md"

    # ---- The scanner -------------------------------------------------------
    # The template fixture has no sources at all, so the scan must say it did not run
    # rather than claim a clean result it never earned.
    rc="$(run_capture "${work}/none.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/none.txt")"
    expect_exit 0 "$rc" "a repository with no shipped sources passes"
    expect_contains "$out" 'no shipped sources or string catalogs' \
        "the scan reports a skip instead of a clean result it did not earn"

    local src="${fx}/App/Fixture/Paywall.swift"
    mkdir -p "${fx}/App/Fixture"

    # P1 — the defect itself: a price typed into a view.
    printf 'Text("$9.99")\n' > "$src"
    rc="$(run_capture "${work}/dollar.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/dollar.txt")"
    expect_exit 65 "$rc" "a price typed into a view fails the static gate"
    expect_contains "$out" 'App/Fixture/Paywall.swift:1' \
        "the refusal names the file and the line, not just the repository"

    # P2 — the same defect in the other convention, which a dollar-shaped pattern
    # would have missed entirely.
    printf 'Text("€4,99")\n' > "$src"
    rc="$(run_capture "${work}/euro.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a comma-decimal price in euros fails too"

    # P3 — and in the order the euro is actually written in.
    printf 'let plan = "4,99 €"\n' > "$src"
    rc="$(run_capture "${work}/euro-suffix.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "an amount followed by its symbol fails"

    # P4 — the hard one: the price is real and only the symbol is hard-coded, so the
    # app is correct in one storefront and wrong in every other.
    printf 'Text("$\\(price)")\n' > "$src"
    rc="$(run_capture "${work}/interp.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a currency symbol wrapped around a real price fails"

    # P5 — a whole-number price, which has no decimal point to find it by.
    printf 'Text("$19")\n' > "$src"
    rc="$(run_capture "${work}/whole.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a whole-number price fails"

    # ---- What it must tolerate ---------------------------------------------
    # P6 — Swift's closure shorthand, in the shape it is written a hundred times in
    # any real project. This is the false positive that would end the gate.
    printf 'let s = items.map { $0.price }.sorted { $0.id < $1.id }\n' > "$src"
    rc="$(run_capture "${work}/closure.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "closure shorthand is not a price"

    # P7 — positional format specifiers, including past nine, and a property wrapper.
    printf 'let f = "%%1$@ of %%2$@ and %%12$@"\nlet b = $binding.wrappedValue\n' > "$src"
    rc="$(run_capture "${work}/format.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "positional specifiers and property wrappers are not prices"

    # P8 — the correct code, which must never be what the gate reports.
    printf 'Text(product.displayPrice)\nText("Save \\(percent)%%")\n' > "$src"
    rc="$(run_capture "${work}/correct.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a price taken from the loaded product is not a finding"

    # P9 — documentation about a price is not a price, in both comment forms.
    printf '/// The paywall showed $9.99 before the annual plan.\n/*\n 4,99 € was the old one.\n*/\nstruct Paywall {}\n' > "$src"
    rc="$(run_capture "${work}/comment.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a comment quoting a price is documentation, not a finding"
    rm -f "$src"

    # P10 — the string catalog, which is where a price does the most damage: it is
    # handed to a translator as though it were copy.
    printf '{ "strings" : { "plan" : { "value" : "$9.99" } } }\n' \
        > "${fx}/App/Fixture/Localizable.xcstrings"
    rc="$(run_capture "${work}/catalog.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/catalog.txt")"
    expect_exit 65 "$rc" "a price in a string catalog fails"
    expect_contains "$out" 'Localizable.xcstrings:1' \
        "the refusal names the catalog, not only the sources"
    rm -f "${fx}/App/Fixture/Localizable.xcstrings"

    # P11 — a test bundle is not shipped, and a test for this rule has to name a
    # price to assert anything at all.
    mkdir -p "${fx}/App/FixtureTests"
    printf 'XCTAssertEqual(formatted, "$9.99")\n' > "${fx}/App/FixtureTests/PriceTests.swift"
    rc="$(run_capture "${work}/tests.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a test asserting against a price is not a finding"
    rm -rf "${fx}/App/FixtureTests"

    # P12 — neither is preview data, which never reaches a person.
    mkdir -p "${fx}/App/Fixture/Preview Content"
    printf 'let sample = "$9.99"\n' > "${fx}/App/Fixture/Preview Content/Sample.swift"
    rc="$(run_capture "${work}/preview.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "preview content naming a price is not a finding"
    rm -rf "${fx}/App/Fixture/Preview Content"

    # P13 — a product that sells nothing has no price to display, and owes none.
    rm -rf "${fx}/App/Fixture"
    rc="$(run_capture "${work}/final.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a product with no paywall at all passes, and every mutation was restored"
}


# An application can satisfy every other contract in this repository and still be one
# nobody wants to open twice: correct states, passing tests, default hierarchy, no
# feedback, no reason to come back. That is not a defect any gate here can observe, so
# the only place it can be prevented is upstream — initialization asking what the core
# loop is and what this product's own mechanics are, DESIGN carrying an action
# hierarchy and a signature moment, and the Builder's self-review covering craft in the
# same session it already owns.
#
# This case asserts what the review-request and legal-and-support contracts assert:
# that the documents STATE the rules, and that the guard FIRES. It adds no role, no
# session, no milestone state, and no document — and two of the assertions below exist
# specifically to prove that, because "improve quality" is the request most likely to
# come back as a new mandatory stage.
case_product_craftsmanship_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/DESIGN.md" "${IOSAI_ROOT}/AI/PRODUCT.md" \
        "${IOSAI_ROOT}/AI/WORKFLOW.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/execute-next-milestone.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-product.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 8000 ]; then
        check fail "the craftsmanship corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the craftsmanship corpus was collected (${#corpus} bytes)"

    # ---- Initialization considers the product, not only the feature list ----
    expect_contains "$corpus" 'The core loop' \
        "initialization settles what the person does and what brings them back"
    expect_contains "$corpus" 'Repeat-use value' \
        "it asks what is better on a later visit than on the first"
    expect_contains "$corpus" 'candidate mechanics specific to this product' \
        "the mechanics it weighs are this product's own, not a catalogue"
    expect_contains "$corpus" 'streaks, points, badges, gamification' \
        "the generic ones need an argument before they are allowed in"
    expect_contains "$corpus" 'Signature Experience' \
        "one moment is proposed that should make the product feel unusually well made"

    # A concept, not a mandatory feature: a product with nothing that deserves one
    # says so. Without this, "every app has a signature experience" becomes bloat the
    # template asked for.
    expect_contains "$corpus" 'records `None` and the reason' \
        "a product that needs no signature moment records that instead of inventing one"
    expect_contains "$corpus" 'FUTURE_PRODUCT_IDEA' \
        "the mechanics that were not selected stay recorded rather than built"

    # ---- iOS-native capability is an opportunity, never a checklist --------
    expect_contains "$corpus" 'especially well because it is an iOS app' \
        "the platform question is asked as an opportunity"
    expect_contains "$corpus" 'never a list to satisfy' \
        "and answered only where it carries user value for this product"

    # ---- DESIGN carries a craftsmanship contract, not a design system ------
    expect_contains "$corpus" '## Craftsmanship and signature experience' \
        "the design contract has a section for it"
    expect_contains "$corpus" 'It is not gradients, glass, cards, or animation' \
        "premium is defined as clarity and hierarchy rather than decoration"
    expect_contains "$corpus" 'it is a product language, not a design-system specification' \
        "the section stays small on purpose"
    expect_contains "$corpus" 'Decoration standing in for resolution' \
        "decoration used instead of resolving a screen is a prohibited pattern"

    # ---- The quality bar lives in the session that already exists ----------
    expect_contains "$corpus" 'craftsmanship pass' \
        "the Builder's self-review covers craft on user-facing work"
    expect_contains "$corpus" 'never a separate polish milestone after every feature' \
        "and it is not a milestone of its own"
    expect_contains "$corpus" 'says so in one line and moves on' \
        "a change with no user-facing surface is not made to answer UI categories"
    expect_contains "$corpus" 'judged on the running application' \
        "meaningful UI work is validated by driving the app, not by reading the diff"
    expect_contains "$corpus" 'Profiling belongs to a problem that was actually observed' \
        "performance work is proportional rather than routine"

    # ---- Specialized skills accelerate; they are never prerequisites -------
    expect_contains "$corpus" 'is not a dependency of this template' \
        "an optional iOS skill is never something the workflow requires"
    expect_contains "$corpus" 'Never add a capability to the product because a skill for it exists' \
        "and having a skill is not a reason to build the thing it is good at"

    # No new mandatory stage came with any of this. The five states and the one-session
    # rule are asserted elsewhere; what is asserted here is that this layer did not
    # quietly add a sixth of either.
    expect_absent "$corpus" 'craftsmanship milestone' \
        "craft did not become a milestone of its own"
    expect_absent "$corpus" 'craftsmanship review session' \
        "and it did not become a second session"

    # The gate greps six phrases and this case asserts the same six in prose: two
    # copies that can drift apart, leaving a gate that searches for wording no document
    # uses any more and passes everything forever. Tying them together is what makes a
    # reworded anchor fail here instead of silently disarming the gate.
    local anchors phrase
    anchors="$(sed -n '/^CRAFTSMANSHIP_PHRASES=/,/^"$/p' \
        "${IOSAI_ROOT}/Scripts/verify-template.sh")"
    for phrase in 'Signature Experience' \
                  'mechanics that genuinely fit the approved MVP' \
                  'FUTURE_PRODUCT_IDEA' \
                  'Decoration standing in for resolution' \
                  'craftsmanship pass' \
                  'is not a dependency of this template'
    do
        expect_contains "$anchors" "$phrase" \
            "the gate anchors on '${phrase}'"
        expect_contains "$corpus" "$phrase" \
            "the documents state '${phrase}', so the anchor cannot drift off them"
    done

    local fx="${SELFTEST_DIR}/craftsmanship"
    local work="${SELFTEST_DIR}/craftsmanship-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped craftsmanship contract satisfies the fast gate"

    local doc base
    for doc in AI/DESIGN.md AI/PRODUCT.md AI/WORKFLOW.md \
               AI/prompts/initialize-product.md
    do
        base="${work}/$(basename "$doc").base"
        cp "${fx}/${doc}" "$base"
    done

    # ---- The design section a product repository keeps too ------------------
    # A REQUIRED_HEADINGS row rather than a phrase, for the reason the review-request
    # contract records: the section has to survive into every generated product, and a
    # heading is what a rewrite deletes first.
    grep -vF -- '## Craftsmanship and signature experience' "${work}/DESIGN.md.base" \
        > "${fx}/AI/DESIGN.md"
    rc="$(run_capture "${work}/section.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/section.txt")"
    expect_exit 65 "$rc" "a design contract with no craftsmanship section is refused"
    expect_contains "$out" 'missing the required heading' \
        "the refusal names the section a product repository must keep too"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"

    # ---- Each document anchor fires ----------------------------------------
    grep -vF -- 'Decoration standing in for resolution' "${work}/DESIGN.md.base" \
        > "${fx}/AI/DESIGN.md"
    rc="$(run_capture "${work}/decoration.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/decoration.txt")"
    expect_exit 65 "$rc" "dropping the prohibition on decoration-as-resolution is refused"
    expect_contains "$out" 'does not state the craftsmanship rule' \
        "the refusal names the rule rather than the line"
    cp "${work}/DESIGN.md.base" "${fx}/AI/DESIGN.md"

    grep -vF -- 'FUTURE_PRODUCT_IDEA' "${work}/PRODUCT.md.base" \
        > "${fx}/AI/PRODUCT.md"
    rc="$(run_capture "${work}/idea.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a product contract with nowhere to record an unselected idea is refused"
    cp "${work}/PRODUCT.md.base" "${fx}/AI/PRODUCT.md"

    grep -vF -- 'craftsmanship pass' "${work}/WORKFLOW.md.base" \
        > "${fx}/AI/WORKFLOW.md"
    rc="$(run_capture "${work}/pass.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a self-review that stops at 'it works and the tests pass' is refused"
    cp "${work}/WORKFLOW.md.base" "${fx}/AI/WORKFLOW.md"

    # The one anchor that protects the template FROM a change rather than requiring
    # one: without it, a rewrite could make an optional iOS skill a prerequisite and
    # every machine without it would fail for a reason no message explains.
    grep -vF -- 'is not a dependency of this template' "${work}/WORKFLOW.md.base" \
        > "${fx}/AI/WORKFLOW.md"
    rc="$(run_capture "${work}/optional.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "making a specialized iOS skill a prerequisite is refused"
    cp "${work}/WORKFLOW.md.base" "${fx}/AI/WORKFLOW.md"

    grep -vF -- 'Signature Experience' "${work}/initialize-product.md.base" \
        > "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/signature.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "initialization that proposes no signature moment is refused"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    grep -vF -- 'mechanics that genuinely fit the approved MVP' \
        "${work}/initialize-product.md.base" > "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/mechanics.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "initialization that never narrows the mechanics to the MVP is refused"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    # The craftsmanship layer generated no second final milestone, and this is the
    # existing fixture comparison proving it rather than a rule added for it.
    printf '\nSignature Experience Pass -> AI/prompts/audit-ui-ux.md\n' \
        >> "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting craft to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "${work}/initialize-product.md.base" "${fx}/AI/prompts/initialize-product.md"

    # Every mutation above restored something; assert that rather than assume it.
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# The craftsmanship contract above asks for a product that feels made rather than
# assembled. It never says how a moment worth building properly gets built, and this case
# guards the layer that does — in both directions, because "make it feel premium" fails
# twice over.
#
# The first failure is a product built entirely from default controls, because nothing
# told the session that a bespoke illustration, a piece of motion, or a haptic was ever an
# option. The second is the one a model actually produces when asked for polish: artwork on
# every screen, a spring on every transition, and a generated illustration filling space
# that a clearer hierarchy would have filled better. So every capability asserted below is
# paired with its bound, and the pairs are asserted together rather than in separate
# groups: an assertion set that established only the capability would ratchet this
# template toward decoration, which is precisely what it exists to prevent.
#
# Three further things are asserted because they are what a rewrite loses first. Missing
# design or image-generation tooling must never block a milestone — Claude and Codex are
# both valid here, and a template that quietly grew a dependency on one connected tool
# would fail on every machine without it for a reason no message explains. A bespoke
# moment must be judged running, because an asset in the catalogue is not an asset that
# works on the screen. And no product configuration may name a design file, URL, key,
# provider, or server for any of it, which is asserted against the accepted key set rather
# than against prose.
#
# README.md is deliberately outside the corpus, for the reason the decision-autonomy case
# below records: initialize-project.sh replaces it with a product guide, and this suite
# runs inside derived repositories via `make integration`.
case_visual_craftsmanship_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/DESIGN.md" "${IOSAI_ROOT}/AI/WORKFLOW.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/execute-next-milestone.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-ui-ux.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-accessibility.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 60000 ]; then
        check fail "the visual craft corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the visual craft corpus was collected (${#corpus} bytes)"

    # ---- The opportunity is identified up front, and stays small ------------
    expect_contains "$corpus" 'Delight Opportunities' \
        "initialization names the moments where bespoke work might earn its place"
    expect_contains "$corpus" 'normally two to four' \
        "and keeps the set small for an initial product"
    expect_contains "$corpus" 'an important empty state' \
        "the candidate moments include the states most often left default"
    expect_contains "$corpus" 'whose feedback carries the reassurance' \
        "and a destructive or recovery action where the feedback is the point"

    # ---- ...and every statement of it is bounded in the same breath ---------
    # Without this half, a section that merely EXISTS becomes a quota to fill.
    expect_contains "$corpus" 'They are opportunities, not features' \
        "a delight opportunity is never a feature the product owes"
    expect_contains "$corpus" 'an empty table is' \
        "a product with nothing that earns one records that instead of inventing one"
    expect_contains "$corpus" 'premium here means' \
        "premium is resolution rather than decoration"
    expect_contains "$corpus" 'a screen that needed nothing is finished once it is clear' \
        "and a screen that needed nothing is already finished"

    # ---- Native first is the medium order, not a fallback -------------------
    expect_contains "$corpus" 'Native first, and a bespoke asset only where native cannot express it' \
        "the platform solution is the first choice"
    expect_contains "$corpus" 'SF Symbols and symbol effects' \
        "and the native inventory is named rather than implied"
    expect_contains "$corpus" 'accessibility on their own, which is why they are the first choice' \
        "the reason given is that native adapts to state and accessibility by itself"
    expect_contains "$corpus" 'records why native was insufficient' \
        "a bespoke asset carries the same justification a custom control does"

    # ---- A generated asset is judged before it is kept ----------------------
    expect_contains "$corpus" 'obviously generated' \
        "artwork that reads as generated is rejected"
    expect_contains "$corpus" 'does not overpower the interface around it' \
        "an asset that outweighs the interface is rejected"
    expect_contains "$corpus" 'no simpler native solution would do the job better' \
        "and the last question asked of any asset is whether native would be better"
    expect_contains "$corpus" 'One strong asset is worth more than several decorative ones' \
        "one strong asset beats several decorative ones"
    expect_contains "$corpus" 'never calls an image-generation service at runtime' \
        "the committed application renders its own static artwork"
    expect_contains "$corpus" 'Never download web imagery into the' \
        "and web imagery is not harvested into the product because it looks about right"

    # ---- Motion is interaction design; micro-interactions are proportional --
    expect_contains "$corpus" 'Motion is interaction design' \
        "motion communicates rather than decorates"
    expect_contains "$corpus" 'Looping decoration, animation on every element' \
        "the named anti-patterns include looping and blanket animation"
    expect_contains "$corpus" 'An ordinary tap does not become an event' \
        "and feedback stays proportional to the interaction"

    # ---- Meaningful visual work is judged on the running application --------
    expect_contains "$corpus" 'not finished because the asset exists in the asset catalogue' \
        "an asset in the catalogue is not a finished moment"
    expect_contains "$corpus" 'Source inspection alone does not settle whether a visual moment works' \
        "reading the diff does not settle it"
    expect_contains "$corpus" 'That boundary is narrow:' \
        "and the physical-device boundary stays narrow rather than swallowing every asset"

    # ---- An available tool is used; a missing one is never a blocker --------
    expect_contains "$corpus" 'a design, image-generation, animation, or runtime-inspection tool' \
        "a specialized design, image, animation, or runtime tool is used where it helps"
    expect_contains "$corpus" 'XcodeBuildMCP' \
        "the recognizable examples are named so a session knows what it has"
    expect_contains "$corpus" 'is never a reason to block a milestone' \
        "and a missing one is never a reason to block a milestone"
    expect_contains "$corpus" 'nothing here assumes which agent implements' \
        "no agent is assumed, so Claude and Codex both remain valid"
    expect_contains "$corpus" 'nothing here adds a design-handoff step' \
        "a design tool did not become an approval stage"
    expect_contains "$corpus" 'code is the implementation source of truth' \
        "and code remains the implementation source of truth"

    # ---- Neither audit may turn a clean native screen into a defect ---------
    expect_contains "$corpus" 'custom imagery is not a finding' \
        "the interface audit does not report the absence of artwork"
    expect_contains "$corpus" 'not better because it has more custom visuals' \
        "and the product audit does not score a product for carrying more of it"
    expect_contains "$corpus" 'decorative artwork announced as content' \
        "accessibility covers bespoke visual work rather than exempting it"

    # ---- Decision autonomy is unchanged by any of it ------------------------
    expect_contains "$corpus" 'several technical ways to produce one effect' \
        "how to build an effect stays the session's own reversible choice"

    # ---- Nothing became a milestone, a session, a prompt, or a config key ---
    # The final milestone, the five states, and the three lifecycle prompts are
    # asserted by their own cases; what is asserted here is that this layer invented no
    # vocabulary for an eighth of anything.
    for invented in 'visual assets milestone' 'delight milestone' 'delight audit' \
                    'visual craftsmanship milestone' 'visual review session' \
                    'design review session' 'design handoff stage' \
                    'Figma is required' 'image generation is required'
    do
        expect_absent "$corpus" "$invented" \
            "the capability did not invent '${invented}'"
    done

    # A configuration key is the one way an optional tool becomes a prerequisite that no
    # amount of prose can undo, so this is asserted against the accepted key set itself.
    local config_keys
    config_keys="$(grep -E '^[A-Z][A-Z0-9_]*=' \
        "${IOSAI_ROOT}/Config/project.env.example" | sed 's/=.*//' | tr '\n' ' ')"
    if [ -z "$config_keys" ]; then
        check fail "no configuration keys were read; the key scan did not run"
    else
        check pass "the configured key set was read (${config_keys% })"
        for forbidden_key in FIGMA DESIGN IMAGE MCP ASSET; do
            expect_absent "$config_keys" "$forbidden_key" \
                "no configuration key names ${forbidden_key}"
        done
    fi

    # ---- The gate anchors and the documents cannot drift apart -------------
    # Asserted per row rather than against the flattened corpus: three files carry more
    # than one anchor, and a corpus match would be satisfied by whichever kept one.
    local anchors rows doc phrase
    anchors="$(sed -n '/^VISUAL_CRAFT_PHRASES=/,/^"$/p' \
        "${IOSAI_ROOT}/Scripts/verify-template.sh")"
    rows='AI/prompts/initialize-product.md|Delight Opportunities
AI/DESIGN.md|They are opportunities, not features
AI/DESIGN.md|Native first, and a bespoke asset only where native cannot express it
AI/DESIGN.md|One strong asset is worth more than several decorative ones
AI/WORKFLOW.md|a design, image-generation, animation, or runtime-inspection tool
AI/WORKFLOW.md|is never a reason to block a milestone
AI/WORKFLOW.md|not finished because the asset exists in the asset catalogue
AI/prompts/audit-ui-ux.md|custom imagery is not a finding
AI/prompts/audit-product.md|not better because it has more custom visuals
AI/prompts/audit-accessibility.md|decorative artwork announced as content'

    while IFS='|' read -r doc phrase; do
        [ -n "${doc:-}" ] || continue
        expect_contains "$anchors" "$(printf '%s\t%s' "$doc" "$phrase")" \
            "the gate anchors '${phrase}' on ${doc}"
        if grep -Fq -- "$phrase" "${IOSAI_ROOT}/${doc}"; then
            check pass "${doc} states it, so the anchor cannot drift off that file"
        else
            check fail "${doc} does not state '${phrase}'; the anchor points at nothing"
        fi
    done <<EOF
$rows
EOF

    local fx="${SELFTEST_DIR}/visual-craft"
    local work="${SELFTEST_DIR}/visual-craft-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out base before after complaints
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped visual craftsmanship contract satisfies the fast gate"

    # Each row is copied, mutated, and restored inside its own iteration, so three rows
    # targeting AI/WORKFLOW.md cannot skew one another.
    while IFS='|' read -r doc phrase; do
        [ -n "${doc:-}" ] || continue
        base="${work}/mutating.base"
        cp "${fx}/${doc}" "$base"
        before="$(wc -l < "$base" | tr -d ' ')"
        grep -vF -- "$phrase" "$base" > "${fx}/${doc}"
        after="$(wc -l < "${fx}/${doc}" | tr -d ' ')"

        # The anchor sat on its own line, and nothing else left the file with it.
        expect_same "$((before - after))" "1" \
            "dropping '${phrase}' removed exactly one line of ${doc}"

        rc="$(run_capture "${work}/dropped.txt" "${fx}/Scripts/verify-template.sh")"
        out="$(cat "${work}/dropped.txt")"
        expect_exit 65 "$rc" "a template that dropped '${phrase}' is refused"
        expect_contains "$out" "does not state the visual craftsmanship rule: ${phrase}" \
            "the refusal names that rule rather than the family"

        # Exactly one rule complained, so this mutation proved this anchor and no other.
        complaints="$(grep -cF 'does not state the visual craftsmanship rule' \
            "${work}/dropped.txt" || true)"
        expect_same "${complaints:-0}" "1" \
            "only '${phrase}' complained, so no neighbouring anchor was collateral"

        cp "$base" "${fx}/${doc}"
    done <<EOF
$rows
EOF

    # The capability generated no second final milestone, and this is the existing
    # generation contract proving it rather than a rule added for it.
    cp "${fx}/AI/prompts/initialize-product.md" "${work}/generator.base"
    printf '\nDelight Opportunities Pass -> AI/prompts/audit-ui-ux.md\n' \
        >> "${fx}/AI/prompts/initialize-product.md"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting delight work to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "${work}/generator.base" "${fx}/AI/prompts/initialize-product.md"

    # Every mutation above restored something; assert that rather than assume it.
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# One rule decides how often a session interrupts the developer, and it decays in both
# directions. Asked too readily, it turns every reversible choice — a state container, a
# view split, a test shape — into a question the contracts already answer, and the
# developer becomes the bottleneck for work they delegated. Asked too rarely, a session
# quietly settles pricing or a privacy boundary because stopping felt like friction.
# Neither failure is observable by any gate: both look like a session doing its job.
#
# So this case asserts what the other prose contracts assert — that the documents STATE
# the rule, and that the guard FIRES — and it adds nothing to the gate beyond the anchor
# loop. What is new here is the strength of the tie. Three earlier drafts of this policy
# used one shared anchor across several files, which passes when ANY one file carries it
# while reading as though all of them do; every anchor is therefore distinct, the tie is
# asserted per file as a tab-joined row, and each mutation asserts that exactly one line
# left the file and exactly one rule complained. Without those two counts a mutation that
# also deleted a neighbouring anchor would still exit 65, and the case would pass while
# proving something else entirely.
#
# README.md is deliberately outside the corpus: initialize-project.sh replaces it with a
# product guide, and this suite runs inside derived repositories via `make integration`.
# That is the same discriminator case_documentation_consistency uses for the same reason.
case_decision_autonomy_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AGENTS.md" "${IOSAI_ROOT}/CLAUDE.md" \
        "${IOSAI_ROOT}/AI/WORKFLOW.md" "${IOSAI_ROOT}/AI/PRODUCT.md" \
        "${IOSAI_ROOT}/AI/prompts/execute-next-milestone.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/audit-product.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 25000 ]; then
        check fail "the decision corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the decision corpus was collected (${#corpus} bytes)"

    # ---- The default: decide, recommend, keep going ------------------------
    expect_contains "$corpus" 'choose the one you would recommend and proceed' \
        "a reasonable set of options is resolved by choosing the recommended one"
    expect_contains "$corpus" 'any other reversible implementation choice' \
        "and the categories are open-ended rather than a closed list"
    expect_contains "$corpus" 'Prefer the simplest' \
        "the tie-breaker is the simplest option the approved product allows"
    expect_contains "$corpus" 'do not stop to present a choice this session can responsibly resolve' \
        "presenting a resolvable choice is named as the thing not to do"
    expect_contains "$corpus" 'spends the developer' \
        "and asking to look careful is named as a cost rather than as caution"
    expect_contains "$corpus" 'A16 Decide reversible choices yourself' \
        "the obligation list carries the default"

    # ---- The boundary: what is still the developer's -----------------------
    expect_contains "$corpus" 'Interrupt the milestone only for a genuine product decision' \
        "the stop rule still opens with the genuine-product-decision test"
    for trigger in 'MVP scope' 'monetization or pricing' 'privacy' \
                   'destructive or irreversible behavior' 'significant product mechanic' \
                   'legal or compliance decision' 'neither option clearly preferable'
    do
        expect_contains "$corpus" "$trigger" \
            "the stop list names '${trigger}'"
    done

    # ---- The shape of a question that does reach the developer -------------
    expect_contains "$corpus" 'two to four genuine options' \
        "a question offers two to four options"
    expect_contains "$corpus" 'the trade-off that separates them in a sentence each' \
        "each option carries the trade-off that separates it"
    expect_contains "$corpus" 'exactly one marked Recommended' \
        "exactly one of them is marked as the recommendation"
    expect_contains "$corpus" 'wait for that choice before continuing' \
        "and nothing proceeds until the developer chooses"
    expect_contains "$corpus" 'the recommendation is not an answer' \
        "the recommendation itself is not read as the answer"
    expect_contains "$corpus" 'A recommendation is not a resolution' \
        "a marked option in an unresolved row stays unresolved"

    # The question has to survive the session that asked it, or the next session reads a
    # chat it cannot see. AGENTS.md:6 makes the repository the memory; this is where the
    # policy honours that, using the status field that already exists.
    expect_contains "$corpus" 'line of `AI/PROJECT_STATUS.md`' \
        "the decision and its options are recorded where the repository keeps them"

    # ---- Nothing became a stage, a state, a role, or a document ------------
    # The one-session rule and the five states are asserted by case_workflow_contract and
    # by IOSAI_MILESTONE_STATUSES in Scripts/lib/common.sh; AI/decisions and
    # AI/templates/decision-record-template.md are already in FORBIDDEN_LIVE_PATHS. What
    # is asserted here is only that this policy invented no vocabulary for one.
    expect_contains "$corpus" 'one milestone per session' \
        "one session is still one milestone"
    expect_contains "$corpus" 'Set `BLOCKED`' \
        "asking still uses the milestone state that already exists"
    for invented in 'decision milestone' 'decision session' 'decision gate' \
                    'AWAITING_DECISION' 'decision record'
    do
        expect_absent "$corpus" "$invented" \
            "the policy did not invent '${invented}'"
    done

    # ---- The gate anchors and the documents cannot drift apart -------------
    # Asserted per row rather than against the flattened corpus: three of these phrases
    # would otherwise be satisfied by whichever file happened to keep one.
    local anchors rows doc phrase
    anchors="$(sed -n '/^DECISION_PHRASES=/,/^"$/p' \
        "${IOSAI_ROOT}/Scripts/verify-template.sh")"
    rows='AGENTS.md|A16 Decide reversible choices yourself
AGENTS.md|two to four options, one marked Recommended
AI/WORKFLOW.md|any other reversible implementation choice
AI/WORKFLOW.md|two to four genuine options
AI/WORKFLOW.md|exactly one marked Recommended
AI/WORKFLOW.md|wait for that choice before continuing
AI/prompts/execute-next-milestone.md|choose the option you would recommend
AI/prompts/execute-next-milestone.md|exactly one option marked Recommended
AI/prompts/initialize-product.md|Options column offers two to four
AI/prompts/audit-product.md|precise question with two to four options
AI/PRODUCT.md|A recommendation is not a resolution'

    while IFS='|' read -r doc phrase; do
        [ -n "${doc:-}" ] || continue
        expect_contains "$anchors" "$(printf '%s\t%s' "$doc" "$phrase")" \
            "the gate anchors '${phrase}' on ${doc}"
        if grep -Fq -- "$phrase" "${IOSAI_ROOT}/${doc}"; then
            check pass "${doc} states it, so the anchor cannot drift off that file"
        else
            check fail "${doc} does not state '${phrase}'; the anchor points at nothing"
        fi
    done <<EOF
$rows
EOF

    local fx="${SELFTEST_DIR}/decision-autonomy"
    local work="${SELFTEST_DIR}/decision-autonomy-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out base before after complaints
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped decision autonomy contract satisfies the fast gate"

    # Each row is copied, mutated, and restored inside its own iteration, so four rows
    # targeting AI/WORKFLOW.md cannot skew one another.
    while IFS='|' read -r doc phrase; do
        [ -n "${doc:-}" ] || continue
        base="${work}/mutating.base"
        cp "${fx}/${doc}" "$base"
        before="$(wc -l < "$base" | tr -d ' ')"
        grep -vF -- "$phrase" "$base" > "${fx}/${doc}"
        after="$(wc -l < "${fx}/${doc}" | tr -d ' ')"

        # The anchor sat on its own line, and nothing else left the file with it.
        expect_same "$((before - after))" "1" \
            "dropping '${phrase}' removed exactly one line of ${doc}"

        rc="$(run_capture "${work}/dropped.txt" "${fx}/Scripts/verify-template.sh")"
        out="$(cat "${work}/dropped.txt")"
        expect_exit 65 "$rc" "a template that dropped '${phrase}' is refused"
        expect_contains "$out" "does not state the decision autonomy rule: ${phrase}" \
            "the refusal names that rule rather than the family"

        # Exactly one rule complained, so this mutation proved this anchor and no other.
        complaints="$(grep -cF 'does not state the decision autonomy rule' \
            "${work}/dropped.txt" || true)"
        expect_same "${complaints:-0}" "1" \
            "only '${phrase}' complained, so no neighbouring anchor was collateral"

        cp "$base" "${fx}/${doc}"
    done <<EOF
$rows
EOF

    # Every mutation above restored something; assert that rather than assume it.
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# Localization is the only workflow here that runs in parallel, and every way it can
# go wrong is a way a language gets lost. Two of those ways are silent: a locale
# session that edits main or another language's worktree, and a fan-in that settles a
# shared-file conflict by taking one whole side — which deletes whichever language was
# on the other. Neither is observable by any gate; both are prevented only by the
# prompts stating the rule, which is exactly the kind of prose that drifts back.
#
# So this case asserts the same two things the review-request and legal-and-support
# contracts assert: that the documents STATE the rules, and that the guards FIRE. It
# adds no new guard of its own. The three prompts are REQUIRED_FILES, so their absence
# is already refused; they are under AI/prompts/, so the universal preflight already
# covers them; and the byte-compared generation table already refuses localization
# being promoted to a second generated final milestone. What is proved below is that those
# existing mechanisms reach the new files.
case_localization_workflow_contract() {
    local corpus
    corpus="$(cat "${IOSAI_ROOT}/AI/WORKFLOW.md" "${IOSAI_ROOT}/AI/DESIGN.md" \
        "${IOSAI_ROOT}/AI/prompts/initialize-product.md" \
        "${IOSAI_ROOT}/AI/prompts/add-localization-worktree.md" \
        "${IOSAI_ROOT}/AI/prompts/integrate-localization-worktrees.md" \
        "${IOSAI_ROOT}/AI/prompts/polish-localizations.md" | tr '\n' ' ' | tr -s ' ')"

    # A scan that found nothing must never read as a clean result.
    if [ ${#corpus} -lt 6000 ]; then
        check fail "the localization corpus is implausibly small (${#corpus} bytes); the scan did not run"
        return 0
    fi
    check pass "the localization corpus was collected (${#corpus} bytes)"

    # The precondition and the two isolation rules, each by the shortest phrase that
    # cannot survive the rule being dropped. Flattened above for the same reason
    # case_documentation_consistency flattens: an anchor that wrapped at 80 columns
    # would be searched for and never found.
    # The milestone sequence is single-language on purpose: which languages are worth
    # adding is not knowable until the finished product has been used, so it is
    # decided after the device review rather than planned into the milestone graph.
    # That is why nothing routes to these prompts and the developer sends them.
    expect_contains "$corpus" 'The milestone plan ships one language, English' \
        "initialization plans no translation milestone"
    expect_contains "$corpus" 'The milestones build, audit, and verify one language, English' \
        "the design contract records that the milestones are English-only"
    expect_contains "$corpus" 'reaches `READY_FOR_HUMAN`' \
        "a language is added only after the English candidate is ready"
    expect_contains "$corpus" 'the three prompts below are sent explicitly' \
        "nothing routes automatically to the localization prompts"
    expect_contains "$corpus" 'it begins only after' \
        "localization starts after the milestones, never during them"
    expect_contains "$corpus" 'reopens, invalidates, or re-verifies none of them' \
        "adding a language leaves completed milestones alone"
    expect_contains "$corpus" 'never edits the main checkout or another language' \
        "a locale session owns its worktree and nothing else"
    expect_contains "$corpus" 'taking one whole side is wrong by construction' \
        "the fan-in states why one side of a shared-file conflict is never taken"
    expect_contains "$corpus" 'wholesale is forbidden there' \
        "the fan-in forbids resolving a multi-language conflict by preferring a side"
    expect_contains "$corpus" 'A complete key set is not a finished localization' \
        "a translated key is not evidence that the language is done"
    expect_contains "$corpus" 'does not replace the pass each language already made' \
        "the cross-language pass is additional, not a substitute"

    # The lowercase-locale rule used to be prose asking a human to remember it, which
    # is how two names for one branch appear on a filesystem that cannot tell them
    # apart. It is now the tool's refusal, and the documents name the invocation.
    expect_contains "$corpus" './Scripts/create-worktree.sh de' \
        "the documents name the exact invocation that creates a language's worktree"
    expect_contains "$corpus" 'refuses an uppercase locale' \
        "the lowercase rule is enforced by the tool, not only asked of a human"

    local fx="${SELFTEST_DIR}/localization-workflow"
    local work="${SELFTEST_DIR}/localization-workflow-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out prompt
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped localization prompts satisfy the fast gate"

    # ---- The prompts are required files -------------------------------------
    for prompt in add-localization-worktree integrate-localization-worktrees \
                  polish-localizations; do
        cp "${fx}/AI/prompts/${prompt}.md" "${work}/${prompt}.base"
        rm -f "${fx}/AI/prompts/${prompt}.md"
        rc="$(run_capture "${work}/missing-${prompt}.txt" "${fx}/Scripts/verify-template.sh")"
        out="$(cat "${work}/missing-${prompt}.txt")"
        expect_exit 65 "$rc" "a template missing ${prompt}.md is refused"
        expect_contains "$out" "AI/prompts/${prompt}.md" "the refusal names the missing prompt"
        cp "${work}/${prompt}.base" "${fx}/AI/prompts/${prompt}.md"
    done

    # ---- They inherit the universal preflight, rather than needing their own --
    local locale_prompt="${fx}/AI/prompts/add-localization-worktree.md"
    local locale_base="${work}/add-localization-worktree.base"
    cp "$locale_prompt" "$locale_base"

    grep -vF '2. Read `AGENTS.md`.' "$locale_base" > "$locale_prompt"
    rc="$(run_capture "${work}/preflight.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/preflight.txt")"
    expect_exit 65 "$rc" "a localization prompt that stopped reconstructing session state is refused"
    expect_contains "$out" 'preflight item 2 should reference' \
        "the existing preflight guard is what reaches the new prompts"
    cp "$locale_base" "$locale_prompt"

    # ---- Localization is not a second generated final milestone -------------
    # Same shape as the review-request and legal-and-support cases: writing it into
    # the generation table's `<title> -> <prompt>` form is refused by the existing
    # byte-for-byte fixture, not by a rule added for localization.
    local gen="${fx}/AI/prompts/initialize-product.md"
    local gen_base="${work}/initialize-product.base"
    cp "$gen" "$gen_base"

    printf '\nFinal Localization -> AI/prompts/add-localization-worktree.md\n' >> "$gen"
    rc="$(run_capture "${work}/eighth.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/eighth.txt")"
    expect_exit 65 "$rc" "promoting localization to a second generated final milestone is refused"
    expect_contains "$out" 'does not state the one final milestone' \
        "the existing generation contract is what catches it"
    cp "$gen_base" "$gen"

    # ---- Everything restored ------------------------------------------------
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "every fixture mutation was restored"
}


# App Store listing production is not this template's work, and used to be. A
# localization session was told to translate "App Store metadata kept in this
# repository", so it invented a file to hold it — AI/STORE_TEXT.md, then one per
# language — and the release schema backed the instruction up with rows a person had
# to answer about screenshots, keywords, and What's New before the gate was satisfied.
# The template carries the application to READY_FOR_HUMAN; the listing is a separate
# App Store Connect workflow that starts after it.
#
# This case is deliberately two-sided. Half of it asserts the obligation is gone from
# every document that carried it. The other half asserts what must NOT have gone with
# it: the content audit still reads in-app copy, and the release audit still reads
# StoreKit, privacy, entitlements, and build identity. A boundary enforced by deleting
# the neighbouring coverage would pass a one-sided test and ship a worse template.
case_store_listing_out_of_scope() {
    local prompts="${IOSAI_ROOT}/AI/prompts"
    local doc phrase

    # Documents that must be silent about the listing altogether: the generator, the
    # milestone shape it generates from, and the four audits that never had a reason
    # to mention it. Bare 'App Store' is deliberately NOT in this set — it has
    # legitimate uses, and a test that grepped for it would fail on the sentence
    # saying the developer alone decides whether to submit.
    local silent_docs="AI/prompts/initialize-product.md
AI/templates/milestone-template.md
AI/prompts/audit-functional.md
AI/prompts/audit-ui-ux.md
AI/prompts/audit-accessibility.md
AI/prompts/audit-product.md"
    local listing_vocabulary="STORE_TEXT
App Store metadata
store metadata
store materials
Store materials
store-metadata
store-text
subtitle
keywords
promotional text
What's New
screenshot caption"

    while IFS= read -r doc; do
        [ -n "$doc" ] || continue
        local body
        body="$(cat "${IOSAI_ROOT}/${doc}" 2>/dev/null || true)"
        # A scan that found nothing must never read as a clean result.
        if [ ${#body} -lt 400 ]; then
            check fail "${doc} is implausibly small (${#body} bytes); the scan did not run"
            continue
        fi
        while IFS= read -r phrase; do
            [ -n "$phrase" ] || continue
            expect_absent "$body" "$phrase" "${doc} does not assign '${phrase}'"
        done <<VOCABULARY
$listing_vocabulary
VOCABULARY
    done <<SILENT
$silent_docs
SILENT

    # Initialization still generates the product it always did, so the silence above
    # is a removed obligation and not a truncated prompt.
    local generator
    generator="$(cat "${prompts}/initialize-product.md")"
    expect_contains "$generator" 'AI/PRODUCT.md' "initialization still writes the product contract"
    expect_contains "$generator" 'Final Product Polish -> AI/prompts/final-polish.md' \
        "initialization generates the single consolidated final milestone"

    # The two audits that DO touch the boundary state it, rather than staying quiet
    # and leaving the next session to guess. Both must also have lost the specific
    # assignments that made listing production their job.
    local content release
    content="$(cat "${prompts}/audit-content.md")"
    release="$(cat "${prompts}/audit-release.md")"

    for phrase in 'Store materials:' 'store-metadata' 'store-text' 'store metadata agrees'; do
        expect_absent "$content" "$phrase" "the content audit does not assign '${phrase}'"
        expect_absent "$release" "$phrase" "the release audit does not assign '${phrase}'"
    done
    expect_contains "$content" 'App Store Connect by a separate workflow' \
        "the content audit says who owns the listing instead"
    expect_contains "$release" 'The App Store listing is out of scope' \
        "the release audit says the listing is out of scope"
    expect_contains "$release" 'not P0, not P1, not P2' \
        "a missing listing is not a finding at any severity"

    # What the content audit must still cover: the copy inside the application.
    for phrase in 'Onboarding' 'empty states' 'errors' 'permission explanations' \
                  'Paywall copy' 'localization'; do
        expect_contains "$content" "$phrase" "the content audit still covers ${phrase}"
    done

    # What the release audit must still cover: the correctness of the shipped app.
    for phrase in 'StoreKit' 'entitlements' 'Privacy: the manifest' 'Bundle identifier' \
                  'marketing version' 'Permissions' 'debug flag'; do
        expect_contains "$release" "$phrase" "the release audit still covers ${phrase}"
    done

    # The release schema is where the obligation was enforced, so it is where the
    # absence has to be proved. The four retired IDs are gone, and no surviving row
    # description asks for listing copy under a different number.
    local schema
    schema="$(cat "${IOSAI_ROOT}/Config/release-requirements.v3.tsv")"
    if [ ${#schema} -lt 3000 ]; then
        check fail "the release schema is implausibly small (${#schema} bytes); the scan did not run"
        return 0
    fi
    check pass "the release schema was collected (${#schema} bytes)"

    for phrase in REL-1001 REL-1002 REL-1003 REL-1006; do
        expect_absent "$schema" "$phrase" "the release schema retired the listing row ${phrase}"
    done
    for phrase in 'Screenshots' 'screenshots' 'subtitle' 'keywords' "What's New" 'promotional'; do
        expect_absent "$schema" "$phrase" "no release requirement asks for '${phrase}'"
    done

    # And the release correctness rows the boundary must not have taken with it.
    for phrase in 'REL-503' 'REL-1004' 'REL-506' 'REL-1008' 'REL-502' 'REL-1005' 'REL-1007'; do
        expect_contains "$schema" "$phrase" "the release schema keeps ${phrase}"
    done
}


# The strict gates verify from a detached worktree whose whole tree is made
# read-only for the duration. Cleanup used to be a straight line between the
# `chmod -R a-w` and the removal, so any interrupt in that window — Ctrl-C, a
# closed terminal, a timeout — left a mode-0555 worktree registered in the
# repository forever. `git worktree list` reported it as real and cleanup failed.
case_candidate_worktree_cleanup() {
    local fx="${SELFTEST_DIR}/candidate-cleanup"
    local work="${SELFTEST_DIR}/candidate-cleanup-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    # A stub self-test that parks inside the read-only window and publishes its
    # own PID, so the interrupt lands deterministically where the leak occurred
    # rather than depending on timing.
    local pidfile="${work}/inner.pid"
    cat > "${fx}/Scripts/self-test.sh" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$$" > "${IOSAI_CLEANUP_PIDFILE:?}"
sleep 120
EOS
    chmod +x "${fx}/Scripts/self-test.sh"
    fixture_commit_unchecked "$fx" "park the gate inside the read-only window"

    # Invoke the gate itself in the background. Backgrounding the
    # fixture_integration shell function made $! identify a wrapper subshell, so
    # waiting for it did not necessarily wait for verify-integration.sh's EXIT trap
    # to remove the candidate. The assertions then raced the cleanup they were meant
    # to prove. The real gate process owns both the trap and the PID we wait on.
    local candidate
    candidate="$(fixture_candidate "$fx")"
    IOSAI_CLEANUP_PIDFILE="$pidfile" \
        "${fx}/Scripts/verify-integration.sh" --candidate "$candidate" \
        >"${work}/gate.txt" 2>&1 &
    local outer=$!

    local waited=0 snapshot=""
    while [ "$waited" -lt 120 ]; do
        if [ -s "$pidfile" ]; then
            snapshot="$(git -C "$fx" worktree list --porcelain \
                | awk '/^worktree /{p=substr($0,10)} /^detached/{print p}' | head -n1)"
            [ -n "$snapshot" ] && break
        fi
        kill -0 "$outer" 2>/dev/null || break
        sleep 1
        waited=$((waited + 1))
    done

    if [ -z "$snapshot" ]; then
        check fail "the gate never reached the read-only candidate window (nothing to interrupt)"
        kill -TERM "$outer" 2>/dev/null || true
        wait "$outer" 2>/dev/null || true
        return 0
    fi
    check pass "the gate materialised a candidate worktree at ${snapshot##*/T/}"
    if [ -w "$snapshot" ]; then
        check fail "the candidate snapshot was writable during the run"
    else
        check pass "the candidate snapshot is read-only during the run"
    fi

    # Interrupt the way a terminal does: the whole foreground group dies. Bash
    # only runs a trap between commands, so the inner child has to go first or
    # the parent would sit in `wait` and the trap would never be reached.
    kill -TERM "$outer" 2>/dev/null || true
    kill -TERM "$(cat "$pidfile")" 2>/dev/null || true
    wait "$outer" 2>/dev/null || true

    local still
    still="$(git -C "$fx" worktree list --porcelain | grep -c '^worktree ' || true)"
    expect_same "1" "${still:-0}" "an interrupted gate leaves no registered candidate worktree"
    if [ -e "$snapshot" ]; then
        check fail "the candidate directory survived the interrupt: ${snapshot}"
    else
        check pass "the candidate directory was removed"
    fi
    if [ -e "$(dirname -- "$snapshot")" ]; then
        check fail "the candidate's temporary parent survived the interrupt"
    else
        check pass "the candidate's temporary parent was removed"
    fi
    if [ -n "$(git -C "$fx" worktree list --porcelain | awk '/^prunable/{print}')" ]; then
        check fail "a prunable worktree registration was left behind"
    else
        check pass "no prunable worktree registration was left behind"
    fi

    # The repository must be immediately usable again, with no manual repair.
    local rc
    rc="$(run_capture "${work}/after.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the repository is usable again straight after the interrupt"
}

case_optional_hooks() {
    local fx="${SELFTEST_DIR}/optional-hooks"
    local work="${SELFTEST_DIR}/optional-hooks-work"
    local wt="${SELFTEST_DIR}/optional-hooks-worktree"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local rc out
    expect_same "" "$(git -C "$fx" config --get core.hooksPath 2>/dev/null || true)" \
        "fixtures start with no configured hooks"
    rc="$(run_capture "${work}/setup.txt" make -C "$fx" setup)"
    expect_exit 0 "$rc" "make setup validates without installing hooks"
    expect_same "" "$(git -C "$fx" config --get core.hooksPath 2>/dev/null || true)" \
        "make setup leaves core.hooksPath unset"

    rc="$(run_capture "${work}/install.txt" "${fx}/Scripts/install-git-hooks.sh")"
    expect_exit 0 "$rc" "optional pre-commit installation succeeds"
    expect_same ".githooks" "$(git -C "$fx" config --get core.hooksPath)" \
        "installer configures only the versioned optional hook path"
    [ -x "${fx}/.githooks/pre-commit" ] && check pass "optional pre-commit hook exists" \
        || check fail "optional pre-commit hook is missing"
    [ ! -e "${fx}/.githooks/pre-push" ] && check pass "no pre-push hook exists" \
        || check fail "a pre-push hook remains"
    [ ! -e "${fx}/Scripts/verify-push.sh" ] && check pass "obsolete push verifier is absent" \
        || check fail "obsolete push verifier remains"

    printf '<<<<<<< HEAD\n' > "${fx}/App/StaticFailure.swift"
    rc="$(run_capture "${work}/commit.txt" git -C "$fx" commit --allow-empty -m 'hook static failure')"
    out="$(cat "${work}/commit.txt")"
    if [ "$rc" = "0" ]; then
        check fail "optional pre-commit allowed a static failure"
    else
        check pass "optional pre-commit blocks a static failure (exit ${rc})"
    fi
    expect_contains "$out" "Static verification" "the hook ran the non-simulator static gate"
    rm -f "${fx}/App/StaticFailure.swift"

    git -C "$fx" worktree add -q -b hook-inheritance "$wt"
    expect_same ".githooks" "$(git -C "$wt" config --get core.hooksPath)" \
        "optional hook configuration is inherited across worktrees"

    rc="$(run_capture "${work}/uninstall.txt" "${fx}/Scripts/install-git-hooks.sh" --uninstall)"
    expect_exit 0 "$rc" "safe optional-hook uninstall succeeds"
    expect_same "" "$(git -C "$fx" config --get core.hooksPath 2>/dev/null || true)" \
        "uninstall removes the template hook path"

    git -C "$fx" config core.hooksPath custom-hooks
    rc="$(run_capture "${work}/custom.txt" "${fx}/Scripts/install-git-hooks.sh" --uninstall)"
    expect_exit 0 "$rc" "uninstall safely ignores a custom hook path"
    expect_same "custom-hooks" "$(git -C "$fx" config --get core.hooksPath)" \
        "custom hook path remains unchanged"
}

case_worktree_targets() {
    local fx="${SELFTEST_DIR}/worktree"
    local work="${SELFTEST_DIR}/worktree-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"

    local t rc out
    # Regex-shaped and malformed targets: user input never reaches a regular
    # expression, so none of these may resolve to a worktree the caller did not name.
    for t in '.' '.*' 'M[0-9]*' '^M00$' 'de-' '-de' 'pt--br' 'DE'; do
        rc="$(run_capture "${work}/out.txt" "${fx}/Scripts/remove-worktree.sh" "$t")"
        expect_exit 64 "$rc" "a non-locale target is refused: ${t}"
    done

    # The create side takes no path, so its grammar must reject every shape that
    # would reach `git worktree add -b` as something other than one locale. A branch
    # named localization/de/x, or one carrying a ref metacharacter, is refused before
    # git is asked to interpret it.
    for t in 'de/x' 'de..x' 'de.lock' 'de x' 'de@{1}' 'e' ''; do
        rc="$(run_capture "${work}/bad-locale.txt" "${fx}/Scripts/create-worktree.sh" "$t")"
        expect_exit 64 "$rc" "create-worktree.sh refuses a non-locale argument: '${t}'"
    done

    # The retired concept names itself rather than being reported as a bad locale.
    # Advising a caller who typed M03 to try 'm03' would be nonsense: their problem
    # is that per-milestone worktrees no longer exist.
    rc="$(run_capture "${work}/milestone.txt" "${fx}/Scripts/remove-worktree.sh" M03)"
    expect_exit 64 "$rc" "a milestone ID is no longer a worktree target"
    expect_contains "$(cat "${work}/milestone.txt")" "milestone worktrees no longer exist" \
        "the refusal names the policy rather than the grammar"
    rc="$(run_capture "${work}/create-milestone.txt" "${fx}/Scripts/create-worktree.sh" M03)"
    expect_exit 64 "$rc" "create-worktree.sh no longer takes a milestone ID"
    expect_contains "$(cat "${work}/create-milestone.txt")" "milestone worktrees no longer exist" \
        "the create refusal names the policy too"

    # A valid locale with no matching worktree is a missing input, not a match.
    rc="$(run_capture "${work}/valid.txt" "${fx}/Scripts/remove-worktree.sh" ja)"
    expect_exit 66 "$rc" "a valid locale with no worktree reports nothing to remove"

    # Uppercase is refused before a branch exists, with the form to use named. Git
    # refs are files, and a macOS filesystem usually cannot tell pt-BR from pt-br —
    # so accepting both spellings would mean two names for one branch.
    rc="$(run_capture "${work}/upper.txt" "${fx}/Scripts/create-worktree.sh" pt-BR)"
    expect_exit 64 "$rc" "an uppercase locale is refused"
    out="$(cat "${work}/upper.txt")"
    expect_contains "$out" "pt-br" "the refusal names the lowercase form to use"
    if [ ! -e "${SELFTEST_DIR}/worktree-pt-BR" ] && [ ! -e "${SELFTEST_DIR}/worktree-pt-br" ]; then
        check pass "the refused locale created nothing"
    else
        check fail "a refused locale left a directory behind"
    fi

    # A real worktree, its branch, and a --delete-branch that must be refused loudly.
    rc="$(run_capture "${work}/create.txt" "${fx}/Scripts/create-worktree.sh" de)"
    expect_exit 0 "$rc" "a lowercase locale creates its worktree"
    local wt="${SELFTEST_DIR}/$(basename -- "$fx")-de"
    if [ -d "$wt" ]; then
        check pass "create-worktree.sh made ${wt##*/}"
        expect_same "localization/de" "$(git -C "$wt" rev-parse --abbrev-ref HEAD)" \
            "the worktree is on the conventional branch"

        # Never reuses, never overwrites, never forces.
        rc="$(run_capture "${work}/again.txt" "${fx}/Scripts/create-worktree.sh" de)"
        expect_exit 65 "$rc" "an existing locale branch is never reused or overwritten"

        # `br` must not resolve `-pt-br`: a locale resolves through its branch, not
        # through a path suffix, or removing one language could remove another.
        "${fx}/Scripts/create-worktree.sh" pt-br >/dev/null 2>&1
        rc="$(run_capture "${work}/suffix.txt" "${fx}/Scripts/remove-worktree.sh" br)"
        expect_exit 66 "$rc" "a locale that is only a suffix of another resolves to nothing"

        # A worktree whose state cannot be read is not called clean. `git status ||
        # true` used to read an unreadable index as "no changes" and print "the
        # worktree is clean"; only Git's own refusal saved the uncommitted file.
        local ptwt="${SELFTEST_DIR}/$(basename -- "$fx")-pt-br" ptindex
        if [ -d "$ptwt" ]; then
            printf 'uncommitted translation\n' > "${ptwt}/App/Uncommitted.swift"
            ptindex="$(git -C "$ptwt" rev-parse --absolute-git-dir)/index"
            chmod 000 "$ptindex"
            rc="$(run_capture "${work}/unreadable.txt" "${fx}/Scripts/remove-worktree.sh" pt-br)"
            chmod 644 "$ptindex"
            out="$(cat "${work}/unreadable.txt")"
            expect_exit 65 "$rc" "a worktree whose state cannot be read is not removed"
            expect_contains "$out" "refusing to assume it is clean" \
                "the refusal says the state could not be read"
            expect_absent "$out" "the worktree is clean" "no cleanliness is claimed that was never checked"
            [ -f "${ptwt}/App/Uncommitted.swift" ] \
                && check pass "the uncommitted file survived the refusal" \
                || check fail "the uncommitted file was lost"
            rm -f "${ptwt}/App/Uncommitted.swift"
            rc="$(run_capture "${work}/clean-remove.txt" "${fx}/Scripts/remove-worktree.sh" pt-br)"
            expect_exit 0 "$rc" "a clean worktree with no upstream is removed"
            [ ! -e "$ptwt" ] && check pass "the removed worktree's directory is gone" \
                || check fail "the removed worktree's directory remains"
            expect_same "localization/pt-br" \
                "$(git -C "$fx" for-each-ref --format='%(refname:short)' refs/heads/localization/pt-br)" \
                "removing the worktree keeps its branch"
        else
            check fail "the pt-br worktree was not created; the fail-closed checks cannot run"
        fi

        printf 'let extra = 1\n' > "${wt}/App/Extra.swift"
        fixture_commit_unchecked "$wt" "unmerged work"
        rc="$(run_capture "${work}/del.txt" "${fx}/Scripts/remove-worktree.sh" de --delete-branch)"
        expect_exit 65 "$rc" "a refused --delete-branch exits non-zero"
        expect_contains "$(cat "${work}/del.txt")" "not merged" "the refusal says why"
    else
        check fail "create-worktree.sh did not create the worktree: $(cat "${work}/create.txt")"
    fi
}

case_app_target_identity() {
    local fx="${SELFTEST_DIR}/app-target"
    local work="${SELFTEST_DIR}/app-target-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local settings="${work}/settings"
    mkdir -p "$settings"

    # No application target at all.
    cat > "${settings}/none.json" <<'JSON'
[{"target":"FixtureTests","buildSettings":{"PRODUCT_TYPE":"com.apple.product-type.bundle.unit-test","MARKETING_VERSION":"1.0.0","CURRENT_PROJECT_VERSION":"1"}}]
JSON
    # Two application targets, agreeing on the value: ambiguous identity.
    cat > "${settings}/two.json" <<'JSON'
[{"target":"A","buildSettings":{"PRODUCT_TYPE":"com.apple.product-type.application","MARKETING_VERSION":"1.0.0","CURRENT_PROJECT_VERSION":"1"}},
 {"target":"B","buildSettings":{"PRODUCT_TYPE":"com.apple.product-type.application","MARKETING_VERSION":"1.0.0","CURRENT_PROJECT_VERSION":"1"}}]
JSON
    # An extension named exactly like the configured APP_TARGET.
    cat > "${settings}/extension.json" <<'JSON'
[{"target":"Fixture","buildSettings":{"PRODUCT_TYPE":"com.apple.product-type.app-extension","MARKETING_VERSION":"7.7.7","CURRENT_PROJECT_VERSION":"77"}}]
JSON

    local name rc out
    for name in none two extension; do
        rc="$(PATH="${STUB_BIN}:$PATH" STUB_SETTINGS_JSON="${settings}/${name}.json" \
            run_capture "${work}/${name}.txt" fixture_release "$fx")"
        out="$(cat "${work}/${name}.txt")"
        expect_exit 1 "$rc" "release refuses to guess identity: ${name}"
        expect_contains "$out" "VERDICT=VERIFICATION_FAILED" "verdict stated for ${name}"
    done

    # The fixture's own settings resolve to exactly one application target.
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/one.txt" \
        fixture_release "$fx" --print-candidate)"
    out="$(cat "${work}/one.txt")"
    expect_exit 0 "$rc" "one application target resolves"
    expect_contains "$out" "MARKETING_VERSION=1.0.0" "the app target's version is used"
    expect_absent "$out" "9.9.9" "the test target's version is ignored"
}

case_distribution_channel() {
    local fx="${SELFTEST_DIR}/channel"
    local work="${SELFTEST_DIR}/channel-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"

    # Internal readiness uses the internal-only coverage rows.
    local rc out report body
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/internal.txt" fixture_release "$fx")"
    out="$(cat "${work}/internal.txt")"
    expect_exit 0 "$rc" "an internal candidate reaches distribution readiness"
    expect_contains "$out" 'VERDICT=READY_FOR_HUMAN' \
        "the internal candidate has the release success verdict"
    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_contains "$report" '**Distribution:** internal' \
        "the report binds readiness to the internal channel"
    body="$(cat "${fx}/AI/audits/M01-final-polish.md")"
    expect_absent "$body" "REL-1004" "an internal candidate is not asked for the App Store support URL"
    expect_contains "$body" "REL-1201" "an internal candidate is asked about its own channel"
    expect_contains "$body" "REL-1101" "channel-independent release coverage still applies"

    # App Store readiness uses the App Store-only coverage rows.
    sed -e 's|^DISTRIBUTION_CHANNEL=.*|DISTRIBUTION_CHANNEL="app-store"|' \
        "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
    mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
    fixture_commit_unchecked "$fx" "switch to App Store distribution"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/app-store.txt" fixture_release "$fx")"
    out="$(cat "${work}/app-store.txt")"
    expect_exit 0 "$rc" "an App Store candidate reaches distribution readiness"
    expect_contains "$out" 'VERDICT=READY_FOR_HUMAN' \
        "the App Store candidate has the release success verdict"
    report="$(cat "$(cat "${fx}/.artifacts/release/latest.txt")/report.md")"
    expect_contains "$report" '**Distribution:** app-store' \
        "the report binds readiness to the App Store channel"
    body="$(cat "${fx}/AI/audits/M01-final-polish.md")"
    expect_contains "$body" "REL-1004" "an App Store candidate must answer for its support URL"
    expect_absent "$body" "REL-1201" "internal-distribution items are not generated"

    # The listing rows are gone from the schema, so even the channel that used to be
    # asked for them is not: REL-1001 and REL-1002 were the screenshots, REL-1003 the
    # name, subtitle, description, and keywords, REL-1006 the What's New text. They
    # belong to App Store Connect, and no candidate of any channel waits on them.
    local retired_listing_row
    for retired_listing_row in REL-1001 REL-1002 REL-1003 REL-1006; do
        expect_absent "$body" "$retired_listing_row" \
            "an App Store candidate is not asked for the retired listing row ${retired_listing_row}"
    done

    expect_absent "$body" "REL-1104" "distribution operations are not application coverage"

    # The template has one local-to-distribution workflow. A hosted beta service
    # must not reappear in documentation, configuration guidance, or gate output
    # under a different sentence while the channel assertions above still pass.
    local retired_beta_service="Test""Flight"
    rc="$(run_capture "${work}/hosted-beta-scan.txt" \
        git -C "$IOSAI_ROOT" grep -I -i -n -e "$retired_beta_service" -- .)"
    case "$rc" in
        1) check pass "tracked template guidance contains no hosted beta suggestion" ;;
        0) check fail "tracked template guidance still names ${retired_beta_service}: $(cat "${work}/hosted-beta-scan.txt")" ;;
        *) check fail "the hosted beta guidance scan failed with exit ${rc}" ;;
    esac
}

case_cwd_independence() {
    local fx="${SELFTEST_DIR}/cwd"
    local work="${SELFTEST_DIR}/cwd-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local other="${SELFTEST_DIR}/unrelated repo"
    mkdir -p "$other"
    git -C "$other" init -q .
    git -C "$other" config user.email "selftest@example.invalid"
    git -C "$other" config user.name "Self Test"
    git -C "$other" commit -q --allow-empty -m "unrelated"

    local fx_head other_head rc out
    fx_head="$(git -C "$fx" rev-parse HEAD)"
    other_head="$(git -C "$other" rev-parse HEAD)"

    rc="$(cd "$other" && "${fx}/Scripts/install-git-hooks.sh" >"${work}/hooks.txt" 2>&1; printf '%s' "$?")"
    expect_exit 0 "$rc" "the hook installer runs from an unrelated repository"
    expect_same "" "$(git -C "$other" config --get core.hooksPath || true)" \
        "the caller's repository was not reconfigured"
    expect_same ".githooks" "$(git -C "$fx" config --get core.hooksPath)" \
        "the target repository was configured"

    rc="$(cd "$other" && PATH="${STUB_BIN}:$PATH" fixture_integration "$fx" >"${work}/integration.txt" 2>&1; printf '%s' "$?")"
    out="$(cat "${work}/integration.txt")"
    expect_exit 0 "$rc" "the integration gate runs from an unrelated repository"
    expect_contains "$out" "VERIFIED_COMMIT=${fx_head}" "it verified the target repository's HEAD"
    expect_absent "$out" "$other_head" "it did not report the caller's HEAD"

    # And from a parent directory, and from a path containing spaces.
    rc="$(cd "$(dirname -- "$fx")" && "${fx}/Scripts/project-status.sh" validate >/dev/null 2>&1; printf '%s' "$?")"
    expect_exit 0 "$rc" "project-status validates from a parent directory"

    # A repository path may contain an apostrophe as well as a space — both are
    # ordinary in a user directory name — and the optional linter is the one check
    # invoked through `sh -c`, so it is where a quoting mistake would land.
    #
    # This is a STANDING GUARD, not the reproduction of a fixed defect. An audit
    # reported the earlier spliced-interpolation form as broken on an apostrophe
    # path; tested, it was not — the apostrophe fell inside the double quotes of
    # the assembled script, where `sh` treats it literally. The finding was
    # withdrawn and the invocation was rewritten to pass the root positionally
    # because that is plainly easier to read, not because it fixed anything. This
    # case therefore passes against both forms, and its job is to keep any future
    # rewrite honest.
    #
    # The linter is STUBBED rather than skipped when absent. Without a stub this
    # case passes on any machine that has no shellcheck installed, because
    # run_optional_tool reports "enabled but not installed" long before the command
    # is ever assembled — so it would assert nothing about the invocation at all.
    local quoted="${SELFTEST_DIR}/Jane's toolbox"
    local qfx="${quoted}/quoted fixture"
    local qbin="${work}/quoted-bin"
    mkdir -p "$quoted" "$qbin"
    printf '#!/usr/bin/env bash\nfor a in "$@"; do case "$a" in -*) continue ;; esac\n  [ -f "$a" ] || { printf "stub shellcheck: not a file: %%s\\n" "$a"; exit 1; }\ndone\nexit 0\n' \
        > "${qbin}/shellcheck"
    chmod +x "${qbin}/shellcheck"
    fixture_product "$qfx" "${work}/quoted"
    sed 's|^ENABLE_SHELLCHECK=.*|ENABLE_SHELLCHECK="true"|' "${qfx}/Config/project.env" \
        > "${qfx}/Config/project.env.new"
    mv "${qfx}/Config/project.env.new" "${qfx}/Config/project.env"
    fixture_commit_unchecked "$qfx" "enable the optional shell linter"
    rc="$(PATH="${qbin}:$PATH" run_capture "${work}/quoted.txt" "${qfx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/quoted.txt")"
    expect_exit 0 "$rc" "static passes from a path containing an apostrophe and a space"
    expect_contains "$out" "shellcheck clean" "the linter actually ran against that path"
    expect_absent "$out" "not a file" "every operand reached the linter as one intact path"
    expect_absent "$out" "syntax error" "the invocation produces no shell syntax error"
    expect_absent "$out" "unexpected EOF" "the invocation leaves no unterminated quote"
}

# Which credential filenames get checked must not depend on what sits in the
# repository. The pattern list is full of globs and the scan runs from the
# repository root, so an unquoted `for p in $LIST` pathname-expanded it: a
# directory named Secrets.playground/ consumed the Secrets.* pattern and
# App/Secrets.plist was never looked for, while the gate reported no credential
# files and passed.
case_secret_pattern_isolation() {
    local fx="${SELFTEST_DIR}/secret-globs"
    local work="${SELFTEST_DIR}/secret-globs-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc out

    printf '<?xml version="1.0"?>\n<plist version="1.0"><dict/></plist>\n' \
        > "${fx}/App/Secrets.plist"
    rc="$(run_capture "${work}/control.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/control.txt")"
    expect_exit 65 "$rc" "a credential-named file fails static verification"
    expect_contains "$out" "App/Secrets.plist" "the credential file is named"

    # The decoys: repository-root entries that match the very patterns the scan
    # iterates. Each one used to disable its own pattern for that iteration.
    mkdir -p "${fx}/Secrets.playground" "${fx}/credentials.bundle" "${fx}/secrets.d"
    printf 'let decoy = 1\n' > "${fx}/Secrets.playground/Contents.swift"
    rc="$(run_capture "${work}/decoys.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/decoys.txt")"
    expect_exit 65 "$rc" "root decoys matching the pattern list do not disable the scan"
    expect_contains "$out" "App/Secrets.plist" "the credential file is still named"
    expect_absent "$out" "no credential or signing files" \
        "the scan does not report a clean result while the file is present"

    # The failure hint may not claim ignore coverage the repository does not have.
    expect_contains "$out" "may contain credential or signing material" \
        "the hint states what was actually found"
    expect_absent "$out" "already excludes these names" \
        "the hint claims no .gitignore coverage it cannot guarantee"
    rm -rf "${fx}/Secrets.playground" "${fx}/credentials.bundle" "${fx}/secrets.d"
    rm -f "${fx}/App/Secrets.plist"

    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the same fixture passes once the credential file is gone"
}

# A Git query whose status is discarded reports an empty answer, and an empty
# answer used to read as "clean". milestone_checkout_is_clean is always the left
# operand of an `||` list, so `set -e` is inactive for its body: an unreadable
# index made a dirty tree earn a PASSED verdict and a VERIFIED_COMMIT.
case_git_state_failure_closed() {
    local fx="${SELFTEST_DIR}/git-state"
    local work="${SELFTEST_DIR}/git-state-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out mode

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/clean.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "a clean checkout still verifies normally"

    printf '// dirty\n' >> "${fx}/App/Fixture/Fixture.swift"
    mode="$(stat -f '%Lp' "${fx}/.git/index")"
    chmod 000 "${fx}/.git/index"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/unreadable.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    # Restored before any assertion, so a failing check cannot leave the fixture
    # undeletable for the suite's cleanup.
    chmod "$mode" "${fx}/.git/index"
    out="$(cat "${work}/unreadable.txt")"
    expect_exit 65 "$rc" "an unreadable index blocks milestone verification"
    expect_contains "$out" "could not read the working tree state" \
        "the gate says it could not determine cleanliness"
    expect_absent "$out" "VERIFIED_COMMIT" "no commit is marked verified"
    expect_absent "$out" "PASSED milestone verification" "no PASSED verdict is claimed"
    git -C "$fx" checkout -q -- App/Fixture/Fixture.swift

    # The boundary of the ignored-input scan, asserted in both directions, because
    # the interesting property is not that it refuses but what it refuses.
    #
    # Finder drops .DS_Store into any directory somebody opens — including the ones
    # scanned here — and it holds window geometry, not build input. A gate that
    # refused to verify because a folder had been looked at in Finder produced a
    # failure the developer learned to dismiss, and the next dismissal is the real
    # ignored source file.
    printf 'Finder window state, not a build input\n' > "${fx}/AI/.DS_Store"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/dsstore.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "an ignored .DS_Store under a scanned directory still verifies"
    rm -f "${fx}/AI/.DS_Store"

    # And the half that matters: the tolerance is one filename, not a category. An
    # ignored Swift file under App/ is exactly the byte this scan exists to catch,
    # and it still refuses while a .DS_Store sits beside it.
    printf 'App/LocalOnly.swift\n' >> "${fx}/.gitignore"
    git -C "$fx" add .gitignore
    git -C "$fx" -c user.name=selftest -c user.email=selftest@example.com \
        commit -q -m 'ignore a local-only source file'
    printf 'let localOnly = 1\n' > "${fx}/App/LocalOnly.swift"
    printf 'Finder window state, not a build input\n' > "${fx}/AI/.DS_Store"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ignored-source.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/ignored-source.txt")"
    expect_exit 65 "$rc" "an ignored source file under App/ still blocks verification"
    expect_contains "$out" "could affect verification" "the refusal names the reason"
    expect_contains "$out" "App/LocalOnly.swift" "the refusal names the file it found"
    expect_absent "$out" ".DS_Store" "the tolerated file is not listed as a build input"
    rm -f "${fx}/App/LocalOnly.swift" "${fx}/AI/.DS_Store"
}

# Xcode writes per-user state into every project a developer opens — window layout,
# scheme-list order, breakpoints — and M00 begins by opening one. The milestone gate
# refused all of it as ignored build input, which failed the documented clean-HEAD
# command for every developer who used Xcode: before the build, or, with Xcode open,
# at the closing recheck after a whole build and test run. An audit reproduced both
# against real Xcode, and two products built on this workflow had worked around it on
# nearly every milestone. Asserted in both directions, like .DS_Store above: what Xcode
# writes by itself is not an input, and what can change a build still is.
case_xcode_user_state() {
    local fx="${SELFTEST_DIR}/xcode-user-state"
    local work="${SELFTEST_DIR}/xcode-user-state-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out latest report
    local proj="${fx}/App/Fixture.xcodeproj"
    local user_dir="${proj}/xcuserdata/fixture.xcuserdatad"
    local ws_dir="${proj}/project.xcworkspace/xcuserdata/fixture.xcuserdatad"

    # 1. Everything Xcode writes on its own, present before the run.
    mkdir -p "${user_dir}/xcschemes" "${user_dir}/xcdebugger" "${ws_dir}/xcdebugger"
    printf 'window layout\n' > "${ws_dir}/UserInterfaceState.xcuserstate"
    printf 'scheme order\n' > "${user_dir}/xcschemes/xcschememanagement.plist"
    printf 'breakpoints\n' > "${user_dir}/xcdebugger/Breakpoints_v2.xcbkptlist"
    printf 'watch expressions\n' > "${ws_dir}/xcdebugger/Expressions.xcexplist"
    # The Find navigator's saved scopes. An audit found Xcode had written this one
    # into a real project's workspace xcuserdata, and the gate refused it as a build
    # input although xcodebuild never reads it.
    printf 'find scopes\n' > "${ws_dir}/IDEFindNavigatorScopes.plist"
    expect_same "" "$(git -C "$fx" status --porcelain --untracked-files=all)" \
        "Xcode's per-user state is ignored, so the tracked tree stays clean"
    # The control: the scan the gate runs really does see all five files, so the
    # pass below is the tolerance working and not the files being invisible.
    expect_same "5" \
        "$(git -C "$fx" ls-files --others --ignored --exclude-standard -- App | wc -l | tr -d ' ')" \
        "the gate's ignored-input scan sees every planted per-user file"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/present.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/present.txt")"
    expect_exit 0 "$rc" "Xcode's per-user state does not block clean-HEAD milestone verification"
    expect_contains "$out" "VERIFIED_COMMIT=" "the clean-HEAD run verifies the commit"
    expect_absent "$out" "could affect verification" "no per-user file is reported as a build input"

    # 2. A running Xcode rewrites its window state while the gate runs. The closing
    #    recheck is the one that used to fail, after the whole build and test run.
    rm -f "${ws_dir}/UserInterfaceState.xcuserstate"
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_MUTATE_FILE="${ws_dir}/UserInterfaceState.xcuserstate" \
        run_capture "${work}/midrun.txt" "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/midrun.txt")"
    if [ -f "${ws_dir}/UserInterfaceState.xcuserstate" ]; then
        check pass "the window state was rewritten while the gate ran"
    else
        check fail "the mid-run rewrite did not happen; the closing-recheck check proves nothing"
    fi
    expect_exit 0 "$rc" "a window-state rewrite during the run does not fail the closing recheck"
    expect_contains "$out" "VERIFIED_COMMIT=" "the run that saw the rewrite still verifies the commit"

    # 3. What can change a build still refuses, with the tolerated files beside it.
    printf '<Scheme/>\n' > "${user_dir}/xcschemes/Fixture.xcscheme"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/user-scheme.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/user-scheme.txt")"
    expect_exit 65 "$rc" "a user scheme still blocks verification"
    expect_contains "$out" "xcschemes/Fixture.xcscheme" "the refusal names the user scheme"
    expect_absent "$out" "xcschememanagement.plist" "the tolerated files are not listed beside it"
    expect_absent "$out" "IDEFindNavigatorScopes.plist" "the Find navigator's scopes are not listed beside it"
    expect_absent "$out" "VERIFIED_COMMIT" "no commit is verified beside a user scheme"
    rm -f "${user_dir}/xcschemes/Fixture.xcscheme"

    printf 'per-user settings\n' > "${ws_dir}/WorkspaceSettings.xcsettings"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/settings.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "per-user workspace settings still block verification"
    expect_contains "$(cat "${work}/settings.txt")" "WorkspaceSettings.xcsettings" \
        "the refusal names the workspace settings"
    rm -f "${ws_dir}/WorkspaceSettings.xcsettings"

    # The tolerance is a shape, not a filename: the same name outside
    # xcuserdata/<user>.xcuserdatad is an ordinary ignored input.
    printf 'stray\n' > "${fx}/App/UserInterfaceState.xcuserstate"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/stray.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "a state file outside xcuserdata/<user>.xcuserdatad still blocks"
    rm -f "${fx}/App/UserInterfaceState.xcuserstate"

    # 4. A closing recheck that does fail still leaves a verdict in the report. It used
    #    to die after the command list, and the report ended there.
    rc="$(PATH="${STUB_BIN}:$PATH" STUB_MUTATE_FILE="App/Fixture/Fixture.swift" \
        run_capture "${work}/tracked-midrun.txt" "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 65 "$rc" "a tracked source rewritten mid-run still fails the closing recheck"
    expect_contains "$(cat "${work}/tracked-midrun.txt")" "checkout changed during milestone verification" \
        "the refusal comes from the closing recheck"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" "**Verdict:** FAILED" "the failed run's report states a verdict"
    expect_absent "$report" "**VERIFIED_COMMIT:**" "the failed run's report claims no verified commit"
    git -C "$fx" checkout -q -- App/Fixture/Fixture.swift
}

# A scanner that could not read the tree used to be indistinguishable from a
# scanner that found nothing: every driver ended in `|| true`, so one unreadable
# directory produced an empty result set and a green gate.
case_scanner_failure_closed() {
    local fx="${SELFTEST_DIR}/scanner-failure"
    local work="${SELFTEST_DIR}/scanner-failure-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out mode token

    # Assembled at run time so this file is not itself a secret-shaped file.
    token="ghp_$(printf 'C%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36)"

    # 1. Secret content scan.
    mkdir -p "${fx}/AI/locked-notes"
    printf 'token: %s\n' "$token" > "${fx}/AI/locked-notes/leak.md"
    rc="$(run_capture "${work}/secret-control.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/secret-control.txt")"
    expect_exit 65 "$rc" "a planted token is detected while the tree is readable"
    expect_contains "$out" "github-token" "the token class is named"
    mode="$(stat -f '%Lp' "${fx}/AI/locked-notes")"
    chmod 000 "${fx}/AI/locked-notes"
    rc="$(run_capture "${work}/secret-locked.txt" "${fx}/Scripts/verify-static.sh")"
    chmod "$mode" "${fx}/AI/locked-notes"
    out="$(cat "${work}/secret-locked.txt")"
    expect_exit 65 "$rc" "an unreadable directory does not silence the credential scan"
    expect_contains "$out" "could not " "the gate reports that it could not scan"
    # The 65 and "could not" also come from other walkers that meet the same locked
    # directory first, so the credential scan's own verdict line is what proves it.
    expect_contains "$out" "embedded-credential scan incomplete" \
        "the credential content scan itself reports that it could not finish"
    expect_contains "$out" "credential filename scan incomplete" \
        "the credential filename scan itself reports that it could not finish"
    expect_absent "$out" "no embedded private keys" \
        "an inconclusive credential scan is never reported as clean"
    rm -rf "${fx}/AI/locked-notes"

    # 2. Placeholder scan over App/.
    mkdir -p "${fx}/App/Locked"
    printf 'let copy = "TBD"\n' > "${fx}/App/Locked/Draft.swift"
    mode="$(stat -f '%Lp' "${fx}/App/Locked")"
    chmod 000 "${fx}/App/Locked"
    rc="$(run_capture "${work}/placeholder-app.txt" "${fx}/Scripts/verify-static.sh")"
    chmod "$mode" "${fx}/App/Locked"
    out="$(cat "${work}/placeholder-app.txt")"
    expect_exit 65 "$rc" "an unreadable App/ subtree does not silence the placeholder scan"
    expect_contains "$out" "App/ placeholder scan incomplete" \
        "the App/ placeholder scan itself reports that it could not finish"
    expect_absent "$out" "no placeholders in App/ sources" \
        "an inconclusive placeholder scan is never reported as clean"
    rm -rf "${fx}/App/Locked"

    # 3. Placeholder count over AI/.
    mkdir -p "${fx}/AI/locked-docs"
    printf 'TBD\n' > "${fx}/AI/locked-docs/draft.md"
    mode="$(stat -f '%Lp' "${fx}/AI/locked-docs")"
    chmod 000 "${fx}/AI/locked-docs"
    rc="$(run_capture "${work}/placeholder-ai.txt" "${fx}/Scripts/verify-static.sh")"
    chmod "$mode" "${fx}/AI/locked-docs"
    out="$(cat "${work}/placeholder-ai.txt")"
    expect_exit 65 "$rc" "an unreadable AI/ subtree does not silence the document scan"
    expect_contains "$out" "could not scan AI/" "the gate names the scan it could not complete"
    rm -rf "${fx}/AI/locked-docs"

    # 4. Merge conflict marker scan.
    mkdir -p "${fx}/AI/locked-conflict"
    printf '<<<<<<< HEAD\nours\n' > "${fx}/AI/locked-conflict/note.md"
    mode="$(stat -f '%Lp' "${fx}/AI/locked-conflict")"
    chmod 000 "${fx}/AI/locked-conflict"
    rc="$(run_capture "${work}/conflict.txt" "${fx}/Scripts/verify-template.sh")"
    chmod "$mode" "${fx}/AI/locked-conflict"
    out="$(cat "${work}/conflict.txt")"
    expect_exit 65 "$rc" "an unreadable subtree does not silence the conflict-marker scan"
    expect_contains "$out" "could not scan the repository for merge conflict markers" \
        "the gate names the scan it could not complete"
    expect_absent "$out" "no conflict markers" \
        "an inconclusive conflict scan is never reported as clean"
    rm -rf "${fx}/AI/locked-conflict"

    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the fixture passes again once every path is readable"
}

# The status template's phase examples and the validator's accepted set are two
# copies of one enum, and they had drifted: the template offered `maintenance` and
# `release`, both rejected, and hid five real tokens including the one the live
# file uses. Parity is asserted in both directions, derived from the two real
# sources so this case never becomes a third copy.
case_project_phase_parity() {
    local fx="${SELFTEST_DIR}/phase-parity"
    local work="${SELFTEST_DIR}/phase-parity-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local template phase rc offered

    template="$(grep -m1 '^\*\*Phase:\*\*' "${fx}/AI/templates/project-status-template.md")"

    # Direction 1: every canonical token is offered by the template.
    for phase in $IOSAI_PROJECT_PHASES; do
        expect_contains "$template" "$phase" "the status template offers canonical phase ${phase}"
    done

    # Direction 2: every token the template offers is accepted by the validator.
    offered="$(printf '%s\n' "$template" | sed 's/^\*\*Phase:\*\* *//' | tr '|' '\n' \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$')"
    while IFS= read -r phase; do
        [ -n "$phase" ] || continue
        sed "s/^\*\*Phase:\*\* .*/**Phase:** ${phase}/" "${fx}/AI/PROJECT_STATUS.md" \
            > "${fx}/AI/PROJECT_STATUS.md.new"
        mv "${fx}/AI/PROJECT_STATUS.md.new" "${fx}/AI/PROJECT_STATUS.md"
        rc="$(run_capture "${work}/phase-${phase}.txt" \
            "${fx}/Scripts/project-status.sh" validate)"
        expect_exit 0 "$rc" "the validator accepts offered phase ${phase}"
    done <<EOF
$offered
EOF
    git -C "$fx" checkout -q -- AI/PROJECT_STATUS.md

    # And a token neither source knows is still refused, so this is not vacuous.
    sed 's/^\*\*Phase:\*\* .*/**Phase:** maintenance/' "${fx}/AI/PROJECT_STATUS.md" \
        > "${fx}/AI/PROJECT_STATUS.md.new"
    mv "${fx}/AI/PROJECT_STATUS.md.new" "${fx}/AI/PROJECT_STATUS.md"
    rc="$(run_capture "${work}/phase-unknown.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "an uncanonical phase is still refused"
    git -C "$fx" checkout -q -- AI/PROJECT_STATUS.md
}

# Every audit and handoff must declare, machine-readably, whether it is current
# policy or a superseded historical record. One handoff carried no marker and
# ended with a spent "do not merge" instruction that read as live.
case_record_policy_status() {
    local fx="${SELFTEST_DIR}/policy-status"
    local work="${SELFTEST_DIR}/policy-status-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc out record="${fx}/AI/handoffs/fixture-record.md"

    rc="$(run_capture "${work}/baseline.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "the shipped audits and handoffs are all classified"

    printf '# Fixture record\n\nno marker at all\n' > "$record"
    rc="$(run_capture "${work}/unmarked.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/unmarked.txt")"
    expect_exit 65 "$rc" "an unclassified record is refused"
    expect_contains "$out" "fixture-record.md" "the refusal names the record"

    printf '**Policy status:** current\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/current.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a record marked current is accepted"

    printf '> **HISTORICAL RECORD — SUPERSEDED POLICY**\n\n**Policy status:** superseded\n**Superseded by:** solo-workflow/2\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/superseded.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "a correctly bannered superseded record is accepted"

    printf '**Policy status:** superseded\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/nobanner.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a superseded record without its banner is refused"

    printf '**Policy status:** current\n**Policy status:** superseded\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/duplicate.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/duplicate.txt")"
    expect_exit 65 "$rc" "duplicate status fields are refused"
    expect_contains "$out" "exactly one is allowed" "the refusal explains the ambiguity"

    printf '**Policy status:** retired\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/unknown.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "an unknown status value is refused"

    printf '> **HISTORICAL RECORD — SUPERSEDED POLICY**\n\n**Policy status:** current\n**Superseded by:** solo-workflow/2\n\n# Fixture record\n' > "$record"
    rc="$(run_capture "${work}/contradictory.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 65 "$rc" "a record cannot be both current and superseded"

    rm -f "$record"
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-template.sh")"
    expect_exit 0 "$rc" "removing the fixture record restores a clean tree"
}

# A report is read by a Reviewer who was not there. It may not record `unknown`
# where a mode belongs, state a machine-read field twice, claim a candidate
# worktree that does not exist, or let a template-scope pass read as though an
# application had been built and tested.
case_milestone_report_hygiene() {
    local fx="${SELFTEST_DIR}/report-hygiene"
    local work="${SELFTEST_DIR}/report-hygiene-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc report latest branches

    # --- product mode, current HEAD ---
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/product.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    expect_exit 0 "$rc" "product-mode milestone verification passes"
    latest="$(cat "${fx}/.artifacts/milestone/M00/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" '**Mode:** product' "the report records the resolved repository mode"
    expect_absent "$report" '**Mode:** unknown' "the report never records an unknown mode"
    branches="$(grep -c '^\*\*Branch:\*\*' "${latest}/report.md")"
    expect_same "1" "$branches" "the report states the branch exactly once"
    expect_absent "$report" "read-only candidate worktree" \
        "a current-HEAD run claims no candidate worktree"
    expect_contains "$report" '**VERIFIED_COMMIT:**' "a passing product report records the verified commit"

    # --- template mode: honest about what did not run ---
    local tfx="${SELFTEST_DIR}/report-hygiene-template"
    local twork="${SELFTEST_DIR}/report-hygiene-template-work"
    mkdir -p "$twork"
    fixture_template "$tfx" "$twork"
    # M00 cannot pass in template mode, so exercise a later milestone in REVIEW.
    cat > "${tfx}/AI/milestones/M01-fixture.md" <<'MILESTONE'
# M01 — Fixture

**ID:** M01
**Status:** REVIEW
**Depends on:** M00
**Validation:** make milestone ID=M01
**Handoff:** AI/handoffs/M01-handoff.md

## Objective

Exercise the template-scope milestone report.

## Scope

- Fixture only.

## Non-goals

- No application.

## Acceptance criteria

- [ ] The report states what did not run.
MILESTONE
    sed 's/^\*\*Status:\*\* PLANNED$/**Status:** DONE/' \
        "${tfx}/AI/milestones/M00-template-bootstrap.md" \
        > "${tfx}/AI/milestones/M00-template-bootstrap.md.new"
    mv "${tfx}/AI/milestones/M00-template-bootstrap.md.new" \
        "${tfx}/AI/milestones/M00-template-bootstrap.md"
    fixture_commit_unchecked "$tfx" "add a template-scope milestone in review"

    rc="$(run_capture "${work}/template.txt" "${tfx}/Scripts/verify-milestone.sh" M01)"
    expect_exit 0 "$rc" "template-scope milestone verification passes"
    latest="$(cat "${tfx}/.artifacts/milestone/M01/latest.txt")"
    report="$(cat "${latest}/report.md")"
    expect_contains "$report" '**Mode:** template' "the template-mode report records template mode"
    expect_absent "$report" '**Mode:** unknown' "the template-mode report records no unknown mode"
    branches="$(grep -c '^\*\*Branch:\*\*' "${latest}/report.md")"
    expect_same "1" "$branches" "the template-mode report states the branch exactly once"
    expect_contains "$report" "Application build | NOT RUN" "the report states that no application was built"
    expect_contains "$report" "Application tests | NOT RUN" "the report states that no application test ran"
    expect_contains "$report" "no application test executed" "the report spells out the limit of its claim"
    expect_contains "$report" "template scope" "the verdict is qualified as template scope"

    # --- a refused run claims nothing and publishes nothing ---
    #
    # The clean-tree precondition is checked before any evidence directory is
    # created, so the correct assertion is that no new report appears at all and
    # the previous run's pointer is left alone. A report written *after* a gate has
    # started and then failed is covered by case_report_labels.
    local reports_before reports_after pointer_before pointer_after
    reports_before="$(find "${tfx}/.artifacts/milestone/M01" -name 'report.md' | wc -l | tr -d ' ')"
    pointer_before="$(cat "${tfx}/.artifacts/milestone/M01/latest.txt")"
    printf '\n<!-- dirty -->\n' >> "${tfx}/AI/PRODUCT.md"
    rc="$(run_capture "${work}/failed.txt" "${tfx}/Scripts/verify-milestone.sh" M01)"
    git -C "$tfx" checkout -q -- AI/PRODUCT.md
    reports_after="$(find "${tfx}/.artifacts/milestone/M01" -name 'report.md' | wc -l | tr -d ' ')"
    pointer_after="$(cat "${tfx}/.artifacts/milestone/M01/latest.txt")"
    expect_exit 65 "$rc" "a dirty checkout still blocks verification"
    expect_absent "$(cat "${work}/failed.txt")" "VERIFIED_COMMIT" \
        "a refused run prints no verified commit"
    expect_same "$reports_before" "$reports_after" "a refused run publishes no new report"
    expect_same "$pointer_before" "$pointer_after" "a refused run leaves the latest pointer alone"
}

# project-status.sh built a temporary directory per run and never removed it.
case_status_scratch_cleanup() {
    local fx="${SELFTEST_DIR}/status-scratch"
    local work="${SELFTEST_DIR}/status-scratch-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc cmd before after tmp="${TMPDIR:-/tmp}"

    before="$(find "$tmp" -maxdepth 1 -name 'iosai-status*' 2>/dev/null | wc -l | tr -d ' ')"
    for cmd in summary next worktrees validate; do
        rc="$(run_capture "${work}/${cmd}.txt" "${fx}/Scripts/project-status.sh" "$cmd")"
        expect_exit 0 "$rc" "project-status ${cmd} succeeds"
    done
    after="$(find "$tmp" -maxdepth 1 -name 'iosai-status*' 2>/dev/null | wc -l | tr -d ' ')"
    expect_same "$before" "$after" "no temporary status directory survives a successful run"

    # The failure path must clean up too, and must keep its own exit status.
    sed 's/^\*\*Phase:\*\* .*/**Phase:** nonsense/' "${fx}/AI/PROJECT_STATUS.md" \
        > "${fx}/AI/PROJECT_STATUS.md.new"
    mv "${fx}/AI/PROJECT_STATUS.md.new" "${fx}/AI/PROJECT_STATUS.md"
    rc="$(run_capture "${work}/invalid.txt" "${fx}/Scripts/project-status.sh" next)"
    expect_exit 0 "$rc" "next still reports while the status file is invalid"
    rc="$(run_capture "${work}/invalid-validate.txt" "${fx}/Scripts/project-status.sh" validate)"
    expect_exit 65 "$rc" "validate reports the invalid status file"
    after="$(find "$tmp" -maxdepth 1 -name 'iosai-status*' 2>/dev/null | wc -l | tr -d ' ')"
    expect_same "$before" "$after" "no temporary status directory survives a failing run"
    git -C "$fx" checkout -q -- AI/PROJECT_STATUS.md
}

# Every record the workflow asks for is written from a template in AI/templates/,
# and verify-template.sh requires every record under AI/audits/ and AI/handoffs/ to
# declare a `**Policy status:**`. None of the record templates carried that field, so
# the documented Builder step "write the compact handoff, commit it" produced a file
# that failed static verification — which blocked the optional pre-commit hook and
# every later milestone, integration and release run, on the first milestone of every
# project made from this template. The shipped template IS the specification of a
# valid record, so it is asserted as one.
case_record_templates() {
    local fx="${SELFTEST_DIR}/record-templates"
    local work="${SELFTEST_DIR}/record-templates-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    local rc t d probe

    for t in handoff-template audit-template domain-audit-template release-audit-template; do
        for d in AI/handoffs AI/audits; do
            probe="${fx}/${d}/probe-${t}.md"
            cp "${fx}/AI/templates/${t}.md" "$probe"
            rc="$(run_capture "${work}/${t}-${d##*/}.txt" "${fx}/Scripts/verify-template.sh")"
            expect_exit 0 "$rc" "${t}.md is a valid ${d##*/} record exactly as shipped"
            rm -f "$probe"
        done
    done

    # The whole documented Builder sequence, not just the template in isolation.
    cp "${fx}/AI/templates/handoff-template.md" "${fx}/AI/handoffs/M00-handoff.md"
    rc="$(run_capture "${work}/static.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "committing a handoff written from the template keeps make static green"

    # And the rule still bites when the field is genuinely absent.
    printf '# Hand-written record\n\nno marker\n' > "${fx}/AI/handoffs/M00-handoff.md"
    rc="$(run_capture "${work}/unmarked.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "a record without the field is still refused"
    rm -f "${fx}/AI/handoffs/M00-handoff.md"
}

# make static is the daily command and the optional pre-commit hook. It used to
# accept a configuration that every gate consuming the value rejects — an absolute
# or `..`-escaping project path, a project outside App/, an unknown distribution
# channel, a RELEASE_TEST_ARGUMENTS value that narrows a complete-suite gate. Nothing
# unsafe happened; the developer simply found out at build time instead.
case_static_configuration_validation() {
    local fx="${SELFTEST_DIR}/static-config"
    local work="${SELFTEST_DIR}/static-config-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc base="${work}/config.base" cfg="${fx}/Config/project.env"
    cp "$cfg" "$base"

    rc="$(run_capture "${work}/baseline.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the product fixture passes static verification to begin with"

    set_key() {
        local key="$1" value="$2"
        cp "$base" "$cfg"
        sed "s|^${key}=.*|${key}=\"${value}\"|" "$cfg" > "${cfg}.new"
        mv "${cfg}.new" "$cfg"
    }

    # Optional-tool booleans fail closed. A misspelling used to take the same
    # branch as "false", so a configured check disappeared while static reported
    # success. Exercise all three keys and require the diagnostic to identify the
    # exact one that is malformed.
    local optional_key
    for optional_key in ENABLE_SWIFTLINT ENABLE_SWIFTFORMAT ENABLE_SHELLCHECK; do
        set_key "$optional_key" "ture"
        rc="$(run_capture "${work}/${optional_key}.txt" "${fx}/Scripts/verify-static.sh")"
        expect_exit 65 "$rc" "static refuses misspelled ${optional_key}"
        expect_contains "$(cat "${work}/${optional_key}.txt")" "$optional_key" \
            "the optional-tool diagnostic names ${optional_key}"
        expect_contains "$(cat "${work}/${optional_key}.txt")" '"true" or "false"' \
            "the optional-tool diagnostic states the accepted booleans"
    done

    set_key PROJECT_PATH "/etc/passwd"
    rc="$(run_capture "${work}/absolute.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" "static refuses an absolute project path"
    expect_contains "$(cat "${work}/absolute.txt")" "repository-relative" "the reason is named"

    set_key PROJECT_PATH "../elsewhere/App.xcodeproj"
    rc="$(run_capture "${work}/escape.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" "static refuses a project path that escapes through .."

    set_key PROJECT_PATH "Other/App.xcodeproj"
    rc="$(run_capture "${work}/outside.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" "static refuses a project outside App/"

    set_key DISTRIBUTION_CHANNEL "enterprise"
    rc="$(run_capture "${work}/channel.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "static refuses an unknown distribution channel"

    set_key RELEASE_TEST_ARGUMENTS "-only-testing:FixtureTests"
    rc="$(run_capture "${work}/narrow.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" "static refuses a release argument that narrows the suite"
    expect_contains "$(cat "${work}/narrow.txt")" "may not change which tests run" "the reason is named"

    set_key RELEASE_TEST_ARGUMENTS "-parallel-testing-enabled NO"
    rc="$(run_capture "${work}/allowed.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "an allowlisted release argument still passes"

    # The same validation runs before repository-mode branching. Prove an empty
    # explicit value fails in template mode too rather than inheriting the default.
    local template_fx="${SELFTEST_DIR}/static-config-template"
    local template_work="${SELFTEST_DIR}/static-config-template-work"
    mkdir -p "$template_work"
    fixture_template "$template_fx" "$template_work"
    sed 's|^ENABLE_SHELLCHECK=.*|ENABLE_SHELLCHECK=""|' \
        "${template_fx}/Config/project.env" > "${template_fx}/Config/project.env.new"
    mv "${template_fx}/Config/project.env.new" "${template_fx}/Config/project.env"
    rc="$(run_capture "${template_work}/empty-boolean.txt" \
        "${template_fx}/Scripts/verify-static.sh")"
    expect_exit 65 "$rc" "template mode refuses an explicitly empty optional-tool boolean"
    expect_contains "$(cat "${template_work}/empty-boolean.txt")" "ENABLE_SHELLCHECK" \
        "template-mode validation names the malformed optional-tool key"

    # Both containers configured. Every build gate refuses this with exit 64 —
    # require_project_configured has always caught it — but `make static` passed it,
    # which is the late-discovery pattern this whole block exists to prevent. The
    # check now lives in assert_single_project_container and both callers use it.
    cp "$base" "$cfg"
    sed 's|^WORKSPACE_PATH=.*|WORKSPACE_PATH="App/Fixture.xcworkspace"|' "$cfg" > "${cfg}.new"
    mv "${cfg}.new" "$cfg"
    mkdir -p "${fx}/App/Fixture.xcworkspace"
    printf '<Workspace></Workspace>\n' > "${fx}/App/Fixture.xcworkspace/contents.xcworkspacedata"
    rc="$(run_capture "${work}/both-containers.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 64 "$rc" "static refuses a configuration naming both a project and a workspace"
    expect_contains "$(cat "${work}/both-containers.txt")" "mutually exclusive" "the reason is named"
    rm -rf "${fx}/App/Fixture.xcworkspace"

    cp "$base" "$cfg"
    rc="$(run_capture "${work}/restored.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the fixture passes again once the configuration is restored"
}

# A repository made from this template owns its own front page and its own
# milestone slugs.
#
# verify-template.sh required the literal path AI/milestones/M00-template-bootstrap.md
# and five README headings including "## Updating this template" — a section about
# maintaining the template, in a document that is the product's front page. Because
# verify-static.sh runs verify-template.sh first, writing your app's README broke
# `make static`, the optional pre-commit hook, and the first stage of every strict
# gate, reporting only "missing the required heading". Nothing needed the exact M00
# filename: milestone_file_for_id resolves M00-*.md.
case_product_repository_identity() {
    local fx="${SELFTEST_DIR}/product identity"
    local work="${SELFTEST_DIR}/product-identity-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out

    rc="$(run_capture "${work}/baseline.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the product fixture passes static verification to begin with"

    # The marker initialize-project.sh writes. Its absence is what identifies the
    # universal template, and initialization refuses to run when it is present, so
    # the template can never acquire one.
    printf 'ios-ai-project/2\nowner=Fixture Owner\nprimary_branch=main\n' > "${fx}/.iosai-project"
    mv "${fx}/AI/milestones/M00-template-bootstrap.md" \
       "${fx}/AI/milestones/M00-product-bootstrap.md"
    cat > "${fx}/README.md" <<'README'
# Fixture App

A tiny iOS app that does one thing well.

## Install

From the App Store.
README
    fixture_commit_unchecked "$fx" "the project takes ownership of its README and its M00 slug"

    rc="$(run_capture "${work}/owned.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/owned.txt")"
    expect_exit 0 "$rc" "a project repository may rename M00 and write its own README"
    expect_absent "$out" "Updating this template" \
        "no template-maintenance heading is demanded of a project repository"
    expect_contains "$out" "README.md structure" "the skipped check is reported, not silent"

    # M00 must still exist under some slug: it is what proves the harness works, and
    # every other milestone depends on it.
    mv "${fx}/AI/milestones/M00-product-bootstrap.md" "${fx}/AI/milestones/M01-not-zero.md"
    rc="$(run_capture "${work}/no-m00.txt" "${fx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/no-m00.txt")"
    expect_exit 65 "$rc" "a repository with no M00 milestone is still refused"
    expect_contains "$out" "no M00 milestone" "the reason names the missing milestone"
    mv "${fx}/AI/milestones/M01-not-zero.md" "${fx}/AI/milestones/M00-product-bootstrap.md"

    # And the universal template still holds itself to its own README contract.
    local tfx="${SELFTEST_DIR}/template identity"
    fixture_template "$tfx" "$work"
    [ ! -e "${tfx}/.iosai-project" ] \
        && check pass "the universal template carries no project marker" \
        || check fail "the template fixture unexpectedly looks like a derived project"
    grep -v '^## Updating this template$' "${tfx}/README.md" > "${tfx}/README.new"
    mv "${tfx}/README.new" "${tfx}/README.md"
    rc="$(run_capture "${work}/template-readme.txt" "${tfx}/Scripts/verify-template.sh")"
    out="$(cat "${work}/template-readme.txt")"
    expect_exit 65 "$rc" "the universal template still requires its own README structure"
    expect_contains "$out" "## Updating this template" "the template names the heading it lost"
}

# A vendored dependency tree is not repository content, and its own test fixtures
# are not this project's secrets. Scanning Pods/ reported somebody else's test
# certificate as a leaked credential and failed every gate for a workspace-based
# project. Under App/, the same trees are refused as ignored build inputs instead —
# a candidate snapshot never contains them — and the configuration example says so
# rather than offering CocoaPods as a supported setup.
case_vendored_dependencies() {
    local fx="${SELFTEST_DIR}/vendored"
    local work="${SELFTEST_DIR}/vendored-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out

    mkdir -p "${fx}/Pods/SomeLib/Tests" "${fx}/Carthage/Build/Some"
    printf -- '-----BEGIN CERTIFICATE-----\nnot ours\n' > "${fx}/Pods/SomeLib/Tests/fixture.pem"
    printf 'key material\n' > "${fx}/Carthage/Build/Some/signing.key"
    printf 'let copy = "TBD"\n' > "${fx}/Pods/SomeLib/Draft.swift"
    rc="$(run_capture "${work}/vendored.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/vendored.txt")"
    expect_exit 0 "$rc" "a vendored dependency tree does not fail the credential scan"
    expect_absent "$out" "Pods/SomeLib" "no vendored path is reported as this project's secret"
    expect_absent "$out" "Carthage/Build" "no vendored path is reported at all"

    # The same bytes in the project's own sources must still fail, or the prune has
    # become a hole rather than a scope.
    cp "${fx}/Pods/SomeLib/Tests/fixture.pem" "${fx}/App/ours.pem"
    rc="$(run_capture "${work}/ours.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/ours.txt")"
    expect_exit 65 "$rc" "the same file under App/ is still a finding"
    expect_contains "$out" "App/ours.pem" "the project's own credential file is named"
    rm -rf "${fx}/Pods" "${fx}/Carthage" "${fx}/App/ours.pem"

    # Under App/ a vendored tree is what the build would compile, it is ignored, and
    # no candidate snapshot contains it, so the clean-HEAD gate refuses it. The
    # configuration example used to offer CocoaPods as a reason for a workspace; it
    # now names Swift Package Manager and states this limit.
    mkdir -p "${fx}/App/Pods/SomeLib"
    printf 'let lib = 1\n' > "${fx}/App/Pods/SomeLib/Lib.swift"
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/app-pods.txt" \
        "${fx}/Scripts/verify-milestone.sh" M00)"
    out="$(cat "${work}/app-pods.txt")"
    expect_exit 65 "$rc" "a CocoaPods tree under App/ is refused as an ignored build input"
    expect_contains "$out" "App/Pods/SomeLib/Lib.swift" "the refusal names the vendored file"
    rm -rf "${fx}/App/Pods"
    local example
    example="$(cat "${IOSAI_ROOT}/Config/project.env.example")"
    expect_contains "$example" "Third-party code comes from Swift Package Manager" \
        "the configuration example names Swift Package Manager as the way in"
    expect_contains "$example" "A CocoaPods Pods/ or a Carthage tree under App/ cannot be verified" \
        "the configuration example states that vendored trees under App/ cannot be verified"
    expect_absent "$example" "CocoaPods or a multi-project workspace" \
        "the configuration example no longer offers CocoaPods as a supported workspace setup"
}

# The content scans used to run one grep per (file x pattern): 11,726 processes and
# 44 seconds on a 1,067-file application, for a command that is both `make static`
# and the optional pre-commit hook. Batching must not change a single answer — the
# same files, the same patterns, secret bytes still never printed, and a scan that
# could not run still failing closed.
case_batched_scanning() {
    local fx="${SELFTEST_DIR}/batched"
    local work="${SELFTEST_DIR}/batched-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out i secret mode

    mkdir -p "${fx}/App/Generated"
    i=0
    while [ "$i" -lt 60 ]; do
        printf 'import Foundation\nstruct S%s { let v = %s }\n' "$i" "$i" \
            > "${fx}/App/Generated/S${i}.swift"
        i=$((i + 1))
    done
    rc="$(run_capture "${work}/clean.txt" "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "a padded product tree still passes"

    # Assembled at run time so this file is not itself a secret-shaped file.
    secret="AKIA$(printf 'A%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)"
    printf 'let k = "%s"\n' "$secret" > "${fx}/App/Generated/S7.swift"
    printf 'let copy = "FIXME finish this"\n' > "${fx}/App/Generated/S8.swift"
    rc="$(run_capture "${work}/found.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/found.txt")"
    expect_exit 65 "$rc" "a planted secret in a padded tree is still found"
    expect_contains "$out" "App/Generated/S7.swift:1: aws-access-key" "the finding names path, line and class"
    expect_contains "$out" "App/Generated/S8.swift" "the placeholder in shipping source is still found"
    expect_absent "$out" "$secret" "the matched secret bytes are never printed"

    # Batching also must not turn an unreadable file into a clean result.
    printf 'let clean = 1\n' > "${fx}/App/Generated/S7.swift"
    printf 'let clean = 2\n' > "${fx}/App/Generated/S8.swift"
    mode="$(stat -f '%Lp' "${fx}/App/Generated/S9.swift")"
    chmod 000 "${fx}/App/Generated/S9.swift"
    rc="$(run_capture "${work}/unreadable.txt" "${fx}/Scripts/verify-static.sh")"
    out="$(cat "${work}/unreadable.txt")"
    chmod "$mode" "${fx}/App/Generated/S9.swift"
    expect_exit 65 "$rc" "an unreadable file still fails the scan closed"
    expect_contains "$out" "not readable" "the unreadable path is reported"
    expect_absent "$out" "no embedded private keys" "no clean credential result is claimed"

    # The process budget is the point of the change, and the invariant is the SLOPE,
    # not the absolute count: the gate legitimately runs a fixed number of greps for
    # required ignore rules, document headings, record classification and so on. What
    # must not happen is a grep per repository file. So the same gate is counted
    # twice, with a few hundred files added in between, and the difference is what is
    # asserted. An absolute bound would just encode today's fixed cost.
    mkdir -p "${work}/countbin"
    cat > "${work}/countbin/grep" <<COUNTER
#!/usr/bin/env bash
printf 'x\n' >> "${work}/grep-calls"
exec /usr/bin/grep "\$@"
COUNTER
    chmod +x "${work}/countbin/grep"

    : > "${work}/grep-calls"
    rc="$(PATH="${work}/countbin:$PATH" run_capture "${work}/counted-base.txt" \
        "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the counted baseline run still passes"
    local base_calls added_calls added=240 slope budget
    base_calls="$(wc -l < "${work}/grep-calls" | tr -d ' ')"

    i=0
    while [ "$i" -lt "$added" ]; do
        printf 'import Foundation\nstruct P%s { let v = %s }\n' "$i" "$i" \
            > "${fx}/App/Generated/P${i}.swift"
        i=$((i + 1))
    done
    : > "${work}/grep-calls"
    rc="$(PATH="${work}/countbin:$PATH" run_capture "${work}/counted-padded.txt" \
        "${fx}/Scripts/verify-static.sh")"
    expect_exit 0 "$rc" "the counted padded run still passes"
    added_calls="$(wc -l < "${work}/grep-calls" | tr -d ' ')"

    slope=$((added_calls - base_calls))
    [ "$slope" -ge 0 ] || slope=0
    # Generous, and still an order of magnitude below per-file scanning: the old
    # shape spent eleven credential patterns plus a placeholder and a conflict scan
    # on every single file.
    budget=$((added / 4))
    if [ "$slope" -le "$budget" ]; then
        check pass "adding ${added} files added only ${slope} grep invocations (budget ${budget})"
    else
        check fail "scanning is still per file: ${added} files added ${slope} grep invocations"
    fi
}

# Candidate IDs include a fixed-width SHA fragment and must not change with Git's
# configurable display abbreviation.
case_candidate_identity_stability() {
    local fx="${SELFTEST_DIR}/candidate-identity"
    local work="${SELFTEST_DIR}/candidate-identity-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc expected

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/ready.txt" fixture_release "$fx")"
    expect_exit 0 "$rc" "the fully audited candidate reaches distribution readiness"
    expected="$(fixture_candidate "$fx" | cut -c1-12)"
    expect_contains "$(cat "${work}/ready.txt")" "$expected" "the candidate uses the fixed SHA fragment"

    # Change how git would abbreviate, then re-run the same candidate.
    git -C "$fx" config core.abbrev 4
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/narrow-abbrev.txt" fixture_release "$fx")"
    expect_exit 0 "$rc" "a narrower core.abbrev does not change readiness identity"
    git -C "$fx" config core.abbrev 20
    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/wide-abbrev.txt" fixture_release "$fx")"
    expect_exit 0 "$rc" "a wider core.abbrev does not change readiness identity"
    expect_contains "$(cat "${work}/wide-abbrev.txt")" "$expected" \
        "candidate identity is independent of abbreviation width"
    git -C "$fx" config --unset core.abbrev
}

case_derived_data_argument() {
    local fx="${SELFTEST_DIR}/derived-arg"
    local work="${SELFTEST_DIR}/derived-arg-work"
    mkdir -p "$work"
    fixture_product "$fx" "$work"
    local rc out sentinel="${work}/outside/keep.txt"
    mkdir -p "${work}/outside"
    printf 'unrelated\n' > "$sentinel"

    # The milestone contract has to agree with the configured selector, so both are
    # set: this is the only route by which such an argument can reach xcodebuild.
    sed "s|^MILESTONE_TEST_ARGUMENTS=.*|MILESTONE_TEST_ARGUMENTS=\"-derivedDataPath ${work}/outside/dd\"|" \
        "${fx}/Config/project.env" > "${fx}/Config/project.env.new"
    mv "${fx}/Config/project.env.new" "${fx}/Config/project.env"
    {
        printf '**Milestone test arguments:** -derivedDataPath %s/outside/dd\n' "$work"
        printf '**Test scope rationale:** deliberate attempt to relocate the build cache\n'
    } >> "${fx}/AI/milestones/M00-template-bootstrap.md"
    fixture_commit_unchecked "$fx" "attempt a cache redirect"

    rc="$(PATH="${STUB_BIN}:$PATH" run_capture "${work}/redirect.txt" \
        fixture_milestone "$fx" M00)"
    out="$(cat "${work}/redirect.txt")"
    expect_exit 64 "$rc" "a -derivedDataPath outside the owned cache root is refused"
    expect_contains "$out" "owned cache root" "the refusal names the boundary"
    expect_same "unrelated" "$(cat "$sentinel")" "the unrelated directory is untouched"
    [ ! -e "${work}/outside/dd" ] \
        && check pass "no cache directory was created outside the owned root" \
        || check fail "a cache directory was created outside the owned root"
}

# ---------------------------------------------------------------------------
# The parallel driver.
#
# Cases run concurrently, so the driver itself is now load-bearing: a scheduler
# that dropped a case, mixed two cases' fixtures, or lost a failing case's output
# would turn "the suite passed" into a false statement exactly the way a narrowed
# test suite does. These cases hold it to that.
#
# They exercise the driver against a SYNTHETIC registry rather than the real one.
# A real case costs tens of seconds, and the assertions here are about membership,
# counts and isolation — properties that need an exactly-known case set, not an
# expensive one. Nothing here asserts a duration: a "parallel must finish in N
# seconds" check fails on a busy machine while proving nothing about correctness.
# ---------------------------------------------------------------------------

# fixture_synthetic_suite <fixture-dir> — replace the fixture's case registry with
# the five synthetic cases and their stubs.
#
# The stubs are inserted after the driver's banner, which is the last point at
# which a function definition is still ahead of its use. Both edits are verified
# afterwards, and the case fails loudly if either anchor has moved: a refactor
# that silently stopped installing the stubs would leave these cases passing
# against the real registry, which is the one outcome worse than failing.
fixture_synthetic_suite() {
    local dir="$1"
    local target="${dir}/Scripts/self-test.sh"
    local stubs="${dir}/.synthetic-stubs"

    cat > "$stubs" <<'STUBS_PLACEHOLDER'
# --- synthetic cases, installed into a fixture by the parallel-driver cases ----
# They replace the real registry so the driver can be held to an exactly-known
# case set, with known check counts and a known outcome, at a cost of
# milliseconds instead of tens of seconds. SELFTEST_PROBE_DIR is how they report
# what they saw from inside their own worker process; SELFTEST_PLANT_FAILURE is
# how one of them is turned into a defect.
_probe() {
    printf '%s\n' "$1" >> "${SELFTEST_PROBE_DIR:?}/ran"
    printf '%s %s\n' "$1" "$SELFTEST_DIR" >> "${SELFTEST_PROBE_DIR}/dirs"
    mkdir -p "$SELFTEST_DIR" "${SELFTEST_PROBE_DIR}/running"
    : > "${SELFTEST_DIR}/owned-by-$1"
    # How many cases were running while this one was. Recorded rather than
    # asserted here: the outer case decides what the number has to be, and a count
    # can only over-report if that many really did overlap.
    : > "${SELFTEST_PROBE_DIR}/running/$1"
    find "${SELFTEST_PROBE_DIR}/running" -type f | wc -l | tr -d ' ' \
        > "${SELFTEST_PROBE_DIR}/observed-$1"
    sleep 0.3
    rm -f "${SELFTEST_PROBE_DIR}/running/$1"
}

# A checkout under the case's own root, and the build-cache root a gate would make
# for it, created through the library exactly as a gate creates it. The root's path is
# reported so the outer case can prove the run's cleanup removed it.
_plant_cache() {
    [ "${SELFTEST_PLANT_CACHE:-}" = "$1" ] || return 0
    local owner="${SELFTEST_DIR}/cache-owner"
    mkdir -p "${owner}/Scripts/lib"
    cp "${IOSAI_ROOT}/Scripts/lib/common.sh" "${IOSAI_ROOT}/Scripts/lib/simulator.sh" \
        "${IOSAI_ROOT}/Scripts/lib/platform.sh" "${IOSAI_ROOT}/Scripts/lib/lease.pl" \
        "${IOSAI_ROOT}/Scripts/lib/companion.sh" "${owner}/Scripts/lib/"
    # Printed only once the directory demonstrably exists, so the outer check can
    # never pass because nothing was created in the first place.
    bash -c 'set -e
             . "$1/Scripts/lib/common.sh"
             ensure_derived_data_root "$(derived_data_path)"
             root="$(derived_data_owned_root)"
             [ -d "${root}/DerivedData" ]
             printf "%s\n" "$root"' _ "$owner" > "${SELFTEST_PROBE_DIR}/cache-root"
}

_plant() {
    _plant_cache "$1"
    if [ "${SELFTEST_PLANT_ABORT:-}" = "$1" ]; then
        # Ends the worker process with no result written at all. The old serial
        # driver would have taken the whole suite down here; the driver must now
        # treat one silent worker as that case failing, and never as good news.
        exit "$EX_SOFTWARE"
    fi
    if [ "${SELFTEST_PLANT_FAILURE:-}" = "$1" ]; then
        # A captured gate run that only the failure reprint can bring back: the
        # fixture holding it is deleted with the run.
        run_capture "${SELFTEST_DIR}/planted-gate.txt" \
            printf 'planted gate output for %s\n' "$1" >/dev/null
        check fail "planted defect visible in $1"
    else
        check pass "$1 ran"
    fi
}

case_alpha() { _probe alpha; _plant alpha; check pass "alpha ran a second check"; }
case_beta() {
    _probe beta
    _plant beta
    check pass "beta ran a second check"
    check pass "beta ran a third check"
}
case_gamma() { _probe gamma; _plant gamma; }
case_delta() { _probe delta; _plant delta; }
case_epsilon() {
    _probe epsilon
    # Each worker must be handed a fixture root of its own, named for its case.
    # Asserted from inside the worker as well as from outside, because this is the
    # property every other isolation guarantee rests on.
    expect_same "epsilon" "$(basename -- "$SELFTEST_DIR")" \
        "the worker received a fixture root named for its own case"
    _plant epsilon
}
STUBS_PLACEHOLDER

    awk -v stubs="$stubs" '
        /^CASES="/ {
            print "CASES=\"alpha\nbeta\ngamma\ndelta\nepsilon\""
            registry = 1
            next
        }
        registry == 1 { if ($0 ~ /"$/) registry = 0; next }
        seen_driver == 1 && inserted == 0 && /^# -----/ {
            print
            while ((getline line < stubs) > 0) print line
            close(stubs)
            inserted = 1
            next
        }
        /^# Driver$/ { seen_driver = 1 }
        { print }
    ' "$target" > "${target}.new"
    mv "${target}.new" "$target"
    chmod +x "$target"
    rm -f "$stubs"

    if ! grep -q '^case_epsilon() {' "$target"; then
        check fail "the synthetic stubs were not installed; the driver banner anchor moved"
        return 1
    fi
    if ! grep -q '^CASES="alpha$' "$target"; then
        check fail "the synthetic registry was not installed; the CASES anchor moved"
        return 1
    fi
    if ! bash -n "$target" 2>/dev/null; then
        check fail "the synthetic suite does not parse"
        return 1
    fi
    return 0
}

# run_synthetic <fixture> <probe-dir> <out-file> [args...] — run the synthetic
# suite and echo its exit status.
run_synthetic() {
    local fx="$1" probe="$2" out="$3"
    shift 3
    mkdir -p "$probe"
    SELFTEST_PROBE_DIR="$probe" run_capture "$out" "${fx}/Scripts/self-test.sh" "$@"
}

# verdict_lines <output-file> — the ordered PASS/FAIL verdict sequence, which is
# what must be identical at any worker count. Captured output carries no colour:
# the nested run's stdout is a file, so common.sh disables it at source time.
verdict_lines() {
    grep -E '^(PASS|FAIL) ' "$1" || true
}

case_parallel_worker_count() {
    local fx="${SELFTEST_DIR}/jobs-count"
    local work="${SELFTEST_DIR}/jobs-count-work"
    mkdir -p "$work"
    fixture_copy "$fx"
    local lib="${fx}/Scripts/lib/common.sh" rc out want bad

    # Auto has to produce a usable width on whatever machine runs this, without
    # the case knowing anything about that machine. The band is the contract.
    out="$(bash -c ". '${lib}'; iosai_resolve_jobs auto" 2>/dev/null || true)"
    if printf '%s' "$out" | grep -Eq '^[1-9][0-9]*$' \
       && [ "$out" -ge 1 ] && [ "$out" -le 8 ]; then
        check pass "auto resolves to a conservative worker count (${out})"
    else
        check fail "auto resolved to '${out}', which is not a width between 1 and 8"
    fi
    out="$(bash -c ". '${lib}'; iosai_resolve_jobs" 2>/dev/null || true)"
    if printf '%s' "$out" | grep -Eq '^[1-9][0-9]*$'; then
        check pass "a missing request resolves like auto (${out})"
    else
        check fail "a missing request resolved to '${out}'"
    fi

    # An explicit width is taken verbatim, so 1 really is serial and a large
    # machine can be asked for more than auto would choose on its own.
    for want in 1 2 4 8 16 64; do
        out="$(bash -c ". '${lib}'; iosai_resolve_jobs ${want}" 2>/dev/null || true)"
        expect_same "$want" "$out" "an explicit width of ${want} is used as given"
    done

    # Anything else is refused rather than coerced. A silently-defaulted width
    # would hide a broken invocation, and this value decides how the suite runs.
    for bad in 0 -1 abc 2.5 08x 65 999 '1 2' ' ' '+3' '1e2' 0x8; do
        rc="$(run_capture "${work}/bad.txt" bash -c ". '${lib}'; iosai_resolve_jobs '${bad}'")"
        out="$(cat "${work}/bad.txt")"
        expect_exit 64 "$rc" "the worker count '${bad}' is refused"
        expect_contains "$out" "worker count" "the refusal of '${bad}' names the problem"
    done

    # The same refusal has to reach the command line, not just the library.
    rc="$(run_capture "${work}/cli.txt" "${fx}/Scripts/self-test.sh" --jobs 0 --case config_parser)"
    expect_exit 64 "$rc" "--jobs 0 is refused before any case runs"
    expect_contains "$(cat "${work}/cli.txt")" "worker count" \
        "--jobs 0 is refused for the stated reason, not for an unmatched case"
    rc="$(run_capture "${work}/cli-empty.txt" "${fx}/Scripts/self-test.sh" --jobs "" --case config_parser)"
    expect_exit 64 "$rc" "an empty --jobs value is refused"
    rc="$(run_capture "${work}/env.txt" env IOSAI_TEST_JOBS=nonsense "${fx}/Scripts/self-test.sh" --case config_parser)"
    expect_exit 64 "$rc" "an unusable IOSAI_TEST_JOBS is refused"
    out="$(cat "${work}/env.txt")"
    expect_contains "$out" "worker count" "the environment refusal names the problem"

    # A knob nobody can find is not configurable. These are the two places a
    # maintainer looks: the script's own help, and the documents about maintaining
    # this template.
    out="$(cd "$fx" && ./Scripts/self-test.sh --help)"
    expect_contains "$out" "--jobs" "the help text documents the width option"
    expect_contains "$out" "IOSAI_TEST_JOBS" "the help text names the environment variable"
    out="$(cat "${fx}/README.md" "${fx}/CLAUDE.md" "${fx}/AI/WORKFLOW.md")"
    expect_contains "$out" "IOSAI_TEST_JOBS=1" \
        "the live documents show how to force serial execution"
    expect_contains "$out" "xargs" "the tool manifest names the tool the pool depends on"
}

case_parallel_scheduler() {
    local fx="${SELFTEST_DIR}/jobs-scheduler"
    local work="${SELFTEST_DIR}/jobs-scheduler-work"
    mkdir -p "$work"
    fixture_copy "$fx"
    local lib="${fx}/Scripts/lib/common.sh" rc out items expected

    # The payload records its own presence in a directory and removes it on the
    # way out, so the widest overlap actually observed can be read afterwards.
    # A count is used rather than elapsed time on purpose: an observed count of K
    # can only happen if K really were running at once, so `observed <= jobs` can
    # never fail spuriously on a slow machine.
    cat > "${work}/payload.sh" <<'PAYLOAD'
#!/usr/bin/env bash
set -euo pipefail
dir="$1"; item="$2"
printf '%s\n' "$item" >> "${dir}/ran"
: > "${dir}/running/${item}"
find "${dir}/running" -type f | wc -l | tr -d ' ' >> "${dir}/observed"
if [ -f "${dir}/rendezvous" ]; then
    waited=0
    while [ "$(find "${dir}/running" -type f | wc -l | tr -d ' ')" -lt 2 ]; do
        if [ "$waited" -ge 600 ]; then
            : > "${dir}/rendezvous-timeout"
            break
        fi
        sleep 0.1
        waited=$((waited + 1))
    done
fi
rm -f "${dir}/running/${item}"
# `a && b && exit` returns 1 under errexit when a is false, which would fail every
# item that is not the planted one.
if [ "$item" = "item03" ] && [ -f "${dir}/should-fail" ]; then
    exit 3
fi
exit 0
PAYLOAD
    chmod +x "${work}/payload.sh"

    items="item01 item02 item03 item04 item05 item06 item07 item08 item09 item10 item11 item12"
    expected="$(printf '%s\n' $items | sort)"

    local jobs peak
    for jobs in 1 4; do
        local d="${work}/run-${jobs}"
        mkdir -p "${d}/running"
        : > "${d}/ran"
        : > "${d}/observed"
        rc="$(run_capture "${work}/run-${jobs}.txt" bash -c \
            ". '${lib}'; printf '%s\n' ${items} | iosai_run_jobs ${jobs} '${work}/payload.sh' '${d}'")"
        expect_exit 0 "$rc" "the pool at ${jobs} worker(s) reports success when every item succeeds"
        expect_same "$expected" "$(sort "${d}/ran")" \
            "every item ran exactly once at ${jobs} worker(s)"
        peak="$(sort -n "${d}/observed" | tail -n1)"
        if [ "${peak:-0}" -le "$jobs" ]; then
            check pass "the pool never exceeded ${jobs} concurrent worker(s) (observed ${peak})"
        else
            check fail "the pool ran ${peak} workers concurrently with a limit of ${jobs}"
        fi
        if [ "$jobs" = "1" ]; then
            expect_same "1" "${peak:-0}" "one worker means strictly serial execution"
        fi
    done

    # Concurrency is not merely permitted, it happens: two items must be able to
    # meet inside the pool. The wait is bounded the way the interrupted-gate case
    # bounds its own, and the assertion is on the rendezvous, not on how long it took.
    local d="${work}/rendezvous"
    mkdir -p "${d}/running"
    : > "${d}/ran"; : > "${d}/observed"; : > "${d}/rendezvous"
    rc="$(run_capture "${work}/rendezvous.txt" bash -c \
        ". '${lib}'; printf '%s\n' item01 item02 | iosai_run_jobs 2 '${work}/payload.sh' '${d}'")"
    expect_exit 0 "$rc" "the rendezvous pool succeeds"
    if [ -f "${d}/rendezvous-timeout" ]; then
        check fail "two items never ran at the same time; the pool is serialising"
    else
        check pass "two items ran concurrently inside the pool"
    fi

    # A failing item must not cancel the rest, or one broken case would hide the
    # verdicts of every case queued behind it.
    d="${work}/failing"
    mkdir -p "${d}/running"
    : > "${d}/ran"; : > "${d}/observed"; : > "${d}/should-fail"
    rc="$(run_capture "${work}/failing.txt" bash -c \
        ". '${lib}'; printf '%s\n' ${items} | iosai_run_jobs 4 '${work}/payload.sh' '${d}'")"
    if [ "$rc" = "0" ]; then
        check fail "the pool reported success although an item failed"
    else
        check pass "the pool reports a failing item (exit ${rc})"
    fi
    expect_same "$expected" "$(sort "${d}/ran")" \
        "a failing item does not stop the items queued behind it"

    # The scheduler refuses a width it cannot honour, rather than guessing one.
    rc="$(run_capture "${work}/nojobs.txt" bash -c \
        ". '${lib}'; printf '%s\n' item01 | iosai_run_jobs 0 /bin/true")"
    expect_exit 64 "$rc" "the pool refuses a zero worker count"
    rc="$(run_capture "${work}/nocmd.txt" bash -c \
        ". '${lib}'; printf '%s\n' item01 | iosai_run_jobs 2")"
    expect_exit 64 "$rc" "the pool refuses to run with no command"
}

case_parallel_case_isolation() {
    local fx="${SELFTEST_DIR}/parallel-isolation"
    local work="${SELFTEST_DIR}/parallel-isolation-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    fixture_synthetic_suite "$fx" || return 0

    local probe="${work}/probe" out rc kept name
    rc="$(run_synthetic "$fx" "$probe" "${work}/run.txt" --jobs 3 --keep)"
    out="$(cat "${work}/run.txt")"
    expect_exit 0 "$rc" "the synthetic suite passes under three workers"

    # Exactly once, established from inside the workers rather than from the
    # driver's own report, so a driver that printed a case it never ran is caught.
    expect_same "$(printf 'alpha\nbeta\ndelta\nepsilon\ngamma\n')" \
        "$(sort "${probe}/ran")" "every selected case ran exactly once"

    # And the report agrees with them, in registry order, with per-case counts.
    expect_same "$(printf 'PASS alpha (2 checks)\nPASS beta (3 checks)\nPASS gamma (1 checks)\nPASS delta (1 checks)\nPASS epsilon (2 checks)\n')" \
        "$(verdict_lines "${work}/run.txt")" \
        "every case is reported once, in registry order, with its own check count"
    expect_contains "$out" "cases: 5   checks passed: 9   failed: 0   workers: 3" \
        "the summary counts every case and check and names the width"

    # No two cases may share a fixture root.
    expect_same "5" "$(awk '{print $2}' "${probe}/dirs" | sort -u | wc -l | tr -d ' ')" \
        "each case received its own fixture root"

    kept="$(printf '%s\n' "$out" | sed -n 's/^fixtures kept: //p' | tail -n1)"
    if [ -z "$kept" ] || [ ! -d "$kept" ]; then
        check fail "the kept fixture root was not reported: '${kept}'"
        return 0
    fi
    # Each case's own marker, and nothing belonging to anyone else, under its root.
    local strays=0
    for name in alpha beta gamma delta epsilon; do
        if [ ! -f "${kept}/${name}/owned-by-${name}" ]; then
            check fail "${name} did not own its fixture root"
        fi
        if [ -n "$(find "${kept}/${name}" -maxdepth 1 -name 'owned-by-*' ! -name "owned-by-${name}" 2>/dev/null)" ]; then
            strays=$((strays + 1))
        fi
    done
    expect_same "0" "$strays" "no case wrote inside another case's fixture root"
    # Every recorded root really is a child of this run's root, so a case cannot
    # have been given a path outside the tree cleanup owns.
    local outside=0 dir
    for dir in $(awk '{print $2}' "${probe}/dirs"); do
        case "$dir" in
            "${kept}"/*) : ;;
            *) outside=$((outside + 1)) ;;
        esac
    done
    expect_same "0" "$outside" "every case fixture lives under this run's own root"

    # The driver never exceeds the width it was given. A count can only
    # over-report if that many cases really were running, so this cannot fail on a
    # slow machine — and no assertion here is made about elapsed time.
    local widest
    widest="$(cat "${probe}"/observed-* 2>/dev/null | sort -n | tail -n1)"
    if [ "${widest:-0}" -le 3 ]; then
        check pass "the driver ran at most the three workers it was given (observed ${widest})"
    else
        check fail "the driver ran ${widest} cases at once with a width of three"
    fi

    # The kept root is the nested run's own, and `mktemp -t` puts it beside this
    # one rather than inside it, so removing it is this case's job. Guarded, because
    # a mis-parsed path is not a licence to delete something else.
    case "$kept" in
        */iosai-selftest.*) rm -rf -- "$kept" ;;
        *) check fail "refusing to remove an unexpected kept root: ${kept}" ;;
    esac

    # The serial lane: a case named in it must run with nothing else running. The
    # lane is exercised against a synthetic case here; in the real suite it holds
    # status_scratch_cleanup, whose assertion counts a shared temporary namespace.
    local serial_probe="${work}/probe-serial"
    rc="$(IOSAI_SELFTEST_SERIAL_CASES=delta \
        run_synthetic "$fx" "$serial_probe" "${work}/serial-lane.txt" --jobs 4)"
    expect_exit 0 "$rc" "the suite passes with a case held in the serial lane"
    expect_same "$(printf 'alpha\nbeta\ndelta\nepsilon\ngamma\n')" \
        "$(sort "${serial_probe}/ran")" "the serial lane still runs every case exactly once"
    expect_same "1" "$(cat "${serial_probe}/observed-delta")" \
        "a case in the serial lane runs with nothing else running"
    widest="$(cat "${serial_probe}"/observed-* 2>/dev/null | sort -n | tail -n1)"
    if [ "${widest:-0}" -le 4 ]; then
        check pass "the width is still honoured with a case held serial (observed ${widest})"
    else
        check fail "the serial lane let ${widest} cases run at once with a width of four"
    fi
}

case_parallel_failure_surfaced() {
    local fx="${SELFTEST_DIR}/parallel-failure"
    local work="${SELFTEST_DIR}/parallel-failure-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    fixture_synthetic_suite "$fx" || return 0

    local probe="${work}/probe" out rc
    rc="$(SELFTEST_PLANT_FAILURE=gamma run_synthetic "$fx" "$probe" "${work}/run.txt" --jobs 3)"
    out="$(cat "${work}/run.txt")"
    expect_exit 65 "$rc" "one failing case fails the whole suite"
    expect_contains "$out" "FAIL gamma" "the failing case is named"
    expect_contains "$out" "planted defect visible in gamma" \
        "the failing worker's own output is reproduced by the driver"
    expect_contains "$out" "planted gate output for gamma" \
        "a failed check reprints the end of the case's last captured gate output"
    expect_contains "$out" "self-test FAILED in: gamma" "the summary names the failing case"
    expect_contains "$out" "checks passed: 8   failed: 1" \
        "the summary counts the failed check and keeps the passed ones"
    expect_contains "$out" "cases: 5" "a failure does not reduce the number of cases run"
    expect_contains "$out" "PASS alpha" "the other cases still report their own verdict"
    expect_same "$(printf 'alpha\nbeta\ndelta\nepsilon\ngamma\n')" \
        "$(sort "${probe}/ran")" "a failing case does not stop the rest of the suite"

    # A passing case's detail is not reprinted; a failing case's is. Otherwise the
    # concise report would bury the one thing worth reading.
    expect_absent "$out" "alpha ran a second check" \
        "a passing case's detail stays out of the report"

    # A worker that dies without writing a result is the case the whole reporting
    # design exists for: nothing failed an assertion, so there is no failure to
    # find unless the driver treats silence as a failure by itself.
    local abort_out
    rc="$(SELFTEST_PLANT_ABORT=beta \
        run_synthetic "$fx" "${work}/probe-abort" "${work}/abort.txt" --jobs 3)"
    abort_out="$(cat "${work}/abort.txt")"
    expect_exit 65 "$rc" "a worker that dies without reporting fails the suite"
    expect_contains "$abort_out" "FAIL beta" "the silent case is named"
    expect_contains "$abort_out" "produced no result" \
        "the driver states that the worker never reported"
    expect_contains "$abort_out" "a case that did not report is a failure, never a pass" \
        "the driver says why silence is not a pass"
    expect_contains "$abort_out" "worker pool exited with status" \
        "the pool's own nonzero status is reported as well"
    expect_contains "$abort_out" "PASS alpha" "the surviving cases still report their verdicts"
    expect_contains "$abort_out" "cases: 5" "the silent case is still counted as run"
}

case_parallel_serial_equivalence() {
    local fx="${SELFTEST_DIR}/parallel-equivalence"
    local work="${SELFTEST_DIR}/parallel-equivalence-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    fixture_synthetic_suite "$fx" || return 0

    # The same defect, at one worker and at four. Verdict, per-case outcomes and
    # every count must match: if they can differ, the width has become part of the
    # answer, and "the suite passed" would depend on the machine that ran it.
    local rc_serial rc_parallel serial parallel
    rc_serial="$(SELFTEST_PLANT_FAILURE=delta \
        run_synthetic "$fx" "${work}/probe-serial" "${work}/serial.txt" --jobs 1)"
    rc_parallel="$(SELFTEST_PLANT_FAILURE=delta \
        run_synthetic "$fx" "${work}/probe-parallel" "${work}/parallel.txt" --jobs 4)"

    expect_exit 65 "$rc_serial" "the defect fails the suite at one worker"
    expect_same "$rc_serial" "$rc_parallel" "the exit code does not depend on the width"
    expect_same "$(verdict_lines "${work}/serial.txt")" "$(verdict_lines "${work}/parallel.txt")" \
        "the ordered per-case verdicts do not depend on the width"

    # The width itself is reported, and is the only field allowed to differ.
    serial="$(sed -n 's/^\(cases: .*failed: [0-9]*\).*/\1/p' "${work}/serial.txt" | tail -n1)"
    parallel="$(sed -n 's/^\(cases: .*failed: [0-9]*\).*/\1/p' "${work}/parallel.txt" | tail -n1)"
    expect_same "$serial" "$parallel" "the case and check totals do not depend on the width"
    if [ -z "$serial" ]; then
        check fail "no summary totals were found to compare"
    else
        check pass "the compared totals were actually present (${serial})"
    fi
    expect_contains "$(cat "${work}/serial.txt")" "workers: 1" "the serial run reports its width"
    expect_contains "$(cat "${work}/parallel.txt")" "workers: 4" "the parallel run reports its width"

    # And a clean run agrees with itself the same way.
    local clean_serial clean_parallel
    clean_serial="$(run_synthetic "$fx" "${work}/probe-cs" "${work}/clean-serial.txt" --jobs 1)"
    clean_parallel="$(run_synthetic "$fx" "${work}/probe-cp" "${work}/clean-parallel.txt" --jobs 4)"
    expect_exit 0 "$clean_serial" "a clean suite passes at one worker"
    expect_exit 0 "$clean_parallel" "a clean suite passes at four workers"
    expect_same "$(verdict_lines "${work}/clean-serial.txt")" \
        "$(verdict_lines "${work}/clean-parallel.txt")" \
        "a clean run reports the same verdicts at either width"
}

case_parallel_cleanup_confined() {
    local fx="${SELFTEST_DIR}/parallel-cleanup"
    local work="${SELFTEST_DIR}/parallel-cleanup-work"
    mkdir -p "$work"
    fixture_template "$fx" "$work"
    fixture_synthetic_suite "$fx" || return 0

    # A sentinel beside where the run will put its root, and one inside the
    # fixture. Neither belongs to the run, so neither may be touched.
    local sentinel="${work}/sentinel"
    mkdir -p "${sentinel}/nested"
    printf 'keep me\n' > "${sentinel}/nested/data.txt"
    printf 'fixture\n' > "${fx}/.sentinel"

    local out rc kept planted
    rc="$(SELFTEST_PLANT_CACHE=alpha run_synthetic "$fx" "${work}/probe" "${work}/run.txt" --jobs 2)"
    out="$(cat "${work}/run.txt")"
    expect_exit 0 "$rc" "the synthetic suite passes under two workers"
    kept="$(printf '%s\n' "$out" | sed -n 's/^  fixtures: //p' | tail -n1)"
    if [ -n "$kept" ] && [ -e "$kept" ]; then
        check fail "a completed run left its temporary root behind: ${kept}"
    else
        check pass "a completed run removes its own temporary root"
    fi

    # The build cache a gate makes for a fixture lives outside the temporary root, at
    # the checkout-keyed /private/tmp location the gates trust, so removing the root
    # alone left one behind for every fixture. alpha planted one through the library.
    planted="$(cat "${work}/probe/cache-root" 2>/dev/null || true)"
    case "$planted" in
        /private/tmp/*-*)
            check pass "a synthetic case created a fixture build-cache root to clean up"
            if [ -e "$planted" ]; then
                check fail "a completed run left a fixture's build-cache root behind: ${planted}"
            else
                check pass "a completed run removes the build-cache roots of its fixtures"
            fi ;;
        *)
            check fail "the synthetic case planted no build-cache root; the cleanup check proves nothing" ;;
    esac
    expect_same "keep me" "$(cat "${sentinel}/nested/data.txt")" \
        "a neighbouring directory is untouched by a parallel run"
    expect_same "fixture" "$(cat "${fx}/.sentinel")" "the fixture itself is untouched"

    # An interrupted run has workers to stop as well as a tree to remove. A case
    # that parks lets the interrupt land inside the window that matters.
    awk '
        /^case_delta\(\) \{/ {
            print "case_delta() { _probe delta; sleep 120; _plant delta; }"
            next
        }
        { print }
    ' "${fx}/Scripts/self-test.sh" > "${fx}/Scripts/self-test.sh.new"
    mv "${fx}/Scripts/self-test.sh.new" "${fx}/Scripts/self-test.sh"
    chmod +x "${fx}/Scripts/self-test.sh"
    grep -q 'sleep 120; _plant delta' "${fx}/Scripts/self-test.sh" \
        || { check fail "the parking case was not installed"; return 0; }

    mkdir -p "${work}/probe-term"
    SELFTEST_PROBE_DIR="${work}/probe-term" "${fx}/Scripts/self-test.sh" --jobs 3 \
        >"${work}/term.txt" 2>&1 &
    local runner=$! waited=0 root=""
    while [ "$waited" -lt 120 ]; do
        root="$(sed -n 's/^  fixtures: //p' "${work}/term.txt" 2>/dev/null | tail -n1)"
        [ -n "$root" ] && [ -d "$root" ] && break
        kill -0 "$runner" 2>/dev/null || break
        sleep 1
        waited=$((waited + 1))
    done
    if [ -z "$root" ] || [ ! -d "$root" ]; then
        check fail "the interrupted run never reported a temporary root to check"
        kill -TERM "$runner" 2>/dev/null || true
        wait "$runner" 2>/dev/null || true
        return 0
    fi
    check pass "the run materialised a temporary root at ${root##*/}"

    kill -TERM "$runner" 2>/dev/null || true
    wait "$runner" 2>/dev/null || true
    waited=0
    while [ -e "$root" ] && [ "$waited" -lt 30 ]; do
        sleep 1
        waited=$((waited + 1))
    done
    if [ -e "$root" ]; then
        check fail "an interrupted parallel run left its temporary root behind: ${root}"
    else
        check pass "an interrupted parallel run removes its own temporary root"
    fi
    expect_same "keep me" "$(cat "${sentinel}/nested/data.txt")" \
        "an interrupted parallel run does not reach a neighbouring directory"
    expect_same "fixture" "$(cat "${fx}/.sentinel")" \
        "an interrupted parallel run does not reach the fixture"
    # And the worker processes are gone with it: a run whose tree was removed while
    # its workers kept going would be the way a cancelled run corrupts the next one.
    if [ -n "$(find "$(dirname -- "$root")" -maxdepth 1 -name "$(basename -- "$root")" 2>/dev/null)" ]; then
        check fail "the interrupted run's root reappeared, so a worker outlived the cleanup"
    else
        check pass "no worker outlived the cleanup to recreate the removed root"
    fi
}

# ---------------------------------------------------------------------------
# Driver
#
# Two modes, one code path per case. The parent selects cases, dispatches them to
# a bounded pool of workers, and reports; a worker runs exactly one case in its
# own process and writes what it found to a file. Every count in the summary is
# read back from those files, so the verdict is a function of the cases alone and
# not of how many ran at once.
# ---------------------------------------------------------------------------

# case_in_registry <name> — exact membership, so a worker cannot be pointed at a
# function this suite does not own.
case_in_registry() {
    local want="$1" name
    for name in $CASES; do
        [ "$name" = "$want" ] && return 0
    done
    return 1
}

if [ -n "$opt_run_one" ]; then
    # --- worker mode -------------------------------------------------------
    # This process creates no temporary root and installs no cleanup trap. The
    # parent owns the root and is the only thing that removes it; a worker owns
    # exactly one subtree of it and deletes nothing at all. That split is what
    # keeps an interrupted parallel run from destroying another case's fixture.
    [ -n "$opt_root" ] || die "$EX_USAGE" "--run-one requires --root"
    [ -d "$opt_root" ] || die "$EX_USAGE" "--run-one root does not exist: ${opt_root}"
    case_in_registry "$opt_run_one" || die "$EX_USAGE" "unknown case: ${opt_run_one}"

    # One case, one private subtree, named after the case. Fixture paths were
    # already disjoint by convention across the whole suite; pointing SELFTEST_DIR
    # at a per-case root makes them disjoint by construction, with no change to any
    # case body.
    #
    # TMPDIR is deliberately NOT redirected. On macOS `mktemp -t` resolves the
    # per-user Darwin temporary directory and ignores TMPDIR, so a private value
    # would not actually move the `mktemp -t` namespace that project-status.sh and
    # the candidate-snapshot helper use — it would only hide that namespace from
    # the one case whose whole purpose is to count it. Cases that observe shared
    # temporary state are run alone instead; see IOSAI_SELFTEST_SERIAL_CASES.
    SELFTEST_DIR="${opt_root}/${opt_run_one}"
    mkdir -p "$SELFTEST_DIR" "${opt_root}/.results"

    _result="${opt_root}/.results/${opt_run_one}.result"
    if [ "$opt_stream" != "yes" ]; then
        exec >"${opt_root}/.results/${opt_run_one}.output" 2>&1
    fi
    printf '%s==>%s %s\n' "${_C_BLUE}${_C_BOLD}" "$_C_RESET" "$opt_run_one"

    CURRENT_CASE="$opt_run_one"
    # A case that dies takes its own failure with it rather than the whole suite.
    # The `if !` condition context is also what suppresses errexit inside the case
    # body; calling the function any other way would abort a case at its first
    # nonzero command.
    if ! "case_${opt_run_one}"; then
        check fail "the case itself errored"
    fi

    _status=pass
    [ "$CHECKS_FAILED" -eq 0 ] || _status=fail
    # Renamed into place so the parent can never read a half-written result.
    printf '%s %s %s\n' "$_status" "$CHECKS_PASSED" "$CHECKS_FAILED" > "${_result}.tmp"
    mv -f "${_result}.tmp" "$_result"
    # A worker reports a failing case through its result file and still exits 0.
    # Reserving a nonzero exit for a malfunctioning worker is what lets the parent
    # tell "this case failed" apart from "this case never reported".
    exit 0
fi

# --- parent mode -----------------------------------------------------------
JOBS="$(iosai_resolve_jobs "${opt_jobs:-${IOSAI_TEST_JOBS:-auto}}")"

SELFTEST_ROOT="$(mktemp -d -t iosai-selftest)"
RESULT_DIR="${SELFTEST_ROOT}/.results"
mkdir -p "$RESULT_DIR"
trap cleanup EXIT
trap '_selftest_signal_cleanup INT'  INT
trap '_selftest_signal_cleanup TERM' TERM
trap '_selftest_signal_cleanup HUP'  HUP

# Selection is registry order, and the filter is a substring match, exactly as
# before. Reporting walks this same list, so output order never depends on the
# order work happened to finish in.
SELECTED=""
for name in $CASES; do
    if [ -n "$opt_case" ]; then
        case "$name" in
            *"$opt_case"*) : ;;
            *) continue ;;
        esac
    fi
    SELECTED="${SELECTED}${name} "
done
if [ -z "$SELECTED" ]; then
    log_error "no cases matched '${opt_case}'"
    hint "list them with: ./Scripts/self-test.sh --list"
    exit "$EX_USAGE"
fi

log_step "Self-test: the template's own regression suite"
log_info "  fixtures: ${SELFTEST_ROOT}"
log_info "  workers:  ${JOBS}   (IOSAI_TEST_JOBS=1 runs serially with live output)"
log_info "  xcodebuild and xcresulttool are stubbed; no real build is claimed."
printf '\n'

# order_by_cost <name...> — the given names, heaviest first.
#
# Dispatch order is a performance hint and carries no meaning: results are read,
# counted and printed in registry order, so nothing about it can change a verdict.
# Heaviest first, because one long case dispatched last stretches the run well past
# the point where every other worker has gone idle.
#
# The weight is recomputed from this file on every run. A hardcoded duration table
# would go stale the first time a case changed, and a stale table is worse than a
# rough one. The list of NAMES, though, comes from the caller and never from the
# function definitions here: a `case_x() {` line also appears inside the heredoc
# that installs the synthetic suite, so scanning for definitions would dispatch
# such a case twice. Definitions are read only to accumulate a weight.
#
# The names reach awk through a file rather than a `case` pattern inside a command
# substitution: Bash 3.2 mis-parses the `)` in such a pattern there, the same quirk
# the documentation-consistency case works around further up this file.
order_by_cost() {
    printf '%s\n' "$@" > "${RESULT_DIR}/.order-in"
    awk -v names="${RESULT_DIR}/.order-in" '
        BEGIN {
            while ((getline line < names) > 0) { order[++n] = line; weight[line] = 0 }
            close(names)
        }
        /^case_[a-z0-9_]+\(\) \{/ {
            name = $1; sub(/\(\).*/, "", name); sub(/^case_/, "", name)
            current = (name in weight) ? name : ""
            next
        }
        current != "" && /fixture_(copy|product|template|milestone|integration|release)|run_capture/ {
            weight[current]++
        }
        END { for (i = 1; i <= n; i++) printf "%06d %s\n", weight[order[i]], order[i] }
    ' "$SELF" | sort -r | awk '{ print $2 }'
}

# Cases that may not run beside anything else.
#
# status_scratch_cleanup proves that project-status.sh leaves no scratch directory
# behind, and it proves it by counting `iosai-status*` entries in the temporary
# directory before and after its own runs. That namespace is unavoidably shared:
# macOS `mktemp -t` ignores TMPDIR, so the case cannot be given a private one, and
# any sibling running `project-status.sh next` or `summary` would move the count
# underneath it. Running it alone keeps the assertion exact. Narrowing what it
# counts would have made the suite faster by making one check weaker, which is the
# one trade this change does not make.
#
# Overridable so the driver's own regression cases can exercise the serial lane
# against a synthetic case instead of a minute-long real one.
#
# simulator_isolation and simulator_leases are in the lane for the same reason. The
# lease helper keeps one registry per user under /private/tmp, shared by every
# checkout on the machine, and validates every entry on every call, so a sibling
# case holding or abandoning a lease is state these two would observe.
IOSAI_SELFTEST_SERIAL_CASES="${IOSAI_SELFTEST_SERIAL_CASES:-status_scratch_cleanup simulator_isolation simulator_leases}"

PARALLEL_CASES=""
SERIAL_CASES=""
for name in $SELECTED; do
    if token_in_list "$name" "$IOSAI_SELFTEST_SERIAL_CASES"; then
        SERIAL_CASES="${SERIAL_CASES}${name} "
    else
        PARALLEL_CASES="${PARALLEL_CASES}${name} "
    fi
done

DISPATCH=""
if [ -n "$PARALLEL_CASES" ] && [ "$JOBS" -eq 1 ]; then
    # One worker: registry order, so each case's streamed checks sit directly under
    # its own heading and its verdict line follows immediately. That readability is
    # the entire reason to run serially, and cost ordering buys nothing here — there
    # is no second worker that could go idle waiting for a long case.
    DISPATCH="$PARALLEL_CASES"
elif [ -n "$PARALLEL_CASES" ]; then
    DISPATCH="$(order_by_cost $PARALLEL_CASES)"
fi

STREAM_ARGS=()
# One worker means nothing to interleave, so the case writes straight to the
# terminal. That keeps `IOSAI_TEST_JOBS=1` useful for watching a case that hangs,
# without a second execution path: the verdict still comes from the result file.
[ "$JOBS" -eq 1 ] && STREAM_ARGS=(--stream)

# The pool runs in the background and publishes its own status through a file.
# The parent needs to know "no further results are coming" without depending on
# when Bash happens to reap a background child, and a renamed sentinel answers
# that regardless of reaping.
#
# `set -m` is what makes the pool its own process group, so cleanup can stop the
# whole tree of workers with one signal instead of orphaning xargs and its
# children. It is switched back off immediately: the parent wants no job control
# of its own.
set -m
{
    pool_rc=0
    # `|| pool_rc=$?` and not a bare pipeline: under errexit a failing pool would
    # take this subshell down before it published anything, and the parent would
    # then report "no status" for every run in which a worker died — turning the
    # most important case into the least informative one.
    if [ -n "$DISPATCH" ]; then
        printf '%s\n' $DISPATCH | iosai_run_jobs "$JOBS" \
            "$SELF" --root "$SELFTEST_ROOT" \
            ${STREAM_ARGS[@]+"${STREAM_ARGS[@]}"} --run-one || pool_rc=$?
    fi
    # The serial lane runs after the pool has drained, so a case in it is alone on
    # the machine — which is the whole reason it is in the lane.
    if [ -n "$SERIAL_CASES" ]; then
        printf '%s\n' $SERIAL_CASES | iosai_run_jobs 1 \
            "$SELF" --root "$SELFTEST_ROOT" \
            ${STREAM_ARGS[@]+"${STREAM_ARGS[@]}"} --run-one || pool_rc=$?
    fi
    printf '%s\n' "$pool_rc" > "${RESULT_DIR}/.pool.tmp"
    mv -f "${RESULT_DIR}/.pool.tmp" "${RESULT_DIR}/.pool"
} &
POOL_PID=$!
set +m

# count_failure <case> <reason> — a harness malfunction recorded the same way a
# failed assertion is, so scheduling cannot make one disappear.
count_failure() {
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    case "$FAILED_CASES" in
        *"$1 "*) : ;;
        *) FAILED_CASES="${FAILED_CASES}$1 " ;;
    esac
    printf '%sFAIL%s %s\n' "$_C_RED" "$_C_RESET" "$1"
    log_error "$2"
}

for name in $SELECTED; do
    result="${RESULT_DIR}/${name}.result"
    while [ ! -f "$result" ]; do
        if [ -f "${RESULT_DIR}/.pool" ]; then
            # The pool has finished. One more look closes the race between a
            # worker's final rename and the pool's own exit, then stop waiting:
            # no further result can arrive.
            sleep 0.2
            break
        fi
        sleep 0.2
    done
    CASES_RUN=$((CASES_RUN + 1))

    if [ ! -f "$result" ]; then
        count_failure "$name" "${name}: the worker produced no result"
        hint "a case that did not report is a failure, never a pass"
        continue
    fi
    status=""; passed=""; failed=""
    read -r status passed failed < "$result" || true
    if ! printf '%s' "$passed" | grep -Eq '^[0-9]+$' \
       || ! printf '%s' "$failed" | grep -Eq '^[0-9]+$' \
       || { [ "$status" != "pass" ] && [ "$status" != "fail" ]; }; then
        count_failure "$name" "${name}: unreadable result from the worker"
        continue
    fi

    CHECKS_PASSED=$((CHECKS_PASSED + passed))
    if [ "$failed" -gt 0 ] || [ "$status" = "fail" ]; then
        CHECKS_FAILED=$((CHECKS_FAILED + failed))
        case "$FAILED_CASES" in
            *"$name "*) : ;;
            *) FAILED_CASES="${FAILED_CASES}${name} " ;;
        esac
        printf '%sFAIL%s %s\n' "$_C_RED" "$_C_RESET" "$name"
        # The detail is the point of a failure, so it is reprinted here rather
        # than left in a temporary directory the run is about to remove.
        if [ -f "${RESULT_DIR}/${name}.output" ]; then
            sed 's/^/    /' "${RESULT_DIR}/${name}.output"
        fi
    else
        printf '%sPASS%s %s (%s checks)\n' "$_C_GREEN" "$_C_RESET" "$name" "$passed"
    fi
done

wait "$POOL_PID" 2>/dev/null || true
# Cleared so the EXIT trap cannot signal a process group this PID has since been
# recycled into. There is nothing left to stop on the normal path.
POOL_PID=""

# Exactly once: a result belonging to a case that was not selected means dispatch
# and reporting disagreed, and a case could then run without being reported on.
for result in "${RESULT_DIR}"/*.result; do
    [ -e "$result" ] || continue
    name="$(basename -- "$result")"
    name="${name%.result}"
    case " ${SELECTED} " in
        *" ${name} "*) : ;;
        *) count_failure "$name" "a case ran that was not selected: ${name}" ;;
    esac
done

pool_status="$(cat "${RESULT_DIR}/.pool" 2>/dev/null || printf 'missing')"
if [ "$pool_status" != "0" ]; then
    # Workers exit 0 even for a failing case, so this means a worker died instead
    # of reporting. Any missing result has been counted already; this makes the
    # malfunction itself visible rather than leaving it to be inferred.
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    log_error "the worker pool exited with status ${pool_status}"
fi

printf '\n'
log_info "cases: ${CASES_RUN}   checks passed: ${CHECKS_PASSED}   failed: ${CHECKS_FAILED}   workers: ${JOBS}"
if [ "$CHECKS_FAILED" -gt 0 ]; then
    log_error "self-test FAILED in: ${FAILED_CASES}"
    hint "re-run one case with: ./Scripts/self-test.sh --case <name> --keep"
    hint "reproduce it serially with: IOSAI_TEST_JOBS=1 ./Scripts/self-test.sh --case <name>"
    exit "$EX_VERIFY"
fi
log_ok "self-test PASSED — every regression case behaved as required"
log_info ""
log_info "What this does NOT establish: that a real xcodebuild, a real simulator, or a"
log_info "genuine .xcresult bundle behaves as the stubs do. No Xcode ran here."
