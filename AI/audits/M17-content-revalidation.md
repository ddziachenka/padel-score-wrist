# M17 final domain audit — content

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-content.md
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

- REL-405 | OUTCOME=VERIFIED | EVIDENCE=Phone uses LifetimeProduct.displayPrice from StoreKit; full phone tests cover US/USD and German/EUR storefronts and0/paid price. No formatted guessed amount; owned state intentionally hides purchase CTA.
- REL-406 | OUTCOME=VERIFIED | EVIDENCE=Physical Access contains Support/Privacy/Terms and Watch requirement, with all tabs usable. No automatic purchase/paywall. PhoneLegalLinks resolves localized existing routes; published site131/131 exact files checked.
- REL-408 | OUTCOME=VERIFIED | EVIDENCE=No crossed-out price/savings/temporary price baked into paywall/assets. Exact StoreKit price shown for available product; launch offer is existing non-consumable0 and requires confirmation. Clock begins only actual public launch day plus seven full regional days.
- REL-503 | OUTCOME=VERIFIED | EVIDENCE=M17 found old public pages lacked M16 companion/review-preference explanation. Authorized existing prepared site published with make site-deploy PRODUCTION=1, exit0. HTTPS131/131 source hashes match, including all localized Privacy pages; .artifacts/M17/live-readback.json.
- REL-506 | OUTCOME=VERIFIED | EVIDENCE=Phone native HTTPS localized links share existing pages; route tests cover Spanish/Portuguese/Norwegian/Russian/English. Watch displays readable offline legal/contact/URLs; BootstrapUITests passes. All39 legal/support URLs resolve in131-file public readback.
- REL-801 | OUTCOME=VERIFIED | EVIDENCE=Current strings/native screens and52 public HTML pages reviewed; no placeholder claim, fake outcome or app-facing implementation label added. Store screenshots are genuine native images; temporary launch price is not embedded.
- REL-802 | OUTCOME=VERIFIED | EVIDENCE=Phone text explains Watch requirement, installation, one payment, offline independence, local history boundary and recovery. Physical Start/Access copy is readable; existing catalogs plus48 phone keys remain translated with glossary checks.
- REL-803 | OUTCOME=VERIFIED | EVIDENCE=All13 app language variants/14 ASC locales retain catalogs and52 translated pages. M16 real56-image gallery plus complete Watch locale Creation/Journeys/Screens coverage and static localization guards passed; no machine popularity estimates invented.
- REL-804 | OUTCOME=VERIFIED | EVIDENCE=Spanish NOSOTROS largest-text case uses full-width wrapping cards; full M16 UI gallery checks all locales. German/Finnish/Russian and both Portuguese contact sheets re-inspected; old contrast finding retained with bounded exception.
- REL-805 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No RTL language ships in the approved language set.
- REL-1004 | OUTCOME=VERIFIED | EVIDENCE=All localized public support pages HTTPS200 and source-identical after M17 deployment; exact source/readback hashes .artifacts/M17/live-readback.json. ASC support URLs use those routes.
- REL-1008 | OUTCOME=VERIFIED | EVIDENCE=Every public Terms page retains Apple Standard EULA link https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ and no invented custom agreement. Public131-file source-identical readback passed.

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
