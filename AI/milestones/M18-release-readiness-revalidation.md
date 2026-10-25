# M18 — Release Readiness Revalidation

**ID:** M18
**Status:** DONE
**Depends on:** M17
**Validation:** make release CANDIDATE=<full-SHA>
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

Clean REVIEW immutable verification via make release CANDIDATE=<exact-full-SHA>, actual
plists/packages, complete Watch and iPhone profiles and candidate continuity.
Owner-accepted exceptions carry forward explicitly; no test or gate is changed.
Signed archive/export/server validation and TestFlight distribution verification
follow under the owner's explicit request, before normal app+IAP submission.

## Acceptance criteria

- [x] M17 DONE, all six domain records current and no unaccepted P0/P1.
- [x] make release CANDIDATE=<full-SHA> executed unchanged on clean REVIEW candidate;
      raw exits/counts/verdicts recorded. Full M17 is already complete on identical
      App/Config/Scripts inputs, with only continuity Markdown added since.
- [x] If only the two accepted Contrast failed cases remain, record the owner's
      acceptance separately; never invent automated READY_FOR_HUMAN.
- [x] Handoff, static/status/continuity complete. New build identity and active
      monitor guards match before App Review; no Sandbox/TestFlight offer clock.

## Non-goals

No new product changes, no rewriting M10/M16 evidence, no bypass of Apple's former
submission restriction. Prove the ordinary iPhone app plus first IAP path with the
new build. Submission is explicitly authorized by the owner's current request.

## Owner acceptance

AI/evidence/M17/owner-release-authorization.md carries the exact existing scope into
this release assessment. Any new failure or unavailable unaccepted required
coverage still blocks; complete suites and result parsers remain mandatory.

## Bounded verification consolidation — before M18 starts

Owner asked «Действуй рационально, если на чем-то можно сократить время то сократи».
The agent combines the unstarted redundant M18 milestone rerun with its stricter
full immutable release command. M17 already ran both complete platforms. M18 now
declares the unchanged make release command as its exact validation, retaining
all test definitions, invocations, assertions, native audit categories, platforms,
release policy, build, package and parser checks. No generic script/config change.
The previously planned make milestone ID=M18 is not run and not called passed.
This is scheduling consolidation, not owner acceptance of any additional failure.
Any changed app/config/test input or new failure still requires fresh verification.
Raw accepted failures remain FAILED/VERIFICATION_FAILED, not READY_FOR_HUMAN.

Exact result/owner disposition: AI/handoffs/M18-handoff.md. Distribution guards remain required before App Review.
