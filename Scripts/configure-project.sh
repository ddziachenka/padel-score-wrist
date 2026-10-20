#!/usr/bin/env bash
# configure-project.sh — create or update Config/project.env.
#
# Validates as it writes: exactly one project container, the container exists,
# and the repository is switched from template mode to product mode.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/configure-project.sh [options]

Creates or updates Config/project.env for this repository.

Project container (exactly one is required):
  --project PATH              path to a .xcodeproj, e.g. App/YourApp.xcodeproj
  --workspace PATH            path to a .xcworkspace, e.g. App/YourApp.xcworkspace

Commonly used:
  --platform PLATFORM         iOS (default) or watchOS (Watch-only)
  --scheme NAME               shared scheme every gate builds and tests
  --name NAME                 human-readable product name
  --bundle-id ID              application bundle identifier
  --build-destination SPEC    xcodebuild -destination used for builds
  --simulator-mode MODE      managed (product default) or explicit
  --simulator-device-type ID installed CoreSimulator device type identifier
  --simulator-runtime ID     pinned installed platform runtime identifier
  --test-destination SPEC     xcodebuild -destination used for tests
  --app-target NAME           application target, when the scheme has several

Optional:
  --configuration-debug NAME    default: Debug
  --configuration-release NAME  default: Release
  --fast-test-args ARGS         extra args for verify-fast.sh
  --milestone-test-args ARGS    extra args for verify-milestone.sh
  --release-test-args ARGS      extra args for verify-release.sh (no -only-testing)
  --derived-data PATH           override the computed DerivedData location
  --distribution CHANNEL        app-store (default) or internal. Decides which
                                final audit coverage applies.
  --site-url URL                origin of the published legal and support site,
                                https, no trailing slash. Its first host label is
                                the Cloudflare Pages project name.
                                e.g. https://yourapp.pages.dev
  --support-email ADDRESS       address shown on the privacy and support pages
  --developer-name NAME         developer published in the site footer
  --enable-swiftlint            set ENABLE_SWIFTLINT="true"
  --enable-swiftformat          set ENABLE_SWIFTFORMAT="true"
  --enable-shellcheck           set ENABLE_SHELLCHECK="true"
  --template-mode               write a template-mode config (no product keys)

Behaviour:
  --force                     overwrite an existing PRODUCT configuration.
                              A template-mode configuration holds no product
                              settings, so it is replaced without --force.
  --print                     show the resolved configuration and exit
  -h, --help                  this message

Examples:
  ./Scripts/configure-project.sh \
      --project App/YourApp.xcodeproj \
      --scheme YourApp \
      --name "Your App" \
      --bundle-id com.example.yourapp \
      --simulator-device-type com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro \
      --simulator-runtime com.apple.CoreSimulator.SimRuntime.iOS-26-5
  make simulator-setup

  # Replace the example identifiers with ones installed on this machine:
  xcrun simctl list -j
EOF
}

# --- defaults ---------------------------------------------------------------
opt_platform="iOS"
opt_project=""
opt_workspace=""
opt_scheme=""
opt_name=""
opt_bundle_id=""
opt_app_target=""
opt_config_debug="Debug"
opt_config_release="Release"
opt_build_dest=""
opt_test_dest=""
opt_fast_args=""
opt_milestone_args=""
opt_release_args=""
opt_derived=""
opt_distribution="app-store"
opt_site_url=""
opt_support_email=""
opt_developer_name=""
opt_swiftlint="false"
opt_swiftformat="false"
opt_shellcheck="false"
opt_template_mode="false"
opt_simulator_mode=""
opt_simulator_type=""
opt_simulator_runtime=""
opt_force="no"
opt_print="no"

