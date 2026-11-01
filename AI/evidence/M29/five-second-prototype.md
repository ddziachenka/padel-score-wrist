# M29 — owner-approved five-second timing prototype

Owner selected “Прототип 5 секунд (Recommended)” on 2026-11-01 after intermittent
physical two-series recognition on Watch build 4. [Decision](gesture-input-decision.md).
This is an experiment, not a ≥95% recognition/comfort pass or release approval.
M29 is IN_PROGRESS; the other physical requirements remain mandatory.

## Implementation and self-review

One production constant changes from three to five seconds in the existing shared
GestureInput reducer. One series proposes US, two select THEM, a third cancels.
The first activation fixes the deadline; further activations never extend it.
Visibility/lifecycle/revision cancellation, touch override, atomic commit/Undo,
no-motion architecture and schema 5 remain. Watch and explicitly simulated phone
teaching say five seconds in all 13 UI languages. Exact build identifiers advance
4 → 5 in all twenty project configurations and both version assertions.

Tests update their exact boundary from 2999/3000ms to 4999/5000ms. Expiry remains
at/after the deadline, and cancelled/stale-context observations move beyond the
new deadline so they cannot pass merely by checking too early. Timer-identity
coverage still exercises an expired old timer against a later pending sequence.
UI settle/cancellation waits move by exactly two seconds, preserving their margin;
no check is removed. A new unit regression tests second activation at 3500,4500,
4999ms, no premature award at three seconds, the unchanged 5000ms deadline and no
double commit. A new live UI regression checks Pending: US/no point after 3.2s,
then selects THEM and expects only their ordinary point.

## Mutable before/after evidence

Base main SHA `85ab8477149930025b894b68af707177242a254d`. Before run adds only the
new/updated gesture unit tests; production reducer is unchanged three seconds and
version remains 4. No production mutation occurs until this run finishes.

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/five-second-before.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/GestureInputTests -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Exit **65**, UTC2026-11-01T11:06:33.838Z–11:06:48.564Z. Five definitions / ten
invocations; three definitions pass, two fail (both exact five-second-selection
and late-second-series checks). Zero skipped/expected/runtime warnings. Raw
bundle, log and native summary retained under `.artifacts/M29/five-second-before*`.
This is the expected fail-before of the approved changed behavior, not a waived
failure of the old three-second product contract.

After five-second implementation, matching teaching and build-5 identity:

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/five-second-unit-after.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/GestureInputTests -only-testing:PadelScoreWatchTests/GestureScoringTests -only-testing:PadelScoreWatchTests/AppConfigurationTests -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Exit **0**, UTC2026-11-01T11:08:56.165Z–11:09:09.897Z. **26/26 definitions /
67/67 invocations**, zero failed/skipped/expected/runtime warnings. Includes all
gesture integration, failure/retry, Undo, completion accounting, migrations and
exact installed identity/localizations. Bundle, log and native summary under
`.artifacts/M29/five-second-unit-after*`. Frozen 242 App/Config/Scripts hashes:
`.artifacts/M29/five-second-source-inputs.json`; next commit will bind this exact
input set before UI verification and signed local build/install.

## Remaining work

Committed-source current/minimum UI and phone simulation checks; build/sign/install
1.0 (5), owner confirmation of Watch identity, and short real gesture/comfort
probes. No build-4 recognition result proves the five-second prototype. All full
M29 physical rows, final-source localized galleries/materials and six-domain
records, followed by the full unchanged milestone gate, remain incomplete.

## Committed-source UI, compatibility and physical phone follow-up

Exact frozen prototype SHA **e9053e7afce11877225fd58e826fcbeebd866bcf** matches all
242 mutable-tested App/Config/Scripts hashes. Current watchOS 27 UI: exit **0**,
**10/10 definitions/invocations**, zero failed/skipped/expected/runtime warnings,
UTC2026-11-01T11:10:57.211Z–11:15:13.837Z. Report
`.artifacts/M29/five-second-current-ui.xcresult`, matching log/summary/attachments.
The new late-second-series live regression passes, along with native accessibility,
About build 5, touch/Undo, cancellation/background, failures and both setup routes.
The saved-point attachment was taken during numeric animation (visible old zero);
its frame is not used as final pixel proof of the saved value. Native score/team
assertions pass; practice 1:0 and readable control captures were also inspected.

