# M23 final-source runtime verification

Source: `868723c267905cd9e92a445e9f98301a85025777`, clean main.
Frozen App/Config/Scripts trees: `.artifacts/M23/frozen-runtime.json`.

Exact command `bash .artifacts/M23/run-minimum.sh`, exit **0**.
Underlying owned profile command: `bash .artifacts/M16/runtime-profile.sh
watch-minimum run bash .artifacts/M23/check-minimum.sh`.
Watch SE40mm, watchOS10.0/21R355, UDID
`D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C`.
UTC test interval `2026-10-28T14:40:44.568Z`–`2026-10-28T14:46:12.381Z`.

Build-for-testing and test-without-building passed. Selected complete new-scope
suites: KnownScoreStartTests, KnownScoreFlowTests, KnownScoreUITests.
**16/16 definitions, 20 invocations**, zero failed/skipped/expected/runtime warnings.
Result `.artifacts/M23/minimum-corrected.xcresult`; raw log
`.artifacts/M23/minimum-corrected.log`; JSON
`.artifacts/M23/minimum-corrected-summary.json`. The helper reuses the existing
watchOS10 XCTest runner framework-path compatibility environment; it changes no
app, assertion, audit category, result parsing or test selection inside these suites.

Coverage: all deuce modes and extended tie-break, completed-set/service boundaries,
invalid/complete combinations, explicit Americano partial-block position, access,
normal identity, finish/Undo/correction once-per-game accounting, checkpoint limits,
atomic write-failure retry/restart, cancellation and changes to setup rules while
preserving the entered score. Four UI cases drive both formats through review,
Start, scoring/service rotation and Undo; verify unknown checkpoint detail and cold
relaunch; check largest text, live background draft retention and cancellation;
and run all native accessibility audit categories on score entry and confirmation.

Final captures inspected in `.artifacts/M23/minimum-corrected-attachments/`:

- `45CA9AD2-857B-403E-BDD1-FBE53C84BEA7.png` — Americano score/server/block/rules.
- `F6FBCA1A-5DB8-4D80-AE5C-6D7F64AE2F16.png` — Match score/games/server/rule.
- `813592EF-A684-4287-ACD5-69708BAC691C.png` — explicit known-score checkpoint.
- `8E40DD0C-A0D4-4B4B-8C62-BC11F1C130DA.png` — native audit confirmation.
- `96AC0B2C-B3FC-490F-AC7B-728E68F537DE.png` — largest-text wrapped confirmation.

The first watchOS10 set on `88a6bf306aef377c1e0dc07862beba7dc87dd020`
also passed exit0 (15 definitions/19 invocations), in
`.artifacts/M23/minimum-final.xcresult`. It predates the setup-rule preservation
correction, which is why the whole new-scope set ran again above. The earlier
failed UI set remains in development.md and is not counted as passing evidence.

`make clean-derived-data`, exit0, removed only this checkout's354MB primary
mutable cache before the full gate; all evidence and minimum-profile cache remain.
No physical-device or all-locale audit is claimed here; M25 owns that work.
