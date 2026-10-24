# M18 — Release Readiness Revalidation

**ID:** M18
**Status:** PLANNED
**Depends on:** M17
**Validation:** make milestone ID=M18
**Handoff:** AI/handoffs/M18-handoff.md
**Revalidated domains:** functional, ui-ux, content, accessibility, product, release
**functional revalidation record:** AI/audits/M17-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/M17-ui-ux-revalidation.md
**content revalidation record:** AI/audits/M17-content-revalidation.md
**accessibility revalidation record:** AI/audits/M17-accessibility-revalidation.md
**product revalidation record:** AI/audits/M17-product-revalidation.md
**release revalidation record:** AI/audits/M17-release-revalidation.md

## Objective

Establish candidate-bound release evidence for the companion build after M17's
six-domain reassessment. Preserve historical Watch-only readiness and raw failures.

## Scope

Clean REVIEW verification then make release CANDIDATE=<exact-full-SHA>, actual
plists/packages, complete Watch and iPhone profiles and candidate continuity.
Owner-accepted exceptions carry forward explicitly; no test or gate is changed.
Signed archive/export/server validation and TestFlight distribution verification
follow under the owner's explicit request, before normal app+IAP submission.

## Acceptance criteria

- [ ] M17 DONE, all six domain records current and no unaccepted P0/P1.
- [ ] make milestone ID=M18 and make release CANDIDATE=<full-SHA> executed unchanged
      on the same candidate; raw exits/counts/verdicts recorded.
- [ ] If only the two accepted Contrast failed cases remain, record the owner's
      acceptance separately; never invent automated READY_FOR_HUMAN.
- [ ] Handoff, static/status/continuity complete. New build identity and active
      monitor guards match before App Review; no Sandbox/TestFlight offer clock.

## Non-goals

No new product changes, no rewriting M10/M16 evidence, no bypass of Apple's former
submission restriction. Prove the ordinary iPhone app plus first IAP path with the
new build. Submission is explicitly authorized by the owner's current request.

## Owner acceptance

AI/evidence/M17/owner-release-authorization.md carries the exact existing scope into
this release assessment. Any new failure or unavailable unaccepted required
coverage still blocks; complete suites and result parsers remain mandatory.
