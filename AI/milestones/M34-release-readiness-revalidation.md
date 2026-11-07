# M34 — Release Readiness Revalidation

**ID:** M34
**Status:** PLANNED
**Depends on:** M33
**Validation:** make milestone ID=M34
**Handoff:** AI/handoffs/M34-handoff.md
**Revalidated domains:** functional, ui-ux, content, accessibility, product, release
**functional revalidation record:** AI/audits/M33-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/M33-ui-ux-revalidation.md
**content revalidation record:** AI/audits/M33-content-revalidation.md
**accessibility revalidation record:** AI/audits/M33-accessibility-revalidation.md
**product revalidation record:** AI/audits/M33-product-revalidation.md
**release revalidation record:** AI/audits/M33-release-revalidation.md

## Objective

Establish fresh exact-candidate release readiness for the serve-side build after
DONE M33's audits, physical acceptance and local material preparation.

## Scope

Follow AI/prompts/final-release-readiness.md. Verify complete current six-domain
coverage, build/material identity, the full milestone gate and the unchanged
exact-SHA release gate. Preserve historical failure and physical-evidence limits.

## Non-goals

No inherited affected-only waiver, App Review submission, upload, price change or
publication. Build 7's withdrawal and monitor hold remain historical facts.

## Acceptance criteria

- [ ] M33 is DONE with complete applicable six-domain coverage, affected physical
      acceptance and zero open P0/P1 findings.
- [ ] Full `make milestone ID=M34` passes at clean REVIEW/main.
- [ ] `make release CANDIDATE=<verified-full-SHA>` reports READY_FOR_HUMAN for the
      same exact SHA, with commands, exits, reports and counts in the handoff.
- [ ] Static/status/continuity validate the DONE record; candidate-bound human
      checklist rows are reported honestly and distribution remains the owner's decision.

Owner approved this split on 2026-11-07; AI/evidence/M33/planning-blocker.md.
