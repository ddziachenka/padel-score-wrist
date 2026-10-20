#!/usr/bin/env bash
# Platform policy shared by configuration, simulator tools and build gates.
# Sourced by common.sh; Bash 3.2. No tool discovery during static validation.

app_platform() { printf '%s\n' "${APP_PLATFORM-iOS}"; }
platform_simulator_name() { printf '%s Simulator\n' "$(app_platform)"; }
platform_simulator_destination() { printf 'platform=%s,id=%s\n' "$(platform_simulator_name)" "$1"; }
platform_device_destination() { printf 'generic/platform=%s\n' "$(app_platform)"; }

platform_config_validate() {
    case "$(app_platform)" in
        iOS|watchOS) : ;;
        *) die "$EX_USAGE" 'APP_PLATFORM must be iOS or watchOS (Watch-only)' ;;
    esac
    # Managed destinations are derived from the binding. Explicit destinations
    # may omit platform (Xcode resolves an ID), but must not contradict it.
    [ "${SIMULATOR_MODE-explicit}" = explicit ] || return 0
    platform_validate_destination "${BUILD_DESTINATION:-}"
    platform_validate_destination "${TEST_DESTINATION:-}"
}

platform_validate_destination() {
    local destination="$1" component selected
    selected="$(app_platform)"
    # Read comma-separated components without shell expansion or word splitting.
    while IFS= read -r component; do
        component="$(printf '%s' "$component" | sed 's/^ *//;s/ *$//')"
        case "$component" in
            platform=*|generic/platform=*)
                case "${component#*=}" in
                    "$selected"|"$selected Simulator") : ;;
                    *) die "$EX_USAGE" "destination contradicts APP_PLATFORM=${selected}: $destination" ;;
                esac ;;
        esac
    done <<EOF
$(printf '%s' "$destination" | tr ',' '\n')
EOF
}

# Keep the historical iOS behavior for settings without platform metadata;
# watchOS must positively identify a modern watch application, never its stub.
platform_application_entries() {
    jq -c --arg platform "$(app_platform)" --arg target "${APP_TARGET:-}" '
        [ .[] | select(.buildSettings.PRODUCT_TYPE == "com.apple.product-type.application")
          | select($target == "" or .target == $target)
          | select(if $platform == "watchOS" then
              (.buildSettings.PLATFORM_NAME // .buildSettings.SUPPORTED_PLATFORMS // ""
               | test("(^| )(watchos|watchsimulator)( |$)"))
            else
              (.buildSettings.PLATFORM_NAME // .buildSettings.SUPPORTED_PLATFORMS // "iphoneos"
               | test("(^| )(iphoneos|iphonesimulator)( |$)"))
            end) ]'
}

