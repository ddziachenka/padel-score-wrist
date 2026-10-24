# M17 final domain audit — product

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-product.md
**Candidate:** 9ab02a92c1b78c1153ea98a4f115a745c48c8615
**Audited at:** 2026-10-24T18:23:00Z

This is current runtime/source reassessment of all affected companion release domains,
not independent approval. Exact-input M16 evidence is referenced, not inherited M10
readiness. The owner explicitly requested separate release revalidation with existing
exceptions: AI/evidence/M17/owner-release-authorization.md. Raw failed tests remain
failures. OUTCOME=VERIFIED below means assessed coverage, including explicit owner
exception where named; it never relabels an audit or unperformed device check a pass.

## Candidate context

App/Config/Scripts are unchanged from M16 final implementation fc118f8a0b357d52e0b06f8ba1f17449297ca623
through source checkpoint 9ab02a92c1b78c1153ea98a4f115a745c48c8615. Phone iOS27.0.1 current physical device was operated
through normal iPhone Mirroring with a shared-desktop/physical-pair lease. Observed
Start, exact Match and Americano sequences, owned Access and normal cancellation of
Apple sign-in during restore. No password entered, no purchase history reset, no new
physical acquisition/reinstall claimed. TestFlight opened; PadelScore absent before
upload. Mandatory complete M16 bundles and supplements are documented in
AI/evidence/M16/milestone-verification.md; new full M17 gate follows these records.
Public site revalidation: .artifacts/M17/live-readback.json,131/131 identical files.

**Coverage result:** COMPLETE
**Open P0/P1:** 0

## Coverage

- REL-201 | OUTCOME=VERIFIED | EVIDENCE=DESIGN J1–J8 exercised by complete current Watch M16 suite. Physical phone Start→Match40/30→Golden point→game3–2→Undo40/40, Americano10–10→12–12 draw and Access were walked in this revalidation.
- REL-202 | OUTCOME=VERIFIED | EVIDENCE=Current PRODUCT M16 fixtures, independent Watch boundary, five free completed Watch games and one existing non-consumable match source/unit/UI and physical observations. Phone has no real-match repository or claimed Watch free-game remainder.
- REL-203 | OUTCOME=VERIFIED | EVIDENCE=Start has immediate demo action; offline/unavailable Access provides Retry/Restore; Watch empty history provides navigation. Phone demos contain no persisted history or empty database.
- REL-205 | OUTCOME=VERIFIED | EVIDENCE=Physical cancellation displayed Purchase cancelled. Nothing has changed. and retained verified ownership. Shared PurchaseMessages and StoreKit network/unverified/pending tests explain recovery without granting unsupported rights.
- REL-206 | OUTCOME=VERIFIED | EVIDENCE=Physical Undo reopened finished Match with exact score/service; demos reset only memory. Real Watch correction/delete confirmation and transactional deletion coverage passed in M16 complete suite. No owner data was deleted in this audit.
- REL-208 | OUTCOME=VERIFIED | EVIDENCE=ReviewEligibility test requires both demos, later calendar day, purchase idle and365-day spacing. CompanionRootView invokes injected requestReview only at Start; physical first-day use completing both demos produced no prompt. No sentiment or entitlement gate.
- REL-209 | OUTCOME=VERIFIED | EVIDENCE=PhoneHelpView has a native Link to https://apps.apple.com/app/id6825393194?action=write-review; ReviewAndLinksTests verifies exact existing app ID. System refusal/no prompt leaves all tabs usable. Public review page availability begins with first public release; no posted review or prepublication page success is claimed.
- REL-401 | OUTCOME=VERIFIED | EVIDENCE=M16 genuine StoreKitTest free/paid purchase and signed entitlement pass, plus owner-accepted current physical Sandbox observations. Physical Access currently shows verified lifetime. TestFlight was opened; this app is not available there before upload. No new physical acquisition is claimed.
- REL-402 | OUTCOME=VERIFIED | EVIDENCE=Full phone StoreKit tests cover cancelled/pending/approval/unverified; shared entitlement never grants pending/unverified rights. Physical AppStore.sync authorization was cancelled, Access recovered and owned status persisted. This is cancellation evidence, not a new restore success.
- REL-403 | OUTCOME=VERIFIED | EVIDENCE=M16 fresh entitlement-store restore/relaunch tests pass; owner explicitly confirmed restore on both devices previously. New physical reinstall/fresh Sandbox acquisition not executed and explicitly owner-accepted. Current restore attempt cancelled at Apple sign-in; not labelled successful.
- REL-404 | OUTCOME=VERIFIED | EVIDENCE=Shared signed transaction revocation/refund tests remove new-game unlock and retain existing game/history. Non-consumable has no expiry; test price return0→4.99 preserves acquired lifetime. Each device independently queries Apple transactions.
- REL-405 | OUTCOME=VERIFIED | EVIDENCE=Phone uses LifetimeProduct.displayPrice from StoreKit; full phone tests cover US/USD and German/EUR storefronts and0/paid price. No formatted guessed amount; owned state intentionally hides purchase CTA.
- REL-406 | OUTCOME=VERIFIED | EVIDENCE=Physical Access contains Support/Privacy/Terms and Watch requirement, with all tabs usable. No automatic purchase/paywall. PhoneLegalLinks resolves localized existing routes; published site131/131 exact files checked.
- REL-407 | OUTCOME=VERIFIED | EVIDENCE=No forced onboarding/paywall, fake countdown, recurring plan, preselected subscription, deceptive close or purchase gate. Physical Start/demo are reachable while owned and functional UI test checks access before Watch install.
- REL-408 | OUTCOME=VERIFIED | EVIDENCE=No crossed-out price/savings/temporary price baked into paywall/assets. Exact StoreKit price shown for available product; launch offer is existing non-consumable0 and requires confirmation. Clock begins only actual public launch day plus seven full regional days.

## Findings

| ID | Severity | Location | Reproduction and required correction |
| --- | --- | --- | --- |
| M17-R1 | P1, resolved | Public site |52 pages lacked prepared M16 companion/review-preference copy. Published existing prepared source;131/131 files read back identical. No new legal or collection decision. |
| M17-A1 | P2, owner-accepted uncertainty | Native iOS17 SE3 audit |Only testLargestTextAccessibility and testSpanishTeamNamesAtLargestTextAreNotClipped return Contrast failed. Not proved false positives; current-iOS27 tests pass. Raw errors retained. |

## Fixes

Public M16 prepared website published using existing make site-deploy PRODUCTION=1,
exit0. No app, data model, price, transaction policy, test or parser changed.
Evidence: .artifacts/M17/site-deploy.log, live-before.json, live-readback.json.

## Deferred P2

The two bounded native contrast results remain explicitly accepted for this release.
No broader accessibility category excluded. Additional physical scenarios remain
accepted omissions and are not labelled passed. No cosmetic redesign added.

## FUTURE_PRODUCT_IDEA

None in this scope. History sync, real phone games and remote Watch control remain
outside the approved companion.

## Targeted re-audit

Only external content changed: all131 public files re-read and hash matched;52 pages
and78 PNGs plus CSS are current. Physical Restore cancellation recovered without
losing ownership. No new production code to re-audit; full platform gates follow.

## Validation

Current source/runtime evidence: AI/evidence/M16/milestone-verification.md plus current
physical observations above. Exact new make milestone ID=M17 result and candidate
will be recorded in AI/handoffs/M17-handoff.md after its unchanged full run. No new
passing gate or release verdict is claimed by this preliminary domain record.
