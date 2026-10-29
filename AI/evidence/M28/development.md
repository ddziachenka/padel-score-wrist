# M28 development evidence

Baseline main: `3af3b6ba2691e6571b4e3c833c6765abc6bdd214` (clean at start).
Owner approved the gesture plan and its one-milestone-per-session boundary.
This is Builder self-review, not independent review or release approval.

## Raw development runs (not final milestone evidence)

- `build-watch-1.log`: sandboxed Xcode could not access CoreSimulator or execute
  Swift macro plugins; build failed. Execution outside that sandbox was approved.
- `build-watch-2.log`: exited65, new Watch source memberships absent/misplaced.
  Corrected explicit Watch/phone and both StoreKit-host source registration.
- `build-watch-3.log`: exited0, Watch Debug build passed. Native metadata-extraction
  warning states that no AppIntents dependency exists; no App Intents added.
- `watch-unit-1.xcresult`: exited65 before tests; StoreKit-host parity guard caught
  missing new Watch-host members. Guard unchanged, memberships corrected.
- `watch-unit-2.xcresult`: exited65 before tests; exhaustive Debug seed switch lacked
  the two new seeds. Fixed the switch, no assertion removed.
- `watch-unit-3.xcresult`: exited65;464 definitions ran, two legacy shape-comparison
  invocations failed because the test's schema2 projection retained the newly added
  schema5 flag. Projection now explicitly asserts/removes false input preference;
  original frozen fixtures remain unchanged. All new gesture tests passed.
- `watch-gesture-ui-1.xcresult`: unit36 definitions passed; UI4/6 passed. New setup
  test used a finished-game seed rather than empty, and the new menu helper required
  the entire corner control to fit an unnecessary scrolling rectangle. Corrected
  new seed/helper using existing tested tap behavior. Production checks unchanged.
- `watch-gesture-ui-2.xcresult`: deliberately interrupted development run after
  visual inspection proved the added full-width row pushed normal40mm scoring into
  scrolling. Raw Xcode exit73 and incomplete bundle retained; not a pass. Busy
  follow-up returned75 before tests and is preserved separately.
- `watch-gesture-ui-3.xcresult`: exited0, four focused UI cases passed: native audit,
  menu opt-in/background/disable, both teams/touch/Undo/relaunch, setup/practice.
  Supplemental final-source verification follows separately.
- `build-phone-1.log`: exited0, iPhone Debug build passed.
- `fast-1.log`: make2/verifier1 before tests. Existing checkout DerivedData contained
  `PadelScoreWatch.app/PlugIns/PadelScoreWatchTests.xctest`; inventory is in
  `.artifacts/M28/cache-packaging.txt`. Removed only this checkout's disposable
  cache using unchanged `make clean-derived-data`; packaging guard not weakened.

All named logs and result bundles live under `.artifacts/M28/` unless a report
names the ordinary `.artifacts/fast/` location. Failures are preserved and are not
called pre-existing product defects. No baseline product-failure claim is made.

## Self-review corrections

Visual captures from the first UI run showed the normal40mm board scrolling and
its gesture action partly off screen. Replaced the extra row in the compact layout
with a visible44pt action between Undo and Menu, displaying serving when idle and
an hourglass/team while pending. Large text retains the ordinary stacked layout.
The state is accessible as Double Tap / Pending: US / Pending: THEM; idle serving
is the action's spoken value. Pending content uses stable compact geometry.

Moved practice links ahead of long explanations. Preserved catalog ordering to
avoid reformatting existing translations. Selection feedback fires only for a
nonempty selection; saved feedback follows successful storage only. Practice
success feedback does not fire on Reset. Timer callbacks revalidate visibility,
lifecycle, game identity, revision and playability before any write.

## Physical coverage

No hardware check was attempted or claimed here. M29 owns real recognition,
comfort, wrist/racket-hand behavior, haptics, VoiceOver, interruptions, purchases,
recovery and the remaining M27 physical scenarios. Simulator action-button taps
exercise the shared software path, never prove actual finger recognition.

