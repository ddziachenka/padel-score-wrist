# watchOS 10 and release-preparation handoff

**Policy status:** current

## Milestone

M08 remains `BLOCKED` by required real-Watch purchase checks. M09 remains blocked
by M08; M10 has not started. This is owner-authorized release preparation and a
bounded compatibility experiment, not milestone completion or independent approval.

## Summary

Downloaded Apple's official watchOS 10.0 (21R355) runtime through the signed-in
Developer archive and imported it successfully. Created a separate managed device
in a bounded experiment worktree; the primary watchOS 26.1 configuration is intact.
The final Release build launches on watchOS 10 without test overrides, and the
selected core/StoreKit and UI regressions pass. Reproduced UI
failures were corrected: taps clear clipped screen edges, the sheet presenter closes
Access, saved Finish/correction actions return to the game, Cancel returns to the
menu, serving confirmation and next-game setup return to play, and pushed screens
retain system Back. Direct rendering exposed missing Games/Sets captions; intrinsic
caption sizing restores them without losing Back. Assertions remain intact. An isolated xctestrun uses the compatible current
Xcode automation framework to avoid crashes in the old runtime test framework. The release gate
correctly refuses readiness while required work remains. Nothing was submitted.

## Changed files

- `AI/audits/release-1.0-preparation.md` — exact commands, results, partial release
  coverage, runtime discovery and live read-only store/site evidence.
- `AI/PROJECT_STATUS.md` — replace the unavailable-runtime statement with observed
  runtime availability and the measured compatibility coverage.
- `App/PadelScoreWatch/Features/Access/AccessView.swift` — optional presenter-owned Close action.
- `App/PadelScoreWatch/Features/NewGame/SetupView.swift` — dismiss the purchase sheet and restore editing without losing the draft.
- `App/PadelScoreWatch/Features/Game/LiveScoreView.swift` — explicit completion/discard callbacks and system Back availability.
- `App/PadelScoreWatch/Features/Game/SetServingView.swift` — return after serving confirmation saves.
- `App/PadelScoreWatch/Features/NewGame/NewGameView.swift` — pass the start completion to setup.
- `App/PadelScoreWatch/Features/NewGame/NewGameFlow.swift` — report success only after storage accepts the start/retry.
- `App/PadelScoreWatchTests/Features/NewGameFlowTests.swift` — assert success/failure results without removing integrity assertions.
- `App/PadelScoreWatchUITests/NewGameUITests.swift` — scroll the rule row before selecting it.
- `App/PadelScoreWatchUITests/CorrectionUITests.swift` — scroll off-screen rule and number controls before tapping; retain all assertions.
- `App/PadelScoreWatch/Features/Result/ResultView.swift` — return only after a successful Finish.
- `App/PadelScoreWatch/Features/Correction/GameEditorScreen.swift` — close after a successful correction.
- `App/PadelScoreWatchUITests/UITestSupport.swift` — stricter tappable center bounds.
- This handoff — bounded scope and reproducible continuation.

The separate shared-scheme edit is preserved and excluded; its origin is unknown.

## Validation

| Field | Evidence |
| --- | --- |
| Corrected SHA | `f287cdfa581fa6d1cc6974e91794321d02399804` |
| Exact command | `make release CANDIDATE=f287cdfa581fa6d1cc6974e91794321d02399804` |
| Exit code | make 2; verifier 65; `NOT_READY` |
| Timestamp | 2026-10-21T18:16:41Z |
| Report | `.artifacts/release/20261021T181641Z-43099/report.md` |
| Counts | Preflight stops before release tests/checklist; not a passing release gate |

Additional exact build/test commands and historical failed bundles are in the audit.
The corrected candidate's Debug and clean unsigned Release builds exit 0; all 13
Release binary/package checks pass. Final selected regressions at that exact SHA:

- watchOS 10.0: **337 passed, 0 failed, 0 skipped**, exit 0;
  `.artifacts/watchos10-audit/verified-watchos10.xcresult`.
- watchOS 26.1: **337 passed, 0 failed, 0 skipped**, exit 0;
  `.artifacts/watchos10-audit/verified-watchos26.xcresult`.

Each contains 328 Swift, 4 StoreKit and 5 UI logical tests; expanded parameterized
count 681 passed on each device. Exact commands, UTC times and earlier broader
matrices are in the audit. `make static` and status validation exit 0; optional
linters are disabled. Continuity refuses the preserved uncommitted scheme edit.
The final Release simulator build and direct launch also exit 0;
`verified-release10-launch.png` shows the ordinary New game screen.
No current milestone gate is claimed to have passed.

## Tests

Existing tests reproduced purchase dismissal, saved-action navigation and missing
Back failures. No assertion was removed and no test was skipped or retried into a
pass. The tap helper uses stricter safe bounds. Temporary diagnostic source changes
were removed; all 137 App files in the test snapshot match the recorded commit.
Self-review covered the complete twelve-file diff: idempotent sheet dismissal,
retained draft/count/previous game, success-only navigation, error recovery, and
system Back availability without adding a score title. Success callbacks preserve
failed-save screens; discard removes only editor routes, leaving the menu. The
next-game callback requires an explicitly successful store operation; invalid,
failed and paywalled starts do not navigate. Intrinsic caption sizing was visually
checked without XCTest, then included in layout/accessibility regressions. This is
self-review, not independent approval.

## Known issues

- Required physical Watch testing remains unavailable: purchase/sandbox restore,
  wrist lifecycle, haptics, Crown usability and spoken accessibility cannot be
  signed off from a simulator.
- The final evidence is selected regression coverage, not a complete latest-SHA
  scheme/milestone gate. watchOS 10 UI testing needs the recorded isolated XCTest
  framework override. Full minimum-OS coverage remains part of M10.
- The unrelated shared-scheme edit remains uncommitted; clean-checkout milestone
  and continuity gates cannot pass while it is present. It was not reverted or
  included in the tested immutable source.
- ARCHITECTURE opening still describes H1 as open; approved PRODUCT/site sections
  carry the resolved decision. This adjacent documentation correction is left for follow-up.
- No full six-domain M10 audit, Archive/Organizer validation or release approval.
- Ignored local result bundles are not backed up by a Git commit.

## Next step

The installed watchOS 10 runtime and managed experiment device remain available
for the full final-audit matrix. Resume required hardware coverage when a real Watch is available, run M08's declared
`make milestone ID=M08` on its clean final candidate, then complete M09 and M10 in
workflow order. Do not send anything for App Review without the owner's instruction.
