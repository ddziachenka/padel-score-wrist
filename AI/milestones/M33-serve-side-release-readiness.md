# M33 — Serve-side Audit and Store Materials

**ID:** M33
**Status:** DONE
**Depends on:** M32
**Validation:** make milestone ID=M33
**Handoff:** AI/handoffs/M33-handoff.md

## Objective

Complete six-domain revalidation and fresh affected physical acceptance for the
L/R candidate, with corresponding local store screenshots and Review Notes.

## Approved split — 2026-11-07

The owner selected M33 audit/materials followed by M34 readiness. M33 owns the six
records AI/audits/M33-<domain>-revalidation.md, using the six ordered domain methods
in AI/prompts/audit-{functional,ui-ux,content,accessibility,product,release}.md and
AI/templates/domain-audit-template.md. M34 consumes these only after M33 is DONE.
[Exact decision](../evidence/M33/planning-blocker.md). Existing gates remain unchanged.

## Scope

Update affected screenshots, localized store/review guide material and six-domain
coverage. Complete fresh affected physical Watch readability/VoiceOver acceptance.
Bind the new build identity and all required evidence to one exact candidate.

## Non-goals

No release readiness verdict in this milestone; M34 owns the full release gate.
No automatic App Review resubmission, price change or publication. Build 7 and its
old readiness/monitor guard remain historical. No inherited affected-only waiver.

## Acceptance criteria

- [x] Current applicable six-domain coverage and affected device checks are complete;
      unavailable required hardware blocks readiness, and all P0/P1 issues are fixed.
- [x] Updated local screenshots and review text demonstrate R/L and receivers' choice,
      without claiming competitor uniqueness or guaranteed review acceptance.
- [x] Full make milestone ID=M33 passes at clean REVIEW/main with exact SHA,
      exit, counts and report in the handoff; all six records have complete typed
      coverage and zero open P0/P1 findings.
- [ ] Static/status/continuity validate the DONE record; human distribution decision
      remains pending and this session submits nothing.
