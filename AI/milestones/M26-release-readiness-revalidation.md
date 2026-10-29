# M26 — Release Readiness Revalidation

**ID:** M26
**Status:** PLANNED
**Depends on:** M29
**Validation:** make milestone ID=M26
**Handoff:** AI/handoffs/M26-handoff.md
**Revalidated domains:** functional, ui-ux, content, accessibility, product, release
**functional revalidation record:** AI/audits/M29-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/M29-ui-ux-revalidation.md
**content revalidation record:** AI/audits/M29-content-revalidation.md
**accessibility revalidation record:** AI/audits/M29-accessibility-revalidation.md
**product revalidation record:** AI/audits/M29-product-revalidation.md
**release revalidation record:** AI/audits/M29-release-revalidation.md

## Objective

Establish fully passing release evidence for the new exact candidate and prepare the next binary.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Current six-domain records, migration/package validation, new archive/build identity and candidate continuity; full immutable milestone and release gates; prepare resubmission evidence and launch-monitor guard for the new candidate.

## Acceptance criteria

- [ ] M29 DONE and all six domain records current with no missing required coverage or unaccepted failure.
- [ ] make milestone ID=M26 and make release CANDIDATE=<full-SHA> pass unchanged on the clean REVIEW candidate with both full platforms.
- [ ] Actual package/version/build/provenance and migration evidence match the candidate; historical M18 acceptance is not transferred.
- [ ] Monitor candidate/build guard is updated and read back before future publication work; submission remains a separate owner decision.

## Non-goals

No M18 gate consolidation, contrast waiver, automatic submission or promotion before public availability.

## Validation

`make milestone ID=M26` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.

Also run `make release CANDIDATE=<full-SHA>` on that exact REVIEW candidate.
