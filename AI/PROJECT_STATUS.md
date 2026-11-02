# Project status

**Phase:** implementation
**Current milestone:** M31
**Completed milestones:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23, M24, M27, M28, M25, M29
**Next milestone:** M31
**Blockers:** M31 REVIEW: corrected gesture UI preconditions pass5/5 at0340e58c70af66a96e3e743ebcbf2c93c6bf26a8; complete fresh gate pending. Prior full640-definition Watch run FAILED1 remains preserved. Build7 icon runtime and all materials complete. M26/M30 pending; nothing uploaded/sent/submitted.
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


## M21 completed — 2026-10-28 UTC

M21 DONE. Exact clean REVIEW/main candidate `9b10f99b6b96a45fc91bff736b68ff9d4df243ac`
passed `make milestone ID=M21`, exit0,06:07:52–08:34:50UTC. Watch536/536
 definitions/940 invocations, phone unit14/14/20, phone UI6/6; zero
failed/skipped/expected/runtime warnings. Both native contrast audits pass.
Both Debug/package guards pass. Handoff: [M21](handoffs/M21-handoff.md);
[exact evidence](evidence/M21/milestone-verification.md).

Selective change/remove/insert previews preserve later winners and stable IDs after
the last checkpoint; changed set serving is explicit, unresolved results unknown.
Apply is revision-bound/atomic; one Undo restores the whole original record and
archive timestamp; usage never double-counts. Flat patches retain original audit
events without copied journals or truncation.4000-rally preview/apply about0.0166s
on Simulator;1945791encoded bytes. No new user-facing UI inM21.

The first full candidate's Watch536/940 passed, but the overall gate failed on
missing iPhone source registration. Both missing memberships were fixed and a
strict source-graph omission regression added; all required suites then reran and
passed at the exact new SHA above. Failed report retained, never counted as a pass.
Competitor correction-flow equivalence remains unknown under the approved
inaccessibility rule; exact listing version/access evidence is recorded.

Builder self-review, not independent review or release approval. App Review reply
remains unsent/on hold,4.3(a) unresolved; no upload/submission/pricing/Promotional
Text change. Next Builder session owns M22; M22–M26 remain PLANNED. This session
stops after DONE static/status/continuity checks against the verified SHA.


## M22 completed — current checkpoint

M22 DONE. Clean REVIEW/main candidate `b52ea03978bc63664f2b43289fb950bf5d44c611` passed
`make milestone ID=M22`, exit 0, UTC `20261028T112312Z`–`20261028T140420Z`.
Watch: 551/551 definitions, 955 invocations; iPhone unit: 14/14, 20; iPhone UI: 6/6, 6.
Aggregate: 571 definitions / 981 invocations;
zero failed/skipped/expected/runtime warnings. Both Debug/package guards and both
native iPhone contrast audits pass. Handoff: [M22](handoffs/M22-handoff.md);
[exact evidence](evidence/M22/milestone-verification.md).

Watch Journal changes/deletes/inserts an earlier recorded rally with complete
Before/After score, service and finish review; ambiguities require explicit
serving. Cancel/save failure/stale preview preserve the original; one Undo
restores the full correction. Latest result remains editable with Undo, archived
journals are read-only, legacy detail is unavailable, and manual editing explains
its checkpoint. All 39 new strings ship in 13 locales. Largest text, native audits,
4000-rally scrolling and complete minimum-watchOS 10 set pass 15/15. Self-review
found and reproduced background draft loss, fixed it with a narrow navigation
condition, and added a fail-before/pass-after regression. Partial serving choices
and full previews now survive background; cold launch keeps only saved state.
The first full candidate's cancelled FAILED report is retained and superseded by
this complete passing candidate, with no test or waiver carried around the failure.

Builder self-review, not independent review or release approval. App Review reply
remains unsent/on hold and 4.3(a) unresolved; no upload/submission/pricing/Promotional
Text change. Next Builder owns M23; M23–M26 remain PLANNED. This Builder stops after
committing DONE records and passing static/status/continuity against the verified SHA.


