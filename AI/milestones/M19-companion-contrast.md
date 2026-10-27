# M19 — Companion Contrast Repair

**ID:** M19
**Status:** IN_PROGRESS
**Depends on:** M18
**Validation:** make milestone ID=M19
**Handoff:** AI/handoffs/M19-handoff.md

## Objective

Remove the two native contrast failures on iPhone SE (3rd generation), iOS17, without suppressing any audit.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Reproduce the unchanged English and Spanish largest-text cases, identify the rendered failing elements, fix the production presentation, inspect light/dark and large text, and run both full platform suites.

## Acceptance criteria

- [ ] Both previously failing tests reproduce on baseline with raw evidence and exact source SHA.
- [ ] The same native audit categories and assertions pass after the production fix; unknown issues are never ignored.
- [ ] Runtime inspection covers the changed presentation in light/dark, English/Spanish largest text and ordinary scoring; no clipping or accidental points.
- [ ] Full make milestone ID=M19 passes on clean REVIEW SHA; handoff records commands, exits, per-platform counts and self-review.

## Non-goals

No journal, new demo, scoring, purchase, iPad, App Store or verification-policy change.

## Validation

`make milestone ID=M19` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
