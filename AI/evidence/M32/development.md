# M32 development and self-review

Baseline: `bd3cb546c26e8130db8333bc0a41d6942577a605`, primary checkout/main.
Builder self-review, not an independent audit or release approval.

## Changes reviewed

- `ServeSide` derives only from accepted Match phase/service and Americano's
  explicit `rallyInBlock`. Comparing parity avoids overflowing corrected scores.
  No session schema, commands, journal replay or persistence format changed.
- `ScoreBoard` hides the derived value on finished/unconfirmed states. Existing
  readers (live Watch, gesture action, demos, journal and phone recovery) receive
  the same value. US/THEM order and score typography remain unchanged.
- L/R is literal; the full side/receivers' choice and viewpoint/help explanation
  are translated in all thirteen app locales. VoiceOver announcements include
  the next side; the visible golden-point explanation is not read twice.
- Reviewed compact Watch rendering in all thirteen locales. The first implementation
  spent too much height on the service footer. Corrected it to wrap name + symbol
  using the existing two-line/0.75 minimum scale for built-in roles in columns,
  unlimited custom-name lines and a scrolling fallback; a full-width golden-point note uses inter-row spacing.
  The note alone can scale to 0.8 in compact columns. Score size is unchanged.
  Final native golden-point captures all keep score, choice, name, L/R and both
  controls on screen at the ordinary Large size on the managed 40-mm Watch.
- Updated exact speech expectations, including punctuation between the side and
  the demo's existing closing sentence. Tests cover normal-score table, repeated
  deuce, both deciding rules, tie-break server/set boundaries, arbitrary Americano
  blocks, correction, selective replay, known-score start, restart, Finish/Resume,
  Undo and failed saves. UI checks include compact golden point, existing large
  text/long-name scenarios, Always On, and phone light/dark side transitions.

## Development evidence

These mutable runs do not replace the clean full M32 gate.

- `Scripts/simulator.sh run -- bash .artifacts/M32/test-watch-feature.sh`: exit 0;
  `.artifacts/M32/watch-feature.xcresult`, `watch-feature-summary.json` and
  `watch-feature-tests.json`. 479 definitions / 933 invocations, 0 failed,
  skipped, expected failures or runtime warnings. Includes all Watch unit tests
  and `LiveScoreUITests/testGoldenPointSideFitsWithTheScoreOnTheCompactWatch`.
- `python3 Scripts/verify-localizations.py --all`: exit 0;
  `.artifacts/M32/localization-check-final.log`.
- `./Scripts/project-status.sh validate`: exit 0;
  `.artifacts/M32/status-development.log`. `git diff --check`: exit 0.
- Native inspection scripts: `.artifacts/M32/inspect-watch.sh` and
  `inspect-locales.sh`, run via the managed simulator lease, explicit UDID
  `A7CBB23C-F823-4850-BE4B-CAD76922DD08`. Latest logs
  `watch-inspection-final-layout.log` and `watch-locale-final-layout.log`, exit 0.
  Images: `watch-{matchStart,storeGoldenPoint,storeAmericano,matchTieBreak,gestureMatch}.png`,
  `golden-<locale>.png`, combined contact `golden-locales-contact.png`.
  These are Simulator observations, not physical VoiceOver or wrist acceptance.

## Preserved unsuccessful development attempts

- Initial `make static` failed the existing shipping-source/capture fingerprint
  guard after implementation (`.artifacts/M32/static-development.log`). Fresh
  native captures are required; the guard is unchanged.
- An attempted temporary narrowing of `FAST_TEST_ARGUMENTS` was rejected by
  automatic approval review before execution. No configuration was changed.
- First full `make fast` failed packaging the old owned DerivedData test product
  (`fast-full.log`). `make clean-derived-data` then succeeded (`cache-clean.log`).
  The subsequent full mutable run (`fast-clean.log`) was explicitly cancelled
  after source/speech expectation fixes made that run obsolete; it is not a pass.
  Reports remain under `.artifacts/fast/20261106T061350Z-71432` and
  `.artifacts/fast/20261106T061449Z-75382`.
- First manual inspection attempted install while the owned simulator was shut
  down (exit 149); subsequent runs explicitly waited for its boot and succeeded.
- First phone diagnostic command incorrectly combined unit and UI targets under
  the UI-only scheme (exit 70, `.artifacts/M32/phone-feature.log`). The corrected
  run uses the repository's separate PhoneUnit and Phone schemes.