Exact current UI command (under `watch-current run`):

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination "platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/five-second-current-ui.xcresult -parallel-testing-enabled NO "-only-testing:PadelScoreWatchUITests/BootstrapUITests/testAboutNavigationAndInstalledVersion" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testFiveSecondWindowKeepsTheSecondSeriesAvailableAfterThreeSeconds" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSeriesTouchUndoAndSavedPreferenceOnRelaunch" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testThirdSeriesAndLeavingScoreCancelWithoutLatePoint" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testMenuOptInOffAndBackgroundCancellation" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSaveFailureKeepsScoreAndCancelDropsPendingGesture" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupOffersOffAndPracticeDoesNotStartGame" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromPlayAgainPreservesTheResultAndDraft" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromNewGamePreservesTheResultAndDraft" "-only-testing:PadelScoreWatchUITests/GestureScoringUITests/testEnabledScoreAndTeachingPassNativeAccessibilityAudit" -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Minimum watchOS 10: exit **0**, **31/31 definitions / 72/72 invocations**, zero
failed/skipped/expected/runtime warnings, UTC2026-11-01T11:17:11.497Z–11:19:45.665Z.
Report `.artifacts/M29/five-second-minimum.xcresult`, matching log/summary.
All gesture units/integration, exact installed identity and five setup UI cases
pass. One owned-device lease covers boot, bootstatus and tests; original Shutdown
is restored, cleanup exit 0. Exact wrapper:
`bash .artifacts/M25/runtime-profile.sh watch-minimum run python3 .artifacts/M29/run-five-second-minimum.py`.
Its exact Xcode command (also in `five-second-minimum-command.json`):

```sh
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-minimum -resultBundlePath .artifacts/M29/five-second-minimum.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/AppConfigurationTests -only-testing:PadelScoreWatchTests/GestureInputTests -only-testing:PadelScoreWatchTests/GestureScoringTests -only-testing:PadelScoreWatchUITests/BootstrapUITests/testAboutNavigationAndInstalledVersion -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupOffersOffAndPracticeDoesNotStartGame -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testMinimumRuntimeKeepsTouchScoringAndOffSetup -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromPlayAgainPreservesTheResultAndDraft -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromNewGamePreservesTheResultAndDraft -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Signed local Release build, strict deep signature verification, phone install,
phone app readback and launch all exit **0**. Same build command as build 4,
log `.artifacts/M29/device-build-5.log`; matching install/readback/signature logs
and JSON files use build5 names. Phone and embedded Watch are 1.0 (5); exact
source/executable identity `.artifacts/M29/candidate-identity-build5.json`.
Through paired-phone Watch settings, agent turned Show App OFF then ON under the
owner's existing test-data-removal authorization. ON screenshot is not independent
proof of installed Watch version. Direct Watch app listing again exits 1 with
Bluetooth L2CAP -6755; no live version readback is credited from that command.

Physical phone through Mirroring: five-second English instruction is readable;
single activations separated by tool overhead beyond the deadline settle US twice.
Two separate activations batched inside the window show Pending: THEM then settle
2:1. Three activations cancel; 2:1 remains after waiting beyond the deadline.
Reset returns 0:0. These are simulated activations, never native recognition trials.
Captures: `phone-build5-five-second-guide.png`, `phone-build5-them-settled.png`,
`phone-build5-cancel-no-late-point.png` under `.artifacts/M29/`.

`make static` on this SHA exits Make **2** / verifier **65**; log
`.artifacts/M29/static-prototype5.log`. All other static sections complete; one
source-bound material/site check fails because the old gallery project fingerprint
is stale. No hash-only refresh, waiver, parser or test weakening. Final complete
captures remain required after physical input/teaching direction settles.

## Owner feedback and teaching correction

Owner responds to the build-5 trial: very stable when one series first shows
Pending: US, then another series is made immediately; THEM is correct. That
sequence was not initially obvious. No exact 5-attempt outcome counts or separate
About version were supplied. This is qualitative evidence, not ≥95% proof. The
new learned cadence and longer window were tried together, so the improvement
cannot be attributed to window length alone.

Build 6 keeps the identical five-second reducer and adds an explicit second-series
cue in teaching on Watch/phone and in the Watch action's accessibility hint.
Every locale quotes its real localized Pending: US value. A new practice UI
regression reads the cue, performs the explained US→THEM preview and verifies only
0:1 settles with no real game/opt-in side effect. Phone simulation now also asserts
0:0 at 3.2 seconds before the unchanged total 5.3-second settle wait. Exact build
assertions become 6, not ranges. No production input/timing change from build 5.

Owner also requests keeping the app open and avoiding inactivity. Apple documents
that ordinary apps cannot override frontmost duration in watchOS 7+; per-app
Return to Clock and Wake Duration settings are investigated separately. No fake
workout, motion collection, permissions or bypass of inactive-input cancellation.