## M23 completed — current checkpoint

M23 DONE. Clean REVIEW/main candidate `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e` passed
`make milestone ID=M23`, exit 0, UTC `2026-10-28T16:28:52Z`–`2026-10-28T19:16:57Z`.
Watch 568/568 definitions/976 invocations; phone unit 14/14/20, UI 6/6/6.
Aggregate 588 definitions/1002 invocations; zero failed/skipped/expected/runtime
warnings. Both Debug/package guards and native iPhone contrast audits pass.
Handoff: [M23](handoffs/M23-handoff.md);
[exact evidence](evidence/M23/milestone-verification.md).

Match/Americano can start from a validated known score and explicit service,
confirmed before saving a normal game with an initial checkpoint. Earlier rallies
remain unknown; Undo cannot cross the start. Invalid/completed rounds cannot
start, cancellation writes nothing, and later corrections/finish/Undo count one
GameID once. Going back to change setup rules preserves entered score and
revalidates it. All seven strings ship in thirteen locales. Final-source minimum
watchOS 10 set passes17/17 definitions/21 invocations, including five UI cases,
native audits, largest text, background, cold launch and exact copy regressions.
The deliberately interrupted first full candidate remains raw FAILED evidence;
this fresh complete pass supersedes it without weakening any check or waiver.

Builder self-review, not independent review or release approval. App Review reply
remains unsent/on hold and 4.3(a) unresolved; no upload/submission/pricing/Promotional
Text change. Next Builder owns M24; M24–M26 remain PLANNED. This Builder stops after
DONE static/status/continuity checks against the verified SHA.


## M24 completed — current checkpoint

M24 DONE. Clean REVIEW/main `9831216685a4bbcf8e9c567cf1c11cebb7b57e85` passed `make milestone ID=M24`,
exit 0, UTC `2026-10-29T00:49:37Z`–`2026-10-29T04:28:38Z`.
Watch 568/568 definitions/976 invocations; phone unit 21/21/30, UI 13/13/13;
aggregate 602 definitions/1019 invocations, zero failed/skipped/expected/runtime
warnings. Both Debug/package guards pass. Large-phone supplement 7/7 and full
phone-unit supplement 21/21/30 pass on the same frozen source.
Handoff: [M24](handoffs/M24-handoff.md);
[exact evidence](evidence/M24/milestone-verification.md).

Two real interactive guides teach historical rally correction and known-score
Match/Americano play through input, preview, confirmation, cancel/Undo and result.
Disposable sessions cannot reach real storage, settings, usage, entitlements or
review eligibility; original demos stay intact. All thirteen locales run in actual
Light/Dark and largest Dynamic Type on small/large phones. Self-review corrected
navigation/field identity, native text measurement, visible input labels and action
surfaces; prior failures remain raw failures, without a waiver or skipped check.

Builder self-review, not independent audit or release approval. App Review 4.3(a)
and the unsent/on-hold reply remain unchanged; no upload/submission/pricing/
Promotional Text/public-release action. A new Builder owns M25 — Recovery Experience
and Review Materials; M25–M26 remain planned. This session stops after DONE
static/status/continuity against the verified SHA.


## M27 approved — 2026-10-29

Owner approved optional Partner/Opponent 1/Opponent 2 names on Apple Watch before
and during games, remembered latest roster, immutable archived rosters, native input,
local-only storage and schema 4 migration. M27 depends on M24 and precedes M25/M26.
This Builder owns only M27. No submission or release action is authorized here.

Owner validation direction, 2026-10-29: “давай все проверки на физических часах
сделаем перед подготовкой к релизу”. M25 owns all physical-Watch checks before
M26, including M27 native name input/VoiceOver/lifecycle. M27 requires its full
automated gate and Simulator runtime coverage. Physical connection attempts failed
with CoreDevice Bluetooth L2CAP/tunnel errors and executed no tests; no hardware
pass or release waiver is claimed.


## M27 completed — current checkpoint

