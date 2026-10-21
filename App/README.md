# Padel Score — Wrist

Open `PadelScore.xcodeproj` in Xcode and choose the shared **PadelScore** scheme.
The runnable target is **PadelScoreWatch**, with a minimum deployment target of
watchOS 10. The **PadelScore** target is the Watch-only packaging container;
there is no iPhone companion interface.

| Target | Purpose | Bundle identifier |
| --- | --- | --- |
| PadelScoreWatch | SwiftUI Watch app | com.dziachenka.padelscore.watchapp |
| PadelScore | Packaging container | com.dziachenka.padelscore |
| PadelScoreWatchTests | Hosted Swift Testing bundle | com.dziachenka.padelscore.padelscorewatchtests |
| PadelScoreWatchUITests | XCTest UI tests | com.dziachenka.padelscore.padelscorewatchuitests |

The project is checked in directly and has no external package dependencies.
Debug and Release both use Swift 6 with strict concurrency. Development language
and the initial String Catalog are English. Version/build are 1.0 (1) in both app
targets.

Run repository checks from the repository root:

```sh
make static
make simulator-context
make fast
```

The repository owns a separate Watch simulator, configured in `Config/project.env`.
Its local binding is ignored by Git. Follow `AI/WORKFLOW.md` when driving it.
No signing team is stored in the project; select the owner's development team in
Xcode when preparing a physical-device build.

M00 provides the launch screen and About navigation. M01 adds the regular-match
scoring engine in `PadelScoreWatch/Domain` — pure Swift with no UI, storage or
clock — and its Swift Testing suites in `PadelScoreWatchTests/Domain`. M02 adds the
americano engine beside it, and `GameSnapshot`, which gives a game the stable
identity its corrections keep. M03 adds the session — the game or its result, the
previous result, recent settings, the free-use ledger and full undo history — as a
Domain value, and in `PadelScoreWatch/Services` its versioned file, the repository
actor that saves it atomically with a backup and recovers from damage, and the
main-actor `SessionStore`; their suites are in `PadelScoreWatchTests/Services`.

M04 adds the screens that create a game. `PadelScoreWatch/App` is the composition root:
it builds the one `SessionStore` over the Watch's Application Support folder. In Debug
builds only, a UI test can give the app a store of its own through the launch
environment (`UITestStore.swift`: `PADEL_UITEST_STORE`, `PADEL_UITEST_SEED`,
`PADEL_UITEST_FAIL_SAVES`); a Release build has no such path. `PadelScoreWatch/Features`
holds the views: `Root` opens the saved game, New game, loading or recovery from the
store's state; `NewGame` holds the in-memory `SetupDraft` and the `NewGameFlow` that
starts the game; `Editors` are the field editors (40–40 rule, a number with the Digital
Crown, serving order) that later corrections reuse; `Game` shows the started game until
the live score replaces it; `Shared` holds the design tokens of `AI/DESIGN.md`. The
semantic colors and the app icon live in `Assets.xcassets`; the icon is drawn by
`App/Design/render-app-icon.swift`, which writes the committed PNG:

```sh
swift App/Design/render-app-icon.swift App/PadelScoreWatch/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

M05 replaces the read-only game screen with the live score in `PadelScoreWatch/Features/Game`.
`ScoreBoard` is what the screen shows of a saved game — the line above the score, each team's
points, the counts under them and who serves next — and `ScoreAnnouncement` is what VoiceOver
says after each saved change. `LiveScore` is the screen's model: it sends a rally, Undo or a new
set's serving order to the session store one at a time, treats a second tap within half a second
as the same tap, plays a haptic and posts the announcement only after the save, and holds a failed
save for Retry or Cancel. `LiveScoreView` lays the score out in two columns while they fit and as
stacked, scrolling sections at larger text, and shows it read only in Always On; `SetServingView`
confirms a new set's serving order and `GameMenuView` holds the rules and About. Haptics go
through the `HapticPlayer` protocol in `Services/Haptics.swift`; the composition root passes the
WatchKit adapter. Debug UI tests can also seed a match at 0–0, at set point or in a tie-break and
two americano rounds, and `PADEL_UITEST_ALWAYS_ON=1` draws the live score as in Always On.

M06 adds corrections in `PadelScoreWatch/Features/Correction`. `CorrectionDraft` starts as the saved
game and is changed value by value — the match's points with the 40–40 stage, games, completed sets, the
tie-break's points and serving, or the round's points, totals and place in the block, or a new format —
without converting or replaying anything; it names what still disagrees and asks for serving to be
checked when a change made it uncertain. `GameEditor` holds the draft with the session revision it was
made from; `LiveScore` owns it, records nothing behind it, and saves the whole draft as one `.correct`
request. `GameEditorScreen` is Edit score and Game settings, `TeamValuesEditor` edits one value for each
team with the Digital Crown, and the points, games, sets, serving and format screens complete the editor.

Finishing a game and commerce belong to subsequent milestones. A successful
test on a recent simulator does not prove watchOS 10 runtime compatibility, and the simulator
does not prove how a haptic feels.
