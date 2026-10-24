#!/usr/bin/env bash
# Sourced by common.sh. Bash 3.2; no simulator discovery during static checks.
IOSAI_SIMULATOR_TOKEN=""
IOSAI_SIMULATOR_UDID=""
IOSAI_SIMULATOR_NAME=""

simulator_config_validate() {
    case "${SIMULATOR_MODE-explicit}" in
        explicit) return 0 ;;
        managed) ;;
        *) die "$EX_USAGE" 'SIMULATOR_MODE must be managed or explicit' ;;
    esac
    [[ "${SIMULATOR_DEVICE_TYPE:-}" =~ ^com\.apple\.CoreSimulator\.SimDeviceType\.[A-Za-z0-9.-]+$ ]] \
        || die "$EX_USAGE" 'managed mode requires SIMULATOR_DEVICE_TYPE (installed identifier)'
    local runtime_pattern="^com\.apple\.CoreSimulator\.SimRuntime\.$(app_platform)-[0-9-]+$"
    [[ "${SIMULATOR_RUNTIME:-}" =~ $runtime_pattern ]] \
        || die "$EX_USAGE" "managed mode requires SIMULATOR_RUNTIME (pinned $(app_platform) identifier)"
}

simulator_owner() { printf '%s\n' "${IOSAI_CACHE_OWNER_PATH:-$IOSAI_ROOT}"; }
simulator_device_name() {
    local digest
    digest="$(printf '%s' "$(simulator_owner)" | shasum -a 256 | awk '{print $1}')"
    printf 'iosai-%s%s-%s\n' "$(basename "$(simulator_owner)")" "${IOSAI_PLATFORM_PROFILE:+-${IOSAI_PLATFORM_PROFILE}}" "$digest"
}
simulator_state_dir() { printf '%s/.iosai-local%s\n' "$(simulator_owner)" "${IOSAI_PLATFORM_PROFILE:+/${IOSAI_PLATFORM_PROFILE}}"; }
simulator_lease() {
    local rc=0
    perl "${IOSAI_ROOT}/Scripts/lib/lease.pl" "$@" || rc=$?
    # Keep the Perl manager's sysexits contention result in the shared vocabulary.
    [ "$rc" -ne 75 ] || return "$EX_TEMPFAIL"
    return "$rc"
}

simulator_local_directory() {
    local dir
    dir="$(simulator_state_dir)"
    assert_no_symlink_ancestry "$dir" || exit "$EX_USAGE"
    if [ ! -d "$dir" ]; then (umask 077; mkdir -p "$dir") || exit "$EX_CANTCREAT"; fi
    [ -O "$dir" ] || die "$EX_USAGE" "local simulator state is not owned by this user: $dir"
}

simulator_inventory() {
    require_tools xcrun jq perl
    IOSAI_SIMULATOR_INVENTORY="$(xcrun simctl list -j)" \
        || die "$EX_UNAVAILABLE" 'cannot read CoreSimulator inventory'
    printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -e \
        --arg type "$SIMULATOR_DEVICE_TYPE" --arg runtime "$SIMULATOR_RUNTIME" \
        'any(.devicetypes[]; .identifier == $type) and
         any(.runtimes[]; .identifier == $runtime and .isAvailable == true and
             any(.supportedDeviceTypes[]?; .identifier == $type))' >/dev/null \
        || die "$EX_UNAVAILABLE" 'configured simulator type/runtime is unavailable or incompatible; inspect installed runtimes in Xcode'
}

simulator_resolve() {
    [ "${SIMULATOR_MODE-explicit}" = managed ] || die "$EX_USAGE" 'this command requires SIMULATOR_MODE="managed"'
    simulator_inventory
    local manifest owner
    owner="$(simulator_owner)"
    manifest="$(simulator_state_dir)/simulator.json"
    assert_no_symlink_ancestry "$manifest" || exit "$EX_USAGE"
    [ -f "$manifest" ] || die "$EX_UNAVAILABLE" 'simulator is not prepared; run make simulator-setup'
    jq -e --arg owner "$owner" --arg type "$SIMULATOR_DEVICE_TYPE" --arg runtime "$SIMULATOR_RUNTIME" \
        '.version == 1 and .owner == $owner and .device_type == $type and .runtime == $runtime and
         (.udid | type == "string" and test("^[A-Fa-f0-9-]{36}$")) and (.name | type == "string")' "$manifest" >/dev/null \
        || die "$EX_VERIFY" 'simulator binding does not match this checkout/configuration; preserve it and run simulator-setup for diagnosis'
    IOSAI_SIMULATOR_UDID="$(jq -r .udid "$manifest")"
    IOSAI_SIMULATOR_NAME="$(jq -r .name "$manifest")"
    [ "$IOSAI_SIMULATOR_NAME" = "$(simulator_device_name)" ] \
        || die "$EX_VERIFY" 'simulator name does not belong to this checkout'
    printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -e --arg runtime "$SIMULATOR_RUNTIME" \
        --arg id "$IOSAI_SIMULATOR_UDID" --arg name "$IOSAI_SIMULATOR_NAME" --arg type "$SIMULATOR_DEVICE_TYPE" \
        'any(.devices[$runtime][]?; .udid == $id and .name == $name and .deviceTypeIdentifier == $type and .isAvailable == true)' >/dev/null \
        || die "$EX_UNAVAILABLE" 'bound simulator is missing, unavailable or changed; no fallback device will be used'
}

simulator_acquire() {
    local lease
    lease="$(simulator_lease acquire "$$" "$(simulator_owner)" \
        "checkout:$(simulator_owner)" ${IOSAI_SIMULATOR_UDID:+"device:${IOSAI_SIMULATOR_UDID}"})" || return $?
    IOSAI_SIMULATOR_TOKEN="$(printf '%s' "$lease" | jq -r .token)"
}
simulator_release() {
    if [ -n "$IOSAI_SIMULATOR_TOKEN" ]; then
        simulator_lease release "$IOSAI_SIMULATOR_TOKEN" >/dev/null || true
        IOSAI_SIMULATOR_TOKEN=""
    fi
}
simulator_signal_traps() {
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP
}

simulator_gate_begin() {
    local report="$1"
    report_line "$report" "**App platform:** $(app_platform)"
    [ "${SIMULATOR_MODE-explicit}" = managed ] || return 0
    simulator_resolve
    simulator_acquire || return $?
    simulator_signal_traps
    BUILD_DESTINATION="$(platform_simulator_destination "$IOSAI_SIMULATOR_UDID")"
    TEST_DESTINATION="$BUILD_DESTINATION"
    report_line "$report" "**Simulator UDID:** ${IOSAI_SIMULATOR_UDID}"
    report_line "$report" "**Simulator runtime:** ${SIMULATOR_RUNTIME}"
    report_line "$report" "**Simulator owner:** $(simulator_owner)"
}

simulator_context() {
    jq -n --arg owner "$(simulator_owner)" --arg udid "$IOSAI_SIMULATOR_UDID" \
        --arg runtime "$SIMULATOR_RUNTIME" --arg type "$SIMULATOR_DEVICE_TYPE" \
        --arg destination "$(platform_simulator_destination "$IOSAI_SIMULATOR_UDID")" \
        --arg name "$IOSAI_SIMULATOR_NAME" --arg derived "$(derived_data_path)" \
        '{owner:$owner,udid:$udid,runtime:$runtime,device_type:$type,name:$name,
          destination:$destination,derived_data:$derived}'
}
