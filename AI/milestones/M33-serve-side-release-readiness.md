# M33 — Serve-side Release Readiness Revalidation

**ID:** M33
**Status:** PLANNED
**Depends on:** M32
**Validation:** make milestone ID=M33
**Handoff:** AI/handoffs/M33-handoff.md

## Objective

Establish fresh release readiness for the L/R candidate and prepare corresponding
local store screenshots and Review Notes, following AI/prompts/final-release-readiness.md.

## Scope

Update affected screenshots, localized store/review guide material and six-domain
coverage. Complete fresh affected physical Watch readability/VoiceOver acceptance.
Bind the new build identity and all required evidence to one exact candidate.

## Non-goals

No automatic App Review resubmission, price change or publication. Build 7 and its
old readiness/monitor guard remain historical. No inherited affected-only waiver.

## Acceptance criteria

- [ ] Current applicable six-domain coverage and affected device checks are complete;
      unavailable required hardware blocks readiness, and all P0/P1 issues are fixed.
- [ ] Updated local screenshots and review text demonstrate R/L and receivers' choice,
      without claiming competitor uniqueness or guaranteed review acceptance.
- [ ] make milestone ID=M33 and make release CANDIDATE=<verified-full-SHA> pass,
      with READY_FOR_HUMAN for that exact SHA and complete evidence in the handoff.
- [ ] Static/status/continuity validate the DONE record; human distribution decision
      remains pending and this session submits nothing.
