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
  using the existing two-line/0.75 minimum name scale in columns, unlimited lines
  in the scrolling layout; a full-width golden-point note uses inter-row spacing.
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
