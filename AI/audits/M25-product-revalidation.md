# M25 digital domain revalidation — product

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (completed digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-product.md
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

- REL-201 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Full Watch journey suites and all phone interactive guide/demo cases; screenshots are actual app surfaces, not isolated mockups.
- REL-202 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=PRODUCT/ARCHITECTURE review: independent Watch scoring, five completed games, one lifetime purchase, unrestricted Match sets and no phone real-game repository.
- REL-203 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Empty local History/new setup, demo actions and initial Access without a product remain usable.
- REL-205 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry.
- REL-206 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation.
- REL-208 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=ReviewAndLinksTests later-day, both demos, idle/not purchasing, annual limit; real system prompt remains M29.
- REL-209 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=PhoneLinks exact review URL and no-prompt behavior; actual device external navigation remains M29.
- REL-401 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Genuine Xcode StoreKitTest verified purchase/update flow and shared Watch entitlement logic; fresh physical Sandbox acquisition remains M29.
- REL-402 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=StoreKitPurchaseTests cancellation, pending→approval, unverified and network-error paths; real Apple authorization remains M29.
- REL-403 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Fresh EntitlementStore instance restores verified Xcode transaction; physical fresh-install restore remains M29.
- REL-404 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Signed transaction refund/revocation removes new-game unlock while preserving current game/history; lifetime has no subscription expiry.
- REL-405 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=StoreKitPurchaseTests testPriceFollowsUSAndGermanStorefronts compares actual Product.displayPrice and USD/EUR; no application-formatted price.
- REL-406 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=Watch offline legal pages and phone Terms/Privacy links; close/back remains available and current game/history stay free.
- REL-407 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=DESIGN comparison: no subscription/trial/dark-pattern savings, no paywall on phone cold launch, price comes from Apple.
- REL-408 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=StoreKit zero→paid-price-return test preserves acquired rights; local neutral promo contains no temporary-offer clock or invented comparison.
- REL-1301 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=GestureScoring/NewGame/PlayAgain tests: all new games OFF, active ON persists outside score Undo, restart has no pending preview.
- REL-1304 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=RallyCorrection/Journal real-file and UI change/delete/insert preview/cancel/apply/retry/whole Undo, stable IDs/later winner order and explicit serving ambiguity.
- REL-1307 | OUTCOME=VERIFIED_DIGITAL | EVIDENCE=GesturePractice and CompanionDemo/Recovery models are memory-only with no real store/usage/entitlement/review dependencies; tab/cold-launch reset.

- REL-1308 | OUTCOME=PENDING_M29 | EVIDENCE=Actual supported-Watch recognition requires at least95% each-team success, zero wrong-team/accidental points in one-hour play and real video. Simulator activation is not physical proof.

## Findings and fixes

Gesture option stays off per new game, current-game choice persists; touch/Undo unchanged. Phone simulation is explicit and disposable. Main real-game value remains Watch scoring/service/history with five completed games free, one lifetime unlock. No new strategic/product decision.

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
