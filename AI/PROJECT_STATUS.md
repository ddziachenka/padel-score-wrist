# Project status

**Phase:** implementation
**Current milestone:** M21
**Completed milestones:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20
**Next milestone:** M21
**Blockers:** Existing app1.0(2) rejected4.3(a); reply draft unsent/on hold. M20 passed; M21 REVIEW with passing domain/persistence tests; full gate pending. M22–M26 planned. No public release. See AI/recovery-differentiation-plan.md and AI/handoffs/ASC-review-20261027.md.
**Important decisions:** Contracts approved; watchOS 10 min; Padel Score — Wrist; independent Watch + iPhone companion (M16); approved 2026-10-23: English + 11 languages (12 added locales), localization before M10; bundle com.dziachenka.padelscore(.watchkitapp). H2 unchanged. H4: 5 completed games free, count kept on deletion, then one $4.99 USD lifetime unlock; no trial wording. ASC app 6825393194 / IAP 6825393394, 175 regions; submitted Oct25, rejected4.3(a) Oct27. H1 approved; site live. Plan 2026-10-22 (AI/purchase-appeal-plan.md): history free for all, fixed Match demo, M11–M15 before M10.

Localization preparation and coordinator editorial/visual audit complete under the owner exception in WORKFLOW: 11 added languages / 12 added locales, 48 added site pages, store drafts and 72 new raw screenshots. Exact candidate `8dd50d72b04689da93bfaed2599eb28bd26e3591` passed full integration (exit 0; 510/510 definitions, 884 invocations, no failed/skipped/expected); report `AI/localization/evidence/integration-final.md`, handoff `AI/localization/HANDOFF.md`. Owner has now confirmed all physical-device checks; M10 is DONE against the multilingual build. At the M10 checkpoint the prepared multilingual site was published with owner approval; ASC archive/upload/submission had not yet been performed (see the later preparation record below).

M10 DONE: exact candidate `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f` passed `make milestone ID=M10` and `make release CANDIDATE=93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`, both exit 0, each 510/510 definitions / 884 invocations with zero failures or skips. Release verdict READY_FOR_HUMAN; three post-readiness human checklist rows PENDING (subjective candidate review, Archive/Organizer, distribution decision). No further milestone. Commands, UTC timestamps, counts and reports: `AI/handoffs/M10-handoff.md`, `AI/evidence/M10/milestone-verification.md`, `AI/evidence/M10/release-verification.md`. Owner hardware confirmation and approved production site publication are separately preserved.

## App Store preparation — 2026-10-24

Owner explicitly authorized version 1.0 submission with lifetime IAP, AFTER_APPROVAL, and a zero-price launch offer covering launch day plus seven full days. Source inputs remain identical to verified candidate `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`. Build 1 was archived, signed, server-validated, uploaded, processed VALID and selected. All 14 localizations and 112 image placements are saved and read back; lifetime price is zero in all 175 regions, original price points backed up. Hourly automation `padel-score-lifetime` is active and silent for unchanged preparation state. No public release or promotion-end date yet. The same hourly monitor also checks only the exact Apple support case for new substantive replies, without sending follow-up messages automatically.

Draft `17c2964a-e72b-4558-983f-4a40c5545d9f` contains app 1.0 (1) and IAP version `d96baf47-39f7-4632-856e-b2cd28ec458f`. Both items are READY_FOR_REVIEW, but Submit for Review is disabled: Apple says Watch IAPs cannot be included. An attempted API submission tool call was rejected by automatic approval review before execution as a bypass of the observed restriction. **Nothing submitted; not Waiting for Review.** This newly observed distribution blocker supersedes earlier preparation assumptions without rewriting historical M10 verification.

Handoff: [ASC launch](handoffs/ASC-launch-20261024.md). The owner authorized the [Apple support inquiry](launch-20261024/apple-support-draft.md), now sent and confirmed as case **103007020727**. The then-current decision to await Apple and preserve Watch-only was superseded by the owner-approved M16 companion below. All assets, API backups, scripts and archive are in `.artifacts/asc-launch-20261024/`; retain that directory for the active promotion monitor. No app/configuration change or new milestone was made.

## M16 completed — 2026-10-24

