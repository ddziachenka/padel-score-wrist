# M25 — Gesture Experience and Store Materials

**ID:** M25
**Status:** DONE
**Depends on:** M28
**Validation:** make milestone ID=M25
**Handoff:** AI/handoffs/M25-handoff.md

## Objective

Revalidate the complete experience and prepare evidence that reviewers can reproduce.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Six ordered domains: functional, ui-ux, content, accessibility, product, release. Typed inventory and current records under AI/audits/M25-<domain>-revalidation.md. Digital Simulator journeys, localization, privacy and StoreKit simulation; all Watch/iPhone/creative galleries in14ASC locales, three imagegen directions and selected refined artwork, site/metadata and Review Notes drafts. The approved gesture plan assigns every physical check and real Watch video to M29.

## Acceptance criteria

- [x] All six digital domain records cover updated inventory and exact candidate inputs; no unresolved P0/P1. Physical rows explicitly belong to M29 and are not claimed passed here.
- [x] All required Simulator/runtime evidence is current; every physical Watch/iPhone/VoiceOver/haptic/StoreKit scenario is inventoried for M29.
- [x] All supported locales, minimum/current runtimes, light/dark and large text are checked in their applicable surfaces.
- [x] All active galleries are replaced locally with actual new UI/provenance, gesture-first narrative and selected generated explanatory artwork; hardware-dependent claims require M29 confirmation. No unsupported uniqueness claims.
- [x] Verification accepted under the explicit M25-only owner exception: same-SHA Watch plus complete new phone suites pass; raw full make failures remain separate.

## Non-goals

No automatic publication, external reply, price change or resubmission.

## Validation

Original command: `make milestone ID=M25` on a clean REVIEW commit. Its raw FAILED/130 report is retained. The explicit M25-only [owner exception](../evidence/M25/owner-verification-exception.md) accepts the fully passing Watch component plus complete new phone verification on the same unchanged SHA. No skipped/failed mandatory component or inherited contrast waiver is accepted. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.

Owner-approved scope is now AI/gesture-differentiation-plan.md; M29 assembles final current six-domain records for M26.


## M28 digital handoff

M28's required native full phone/current suites pass; some minimum-iOS17 captures
labelled Dark still render Light despite XCTest's setting readback. The six-domain
digital appearance/localization review owns resolving this automation discrepancy
and recording actual per-surface/theme pixels across the store locales. Do not use
capture labels/getter assertions alone as proof, and do not exempt native audits.
M28 records actual current-iOS Light/Dark inspection and minimum-phone observations
separately. This digital follow-up must be complete before M29/M26.

## Owner-authorized completion

M25 is DONE under the explicit M25-only owner exception. Verified candidate
`5eb65bbc17e9540d3922a520b44d3c8731947432`: watch 635/635 definitions/1085 invocations; phone-unit 21/21 definitions/30 invocations; phone-ui 21/21 definitions/21 invocations.
Aggregate 677 definitions/1136 invocations, zero failed/skipped/
expected/native runtime warnings in the accepted components. Both Debug/package
guards pass. Complete new phone command `bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`, exit0,
UTC2026-10-31T14:27:08Z–2026-10-31T16:45:19Z; report `.artifacts/M25/phone-complete-same-candidate/report.md`.
The Watch component is from `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult` at exactly the same SHA.
The complete monolithic make remains FAILED/exit130, never relabelled passed.
See [owner authorization](../evidence/M25/owner-verification-exception.md) and
[exact verification](../evidence/M25/milestone-verification.md). All physical checks remain M29.

Handoff: [M25](../handoffs/M25-handoff.md). M26 retains full milestone/release gates.
