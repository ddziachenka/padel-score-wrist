# M22 — Watch Journal and Correction Experience

**ID:** M22
**Status:** PLANNED
**Depends on:** M21
**Validation:** make milestone ID=M22
**Handoff:** AI/handoffs/M22-handoff.md

## Objective

Make selective recovery understandable and usable on the Watch during a game.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Game menu journal, event details, winner/delete/insert actions, before/after preview, explicit ambiguity resolution and confirmation. New archived journals are read-only. Manual current-state editor remains available and explains its checkpoint.

## Acceptance criteria

- [ ] One tap still records ordinary points; correction requires explicit review/apply and cancellation is harmless.
- [ ] Current game/latest editable result supports corrections within the checkpoint; archived games expose no edit action.
- [ ] Unknown legacy detail, empty history, stale preview, save failure and ambiguity have actionable localized states.
- [ ] VoiceOver, large text, minimum Watch runtime and visual/interaction inspection pass; full make milestone ID=M22 passes.

## Non-goals

No start-from-score setup or real-match iPhone control.

## Validation

`make milestone ID=M22` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