M27 DONE. Clean REVIEW/main candidate `488809d6c06b29233e7c1d1f7687c9cec03bbab4`
passed `make milestone ID=M27`, exit0, UTC2026-10-29T09:23:11Z–13:30:22Z.
Watch591/591 definitions/1013 invocations; phone unit21/21/30; UI13/13/13;
aggregate625/1056, zero failed/skipped/expected/runtime warnings. Both Debug
builds and independent package guards pass. Final-source minimum watchOS10 and
current27 supplements each pass454/454/876, exit0. Final mutable make fast
passes454/454/876, exit0. Handoff: [M27](handoffs/M27-handoff.md);
[exact evidence](evidence/M27/milestone-verification.md).

Optional native Players editor in setup and active menus supports both formats,
remembered roster, game-local service/score/correction/journal/result/VoiceOver
names and independent archived rosters. Names are metadata outside snapshots;
rename is atomic/revision-bound, does not consume usage or Undo, and invalidates
old correction previews. Schema4 explicitly migrates1–3. Thirteen locales,
maximum text, native audits/input, real-file failure/retry/backup/restart/delete
and cancel/background/clear/Undo/result/repeat pass. Final runtime captures were
inspected after fixing the maximum-text form hierarchy. Earlier failures remain
raw evidence; no test/assertion/category/parser was weakened. Builder self-review,
not independent audit or release approval.

Owner explicitly assigned every physical-Watch check to M25 before M26. Failed
Bluetooth tunnel attempts executed no tests; no physical pass or hardware waiver
is claimed. M25 now depends on M24 and M27 and is the next Builder session;
M25–M26 remain planned. Existing App Review4.3(a) and unsent/on-hold reply remain;
no upload/submission/pricing/Promotional Text/public-release action. This session
stops after DONE static/status/continuity against the exact verified SHA.


## Gesture plan approved — 2026-10-29

Owner explicitly requested implementation of AI/gesture-differentiation-plan.md.
M28 IN_PROGRESS; sequence M28→M25→M29→M26→M30. Per-new-game gestures OFF,
one/two Double Tap series US/THEM in3s, third cancels; existing Match result
without overall winner retained by owner decision. All physical checks move to M29,
including outstanding M27 coverage. M25 owns digital experience and three generated
artwork directions/all14locale galleries; M30 replaces old reply and handles
separately authorized resubmission. Owner clarified initial competitor research;
old no-research wording must not be sent. No new app behavior is verified yet.


M28 implementation/self-review complete; REVIEW candidate follows. Minimum
watchOS10 supplement469/469 definitions/907 invocations and current27
supplement471/471/909 passed, exit0, on frozen app source1c6860f. Mutable make fast
passed474/474 during development. Full unchanged make milestone ID=M28 remains
required before DONE; no release readiness or physical recognition pass claimed.

After final compact-label correction, source872ed0f passed both supplements again:
watchOS10 469/469/907, watchOS27 471/471/909, exits0. Final visuals inspected.
M28 REVIEW now runs the complete unchanged milestone gate on a clean main commit.
All required physical checks remain M29; no external distribution action.


## M28 completed under owner exception — 2026-10-30 UTC

M28 DONE. Exact clean REVIEW/main candidate
`e21875871773f9b47419d526a9cb22e2a4d66fb1` passed
`bash .artifacts/M28/verify-phone-complete.sh owner-verification-5`, exit0,
00:08:36.860730Z–01:33:12.794777Z. Complete fresh phone unit21/21 definitions/30
invocations and UI16/16/16; final current-iOS supplement2/2/2, exit0. Every accepted
component has zero failed/skipped/expected/native runtime warnings. Static, Debug
and packaging guards pass. Source-identical Watch619/1057 from3db is reused only
under the explicit owner-approved M28 exception, proved against574 protected paths.
The original full gate and all failed/partial attempts remain FAILED; no native
audit/filter/parser/assertion was weakened or failed iPhone result accepted.

