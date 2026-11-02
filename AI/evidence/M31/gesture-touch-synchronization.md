# M31 gesture UI synchronization correction

Builder correction/self-review. Production gameplay, gesture mechanics and UI are
unchanged. No automatic verification exception is requested or used.

## Failure and scope

The complete M31 run at16a7a094ac863a416b61aa701d3c7b37d14f445d failed the
late manual-touch assertion: THEM15 instead of30. Exact full counts/report and
source/log timing are in [preserved failures](verification-failures.md).
LiveScore.award applies the existing500ms prior-rally bounce guard to every awarded
point, including a gesture commit. Starting the next simulated rally before that
interval expires is not the scenario's intended test of overriding a pending input.
Existing LiveScoreTests.settleTime checks both sides of that500ms boundary.

Five isolated repetitions of the unchanged compiled test at16a7 did not reproduce
the late-touch failure. They yielded4passed/1failed invocations; the first failed
at the initial Pending: US assertion. This separate initial observation does not
prove a particular lifecycle defect. Readiness was made explicit as an additional
precondition, and the same strict pending/score assertions were retained.
No baseline full-command reproduction was run, so this is not labelled a
baseline-reproduced or accepted pre-existing failure.

## Correction

At0340e58c70af66a96e3e743ebcbf2c93c6bf26a8 only this UI scenario changes:
wait at most5s for the existing action to be enabled and hittable; after the prior
point commits, wait0.6s before beginning a new rally. There is still no inserted
pause between the new gesture and overriding team tap. New exact assertions require
Pending: US before touch and Double Tap after touch. Original score, fixed-window,
Undo and saved-preference/relaunch checks remain. No retrying tap or ignored failure.

## Exact validation

Both commands use the managed Watch destination
platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08 under the checkout
lease, schemePadelScore, Debug, existing ownDerivedData. Exact before command:

```sh
Scripts/simulator.sh run -- bash -c 'xcodebuild test -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination "$IOSAI_SIMULATOR_DESTINATION" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData -resultBundlePath .artifacts/M31/gesture-touch-reproduce.xcresult -only-testing:PadelScoreWatchUITests/GestureScoringUITests/testSeriesTouchUndoAndSavedPreferenceOnRelaunch -test-iterations 5 > .artifacts/M31/gesture-touch-reproduce.log 2>&1; result=$?; printf "%s\n" "$result" > .artifacts/M31/gesture-touch-reproduce-exit.txt; exit "$result"'
```

Exact after command: `bash .artifacts/M31/run-gesture-touch-fixed.sh`; the preserved
script binds0340, keeps all flags and changes only bundle/log prefixes tofixed.

- Before: exact command above,
  bundle.artifacts/M31/gesture-touch-reproduce.xcresult; exit65. One definition
  Failed;4Passed/1Failed invocations,0skips/expected/runtime warnings. Summary/log/
  exit files use the same prefix. First failure diagnostics finished after the
  test repetitions; the test edit happened only after all five executions ended.
- After: `bash .artifacts/M31/run-gesture-touch-fixed.sh`, exit0, clean source
  0340e58c70af66a96e3e743ebcbf2c93c6bf26a8. UTC2026-11-02T06:33:43.436Z–06:36:04.976Z.
  Bundle.artifacts/M31/gesture-touch-fixed.xcresult;1/1definition,5/5invocations,
  allPassed,0failed/skipped/expected/runtime warnings. Source/summary/log/exit
  sidecars share that prefix. The script requires the exact clean commit.
- `make static`, exit0; .artifacts/M31/static-after-touch-test-fix.log.
- `git diff --check`, exit0.

Shipping continuity to frozen capture d4fd56eed1ec786b7558b5f64907291bb0f16aee is
exact except two UI test files (Bootstrap and GestureScoring). Evidence
.artifacts/M31/shipping-continuity-0340.json and strict material validator/static.
No gallery provenance rule was changed. Actual system icon review is complete in
[icon-runtime.md](icon-runtime.md).

The corrected diff was self-reviewed for preserved assertions, no timing extension
of the product deadline, and absence of production changes. Full clean REVIEW/main
`make milestone ID=M31` is still required; this focused pass is not the full gate.
