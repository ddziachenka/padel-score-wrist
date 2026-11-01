# M29 — setup practice navigation correction

Owner reported on physical Watch 1.0 (3) that Try gestures did not open while
creating a game, although the active-game entry worked. Builder reproduced the
result-based setup defect before changing production source. This is a Builder
self-review/correction record, not independent review or release approval.

## Cause and change

Initial NewGameView owns a `NavigationStack<[NewGameFlow.Route]>`. The result's
Play again and New game flows instead use LiveScoreView's combined
`NavigationStack<[GameRoute]>`, mapping `flow.path` through `.newGame(route)`.
The setup practice entry used a direct `NavigationLink<NewGameFlow.Route>`;
the result's stack has no destination for that raw type. Other setup rows already
append through their flow. Practice now appends `.gesturePractice` through the
same flow, preserving both navigation contexts, draft and original result.

Added one regression for each result entry. Both assert practice opens, its real
three-second teaching action settles, returning preserves gestures OFF and an
editable draft, and Back retains the original 6–4 result without starting a game.
Existing cold-start setup/practice coverage remains intact. Test file SHA-256 is
unchanged before/after: `3a747b2891b0e4bdc5a05ecf6ca86d28629951382342f7f3ab65b70dcd2ac2e2`.

All twenty app/extension/test `CURRENT_PROJECT_VERSION` values advance 3 → 4 to
force a distinguishable paired-phone Watch update without uninstalling owner data.
The two exact installed-version assertions advance to exactly 4; neither is
loosened. Marketing version 1.0 and schema 5 are unchanged.

## Reproduction and verification

Baseline production source: `d92b9e9e9250e309a074953faa10ed4c06eddffb`, plus only
the new UI regression cases in the test target. Production bytes were unchanged
during reproduction; hashes in `.artifacts/M29/setup-practice-baseline-identity.json`.
Both commands use this checkout's owned current Watch simulator
`36C94878-A329-4B51-92E9-4D72A40B178B`, watchOS 27.0, no desktop or foreign device.

Before, exact command:

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/setup-practice-before.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromPlayAgainPreservesTheResultAndDraft -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromNewGamePreservesTheResultAndDraft CODE_SIGNING_ALLOWED=NO test
```

Exit **65**, UTC 2026-11-01T10:20:59.580Z–10:22:34.916Z. Two definitions/two
invocations, **0 passed, 2 failed**, zero skipped/expected/runtime warnings. Both
fail exactly at the practice-screen existence assertion. Log:
`.artifacts/M29/setup-practice-before.log`; native summary:
`.artifacts/M29/setup-practice-before-summary.json`. Raw bundle is preserved.

After, exact command (same destination, tests and assertions):

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/setup-practice-after.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromPlayAgainPreservesTheResultAndDraft -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromNewGamePreservesTheResultAndDraft CODE_SIGNING_ALLOWED=NO test
```

Exit **0**, UTC 2026-11-01T10:24:04.170Z–10:25:26.412Z. Two definitions/two
invocations, **2 passed**, zero failed/skipped/expected/runtime warnings. Log:
`.artifacts/M29/setup-practice-after.log`; native summary:
`.artifacts/M29/setup-practice-after-summary.json`. These targeted mutable runs
prove this regression/correction only, not full M29 verification.

The initial sandboxed xcresult summary extraction exited 64 because Xcode could
not access its TestReport cache; the same extraction outside the sandbox passed.
No test was retried or relabelled and no result-bundle parser was changed.

## Remaining work

Committed correction: `0d535ac26a543d37333f3c457bbfba1316663d90` on main. The
current-watchOS 27 supplement passes at that SHA: exit 0, 13 definitions / 39
invocations, zero failed/skipped/expected/runtime warnings. Native report:
`.artifacts/M29/setup-practice-current-supplement.xcresult`; summary and test tree
have the matching `-summary.json` and `-tests.json` names. It includes installed
version, setup practice, native accessibility and the complete AppConfiguration
and GestureInput classes. This remains targeted verification, not the M29 gate.

