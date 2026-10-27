# M21 Builder self-review

Baseline: `bb182fba19662570fe8cf0490ce3d712814b9453`, primary checkout/main.
Builder self-review only; no independent audit or release approval.

## Scope and implementation

Pure revision-bound previews change/remove/insert a stable rally in the editable
suffix after the latest start/migration/manual-replacement checkpoint. Every later
winner remains ordered. Insertion can also follow the checkpoint for an empty
suffix. Inserted identities have their own typed namespace, distinct from the
command that commits the correction. Removed and superseded entries remain in the
append-only audit log. No new rule, Watch journey, localization or phone demo ships
here; those belong to later approved milestones.

A preview carries before/after snapshots, ordered effective rallies, explicit
score/service/completion impacts, displaced service confirmations and the next
required clarification. It stops at the first changed set boundary without
inventing serving beyond it. Unresolved impact values and final snapshot remain
unknown. Supplying an explicit valid team/player/order replays again to the next
clarification or final state. Unchanged confirmed and unconfirmed boundaries retain
their original meaning. Manual/migration checkpoints awaiting confirmation are
supported even without a preceding rally.

Apply recomputes against the same revision, game, checkpoint, event identity and
operation, then uses the existing atomic SessionStore transaction. Cancellation is
discarding a pure value; a failed write publishes nothing and retains the same
retry identity. A flat correction patch is one appended event and one existing
snapshot/prefix Undo entry, never a copied nested journal. One Undo restores the
whole original record and archive timestamp. Usage remains once per GameID.
Finished Americano can become active when replay removes its automatic completion;
manual finish/resume events remain explicit. Reaching the total with later rallies
is rejected with a remaining-rally count. Old archives cannot be edited.

Persistence validation rejects malformed patches or disagreement with the current
snapshot and archived corrected journal. Existing schema1/2 migrations and schema3
fixtures remain unchanged. Schema3 has not shipped publicly; this extends its typed
journal without changing the deployed candidate. Data remains local with no new
permission, integration, dependency or purchase behavior.

## Findings corrected

- Initial development serving fixture incorrectly chose THEM after six games;
  native error correctly required US. Corrected the fixture to use the actual
  serving pair. No scoring rule or production validator was weakened.
- Review found unchanged final unconfirmed boundaries should remain unconfirmed;
  only changed boundaries require a fresh explicit choice. Added direct coverage.
- Review found a migration/manual checkpoint can itself await service, with no
  previous rally identity. Confirmations can anchor to that boundary.
- Unknown final impacts must not read as unchanged while service is unresolved;
  they are optional until replay completes, and preview lists the clarification.
- A new archive-preservation fixture called Finish twice with different fresh
  command IDs and incorrectly compared those two distinct journals. It now creates
  one finished session and verifies that starting a new game preserves that exact
  journal. All integrity/identity/archive assertions remain.

No user-facing surface changes, so visual craftsmanship and new runtime gesture
inspection are inapplicable. Full existing Watch/phone UI coverage still runs in
the declared milestone gate. M25 owns the new physical-device experience evidence.

## Tests and development evidence

New domain and repository tests cover all three operations under all deuce modes,
game/set/tie-break replay against ordinary scoring, stable IDs and edits of inserted
rallies, multiple boundary clarifications, invalid choices, unchanged pending
serving, checkpoint/empty/migration behavior, stale revision, removed/duplicate/no-op
requests, malformed persisted patch/snapshot drift, read-only archives, manual
finish/resume/timestamps, Americano draw/partial block/overflow/completion/Undo and
idempotent usage, every atomic save fault/retry/restart and 4000-rally retention,
roundtrip and flat storage growth.

- `make static` exited0 during development; log `.artifacts/M21/static-development.log`.
- Initial sandboxed `make simulator-context` exited2 (inner69, CoreSimulator access
  denied). The same owned context succeeded outside the sandbox. No simulator
  service was restarted or unrelated device changed.
- Development1 exited65: one invalid serving fixture above; eight parameter
  invocations passed, one failed. Development2–4 exited0 after corrections.
- Development5 exited65: the distinct-Finish-IDs fixture above; 412/413 definitions
  passed, 816/817 invocations; no skipped/expected/runtime warnings.
- Final corrected unit evidence and full immutable gate are recorded in
  `milestone-verification.md` when complete. Logs/result bundles remain under
  `.artifacts/M21/`; no failed run is called a pass or pre-existing.

Development command (mutable, not milestone evidence):

```sh
bash .artifacts/M21/run-unit.sh 6
```

The script runs `Scripts/simulator.sh run -- xcodebuild test
-collect-test-diagnostics never -quiet -project App/PadelScore.xcodeproj
-scheme PadelScore -configuration Debug -destination
'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08'
-derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData
-resultBundlePath .artifacts/M21/development-6.xcresult
-only-testing:PadelScoreWatchTests`. The unchanged mandatory gate has no narrowed
scope or changed diagnostic/repetition options. Configured optional analyzers are
off; no additional problem scanner is configured.


Final development6 exited0: **413/413 definitions,817 invocations**, zero
failed/skipped/expected/runtime warnings. Summary: `.artifacts/M21/unit-6-summary.json`.
UTC test interval: 2026-10-28T00:21:40.357Z–00:21:58.575Z. No blocking
self-review finding remains. Before the immutable gate, only the owned disposable
build cache is cleared to avoid retaining a hosted unit-test bundle in the shipping
Debug app; all prior `.artifacts/` evidence is retained.
