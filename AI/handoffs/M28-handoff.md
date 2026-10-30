# M28 handoff

**Policy status:** current

## Milestone

`M28` — Gesture Scoring; status `DONE` under the explicit M28-only owner verification exception.

## Summary

Every new Match/Americano, known-score start and Play again defaults gestures OFF.
The current game's toggle persists across resume, can be changed in its menu and
stays outside score history/Undo. One/two native Double Tap series preview US/THEM
in a fixed three-second window; the third cancels. Exactly one ordinary rally is
saved when due. Touch cancels the preview and scores immediately. Screen visibility/reduced-luminance/
scene inactivity, menu/editor, disable or game/revision changes cancel pending
input without delayed scoring. The visible primary-action button uses watchOS11's
public shortcut; watchOS10 remains supported. Actual recognition depends on the
Watch model/system settings and remains a physical validation obligation.

Schema5 explicitly migrates1–4 OFF while preserving histories/rosters/usage. Watch
practice and clearly labelled iPhone simulation are isolated from real games,
free usage and purchases. New copy ships in thirteen UI locales. Product/design/
architecture and remaining milestone dependencies follow the approved gesture plan.

## Changed files

- `App/PadelScoreWatch/Domain/`, `Services/SessionFile.swift` — transient reducer, per-game metadata and explicit migrations/atomic commands.
- `App/PadelScoreWatch/Features/Game/`, `Features/NewGame/` — opt-in, active shortcut, lifecycle/timer cancellation and safe practice.
- `App/PadelScorePhone/PhoneGestureView.swift`, `PhoneStartView.swift` — real interactive simulation and accessible native guidance.
- Both `Localizable.xcstrings`, `App/PadelScore.xcodeproj/project.pbxproj` — translations and shipping/test-host membership parity.
- Watch tests/fixtures/UI and `App/PadelScorePhoneUITests/CompanionUITests.swift` — clock, storage, scoring, lifecycle and locale regressions.
- `AI/` owning contracts, roadmap, M25/M26/M28/M29/M30, status and M28 evidence — approved scope, separate physical/review milestones and exact owner exception.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `e21875871773f9b47419d526a9cb22e2a4d66fb1` |
| Exact command | `bash .artifacts/M28/verify-phone-complete.sh owner-verification-5` |
| Exit code | 0 |
| Timestamp | `2026-10-30T00:08:36.860730Z`–`2026-10-30T01:33:12.794777Z` |
| Report | `.artifacts/M28/owner-verification-5/report.md` |
| Counts | Fresh iPhone unit21/21 definitions/30 invocations and UI16/16/16; reused Watch619/619/1057; zero failed/skipped/expected/runtime warnings in each accepted component. Static/build/package guards pass. |

The owner approved reuse only of source-identical Watch inputs/results from
`3db256e040e4306477d63f2e75b0223561c1e240`;574 protected paths match before/after.
This is an explicit verification exception. The original full `make milestone
ID=M28` report remains FAILED. [Authorization](../evidence/M28/owner-verification-exception.md)
and [exact evidence](../evidence/M28/milestone-verification.md) preserve commands,
exits, full SHAs, UTC times, native summaries/trees and manifest/procedure digests.

Minimum/current Watch supplements pass469/907 and471/909 on identical Watch inputs.
Current-iOS affected supplement passes2/2 definitions/invocations, exit0, same SHA. [Runtime](../evidence/M28/runtime.md)
records commands, devices, captures and observations. Post-DONE actual outputs:
`.artifacts/M28/post-done-static.log`, `post-done-status.log`,
`post-done-continuity.log` and `completion.json`.

## Tests

Tests cover single/double/third input, fixed timer boundaries/stale callbacks,
touch override, navigation/background/Always On, game/revision changes, new-game
OFF, persisted toggles, atomic failure/retry, schemas1–4/required-v5 corruption,
Undo and game/set/tie-break/Americano completion with once-per-game usage. Native
practice and phone simulation remain isolated. Full locale/appearance/largest-text
matrices and strict native audits include the critical explanation fully visible.

Self-review corrected compact Watch labels/transitions, retained-screen/timer
ownership and phone contrast/clipping using measured accessible native UILabels.
The original native audit helper/categories/count parsers stayed unchanged; new
height/visibility/header/frame assertions strengthen coverage. Individual100ms button
activations explicitly simulate native Watch series, with added intermediate US/THEM
checks and all original score/timer/cancel/navigation expectations. Feedback follows
the action so it stays stationary without hidden sizing copies or empty space. One post-audit Americano picker
uses a single deliberate200ms press with complete-frame visibility, preserving
all option/draw/Undo assertions. Failed/partial runs and framework audit timeouts
remain [development evidence](../evidence/M28/development.md); no failed iPhone
result is accepted. Builder [self-review](../evidence/M28/self-review.md), not an
independent audit or release approval.

## Known issues

No known blocking M28 software issue. Minimum-iOS XCTest theme labels can disagree
with rendered pixels (even Settings showed Light after a Dark setting); current-iOS
actual Light/Dark is inspected, and M25 owns the
comprehensive digital appearance/gallery follow-up. No exhaustive minimum-iOS Dark
claim is made from labels alone. Actual finger recognition, haptics, wrist-down
behavior and every physical Watch/iPhone scenario, including remaining M27 work,
are mandatory in M29. Simulator activations prove software behavior only. M26's
complete milestone and exact-SHA release gates remain required. Existing4.3(a)
and the old unsent/on-hold reply remain; no upload/reply/submission/pricing change
or new release-readiness claim. Apple's SDK build warnings are separately recorded.

## Next step

A new Builder session owns `M25` — Gesture Experience and Store Materials:
six digital domains, actual-screen galleries in all14 Store locales and three
imagegen illustration directions with selection/provenance. Then M29→M26→M30.
Stop after the DONE commit and static/status/continuity against the verified SHA.
