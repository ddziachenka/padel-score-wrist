# M20 handoff — Event Journal and Compatible Persistence

**Policy status:** current

## Milestone

M20 — Event Journal and Compatible Persistence; status DONE.

## Summary

Added schema3 flat journals with stable typed event IDs, real rally winners, service
confirmations, checkpoints, manual replacements and finish/resume events. New
archives retain journals without Undo chains. Schema1/2 migrate to truthful current
checkpoints and explicit unavailable archive detail while preserving sequential
Undo, score/service/rules, settings, timestamps and usage. No user-facing UI changed.

## Changed files

- App/PadelScoreWatch/Domain/Session.swift, SessionCommand.swift and
  SessionValidation.swift — journal model, atomic domain transitions, prefix Undo,
  archive retention and structural validation.
- App/PadelScoreWatch/Services/SessionFile.swift and SessionRepository.swift —
  explicit compatible schema decoding and migration documentation.
- App/PadelScoreWatchTests/Domain and Services — event/Undo/archive/migration,
  corruption/recovery/write-failure and long-storage regressions; frozen schema3
  fixture. Original schema1/2 JSON fixtures remain unchanged.
- AI/ARCHITECTURE.md, M20 contract, PROJECT_STATUS and evidence/M20 — implemented
  boundaries, Builder self-review, exact verification and continuity records.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `98a0502e84453d66904cf13654d92850641ed497`, clean REVIEW/main |
| Exact command | `make milestone ID=M20` |
| Exit code | 0; both Debug builds, packaging guards and all three complete test commands passed |
| Timestamp | 2026-10-27T20:39:05Z–2026-10-27T23:06:43Z |
| Report | `.artifacts/milestone/M20/20261027T203904Z-88591/report.md`; retained report, commands and native counts in `AI/evidence/M20/milestone-verification.md` |
| Counts | Watch 523/523 definitions, 918 invocations; iPhone unit 14/14, 20 invocations; iPhone UI 6/6. Zero failed/skipped/expected failures/runtime warnings |

Both iPhone contrast audits pass without inherited waivers. Corrected development
unit run also passed: 400 definitions/795 invocations. Final storage measurements:
4000 rallies,1949208 active bytes/459659 archived bytes,4002 retained events;
save0.021273959s/load0.02147375s on Simulator. Ten-set Match:568 Undo steps,
374233 bytes. No truncation or arbitrary journal limit.

Completion-record commands: `make static`, `./Scripts/project-status.sh validate`,
`./Scripts/project-status.sh continuity 98a0502e84453d66904cf13654d92850641ed497`.
Closing results/logs are retained under `.artifacts/M20/closing-checks.json` and
`close-*.log`.

## Tests

Added 13 definitions covering stable typed events/retries/stale revisions, chosen
service, full replacement boundaries, legacy Undo, archived detail, malformed and
missing journal fields, every migration/publication write-failure step, restart,
backup recovery and measured long-game retention. Existing complete StoreKit,
functional, accessibility, largest-text and localized suites all ran.

Self-review fixed unavailable-detail restoration after Undo on a migrated result,
and required explicit schema3 archive-detail fields. Development assertion/fixture
corrections and compilation errors are recorded, not counted as passes. The first
same-SHA gate stopped before tests because the development cache held an embedded
unit-test bundle; the shipping guard was preserved. Clearing only the owned cache
with `Scripts/simulator.sh run -- make clean-derived-data` (exit 0) resolved it; all
raw evidence remains, and the unchanged candidate passed. No pre-existing failure
is claimed. This is Builder self-review, not independent review.

## Known issues

No M20 blocking finding remains. Build logs include an Apple StoreKitTest SDK-header
deprecation and metadata-extraction notices; native runtime warning counts are zero.
Optional configured-off linters and an unconfigured additional scanner are not
claimed run. Physical-device and release reassessment belong to M25/M26.

Apple's existing 4.3(a) rejection remains unresolved; the reply/PDF remain unsent/on
hold. No upload, App Review submission, pricing, Promotional Text or release-readiness
change occurred.

## Next step

M21 — selective correction/replay. First perform its bounded hands-on competitor
correction-flow check from the approved recovery plan. Inaccessible behavior remains
unknown; a matching full flow requires the owner's product-direction decision.
M21–M26 remain PLANNED. This Builder stops after the DONE commit and closing checks.
