# M25 — Gesture Experience and Store Materials

**ID:** M25
**Status:** REVIEW
**Depends on:** M28
**Validation:** make milestone ID=M25
**Handoff:** AI/handoffs/M25-handoff.md

## Objective

Revalidate the complete experience and prepare evidence that reviewers can reproduce.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Six ordered domains: functional, ui-ux, content, accessibility, product, release. Typed inventory and current records under AI/audits/M25-<domain>-revalidation.md. Digital Simulator journeys, localization, privacy and StoreKit simulation; all Watch/iPhone/creative galleries in14ASC locales, three imagegen directions and selected refined artwork, site/metadata and Review Notes drafts. The approved gesture plan assigns every physical check and real Watch video to M29.

## Acceptance criteria

- [ ] All six digital domain records cover updated inventory and exact candidate inputs; no unresolved P0/P1. Physical rows explicitly belong to M29 and are not claimed passed here.
- [ ] All required Simulator/runtime evidence is current; every physical Watch/iPhone/VoiceOver/haptic/StoreKit scenario is inventoried for M29.
- [ ] All supported locales, minimum/current runtimes, light/dark and large text are checked in their applicable surfaces.
- [ ] All active galleries are replaced locally with actual new UI/provenance, gesture-first narrative and selected generated explanatory artwork; hardware-dependent claims require M29 confirmation. No unsupported uniqueness claims.
- [ ] Full make milestone ID=M25 passes; raw historical failures remain separate.

## Non-goals

No automatic publication, external reply, price change or resubmission.

## Validation

`make milestone ID=M25` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.

Owner-approved scope is now AI/gesture-differentiation-plan.md; M29 assembles final current six-domain records for M26.


## M28 digital handoff

M28's required native full phone/current suites pass; some minimum-iOS17 captures
labelled Dark still render Light despite XCTest's setting readback. The six-domain
digital appearance/localization review owns resolving this automation discrepancy
and recording actual per-surface/theme pixels across the store locales. Do not use
capture labels/getter assertions alone as proof, and do not exempt native audits.
M28 records actual current-iOS Light/Dark inspection and minimum-phone observations
separately. This digital follow-up must be complete before M29/M26.
