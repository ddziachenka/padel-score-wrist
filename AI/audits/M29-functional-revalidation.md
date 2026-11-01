# M29 domain revalidation — functional (DRAFT)

**Domain prompt:** AI/prompts/audit-functional.md
**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit — DRAFT for Builder finalization
**Milestone:** M29
**Candidate:** 1367217b30ce0c5ffa2c464ea977786e28139439
**Audited at:** 2026-11-01
**Distribution channel:** app-store
**Record status:** DRAFT — final candidate/full gate/counts and post-DONE continuity pending

This is delegated preparation of the owning Builder's record. The Builder must
reconcile pending evidence and finalize it; this is not independent full domain
validation or release approval. Typed coverage classifications are provisional
within this DRAFT and do not make outstanding final checks pass.

## Candidate context

Historical M25 digital baseline: `5eb65bbc17e9540d3922a520b44d3c8731947432`. Exact commands,
accepted same-SHA component counts and runtime matrices remain in
[M25 verification](../evidence/M25/milestone-verification.md),
[M25 runtime](../evidence/M25/runtime.md), and this domain's M25 record.
The original monolithic M25 command remains FAILED/130; its M25-only owner
exception does not extend to M29.

Baseline-to-candidate source comparison bounds shipping changes to gesture timing,
teaching/cue/catalog strings, setup-practice routing and build identity. Scoring,
persistence/migration/recovery, native-name ownership, StoreKit/entitlement,
permissions/privacy, rating eligibility and phone demo models are unchanged.
M25 evidence for those areas is carried with that source-continuity boundary,
not represented as a complete M29 rerun.

Fresh affected evidence: e9053e7afce11877225fd58e826fcbeebd866bcf current Watch
UI10/10 and minimum31 definitions/72 invocations; ff87edd550f376b618d44ebb7904ef29f769b686
current/minimum Watch32 definitions/73 invocations each and phone UI1/1. These
runs exit0 with zero failed/skipped/expected/runtime-warning counts. Exact commands,
times, bundles and limits are in [five-second evidence](../evidence/M29/five-second-prototype.md).
Build6 preserves e905's reducer; the later gallery correction changes tests only.
Complete frozen captures at1367217b30ce0c5ffa2c464ea977786e28139439 now pass:
Watch m29-watch-gallery-2 exits0,14/14 definitions/invocations; phone-current
m29-phone-gallery-2 exits0,2/2 definitions/invocations, all adverse counts0.
Raw native bundles/summaries/source/context are under .artifacts/M25/ with those
run names. The unchanged import/compose/prepare-site/strict-validator/contact/
site-check pipeline exits0:112 Watch+98 phone native originals,28 creatives,
14 locales. Commands/logs: [material refresh](../evidence/M29/material-refresh.md),
.artifacts/M29/refresh-materials.sh, material-validate.log and site-check-final.log.

All14 [Watch sheets](../evidence/M29/watch-gallery-visual-review.md) are visually
reviewed, no P0/P1.112 imported Watch PNGs match the reviewed raw hashes, source,
attachment/bundle, dimensions and order. Watch selected frames do not establish
complete teaching/cue visibility or physical recognition. Final
[phone review](../evidence/M29/phone-gallery-visual-review.md) passes all14 sheets
and binds98 native hashes. Final [creative review](../evidence/M29/creative-visual-review.md)
passes28 PNGs/14 sheets, including original dense-language spot checks and native/
artwork/hash binding. All42 final contact-sheet groups pass with no P0/P1.

Browser identity command `python3 .artifacts/M29/prove-site-identity.py` exits0:
[site-layout-identity.json](../evidence/M29/site-layout-identity.json) proves53
HTML/CSS files unchanged from browser source445859bde0740737ccd580ca0fb95dba429fb534,
which has208/208 actual52page×2width×2appearance layout checks. Dark is explicitly
an isolated CSS preview, not OS preference emulation. The [browser matrix](../evidence/M29/site-browser-matrix.json),
[preview identity](../evidence/M29/site-preview-identity.json) and
[palette checks](../evidence/M29/site-palette-contrast.json) record12 contrast pairs,
minimum5.778084694407478. Root reviewed5 final browser screenshots in
[site-final-captures.json](../evidence/M29/site-final-captures.json):375px Light EN
and1280px isolated-Dark RU, with RU recovery exactly1280×581 (not900high).
Current native-image raster provenance is established separately by imported
hashes/strict validator and those final visual checks. Browser viewport/tab,
desktop lease and two preview servers have been cleaned up by root.

