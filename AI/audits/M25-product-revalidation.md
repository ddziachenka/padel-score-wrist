# M25 digital domain revalidation — product

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-product.md
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

- REL-201 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Full Watch journey suites and all phone interactive guide/demo cases; screenshots are actual app surfaces, not isolated mockups.
- REL-202 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PRODUCT/ARCHITECTURE review: independent Watch scoring, five completed games, one lifetime purchase, unrestricted Match sets and no phone real-game repository.
- REL-203 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Empty local History/new setup, demo actions and initial Access without a product remain usable.
- REL-205 | OUTCOME=PENDING_DIGITAL | EVIDENCE=NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry.
- REL-206 | OUTCOME=PENDING_DIGITAL | EVIDENCE=History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation.
- REL-208 | OUTCOME=PENDING_DIGITAL | EVIDENCE=ReviewAndLinksTests later-day, both demos, idle/not purchasing, annual limit; real system prompt remains M29.
- REL-209 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PhoneLinks exact review URL and no-prompt behavior; actual device external navigation remains M29.
- REL-401 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Genuine Xcode StoreKitTest verified purchase/update flow and shared Watch entitlement logic; fresh physical Sandbox acquisition remains M29.
- REL-402 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKitPurchaseTests cancellation, pending→approval, unverified and network-error paths; real Apple authorization remains M29.
- REL-403 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Fresh EntitlementStore instance restores verified Xcode transaction; physical fresh-install restore remains M29.
- REL-404 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Signed transaction refund/revocation removes new-game unlock while preserving current game/history; lifetime has no subscription expiry.
- REL-405 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKitPurchaseTests testPriceFollowsUSAndGermanStorefronts compares actual Product.displayPrice and USD/EUR; no application-formatted price.
- REL-406 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Watch offline legal pages and phone Terms/Privacy links; close/back remains available and current game/history stay free.
- REL-407 | OUTCOME=PENDING_DIGITAL | EVIDENCE=DESIGN comparison: no subscription/trial/dark-pattern savings, no paywall on phone cold launch, price comes from Apple.
- REL-408 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKit zero→paid-price-return test preserves acquired rights; local neutral promo contains no temporary-offer clock or invented comparison.
- REL-1301 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GestureScoring/NewGame/PlayAgain tests: all new games OFF, active ON persists outside score Undo, restart has no pending preview.
- REL-1304 | OUTCOME=PENDING_DIGITAL | EVIDENCE=RallyCorrection/Journal real-file and UI change/delete/insert preview/cancel/apply/retry/whole Undo, stable IDs/later winner order and explicit serving ambiguity.
- REL-1307 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GesturePractice and CompanionDemo/Recovery models are memory-only with no real store/usage/entitlement/review dependencies; tab/cold-launch reset.

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

Final affected/runtime/material re-audit follows completion of current runs.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