Per-new-game OFF includes Match/Americano/known score/Play again; active-game opt-in
persists, lives outside score Undo and can change in the menu. Fixed3s one/two/third
series preview US/THEM/cancel; one atomic ordinary rally, immediate touch override
and visibility/lifecycle/revision cancellation. Schema5 migrates1–4 OFF. Watch
practice and explicit phone simulation are isolated; thirteen UI locales. Final
measured native guidance and stationary input follow actual Simulator self-review.

A fresh owned SE3/iOS17 Simulator and temporary own-idle-device isolation preceded
the final complete pass after native Code-56 timeouts. Old device/data retained;
all three temporarily stopped own devices restored Booted, exits0. No foreign
device, global service restart or erase. Some minimum-iOS Dark-labelled captures
render Light, including a separate system Settings observation; no exhaustive
minimum-Dark pixel claim is made from XCTest getters. Actual current Light/Dark
is inspected. The comprehensive digital follow-up belongs to M25 before M29/M26.

Handoff: [M28](handoffs/M28-handoff.md); [exact component evidence](evidence/M28/milestone-verification.md),
[runtime](evidence/M28/runtime.md), [owner exception](evidence/M28/owner-verification-exception.md).
Builder self-review, not independent audit or release approval. No upload/reply/
submission/pricing/site publication. All physical recognition/haptics/VoiceOver/
purchases/recovery and remaining M27 checks remain mandatory in M29. M26 retains
its full milestone and exact-SHA release gates; M30 is the separate resubmission task.
A new Builder owns M25 — Gesture Experience and Store Materials, including three
imagegen directions and all14 Store-localization galleries. Stop after DONE commit
static/status/continuity against the verified SHA.


## M25 completed under explicit owner exception — 2026-10-31 UTC

M25 is DONE under the explicit M25-only owner exception. Verified candidate
`5eb65bbc17e9540d3922a520b44d3c8731947432`: watch 635/635 definitions/1085 invocations; phone-unit 21/21 definitions/30 invocations; phone-ui 21/21 definitions/21 invocations.
Aggregate 677 definitions/1136 invocations, zero failed/skipped/
expected/native runtime warnings in the accepted components. Both Debug/package
guards pass. Complete new phone command `bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`, exit0,
UTC2026-10-31T14:27:08Z–2026-10-31T16:45:19Z; report `.artifacts/M25/phone-complete-same-candidate/report.md`.
The Watch component is from `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult` at exactly the same SHA.
The complete monolithic make remains FAILED/exit130, never relabelled passed.
See [owner authorization](evidence/M25/owner-verification-exception.md) and
[exact verification](evidence/M25/milestone-verification.md). All physical checks remain M29.

Centered recovery, native readable Start/Help, actual theme pixels,13 UI languages,
minimum/current runtimes, maximum text, explicit Reset and neutral next-server
copy pass.14ASC galleries contain210 unmodified native/28 creative assets;42
final visual reviews and strict material/site/identity checks pass. All drafts
remain local; App Privacy readback is Data Not Collected. Additional current
StoreKit probe remains raw FAILED/P2, exactly baseline-matched, not credited as
passing. Builder digital self-review is not independent review or release approval.
No upload/reply/submission/pricing/publication. New Builder owns M29 physical
validation; M26 retains complete final gates, M30 separate authorized resubmission.
Handoff: [M25](handoffs/M25-handoff.md). Stop after DONE static/status/continuity.

## M29 current acceptance checkpoint — 2026-11-01

All manual physical coverage is **OWNER_ACCEPTED_BY_DECISION**, following the
owner's explicit “все засчитываем” clarification. The canonical
[decision and full question/answer](evidence/M29/owner-physical-acceptance.md)
close gestures/play, VoiceOver, native names, recovery, Sandbox purchase/Restore/
revocation and all other manual inventory rows for M29. Missing measured
denominators, recognition percentages, elapsed hour/zero-event counts, real Watch
video and independent Watch6 About readback remain disclosed; they are not
renewed manual blockers or claims of measured passes. No repeat manual tests are
requested. [Reconciliation](evidence/M29/physical-coverage-reconciliation.md).

