# Release preparation audit — 1.0 (1)

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** bounded release-preparation audit; not independent release approval
**Initial candidate:** `405967a0fd04866e8a0eb7346a7843283e1b168b`
**Corrected candidate:** `f287cdfa581fa6d1cc6974e91794321d02399804`
**Recorded by:** Codex, continuing the owner-authorized preparation without real hardware
**Recorded at:** 2026-10-21 UTC

## Verdict

`DO_NOT_DISTRIBUTE`. The exact release gate returns `NOT_READY`. This record
preserves useful checks while M08 is blocked; it does not replace M10's six ordered
domains, claim a completed milestone, waive hardware, or authorize submission.

## Initial candidate evidence

All paths below are relative to `.artifacts/watchos10-audit/` unless stated otherwise.

| Field | Evidence |
| --- | --- |
| Exact release command | `make release CANDIDATE=405967a0fd04866e8a0eb7346a7843283e1b168b` |
| Release result | make exit 2, verifier exit 65, `NOT_READY`; release-gate.log |
| Candidate-bound report | `.artifacts/release/20261021T160717Z-28257/report.md` |
| Audit coverage | INCOMPLETE: M08/M09 dependencies, minimum runtime and physical-device evidence remain outstanding |
| Human checklist | Not generated: preflight stops before readiness. No subjective device approval, Archive/Organizer validation, or distribution decision performed |
| Clean Release build | `xcodebuild clean build -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-audit-release CODE_SIGNING_ALLOWED=NO`; exit 0; release-build.log |
| Binary/package checks | release-checks.json: bundle, 1.0 (1), minimum 10.0, WKWatchOnly, manifest, absent debug override/UserDefaults/UI-test store, no purpose strings/background modes/third-party linked frameworks |
| First test batch | current-candidate.xcresult / current-candidate-summary.json: **351 passed, 0 failed, 0 skipped**, exit 0; 328 Swift tests + 4 StoreKit tests + 19 UI tests |
| Currency experiment | currency-probe.xcresult / currency-summary.json: **1 passed, 0 failed, 0 skipped**, exit 0; only an added test in a temporary copy, production sources unchanged |
| Remaining gameplay UI | game-journeys.xcresult / game-journeys-summary.json: **35 passed, 1 failed, 0 skipped**, exit 65; original test products, no rebuild after the separate scheme edit |

The clean build completed before a separate edit to the shared scheme appeared at
16:07:16 UTC (scheme version 1.3 → 1.7, two BlueprintName attributes removed).
That edit was not intentionally made by this audit; its origin is not established, so it is preserved. It is not silently included
in the candidate claim or in this audit's commit. The original candidate checks predate the bounded correction described below.

## watchOS 10 investigation

The previous `xcodebuild -downloadPlatform watchOS -buildVersion 10.0` and `10.5`
failures mean the current Xcode downloader did not offer them, not that Apple has
removed the images. A new explicit `-architectureVariant universal` attempt also
exits 70 (download-universal.log).

Apple's legacy catalog, saved as apple-runtime-index.plist, contains the stable
watchOS 10.0 build **21R355**, **4,023,631,243 bytes**:

