# M17 final domain audit — accessibility

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-accessibility.md
**Candidate:** 02ec9c97b1c6e1d2c1c58aec64f990ed76399f77
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

- REL-601 | OUTCOME=VERIFIED | EVIDENCE=Owner explicitly accepts existing physical assistive-technology scope; no new physical VoiceOver success is invented. Source exposes score label/value/hint, state announcement and semantic native navigation; Watch AccessibilityUITests passed. M16 current-iOS27 audits pass4/4. Coverage disposition includes the owner exception.
- REL-602 | OUTCOME=VERIFIED | EVIDENCE=Full-width accessibility score cards, wrapping headings/actions and scrolling preserve content. Spanish truncation fixed in M16. Current-iOS27 native largest-text and Spanish audits passed; SE3/iOS17 reports only the two accepted Contrast failed findings, not clipped text. Actual failures remain retained.
- REL-603 | OUTCOME=VERIFIED | EVIDENCE=Phone has no custom animated transitions or information carried by motion; native controls honor system settings. Watch accessibility/Reduce Motion coverage preserved in M16 complete suite. Additional physical motion/haptics checks are explicitly accepted omissions.
- REL-604 | OUTCOME=VERIFIED | EVIDENCE=Both appearances inspected through native dark screenshots and current physical light UI; semantic text asset alpha1.000 and AA regression checked. Two native SE3/iOS17 Contrast failed reports remain unresolved and explicitly owner-accepted; current-iOS27 audits pass. This row records completed assessment with exception, not a claim those native failures passed.
- REL-605 | OUTCOME=VERIFIED | EVIDENCE=Phone score buttons have minHeight170 plus padding; links/restore/help at least44pt; native controlSize.large actions. Current-iOS27 native audits and full Watch target-size tests pass; no new undersized target observed on physical phone.
- REL-606 | OUTCOME=VERIFIED | EVIDENCE=Scores, numeric counters, next-server names, demo/finish labels, disabled buttons and text errors remain explicit; team colour is supplementary. Physical Golden point and draw/end states read correctly without inferring colour.

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

## Exact M17 completion evidence

Unchanged full `make milestone ID=M17` on `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77` completed with raw FAILED,
Make2/verifier1/UI65: Watch510/884 passed, phone unit14/20 passed, phone UI4/6
passed and only the two explicitly accepted native Contrast failures remain. Zero
skips/expected/runtime warnings. AI/evidence/M17/milestone-verification.md binds
counts, reports, preserved earlier attempts and the narrow review-prompt harness
correction. This supersedes preliminary pending-verification wording above without
rewriting historical evidence. All six typed domains remain assessed by Builder,
not independent review. Signed archive/export and Apple validation passed; actual
new build upload/selection/TestFlight/joint submission remain subsequent steps.
Neutral14-locale ASO,42 saved records and168 placements were read back, with all
canonical galleries visually reviewed. AI/launch-20261024/companion-aso-final.md
records keywords, real-function boundaries and preview limits. No promotion clock.
