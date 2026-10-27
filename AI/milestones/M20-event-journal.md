# M20 — Event Journal and Compatible Persistence

**ID:** M20
**Status:** DONE
**Depends on:** M19
**Validation:** make milestone ID=M20
**Handoff:** AI/handoffs/M20-handoff.md

## Objective

Record real events and retain new archived journals without losing existing games or inventing history.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Typed stable event IDs for rallies, service confirmations, checkpoints and corrections; versioned persistence migration; read-only archived journals; checkpoint boundaries for existing current states. Preserve sequential Undo and once-per-game usage ledger.

## Acceptance criteria

- [x] Migration preserves old score/service/rules/Undo/settings/archive/usage; unsupported future versions and corrupted backups remain safe.
- [x] Legacy archives explicitly lack detailed events; no reconstructed winners or serving claims.
- [x] New events and archived journal survive restart, recovery and write failure atomically; long-game storage remains bounded by measured behavior, not silent truncation.
- [x] Meaningful migration/repository/domain tests and full make milestone ID=M20 pass.

## Non-goals

No selective correction UI or replay, no sync or gameplay changes.

## Validation

`make milestone ID=M20` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
