# M17 final domain audit — ui-ux

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-ui-ux.md
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

- REL-102 | OUTCOME=VERIFIED | EVIDENCE=Physical iPhone Start opens without paywall/onboarding, explanatory copy visible; Access optional. M16 CompanionUITests testAccessIsOptionalAndCanBeOpenedWithoutWatchInstallation passes. Watch empty History/NewGame flows covered by complete Watch suite.
- REL-105 | OUTCOME=VERIFIED | EVIDENCE=Managed iOS17 SE3 launches in mandatory M16 UI run and watchOS10 SE40 supplement launches. No measured physical oldest-device time is invented; existing current-pair coverage accepted by owner.
- REL-203 | OUTCOME=VERIFIED | EVIDENCE=Start has immediate demo action; offline/unavailable Access provides Retry/Restore; Watch empty history provides navigation. Phone demos contain no persisted history or empty database.
- REL-204 | OUTCOME=VERIFIED | EVIDENCE=Physical restore displayed progress and leave-screen guidance; normal Apple authorization was cancelled and returned to usable Access. StoreKit unavailable/network tests preserve verified offline access and enable retry; no hanging app task was observed.
- REL-205 | OUTCOME=VERIFIED | EVIDENCE=Physical cancellation displayed Purchase cancelled. Nothing has changed. and retained verified ownership. Shared PurchaseMessages and StoreKit network/unverified/pending tests explain recovery without granting unsupported rights.
- REL-206 | OUTCOME=VERIFIED | EVIDENCE=Physical Undo reopened finished Match with exact score/service; demos reset only memory. Real Watch correction/delete confirmation and transactional deletion coverage passed in M16 complete suite. No owner data was deleted in this audit.
- REL-407 | OUTCOME=VERIFIED | EVIDENCE=No forced onboarding/paywall, fake countdown, recurring plan, preselected subscription, deceptive close or purchase gate. Physical Start/demo are reachable while owned and functional UI test checks access before Watch install.
- REL-602 | OUTCOME=VERIFIED | EVIDENCE=Full-width accessibility score cards, wrapping headings/actions and scrolling preserve content. Spanish truncation fixed in M16. Current-iOS27 native largest-text and Spanish audits passed; SE3/iOS17 reports only the two accepted Contrast failed findings, not clipped text. Actual failures remain retained.
- REL-603 | OUTCOME=VERIFIED | EVIDENCE=Phone has no custom animated transitions or information carried by motion; native controls honor system settings. Watch accessibility/Reduce Motion coverage preserved in M16 complete suite. Additional physical motion/haptics checks are explicitly accepted omissions.
- REL-604 | OUTCOME=VERIFIED | EVIDENCE=Both appearances inspected through native dark screenshots and current physical light UI; semantic text asset alpha1.000 and AA regression checked. Two native SE3/iOS17 Contrast failed reports remain unresolved and explicitly owner-accepted; current-iOS27 audits pass. This row records completed assessment with exception, not a claim those native failures passed.
- REL-605 | OUTCOME=VERIFIED | EVIDENCE=Phone score buttons have minHeight170 plus padding; links/restore/help at least44pt; native controlSize.large actions. Current-iOS27 native audits and full Watch target-size tests pass; no new undersized target observed on physical phone.
- REL-606 | OUTCOME=VERIFIED | EVIDENCE=Scores, numeric counters, next-server names, demo/finish labels, disabled buttons and text errors remain explicit; team colour is supplementary. Physical Golden point and draw/end states read correctly without inferring colour.
- REL-701 | OUTCOME=VERIFIED | EVIDENCE=Dark native M16 gallery and preview images re-inspected for Start/Match/Americano/Access, source input parity. Seven final contact sheets cover all14 ASC locales. Native controls/text remain readable; accepted contrast uncertainty separately recorded.
- REL-702 | OUTCOME=VERIFIED | EVIDENCE=Current physical iPhone light appearance inspected Start, Match/Golden/end/Undo, Americano/server/draw and Access/cancellation. Text visible with compact content-driven card spacing. Watch retains approved dark design; no Watch light UI invented.
- REL-703 | OUTCOME=VERIFIED | EVIDENCE=Managed SE3/iOS17 full UI suite exercises compact viewport; accessibility layout wraps/scrolls. No clipped-text failure beyond accepted contrast audits. Watch SE40 full UI suite510/884 passes. No separate iPad or landscape requirement.
- REL-704 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=iPhone-only companion, TARGETED_DEVICE_FAMILY1; no separate iPad UI per approved M16 contract.
- REL-705 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Portrait-only iPhone orientation in built configuration; Watch has no landscape interface.
- REL-706 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Initial unshipped1.0 has no public prior appearance; M16 source/gallery/physical observations are the current comparison.
- REL-804 | OUTCOME=VERIFIED | EVIDENCE=Spanish NOSOTROS largest-text case uses full-width wrapping cards; full M16 UI gallery checks all locales. German/Finnish/Russian and both Portuguese contact sheets re-inspected; old contrast finding retained with bounded exception.
- REL-805 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No RTL language ships in the approved language set.

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
