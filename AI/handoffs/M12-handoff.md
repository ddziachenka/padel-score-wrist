# M12 handoff — Scoreboard Demo

**Policy status:** current

## Milestone

`M12` — Scoreboard Demo; status `DONE`.

## Summary

`Try the scoreboard` now sits under the formats on New game (S1, below the free-game line) and
in About (S11, after Access), which is reached from New game, the result and the game menu. The
demo never opens by itself: not on first launch, not after a result. It opens S16, a fixed Match
example — Golden point, set 1 at 2–2 in games and 40–30, You serving, then Opponent 1, Partner,
Opponent 2 — scored in memory by the real `MatchEngine` and shown with the live score's own
components (context line, both teams, Games and Sets, Undo, Serving).

- `Demo` is drawn in the clock's row, where the live score draws its context, and does not
  scroll, so it stays visible the whole time; `Saved` never appears. The context line, both
  teams, Games, Sets, Undo, Serving and a round ✕ `Close` (in the live score's menu corner) fit
  the 40 mm Watch at Large without scrolling; the hint `Tap a team to add a point. Undo reverses
  it.` and `Reset demo` follow when it scrolls.
- Both teams score with the live score's tap handling (0.5 s settle), haptics (`point`,
  `gameOrSet`, `undo`) and VoiceOver sentences. A point for THEM gives 40–40 with `Golden point`;
  the next point wins the game for either team and moves the serve to Opponent 1.
- The demo ends with its game: the points' place holds a card `Game to US` / `Game to THEM` with
  `Reset demo` (the pattern the live score uses while no point can be recorded), Games and Serving
  show the new state, the hint becomes `The demo ends after one game. Undo the point or reset the
  demo.` and VoiceOver says the same after the game. No point of a full match follows; Undo stays.
- Undo restores the exact score and server one point at a time (context `Action undone`); Reset
  demo returns the example with nothing to undo (context `Demo reset`, VoiceOver `Demo reset.`,
  the points and the server; no haptic).