`make static` on the material-preparation tree exits0; log
.artifacts/M29/static-materials-final.log. This is actual preflight static evidence,
not a claimed full exact-candidate gate. Only final committed candidate/full gate/
counts and post-DONE static/status/continuity remain pending in this DRAFT.
REL-1302 requirement prose was corrected from3 to5 seconds after both frozen
captures; row/schema/guards and shipping App bytes are unchanged.

The owner explicitly accepts all manual M29 physical coverage, including the
remaining VoiceOver/names/storage/recovery/Sandbox purchase/Restore/revoke scope
with reply “все засчитываем”. The canonical
[owner-physical-acceptance.md](../evidence/M29/owner-physical-acceptance.md) has
been reviewed: it records the exact two owner instructions, remaining-scope
question and reply, closes every manual inventory row by decision, and preserves
all unrecorded measurement/media/build-readback limits. The matching WORKFLOW,
gesture-plan and M29 amendments restrict this exception to manual M29 scope.
This is a human acceptance decision, not a fresh laboratory/device observation.
No measured percentage, attempt count, play duration/zero-event count, continuous
video artifact or independent current-Watch6 readback is invented. No automatic
gate is waived and no App Review submission is authorized.

Separate scoped [code review](../evidence/M29/independent-scoped-code-review.md)
and [copy review](../evidence/M29/material-copy-review.md) found no blocking
source/copy issue within their limits; neither claims full M29 validation.

**Coverage result:** DRAFT
**Open P0/P1:** 0

## Coverage

