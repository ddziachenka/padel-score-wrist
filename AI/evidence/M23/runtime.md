# M23 runtime verification

The first section is historical development evidence. The final checkpoint/copy-
corrected source and complete expanded scope are recorded at the end.

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


## Final complete source after checkpoint and invalid-round copy audit

Clean main source `818c1fc59dffef164b66c4622422a8113a560753`.
Frozen trees `.artifacts/M23/frozen-complete-runtime.json`.
Exact command `bash .artifacts/M23/run-minimum.sh`, exit **0**.
Same owned Watch SE40mm/watchOS10.0 profile and compatibility environment above.
UTC `2026-10-28T16:20:52.865Z`–`2026-10-28T16:27:57.196Z`.

**17/17 definitions, 21 invocations**, zero failed/skipped/expected/runtime warnings.
Complete KnownScoreStartTests, KnownScoreFlowTests and all **five** KnownScoreUITests
passed together. Bundle `.artifacts/M23/minimum-complete-final.xcresult`; log
`.artifacts/M23/minimum-complete-final.log`; JSON
`.artifacts/M23/minimum-complete-summary.json`.

This adds the exact unknown-history checkpoint-detail assertion and the invalid
completed-round journey described in development.md. Both new-game score editor
and overview reject completion, offer no ordinary-correction Finish notice, and
cancellation/relaunch confirm no saved game. Ordinary correction behavior remains
covered by the unchanged full gate. All source changes are self-reviewed; no
blocking finding remains known before the fresh full gate.

Final captures inspected in `.artifacts/M23/minimum-complete-attachments/`:

- `A91B1B63-D2BF-4019-A431-573A463C972C.png` — truthful unavailable earlier detail.
- `182DF8A7-131B-4718-A16F-D5CAC8270ABD.png` — invalid completed score, no Finish offer.
- `09A457D7-F814-4C5B-A9AA-CF1635B3EC82.png` — Americano confirmation.
- `D556A741-2E43-4522-9996-D0A9CABF11B7.png` — Match confirmation.
- `3D652C21-8610-4350-888E-980F22D03771.png` — native audit confirmation.
- `D4A6EC8D-0780-4C7E-B6F5-648F26C53206.png` — largest text.

The checkpoint-only source `855e213b9470d0a9756ec9ec955830d42bbb998d` also passed
16/16/20 at `.artifacts/M23/minimum-checkpoint-final.xcresult`; the complete run
above supersedes it after the fifth case and overview-copy correction. Static on
the final source passed exit0, `.artifacts/M23/static-complete-final.log`.
Primary cache cleanup before the fresh full gate exited0 (336MB); only this
checkout's disposable primary cache was removed. Earlier partial/interrupted gate
is retained and never substituted for new candidate verification.