- Close and VoiceOver escape return to where the demo was opened; each opening, and a relaunch,
  starts the example over (the model lives in the screen's `@State`). Leaving the active state
  during a game closes it together with About, as About already closed. The largest text stacks
  the teams and keeps everything reachable; Always On draws outlines and takes no touch.

The model, `ScoreboardDemo`, receives only a haptic player and a clock: no session store,
repository, file system, usage ledger, entitlement store or StoreKit. The live score's private
components became shared ones that take values and actions instead of `LiveScore`, with a
`game.*` / `demo.*` identifier prefix; the live score's behavior and identifiers are unchanged.

Choices made in-session (reversible, recorded here): `Demo` in the clock's row and Close in the
menu's corner instead of a navigation title and a toolbar ✕, because on watchOS 26 either takes
a second top row and pushed Undo and Serving off the 40 mm screen; the navigation bar stays
visible but empty, as on the live score, because watchOS 10 lost system Back around a hidden bar
there; the screen is one accessibility container, as the live score's is, so `Demo` is read first;
the end-of-demo card in the points' place rather than disabled 0–0 buttons, so the reason nothing
scores and both ways on (Undo, Reset) are visible without scrolling; Reset demo plays no haptic
(DESIGN lists none for it); the Sets row stays although the demo cannot change it, so the board
matches the real one.

## Changed files

- `App/PadelScoreWatch/Features/Demo/ScoreboardDemo.swift` (new) — the in-memory demo model.
- `App/PadelScoreWatch/Features/Demo/ScoreboardDemoView.swift` (new) — S16, the end-of-demo card,
  Close.
- `App/PadelScoreWatch/Features/Game/LiveScoreView.swift` — shared `ContextLine`, `TeamButtons`,
  `DetailRows`, `ServingBlock`, `UndoButton`, `IconButton`; `GameRoute.demo`; the haptic player
  for the demo.
- `App/PadelScoreWatch/Features/Game/ScoreBoard.swift` — `init(format:isFinished:)`.
- `App/PadelScoreWatch/Features/Game/ScoreAnnouncement.swift` — `demoReset(_:)`.
- `App/PadelScoreWatch/Features/NewGame/NewGameView.swift`, `NewGameFlow.swift`,
  `SetupView.swift` — the Try the scoreboard row and `Route.demo`.
- `App/PadelScoreWatch/Features/About/AboutView.swift` — the Try the scoreboard row.
- `App/PadelScoreWatch/Features/Root/RootView.swift` — passes the haptic player on.
- `App/PadelScoreWatch/Localizable.xcstrings` — 14 new English entries.
- `App/PadelScore.xcodeproj/project.pbxproj` — the two app sources in the shipping and StoreKit
  host targets (host parity verified), a `Demo` group, two test files.
- `App/PadelScoreWatchTests/Features/ScoreboardDemoTests.swift` (new),
  `App/PadelScoreWatchUITests/DemoUITests.swift` (new), `AccessibilityUITests.swift`,
  `LargeTextUITests.swift` — demo coverage; `CorrectionUITests.swift` — the notice race below.
- `AI/DESIGN.md`, `AI/ARCHITECTURE.md` — how S16 is built; key strings.
- `AI/milestones/M12-scoreboard-demo.md`, `AI/DEVELOPMENT_PLAN.md`, `AI/PROJECT_STATUS.md`, this
  handoff.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | `903945c58c23250c40762bae0093046fc7ecc6bd` (M11 DONE on main) |
| Verified SHA | `5f011ff78fbae60e25a56cccdbb71808fa00cba8`, clean `REVIEW` commit on `main` in `/Users/Shared/D/ios/padel-score` |
| Exact command | `make -C /Users/Shared/D/ios/padel-score milestone ID=M12` (the Makefile runs `./Scripts/verify-milestone.sh M12` in the primary checkout) |
| Exit code | **0** — `PASSED milestone verification`; static, Debug build and the full shared scheme passed |
| Timestamp | Gate 2026-10-22T16:44:10Z–17:36:45Z (report: started 20261022T164412Z, completed 20261022T173645Z) |
| Report | `.artifacts/milestone/M12/20261022T164411Z-81003/report.md` (primary checkout) |
| Result bundle | `.artifacts/milestone/M12/20261022T164411Z-81003/milestone.xcresult` |
| Counts | **443 total, 443 passed, 0 failed, 0 skipped, 0 expected failures**: 365 unit/policy + 5 StoreKit + 73 UI (`xcresulttool`) |
| Environment | Xcode 27.1 (27A9275); managed Apple Watch SE 40 mm (2nd generation), watchOS 26.1 (23S36); UDID A7CBB23C-F823-4850-BE4B-CAD76922DD08 |

Two earlier gate runs failed and are recorded here, not replaced:

First run, on `957d48f300bcb795d2d3faf1c243659afb4291f4` (2026-10-22T14:34:58Z–15:25:53Z, report
`.artifacts/milestone/M12/20261022T143459Z-796/report.md`): exit 2 (script 65), **443 total, 442
passed, 1 failed, 0 skipped** — `CorrectionUITests.testAmericanoTotalsBlockAndServingAreCorrected`
read `Americano` where it expects the 1.5 s `Changes saved` notice (line 336). Classified
**pre-existing** and corrected in the test:

- Reproduced at the baseline `903945c58c23250c40762bae0093046fc7ecc6bd` with the same test:
  `xcodebuild test … -only-testing:PadelScoreWatchUITests/CorrectionUITests/testAmericanoTotalsBlockAndServingAreCorrected
  -test-iterations 4` (development run in a temporary detached checkout of the baseline) — 3
  passed, 1 failed with the identical assertion at the same line.
- Cause, measured with one throwaway diagnostic test (never committed) at both SHAs: `Changes
  saved` is on screen from 0.01–0.03 s to 1.07–1.09 s after the Save tap returns, identically at
  baseline and candidate; the test first looked about 1.07 s after the tap, behind
  `waitForExistence`, whose first look alone takes about a second. The demo refactor did not move
  the notice.
- Correction: the three correction tests with that pattern now watch the context line from the
  moment Save returns (`expectChangesSaved`), then check the score; the assertions are the same.
  The first read now comes about 0.6 s after the tap; each of the three passed twice before the
  next gate run.

Second run, on the corrected `5f011ff78fbae60e25a56cccdbb71808fa00cba8` (2026-10-22T15:49:06Z–
16:41:44Z, report `.artifacts/milestone/M12/20261022T154907Z-42740/report.md`): exit 2 (script 65),
**443 total, 442 passed, 1 failed, 0 skipped** — `LiveScoreUITests.testTheCrownAndTheMenuNeverScore`
found no Back button for its second `goBack()`. Classified **environment**: the failure's UI
hierarchy shows the live score itself, and the simulator log shows the system deactivating the app
for 253 ms (UIKit deactivation reasons 7 and 12, WatchKit `didDeactivate` then `willActivate`,
20:31:44.974–45.227 local) at the first Back tap; leaving the active state closes the game menu and
About by design (M05/M07), so one Back landed on the score. No M12 code is on that path. The third
run, the verified one above, re-ran the unchanged candidate.

Before the gate (development feedback, not evidence): hosted unit run 365/365; the demo,
large-text, largest-text audit and live score UI suites 20/20 after the last product change;
`make static` exit 0; `./Scripts/project-status.sh validate` exit 0; `python3
Scripts/verify-storekit-host.py` passed. No additional problem scanner is configured (SwiftLint,
SwiftFormat and ShellCheck are disabled in Config).

Runtime check on the managed 40 mm simulator with the session's Simulator control tool under the
checkout lease: New game and About rows; the demo at 40–30, Golden point, game to THEM and to US
with the card, Undo, Reset from the card and from below, Close back to New game and to About;
opened from About during a match, closed back to About with Back intact and the match unchanged;
Large and the largest text; Always On; Increase Contrast and Reduce Motion (simulator accessibility
defaults, removed afterwards). It found and fixed the layout and end-of-demo defects listed under
Tests.

## Tests

- `ScoreboardDemoTests` (new, 10): the exact example (rules, 2–2, 40–30, server and the
  You → Opponent 1 → Partner → Opponent 2 order, valid for the engine); THEM to Golden point and
  either team winning from it; the game moving the serve to Opponent 1 and ending the demo, with
  further taps adding nothing; Undo restoring score and server point by point back to the example,
  and reopening the game; Reset from five different states with nothing left to undo; the 0.5 s
  settle time and the fresh tap after Undo; a new demo per opening; haptics; every VoiceOver
  sentence, including the end note and `Demo reset.`
- `ScoreboardDemoIsolationTests` (new, 1): beside a real `SessionStore` over a recording file
  system, with a finished counted match, a round in play with history, settings and an
  `EntitlementStore` over a fake client, every demo action runs; it proves no file-system
  operation, identical file bytes and dates, an identical session (game, history, previous result,
  settings, ledger) and an unchanged entitlement state with no purchase calls.
- UI `DemoUITests` (new, 5): the journey from New game (row under the formats and above About; no
  demo on first launch; example, hint, Golden point, game to THEM with the card, Undo with
  `Action undone`, game to US, Reset from the card with `Demo reset`, Reset demo below, Close; no
  label mentioning saved, at the start and at the end); every opening and a relaunch start over,
  from New game and from About; during a match with every save failing, the demo works fully, no
  failure appears, the match is unchanged with nothing to undo, and after a relaunch it plays on;
  after a result the demo leaves the result, `Free games left: 5 of 5` and the last settings
  (One advantage, Opponent 1 then You) unchanged; Always On takes no point.
- UI `AccessibilityUITests` + About and the demo in four states, and the demo at the largest text;
  `LargeTextUITests` + the whole board inside the 40 mm screen at Large with the teams side by
  side, and the stacked, scrollable demo at the largest size with `Demo` still in the clock's row.
- UI `CorrectionUITests`: three tests watch `Changes saved` from the moment Save returns (see the
  first gate run above); their assertions are unchanged.
- Existing live score, correction, finish and accessibility suites cover the shared components,
  whose identifiers and behavior did not change.

Mutation checks (macOS SwiftPM copy of the non-SwiftUI sources): nine mutations of the demo model
— no end of the demo, Undo keeping the server, the example at 40–15, the other service order,
Reset keeping Undo, no settle time, Undo keeping the last tap, no VoiceOver end note, and another
40–40 rule — each fail at least one test (1 to 8); a save injected between the isolation test's
snapshot and its checks fails three of its expectations.

Self-review (Builder self-review, not an independent review) of the baseline-to-tip diff and the
running app found and corrected: the first layouts (toolbar ✕ with the navigation title, then the
inline title alone) pushed Undo and Serving below the 40 mm screen — replaced by `Demo` in the
clock's row and Close in the menu's corner; the team buttons kept their natural height and cut the
bottom row — they now take what the rows leave, at least a tap; a won game left 0–0 buttons that
silently ignored taps with the explanation below the fold — now the end-of-demo card; a hidden
navigation bar, replaced by the live score's visible empty bar for watchOS 10; the accessibility
audit flagged the `Demo` title as a too-small hit area outside any container — the screen is now
one container like the live score's, and the audit passes; a tautological large-text assertion and
an assertion that could not hold after scrolling were removed before the first run; the "no Saved"
check was widened from one identifier to any label.

## Known issues

- Workflow deviation, as in M01–M11: the session ran in the Claude app worktree
  `.claude/worktrees/next-ready-milestone-edc7e1` (branch `claude/next-ready-milestone-edc7e1`)
  because a session hook blocks edits in the primary checkout. Every commit was made on that
  branch from main's tip and fast-forwarded (`git merge --ff-only`) into `main` of the primary
  checkout, so the SHAs are identical; the gate, static, validate and continuity ran on `main`
  there.
- Not checked on real hardware or on the watchOS 10 runtime. VoiceOver was checked through the
  accessibility tree (labels, hints, values, order), the announcement sentences in unit tests and
  the system audit in the simulator; spoken VoiceOver, haptic feel and Always On on a real Watch
  stay with the M10 hardware evidence, whose blockers are unchanged. The visible-but-empty bar
  copies the live score's watchOS 10 fix; the demo itself was not run on watchOS 10.
- On Watches larger than 40 mm the board fills the screen as the live score does, so the hint and
  the lower `Reset demo` are always one scroll below it; the end-of-demo card keeps Reset in view
  when it is needed.
- The isolation test observes the session store's file system, files, session and entitlement
  state; that the demo cannot reach anything else rests on its initializer taking only a haptic
  player and a clock.
- A system deactivation of the app in the simulator closes the game menu and About by design, so
  UI tests that walk through them can fail when one happens (second gate run above). No test was
  changed for it.
- Adjacent, out of scope (A2): the on-watch legal pages' labels `Public page`, `Email` and `Apple
  Standard EULA` (M09) have no String Catalog entries. English v1 shows the same words, so nothing
  visible changes; the localization work after release readiness should add them.
- `.artifacts/` evidence is local and ignored; the continuity commit does not back it up. Nothing
  was pushed, published or submitted.

## Next step

M13 — Local History and Storage Migration, in a new Builder session. M10 resumes only after
M11–M15 are DONE.
