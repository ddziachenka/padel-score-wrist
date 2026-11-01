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

Current/minimum runtime supplements, physical build 4 installation/retest, and
fresh galleries are still required. `make static` after the fix currently exits
Make **2** / script **65** because the unchanged strict material validator detects
the shipping project fingerprint changed since build 3 captures. Report:
`.artifacts/M29/static-fix.log`. Both complete Watch/phone galleries must be
recaptured and imported at one frozen new SHA; old provenance remains preserved.
The source guard is working and will not be weakened or hash-updated around the
missing captures. Full M29 gate and remaining physical coverage remain pending.
