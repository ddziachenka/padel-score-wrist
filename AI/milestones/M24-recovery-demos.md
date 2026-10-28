# M24 — Interactive iPhone Recovery Scenarios

**ID:** M24
**Status:** REVIEW
**Depends on:** M23
**Validation:** make milestone ID=M24
**Handoff:** AI/handoffs/M24-handoff.md

## Objective

Let users and reviewers try the distinctive recovery flows without an active Watch game.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Keep existing Match/Americano examples and add guided historical correction and start-from-score scenarios using shared domain engines. Explicit Demo state and isolated reset/leave behavior, localized help.

## Acceptance criteria

- [ ] Each new scenario exposes actual input, preview, confirmation, Undo/cancel and result, not a video-only claim.
- [ ] Existing demos and review eligibility behavior remain intact; no real session, archive, settings, free-game or entitlement mutations.
- [ ] All supported locales, small/large phones, light/dark and accessibility sizes are usable.
- [ ] Isolation/domain/UI tests and full make milestone ID=M24 pass.

## Non-goals

No iPhone real-game storage/sync or new paywall.

## Validation

`make milestone ID=M24` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