- REL-101 | OUTCOME=VERIFIED | EVIDENCE=M25 fresh-install/Bootstrap/NewGame evidence plus M29 agent-observed signed phone and paired Watch installation; remaining manual first-launch scope accepted by owner decision.
- REL-102 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: NewGameUITests, HistoryUITests and CompanionUITests optional first launch; no forced paywall or onboarding. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-103 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No previously shipped public version exists; the owner confirms this app has not been released. Development schema migration/recovery are covered separately.
- REL-104 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: SessionFileTests/SessionRepositoryTests frozen schemas1–4, realistic history/long journals, damaged/future state and atomic backup/recovery. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-105 | OUTCOME=VERIFIED | EVIDENCE=M25 minimum/current runtime launch evidence and M29 ff87 current/minimum build6 About/setup passes; physical oldest-device/performance coverage accepted by owner decision, without a fabricated timing measurement.
- REL-106 | OUTCOME=VERIFIED | EVIDENCE=M25 relaunch/background/reset journeys; M29 e905 current five-second UI cancellation/relaunch passes; remaining physical lifecycle coverage accepted by owner decision.
- REL-201 | OUTCOME=VERIFIED | EVIDENCE=M25 full Watch journeys/phone demos; M29 agent-observed phone Match/Americano/correction/known-score journeys, fresh affected e905/ff87 gesture/setup checks, and owner acceptance of remaining manual journeys. Full current automatic gate remains pending below.
- REL-202 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: PRODUCT/ARCHITECTURE review: independent Watch scoring, five completed games, one lifetime purchase, unrestricted Match sets and no phone real-game repository. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-203 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: Empty local History/new setup, demo actions and initial Access without a product remain usable. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-204 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: EntitlementStore/AccessOffer/StoreKitPurchaseTests bounded unavailable/retry/pending handling; save failure retains retry/cancel. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-205 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-206 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-207 | OUTCOME=VERIFIED | EVIDENCE=M25 background/termination/revision tests; e905 current Watch cancellation/background passes; physical wrist-down/lock/interruption/recovery scope accepted by owner decision, not inferred from Simulator.
- REL-301 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No app-owned health/location/camera/microphone/contacts/notification permission is requested. StoreKit authorization is covered separately.
- REL-302 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission denial flow exists.
- REL-303 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission revocation flow exists.
- REL-401 | OUTCOME=VERIFIED | EVIDENCE=M25 genuine Xcode StoreKitTest verified purchase/update and unchanged shared entitlement logic; manual physical Sandbox acquisition/application scope accepted by owner decision. No newly captured transaction receipt is invented.
- REL-402 | OUTCOME=VERIFIED | EVIDENCE=M25 unchanged StoreKitPurchaseTests cancelled/pending/unverified/network-error paths; remaining manual cancelled/declined/pending/error scope accepted by owner decision. Additional current-runtime probe remains FAILED/P2, not a passing test.
- REL-403 | OUTCOME=VERIFIED | EVIDENCE=M25 verified transaction restore into a fresh EntitlementStore; M29 agent-observed existing-install phone Restore succeeds; remaining fresh-install physical Restore scope accepted by owner decision. These evidence sources remain distinct.
- REL-404 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: Signed transaction refund/revocation removes new-game unlock while preserving current game/history; lifetime has no subscription expiry. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-505 | OUTCOME=VERIFIED | EVIDENCE=M25 atomic erase tests preserve usage/signed entitlement and deletion source is unchanged; owner permits test-data disposal and accepts remaining physical deletion/recovery checks. No agent-observed erase is invented.
- REL-901 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: Real scoring/recovery/history and disposable demos are local; failed product load retains verified access. No server/phone connection required for Watch scoring. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-902 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: StoreKit simulated network errors/retry and transactional save failure tests; physical lossy-network purchase coverage is now accepted by owner decision in owner-physical-acceptance.md.
- REL-903 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: No custom server; StoreKit product/request/update errors use shared comprehensible unavailable/offline/retry messages. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-904 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: StoreKit network-failure/update tests preserve signed entitlement and recover on retry; physical disconnect-during-request coverage is now accepted by owner decision in owner-physical-acceptance.md.
- REL-1105 | OUTCOME=VERIFIED | EVIDENCE=M25 frozen schemas1–4 to5, realistic volume, backup/future-file handling and validation-before-write tests; unchanged persistence/recovery implementation. Remaining physical previous-data/recovery scope accepted by owner decision.
- REL-1301 | OUTCOME=VERIFIED | EVIDENCE=M25 OFF-default/active-option-outside-Undo/restart tests; e905 current preference/relaunch and ff87 current/minimum setup routes preserve OFF drafts/original results. Corresponding physical option/default coverage accepted by owner decision.
- REL-1302 | OUTCOME=VERIFIED | EVIDENCE=Approved five-second fixed window supersedes historical three-second wording: e905 current live late-second/touch/Undo/cancel/background/save-failure and ff87 current/minimum reducer/integration/practice checks pass. First activation fixes deadline; timer/game/revision guards remain intact. Manual gesture/lifecycle scope accepted by owner decision.
- REL-1303 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: SessionFile/GestureScoring migration tests freeze1–4 shapes and preserve independent current/archive rosters, journal, score, usage; gestures OFF. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-1304 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: RallyCorrection/Journal real-file and UI change/delete/insert preview/cancel/apply/retry/whole Undo, stable IDs/later winner order and explicit serving ambiguity. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-1305 | OUTCOME=VERIFIED | EVIDENCE=M25 source-continuous digital evidence: KnownScore validation/UI explicit service, unknown earlier rallies/checkpoint boundary, invalid/completed inputs cannot start, one normal counted GameID. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-1306 | OUTCOME=VERIFIED | EVIDENCE=M25 native names UI/model/real-file and immutable archived-roster tests; names/persistence source unchanged. Owner explicitly accepts remaining native entry/dictation/Scribble/VoiceOver/interruption scope, without an invented trial transcript.
- REL-1307 | OUTCOME=VERIFIED | EVIDENCE=M25 memory-only practice/simulation isolation; ff87 current/minimum Watch and phone UI1/1 verify explained US-to-THEM settlement/cancel/reset/leave without real-game/opt-in side effects. Scoped source review confirms no store/entitlement/usage/review dependency. Applicable remaining manual physical coverage is accepted by owner decision in owner-physical-acceptance.md.
- REL-1308 | OUTCOME=VERIFIED | EVIDENCE=M29-only owner acceptance covers native gesture trials, real-play behavior and all remaining manual physical scope; see owner-physical-acceptance.md. Earlier owner reports two contacts award US and stable THEM after Pending: US then a second series. No exact denominators/percentages, measured hour/zero-event counts, continuous-video file or independently read Watch6 identity is claimed. Simulator activation is not physical recognition proof.

## Findings

| ID | Severity | Disposition |
| --- | --- | --- |
| M29 navigation | Corrected | Reproduced result-origin route failure; flow-path correction and current/minimum regressions pass. |
| M29 gallery timing | Corrected | Approved five-second timing exposed obsolete3.3s gallery wait;5.3s wait plus stronger pending/Undo assertions pass focused verification. Both complete captures and final42-sheet visual review pass. |
| Final evidence | Note | Canonical manual acceptance/material/browser/static evidence is recorded; final exact-candidate full gate and post-DONE continuity remain pending. No COMPLETE/DONE verdict is asserted. |

## Fixes

Setup practice uses the owning flow path in both stack contexts. Approved input
uses a fixed five-second window. Build6 teaches first Pending: US preview before
another two-contact series. Cancellation, atomic-save, one/two/third meanings,
pricing, permissions and data architecture remain intact. See
[navigation evidence](../evidence/M29/setup-practice-regression.md) and
[gallery correction](../evidence/M29/gallery-timing-correction.md).

## Deferred P2