UTC 2026-11-01T10:29:30.530Z–10:30:41.761Z. Exact command:

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/setup-practice-current-supplement.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/AppConfigurationTests -only-testing:PadelScoreWatchTests/GestureInputTests -only-testing:PadelScoreWatchUITests/BootstrapUITests/testAboutNavigationAndInstalledVersion -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupOffersOffAndPracticeDoesNotStartGame -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testEnabledScoreAndTeachingPassNativeAccessibilityAudit CODE_SIGNING_ALLOWED=NO test
```

The first minimum-watchOS 10 supplement at the same SHA exited **65**:
15 definitions / 41 invocations, 13 definitions passed and 2 failed, zero
skipped/expected/runtime warnings. UTC 2026-11-01T10:32:15.266Z–10:47:27.525Z.
Report `.artifacts/M29/setup-practice-minimum-supplement.xcresult`, matching log,
summary and test tree preserved. About failed during `app.launch` with
“has not loaded accessibility”; existing cold-start practice expected 1:0 after
3.3 seconds but observed 0:0. Both new result-navigation regressions passed.
These failures are not labelled pre-existing or waived. Exact command:

```sh
bash .artifacts/M25/runtime-profile.sh watch-minimum run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-minimum -resultBundlePath .artifacts/M29/setup-practice-minimum-supplement.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/AppConfigurationTests -only-testing:PadelScoreWatchTests/GestureInputTests -only-testing:PadelScoreWatchUITests/BootstrapUITests/testAboutNavigationAndInstalledVersion -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupOffersOffAndPracticeDoesNotStartGame -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testMinimumRuntimeKeepsTouchScoringAndOffSetup -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromPlayAgainPreservesTheResultAndDraft -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSetupPracticeFromNewGamePreservesTheResultAndDraft CODE_SIGNING_ALLOWED=NO test
```

Read-only process sampling showed Xcode waiting for its own `simctl diagnose`
with a 600-second timeout after the tests finished. It completed naturally, exit
65; no process was killed. Diagnostic screenshot shows the Watch face during the
launch failure. A subsequent shutdown of only owned D5A214D9 returned 149 because
Xcode had already shut it down; boot and bootstatus then exited 0. No device was
erased, foreign device touched, or shared service restarted. The complete same
supplement reran with a fresh result name and only automatic diagnostic
collection disabled; every test and assertion was unchanged. The second bundle,
`.artifacts/M29/setup-practice-minimum-supplement-2.xcresult`, exits 65, 15
definitions / 41 invocations: 14 passed definitions, 1 failed; zero skipped,
expected or runtime warnings. UTC 2026-11-01T10:49:08.431Z–10:51:15.201Z.
About and both new result-navigation regressions pass. Only the existing
cold-start practice assertion still fails. The exact command above changes only
the result name to `setup-practice-minimum-supplement-2.xcresult` and adds
`-collect-test-diagnostics never`; no test filter or assertion changes.

### Cold-start test input correction

Native XCTest video and extracted frames establish a missed tap, not a slow
timer: the Double Tap button is clipped at the bottom of the 40mm watchOS 10
screen, and remains Double Tap with 0:0 throughout the wait. There is no pending
proposal. The existing strict `scrollToAndTap(in:)` helper already documents and
handles this watchOS 10 curved-edge case. Apply it to this action too, and add an
immediate **Pending: US** assertion. Keep the original 3.3-second wait and exact
1:0 assertion, with no timeout increase or condition. Production timer unchanged.

The same focused check reproduces at both current production SHA
`0d535ac26a543d37333f3c457bbfba1316663d90` and the complete original App sources
at baseline `d92b9e9e9250e309a074953faa10ed4c06eddffb`. The latter is an isolated
archive, verified byte-for-byte against Git for all 198 App files; its own original
Scripts are also included. Primary checkout/branch is never switched. Its first
preparation omitted Scripts and failed the unmodified build-script guard before
running any test; that failed bundle is preserved, not a reproduction or a pass.

All three focused commands use the same owned D5A214D9 simulator, project/scheme,
Debug, derived-data path, one exact test filter, no parallel testing, no diagnostic
collection and signing disabled. Exact argv/cwd are retained in the matching
`*-command.json` files; only source cwd/result path differ. Wrapper commands:

```sh
bash .artifacts/M25/runtime-profile.sh watch-minimum run python3 .artifacts/M29/run-practice-launch-probe.py /Users/Shared/D/ios/padel-score practice-tap-current-before
bash .artifacts/M25/runtime-profile.sh watch-minimum run python3 .artifacts/M29/run-practice-launch-probe.py /Users/Shared/D/ios/padel-score/.artifacts/M29/baseline-d92 practice-tap-baseline-before-2
bash .artifacts/M25/runtime-profile.sh watch-minimum run python3 .artifacts/M29/run-practice-launch-probe.py /Users/Shared/D/ios/padel-score practice-tap-current-after
```

| Run / native bundle under `.artifacts/M29/` | Exit | UTC 2026-11-01 | Definitions / invocations |
| --- | --- | --- | --- |
| `practice-tap-current-before.xcresult` | 65 | 10:53:51.770–10:54:27.034 | 1/1, failed at 0:0 versus 1:0 |
| `practice-tap-baseline-before-2.xcresult` | 65 | 10:56:38.784–10:57:07.001 | 1/1, same assertion failure |
| `practice-tap-current-after.xcresult` | 0 | 10:57:26.816–10:58:09.350 | 1/1 passed, including new pending assertion |

All have zero skipped/expected/runtime warnings. Matching logs/native summaries,
the original video and diagnostic frames remain in `.artifacts/M29/`. Full minimum
supplement must now run with the corrected test. This is a test-input correction,
not acceptance of either failed suite or an independent review.

Minimum runtime supplement, physical build 4 Watch installation/retest, and
fresh galleries are still required. `make static` after the fix currently exits
Make **2** / script **65** because the unchanged strict material validator detects
the shipping project fingerprint changed since build 3 captures. Report:
`.artifacts/M29/static-fix.log`. Both complete Watch/phone galleries must be
recaptured and imported at one frozen new SHA; old provenance remains preserved.
The source guard is working and will not be weakened or hash-updated around the
missing captures. Full M29 gate and remaining physical coverage remain pending.
