# M17 final domain audit — functional

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit
**Milestone:** M17
**Domain prompt:** AI/prompts/audit-functional.md
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

- REL-101 | OUTCOME=VERIFIED | EVIDENCE=M16 fresh managed companion installation reaches Start; Watch Bootstrap/NewGame clean test stores reach usable setup. Exact-input full M16 evidence510/884 Watch and14/20 phone plus UI6. Current physical app reopened directly to Start; no fresh physical reinstall is claimed.
- REL-102 | OUTCOME=VERIFIED | EVIDENCE=Physical iPhone Start opens without paywall/onboarding, explanatory copy visible; Access optional. M16 CompanionUITests testAccessIsOptionalAndCanBeOpenedWithoutWatchInstallation passes. Watch empty History/NewGame flows covered by complete Watch suite.
- REL-103 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=Initial unshipped1.0; no previously shipped app version exists. Development installations are not a prior public release.
- REL-104 | OUTCOME=VERIFIED | EVIDENCE=Watch SessionRepository migration/recovery/future-schema and500-result history tests in full M16 suite. M16 adds no Watch schema change or phone game database.
- REL-105 | OUTCOME=VERIFIED | EVIDENCE=Managed iOS17 SE3 launches in mandatory M16 UI run and watchOS10 SE40 supplement launches. No measured physical oldest-device time is invented; existing current-pair coverage accepted by owner.
- REL-106 | OUTCOME=VERIFIED | EVIDENCE=Physical Start→Demo→Access→Start remained responsive. M16 unit/UI relaunch tests preserve signed ownership and reset only demos; full Watch background/resume/launcher cases passed.
- REL-201 | OUTCOME=VERIFIED | EVIDENCE=DESIGN J1–J8 exercised by complete current Watch M16 suite. Physical phone Start→Match40/30→Golden point→game3–2→Undo40/40, Americano10–10→12–12 draw and Access were walked in this revalidation.
- REL-202 | OUTCOME=VERIFIED | EVIDENCE=Current PRODUCT M16 fixtures, independent Watch boundary, five free completed Watch games and one existing non-consumable match source/unit/UI and physical observations. Phone has no real-match repository or claimed Watch free-game remainder.
- REL-203 | OUTCOME=VERIFIED | EVIDENCE=Start has immediate demo action; offline/unavailable Access provides Retry/Restore; Watch empty history provides navigation. Phone demos contain no persisted history or empty database.
- REL-204 | OUTCOME=VERIFIED | EVIDENCE=Physical restore displayed progress and leave-screen guidance; normal Apple authorization was cancelled and returned to usable Access. StoreKit unavailable/network tests preserve verified offline access and enable retry; no hanging app task was observed.
- REL-205 | OUTCOME=VERIFIED | EVIDENCE=Physical cancellation displayed Purchase cancelled. Nothing has changed. and retained verified ownership. Shared PurchaseMessages and StoreKit network/unverified/pending tests explain recovery without granting unsupported rights.
- REL-206 | OUTCOME=VERIFIED | EVIDENCE=Physical Undo reopened finished Match with exact score/service; demos reset only memory. Real Watch correction/delete confirmation and transactional deletion coverage passed in M16 complete suite. No owner data was deleted in this audit.
- REL-207 | OUTCOME=VERIFIED | EVIDENCE=M16 complete Watch suite covers relaunch/resume/launcher and owner confirmed independent disconnected scoring. Phone UI relaunch resets demos and retains signed entitlement. Additional physical scenarios remain owner-accepted omissions, not passes.
- REL-301 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No health/location/camera/microphone/contacts/notification permission is requested; StoreKit authorization is assessed separately.
- REL-302 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No sensitive device permission is requested, so no corresponding denial flow exists.
- REL-303 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No sensitive device permission is requested, so no corresponding runtime revocation exists.
- REL-401 | OUTCOME=VERIFIED | EVIDENCE=M16 genuine StoreKitTest free/paid purchase and signed entitlement pass, plus owner-accepted current physical Sandbox observations. Physical Access currently shows verified lifetime. TestFlight was opened; this app is not available there before upload. No new physical acquisition is claimed.
- REL-402 | OUTCOME=VERIFIED | EVIDENCE=Full phone StoreKit tests cover cancelled/pending/approval/unverified; shared entitlement never grants pending/unverified rights. Physical AppStore.sync authorization was cancelled, Access recovered and owned status persisted. This is cancellation evidence, not a new restore success.
- REL-403 | OUTCOME=VERIFIED | EVIDENCE=M16 fresh entitlement-store restore/relaunch tests pass; owner explicitly confirmed restore on both devices previously. New physical reinstall/fresh Sandbox acquisition not executed and explicitly owner-accepted. Current restore attempt cancelled at Apple sign-in; not labelled successful.
- REL-404 | OUTCOME=VERIFIED | EVIDENCE=Shared signed transaction revocation/refund tests remove new-game unlock and retain existing game/history. Non-consumable has no expiry; test price return0→4.99 preserves acquired lifetime. Each device independently queries Apple transactions.
- REL-505 | OUTCOME=VERIFIED | EVIDENCE=Watch Settings local deletion retains purchase/free counter by explicit contract, atomically erases session/history/settings copies; deletion fault tests in full M16 suite. Phone deletion removes local review prefs only; no sync/backend/developer copy exists.
- REL-901 | OUTCOME=VERIFIED | EVIDENCE=Both phone demos are memory-only real engines; no network required. Watch verified entitlement supports offline scoring without phone per owner confirmation. StoreKit product failure does not remove locally signed rights; tests cover that exact path.
- REL-902 | OUTCOME=VERIFIED | EVIDENCE=Full phone StoreKit network failure test retains verified offline access and exposes restore; Watch delay/error tests passed. New lossy physical purchase scenario was not run, within owner-accepted physical scope.
- REL-903 | OUTCOME=VERIFIED | EVIDENCE=No custom server/API exists. StoreKit unavailable/product request/network paths are exercised by full unit tests and use shared comprehensible retry/offline states; not treated as an absent StoreKit capability.
- REL-904 | OUTCOME=VERIFIED | EVIDENCE=StoreKit network-failure-during-request and outstanding transaction update tests passed. Phone tabs can be left mid-operation; updates reconcile independently. Existing physical scope accepted without a new forced disconnect transaction.
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
