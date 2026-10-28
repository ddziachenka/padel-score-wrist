# M21 — Selective Rally Correction and Replay

**ID:** M21
**Status:** DONE
**Depends on:** M20
**Validation:** make milestone ID=M21
**Handoff:** AI/handoffs/M21-handoff.md

## Objective

Change, remove or insert a recorded rally while preserving later winners and explaining the consequences.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Bounded competitor interaction check first. Pure preview based on revision/event ID/operation; replay to current state after last checkpoint; score/service/completion impact; explicit changed-set serving confirmations; atomic commit and one-step Undo.

## Acceptance criteria

- [x] Competitor check records exact evidence or unknown; full equivalence requires owner direction before implementation.
- [x] All three operations work across game/set/tie-break and all deuce modes while preserving later winners and stable event identity.
- [x] Checkpoint crossing, stale previews and Americano premature completion with remaining entries are rejected explicitly; no dropped events or guessed serving.
- [x] Cancel/write failure preserve everything; one Undo restores the original journal/state; usage never double-counts.
- [x] Domain tests cover repeated edits, boundary ambiguity, draw/partial service block, completion and undo; full make milestone ID=M21 passes.

## Non-goals

No new rules or Watch journey in this milestone.

## Validation

`make milestone ID=M21` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.

## Completion evidence

`9b10f99b6b96a45fc91bff736b68ff9d4df243ac` passed `make milestone ID=M21`, exit0,
2026-10-28T06:07:52Z–08:34:50Z. Watch536/940, iPhone unit14/20 and UI6/6;
zero failed/skipped/expected/runtime warnings.
See [handoff](../handoffs/M21-handoff.md) and [exact verification](../evidence/M21/milestone-verification.md).