# Read the actual built plist, not source INFOPLIST_KEY_* settings. Generated and
# explicit plists therefore have the same verification boundary.
platform_built_plist() {
    local path="$1"
    # Xcode may report /tmp for our /private/tmp cache. Normalize only this
    # system alias; resolving the whole path would hide a nested symlink.
    case "$path" in
        /tmp/*)
            [ -L /tmp ] && [ "$(physical_path /tmp)" = /private/tmp ] \
                || die "$EX_USAGE" 'system /tmp does not resolve to /private/tmp'
            path="/private${path}" ;;
    esac
    assert_path_inside "$path" "$(derived_data_owned_root)" \
        || die "$EX_USAGE" 'built product plist escapes the owned build cache'
    assert_no_symlink_ancestry "$path" || exit "$EX_USAGE"
    [ -f "$path" ] || die "$EX_VERIFY" "built product plist missing: $path"
    plutil -convert json -o - -- "$path" \
        || die "$EX_VERIFY" "cannot read built product plist: $path"
}

# validate_watch_build <configuration> <destination> <derived-data> <report>
# Runs after a successful build. The scheme must build its watch-only packaging
# container too; checking just the executable would miss broken distribution.
validate_watch_build() (
    [ "$(app_platform)" = watchOS ] || exit 0
    local configuration="$1" destination="$2" derived="$3" report="$4"
    local settings apps containers app container app_plist container_plist embedded
    local app_path container_path product_name built_platform
    require_tools xcodebuild jq plutil
    xcb_container_args
    settings="$(xcodebuild -showBuildSettings -json \
        ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} \
        -scheme "$SCHEME" -configuration "$configuration" \
        -destination "$destination" -derivedDataPath "$derived")" \
        || die "$EX_VERIFY" 'cannot resolve built watchOS products'
    apps="$(printf '%s' "$settings" | platform_application_entries)" \
        || die "$EX_VERIFY" 'invalid watchOS build settings'
    [ "$(printf '%s' "$apps" | jq length)" = 1 ] \
        || die "$EX_VERIFY" 'watchOS scheme must identify exactly one modern Watch app'
    # APP_TARGET must not hide a real iOS companion elsewhere in the scheme.
    printf '%s' "$settings" | jq -e '
        all(.[]; .buildSettings.PRODUCT_TYPE != "com.apple.product-type.application" or
          (.buildSettings.PLATFORM_NAME // .buildSettings.SUPPORTED_PLATFORMS // ""
           | test("(^| )(watchos|watchsimulator)( |$)")))' >/dev/null \
        || die "$EX_VERIFY" 'Watch-only scheme contains a non-watch application'
    containers="$(printf '%s' "$settings" | jq -c '
        [.[] | select(.buildSettings.PRODUCT_TYPE == "com.apple.product-type.application.watchapp2-container")]')"
    [ "$(printf '%s' "$containers" | jq length)" = 1 ] \
        || die "$EX_VERIFY" 'Watch-only scheme must build exactly one Xcode packaging container'
    app="$(printf '%s' "$apps" | jq -c '.[0].buildSettings')"
    container="$(printf '%s' "$containers" | jq -c '.[0].buildSettings')"
    product_name="$(printf '%s' "$app" | jq -r '.FULL_PRODUCT_NAME // empty')"
    case "$product_name" in
        ""|*/*|.|..) die "$EX_VERIFY" 'invalid Watch app product name' ;;
    esac
    app_path="$(printf '%s' "$app" | jq -r '(.TARGET_BUILD_DIR // "") + "/" + (.INFOPLIST_PATH // "")')"
    container_path="$(printf '%s' "$container" | jq -r '(.TARGET_BUILD_DIR // "") + "/" + (.INFOPLIST_PATH // "")')"
    app_plist="$(platform_built_plist "$app_path")" || exit $?
    container_plist="$(platform_built_plist "$container_path")" || exit $?
    case "$(printf '%s' "$app" | jq -r '.PLATFORM_NAME // empty')" in
        watchos) built_platform=WatchOS ;;
        watchsimulator) built_platform=WatchSimulator ;;
        *) die "$EX_VERIFY" 'built Watch app has no resolved watchOS platform' ;;
    esac
    case "$destination:$built_platform" in
        "generic/platform=watchOS:WatchSimulator"|*"platform=watchOS Simulator"*":WatchOS")
            die "$EX_VERIFY" 'built Watch platform differs from the requested destination' ;;
    esac
    printf '%s' "$app_plist" | jq -e --arg platform "$built_platform" '
        .WKWatchOnly == true and
        ((.WKCompanionAppBundleIdentifier // "") == "") and
        .CFBundlePackageType == "APPL" and
        (.CFBundleSupportedPlatforms | index($platform) != null)' >/dev/null \
        || die "$EX_VERIFY" 'built app is not a Watch-only watchOS application'
    local item plist
    for item in app container; do
        if [ "$item" = app ]; then plist="$app_plist"; settings="$app"; else plist="$container_plist"; settings="$container"; fi
        printf '%s' "$plist" | jq -e --argjson settings "$settings" '
            (.CFBundleIdentifier | type == "string" and length > 0) and
            (.CFBundleShortVersionString | type == "string" and length > 0) and
            (.CFBundleVersion | type == "string" and length > 0) and
            .CFBundleIdentifier == $settings.PRODUCT_BUNDLE_IDENTIFIER and
            .CFBundleShortVersionString == $settings.MARKETING_VERSION and
            .CFBundleVersion == $settings.CURRENT_PROJECT_VERSION' >/dev/null \
            || die "$EX_VERIFY" "built ${item} identity differs from build settings"
    done
    printf '%s' "$container_plist" | jq -e --argjson app "$app_plist" '
        .CFBundleShortVersionString == $app.CFBundleShortVersionString and
        .CFBundleVersion == $app.CFBundleVersion and
        (.CFBundleIdentifier as $id | $app.CFBundleIdentifier | startswith($id + "."))' >/dev/null \
        || die "$EX_VERIFY" 'Watch app and packaging container identity mismatch'
    if [ -n "${BUNDLE_IDENTIFIER:-}" ]; then
        [ "$(printf '%s' "$app_plist" | jq -r .CFBundleIdentifier)" = "$BUNDLE_IDENTIFIER" ] \
            || die "$EX_VERIFY" 'Watch app bundle identifier differs from configuration'
    fi
    embedded="$(platform_built_plist "$(dirname "$container_path")/Watch/${product_name}/Info.plist")" || exit $?
    [ "$(printf '%s' "$embedded" | jq -S .)" = "$(printf '%s' "$app_plist" | jq -S .)" ] \
        || die "$EX_VERIFY" 'packaging container does not embed the verified Watch app plist'
    report_line "$report" "**${configuration} Watch app:** $(printf '%s' "$app_plist" | jq -r '"\(.CFBundleIdentifier) \(.CFBundleShortVersionString) (\(.CFBundleVersion))"')"
    report_line "$report" "**${configuration} packaging container:** $(printf '%s' "$container_plist" | jq -r '"\(.CFBundleIdentifier) \(.CFBundleShortVersionString) (\(.CFBundleVersion))"')"
)
