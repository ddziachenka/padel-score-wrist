# M22 handoff

**Policy status:** current

## Milestone

`M22` — Watch Journal and Correction Experience; status `DONE`.

## Summary

Watch Journal supports change winner, delete and insert without losing later
recorded winners. A separate Before/After review shows score, service and finish
impact; changed set boundaries require explicit serving. Apply is revision-bound
and atomic; Cancel writes nothing, failed saves retain Retry/Cancel, and one Undo
restores the whole correction. Partial serving choices and full reviews survive
background. Current/latest editable result can change; archived journals are
read-only and unavailable legacy detail is stated truthfully. Manual editing
explains its checkpoint. Ordinary one-tap scoring remains intact.

## Changed files

- `App/PadelScoreWatch/Features/Journal/` — effective timeline, event detail, pure
  review, preview, explicit serving and error states.
- `Features/Game/LiveScore.swift` and `LiveScoreView.swift` — existing save/retry/
  feedback path, navigation and background preservation.
- Game menu, result/history and manual editor views — entry points, result Undo,
  read-only archive and checkpoint explanation.
- `App/PadelScoreWatch/Localizable.xcstrings` plus three unchanged-word registries —
  39 keys in 13 locales; native French/Swedish Journal and Dutch Rally explained.
- Journal unit/UI tests, Debug fixtures and project membership — stable identities,
  checkpoint limits, ambiguity/stale/overflow, atomic failure, cancellation/Undo,
  long lists, native audit, largest text and background lifecycle.
- `AI/DESIGN.md`, milestone/status and `AI/evidence/M22/` — behavior and exact evidence.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `b52ea03978bc63664f2b43289fb950bf5d44c611` |
| Exact command | `make milestone ID=M22` |
| Exit code | 0 |
| Timestamp | UTC `20261028T112312Z`–`20261028T140420Z` |
| Report | `.artifacts/milestone/M22/20261028T112311Z-88354/report.md` |
| Counts | Watch: 551/551 definitions, 955 invocations; iPhone unit: 14/14, 20; iPhone UI: 6/6, 6. Aggregate: 571 definitions, 981 invocations; 0 failed/skipped/expected/runtime warnings; 2 Debug builds/package guards passed |

Additional minimum-runtime command `bash .artifacts/M22/run-minimum.sh`, exit 0:
15/15 on watchOS 10.0, no failed/skipped/expected/runtime warnings. Exact timings,
bundles, source continuity and successful raw gate are in
[verification](../evidence/M22/milestone-verification.md).

## Tests

Six new unit and nine new UI cases cover the new journey and its safeguards.
Self-review corrected shared source membership, test-helper/fixture errors,
score-first preview hierarchy, archived explanation and result Undo. A later
contract check reproduced loss of a Journal draft in background; a narrow path
retention fix and fail-before/pass-after lifecycle regression close it. The
interrupted first full gate remains FAILED; every required suite reran on the
verified SHA. No mandatory test, audit category or parser was weakened. Builder
self-review only, not independent review or release approval.

## Known issues

None known in M22 scope. The existing App Review 4.3(a) rejection and reply hold
remain. M25 owns the approved fresh physical-device/all-locale audit; no new
release readiness, upload or submission is claimed.

## Next step

`M23` — start from a known score. This Builder stops after the DONE commit and
passing static/status/continuity checks against the verified SHA.
