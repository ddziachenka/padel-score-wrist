# M17 — Companion Release Domain Revalidation

**ID:** M17
**Status:** DONE
**Depends on:** M16
**Validation:** make milestone ID=M17
**Handoff:** AI/handoffs/M17-handoff.md

## Objective

Revalidate all six affected release domains for the real iPhone companion and
independent Watch. Owner explicitly requested this separate release assessment,
TestFlight check where available, upload and app+first lifetime IAP submission.

## Scope

Functional, UI/UX, content, accessibility, product and release typed coverage;
current physical phone and exact-input M16 evidence; public support/privacy/terms
readback; distribution package and StoreKit review. Six records:
AI/audits/M17-<domain>-revalidation.md. Preserve M10 and M16 historical records.
No product expansion. No scoring, storage or purchase-model change.

## Acceptance criteria

- [x] Six current typed domain records cover the maintained inventory honestly.
- [x] Current runtime review covers Start, both exact demos, Access, navigation,
      cancellation and known localized/large-text boundaries.
- [x] Public legal/support copy matches the companion privacy architecture.
- [x] No new P0/P1 remains. Exact owner-accepted exceptions are retained, not passes.
- [x] Unchanged full make milestone ID=M17 runs on clean REVIEW SHA; command,
      exits, per-platform counts and all other checks are recorded in handoff.

## Owner acceptance

Latest owner request explicitly carries the already agreed exceptions into this
release revalidation: AI/evidence/M17/owner-release-authorization.md. Only the two
named native SE/iOS17 Contrast failed cases and the accepted physical scope are
nonblocking. Tests/parsers/full suites are unchanged. Any additional failure blocks.
A raw FAILED gate is never described as passed or READY_FOR_HUMAN.

## Non-goals

No new feature or model. Actual archive/export/upload/selection/submission follows
M18 readiness and existing owner authorization; no promotion clock before public
availability. M17 alone is not release approval.

## Corrected verification setup

The first full run exposed a later-day native review prompt covering the first UI
journey. AI/evidence/M17/review-prompt-regression.md records fail-before/pass-after
evidence. Explicitly declining only this known prompt preserves production review
behavior and every existing assertion; no suite, audit category or parser weakened.

Completion: AI/handoffs/M17-handoff.md; raw FAILED preserved under exact owner acceptance.
