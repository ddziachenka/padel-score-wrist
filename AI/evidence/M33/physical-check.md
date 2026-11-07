# M33 fresh physical acceptance — pending

Source: `8eeec63f5287639b86e637803b436b005a6901da`, build 1.0 (8).
This is a check protocol, not a record of completed observations. M29 acceptance
is historical and does not satisfy these changed presentation/speech checks.

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
3. Enable VoiceOver and repeat the Watch Match demo and disposable Watch Americano flow. Record actual full localized side
   speech, readable order, no duplicate receivers' choice, scoring/Undo/Reset
   usability and absence of a letter-only or stale-side announcement.
4. In a disposable real game (only when safe for existing data), check an odd
   service-block length, Undo, known-score/correction preview and relaunch. Side
   must match the accepted service position; no side after Finish or while a new
   set awaits serving confirmation. Check a realistic long name and Always On.
5. Restore any temporary device settings to their original values. Record actual
   results or failures per row; do not replace audio/on-wrist evidence with
   Simulator accessibility labels or screenshots.

Status: BLOCKED. On 2026-11-07 the owner answered the fresh-check availability
question with “The Watch is unavailable”. This resolves availability, not acceptance:
no repeated request or physical check is scheduled until the device is available.
Complete independent digital preparation, preserve the failed connection evidence,
and leave M33 BLOCKED. AGENTS.md A10 and M33's first acceptance criterion require
actual affected physical evidence before DONE; M34 remains PLANNED.
No recognition-rate, elapsed play duration or physical VoiceOver pass is asserted.