M33 owns fresh physical readability/VoiceOver acceptance and release readiness.
No prior milestone exception is transferred. No upload, submission or public-site
publication is part of M32.

Corrected phone diagnostic:
`Scripts/simulator.sh --profile companion run -- bash .artifacts/M32/test-phone-feature-2.sh`
exited 0. `phone-unit.xcresult`: 21 definitions / 30 invocations; `phone-feature-2.xcresult`:
1 UI test with both appearances and Match left → choice → Undo, then Americano
right → left → new server right. Both summaries have zero failures, skips,
expected failures or runtime warnings. Exported native attachments and visually
inspected contact: `.artifacts/M32/phone-feature-attachments/` and
`.artifacts/M32/phone-feature-contact.png`. Names, side, score and golden-point
explanation are legible in both themes on the compact SE/iOS17 profile.

Implementation frozen for material capture at
`f2dee8278a8e910ded1564598d3cbbb751bf6512`. The mutable diagnostic source tree is
identical to this commit's App inputs.

Committed visual contacts for review: `compact-golden-locales.png` (all thirteen
languages at ordinary Large size on 40-mm Watch) and `phone-serve-side-themes.png`
(the six native UI-test attachments arranged for comparison). Contacts are overview
compositions; the unmodified individual screenshots remain at the paths above.

Watch material capture:
`Scripts/capture-store-materials.sh watch capture m32-watch-gallery-1` exited 0.
`.artifacts/M25/m32-watch-gallery-1.xcresult`: 14/14 tests, zero failures,
skips, expected failures or runtime warnings. Inspected all fourteen store locale
variants of live gesture Match (R) and Americano (L) using native attachments and
`.artifacts/M32/watch-gallery-{01-gesture,06-americano}-contact.png`; score/name/side
remain readable. The 44-mm native gallery does not replace the separate 40-mm
inspection above.

## Long custom-name correction

Further self-review found that applying the two-line role limit to an unlimited
custom name could truncate the trailing side too. Reproduced before fixing:
`Scripts/simulator.sh run -- bash .artifacts/M32/test-long-name.sh before`, exit 65,
`.artifacts/M32/long-name-before.xcresult` (1 test, 1 failure, no skips). The native
attachment shows “Alexandra Maria de la…” and no R. This is a real implementation
finding, not a pre-existing failure or an accepted exception.

`ServingBlock` now limits only built-in roles in compact columns. Custom names have
unlimited lines, so the whole name and trailing side reflow; the existing score
screen selects its scrolling layout without shrinking the score. The same strict
UI test passed after the fix:
`Scripts/simulator.sh run -- bash .artifacts/M32/test-long-name.sh after`, exit 0,
`.artifacts/M32/long-name-after.xcresult` (1/1 test; zero failed/skipped/expected or
runtime-warning results). Visually inspected native `long-name-with-side.png`.

The f2dee82 gallery source is superseded by this fix. Watch capture-1 passed for
that source only; the ongoing obsolete phone capture-1 was explicitly cancelled
(exit 75, its interrupted result preserved). Neither supplies final M32 materials.
Both platforms must be captured again on the corrected frozen source. Earlier
compact/default-role contacts still document their original source; that branch
is unchanged by the custom-name correction.

Corrected capture source:
`ac3522a2a94e5d0c75f9f9d134ad83ce9f8dc406`.
`Scripts/capture-store-materials.sh watch capture m32-watch-gallery-2`:
`.artifacts/M25/m32-watch-gallery-2.xcresult`, xcodebuild exit 0; 14/14 tests,
zero failures, skips, expected failures or runtime warnings. The paired phone
capture uses the same frozen SHA; final import/verification is recorded below.
Fresh capture-2 visual review: `.artifacts/M32/watch-gallery-2-01-gesture-contact.png`
and `watch-gallery-2-06-americano-contact.png` cover all fourteen store variants;
built-in role names and R/L remain visible. Also inspected native English
rally-correction and known-score previews, including their derived L/R. Preview
cards retain their existing scrolling behavior. Release/editorial selection of
screens explicitly illustrating golden point remains M33 scope.

Final phone capture:
`Scripts/capture-store-materials.sh phone-current capture m32-phone-gallery-2`,
exit 0; `.artifacts/M25/m32-phone-gallery-2.xcresult`: 2/2 tests, zero failures,
skips, expected failures or runtime warnings. Same full source SHA as Watch
capture-2. Inspected all fourteen phone Match/Americano gallery variants in
`phone-gallery-2-{05-match-demo,06-americano-demo}-contact.png` and the individual
English Americano image; scores and side labels remain intact.