- `fast-2.log`: `bash .artifacts/M28/run-fast.sh` / exact `make fast` exited0;
  474/474 definitions passed, no failures/skips/expected failures. Report
  `.artifacts/fast/20261029T143425Z-37599/report.md`; summary/attachments exported
  under `.artifacts/M28/fast-2-*`. Source was mutable development input; later
  small pending-label/lifecycle/timer-review corrections are verified by the
  final immutable milestone, not retroactively attributed to this run.
- `phone-build-for-testing-1.log`: exited0, iPhone test build prepared.
- `phone-gestures-1.log`: exited70 before tests; command selected the phone unit
  target in the UI-only scheme. Corrected command; production schemes unchanged.

Largest-text Watch captures inspected from fast-2: Russian live/action and practice,
German practice and Portuguese/German matrices available in manifest. Native
scrolling keeps enlarged content readable, actions reachable and counts correct.
Normal40mm compact/action captures from ui-3 exposed a cramped pending label; it
now uses an hourglass and localized team, retaining a full spoken Pending label.

The phone preflight matrix was deliberately stopped after successful English
Light/Dark native audits at largest text and the next locale began. It is partial
development evidence, never a matrix pass. The unchanged full M28 gate owns the
entire13-language/two-appearance matrix and both complete phone schemes; no
assertion, test, plan or parser is removed or skipped.

The partial phone preflight exited143 after its normal interrupt stalled while
Xcode tried to save the unfinished action log; only its own xcodebuild process
was terminated. No simulator/service reset or foreign process termination.
Partial/incomplete bundle and raw logs are preserved and never count as passes.

Final compact visual correction: use a single smaller native Serving heading and
hand/name row; stable pending hourglass/team geometry and identity transitions.
At source872ed0f, watch-current-v2 passes471/471 definitions/909 invocations and
watch-minimum-v2 passes469/469/907, both exit0. Final captures inspected: no
wrapped Serving heading, no ghost previous label after settled transition.
Earlier runtime bundles remain as historical development evidence.

## First immutable milestone candidate

Clean REVIEW/main `3db256e040e4306477d63f2e75b0223561c1e240` ran the complete
`make milestone ID=M28`,2026-10-29T15:14:41Z–18:55:43Z. Make exited2/verifier1;
report `.artifacts/milestone/M28/20261029T151440Z-2914/report.md` is FAILED.
Watch619/619 definitions and phone unit21/21 passed. The new phone gesture matrix
reported native contrast failures for the visible Spanish simulation explanation.
It was deliberately interrupted after those failures, not accepted as a partial
pass. Native UI result contains4 definitions:3 passed/1 failed/0 skipped/0 expected;
the interrupted xcodebuild exited75. Watch/phone unit bundles and complete raw
phone diagnostics remain intact; exported failure attachments are under
`.artifacts/M28/full-gate-1-phone-attachments/`.

Both nominal Light/Dark failure captures actually show Light. Correct the new
matrix to set/assert/restore XCUIDevice appearance exactly as the existing suites
do, instead of relying on a launch argument. Keep all thirteen languages and all
native audit categories. Add an explicit Spanish largest-text contrast regression,
reproduce before the product fix, then rerun the full unchanged milestone gate on
the new clean REVIEW candidate. No baseline or accepted-failure claim is made.

The focused Spanish regression reproduced the same visible explanation failure:
`spanish-contrast-before-2.xcresult`,1 definition/1 failed, native91.119s,
xcodebuild exit65. It explicitly switched both actual device appearances; Light
failed and Dark passed its native audits. Xcode then collected600s diagnostics.
The first wrapper invocation omitted `--` and exited64 before tests; retained as
`spanish-contrast-before.log`, never counted as a test run.

Critical simulation/practice/compatibility guidance now uses primary semantic text
instead of secondary text. No shared palette or other screen changed. The same
focused test passed1/1, exit0, in `spanish-contrast-after.xcresult`. The full matrix
now explicitly sets/asserts/restores actual device appearance; no locale, native
audit category, assertion or deferred-text obligation was removed. Bounded
development reruns disable diagnostic collection only, retaining xcresult and all
audit attachments; the mandatory milestone command/configuration is unchanged.
`make static` passed after this correction; raw log `static-contrast-fix.log`.
