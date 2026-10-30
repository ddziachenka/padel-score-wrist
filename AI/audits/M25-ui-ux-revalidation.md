# M25 digital domain revalidation — ui-ux

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-ui-ux.md
**Candidate:** 4f1689944480aadfad592629e3c8394a9582c6b7
**Audited at:** 2026-10-30

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is an
interim digital record, not a COMPLETE final release-domain record consumed by M26.
PENDING_DIGITAL means the named current-source run/readback is still required;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Final candidate/commands/counts will be bound in the M25 handoff and verification
record; capture-source inputs are recorded in the material manifest.

**Coverage result:** DIGITAL_IN_PROGRESS
**Open P0/P1:** See findings; no unresolved product defect currently known.

## Coverage

- REL-102 | OUTCOME=PENDING_DIGITAL | EVIDENCE=NewGameUITests, HistoryUITests and CompanionUITests optional first launch; no forced paywall or onboarding.
- REL-105 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Minimum watchOS10/current27 and minimum iOS17/current27 managed launches; physical oldest-device timing remains M29.
- REL-203 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Empty local History/new setup, demo actions and initial Access without a product remain usable.
- REL-204 | OUTCOME=PENDING_DIGITAL | EVIDENCE=EntitlementStore/AccessOffer/StoreKitPurchaseTests bounded unavailable/retry/pending handling; save failure retains retry/cancel.
- REL-205 | OUTCOME=PENDING_DIGITAL | EVIDENCE=NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry.
- REL-206 | OUTCOME=PENDING_DIGITAL | EVIDENCE=History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation.
- REL-407 | OUTCOME=PENDING_DIGITAL | EVIDENCE=DESIGN comparison: no subscription/trial/dark-pattern savings, no paywall on phone cold launch, price comes from Apple.
- REL-602 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Watch LargeText/Journal/KnownScore/PlayerNames/Gesture matrices and phone recovery/gesture13locale Light/Dark maximum-size matrices, plus centered EN/DE/RU regression.
- REL-603 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Source/DesignSystem checks preserve information without animation. Actual assistive-display preference and haptic behavior remain M29.
- REL-604 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Original native contrast categories retained on both supported phone themes and Watch dark surface; Start findings corrected with measured opaque semantic labels.
- REL-605 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Native hit-region audits and explicit44pt centered controls; Watch scrolling/reflow tests preserve tap reachability.
- REL-606 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Labels, numbers, disabled states, Pending team text, score/service/Undo announcements carry meaning independently of lime.
- REL-701 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Watch is approved dark-only. Phone real screenshot-margin pixels must prove Dark on7surfaces and every themed locale-matrix capture.
- REL-702 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Phone real screenshot-margin pixels must prove Light on7surfaces and every themed locale-matrix capture. Watch light appearance is outside approved design.
- REL-703 | OUTCOME=PENDING_DIGITAL | EVIDENCE=40mm Watch/minimum OS and SE3/iOS17 smallest-phone runtime checks; long body measurement and largest-text reflow inspected.
- REL-704 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No iPad target/layout is approved or shipped; phone UIDeviceFamily is iPhone.
- REL-705 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Phone is portrait-only; Watch uses system wrist/Crown orientation, not an application landscape layout.
- REL-706 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Current source compared with baseline; no shipped public version exists. Center alignment is explicit owner steering, not a speculative redesign.
- REL-804 | OUTCOME=PENDING_DIGITAL | EVIDENCE=German/Russian largest Start and all13locale recovery/gesture matrices; complete long legal texts remain scrollable.
- REL-805 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No right-to-left language ships in the approved locale set.
- REL-1302 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GestureInput/LiveScore tests fixed3s, one/two/third, touch/navigation/inactive/revision cancellation, atomic ordinary rally and deadline race; physical recognition M29.
- REL-1305 | OUTCOME=PENDING_DIGITAL | EVIDENCE=KnownScore validation/UI explicit service, unknown earlier rallies/checkpoint boundary, invalid/completed inputs cannot start, one normal counted GameID.

## Findings and fixes

Owner requested centered recovery heading/actions. Native largest-text inspection also exposed clipped DE/RU introduction and current-iOS contrast on ordinary Start/primary labels; corrected native measurement/opaque semantic surfaces and accessibility-size icon arrangement. Watch capture navigation was refined to show actual Points and After content.

Full failure/reproduction history: [work log](../evidence/M25/work-log.md).
Final-targeted native centered checks: [runtime](../evidence/M25/runtime.md).
All applicable physical scenarios: [M29 inventory](../evidence/M25/M29-hardware-inventory.md).
Internal-channel REL-1201–1203 do not apply to the configured app-store channel;
no internal installation is inferred from Simulator.

## Deferred P2 / future product ideas

None added. No cloud sync, tournament standings or real phone scoring is introduced.
No final readiness or actual hardware result is claimed.

## Targeted re-audit

Final affected/runtime/material re-audit follows completion of current runs.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