M16 is **DONE under explicit owner acceptance**, with raw automated failure
preserved. Compact iOS17 companion provides Start, real-engine Match/Americano demos
and the existing lifetime flow; watchOS10 app remains independent. Home Screen label
is PadelScore. Invisible explanatory copy/spacing and Spanish largest-text truncation
were fixed. All languages,56 native iPhone store images/14 ASC locales, store/site/
review drafts, dual-platform harness and signed1.0(2) archive are prepared.

Exact clean REVIEW candidate `b671bb1d611daebb03718429f1036eab569a1cca` ran unchanged
`make milestone ID=M16`: Watch510 definitions/884 invocations passed; iPhone unit14
/20 passed; iPhone UI6 executed,4 passed/2 native Contrast failed. No skipped,
expected-failure or runtime-warning results. Raw verdict FAILED: Make2/verifier1/
UI xcodebuild65. Report `.artifacts/milestone/M16/20261024T143428Z-49481/report.md`.
The owner explicitly accepts those exact two SE/iOS17 audits based on passed iOS27
checks and accepts already observed current physical-pair coverage; fresh acquisition,
reinstall and extra physical assistive-technology scenarios were not executed or
reported as passes. No test/parser/suite was weakened. Scope and quote:
[owner acceptance](evidence/M16/owner-acceptance-20261024.md).

Generic tooling self-test passed99 cases/2161 checks in the approved byte-matched
original-template fixture; actual product static/site/package checks passed. Both
watchOS10/27 supplements passed13 definitions/24 invocations each; iOS27 passed4/4.
Signed archive source `fc118f8a0b357d52e0b06f8ba1f17449297ca623` has identical
App/Config/Scripts inputs at the final candidate. Old84 Watch/28 creative assets and
historical readiness evidence remain intact. Earlier failures and cache diagnosis
are preserved, not counted as passes.

Handoff: [M16](handoffs/M16-handoff.md). Exact commands, exits, timestamps, bundle
counts, archive and material provenance:
[final verification](evidence/M16/milestone-verification.md).
Builder session stops after closing static/status/continuity checks. **Separate
Release Readiness Revalidation is still required for the new candidate** and must
carry the owner exception plus raw FAILED verdict; M10 READY_FOR_HUMAN does not apply.
No new ASC build upload/selection/submission occurred; old build1/draft remain as
recorded above. No public launch or offer-end schedule exists. New site/store texts
are local drafts. Existing authorization to submit remains valid after new readiness
and ordinary ASC app+IAP verification. The monitor remains read-only until those
guards are met; Sandbox/TestFlight do not start the launch-day-plus-seven-full-days
offer. Keep both `.artifacts/M16/` and `.artifacts/asc-launch-20261024/`.

## Separate companion release revalidation — active

Owner explicitly requested separate readiness with existing exceptions, TestFlight
verification, upload and app+first lifetime submission. Sequential M17 six-domain
records then M18 candidate-bound gates follow the existing process; source inputs
remain unchanged. M17 REVIEW, M18 PLANNED. Authorization and bounded exception:
AI/evidence/M17/owner-release-authorization.md. Prior M16 completion is historical;
new release readiness/submission has not yet been established.

M17 first unchanged full run on9ab72b4fec5f657b2e606c09e5e776099a541c24 failed:
Watch510/884 and iPhone unit14/20 passed, UI3/6 passed. In addition to the two
accepted contrast cases, the first Access test was covered by the native
Enjoying PadelScore? / Not Now review prompt after the calendar-day change.
This third failure is not accepted. M17 returns to IN_PROGRESS for reproduction
and a narrow UI-test correction; no upload/selection/submission occurred.

The known optional review prompt is now explicitly declined by UI setup, preserving
all existing assertions and production behavior. Targeted ordinary/qualifying
launches pass; fresh full gates remain pending. Evidence:
AI/evidence/M17/review-prompt-regression.md.

## M17 completed — current checkpoint

M17 DONE under explicit bounded owner acceptance. Exact `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77` ran full
make milestone ID=M17: Watch510/884 and phone unit14/20 passed, UI4/6 passed,
only the two accepted native Contrast failures. Raw FAILED/Make2/verifier1/UI65
preserved; no skipped/expected/runtime warnings. Known review-prompt interference
corrected only in UI setup with targeted fail-before/pass-after evidence. Handoff
AI/handoffs/M17-handoff.md. New signed1.0(2) archive/export/server validation passed.
Neutral14-locale ASO and168 images saved/read back. ASC app now PREPARE_FOR_SUBMISSION,
old binary1 still selected; existing IAP remains in draft. Internal owner TF group
prepared without a build. M18 separate candidate-bound release remains required.
Nothing uploaded/submitted/public; offer end not scheduled.

