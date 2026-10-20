#!/usr/bin/env bash
# Owned simulator operations and cooperative desktop/device sessions.
set -euo pipefail
_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
. "${_script_dir}/lib/common.sh"
iosai_enter_root
usage() {
    cat <<'HELP'
Usage: ./Scripts/simulator.sh COMMAND [arguments]
  setup                         create/reuse this checkout's pinned simulator
  context | status              JSON context (status includes current device state)
  boot | shutdown               operate only on the owned device
  install APP                   install a built .app
  launch BUNDLE_ID [arguments]   launch on the owned device
  screenshot FILE               save the owned device's screen
  run -- COMMAND [arguments]    hold checkout/device leases for an external tool;
                                exports IOSAI_SIMULATOR_UDID and IOSAI_SIMULATOR_DESTINATION
  acquire --pid PID [--desktop] hold a session for a live agent process; returns token
  release TOKEN                 explicitly release that session
  desktop-acquire --pid PID      hold the shared desktop for a live agent process
  desktop-release TOKEN          release the desktop session
  leases                        show active cooperative leases as JSON
Busy resources exit 75; no live lease expires by timeout. Keep the token private
until release. GUI sessions hold acquire --desktop across the whole interaction.
HELP
}
command="${1:---help}"
shift || true
case "$command" in -h|--help) usage; exit 0 ;; esac
require_tools perl jq
# These commands need no product configuration or live Simulator service.
case "$command" in
    release|desktop-release) [ $# -eq 1 ] || die "$EX_USAGE" 'release requires TOKEN'; simulator_lease release "$1"; exit ;;
    leases) [ $# -eq 0 ] || die "$EX_USAGE" 'leases takes no arguments'; simulator_lease status; exit ;;
    desktop-acquire)
        [ $# -eq 2 ] && [ "$1" = --pid ] || die "$EX_USAGE" 'desktop-acquire requires --pid PID'
        simulator_lease acquire "$2" "$IOSAI_ROOT" desktop; exit ;;
esac
load_project_config --required
[ "${SIMULATOR_MODE-explicit}" = managed ] || die "$EX_USAGE" 'set SIMULATOR_MODE="managed" and pin SIMULATOR_DEVICE_TYPE and SIMULATOR_RUNTIME first'
trap simulator_release EXIT
simulator_signal_traps
if [ "$command" = setup ]; then
    [ $# -eq 0 ] || die "$EX_USAGE" 'setup takes no arguments'
    simulator_inventory
    simulator_acquire
    simulator_local_directory
    manifest="$(simulator_state_dir)/simulator.json"
    assert_no_symlink_ancestry "$manifest" || exit "$EX_USAGE"
    if [ ! -e "$manifest" ]; then
        # A full checkout-path digest avoids collisions even for equal folder names.
        IOSAI_SIMULATOR_NAME="$(simulator_device_name)"
        # Never adopt an unregistered device merely because its name matches.
        if printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -e --arg name "$IOSAI_SIMULATOR_NAME" \
            'any(.devices[][]; .name == $name)' >/dev/null; then
            die "$EX_VERIFY" 'an unregistered device with the owned name exists; inspect it before preparing again'
        fi
        IOSAI_SIMULATOR_UDID="$(xcrun simctl create "$IOSAI_SIMULATOR_NAME" "$SIMULATOR_DEVICE_TYPE" "$SIMULATOR_RUNTIME")"
        [[ "$IOSAI_SIMULATOR_UDID" =~ ^[A-Fa-f0-9-]{36}$ ]] || die "$EX_SOFTWARE" 'simctl returned an invalid device identifier'
        tmp="$(mktemp "$(simulator_state_dir)/.simulator.XXXXXX")"
        jq -n --arg owner "$(simulator_owner)" --arg id "$IOSAI_SIMULATOR_UDID" \
            --arg type "$SIMULATOR_DEVICE_TYPE" --arg runtime "$SIMULATOR_RUNTIME" --arg name "$IOSAI_SIMULATOR_NAME" \
            '{version:1,owner:$owner,udid:$id,device_type:$type,runtime:$runtime,name:$name}' > "$tmp"
        mv "$tmp" "$manifest"
    fi
    simulator_resolve
    simulator_context
    exit 0
fi
simulator_resolve
case "$command" in
    context) [ $# -eq 0 ] || die "$EX_USAGE" 'context takes no arguments'; simulator_context ;;
    status)
        [ $# -eq 0 ] || die "$EX_USAGE" 'status takes no arguments'
        simulator_context | jq --argjson inventory "$IOSAI_SIMULATOR_INVENTORY" \
            '. + {state:([$inventory.devices[][] | select(.udid == $ARGS.positional[0]) | .state][0])}' \
            --args "$IOSAI_SIMULATOR_UDID" ;;
    acquire)
        [ $# -ge 2 ] && [ "$1" = --pid ] || die "$EX_USAGE" 'acquire requires --pid PID [--desktop]'
        pid="$2"; shift 2
        [ $# -eq 0 ] || { [ $# -eq 1 ] && [ "$1" = --desktop ]; } || die "$EX_USAGE" 'unexpected acquire arguments'
        simulator_lease acquire "$pid" "$(simulator_owner)" "checkout:$(simulator_owner)" \
            "device:$IOSAI_SIMULATOR_UDID" ${1:+desktop} ;;
    boot|shutdown|install|launch|screenshot|run)
        simulator_acquire
        case "$command" in
            boot)
                [ $# -eq 0 ] || die "$EX_USAGE" 'boot takes no arguments'
                state="$(printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -r --arg id "$IOSAI_SIMULATOR_UDID" '.devices[][] | select(.udid == $id) | .state')"
                [ "$state" = Booted ] || xcrun simctl boot "$IOSAI_SIMULATOR_UDID"
                xcrun simctl bootstatus "$IOSAI_SIMULATOR_UDID" -b ;;
            shutdown) [ $# -eq 0 ] || die "$EX_USAGE" 'shutdown takes no arguments'; xcrun simctl shutdown "$IOSAI_SIMULATOR_UDID" ;;
            install) [ $# -eq 1 ] || die "$EX_USAGE" 'install requires APP'; xcrun simctl install "$IOSAI_SIMULATOR_UDID" "$1" ;;
            launch) [ $# -ge 1 ] || die "$EX_USAGE" 'launch requires BUNDLE_ID'; xcrun simctl launch "$IOSAI_SIMULATOR_UDID" "$@" ;;
            screenshot) [ $# -eq 1 ] || die "$EX_USAGE" 'screenshot requires FILE'; xcrun simctl io "$IOSAI_SIMULATOR_UDID" screenshot "$1" ;;
            run)
                [ $# -gt 1 ] && [ "$1" = -- ] || die "$EX_USAGE" 'run requires -- COMMAND'; shift
                export IOSAI_SIMULATOR_UDID
                export IOSAI_SIMULATOR_DESTINATION="$(platform_simulator_destination "$IOSAI_SIMULATOR_UDID")"
                "$@" ;;
        esac ;;
    *) usage >&2; exit "$EX_USAGE" ;;
esac
