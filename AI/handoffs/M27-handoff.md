# M27 handoff

**Policy status:** current

## Milestone

`M27` — Player Names; status `DONE`.

## Summary

Players in Watch setup/active menus offers three optional native text fields for
Match/Americano. Save trims names, clearing restores localized roles, and role
labels distinguish duplicates. Names reach real service/score/correction/journal/
result/VoiceOver surfaces. You and demos retain roles. Next game proposes the last
saved roster; Play again uses its game's roster; setup cancellation writes nothing.
Every result keeps its own roster. All five new strings ship in thirteen locales.

PlayerNames stays outside snapshots. Atomic revision-bound/idempotent rename adds
no rally/checkpoint/Undo/usage, preserves names through score Undo and invalidates
old correction previews. Schema4 explicitly migrates1–3 without losing score,
history, journals or usage. Background drafts, failure/retry/cancel, restart, backup
and deletion are covered. No profiles, contacts, phone sync or archived editing.

## Changed files

- `App/PadelScoreWatch/Domain/` — normalized names, game/archive/recent metadata, start/rename command and validation.
- `App/PadelScoreWatch/Services/SessionFile.swift` — explicit old decoders and strict schema4 storage.
- `App/PadelScoreWatch/Features/Editors/` — native draft editor, literal labels and role context.
- `App/PadelScoreWatch/Features/NewGame/`, `Game/`, `Correction/`, `Journal/`, `Result/`, `Shared/DisplayNames.swift` — game-local name propagation and entry points.
- `App/PadelScoreWatch/Localizable.xcstrings` — thirteen-locale copy.
- `App/PadelScore.xcodeproj/project.pbxproj` — shipping/StoreKit-host source parity.
- `App/PadelScoreWatchTests/`, `App/PadelScoreWatchUITests/NewGameUITests.swift` — domain/store/flow/voice/migration regressions, frozen v4 fixture and five native UI cases.
- `AI/PRODUCT.md`, `AI/DESIGN.md`, `AI/ARCHITECTURE.md`, milestone/plan/status, `AI/evidence/M27/` and this handoff — current product memory and evidence; M27 precedes M25.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `488809d6c06b29233e7c1d1f7687c9cec03bbab4` |
| Exact command | `make milestone ID=M27` |
| Exit code | 0 |
| Timestamp | `2026-10-29T09:23:11Z`–`2026-10-29T13:30:22Z` UTC |
| Report | `.artifacts/milestone/M27/20261029T092309Z-73441/report.md` |
| Counts | Watch591/591 definitions/1013 invocations; phone unit21/21/30; phone UI13/13/13; aggregate625/1056; zero failed/skipped/expected/runtime warnings; both Debug/package guards passed |

Exact commands/bundles and raw report: [verification](../evidence/M27/milestone-verification.md).
make fast exits0:454/454 definitions/876 invocations. Final-candidate watchOS10
and27 supplements each exit0:454/454/876, zero failed/skipped/expected/runtime
warnings. [Runtime](../evidence/M27/runtime.md) records all locales,40mm devices,
maximum text, native audits and final inspected captures. Post-DONE logs:
`.artifacts/M27/post-done-static.log`, post-done-status.log,
post-done-continuity.log and completion.json.

## Tests

The complete Watch gate adds23 definitions/37 invocations over M24. New tests cover
both formats/start paths, Unicode/duplicates/long names/clearing, independent
archive/repeat, rename revision/idempotence/Undo, stale previews, migration/strict
corruption, backup/restart/failure/retry/delete and announcements. Five UI cases
drive native input/service, cancel/background/clear/Undo/result/repeat, save
failure/retry, thirteen-locale maximum-text literal labels and unfiltered native
audit. Both full iPhone suites and all prior Watch coverage run unchanged in scope.

Builder self-review fixed raw draft whitespace handling, inherited row identifiers,
source membership and minimum-OS field resolution; added strict frozen-v3 journal
coverage; moved the explanation below fields after maximum-text inspection.
Every behavior/value/audit assertion remains. Complete fast/compatibility/full
gate runs followed the corrections. Failed runs remain raw
[development evidence](../evidence/M27/development.md). This is self-review,
not independent audit or release approval.

## Known issues

No known blocking M27 issue. Owner explicitly assigned all physical-Watch checks
to M25 before M26, including native input/VoiceOver/lifecycle/player names. Initial
Bluetooth tunnel failures executed no tests; no physical pass or release waiver
is claimed. Existing App Review4.3(a) and unsent/on-hold reply remain. Apple's
StoreKitTest SDK warning is non-blocking; native runtime warnings are zero.
No release readiness or distribution action is claimed.

## Next step

A new Builder session owns `M25` — Recovery Experience and Review Materials,
now depending on M24 and M27. M25–M26 remain planned. Stop after DONE commit
static/status/continuity against `488809d6c06b29233e7c1d1f7687c9cec03bbab4`.