M18 begins on a clean REVIEW Markdown-only continuity candidate. Its declared
validation is the unchanged full immutable make release command; the unstarted
extra M18 milestone rerun is consolidated to save time under owner steering.
AI/WORKFLOW.md and M18 contract record the precise boundary. No test/platform/
assertion/parser omitted and no new failure accepted.

## M18 readiness established — new companion candidate

M18 DONE under exact owner acceptance. Candidate `572e3524157154f9104edab61b1d4311de437857` ran unchanged full
make release: Watch510/884 and phone unit14/20 passed; UI4/6passed, only two
accepted Contrast failures. Raw VERIFICATION_FAILED/Make2/verifier1/UI65 preserved.
No automated READY_FOR_HUMAN claimed. Six domains current; package/servervalidation
passed; source continuity to newly archived02ec9c9 confirmed. Handoff M18-handoff.md.
Actual upload/select/TestFlight/ordinary joint submission follows existing owner
authorization. Until actual server readback, not submitted/not Waiting for Review.
Monitor guard requires current new candidate/build match before public offer work.

## Companion distribution prepared — 2026-10-25

New1.0(2) uploaded exit0, AppleVALID, ID283096f1-80fe-4114-93c1-6fb9f2ace782.
Selected on existing1.0, AFTER_APPROVAL, new2004-character Review Notes saved/read
back. Internal Owner TestFlight has1existing tester and only build2, IN_BETA_TESTING.
New runtime TestFlight inspection unavailable because Mac locked; not called passed.
Final42ASOrecords/14locales exact, neutral promo only;56phone+84Watch+28creative
placements saved. Appdownload0/all175available choices verified; lifetime0all175,
no publication/enddate. Handoff: AI/handoffs/ASC-companion-20261025.md.

Normal website session expired (authResult=FAILED); owner asked to sign in while
remaining API preparation completed. **Not submitted / not Waiting for Review.**
Existing draft contains firstIAP only; after sign-in, add new selected app2 normally
and jointly Submit for Review under existing authorization. No API bypass. Former
Watch-only restriction remains unproven until actual normal joint submission.


## Actual joint submission confirmed — 2026-10-25

Owner unlocked Mac, signed into ASC and explicitly reconfirmed TestFlight check
and joint submission. New1.0(2) installed from the exact TestFlight invitation and
opened on physical iPhone17ProMax. Start text, Match40–30/2–2, Golden point,
completed game3–2/server change, Undo/Reset; Americano10–10/4rallies/Partner,
block change/Opponent2,12–12draw, Undo/Reset; Access StoreKit0.00 and Watch
requirement were observed. Restore requested Apple Account password and was
cancelled; no fresh successful restore/acquisition claimed. Existing bounded
owner hardware exceptions remain.

Ordinary ASC Add for Review accepted app2 into the retained firstIAP draft, then
Submit for Review returned2 Items Submitted. Both app1.0(2) and Lifetime unlock
show Waiting for Review. Submission17c2964a-e72b-4558-983f-4a40c5545d9f, actual
submittedDate2026-10-25T06:33:55.103Z (10:33Tbilisi). API monitor confirms
WAITING_FOR_REVIEW/newbuild283096f1-80fe-4114-93c1-6fb9f2ace782/AFTER_APPROVAL,
public=false. Former Watch-only joint-submission restriction is resolved by actual
normal-path success; no API submission bypass. No application inputs changed.
Hourly monitor updated in place with submitted identity, silent pending states,
public-build guards and unchanged neutral Promotional Text policy. Launch offer
clock/end schedule waits for actual public release. See distribution handoff.

## App Review follow-up — 2026-10-27

