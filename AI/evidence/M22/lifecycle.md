# M22 background-draft correction

## Contract and reproduction

AI/DESIGN.md navigation state and correction abandonment rows (lines55/86) require
an in-memory correction draft to survive background while its process is alive.
The new Journal path used the old generic menu reset and therefore lost its
partial service choice and review during an active game. This is introduced M22
behavior, not a pre-existing defect or a product-direction question.

- Before: App inputs from `6d5fec665f9b65e89ac6c4e5770dfdfd47902a7e`, with only
  the new regression added. `bash .artifacts/M22/run-ui.sh background-before`,
  exit65, `.artifacts/M22/ui-background-before.xcresult`:0/1 passed,1 failed,
  0 skipped/expected/runtime warnings. Exact assertion: “a live correction must
  survive background”. Summary `.artifacts/M22/background-before-summary.json`.
- Fix: `f73955ad954661090a75e9f4daada906e088ba71` on primary main. Only the
  LiveScoreView background-reset condition and its explanation change in production:
  the Journal stack is retained, like the existing manual editor. One new UI test
  covers partial explicit serving choice, complete preview, two background cycles,
  Cancel and unchanged persisted score after a cold launch.
- After: `bash .artifacts/M22/run-ui.sh background-after`, exit0,
  `.artifacts/M22/ui-background-after.xcresult`:1/1 passed,0 failed/skipped/
  expected/runtime warnings. Summary `.artifacts/M22/background-after-summary.json`.

App/Config/Scripts inputs are frozen in
`.artifacts/M22/frozen-inputs-lifecycle.json`. The complete15-case new-scope
watchOS10 set reruns, then a new clean REVIEW commit runs the unchanged full
milestone command. No earlier partial pass replaces either result.

## Interrupted first full gate — retained raw failure

Candidate `6d5fec665f9b65e89ac6c4e5770dfdfd47902a7e`, command
`make milestone ID=M22`, Make exit2 / verifier65 / Xcode75 after the Builder sent
SIGINT to its own exact Xcode PID75608 to correct the lifecycle finding. Native
result: FAILED,515 definitions /919 invocations;514 definitions /918 invocations
passed,1 cancelled test failed,0 skipped/expected/runtime warnings. The cancellation
is `StoreMaterialsUITests/testLocalizeddaCreation()` (“Testing was canceled”).
All419 unit cases,5 StoreKit cases and all original8 Journal UI cases had passed;
this is still an incomplete FAILED gate and is never counted as milestone success.
Companion phases did not run in that attempt.

Raw report: `.artifacts/milestone/M22/20261028T095630Z-49304/report.md`;
result: corresponding `milestone.xcresult`; test log: corresponding `test.log`.
Every failed and cancelled development/verification artifact remains intact.
No waived failure, configured test retry, skipped assertion or pre-existing-failure claim.


## Corrected complete minimum-runtime result

Frozen source `f73955ad954661090a75e9f4daada906e088ba71`, owned Watch SE40mm /
watchOS10.0 `D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C`.
`bash .artifacts/M22/run-minimum.sh`, exit **0**; native start
2026-10-28T11:13:45.532000+00:00, finish 2026-10-28T11:22:06.646000+00:00.
`.artifacts/M22/minimum-background-final.xcresult`: **15/15 definitions /15
invocations**, six unit plus all nine Journal UI tests;0 failed/skipped/expected/
runtime warnings. Log `.artifacts/M22/minimum-background-final.log`; JSON summary
`.artifacts/M22/minimum-background-final-summary.json`. The background regression
retains the partially chosen server, then the completed preview through a second
background cycle; Cancel/relaunch proves the saved score remained unchanged.
All prior change/delete/insert/ambiguity/save-failure/archive/large-text/native-audit/
long-journal scenarios reran and passed on this same corrected source.

`make static` exited0: `.artifacts/M22/static-lifecycle.log`. Only the owned
primary disposable cache was cleared again (345MB), preserving all reports and the
supplemental runtime cache. The next full gate is a fresh run; no result from the
interrupted candidate substitutes for its complete Watch/iPhone suites.
