# Milestone handoff

**Policy status:** current

## Milestone

`M21` — Selective Rally Correction and Replay; status `DONE`.

## Summary

Pure revision/event-bound previews change, remove or insert a rally after the last
checkpoint, preserve later winners and show score/service/completion effects.
Changed set boundaries require explicit serving; unresolved results stay unknown.
Apply revalidates then saves atomically; one Undo restores the original journal,
score, service, finish state and timestamp, while usage stays once per GameID.
Corrections are flat audit patches, never nested journals. No Watch UI ships here.

## Changed files

- `App/PadelScoreWatch/Domain/RallyCorrection.swift` — preview, replay, impacts,
  clarification, identity/checkpoint/overflow validation and storage consistency.
- `App/PadelScoreWatch/Domain/Session.swift`, `SessionCommand.swift`, `SessionValidation.swift` — typed
  inserted IDs/audit patches, atomic command, existing prefix Undo and validation.
- `App/PadelScoreWatchTests/Domain/RallyCorrectionTests.swift` — 13 definitions,
 22 invocations covering edits, boundaries, lifecycle, failure/restart and long logs.
- `App/PadelScore.xcodeproj/project.pbxproj` — shared source in all four app/host targets.
- `Scripts/verify-companion.py`, `Scripts/tests/test_companion.py` — strict shared
  Domain completeness in addition to existing host parity; omission regression.
- `AI/ARCHITECTURE.md`, milestone/status and `AI/evidence/M21/` — contract/evidence.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `9b10f99b6b96a45fc91bff736b68ff9d4df243ac` |
| Exact command | `make milestone ID=M21` |
| Exit code | **0** |
| Timestamp | 2026-10-28T06:07:52Z–08:34:50Z |
| Report | `.artifacts/milestone/M21/20261028T060751Z-15101/report.md` |
| Counts | Watch 536/536 definitions/940 invocations; phone unit 14/14/20; phone UI 6/6. Total 556 definitions/966 invocations; zero failed/skipped/expected/runtime warnings. Both contrast audits pass. |

Full original report, all exact subcommands, native intervals, metrics and earlier
failed candidate: [milestone verification](../evidence/M21/milestone-verification.md).

## Tests

All edit operations/deuce modes, game/set/tie-break replay, changed and unchanged
serving boundaries, sequential clarifications, stale/checkpoint/duplicate/no-op
rejections, repeated edits, empty/migration boundaries, corruption, old archive
read-only rules, manual finish/resume/date, Americano draw/partial block/overflow,
completion/Undo/usage, every write failure/retry/reopen and 4000-rally roundtrip.
Final preview/apply of 4000 rallies: 0.0166341s on Simulator; 1,945,791 encoded bytes,
all stable IDs retained, one flat added event and bounded storage growth.

Builder self-review corrected pending-boundary handling, checkpoint-based serving,
unknown impact semantics and two invalid test fixtures. First full gate exposed
missing iPhone source membership; fixed both targets, added a fail-before/pass-after
source-graph guard, ran complete companion development checks, then reran the whole
full gate at the new SHA. Original failed Make 2/build 65 evidence remains. No test
or gate was weakened. [Self-review](../evidence/M21/self-review.md), not independent
review or release approval. No new UI, so no separate visual craftsmanship surface.

## Known issues

No blocking M21 issue. Native competitor flow was inaccessible; equivalence remains
unknown ([bounded check](../evidence/M21/competitor-check.md)), never absent.
Work scales with rallies and correction patches without arbitrary truncation.
Watch presentation/localized new copy belongs to M22; physical recovery experience
to M25. Existing App Review4.3(a) rejection/reply hold remains unresolved and outside
this milestone. No upload/submission/pricing change or new release readiness.

## Next step

A new Builder session takes `M22`. This session stops after DONE continuity checks.