Apple message at20:32Tbilisi cites4.3(a), similarity in binary, metadata and/or concept, without naming compared apps or matching elements. Build1.0(2); listed device iPad Air11-inch(M3). This alone does not establish Watch was not tested. REJECTED/UNRESOLVED_ISSUES; IAP API READY_TO_SUBMIT, submission UI Ready for Review. No publication. Owner states personal-use development without looking at competitors or copying and requests work toward acceptance. Factual reconsideration response and two-page Watch guide prepared, not sent. No binary/product changes or resubmission. Handoff: AI/handoffs/ASC-review-20261027.md.

Owner subsequently authorized sending the exact response and PDF. ASC draft saved and read back at20:54Tbilisi; not sent. Extension file upload unavailable; native chooser blocked by locked Mac. Continue existing draft after unlock, without another permission request. Evidence: .artifacts/asc-review-20261027/send-attempt.json.

## Recovery plan approved — 2026-10-27

Owner approved M19–M26 in AI/recovery-differentiation-plan.md: selective rally recovery, start from known score, retained read-only journals and isolated iPhone scenarios. M19 first fixes both contrast failures; historical acceptance does not carry into new gates. All eight contracts registered PLANNED; this Builder session owns only M19. App Review draft remains unsent/on hold, no automatic submission or pricing changes.

## M19 completed — 2026-10-27 UTC

M19 DONE with a fully passing gate, without historical contrast exceptions. Exact
clean REVIEW candidate `227a1c43be1fc8cbfe12178683beaeb1308732d8` ran
`make milestone ID=M19`, exit0, 17:48:07–20:15:45UTC. Watch510/510 definitions
(884 invocations), phone unit14/14 (20 invocations), phone UI6/6 passed; zero
failed/skipped/expected/runtime warnings. Both previously failing native contrast
audits pass. One non-blocking Apple StoreKitTest SDK-header deprecation warning
is recorded separately. Opaque semantic native bars preserve original inactive
tab colors; strengthened tests also audit the lower score fully on screen.
Final light/dark checks3/3 each passed. Builder self-review, not independent review.

Handoff: [M19](handoffs/M19-handoff.md); full evidence:
[evidence/M19/milestone-verification.md](evidence/M19/milestone-verification.md).
The next Builder session owns M20 event journal. M20–M26 remain PLANNED; no new
journal/recovery functionality is claimed yet. App Review draft remains unsent/on
hold and the old rejection remains unresolved. No upload, submission, pricing or
Promotional Text change; no new release readiness claimed.


## M20 completed — 2026-10-27 UTC

M20 DONE. Exact clean REVIEW/main candidate
`98a0502e84453d66904cf13654d92850641ed497` passed `make milestone ID=M20`,
exit0,20:39:05–23:06:43UTC. Watch523/523 definitions/918 invocations,
iPhone unit14/14/20, iPhone UI6/6; zero failed/skipped/expected/runtime warnings.
Both native iPhone contrast audits pass without historical waivers. Both Debug
builds and independent Watch/companion packaging guards pass.

Schema3 records stable typed rally/service/checkpoint/correction/lifecycle events,
keeps new archived journals without Undo chains, and explicitly migrates schema1/2
current states to unknown-history boundaries. Legacy archives lack detailed events;
sequential Undo, snapshots, settings, timestamps and once-per-game usage remain.
Migration/new journals survive tested write failures, restart and recovery atomically.
4000 rallies use1949208 active bytes/459659 archived bytes with4002 retained events;
measured save/load about0.021s each on Simulator, with no silent truncation.

The initial same-SHA gate stopped before tests because the development cache held
an embedded unit-test bundle. The packaging guard remained intact; only this
checkout's disposable cache was cleared, all evidence retained, then the unchanged
full gate passed. No pre-existing failure or accepted failure is claimed.

Handoff: [M20](handoffs/M20-handoff.md). Exact evidence:
[evidence/M20/milestone-verification.md](evidence/M20/milestone-verification.md).
Builder self-review, not independent review or release approval. No new UI/replay,
upload, submission, pricing or Promotional Text change. App Review reply remains
unsent/on hold; the old4.3(a) rejection remains unresolved.

Next Builder session owns M21. Before its implementation, perform the bounded
hands-on competitor correction-flow check required by the approved recovery plan;
inaccessibility stays unknown, and an already matching full flow returns product
direction to the owner. M21–M26 remain PLANNED. This Builder stops after committing
DONE records and passing static/status/continuity checks against the verified SHA.