The separate current-iOS StoreKit probe remains FAILED/P2: baseline-matched
synthetic network-error classification and Storefront.current override mismatch;
Product.displayPrice/currency otherwise pass. See
[unaltered evidence](../evidence/M25/storekit-current-runtime.md). No test/parser
is loosened and no failed probe is relabelled. It is not a required-gate waiver.

Copy-review C1/P2: “Wait five seconds to save” could state the first-series anchor
more explicitly. Source/tests fix that deadline and the new cue explains the
first preview; defer further wording during the source freeze. No new blocking
wrong-team/deadline implementation finding is inferred.

## FUTURE_PRODUCT_IDEA

None added. No alternative gesture, workout keep-awake bypass, real phone scoring,
cloud sync or tournament feature is introduced.

## Targeted re-audit

Affected source review covers first-series fixed deadline, single consumption,
stale timer/game/revision guards, inactive/navigation cancellation, both stack
contexts and isolated practice state. Fresh e905/ff87 native tests cover late
second-series input, new cue, OFF draft and original-result preservation.
The corrected gallery first requires a pending preview and unavailable Undo,
then after5.3s a committed undoable point. Raw failures remain preserved.

Complete captures/source-bound import/28-image composition/strict material and
site checks now pass. All112 imported Watch PNGs match the reviewed raw hashes;
Watch and phone visual reviews each pass14 locales; creative review passes28
images/14 sheets. Browser208/208 plus final5image review/identity/12contrast pairs
and preparation make static all pass in their actual scopes. Only final candidate,
full automatic gate/counts and post-DONE continuity remain pending. Old captures
are not relabelled build6; no hash-only provenance refresh is accepted.

## Validation

| Field | Evidence |
| --- | --- |
| Inspected preparation SHA | `1367217b30ce0c5ffa2c464ea977786e28139439` |
| Fresh affected native evidence | e905/ff87 commands/exits/counts/native bundles in five-second-prototype.md; focused gallery1/1 in gallery-timing-correction.md |
| Canonical owner acceptance | Reviewed [exact M29-only decision](../evidence/M29/owner-physical-acceptance.md); OWNER_ACCEPTED_BY_DECISION for all manual rows; no fabricated measurements/media or automatic waiver |
| Source-bound native captures/import | PASS: Watchgallery2 exit0,14/14; phonegallery2 exit0,2/2;112+98 imported originals at1367217; all adverse0; strict validator exit0 |
| Watch visual/import continuity | PASS:14 sheets reviewed;112 PNG hashes/source/attachment/bundle/order equal reviewed raw originals; watch-gallery-visual-review.md |
| Phone native visual review | PASS:14 sheets/98 native hashes; [phone-gallery-visual-review.md](../evidence/M29/phone-gallery-visual-review.md), source1367217 |
| Material/site strict checks | PASS: unchanged pipeline exit0; .artifacts/M29/material-validate.log and site-check-final.log |
| Creative visual/byte identity | PASS:28 PNGs/14 sheets; [creative-visual-review.md](../evidence/M29/creative-visual-review.md), source1367217 and manifest hash binding |
| Browser layout/palette/identity | PASS: prove-site-identity.py exit0;53 HTML/CSS identity/208browser checks/12 contrast pairs min5.778; site-layout-identity.json plus browser/preview/palette JSON |
| Final browser raster spot review | PASS:5 exact-dimension/hash-bound captures; site-final-captures.json, EN375 Light/RU1280 isolated-Dark, RU recovery1280×581 |
| Preparation static | `make static` exit0; .artifacts/M29/static-materials-final.log; preparation tree, not the full gate candidate verdict |
| Current Review Notes | [Build6 local draft](../evidence/M29/review-notes-draft.md), not sent; first-series five-second anchor and access steps match current scope |
| Final candidate SHA | PENDING clean committed REVIEW/main candidate after frozen galleries |
| Exact full command | `make milestone ID=M29` — NOT RUN for this draft |
| Full gate exit code | PENDING |
| Full gate report | PENDING `.artifacts/milestone/M29/<run>/report.md` |
| Full gate counts | PENDING actual definitions/invocations/failures/skips/build/package counts |
| Post-DONE static/status/continuity | PENDING exact commands/exits on continuity commit; no M25 exception inherited |

Before COMPLETE, the Builder must reconcile affected row evidence and replace
pending fields with actual results; validate six typed records; run the unchanged
full gate on the exact clean candidate; record its SHA/exit/report/counts; and
preserve raw failures/P2 dispositions. Only continuity Markdown follows verified
source, then required static/status/continuity checks. No upload, publication,
external message or App Review submission is authorized by this record.
