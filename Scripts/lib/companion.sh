#!/usr/bin/env bash
# Additive two-platform verification. Loaded by common.sh; Bash 3.2.

load_companion_profile() {
    [ "${COMPANION_PROFILE:-}" = Config/companion.env ] \
        || die "$EX_USAGE" 'no committed companion profile is configured'
    assert_no_symlink_ancestry "${IOSAI_ROOT}/Config/companion.env" || exit "$EX_USAGE"
    env_file_load "${IOSAI_ROOT}/Config/companion.env" || exit "$EX_VERIFY"
    IOSAI_PLATFORM_PROFILE=companion
    [ "$(app_platform)" = iOS ] && [ -n "${SCHEME:-}" ] && [ -n "${APP_TARGET:-}" ] \
        || die "$EX_VERIFY" 'companion profile must identify its iOS scheme and app target'
    [ -z "${COMPANION_PROFILE:-}" ] || die "$EX_VERIFY" 'companion profiles cannot recurse'
    platform_config_validate
    simulator_config_validate
    split_args "${RELEASE_TEST_ARGUMENTS:-}"
    assert_test_args_allowed companion-release ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}
    split_args "${MILESTONE_TEST_ARGUMENTS:-}"
    assert_test_args_allowed companion-milestone ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}
}

validate_independent_watch_build() {
    local configuration="$1" destination="$2" derived="$3" report="$4" settings app_path
    xcb_container_args
    settings="$(xcodebuild -showBuildSettings -json \
        ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} -scheme "$SCHEME" \
        -configuration "$configuration" -destination "$destination" -derivedDataPath "$derived")" \
        || die "$EX_VERIFY" 'cannot inspect independent Watch build'
    app_path="$(printf '%s' "$settings" | jq -er --arg target "$APP_TARGET" \
        '[.[] | select(.target == $target)] | if length == 1 then .[0].buildSettings | .TARGET_BUILD_DIR + "/" + .FULL_PRODUCT_NAME else error("Watch target count") end')" \
        || die "$EX_VERIFY" 'independent Watch target is missing or ambiguous'
    platform_built_plist "$app_path/Info.plist" >/dev/null || exit $?
    python3 "${IOSAI_ROOT}/Scripts/verify-companion.py" --watch-app "$app_path" \
        || die "$EX_VERIFY" 'independent Watch packaging failed'
    report_line "$report" "**${configuration} independent Watch:** verified companion ID, independent execution, executable and launcher"
}

validate_companion_build() {
    local configuration="$1" destination="$2" derived="$3" report="$4" settings app_path
    xcb_container_args
    settings="$(xcodebuild -showBuildSettings -json \
        ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} -scheme "$SCHEME" \
        -configuration "$configuration" -destination "$destination" -derivedDataPath "$derived")" \
        || die "$EX_VERIFY" 'cannot inspect iOS companion build'
    app_path="$(printf '%s' "$settings" | jq -er --arg target "$APP_TARGET" \
        '[.[] | select(.target == $target)] | if length == 1 then .[0].buildSettings | .TARGET_BUILD_DIR + "/" + .FULL_PRODUCT_NAME else error("iOS target count") end')" \
        || die "$EX_VERIFY" 'iOS companion target is missing or ambiguous'
    platform_built_plist "$app_path/Info.plist" >/dev/null || exit $?
    python3 "${IOSAI_ROOT}/Scripts/verify-companion.py" --phone-app "$app_path" \
        || die "$EX_VERIFY" 'iOS/Watch distribution packaging failed'
    report_line "$report" "**${configuration} iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified"
}

verify_companion_profile() (
    local mode="$1" parent_dir="$2" report="$3" directory derived result test_rc=0 counts_line
    [ -n "${COMPANION_PROFILE:-}" ] || die "$EX_NOINPUT" 'required companion profile is missing'
    load_companion_profile
    directory="${parent_dir}/companion"
    mkdir -p "$directory" || exit "$EX_CANTCREAT"
    IOSAI_SIMULATOR_TOKEN=""
    trap simulator_release EXIT
    simulator_gate_begin "$report" || exit $?
    derived="$(derived_data_path)"
    ensure_derived_data_root "$derived"
    xcb_container_args
    run_xcodebuild companion-debug "$directory" -- build \
        ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} -scheme "$SCHEME" \
        -configuration "$CONFIGURATION_DEBUG" -destination "$BUILD_DESTINATION" \
        -derivedDataPath "$derived" || exit "$EX_FAIL"
    validate_companion_build "$CONFIGURATION_DEBUG" "$BUILD_DESTINATION" "$derived" "$report" || exit $?
    if [ "$mode" = release ]; then
        run_xcodebuild clean-release "$directory" -- clean build \
            ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} -scheme "$SCHEME" \
            -configuration "$CONFIGURATION_RELEASE" -destination "$(platform_device_destination)" \
            -derivedDataPath "$derived" CODE_SIGNING_ALLOWED=NO || exit "$EX_FAIL"
        validate_companion_build "$CONFIGURATION_RELEASE" "$(platform_device_destination)" "$derived" "$report" || exit $?
    fi
    local scheme_name suite
    for suite in unit ui; do
        if [ "$suite" = unit ]; then scheme_name="${SCHEME}Unit"; else scheme_name="$SCHEME"; fi
        result="${directory}/${suite}.xcresult"
        test_rc=0
        run_xcodebuild "companion-${suite}-tests" "$directory" -- test \
            ${XCB_CONTAINER_ARGS[@]+"${XCB_CONTAINER_ARGS[@]}"} -scheme "$scheme_name" \
            -configuration "$CONFIGURATION_DEBUG" -destination "$TEST_DESTINATION" \
            -derivedDataPath "$derived" -resultBundlePath "$result" || test_rc=$?
        counts_line="$(assert_result_bundle "$result" "complete iOS companion ${suite} suite" \
            "${directory}/${suite}-counts.txt" reject-skipped | tail -n1)" || exit $?
        [ "$test_rc" -eq 0 ] || exit "$EX_FAIL"
        report_line "$report" "**iOS companion ${suite} complete suite:** ${counts_line}"
        report_line "$report" "**iOS companion ${suite} result:** $(relpath "$result")"
    done

)
