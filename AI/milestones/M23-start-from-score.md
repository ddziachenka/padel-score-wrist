# M23 — Start from a Known Score

**ID:** M23
**Status:** DONE
**Depends on:** M22
**Validation:** make milestone ID=M23
**Handoff:** AI/handoffs/M23-handoff.md

## Objective

Join an ongoing Match or Americano at its known state without inventing earlier rallies.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Zero/current-score choice in existing setup. Guided rules/score/service and confirmation; reuse validators, normal game ID and access policy; initial checkpoint with truthful unknown earlier history.

## Acceptance criteria

- [x] Match handles completed sets/current games/points/deuce/tie-break and explicit service; Americano handles points/N/B/block position.
- [x] Invalid or already-completed states cannot start; cancellation leaves stored game/settings untouched.
- [x] Undo cannot cross initial checkpoint; later corrections and finish/undo count the same game once.
- [x] Tests cover valid boundary states, invalid combinations, access/ledger and persistence; full make milestone ID=M23 passes.

## Non-goals

No new formats, imported synthetic rallies or tournament setup.

## Validation

`make milestone ID=M23` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