M29 remains **IN_PROGRESS, not DONE**. Final frozen material captures and domain
records are being prepared before committing the clean REVIEW/main candidate
and running the entire unchanged `make milestone ID=M29`. No full-gate SHA,
exit or counts exist yet. No M25 exception is inherited, and no release,
App Review reply/submission or distribution is authorized. Current
[handoff](handoffs/M29-handoff.md).

## Historical M29 physical checkpoint — superseded, 2026-11-01

The blocked status, pending mechanic choice and outstanding manual requests below
describe the earlier checkpoint. The approved five-second choice and current
owner acceptance above supersede them; original observations and failures remain.

M29 BLOCKED, not DONE. Owner confirms Watch and phone 1.0 (4); two native series
can select THEM but not reliably, with no numeric trial record. Owner asks about
another gesture. [Pending product choice](evidence/M29/gesture-input-decision.md):
five-second prototype (Recommended), alternative-gesture investigation, or retain
three seconds and measure. No production timing/motion change is approved yet.
One-hour play/video postponed by owner; remaining physical rows and final gate
remain mandatory before M26. [Handoff](handoffs/M29-handoff.md).

Fixed result-based setup→Try gestures at `0d535ac26a543d37333f3c457bbfba1316663d90`:
two new regressions fail before/pass after. Current27 supplement13/13 definitions/
39 invocations, exit0. Test-only follow-up `9659e7c3017faf8dc4530c46ad49cb97f3c0eec9`
fixes a baseline-reproduced clipped tap without loosening deadline/assertions;
complete minimum10 supplement15/15/41, exit0, UTC10:59:06.656–11:01:25.818.
Earlier failed bundles preserved. Exact [commands/SHA/reports/counts](evidence/M29/setup-practice-regression.md).
Phone settings restored to owner-approved originals; no outstanding restore approval.
Strict material source fingerprint correctly blocks static until final-source
complete captures are refreshed after the mechanic decision. No full M29 pass,
independent audit, release approval, upload/reply/submission/publication claimed.


## M29 final candidate preparation — 2026-11-01

All manual physical scope is OWNER_ACCEPTED_BY_DECISION, with missing metrics/
video/current-Watch readback disclosed. Watch14/14 and phone2/2 complete galleries
pass at1367217b30ce0c5ffa2c464ea977786e28139439, all adverse counts0. Strict import/
composition/site validators,42 final contact reviews,53-file/208-browser-layout
binding,12 palette pairs and fresh static pass. Build6 shipping bytes stay equal
to targeted-testedff87; REL-1302 prose matches approved5s. M29 now enters REVIEW
for the complete unchanged make milestone ID=M29 on a clean committed main.
No full-gate pass, DONE or release approval is claimed yet.


## M29 completed — current checkpoint

M29 DONE. Clean REVIEW/main candidate `a908212c242663c2079427cd3d40ef923d73bd40` passed
`make milestone ID=M29`, exit0, UTC2026-11-01T13:33:37Z–19:54:49Z.
Watch640/640 definitions/1092 invocations; phone unit21/21/30; UI21/21/21.
Aggregate682 definitions/1143 invocations; every invocation Passed, zero failures,
skips, expected failures or native runtime warnings. Both Debug/package guards pass.
No automated verification waiver/component reuse/filter/parser weakening applies.
[Handoff](handoffs/M29-handoff.md); [exact evidence](evidence/M29/milestone-verification.md).

All manual physical scope is OWNER_ACCEPTED_BY_DECISION with explicit disclosures
of unrecorded metrics/hour/video/Watch6 readback. Build6 fixes result-origin practice
and teaches the stable first-preview→second-series cadence in the approved5s window.
Fresh210 native/28 creative assets,104 site copies,42 visual contacts,208 browser
layout rows/12 palette checks and strict provenance/static checks pass. Six final
Builder domain records combine current evidence with bounded M25 digital evidence.
No independent full audit or release approval is claimed. App Review4.3(a) and
unsent reply remain; no upload/reply/submission/pricing/publication/distribution.
A new Builder owns M26; M30 remains separately authorized. Stop after DONE commit
static/status/continuity against the verified SHA.