need_value() {
    [ "$2" -gt 0 ] || die "$EX_USAGE" "$1 requires a value"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --platform)             need_value "$1" $(($# - 1)); opt_platform="$2"; shift 2 ;;
        --project)              need_value "$1" $(($# - 1)); opt_project="$2"; shift 2 ;;
        --workspace)            need_value "$1" $(($# - 1)); opt_workspace="$2"; shift 2 ;;
        --scheme)               need_value "$1" $(($# - 1)); opt_scheme="$2"; shift 2 ;;
        --name)                 need_value "$1" $(($# - 1)); opt_name="$2"; shift 2 ;;
        --bundle-id)            need_value "$1" $(($# - 1)); opt_bundle_id="$2"; shift 2 ;;
        --app-target)           need_value "$1" $(($# - 1)); opt_app_target="$2"; shift 2 ;;
        --configuration-debug)  need_value "$1" $(($# - 1)); opt_config_debug="$2"; shift 2 ;;
        --configuration-release) need_value "$1" $(($# - 1)); opt_config_release="$2"; shift 2 ;;
        --build-destination)    need_value "$1" $(($# - 1)); opt_build_dest="$2"; shift 2 ;;
        --test-destination)     need_value "$1" $(($# - 1)); opt_test_dest="$2"; shift 2 ;;
        --simulator-mode) need_value "$1" $(($# - 1)); opt_simulator_mode="$2"; shift 2 ;;
        --simulator-device-type) need_value "$1" $(($# - 1)); opt_simulator_type="$2"; shift 2 ;;
        --simulator-runtime) need_value "$1" $(($# - 1)); opt_simulator_runtime="$2"; shift 2 ;;
        --fast-test-args)       need_value "$1" $(($# - 1)); opt_fast_args="$2"; shift 2 ;;
        --milestone-test-args)  need_value "$1" $(($# - 1)); opt_milestone_args="$2"; shift 2 ;;
        --release-test-args)    need_value "$1" $(($# - 1)); opt_release_args="$2"; shift 2 ;;
        --derived-data)         need_value "$1" $(($# - 1)); opt_derived="$2"; shift 2 ;;
        --distribution)         need_value "$1" $(($# - 1)); opt_distribution="$2"; shift 2 ;;
        --site-url)             need_value "$1" $(($# - 1)); opt_site_url="$2"; shift 2 ;;
        --support-email)        need_value "$1" $(($# - 1)); opt_support_email="$2"; shift 2 ;;
        --developer-name)       need_value "$1" $(($# - 1)); opt_developer_name="$2"; shift 2 ;;
        --enable-swiftlint)     opt_swiftlint="true"; shift ;;
        --enable-swiftformat)   opt_swiftformat="true"; shift ;;
        --enable-shellcheck)    opt_shellcheck="true"; shift ;;
        --template-mode)        opt_template_mode="true"; shift ;;
        --force)                opt_force="yes"; shift ;;
        --print)                opt_print="yes"; shift ;;
        -h|--help)              usage; exit 0 ;;
        *)  log_error "unknown argument: $1"
            hint "run ./Scripts/configure-project.sh --help"
            exit "$EX_USAGE" ;;
    esac
done

# --- validate ---------------------------------------------------------------
container_count=0
[ -n "$opt_project" ]   && container_count=$((container_count + 1))
[ -n "$opt_workspace" ] && container_count=$((container_count + 1))

if [ "$opt_template_mode" = "true" ]; then
    if [ "$container_count" -gt 0 ]; then
        log_error "--template-mode cannot be combined with --project or --workspace"
        hint "a repository is either the universal template or a product, never both"
        exit "$EX_USAGE"
    fi
else
    if [ "$container_count" -eq 0 ]; then
        log_error "exactly one of --project or --workspace is required"
        hint "for the universal template repository (no app target) use --template-mode"
        exit "$EX_USAGE"
    fi
    if [ "$container_count" -gt 1 ]; then
        log_error "--project and --workspace are mutually exclusive"
        hint "use --workspace only when a .xcworkspace is what Xcode opens"
        exit "$EX_USAGE"
    fi

    container_rel="${opt_project:-$opt_workspace}"
    validate_project_container_path "$container_rel"
    container_abs="$(abs_path "$container_rel")"
    case "$container_rel" in
        *.xcodeproj)
            [ -n "$opt_project" ] || die "$EX_USAGE" "a .xcodeproj must be passed with --project" ;;
        *.xcworkspace)
            [ -n "$opt_workspace" ] || die "$EX_USAGE" "a .xcworkspace must be passed with --workspace" ;;
        *)
            log_error "not an Xcode project or workspace: ${container_rel}"
            hint "expected a path ending in .xcodeproj or .xcworkspace"
            exit "$EX_USAGE" ;;
    esac

    if [ -z "$opt_scheme" ]; then
        log_error "--scheme is required"
        hint "list shared schemes with:"
        if [ -n "$opt_project" ]; then
            hint "  xcodebuild -list -project $(shell_quote "$container_rel")"
        else
            hint "  xcodebuild -list -workspace $(shell_quote "$container_rel")"
        fi
        exit "$EX_USAGE"
    fi
    validate_build_defining_references "$container_abs"

    if [ "$opt_config_debug" = "$opt_config_release" ]; then
        log_error "--configuration-debug and --configuration-release must be distinct"
        hint "both resolve to: ${opt_config_debug}"
        hint "a release gate must build a shipping configuration, not Debug twice"
        exit "$EX_USAGE"
    fi
fi

case "$opt_distribution" in
    app-store|internal) : ;;
    *)  log_error "--distribution must be app-store or internal, got: ${opt_distribution}"
        hint "app-store: submitted to the App Store, every store requirement applies"
        hint "internal:  enterprise or ad-hoc internal distribution"
        exit "$EX_USAGE" ;;
esac

# Site values are validated before anything is written, for the same reason the
# test arguments below are: a bad value never reaches the file, so a rejected run
# leaves the existing configuration exactly as it was. Empty stays legal — these
# are filled in by the Legal and Support milestone, not at M00.
if [ -n "$opt_site_url" ]; then
    validate_support_site_url "$opt_site_url" || exit "$EX_USAGE"
fi
if [ -n "$opt_support_email" ]; then
    validate_support_email "$opt_support_email" || exit "$EX_USAGE"
fi

# Anything that could narrow the release suite would defeat the gate, so it is
# refused here as well as at gate time — a bad value never reaches the file.
if [ -n "$opt_release_args" ]; then
    split_args "$opt_release_args"
    assert_test_args_allowed "RELEASE_TEST_ARGUMENTS" ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}
fi

# Milestone arguments may narrow the suite, so the allowlist above does not apply —
# but one that retries or repeats a failing test would make the milestone gate's
# counts describe a rerun, so it never reaches the file either.
if [ -n "$opt_milestone_args" ]; then
    split_args "$opt_milestone_args"
    assert_test_args_report_failures "MILESTONE_TEST_ARGUMENTS" ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}
fi

if [ -n "$opt_derived" ]; then
    validate_derived_data_path "$opt_derived" || exit "$EX_USAGE"
fi

if [ -z "$opt_simulator_mode" ]; then
    opt_simulator_mode=managed
    [ "$opt_template_mode" != true ] || opt_simulator_mode=explicit
fi
APP_PLATFORM="$opt_platform"
BUILD_DESTINATION="$opt_build_dest"
TEST_DESTINATION="$opt_test_dest"
SIMULATOR_MODE="$opt_simulator_mode"
SIMULATOR_DEVICE_TYPE="$opt_simulator_type"
SIMULATOR_RUNTIME="$opt_simulator_runtime"
platform_config_validate
simulator_config_validate

# --- overwrite protection ---------------------------------------------------
# A template-mode config holds no product settings, so replacing it loses
# nothing and needs no --force. A product config is real work and is protected.
if [ -f "$IOSAI_CONFIG_FILE" ] && [ "$opt_print" = "no" ]; then
    existing_mode="template"
    if grep -Eq '^(PROJECT_PATH|WORKSPACE_PATH)="[^"]+"' "$IOSAI_CONFIG_FILE"; then
        existing_mode="product"
    fi
    if [ "$existing_mode" = "product" ] && [ "$opt_force" = "no" ]; then
        log_error "Config/project.env already configures a product and will not be overwritten"
        hint "current settings:"
        grep -E '^(PROJECT_PATH|WORKSPACE_PATH|SCHEME)=' "$IOSAI_CONFIG_FILE" \
            | sed 's/^/           /' >&2
        hint "re-run with --force to replace it (the old file is copied to"
        hint ".artifacts/config-backups/ first), or edit Config/project.env by hand."
        exit "$EX_USAGE"
    fi
    if [ "$existing_mode" = "product" ]; then
        backup_dir="${IOSAI_ARTIFACTS_DIR}/config-backups"
        ensure_artifact_directory "$backup_dir"
        backup="${backup_dir}/project.env.$(utc_stamp)-$$"
        backup_tmp="$(mktemp "${backup_dir}/.project.env.tmp.XXXXXX")" \
            || die "$EX_CANTCREAT" "cannot create configuration backup temporary"
        cp -- "$IOSAI_CONFIG_FILE" "$backup_tmp"
        atomic_replace_file_no_follow "$backup_tmp" "$backup" "$IOSAI_ARTIFACTS_DIR"
        log_warn "existing product configuration backed up to $(relpath "$backup")"
    fi
fi

# --- render -----------------------------------------------------------------
if [ "$opt_template_mode" = "true" ]; then
    template_flag="true"
else
    template_flag="false"
fi

rendered="$(cat <<EOF
# Config/project.env — live configuration for THIS repository.
#
# Generated by ./Scripts/configure-project.sh on $(utc_stamp).
# See Config/project.env.example for what every key means.
#
# Committed on purpose: this is what makes a build reproducible elsewhere.
# It must never contain credentials, tokens, or signing material.

APP_PLATFORM="${opt_platform}"
PROJECT_NAME="${opt_name}"
BUNDLE_IDENTIFIER="${opt_bundle_id}"

PROJECT_PATH="${opt_project}"
WORKSPACE_PATH="${opt_workspace}"
SCHEME="${opt_scheme}"
APP_TARGET="${opt_app_target}"

CONFIGURATION_DEBUG="${opt_config_debug}"
CONFIGURATION_RELEASE="${opt_config_release}"

BUILD_DESTINATION="${opt_build_dest}"
TEST_DESTINATION="${opt_test_dest}"
SIMULATOR_MODE="${opt_simulator_mode}"
SIMULATOR_DEVICE_TYPE="${opt_simulator_type}"
SIMULATOR_RUNTIME="${opt_simulator_runtime}"

FAST_TEST_ARGUMENTS="${opt_fast_args}"
MILESTONE_TEST_ARGUMENTS="${opt_milestone_args}"
RELEASE_TEST_ARGUMENTS="${opt_release_args}"

DERIVED_DATA_PATH="${opt_derived}"

DISTRIBUTION_CHANNEL="${opt_distribution}"

SUPPORT_SITE_URL="${opt_site_url}"
SUPPORT_EMAIL="${opt_support_email}"
DEVELOPER_NAME="${opt_developer_name}"

TEMPLATE_REPOSITORY="${template_flag}"

ENABLE_SWIFTLINT="${opt_swiftlint}"
ENABLE_SWIFTFORMAT="${opt_swiftformat}"
ENABLE_SHELLCHECK="${opt_shellcheck}"
EOF
)"

if [ "$opt_print" = "yes" ]; then
    printf '%s\n' "$rendered"
    exit 0
fi

# Validate BEFORE publishing. Writing first and checking second meant a value
# containing " $ or ` replaced a working configuration with one every gate
# rejects — and only a previous PRODUCT config was backed up, so a template-mode
# repository was left needing a hand repair before anything would run again.
config_dir="$(dirname -- "$IOSAI_CONFIG_FILE")"
mkdir -p "$config_dir"
staged="$(mktemp "${config_dir}/.project.env.staged.XXXXXX")" \
    || die "$EX_CANTCREAT" "cannot create configuration staging file"
if ! printf '%s\n' "$rendered" > "$staged"; then
    rm -f -- "$staged"
    die "$EX_CANTCREAT" "cannot write the staged configuration"
fi

if ! env_file_validate "$staged" 2>/dev/null; then
    log_error "the requested configuration is not valid, so nothing was written"
    hint "a value contains a \" \$ or \` character, which this format forbids —"
    hint "values are literal, so there is no way to escape them."
    hint "the offending assignment, reported by path and line:"
    env_file_validate "$staged" 2>&1 | sed "s|${staged}|<staged configuration>|g" \
        | sed 's/^/           /' >&2 || true
    rm -f -- "$staged"
    if [ -f "$IOSAI_CONFIG_FILE" ]; then
        hint "$(relpath "$IOSAI_CONFIG_FILE") is unchanged."
    fi
    exit "$EX_VERIFY"
fi

atomic_replace_file_no_follow "$staged" "$IOSAI_CONFIG_FILE" "$config_dir"

log_ok "wrote $(relpath "$IOSAI_CONFIG_FILE")"

if [ "$opt_template_mode" = "true" ]; then
    log_info ""
    log_info "Mode: template (no application target)."
    log_info "Local gates will run repository-level checks only."
    log_info ""
    log_info "Next steps:"
    log_info "  1. make template-check"
    log_info "  2. make static"
    log_info "  Optional: ./Scripts/install-git-hooks.sh"
else
    log_info ""
    log_info "Mode: product."
    log_info "  container: ${opt_project:-$opt_workspace}"
    log_info "  scheme:    ${opt_scheme}"
    if [ "$opt_simulator_mode" = managed ]; then
        log_info "  simulator: managed (${opt_simulator_type}, ${opt_simulator_runtime})"
    else
        log_info "  build:     ${opt_build_dest:-(not set)}"
        log_info "  test:      ${opt_test_dest:-(not set)}"
    fi
    log_info "  DerivedData: ${opt_derived:-$(derived_data_path)}"
    log_info ""
    log_info "Next steps:"
    log_info "  1. make static          # no simulator needed"
    if [ "$opt_simulator_mode" = managed ]; then
        log_info "  Prepare once: make simulator-setup"
    fi
    log_info "  2. make fast            # Debug build + fast tests"
    log_info "  3. set the milestone to REVIEW, commit, then: make milestone ID=<ID>"
    log_info "  4. write the handoff, set the milestone to DONE, update AI/PROJECT_STATUS.md"
    log_info "  Optional: ./Scripts/install-git-hooks.sh"
    if [ "$opt_simulator_mode" != managed ] && { [ -z "$opt_build_dest" ] || [ -z "$opt_test_dest" ]; }; then
        log_info ""
        log_warn "BUILD_DESTINATION / TEST_DESTINATION are empty; build and test gates will refuse to run"
        hint "list what this machine has: xcrun simctl list devices available"
        hint "then re-run with --build-destination and --test-destination"
    fi
fi
