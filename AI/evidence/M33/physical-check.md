# M33 fresh physical acceptance — in progress

Source: `8eeec63f5287639b86e637803b436b005a6901da`, build 1.0 (8).
Current status: VoiceOver is OWNER_CONFIRMED_VERIFIED from the owner's explicit
2026-11-07 message: “VoiceOver отметь как проверенный, а физический Watch давай сейчас проверим”.
This records the owner's verification, not agent-observed audio or invented device,
language, timing or individual utterance measurements. No repeat VoiceOver request.
Other fresh physical checks are IN_PROGRESS. M29 acceptance remains historical.

The earlier unavailable-device/install-failure checkpoint below is preserved as
history; the owner has now resumed the physical Watch check. Installed build8
identity and visual/interaction observations will be recorded as actually obtained.

## Installation evidence

Signed Release phone + embedded independent Watch + launcher build succeeds:
`xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Release -destination 'generic/platform=iOS' -derivedDataPath .artifacts/M33/device-derived-data DEVELOPMENT_TEAM=WW8JPY8B94 CODE_SIGN_STYLE=Automatic build`, exit 0 outside sandbox.
Log `.artifacts/M33/device-build-unsandboxed.log`; actual three-bundle version
readback `.artifacts/M33/device-build-identity.json`, all 1.0 (8).
The sandboxed attempt exited65 for unavailable signing profiles and is preserved in
`device-build.log`; not an app defect or a passing build.

Direct data-preserving Watch update attempted with
`xcrun devicectl device install app --device 00008310-000823642660E01E --timeout 30 --json-output .artifacts/M33/watch-install-unsandboxed.json .artifacts/M33/device-derived-data/Build/Products/Release-watchos/PadelScoreWatch.app`.
The live connection exited1 with Bluetooth L2CAP open-channel/tunnel error. No
installed-build identity is established. The sandboxed first attempt exited1 after timing out
initializing CoreDeviceService. Both logs/JSON remain under `.artifacts/M33/`.
No uninstall, erase, pairing reset, device setting change or data disposal occurred.

## Required fresh observations

Record device/OS, installed About version, app language, text size and observer/date.
Use isolated Demo where possible; preserve the owner's real game and history.

1. In Watch About confirm 1.0 (8). Open About → Try the scoreboard: 40–30 shows L. Score THEM:
   golden point shows L/R and receivers' choice. Undo restores L. Confirm score,
   server and side are readable on wrist at ordinary and largest text size.
2. In a disposable real Watch Americano game, use three rallies per server. Start
   R, score once for L, once for R, and once more for the next server starting R.
   Do this only when safe for the owner’s existing game; the Watch demo is Match-only.
   The iPhone Americano demo is a supplementary isolated 10–10/R example. Confirm
   the server-facing-net meaning using bundled help.
3. OWNER_CONFIRMED_VERIFIED on2026-11-07 (no repeat requested). Original protocol: enable VoiceOver and repeat the Watch Match demo and disposable Watch Americano flow. Record actual full localized side
   speech, readable order, no duplicate receivers' choice, scoring/Undo/Reset
   usability and absence of a letter-only or stale-side announcement.
4. In a disposable real game (only when safe for existing data), check an odd
   service-block length, Undo, known-score/correction preview and relaunch. Side
   must match the accepted service position; no side after Finish or while a new
   set awaits serving confirmation. Check a realistic long name and Always On.
5. Restore any temporary device settings to their original values. Record actual
   results or failures per row; do not replace audio/on-wrist evidence with
   Simulator accessibility labels or screenshots.

Historical checkpoint — BLOCKED. Earlier on 2026-11-07 the owner answered the fresh-check availability
question with “The Watch is unavailable”. This resolves availability, not acceptance:
no repeated request or physical check is scheduled until the device is available.
Complete independent digital preparation, preserve the failed connection evidence,
and leave M33 BLOCKED. AGENTS.md A10 and M33's first acceptance criterion require
actual affected physical evidence before DONE; M34 remains PLANNED.
No recognition-rate, elapsed play duration or physical VoiceOver pass is asserted.

## Resumed connection attempt — 2026-11-07

Current main at resume:3d2ad927390a8897e1a8d15f87ff928893a99c4e.
`xcrun devicectl list devices --timeout 20 --json-output .artifacts/M33/device-readiness-now.json`
exited0: physical Watch Ultra3/watchOS27.0.1 is paired/available but disconnected;
paired iPhone is unavailable. This discovery is not installed-build verification.

`xcrun devicectl device install app --device 00008310-000823642660E01E --timeout 45 --json-output .artifacts/M33/watch-install-resumed.json .artifacts/M33/device-derived-data/Build/Products/Release-watchos/PadelScoreWatch.app`
exited1 in sandbox, CoreDeviceService initialization timeout. Same installation
outside sandbox with JSON output watch-install-resumed-unsandboxed.json exited1:
Bluetooth connection invalidated before tunnel creation, L2CAP open-channel error.
No installation success or new on-device observation is claimed.

Requested owner connect/unlock the paired iPhone by cable and unlock nearby Watch
with Wi-Fi/Bluetooth enabled, then report readiness (or an already installed1.0(8)).
Awaiting that connection/identity input. VoiceOver remains OWNER_CONFIRMED_VERIFIED.
`./Scripts/project-status.sh validate` and `git diff --check` exited0 for the
resumed documentation update. Full gate and remaining physical rows are pending.

## Owner-connected installation — 2026-11-07

Owner replied “Готово, устройства подключены”. Resume HEAD:
f4f86bcc1fcbeee48c63d159adc3e819da1cfd09. The direct Watch install with the
same app/device and timeout90 exited1 (Bluetooth L2CAP/tunnel failure), recorded
in `.artifacts/M33/watch-install-connected.json`. Watch app-info lookup exited1
with the same connection error (`watch-installed-connected.json`). Neither is a
physical installation/identity pass.

`xcrun xctrace list devices` exited0 and showed the iPhone connected, Watch offline,
while CoreDevice discovery showed only the disconnected Watch. Saved readback:
`.artifacts/M33/xctrace-connected-devices.txt` and connected-all-devices.json.

Fallback succeeded, exit0:
`xcrun devicectl device install app --device 00008150-000104A10284401C --timeout 90 --json-output .artifacts/M33/phone-install-connected.json .artifacts/M33/device-derived-data/Build/Products/Release-iphoneos/PadelScore.app`.
This installed the signed1.0(8) phone app containing the matching Watch app.
It does not itself prove delivery/installation on the Watch. No uninstall, erase,
pairing change or synthetic test data was used.

Awaiting owner readback of Watch About version and the isolated Match demo:
40–30/L → THEM →40–40/LR/receivers choice →Undo→40–30/L, with on-wrist readability.
If the watch update is pending, owner was directed to its normal iPhone Watch app
installation status. Remaining physical rows stay pending; VoiceOver stays verified
by the owner's explicit confirmation.

Phone installed identity confirmed, exit0:
`xcrun devicectl device info apps --device 00008150-000104A10284401C --bundle-id com.dziachenka.padelscore --timeout 30 --json-output .artifacts/M33/phone-installed-connected.json`
returns PadelScore/com.dziachenka.padelscore, version1.0, bundleVersion8.
Watch identity still awaits owner readback.
