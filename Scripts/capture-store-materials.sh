#!/usr/bin/env bash
# Explicit local Store capture profiles. Never uploads, publishes, or changes primary bindings.
set -euo pipefail
m25_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
. "$m25_script_dir/lib/common.sh"
iosai_enter_root
load_project_config --required
m25_platform="${1:-}"
m25_action="${2:-}"
m25_run="${3:-$m25_platform-gallery}"
[[ "$m25_run" =~ ^[A-Za-z0-9-]+$ ]] || die "$EX_USAGE" 'safe output name required'
case "$m25_platform" in
 watch)
  IOSAI_PLATFORM_PROFILE=m25-watch-gallery
  SIMULATOR_DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-44mm-2nd-generation
  SIMULATOR_RUNTIME=com.apple.CoreSimulator.SimRuntime.watchOS-26-1 ;;
 phone-current)
  load_companion_profile
  IOSAI_PLATFORM_PROFILE=m16-phone-current
  SIMULATOR_DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max
  SIMULATOR_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-27-0 ;;
 phone)
  load_companion_profile
  env_file_load "$IOSAI_ROOT/Config/companion-capture.env"
  IOSAI_PLATFORM_PROFILE=companion-capture ;;
 *) die "$EX_USAGE" 'usage: capture-store-materials.sh watch|phone|phone-current setup|context|capture [run-name]' ;;
esac
platform_config_validate
simulator_config_validate
trap simulator_release EXIT
simulator_signal_traps
if [ "$m25_action" = setup ]; then
 simulator_inventory
 simulator_acquire
 simulator_local_directory
 m25_binding="$(simulator_state_dir)/simulator.json"
 assert_no_symlink_ancestry "$m25_binding" || exit "$EX_USAGE"
 if [ ! -e "$m25_binding" ]; then
  IOSAI_SIMULATOR_NAME="$(simulator_device_name)"
  if printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -e --arg name "$IOSAI_SIMULATOR_NAME" 'any(.devices[][]; .name == $name)' >/dev/null; then
   die "$EX_VERIFY" 'unregistered device with owned name; refusing adoption'
  fi
  IOSAI_SIMULATOR_UDID="$(xcrun simctl create "$IOSAI_SIMULATOR_NAME" "$SIMULATOR_DEVICE_TYPE" "$SIMULATOR_RUNTIME")"
  [[ "$IOSAI_SIMULATOR_UDID" =~ ^[A-Fa-f0-9-]{36}$ ]] || exit "$EX_SOFTWARE"
  m25_tmp="$(mktemp "$(simulator_state_dir)/.simulator.XXXXXX")"
  jq -n --arg owner "$(simulator_owner)" --arg id "$IOSAI_SIMULATOR_UDID" --arg type "$SIMULATOR_DEVICE_TYPE" --arg runtime "$SIMULATOR_RUNTIME" --arg name "$IOSAI_SIMULATOR_NAME" '{version:1,owner:$owner,udid:$id,device_type:$type,runtime:$runtime,name:$name}' > "$m25_tmp"
  mv "$m25_tmp" "$m25_binding"
 fi
 simulator_resolve
 simulator_context
 exit 0
fi
simulator_resolve
if [ "$m25_action" = context ]; then simulator_context; exit 0; fi
[ "$m25_action" = capture ] || die "$EX_USAGE" 'expected setup, context or capture'
git diff --exit-code -- App Config Scripts
simulator_acquire
mkdir -p "$IOSAI_ROOT/.artifacts/M25"
m25_output="$IOSAI_ROOT/.artifacts/M25/$m25_run"
[ ! -e "$m25_output.xcresult" ] || die "$EX_USAGE" 'result bundle already exists; preserve it and choose a new run name'
simulator_context > "$m25_output-context.json"
git rev-parse HEAD > "$m25_output-source.txt"
m25_state="$(printf '%s' "$IOSAI_SIMULATOR_INVENTORY" | jq -r --arg id "$IOSAI_SIMULATOR_UDID" '.devices[][] | select(.udid == $id) | .state')"
m25_style=""
m25_cleanup() {
 if [ -n "$m25_style" ]; then xcrun simctl ui "$IOSAI_SIMULATOR_UDID" appearance "$m25_style"; fi
 if [ "$m25_state" = Shutdown ]; then xcrun simctl shutdown "$IOSAI_SIMULATOR_UDID"; fi
 simulator_release
}
trap m25_cleanup EXIT
[ "$m25_state" = Booted ] || xcrun simctl boot "$IOSAI_SIMULATOR_UDID"
xcrun simctl bootstatus "$IOSAI_SIMULATOR_UDID" -b
m25_tests=()
if [ "$m25_platform" = watch ]; then
 for m25_region in enUS esES esMX itIT frFR ptPT ptBR nlNL deDE svSE daDK fiFI nbNO ruRU; do
  m25_tests+=("-only-testing:PadelScoreWatchUITests/StoreMaterialsUITests/testM25Gallery$m25_region")
 done
else
 m25_style="$(xcrun simctl ui "$IOSAI_SIMULATOR_UDID" appearance)"
 xcrun simctl ui "$IOSAI_SIMULATOR_UDID" appearance dark
 m25_tests=(-only-testing:PadelScorePhoneUITests/CompanionUITests/testLocalizedGallery -only-testing:PadelScorePhoneUITests/CompanionUITests/testM25RecoveryGallery)
fi
m25_exit=0
xcodebuild test -quiet -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION_DEBUG" -destination "$(platform_simulator_destination "$IOSAI_SIMULATOR_UDID")" -derivedDataPath "$(derived_data_path)" -resultBundlePath "$m25_output.xcresult" "${m25_tests[@]}" -collect-test-diagnostics never -test-timeouts-enabled YES -maximum-test-execution-time-allowance 1800 > "$m25_output.log" 2>&1 || m25_exit=$?
printf '%s\n' "$m25_exit" > "$m25_output-exit.txt"
xcrun xcresulttool get test-results summary --path "$m25_output.xcresult" --format json > "$m25_output-summary.json"
xcrun xcresulttool export attachments --path "$m25_output.xcresult" --output-path "$m25_output-attachments" > "$m25_output-export.log"
cat "$m25_output-summary.json"
[ "$m25_exit" = 0 ] || exit "$m25_exit"
git diff --exit-code -- App Config Scripts
[ "$(git rev-parse HEAD)" = "$(cat "$m25_output-source.txt")" ] || die "$EX_VERIFY" 'capture source changed during run'
