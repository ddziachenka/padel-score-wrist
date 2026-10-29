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
