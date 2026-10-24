# M17 final domain audit — release

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-release.md
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

- REL-208 | OUTCOME=VERIFIED | EVIDENCE=ReviewEligibility test requires both demos, later calendar day, purchase idle and365-day spacing. CompanionRootView invokes injected requestReview only at Start; physical first-day use completing both demos produced no prompt. No sentiment or entitlement gate.
- REL-209 | OUTCOME=VERIFIED | EVIDENCE=PhoneHelpView has a native Link to https://apps.apple.com/app/id6825393194?action=write-review; ReviewAndLinksTests verifies exact existing app ID. System refusal/no prompt leaves all tabs usable. Public review page availability begins with first public release; no posted review or prepublication page success is claimed.
- REL-301 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No health/location/camera/microphone/contacts/notification permission is requested; StoreKit authorization is assessed separately.
- REL-302 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No sensitive device permission is requested, so no corresponding denial flow exists.
- REL-303 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No sensitive device permission is requested, so no corresponding runtime revocation exists.
- REL-304 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=The app requests no sensitive device permissions or background data entitlement.
- REL-401 | OUTCOME=VERIFIED | EVIDENCE=M16 genuine StoreKitTest free/paid purchase and signed entitlement pass, plus owner-accepted current physical Sandbox observations. Physical Access currently shows verified lifetime. TestFlight was opened; this app is not available there before upload. No new physical acquisition is claimed.
- REL-402 | OUTCOME=VERIFIED | EVIDENCE=Full phone StoreKit tests cover cancelled/pending/approval/unverified; shared entitlement never grants pending/unverified rights. Physical AppStore.sync authorization was cancelled, Access recovered and owned status persisted. This is cancellation evidence, not a new restore success.
- REL-403 | OUTCOME=VERIFIED | EVIDENCE=M16 fresh entitlement-store restore/relaunch tests pass; owner explicitly confirmed restore on both devices previously. New physical reinstall/fresh Sandbox acquisition not executed and explicitly owner-accepted. Current restore attempt cancelled at Apple sign-in; not labelled successful.
- REL-404 | OUTCOME=VERIFIED | EVIDENCE=Shared signed transaction revocation/refund tests remove new-game unlock and retain existing game/history. Non-consumable has no expiry; test price return0→4.99 preserves acquired lifetime. Each device independently queries Apple transactions.
- REL-405 | OUTCOME=VERIFIED | EVIDENCE=Phone uses LifetimeProduct.displayPrice from StoreKit; full phone tests cover US/USD and German/EUR storefronts and0/paid price. No formatted guessed amount; owned state intentionally hides purchase CTA.
- REL-406 | OUTCOME=VERIFIED | EVIDENCE=Physical Access contains Support/Privacy/Terms and Watch requirement, with all tabs usable. No automatic purchase/paywall. PhoneLegalLinks resolves localized existing routes; published site131/131 exact files checked.
- REL-407 | OUTCOME=VERIFIED | EVIDENCE=No forced onboarding/paywall, fake countdown, recurring plan, preselected subscription, deceptive close or purchase gate. Physical Start/demo are reachable while owned and functional UI test checks access before Watch install.
- REL-408 | OUTCOME=VERIFIED | EVIDENCE=No crossed-out price/savings/temporary price baked into paywall/assets. Exact StoreKit price shown for available product; launch offer is existing non-consumable0 and requires confirmation. Clock begins only actual public launch day plus seven full regional days.
- REL-501 | OUTCOME=VERIFIED | EVIDENCE=Phone PrivacyInfo.xcprivacy declares UserDefaults CA92.1, empty collected-data/tracking arrays. ReviewEligibility stores first-use/demo-completion/last-attempt locally. No backend, analytics or WatchConnectivity transfer. Watch privacy architecture remains unchanged.
- REL-502 | OUTCOME=VERIFIED | EVIDENCE=Published ASC Data Not Collected disclosure from existing preparation matches inspected current source: no collection/backend/tracking; only local review prefs added. Apple handles StoreKit; developer receives no payment card or game data.
- REL-503 | OUTCOME=VERIFIED | EVIDENCE=M17 found old public pages lacked M16 companion/review-preference explanation. Authorized existing prepared site published with make site-deploy PRODUCTION=1, exit0. HTTPS131/131 source hashes match, including all localized Privacy pages; .artifacts/M17/live-readback.json.
- REL-504 | OUTCOME=VERIFIED | EVIDENCE=StoreKit diagnostic prints and DebugPremiumOverride are enclosed by #if DEBUG. No phone production logger/network endpoint/PII path; signed Release archive inspection and strict package verification pass. Release gate rechecks device build.
- REL-505 | OUTCOME=VERIFIED | EVIDENCE=Watch Settings local deletion retains purchase/free counter by explicit contract, atomically erases session/history/settings copies; deletion fault tests in full M16 suite. Phone deletion removes local review prefs only; no sync/backend/developer copy exists.
- REL-506 | OUTCOME=VERIFIED | EVIDENCE=Phone native HTTPS localized links share existing pages; route tests cover Spanish/Portuguese/Norwegian/Russian/English. Watch displays readable offline legal/contact/URLs; BootstrapUITests passes. All39 legal/support URLs resolve in131-file public readback.
- REL-801 | OUTCOME=VERIFIED | EVIDENCE=Current strings/native screens and52 public HTML pages reviewed; no placeholder claim, fake outcome or app-facing implementation label added. Store screenshots are genuine native images; temporary launch price is not embedded.
- REL-1004 | OUTCOME=VERIFIED | EVIDENCE=All localized public support pages HTTPS200 and source-identical after M17 deployment; exact source/readback hashes .artifacts/M17/live-readback.json. ASC support URLs use those routes.
- REL-1005 | OUTCOME=VERIFIED | EVIDENCE=Existing ASC age4+ and Sports category match padel scoring, tutorials and non-consumable access; no chat/UGC/gambling/sensitive content added. Saved release preparation declarations unchanged in substance; final ASC readback required before submission.
- REL-1007 | OUTCOME=VERIFIED | EVIDENCE=AI/evidence/M16/review-notes-draft.md describes iPhone Start/demos/Access, independent Watch, five free completed Watch games, StoreKit restore and zero-price launch acquisition. No review login needed. Must save/read back on selected new build before submission.
- REL-1008 | OUTCOME=VERIFIED | EVIDENCE=Every public Terms page retains Apple Standard EULA link https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ and no invented custom agreement. Public131-file source-identical readback passed.
- REL-1101 | OUTCOME=VERIFIED | EVIDENCE=No release debug UI/test launch path; DebugPremiumOverride and diagnostic logging compile only DEBUG. Signed1.0(2) archive packaging/codesign pass and contains no .storekit/.xctest/test hosts; exact production input continuity to M16 preserved.
- REL-1102 | OUTCOME=VERIFIED | EVIDENCE=Version1.0/build2 matches real iPhone executable, independent Watch companion and launcher in signed archive. ASC old build1 remains selected until new distribution readiness; final candidate ID must be read back before submission.
- REL-1103 | OUTCOME=VERIFIED | EVIDENCE=No new diagnosed P0/P1 found. Public policy mismatch fixed by publishing prepared M16 copy. Two exact native contrast audit errors and accepted physical omissions remain explicitly owner-disposed; not converted to automated passes.
- REL-1105 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=M16 adds only local phone review preferences; Watch persisted schema/data model remains unchanged. No new migration or backend exists.