Final material commands, all exit 0:

- `python3 AI/store-assets/m25/tools/import-captures.py --watch-run m32-watch-gallery-2 --phone-run m32-phone-gallery-2`
- `python3 AI/store-assets/m25/tools/compose-creative.py`
- `python3 AI/store-assets/m25/tools/validate.py`
- `make site-check`

Logs: `.artifacts/M32/material-{import,compose,validation}.log` and
`site-check.log`. Exact shipping-input hashes, 112 Watch + 98 phone native images,
28 creatives, 14 store locales and 104 identical local web image copies verified.
Site check also passes six tests and all twelve added app locales (405 keys each).
The legacy `PENDING_M29` markers are fixed schema labels, not a claim of current
physical acceptance; fresh acceptance belongs to M33. No public deployment ran.

## Full-gate findings on 125d807

Clean REVIEW candidate: `125d807173d2bdb13392a60e08f15028340427b6`.
The full `make milestone ID=M32` was actually run without any test filters.

1. `.artifacts/milestone/M32/20261106T084916Z-55521/report.md`: Make 2 /
   verifier 1, before tests. The Debug build succeeded but the packaging guard
   found a leftover `PadelScoreWatchTests.xctest` inside the owned Watch Debug
   product from development testing. Evidence: `.artifacts/M32/packaging-cache-residue.txt`.
   `make clean-derived-data` exited 0 (`cache-clean-before-milestone.log`), removing
   only this checkout's computed default build cache. This is not a claimed
   pre-existing source failure; no guard was changed.
2. `.artifacts/milestone/M32/20261106T085327Z-78477/report.md`: both Debug builds
   and package guards passed. Complete Watch 650/650 definitions, 1104 invocations;
   complete phone unit 21/21 definitions, 30 invocations; zero failed, skipped,
   expected failures or runtime warnings in those completed bundles.
   Phone UI found a new `Text clipped` audit failure for
   `phone.recovery.result.serveSide` in both Light and Dark in
   `testKnownScoreSetBoundaryRequiresServingAndExactUndo`.
   After diagnosing that implementation finding, the remaining obsolete run was
   explicitly interrupted via SIGINT to its exact iPhone xcodebuild PID.
   Final raw result: Make 2 / verifier 1 / phone UI xcodebuild 73, FAILED.
   Partial phone UI: 13 definitions, 11 passed, one audit-failed, one canceled
   (`testM25LocalizedHelpAtLargestTextInBothAppearances`), 0 skipped/expected/runtime
   warnings. Unexecuted UI cases are not passes and no component-reuse waiver applies.

Summaries: `.artifacts/M32/milestone-watch-summary.json`, `milestone-watch-tests.json`,
`milestone-phone-unit-summary.json`, `failed-full-phone-summary.json`.
Console: `.artifacts/M32/milestone-full-clean.log`; the original bundle/report remains
FAILED. Exported failure attachments: `.artifacts/M32/failed-full-phone-attachments/`.
The native screenshot shows the literal L fully visible; the native audit reports
that the text may clip at larger Dynamic Type sizes. The one-letter Text carried
a full-sentence accessibility label. This is a new M32 finding, not attributed to
the baseline.

Correction: the full localized side is now the server element's accessibility
value in phone recovery. The visible L/R and choice explanation remain unchanged,
and their redundant separate accessibility elements are hidden. VoiceOver can read
server and side together. The existing strict native audit is unchanged; its test
also asserts pending service has no side value, confirmed service is right, Undo
restores left, and audit scrolling preserves that full spoken value.
Targeted verification and fresh captures/full verification remain required.

Targeted correction verified:
`Scripts/simulator.sh --profile companion run -- bash .artifacts/M32/test-recovery-side.sh`
exited 0. `.artifacts/M32/recovery-side-fixed.xcresult`: 1/1 definition/invocation,
zero failed/skipped/expected/runtime-warning results. The test performs the same
six native categories in both themes, now also checking the full server-side value
across confirmation/Undo and every audit scroll. Visually inspected the exported
light-theme native attachment: L and server remain fully visible, score unchanged.
Summary/attachments: `recovery-side-fixed-summary.json`, `recovery-side-fixed-attachments/`.
`git diff --check` and `./Scripts/project-status.sh validate` also exit 0.
This is development evidence only; the previous full gate remains FAILED and the
final complete M32 gate will run afresh.
