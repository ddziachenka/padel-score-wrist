# M13 handoff — Local History and Storage Migration

**Policy status:** current

## Milestone

`M13` — Local History and Storage Migration; status `DONE`.

## Summary

History is available from New game, the current result and the game menu under every access
state. Its lazy list orders completed real games newest first, shows the format, local date
and compact US/THEM score, and opens the shared factual result summary with no mutation or
Play again actions. Undated migrated results say `Date unavailable`; an empty history says
`Your finished games will appear here.` Viewing sends no commands or settings changes.

The archive has one final snapshot and optional completion date per GameID, without Undo.
Finish (including automatic Americano completion) adds it; corrections update it; Resume or
Undo to active removes it; re-finishing gives it a new date. Undo restores a result's original
date using only that game's timestamp in the Undo entry. SessionStore injects time and retains
the original request's time through failed saves and retries. Starting another game preserves
the archive and closes correction/Resume of older results. previousResult is a computed view.

Schema 1 migrates atomically to schema 2, retaining the original bytes as backup and preserving
the current game's Undo, available earlier result, recent settings, ledger and notice. Both
versions support ledger recovery; unknown future versions remain protected. Delete local data
also erases archive and service copies. A durable rollback journal makes interrupted or failed
deletion restore every original file before another load/save; removing the journal last commits
the deletion. Usage and the separate Apple purchase entitlement remain. Settings, confirmation,
Privacy, Terms and Support describe local history and its deletion; public-site work stays in M15.

## Changed files

- `App/PadelScoreWatch/Domain/Session.swift`, `SessionCommand.swift`, `SessionValidation.swift` —
  compact archive, derived previous result, lifecycle/date handling and validation.
- `App/PadelScoreWatch/Services/SessionFile.swift`, `SessionRepository.swift`, `SessionStore.swift`
  — explicit v1 migration, v2, both-version usage recovery, clock injection and transactional deletion.
- `App/PadelScoreWatch/Features/Result/HistoryView.swift` (new), `ResultSummary.swift`, `ResultView.swift`
  — History, read-only details, compact scores and result entry point.
- Game/NewGame routes and views, Settings models/views, About and `Localizable.xcstrings` — entry
  points, local data explanations and English strings. Project sources preserve StoreKit host parity.
- `App/PadelScoreWatch/App/UITestStore.swift`, unit/fixture tests and new `HistoryUITests.swift` —
  lifecycle, migration, fault injection, access, performance and runtime regression coverage.
- `AI/ARCHITECTURE.md`, `AI/DESIGN.md` — implementation and deletion transaction; milestone,
  development plan, project status and this handoff — continuity records.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | `804ba948f07d2628fe57bcd03e52da40408fccb2`, clean main |
| Verified SHA | `630587e2102738b741f28b037909cb6532d62232`, clean REVIEW on main |
| Exact command | `make milestone ID=M13` |
| Exit code | **0** — PASSED milestone verification |
| Timestamp | 2026-10-22T18:14:37Z–2026-10-22T19:08:20Z (UTC) |
| Report | `.artifacts/milestone/M13/20261022T181436Z-21872/report.md` |
| Result bundle | `.artifacts/milestone/M13/20261022T181436Z-21872/milestone.xcresult` |
| Counts | **464 total, 464 passed, 0 failed, 0 skipped, 0 expected failures**; 381 unit/policy + 5 StoreKit + 78 UI; one clean Debug build (Watch app + packaging container) |

## Tests

Added lifecycle/date tests for Finish, correction, automatic completion, Resume, Undo,
re-finish, next game, deletion, undated migration and idempotent usage. Pinned v2 JSON fixtures
alongside unchanged v1 fixtures; compare the migrated sessions and v2 encoder, reject invalid
legacy previous results and invalid/duplicate archives, recover usage from both versions,
preserve unknown future files, and fault migration publication at every save step.

Deletion tests inject write/torn-write, removal, publication and final-journal-commit failures;
reloading restores the exact original main, backup and damaged bytes. Retry completes once;
cancelling a failed deletion before the next score preserves all history. Entitlement tests
retain history at the free limit and after revocation, and preserve usage through deletion.

The 500-result check measured 183,987 bytes, save 0.007538625 s and load 0.006605292 s in the
verified simulator run; asserted each operation below 1 s, total file below 500 KB, one Undo
entry below 2 KB, exact reload and unchanged archive after Undo. These are simulator results,
not an oldest-device performance claim.

Five new UI tests drive empty/list/detail flows, undated Match and dated Americano, ordering,
relaunch, all three entry points, free-limit access, read-only archived results, 500 entries
during active play, subsequent scoring, largest text and accessibility audits. Runtime screenshots
were inspected at normal/largest text on the managed 40 mm Watch SE (watchOS 26.1), then rechecked
after making the list date compact and preventing score-pair wrapping. Grouped labels preserve
team order; the detail uses the already accessible result summary. Native rows and scrolling
are sufficient here; no new animation, imagery or haptic was warranted. Screenshots and mutable
check summaries are under `.artifacts/M13-development/`.

Builder self-review of the complete baseline-to-tip diff covered persistence, failure atomicity,
state ownership, lifetime access, retention, localization and craftsmanship. The first gate at
`43ede4cde933756222460e6d457e30afab897f78` found stale exact-copy assertions; it was deliberately
interrupted (make exit 2, gate exit 69 after xcodebuild termination 143; incomplete bundle counts
are not authoritative), report `.artifacts/milestone/M13/20261022T175753Z-2151/report.md`.
Corrections require the full new history-inclusive confirmation and Settings history row.
The longer text also exceeded XCTest's 128-character identifier-query limit; exact-label
NSPredicates retain the complete assertion. Both affected UI tests then passed, exit 0;
`.artifacts/M13-development/deletion-summary.json`. No test/check was removed, skipped or loosened.
This is Builder self-review, not independent review or release approval. No additional problem
scanner is configured beyond static checks and the shipping-source parity check in the build.

Post-DONE continuity validation uses `make static`, `./Scripts/project-status.sh validate`, and
`./Scripts/project-status.sh continuity 630587e2102738b741f28b037909cb6532d62232`; logs are retained
under `.artifacts/M13-development/done-*.log`. Only continuity records change after the verified SHA.

## Known issues

None known in M13. M10 remains BLOCKED under the existing owner exception until M11–M15 are DONE
and its recorded real-Watch evidence is available. Spoken VoiceOver, on-court use, Always On/Low
Power, oldest-device launch, adverse-network StoreKit and the M14 launcher remain M10's release
coverage; simulator accessibility evidence here does not claim those checks. No release-readiness
verdict, upload or App Review submission was performed.

## Next step

M14 — Watch-face launch. Stop after M13 DONE; a new session owns M14.