## Findings

| ID | Severity | Location | Reproduction and required correction |
| --- | --- | --- | --- |
| M17-R1 | P1, resolved | Public site |52 pages lacked prepared M16 companion/review-preference copy. Published existing prepared source;131/131 files read back identical. No new legal or collection decision. |
| M17-A1 | P2, owner-accepted uncertainty | Native iOS17 SE3 audit |Only testLargestTextAccessibility and testSpanishTeamNamesAtLargestTextAreNotClipped return Contrast failed. Not proved false positives; current-iOS27 tests pass. Raw errors retained. |

## Fixes

Public M16 prepared website published using existing make site-deploy PRODUCTION=1,
exit0. No production app, data model, price or transaction policy changed. The narrowly identified native review prompt is now declined in UI setup, with every existing assertion and native audit retained; see AI/evidence/M17/review-prompt-regression.md.
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

## Later-day UI harness correction

AI/evidence/M17/review-prompt-regression.md records the additional blocking failure,
reproduction and correction. Production inputs and approved review timing remain
unchanged. Only UI setup identifies and declines the known optional native review
prompt; original assertions, audit categories and full gates remain mandatory.
Both ordinary and qualifying launches passed targeted diagnosis. Full clean M17
verification follows; this does not reuse the failed first run as completion.
