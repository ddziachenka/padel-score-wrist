# M20 Builder self-review

Baseline: `d914d36fec5d03c4f1e5b915eafa642ea9f29eaf` on primary checkout/main.
This is Builder self-review, not independent review or release approval.

## Scope and implementation

- Schema3 stores snapshots, sequential Undo, flat typed journal, archive, settings,
  revision and usage in the existing single atomic repository envelope.
- Real starts and commands give events stable command identities. Migration uses a
  separately typed GameID identity and a checkpoint at the saved current revision.
  Manual score/rules/format replacement is an explicit correction boundary.
- Old snapshot Undo remains available. Undoing old actions appends an unknown-history
  checkpoint rather than fabricating winners/service confirmations. New Undo uses a
  journal prefix count; no journal or archive is nested into each history entry.
- New finished results retain journals after the next game starts, with no Undo chain.
  Legacy archives encode explicit null journal detail. Missing current-format journal
  fields are damaged, not a legacy fallback. Both old shapes have explicit decoders.
- Repository atomic publication, recovery notices, damaged-byte retention, future
  schema refusal, and usage-loss uncertainty retain their original policies.

No user-facing surface changed. Craftsmanship/runtime visual work is inapplicable;
full existing UI suites remain mandatory in this milestone. No replay/selective edit,
Watch journal UI, start-from-score, sync, purchase policy or store material change.

## Findings corrected

1. Undo of the first new correction on a migrated finished result initially changed
   unavailable archived detail into a checkpoint-only journal. Archive publication now
   retains unavailable detail when only migration/legacy-Undo boundaries remain.
   A regression test checks the whole current record, archive and usage.
2. Optional legacy archived detail initially allowed a missing schema3 key to be read
   silently. Current-format coding now requires the field and writes explicit null
   for legacy detail; a missing-field corruption test proves rejection.
3. Development tests needed a missing `try` and an exclusive-access fix. The first
   executable unit run found one legacy invalid-history fixture also violated the
   new journal revision invariant, plus four recovery expectations omitted the
   established uncertain-usage policy. Fixtures now isolate the intended invariant;
   recovery checks explicitly expect uncertainty. No original assertion was removed,
   relaxed or conditionally skipped; future-version tests use schema4 now schema3
   is supported. Original schema1/2 JSON bytes remain unchanged.

## Coverage

New tests cover typed winners/confirmed service/replacement/lifecycle events, stable
IDs/retries/stale revisions, sequential Undo, legacy Undo checkpoints, archived journal
retention, absent/malformed journal fields, invalid IDs/revisions/boundary games/prefix
references, all write-failure points for migration and completing rallies, restart,
backup recovery, and long-game storage. A frozen schema3 fixture guards the new format;
normalized schema2 comparisons retain assertions for every old field. Existing
complete domain/service/StoreKit/UI and companion suites run in the declared gate.

## Development evidence

- `make static` exited0 during implementation. Optional SwiftLint, SwiftFormat and
  ShellCheck are configured off; no additional problem scanner is configured.
- Initial sandboxed Simulator invocations exited69 because CoreSimulator access
  requires execution outside the filesystem sandbox. The same managed context then
  loaded successfully with that access; no Simulator service was restarted.
- Development builds2/3 failed on the two test compilation errors above (exit65).
- Development unit4 executed397 definitions and recorded five assertion issues already
  described above. Xcode then spent minutes collecting diagnostics; the owning
  development process was interrupted/terminated (final143). Its raw result staging,
  test stdout and process sample are retained; this is not a passing run.
- Corrected unit and exact candidate gate results are recorded in the verification
  record and handoff when complete. No pre-existing failure is claimed.

Corrected development run:

```sh
Scripts/simulator.sh run -- xcodebuild test -collect-test-diagnostics never -quiet -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData -resultBundlePath .artifacts/M20/development-unit-5.xcresult -only-testing:PadelScoreWatchTests
```

Exit0. Native summary:400/400 definitions,795 invocations; zero
failed/skipped/expected failures/runtime warnings. Summary retained in
`.artifacts/M20/unit-5-summary.json`, diagnostics/test stdout in
`.artifacts/M20/unit-5-diagnostics/`. This mutable development run is not the
clean-candidate gate. Only this development command disables collection of system
failure diagnostics; no test assertion or mandatory verification setting changed.

Measured on owned WatchSE/watchOS26.1, retained stdout from that passing run:

- Ten-set Match:568 Undo steps,374233 bytes, saved in0.02055425s.
- Americano2000 rallies:971210 active bytes;4000:1949208 active bytes (2.007×).
- Archived4000 rallies:459659 bytes,4002 retained events (start/rallies/finish),
  with no Undo chain. Save0.020372s; load0.02102125s.

These are Simulator measurements, not physical-Watch latency claims. No arbitrary
journal cap or truncation was added. Final hardware/product experience evidence
remains owned by M25; the full M20 gate remains required here.


## Final outcome

The unchanged clean REVIEW candidate `98a0502e84453d66904cf13654d92850641ed497`
passed `make milestone ID=M20`, exit 0,2026-10-27T20:39:05Z–23:06:43Z.
Watch 523/523 definitions/918 invocations; phone unit 14/14 definitions, 20 invocations; phone UI 6/6.
Zero failed/skipped/expected/runtime-warning results. Exact report, commands,
measurements and the resolved development-cache packaging stop are preserved in
[milestone-verification.md](milestone-verification.md). No blocking self-review
finding remains. No code/configuration/test change followed the verified SHA.
