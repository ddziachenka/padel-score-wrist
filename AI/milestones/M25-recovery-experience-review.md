# M25 — Recovery Experience and Review Materials

**ID:** M25
**Status:** PLANNED
**Depends on:** M24
**Validation:** make milestone ID=M25
**Handoff:** AI/handoffs/M25-handoff.md

## Objective

Revalidate the complete experience and prepare evidence that reviewers can reproduce.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Six ordered domains: functional, ui-ux, content, accessibility, product, release. Typed inventory and current records under AI/audits/M25-<domain>-revalidation.md. Physical-device journeys, localization, privacy and StoreKit coverage; native screenshots, short Watch video and Review Notes drafts.

## Acceptance criteria

- [ ] All six current domain records honestly cover the updated inventory and exact candidate inputs; no unresolved P0/P1.
- [ ] Physical Watch/iPhone, VoiceOver/haptics, persistence/lifecycle and required StoreKit scenarios have current evidence; missing required coverage blocks.
- [ ] All supported locales, minimum/current runtimes, light/dark and large text are checked in their applicable surfaces.
- [ ] Materials demonstrate actual new behavior with provenance; no unsupported uniqueness or competitor-copying claims.
- [ ] Full make milestone ID=M25 passes; raw historical failures remain separate.

## Non-goals

No automatic publication, external reply, price change or resubmission.

## Validation

`make milestone ID=M25` on a clean REVIEW commit. No skipped/failed mandatory test or inherited contrast waiver. Record exact SHA, commands, exits, bundles and counts; self-review is not independent review. Complete handoff, DONE commit, static/status/continuity, then stop.
