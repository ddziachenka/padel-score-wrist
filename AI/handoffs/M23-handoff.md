# M23 handoff

**Policy status:** current

## Milestone

`M23` — Start from a Known Score; status `DONE`.

## Summary

Watch setup offers From zero or Current score for Match and Americano. Shared
validated editors capture completed sets/games/points/deuce/tie-break or points/
total/block, with explicit serving and a complete confirmation. A normal game ID
and initial known-score checkpoint preserve truthful unknown earlier history;
Undo stops there. Invalid/complete states cannot start, cancellation writes
nothing, and the existing access/once-per-game completion policy remains.

## Changed files

- `App/PadelScoreWatch/Domain/SessionCommand.swift`, `Session.swift` — validated known-state start and typed checkpoint.
- `App/PadelScoreWatch/Features/NewGame/` — mode, draft ownership, score entry, confirmation, retry/cancel and rule-change preservation.
- `App/PadelScoreWatch/Features/Correction/`, `Features/Editors/ServingEditor.swift` — shared typed navigation/summary controls and accurate new-game copy.
- `App/PadelScoreWatch/Features/Journal/` — truthful known-checkpoint presentation.
- `App/PadelScoreWatch/Localizable.xcstrings` — seven strings in thirteen locales.
- `App/PadelScoreWatchTests/Domain/SessionLifecycleTests.swift`, `Features/NewGameFlowTests.swift`, `App/PadelScoreWatchUITests/NewGameUITests.swift` — public behavior/regressions.
- `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, milestone/status and `AI/evidence/M23/` — product memory and reproducible evidence.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e` |
| Exact command | `make milestone ID=M23` |
| Exit code | 0 |
| Timestamp | `2026-10-28T16:28:52Z`–`2026-10-28T19:16:57Z` UTC |
| Report | `.artifacts/milestone/M23/20261028T162851Z-63137/report.md` |
| Counts | Watch 568/568 definitions/976 invocations; iPhone unit 14/14/20; UI 6/6/6; total 588/1002; zero failed/skipped/expected/runtime warnings; both Debug/package guards passed |

Bundle paths and exact raw commands: [verification](../evidence/M23/milestone-verification.md).
Final-source minimum-watchOS 10 supplement: `bash .artifacts/M23/run-minimum.sh`,
exit 0,17/17 definitions/21 invocations; [runtime](../evidence/M23/runtime.md).

## Tests

Twelve new domain/flow definitions (sixteen invocations) and five UI cases cover
valid boundaries, explicit service, impossible/complete states, access/ledger,
failed-save identity/retry, restart, initial Undo limits, later correction/Undo,
cancellation and setup-rule changes preserving entered score. UI drives both
formats through review, start, play, service rotation, Undo and relaunch; tests
largest text/background/cancel, all native audits, truthful checkpoint detail and
an invalid completed round with no finish offer. Existing zero-start, correction,
localized and iPhone suites run unchanged.

Builder self-review corrected rule changes silently clearing score entry,
confirmation hierarchy, duplicate Access presentation, Cancel ownership and
misleading reused correction copy. The initial UI query was corrected to the
checkpoint's actual Button role while retaining its exact content requirement.
The interrupted first full gate remains raw failed evidence; the new full gate
above passes without a waiver. This is self-review, not an independent audit.

## Known issues

No known blocking M23 issue. Physical-device/VoiceOver and all-locale final-product
coverage belongs to M25; no such pass is claimed here. Existing App Review 4.3(a)
rejection and unsent/on-hold reply remain unchanged. No new release readiness or
distribution is claimed.

## Next step

A new Builder session owns M24 — interactive iPhone recovery scenarios. M24–M26
remain planned. Stop after the DONE commit passes static/status/continuity against
`ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e`.
