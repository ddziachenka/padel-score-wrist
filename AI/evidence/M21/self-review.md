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
UTC test interval: 2026-10-27T23:21:40.357Z–23:21:58.575Z. No blocking
self-review finding remains. Before the immutable gate, only the owned disposable
build cache is cleared to avoid retaining a hosted unit-test bundle in the shipping
Debug app; all prior `.artifacts/` evidence is retained.


## First full gate and source-graph correction

Clean REVIEW candidate `822b97bc0497d2f6094cbbdf3066be738680960b` ran unchanged
`make milestone ID=M21`, overall Make2/verifier1. Watch Debug/package checks and
**536/536 definitions,940 invocations** passed with zero failed/skipped/expected/
runtime warnings. Report: `.artifacts/milestone/M21/20261027T232244Z-23664/report.md`;
summary `.artifacts/M21/first-gate-watch-summary.json`.

The next companion Debug build failed65: `RallyCorrection.swift` was registered in
Watch and Watch StoreKit-host phases but absent from the two separate iPhone phases.
The iPhone production target could not resolve the new types/extensions. Phone
unit/UI tests were not reached, not passed. This was caused by this milestone's
project registration, not a claimed pre-existing failure. All raw evidence remains.

Corrected both phone source phases. The source-graph validator now requires every
shared Domain source exactly once, in addition to its existing host-parity checks.
A mutation removes the new file from both phone targets (which kept old parity but
would not compile) and proves rejection. The new check failed before the project
repair (exit1); after repair, source validation and all seven tooling tests passed.
Corrected direct iPhone Debug build passed0. This strengthens verification; no
original test, parser, assertion, category, repetition or gate scope changed.

The entire unchanged mandatory gate will be repeated against a new clean REVIEW
candidate. Passing first-candidate Watch evidence is retained as history, not
reused as verification of the corrected candidate. Companion unit/UI correction
checks are development evidence only. No independent audit or release verdict.


Correction validation: direct `Scripts/simulator.sh --profile companion run --
xcodebuild build -quiet -project App/PadelScore.xcodeproj -scheme PadelScorePhone
-configuration Debug -destination 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7'
-derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion` exited0.
The same wrapper/destination/cache with `xcodebuild test -quiet
-collect-test-diagnostics never` ran `-scheme PadelScorePhoneUnit
-resultBundlePath .artifacts/M21/phone-unit-correction.xcresult` and then
`-scheme PadelScorePhone -resultBundlePath .artifacts/M21/phone-ui-correction.xcresult`:
both exited0, **unit14/14 definitions/20 invocations,UI6/6**, zero failures,
skips,expected failures or native runtime warnings. Both contrast audits pass.
Both summaries are retained in `.artifacts/M21/*-correction-summary.json`.
`python3 Scripts/verify-companion.py --phone-app
/private/tmp/padel-score-1acada2a5b10/DerivedData-companion/Build/Products/Debug-iphonesimulator/PadelScore.app`
exited0, including independent Watch/launcher and test-isolation checks.
`make static` exited0 (`.artifacts/M21/static-correction.log`).

Xcode emitted IDE SDK-build/debugger metadata messages in the development console;
these did not fail either command, and native result runtime-warning arrays are
empty. No claim of a baseline reproduction or pre-existing application failure.
Self-review of the complete baseline-to-corrected diff found no remaining blocking
issue. The only app-project correction adds the already-shared file to the two
missing iPhone source phases; no engine or UI semantics changed after Watch passed.
All required suites will still repeat in the full new-candidate gate.


## Final outcome

The new clean REVIEW/main candidate `9b10f99b6b96a45fc91bff736b68ff9d4df243ac` passed the unchanged full
`make milestone ID=M21`, exit0,2026-10-28T06:07:52Z–08:34:50Z. Watch536/940,
phone unit14/20 and UI6/6; zero failures/skips/expected/runtime warnings.
Both contrast audits pass. Final exact evidence:
[milestone-verification.md](milestone-verification.md). No blocking finding remains;
this is Builder self-review, not independent review or release approval.
Only AI Markdown continuity records follow this verified SHA.
