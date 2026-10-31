# M25 digital domain revalidation — ui-ux

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (completed digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-ui-ux.md
**Candidate:** 5eb65bbc17e9540d3922a520b44d3c8731947432
**Audited at:** 2026-10-31

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is a
completed digital record, not a COMPLETE final release-domain record consumed by M26.
VERIFIED_DIGITAL means the named source/Simulator/readback evidence is complete;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Exact command/exit0/counts and the M25-only owner authorization are bound in
[verification](../evidence/M25/milestone-verification.md). The monolithic make
remains FAILED; no failed phone result is accepted.

**Coverage result:** DIGITAL_COMPLETE
**Open P0/P1:** None currently identified in reviewed source. C1/C2 are corrected; f097 minimum/current Watch and complete current-phone20 pass. Both new gallery4 bundles, strict provenance/site checks and all42 visual reviews pass. The required component verification is accepted under the explicit M25-only owner exception; raw full reports remain FAILED.

## Coverage

- REL-102 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=NewGameUITests, HistoryUITests and CompanionUITests optional first launch; no forced paywall or onboarding.
- REL-105 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Minimum watchOS10/current27 and minimum iOS17/current27 managed launches; physical oldest-device timing remains M29.
- REL-203 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Empty local History/new setup, demo actions and initial Access without a product remain usable.
- REL-204 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=EntitlementStore/AccessOffer/StoreKitPurchaseTests bounded unavailable/retry/pending handling; save failure retains retry/cancel.
- REL-205 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry.
- REL-206 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation.
- REL-407 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=DESIGN comparison: no subscription/trial/dark-pattern savings, no paywall on phone cold launch, price comes from Apple.
- REL-602 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Watch LargeText/Journal/KnownScore/PlayerNames/Gesture matrices and phone recovery/gesture13locale Light/Dark maximum-size matrices, plus centered EN/DE/RU regression.
- REL-603 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Source/DesignSystem checks preserve information without animation. Actual assistive-display preference and haptic behavior remain M29.
- REL-604 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Original native contrast categories retained on both supported phone themes and Watch dark surface; Start findings corrected with measured opaque semantic labels.
- REL-605 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Native hit-region audits and explicit44pt centered controls; Watch scrolling/reflow tests preserve tap reachability.
- REL-606 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Labels, numbers, disabled states, Pending team text, score/service/Undo announcements carry meaning independently of lime.
- REL-701 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Watch is approved dark-only. Phone real screenshot-margin pixels prove Dark on8surfaces and every themed locale-matrix capture.
- REL-702 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Phone real screenshot-margin pixels prove Light on8surfaces and every themed locale-matrix capture. Watch light appearance is outside approved design.
- REL-703 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=40mm Watch/minimum OS and SE3/iOS17 smallest-phone runtime checks; long body measurement and largest-text reflow inspected.
- REL-704 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No iPad target/layout is approved or shipped; phone UIDeviceFamily is iPhone.
- REL-705 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Phone is portrait-only; Watch uses system wrist/Crown orientation, not an application landscape layout.
- REL-706 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Current source compared with baseline; no shipped public version exists. Center alignment is explicit owner steering, not a speculative redesign.
- REL-804 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=German/Russian largest Start and all13locale recovery/gesture matrices; complete long legal texts remain scrollable.
- REL-805 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No right-to-left language ships in the approved locale set.
- REL-1302 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=GestureInput/LiveScore tests fixed3s, one/two/third, touch/navigation/inactive/revision cancellation, atomic ordinary rally and deadline race; physical recognition M29.
- REL-1305 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=KnownScore validation/UI explicit service, unknown earlier rallies/checkpoint boundary, invalid/completed inputs cannot start, one normal counted GameID.

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

Minimum-phone traversal correction: the first full fa70662 run is raw FAILED,
not a passing gate. Measured short-drag travel was insufficient for the distant
Portuguese-largest heading. The bounded64-drag correction preserves the exact
full-visibility predicate and all six native categories. A new focused regression
fails before and passes1/1 on minimum/current runtimes, zero adverse native counts;
current run uses clean source4720028. Production/gallery4 shipping inputs remain
unchanged. Exact source patches, commands, times, native counts and inspected
originals: [traversal evidence](../evidence/M25/minimum-gesture-audit-traversal.md).

Frozen f097 fresh minimum-phone4/4, minimum-Watch492/492 definitions/942
invocations, current-Watch498/498/948 and complete current-phone20/20 pass,
exit0, all zero failed/skipped/expected/native runtime-warning counts. This
includes26 language/theme pairs each for gesture/reset, maximum-text Help and
both recovery journeys, actual eight-surface theme pixels and centered EN/DE/RU.
The strict accepted native summaries/leaf counts are in runtime.md and
native-supplements.json. Both gallery4 bundles, strict material/site checks and all42 final visual contact
reviews pass. The required component verification is accepted under the explicit M25-only owner exception; raw full reports remain FAILED. The additional baseline-matched current StoreKit
probe stays FAILED/P2; storekit-current-runtime.md records the exact boundaries.
Physical evidence remains PENDING_M29.

## Validation

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