- [Apple runtime catalog](https://devimages-cdn.apple.com/downloads/xcode/simulators/index2.dvtdownloadableindex)
- [Apple Developer archive](https://developer.apple.com/download/all/?q=watchOS%2010)
- [Official runtime image](https://download.developer.apple.com/Developer_Tools/watchOS_10_Simulator_Runtime/watchOS_10_Simulator_Runtime.dmg)

Unauthenticated curl redirects to Apple's unauthorized page. The signed-in archive
shows the image; the browser-tab controller navigation returned ERR_BLOCKED_BY_CLIENT.
A normal native Chrome click successfully starts the download. No browser security
setting was changed and no credentials were extracted. wait-import.sh waits for the
completed file, verifies its catalog size, records SHA-256, and imports using Xcode.
Import succeeded (exit 0) at 2026-10-21T16:31 UTC, registered as
1AF8BF7D-3C6B-4543-A9E0-77A02DDFADC8. The downloaded SHA-256 is
`f10c4de7b36f3e6d63a4fb9d6aed0547e615e5c127db286356e54e64503b6e63`.
CoreSimulator reports watchOS 10.0 (21R355), arm64/x86_64, isAvailable=true.
The owned SE 40mm device **3807D4BD-1657-49C7-A055-AE778141A06E** booted.
The completed result bundle reports **351 tests: 341 passed, 10 failed, 0 skipped**,
xcodebuild exit 65. All 328 Swift tests and four StoreKit tests passed. Nine of
19 UI tests passed; ten failed on navigation/taps or subsequent expected state.
Evidence: watchos10.xcresult, watchos10-summary.json, watchos10-tests.log.
Xcode’s additional simctl diagnose collection stalled after tests ended; only that
owned diagnostic child received SIGTERM. Xcode then finalized the failed bundle
and released the device. No test was interrupted or converted to a pass.
The compatibility experiment uses managed worktree
`/Users/dima/.codex/worktrees/watchos10-runtime-audit/padel-score`, detached at the
candidate. Only its simulator-runtime configuration changes to 10.0. The primary
26.1 binding/configuration is left untouched. This is the bounded environment
experiment allowed by AGENTS, not milestone implementation or gate verification in
a worktree. test-watchos10-worktree.sh records setup/context and runs the tests only
after a successful import; no runtime patch, global restart or simulator deletion.

Host: macOS 27.0.1 (26A434), Xcode 27.0 (27A266a). Original managed simulator:
A7CBB23C-F823-4850-BE4B-CAD76922DD08, watchOS 26.1 (23S36), SE 40mm (2nd generation).
A deployment target is not evidence of execution on watchOS 10.

## Release-domain coverage so far

`PARTIAL` and `PENDING` below explicitly mean the owning final-audit row is not
complete. The schema and final-gate requirements are unchanged.

| Requirement | Result | Evidence / remaining work |
| --- | --- | --- |
| REL-208 | INAPPLICABLE | Approved Watch-only app; no rating-request flow required by the platform exception |
| REL-209 | INAPPLICABLE | Approved Watch-only app; no manual App Store review entry required |
| REL-301 | INAPPLICABLE | No sensitive permission capability or purpose strings in the shipping app |
| REL-302 | INAPPLICABLE | No sensitive permission request to deny |
| REL-303 | INAPPLICABLE | No sensitive permission authorization to revoke |
| REL-304 | INAPPLICABLE | No HealthKit, location, camera, contacts, microphone or notification permission scope |
| REL-401 | PARTIAL | Local SKTestSession purchase succeeds; real-Watch Apple sandbox remains required |
| REL-402 | PARTIAL | Model tests cover cancellation/failure; local StoreKit pending/approval tested; hardware store dialogs remain |
| REL-403 | PARTIAL | Local StoreKit restore/relaunch tested; fresh-install real-Watch sandbox restore remains |
| REL-404 | PARTIAL | Local StoreKit refund revokes entitlement; non-consumable has no subscription expiry; hardware remains |
| REL-405 | PARTIAL | Production passes through Product.displayPrice; isolated USD/EUR storefront test passed, with identical Product.displayPrice; actual ASC prices read back as USD 4.99 and EUR 5.99; physical sandbox display still pending |
| REL-406 | PARTIAL | Access Terms/Privacy and Close tests; physical presentation remains part of M08 |
| REL-407 | PARTIAL | No activation, countdown, recurring payment, hidden dismissal or fabricated discount; five completed games stated; final product pass remains |
| REL-408 | VERIFIED | No comparison price, saving or promotional offer. DisplayPrice is verbatim StoreKit output; text says one purchase, no recurring payments; ASC type NON_CONSUMABLE |
| REL-501 | VERIFIED | PrivacyInfo.xcprivacy matches source and Release binary: no collection/tracking/required-reason calls. File creation/read/write is local; debug-only UserDefaults absent from binary |
| REL-502 | VERIFIED | Published Data Not Collected evidence in `.artifacts/publication-prep/asc-privacy-published.png`, unchanged shipping collection behavior; separate web/email processing described in policy |
| REL-503 | VERIFIED | ASC privacy URL matches public /privacy/; HTTP 200, byte-identical to source, specific to this app |
| REL-504 | VERIFIED | No application logging calls in shipping sources; no personal-data logging implementation. Apple/system logging is not claimed disabled |
| REL-505 | PARTIAL | Storage tests and deletion UI preserve only approved completed-game ledger and Apple purchase, remove games/results/undo/settings including recovery copies; hardware lifecycle remains |
| REL-506 | PARTIAL | Bundled readable legal/support content; standard-size reachability and large-text Access checks; final Watch usability still pending |
| REL-801 | VERIFIED | Reachable app/web copy contains no placeholder/TODO/example domain/trial/subscription strings; bundled contact and URLs are approved values |
| REL-1004 | VERIFIED | ASC Support URL /support/ returns 200 and matches published source with corrected email |
| REL-1005 | VERIFIED | Live ASC categories SPORTS/UTILITIES and age declaration all false/NONE; published 4+ evidence in M09 preparation matches scoring-only app |
| REL-1007 | VERIFIED | Review notes explain five small Americano games, sixth-game gate, About/Access/Restore, retained count and no account; contact fields complete; no private contact copied here |
| REL-1008 | VERIFIED | Public Terms identifies and links Apple Standard EULA; byte-identical source readback |
| REL-1101 | VERIFIED | Release symbols lack DebugPremiumOverride, UITestStore and NSUserDefaults; production composition ignores test environment; #if DEBUG encloses test paths |
| REL-1102 | VERIFIED | Initial unshipped 1.0 (1), consistent container/Watch identity; no uploaded build. Increment before any subsequent upload if needed |
| REL-1103 | PENDING | This bounded pass cannot establish the absence of blocking findings across the six full M10 domains and hardware |
| REL-1105 | INAPPLICABLE | First unshipped version, no previous production schema/build to migrate; local corruption/recovery remains tested separately |

Internal-only REL-1201–1203 do not apply to the configured app-store channel.

## Supplemental test scope and visual inspection

First batch, exit 0, UTC 2026-10-21T16:04:50.680Z–16:17:34.089Z:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination "$IOSAI_SIMULATOR_DESTINATION" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData -resultBundlePath .artifacts/watchos10-audit/current-candidate.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessibilityUITests -only-testing:PadelScoreWatchUITests/LargeTextUITests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/BootstrapUITests'
```

`current-screens/manifest.json` maps screenshots to tests and timestamps. Inspected
8D2FD192… (dismissible one-time paywall, five completions, $4.99), 4F668A51… (complete
wrapped support address/email), EEE5E5E8… (stacked largest-text scores), and 1F6A4E70…
(largest-text result/Saved). Scrolling tests prove off-screen controls remain reachable;
no claim that every element must be simultaneously visible at the largest text size.
The eight XCTest accessibility-audit methods passed without filtering out issues.
This is not a substitute for physical VoiceOver speech or interaction.

The isolated currency probe is `currency-probe.swift`, inserted only into the copied
StoreKitPurchaseTests.swift under `/private/tmp/padel-score-currency-probe/`, created
with `git archive <candidate> App`. It checks Apple-returned USD/EUR currency codes,
active USA/DEU storefront, byte-equal displayed price, and differing localized strings.
The local fixture yields **$4.99** and **4,99 €**; this tests formatting, not the live
German amount. Read-only ASC confirms live **$4.99 USA / €5.99 Germany**, with one
manual USA price and 174 automatic prices. No prices were changed.

```sh
xcodebuild build-for-testing -project /private/tmp/padel-score-currency-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-currency-probe-derived
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-currency-probe-derived/Build/Products/PadelScore_PadelScore_watchsimulator27.0-arm64-x86_64.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/currency-probe.xcresult -only-testing:PadelScoreWatchTests/StoreKitPurchaseTests/testAuditPriceFollowsUSAndGermanStorefronts'
```

Both commands exit 0. `currency-attachments/*.txt` contains the two observed price
strings. The experiment is supplementary evidence, not a milestone gate or a new
shipping/test-source commit. The original Products were copied to
`/private/tmp/padel-score-audit-products`; test-products-digests.json binds retained
binaries and xctestrun files for the remaining UI pass.

## Additional exact commands and runtime evidence

Remaining gameplay batch (35 passed, 1 failed, 0 skipped, exit 65):

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-audit-products/PadelScore_watchsimulator27.0-arm64.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/game-journeys.xcresult -only-testing:PadelScoreWatchUITests/CorrectionUITests -only-testing:PadelScoreWatchUITests/FinishResumeUITests -only-testing:PadelScoreWatchUITests/LiveScoreUITests -only-testing:PadelScoreWatchUITests/NewGameUITests'
```

CorrectionUITests.testCorrectingTheScoreAsksForServingAndIsUndoneWhole failed on
line 90: observed “Set 1”, expected the transient “Changes saved”. An isolated repeat
with the same binary instead failed earlier, opening menu.editScore. Neither failure
is labelled pre-existing or dismissed as flakiness. correction-serial.xcresult and
correction-serial-summary.json report 0 passed, 1 failed, 0 skipped, exit 65.
The repeat used the same command with `-collect-test-diagnostics never`, the result
path `correction-serial.xcresult`, and only that exact test selector.

Original watchOS 10 batch from the experiment worktree:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination "$IOSAI_SIMULATOR_DESTINATION" -derivedDataPath /private/tmp/padel-score-watchos10-derived -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/watchos10.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/BootstrapUITests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/LargeTextUITests -only-testing:PadelScoreWatchUITests/AccessibilityUITests'
```

The 10 UI failures comprise 3 Access, 4 Accessibility and 3 LargeText tests. Both
Bootstrap tests passed, including bundled legal/support routes. The three Access
failures occurred before purchase, on navigation after taps. The accessibility
failures were missing expected screens/controls, not an ignored accessibility issue.

The bounded center-tap probe changes only the tap delivery and adds AX diagnostics
in a temporary test-source copy; ui-center-probe.diff records the exact change. It
preserves all assertions and the application source. First scheduled attempt exited
75 on a busy lease. The subsequent attempt stalled waiting for accessibility after
launch; cancellation produced exit 73 / TEST EXECUTE INTERRUPTED, not a test pass.
Only the owned watchOS 10 device was restarted; no global service was reset.

Release simulator build (exit 0, watchos10-release-build.log):

```sh
xcodebuild build -project /Users/dima/.codex/worktrees/watchos10-runtime-audit/padel-score/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-watchos10-release
```

Under the owned device/desktop lease, `xcrun simctl install` installed that Release
PadelScoreWatch.app on 3807D4BD-1657-49C7-A055-AE778141A06E; `xcrun simctl launch`
started com.dziachenka.padelscore.watchapp (PID 85143), both exit 0. With no test
launch arguments, release10-first-launch.png shows the normal New game screen with
Match and Americano choices. Simulator.app is absent from the installed Xcode
Developer/Applications path; native interactive inspection could not proceed.
The screenshot is launch/render evidence, not a completed manual interaction audit.

## Compatibility correction

The center-tap-only probe reproduced all three Access failures after the device
restart (0 passed, 3 failed, 0 skipped, exit 65). AX evidence shows tappable rows
with centers at y=178.5–188.5 on a 197-point screen; taps did not navigate. Keeping
centers below the 48-point navigation bar and at least 32 points above the bottom
allowed the same actions to navigate. The stricter helper preserves every assertion,
uses the ordinary element tap, and does not add retries of a product action.

The safe-area probe passed deletion/count retention and largest-text voluntary
Access (2 passed) but exposed a separate sixth-game failure (1 failed, 0 skipped,
exit 65). After closing the sheet, setup showed “A new game can’t start right now”
with disabled fields: the derived presentation binding had not restored editing.
Adding onDismiss alone did not fix the failure (watchos10-dismiss.xcresult,
0 passed, 1 failed, 0 skipped, exit 65): Close inside the nested NavigationStack
did not dismiss the presented sheet on watchOS 10. The correction passes an explicit
Close callback from the sheet presenter to AccessView. It invokes the existing
idempotent cancelFailedStart method, making the presentation binding false;
onDismiss also handles system dismissal. It leaves the draft, previous game and usage ledger intact;
it neither unlocks access nor implicitly starts a game. Existing AccessUITests covers
Close, the retained draft, going back to the result and resuming it.

The changes are limited to AccessView.swift, SetupView.swift and UITestSupport.swift, made in the
primary checkout. correction.diff preserves the diff. Model coverage already checks
that an access-refused start retains its draft and cancellation restores editing.
No assertions were removed, test skipped, threshold relaxed or purchase check mocked.
Final verification is recorded below.

## Corrected candidate verification

The primary checkout commit `bb97b20e7de12ae60ab2fd9f254824cc8c832536` contains
only the three correction files above. The shared-scheme change remains unstaged.
The existing sixth-game scenario passes on watchOS 10 with the final presenter
callback (watchos10-presenter.xcresult: 1 passed, 0 failed, 0 skipped, exit 0).
Inspected screenshots show five completed games, the localized $4.99 offer, and
resumed play at 15–0 after dismissing Access. No purchase was required to resume.

A fresh `git archive bb97b20e7de12ae60ab2fd9f254824cc8c832536 App` snapshot was
extracted to `/private/tmp/padel-score-final-bb97b20`. Exact build commands:

```sh
xcodebuild build-for-testing -project /private/tmp/padel-score-final-bb97b20/App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-final-derived
xcodebuild clean build -project /private/tmp/padel-score-final-bb97b20/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-final-release CODE_SIGNING_ALLOWED=NO
python3 .artifacts/watchos10-audit/check-final-release.py
```

All three exit 0; final-build.log, final-release.log and final-release-checks.json
record the results. All 13 binary/package checks remain true on the corrected source.

`make release CANDIDATE=bb97b20e7de12ae60ab2fd9f254824cc8c832536` returns make 2,
verifier 65, `NOT_READY`: no readiness milestone is in REVIEW. Report:
`.artifacts/release/20261021T165931Z-32585/report.md`. The initial sandbox-limited
attempt could not materialize its temporary snapshot; the ordinary authorized retry
produced this report. No checklist, archive, upload or submission was created.

The declared `make milestone ID=M08` was also executed: make 2, verifier 65,
`final-milestone-gate.log`. It refuses the dirty working tree (audit records and the
separate scheme edit), before any tests. The unrelated edit was not reverted or
stashed for a gate pass. M08 remains BLOCKED by real hardware regardless of this
checkout preflight. Supplemental immutable-source results are not a milestone pass.

The bb97b20 selected matrix completed on watchOS 10 with **345 passed, 6 failed,
0 skipped**, exit 65 (`final-watchos10.xcresult`, `final-watchos10-summary.json`).
All 332 core/StoreKit tests and all three Access tests passed. The six remaining
failures exposed saved-action navigation, missing Back, or the injected old XCTest
framework crashing during accessibility snapshots. On watchOS 26.1 the same bb97b20
source passed **336/336, 0 failures/skips**, exit 0 (`final-watchos26.xcresult`,
`final-watchos26-summary.json`): 332 core/StoreKit, three Access tests and the original
score-correction test that failed on 405967a. `run-final-26.sh` preserves its command.
These results belong to bb97b20, not the later navigation corrections.

## watchOS 10 navigation and test-runtime corrections

Saved Finish and correction actions persisted their data but could leave the old
screen visible on watchOS 10. Finish now calls its presenter's completion callback
only after `live.showsResult`; correction calls its existing close callback for
`.saved` as well as `.unchanged`. Errors retain the existing screen and recovery UI.
The parent's existing state observers remain for other state transitions.

The serving screen had no Back button on watchOS 10. A destination-only toolbar
modifier at `129fea6f115f2e51b175de6837e90e7e21c9161f` did not fix it and was
removed. The successful correction makes the score navigation bar visible while
serving confirmation is pending, before pushing the serving screen. Ordinary score
presentation remains unchanged. The original accessibility/live-score test passes
with this correction: `serving-bar.xcresult`, **1 passed, 0 failed/skipped**, exit 0.
The saved Finish and largest-text correction tests also pass with the callbacks:
`explicit-navigation.xcresult`, **2 passed, 1 failed, 0 skipped**, exit 65; its sole
failure was the missing Back subsequently fixed by the serving-bar change.

Three longer UI tests crashed with EXC_BAD_ACCESS in `_platform_strcmp` called by
`XCTAutomationSupport runtime_issue_os_log_fault_callback`, with
`__LIBTRACE_CLIENT_QUARANTINED_DUE_TO_HIGH_LOGGING_VOLUME__` in the log stack.
Saved reports: `watchos10-correction-crash.ips`, `watchos10-legal-crash.ips`.
The injected runtime framework was version 10.0/build 22179.2.3. The installed
Xcode framework is version 16.0/build 25228, declaring MinimumOSVersion 10.0.
For the diagnostic/final supplemental test run only, the UI target app's
`DYLD_FRAMEWORK_PATH` in a copied xctestrun prepends:

```
/Applications/Xcode.app/Contents/Developer/Platforms/WatchSimulator.platform/Developer/Library/PrivateFrameworks:
```

The original path follows it. `tooling-loaded-image.txt` records vmmap confirmation
that the current Xcode framework loaded. No runtime image or Xcode installation was
patched; no app assertion, accessibility audit or application log was disabled.
`-collect-test-diagnostics never` prevents the separate stalled post-run sysdiagnose
collection; test assertions and screenshot attachments remain. The shipping Release
app does not load XCTest. Legal/support and correction tests that previously crashed
completed under this configuration. This is a supplemental tooling workaround,
not evidence that the repository's default gate automatically uses that framework.

## Expanded compatibility candidates

`389edb80d602d730d02e830442886788f328d308` contains all six changed Swift files.
`candidate-source-comparison.json` checks all 137 tracked App files against `git show`
for that exact SHA in `/private/tmp/padel-score-ui-probe`; all match. No temporary
AX logging or diagnostic test changes remain in those sources. The separate shared
scheme edit in the working checkout is excluded.

```sh
xcodebuild build-for-testing -project /private/tmp/padel-score-ui-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-ui-safe-derived
xcodebuild clean build -project /private/tmp/padel-score-ui-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-candidate-release CODE_SIGNING_ALLOWED=NO
make release CANDIDATE=389edb80d602d730d02e830442886788f328d308
```

Release gate: make 2, verifier 65, `NOT_READY`, at 2026-10-21T17:35:44Z.
Report: `.artifacts/release/20261021T173544Z-83610/report.md`.
No readiness milestone is in REVIEW; no checklist, archive or submission is created.

Both build commands exit 0 (`candidate-build.log/.exit`, `candidate-release.log/.exit`).
`python3 .artifacts/watchos10-audit/check-candidate-release.py` exits 0;
`candidate-release-checks.json` records all 13 checks as true.

The watchOS 10 command runs from the separate managed experiment checkout. Each wrapper acquires its own device
lease and supplies the explicit bound destination. The following is the exact test
command, also retained in `run-candidate10.sh`:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-ui-safe-derived/Build/Products/PadelScore-watchos10-current-tooling.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/candidate-watchos10.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/AccessibilityUITests -only-testing:PadelScoreWatchUITests/BootstrapUITests -only-testing:PadelScoreWatchUITests/LargeTextUITests -only-testing:PadelScoreWatchUITests/LiveScoreUITests/testANewSetWaitsForItsServingOrder -only-testing:PadelScoreWatchUITests/CorrectionUITests/testLeavingWithChangesAsksAndKeepsTheSavedGame -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testAFinishThatCannotBeSavedKeepsTheGame'
```

The completed `candidate-watchos10.xcresult` reports **352 passed, 2 failed,
0 skipped, 354 total**, exit 65, UTC 17:35:28–17:48:46. All original 351 selected
checks passed. The added finish-save-failure test passed. The two new failures were
Cancel leaving the editor screen open and confirmed serving leaving its setup open.
Both operations had updated model/storage state; root navigation observers did not
remove the pushed screens on this runtime. The follow-up commit
`739f2a38da71aadc9a9dc5bde37c4e5e21f9421d` explicitly removes editor routes on
discard and serving routes after successful confirmation. No route closes after a
failed save.

Screens exported from the original new-set test confirm the restored Back button
and readable pending-set layout: `candidate-new-set-screens/BD48C7FB-606F-4064-84C7-8D68C5D7D8CA.png`
and `B52691EF-C027-42AC-8D12-8E1B04E1EC28.png`, both visually inspected.
The XCTest accessibility audit also passes for those states. This visual evidence
precedes the additional confirmation callback; the layout is unchanged.

The expanded follow-up uses `run-revised10.sh`: all core tests, three correction
journeys, all six FinishResume tests, serving confirmation and its accessibility
journey. It exposed additional off-screen direct test taps on correction minus and
rule controls, and next-game setup staying open after the new game had saved.
The correction helper now scrolls these controls through the existing stricter
safe-area helper; the maximum iteration count and all value assertions are unchanged.
The visible setup destination reports the active game's new identity to its
presenter, which clears the previous result's setup routes. Failed or paywalled
starts have no active-game identity and do not close.

`revised-watchos10.xcresult` completed at 17:56:33Z: **338 passed, 5 failed,
0 skipped, 343 total**, exit 65. The original serving-confirmation failure passed;
Cancel returned to the menu and reached the later value-editing portion of its test.
Three correction tests failed on direct taps outside the safe visible area. The
other failures were next-game setup (described above) and Back from the menu after
resuming a match. The six FinishResume methods ran: four passed, those two failed.
All 332 core/StoreKit tests passed. `revised-watchos10-summary.json` contains the
exact counts, including expanded parameterized counts separately.

`aafa1b91caac2b1f559592f67e1723a623b4ce73` fixes the next-game setup and correction
taps. `8017a4f931e8121e187034cdbe9273553b070fa4` then generalizes the navigation-bar
correction: the score keeps the system navigation bar available before any push,
without adding a navigation title. Geometry still places the context in the clock
row. Tests explicitly check ordinary large text without scrolling, largest-text
stacking, accessibility, menu Back, serving Back and confirmation.

## Final exact-source regression

Final source: `8017a4f931e8121e187034cdbe9273553b070fa4`.
`complete-source-comparison.json`: all 137 tracked App files match the exact SHA.
No diagnostic test edits remain. `complete-build.log/.exit` records Debug
build-for-testing (same project/destination/derived-data command above), exit 0.
The final clean Release build uses the same device command above and is recorded
in `complete-release.log/.exit`; binary checks use `check-candidate-release.py`.

The two runtime regressions use distinct owned device leases and read-only shared
build products. watchOS 10 uses the documented copied xctestrun/current automation
framework; watchOS 26.1 uses the unmodified generated xctestrun. The primary runtime
binding remains unchanged. Exact commands:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-ui-safe-derived/Build/Products/PadelScore-watchos10-current-tooling.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/complete-watchos10.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testTheLiveScorePassesTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testFinishingAndTheResultPassTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreFitsWithoutScrollingAtLargeText -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreStacksAndScrollsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/LargeTextUITests/testACorrectionReflowsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/CorrectionUITests/testLeavingWithChangesAsksAndKeepsTheSavedGame -only-testing:PadelScoreWatchUITests/CorrectionUITests/testAFailedSaveKeepsTheDraftAndTheSavedGame -only-testing:PadelScoreWatchUITests/CorrectionUITests/testCorrectingTheScoreAsksForServingAndIsUndoneWhole -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testFinishingAMatchSavesItsResultAndResumes -only-testing:PadelScoreWatchUITests/LiveScoreUITests/testANewSetWaitsForItsServingOrder'
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-ui-safe-derived/Build/Products/PadelScore_PadelScore_watchsimulator27.0-arm64-x86_64.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/complete-watchos26.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testTheLiveScorePassesTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testFinishingAndTheResultPassTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreFitsWithoutScrollingAtLargeText -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreStacksAndScrollsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/LargeTextUITests/testACorrectionReflowsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/CorrectionUITests/testLeavingWithChangesAsksAndKeepsTheSavedGame -only-testing:PadelScoreWatchUITests/CorrectionUITests/testAFailedSaveKeepsTheDraftAndTheSavedGame -only-testing:PadelScoreWatchUITests/CorrectionUITests/testCorrectingTheScoreAsksForServingAndIsUndoneWhole -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testFinishingAMatchSavesItsResultAndResumes -only-testing:PadelScoreWatchUITests/LiveScoreUITests/testANewSetWaitsForItsServingOrder'
```

The completed matrix at 8017a4f reports:

| Runtime | Logical passed / failed / skipped | Exit | Bundle |
| --- | --- | --- | --- |
| watchOS 10.0 | 345 / 1 / 0 (346 total) | 65 | complete-watchos10.xcresult |
| watchOS 26.1 | 346 / 0 / 0 (346 total) | 0 | complete-watchos26.xcresult |

The only remaining failure on 10.0 was starting the next game from its result.
The visible destination's onChange did not solve it on that runtime and was removed.
All correction, cancellation, error recovery, serving, finish/resume and large-text
regressions in this matrix passed. `complete-watchos*-summary.json` preserves
logical and expanded parameterized totals separately. Release build and 13 package
checks pass at this SHA (`complete-release.log/.exit`, `complete-release-checks.json`).
Its release gate remains NOT_READY: make 2/verifier 65, report
`.artifacts/release/20261021T175835Z-32111/report.md`.

## Explicit start completion and final candidate

`b91a49d07179958673132e7e876d6629130e6471` makes NewGameFlow.start/retryStart
return true only after the store operation succeeds; all guards and failures return
false. Setup's Start/Retry actions report that success to the presenting stack,
which clears its routes. There is no retained callback in the model and no second
source of purchase access. The visible onChange experiment is removed. Existing
NewGameFlow tests now additionally assert these results for valid Match/Americano,
missing values, rejected access, an already active game, failed save/retry and a
successful repaired retry; all previous data-integrity assertions remain.

A fresh `git archive` snapshot lives at `/private/tmp/padel-score-confirmed`.
`confirmed-source-comparison.json`: all 137 tracked App files match the exact SHA.
Debug build-for-testing and clean unsigned device Release both exit 0:

```sh
xcodebuild build-for-testing -project /private/tmp/padel-score-confirmed/App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-confirmed-derived
xcodebuild clean build -project /private/tmp/padel-score-confirmed/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-candidate-release CODE_SIGNING_ALLOWED=NO
python3 .artifacts/watchos10-audit/check-candidate-release.py
make release CANDIDATE=b91a49d07179958673132e7e876d6629130e6471
```

Build logs: `confirmed-build.log/.exit`, `confirmed-release.log/.exit`.
All 13 checks true: `confirmed-release-checks.json/.exit` (exit 0).
Release gate: make 2/verifier 65, NOT_READY, 2026-10-21T18:08:57Z;
`.artifacts/release/20261021T180857Z-36727/report.md`. No readiness milestone in
REVIEW; no archive, checklist, upload or submission.

Targeted final tests cover all core/StoreKit tests, all Access UI tests, next game
from the result, initial Match and Americano creation and failed-start recovery.
Exact commands, also retained in `run-confirmed10.sh` and `run-confirmed26.sh`:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-confirmed-derived/Build/Products/PadelScore-watchos10-current-tooling.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/confirmed-watchos10.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly -only-testing:PadelScoreWatchUITests/NewGameUITests/testMatchStartsOnceEveryValueIsChosenAndReopens -only-testing:PadelScoreWatchUITests/NewGameUITests/testAmericanoStartsWithTheNumberEditors -only-testing:PadelScoreWatchUITests/NewGameUITests/testFailedSaveStartsNothingAndKeepsTheChoices'
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-confirmed-derived/Build/Products/PadelScore_PadelScore_watchsimulator27.0-arm64-x86_64.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/confirmed-watchos26.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/AccessUITests -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly -only-testing:PadelScoreWatchUITests/NewGameUITests/testMatchStartsOnceEveryValueIsChosenAndReopens -only-testing:PadelScoreWatchUITests/NewGameUITests/testAmericanoStartsWithTheNumberEditors -only-testing:PadelScoreWatchUITests/NewGameUITests/testFailedSaveStartsNothingAndKeepsTheChoices'
```

At b91a49d, the selected start-flow matrix completes as follows:

| Runtime | Passed / failed / skipped | Exit | Bundle |
| --- | --- | --- | --- |
| watchOS 10.0 | 338 / 1 / 0 (339 total) | 65 | confirmed-watchos10.xcresult |
| watchOS 26.1 | 339 / 0 / 0 (339 total) | 0 | confirmed-watchos26.xcresult |

The next-game result journey now passes on both runtimes. The remaining 10.0
failure is NewGameUITests.testMatchStartsOnceEveryValueIsChosenAndReopens at
oneAdvantage.isSelected: the preceding direct tap did not select the clipped rule
row. The final correction scrolls that row into view before tapping, preserving
selection, setup, start, Crown non-scoring and relaunch assertions.

## Visual regression and final verification

Inspection of `complete-score-screens/E7FC4B0E-F8AE-413A-A3C5-28E0BAB5C6A2.png`
found missing Games/Sets captions even though layout bounds and accessibility
checks passed. The matching original 405967a screenshot,
`baseline-score-screens/B44ACCE3-575A-471D-8647-D6007033A1AE.png`, has both captions.
A direct launch of b91a49d, without XCTest injection, reproduces the missing text
(`standalone-match10.png`, command/log/exit in standalone-match10.log/.exit).
Thus the issue was not dismissed as a test-framework artifact. Giving the middle
caption its intrinsic horizontal size fixes the watchOS 10 layout while retaining
system Back. Direct launch confirms both captions visible in
`standalone-label-fixed10.png` (exit 0), visually inspected. Match and Americano
retain their compact layout; no navigation title was added to the score.

The direct-render commands run inside the experiment checkout's simulator lease:

```sh
Scripts/simulator.sh run -- bash -c 'set -e; env SIMCTL_CHILD_PADEL_UITEST_STORE=visual-standalone-10 SIMCTL_CHILD_PADEL_UITEST_SEED=matchSetPoint xcrun simctl launch --terminate-running-process "$IOSAI_SIMULATOR_UDID" com.dziachenka.padelscore.watchapp -AppleLanguages "(en)" -AppleLocale en_US -UIPreferredContentSizeCategoryName UICTContentSizeCategoryL; sleep 2; xcrun simctl io "$IOSAI_SIMULATOR_UDID" screenshot /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/standalone-match10.png'
Scripts/simulator.sh run -- bash -c 'set -e; xcrun simctl install "$IOSAI_SIMULATOR_UDID" /private/tmp/padel-score-label-derived/Build/Products/Debug-watchsimulator/PadelScoreWatch.app; env SIMCTL_CHILD_PADEL_UITEST_STORE=visual-label-fixed-10 SIMCTL_CHILD_PADEL_UITEST_SEED=matchSetPoint xcrun simctl launch --terminate-running-process "$IOSAI_SIMULATOR_UDID" com.dziachenka.padelscore.watchapp -AppleLanguages "(en)" -AppleLocale en_US -UIPreferredContentSizeCategoryName UICTContentSizeCategoryL; sleep 2; xcrun simctl io "$IOSAI_SIMULATOR_UDID" screenshot /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/standalone-label-fixed10.png'
```

Final source: **f287cdfa581fa6d1cc6974e91794321d02399804**.
`verified-source-comparison.json` confirms all 137 App files in the tested source
copy match that exact commit. Final build/package commands:

```sh
xcodebuild build-for-testing -project /private/tmp/padel-score-label-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-label-derived
xcodebuild clean build -project /private/tmp/padel-score-label-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-candidate-release CODE_SIGNING_ALLOWED=NO
python3 .artifacts/watchos10-audit/check-candidate-release.py
make release CANDIDATE=f287cdfa581fa6d1cc6974e91794321d02399804
make milestone ID=M08
```

Debug/Release builds and all 13 binary checks exit 0: `label-build.log/.exit`,
`verified-release.log/.exit`, `verified-release-checks.json/.exit`.
Release gate returns make 2/verifier 65, NOT_READY at 2026-10-21T18:16:41Z;
`.artifacts/release/20261021T181641Z-43099/report.md`. Declared milestone command
returns make 2/verifier 65 before tests because of the dirty checkout (our audit
records and the separately preserved scheme edit), `verified-milestone-gate.log`.
Neither is claimed as a passing release or milestone verification. No archive,
checklist, upload or review submission was created.

The final targeted matrix covers all 332 core/StoreKit checks, initial Match start
and relaunch, next game from a result, live-score accessibility, large-text fit and
maximum-text stacking. Exact commands are also retained in `run-verified10.sh` and
`run-verified26.sh`:

```sh
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-label-derived/Build/Products/PadelScore-watchos10-current-tooling.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/verified-watchos10.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/NewGameUITests/testMatchStartsOnceEveryValueIsChosenAndReopens -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreFitsWithoutScrollingAtLargeText -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreStacksAndScrollsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testTheLiveScorePassesTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly'
Scripts/simulator.sh run -- bash -c 'exec xcodebuild test-without-building -xctestrun /private/tmp/padel-score-label-derived/Build/Products/PadelScore_PadelScore_watchsimulator27.0-arm64-x86_64.xctestrun -destination "$IOSAI_SIMULATOR_DESTINATION" -collect-test-diagnostics never -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/verified-watchos26.xcresult -only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/NewGameUITests/testMatchStartsOnceEveryValueIsChosenAndReopens -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreFitsWithoutScrollingAtLargeText -only-testing:PadelScoreWatchUITests/LargeTextUITests/testTheLiveScoreStacksAndScrollsAtTheLargestTextSize -only-testing:PadelScoreWatchUITests/AccessibilityUITests/testTheLiveScorePassesTheAccessibilityAudit -only-testing:PadelScoreWatchUITests/FinishResumeUITests/testANewGameKeepsTheResultForViewingOnly'
```

Final selected results at f287cdfa581fa6d1cc6974e91794321d02399804:

| Runtime | Logical passed / failed / skipped | Exit | UTC | Result bundle |
| --- | --- | --- | --- | --- |
| watchOS 10.0 | 337 / 0 / 0 | 0 | 2026-10-21T18:16:26.102000+00:00 → 2026-10-21T18:19:19.026000+00:00 | verified-watchos10.xcresult |
| watchOS 26.1 | 337 / 0 / 0 | 0 | 2026-10-21T18:17:15.573000+00:00 → 2026-10-21T18:20:29.729000+00:00 | verified-watchos26.xcresult |

Each bundle has 337 logical tests (328 Swift, 4 StoreKit, 5 UI); its expanded
single-device parameterized count is 681 passed, 0 failed/skipped. The JSON summaries
preserve both representations. These are selected final regressions, not a claim
that the entire shared UI scheme or milestone gate ran at this SHA. Earlier broader
matrices and the failures that prompted each correction remain above.

All failures observed in the exercised journeys were reproduced, corrected and
rechecked. Required physical coverage and the full M10 matrix remain open. Static
verification and project-status validation exit 0. Optional swiftlint/swiftformat/
shellcheck were not enabled and did not run; they are not claimed passed. The
continuity check refuses the uncommitted separate scheme edit; immutable snapshots
exclude it, and no clean-working-checkout/archive identity is asserted.

## Final Release launch on the minimum runtime

The final f287cdfa581fa6d1cc6974e91794321d02399804 source also builds in Release
for the simulator and launches directly on watchOS 10.0 without XCTest or test seed
parameters. Both commands exit 0:

```sh
xcodebuild build -project /private/tmp/padel-score-label-probe/App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS Simulator' -derivedDataPath /private/tmp/padel-score-release10-final
Scripts/simulator.sh run -- bash -c 'set -e; xcrun simctl install "$IOSAI_SIMULATOR_UDID" /private/tmp/padel-score-release10-final/Build/Products/Release-watchsimulator/PadelScoreWatch.app; xcrun simctl launch --terminate-running-process "$IOSAI_SIMULATOR_UDID" com.dziachenka.padelscore.watchapp -AppleLanguages "(en)" -AppleLocale en_US; sleep 2; xcrun simctl io "$IOSAI_SIMULATOR_UDID" screenshot /Users/Shared/D/ios/padel-score/.artifacts/watchos10-audit/verified-release10-launch.png'
```

Build: `verified-release10-build.log/.exit`. Install/launch: `verified-release10-launch.log/.exit`,
PID 59734. Visually inspected `verified-release10-launch.png` shows the normal
New game screen with Match and Americano. This is final Release startup/rendering
evidence; it does not claim a complete manual Release journey. The owned simulator
lease was released. The downloaded runtime image and managed test device remain
available for later checks.

## Live store and website evidence

Read-only ASC requests: asc-version.json, asc-iap.json, asc-reviews.json,
asc-listing.json, asc-privacy-url.json, asc-screenshots.json, asc-rating.json,
asc-primary-category.json, asc-secondary-category.json, asc-build.json,
asc-review-info.json. Private review contact remains only in ignored local evidence.

App 6825393194 is PREPARE_FOR_SUBMISSION; IAP 6825393394 is READY_TO_SUBMIT;
three screenshots COMPLETE with no errors; build relation is null; review submissions
are empty. No metadata mutation, archive, upload or App Review request was made.

site-check.json and live-*.html/headers preserve HTTP 200, source byte equality and
CSP for all four pages. All three legal/support pages have the corrected Gmail;
the home page links to Support. Python urllib received 403; curl readbacks succeeded.
An initial ad-hoc assertion wrongly expected the email on the home page too; the
correct product check verifies its Support link. This did not change any app test.

## Findings and remaining evidence

- **Environment blocker:** unavailable real Watch: sandbox transactions and fresh-install
  restore, offline StoreKit behavior, actual VoiceOver speech/order, haptics, Crown,
  lock/wrist-down return, on-court readability and oldest-device performance.
- **Minimum-runtime scope:** official watchOS 10.0 is installed and runs. The
  reproduced navigation, clipped-tap and count-caption failures were corrected and
  rechecked in selected regressions. This is not a complete latest-SHA run of every
  UI journey or M10 acceptance, and uses the documented XCTest compatibility override.
- **Release warnings:** the clean build emits container interface-orientation and
  launch-configuration warnings and an AppIntents metadata-extraction warning
  because the app has no AppIntents framework. No failure or App Store acceptance
  is inferred; inspect the Watch-only archive in the owner's Organizer step.
- **Documentation P2:** the opening of ARCHITECTURE still calls H1 open, while its
  approved public-site/privacy sections and PRODUCT carry the resolved H1 values.
  No missing product decision is inferred from the stale opening.
- Full functional lock/termination/offline journeys, complete visual/copy and spoken
  accessibility passes remain requirements of M10, not waived by this record.

## Next step

Keep the installed runtime and managed experiment device for the full minimum-OS
matrix in M10. Keep M08/M09 blocked until required hardware evidence and declared
gates pass, then carry out M10's single complete final-polish session. Do not submit for App Review.
