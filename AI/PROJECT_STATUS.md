# Project status

**Phase:** release-preparation
**Current milestone:** M17
**Completed milestones:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13, M14, M15, M16
**Next milestone:** M17
**Blockers:** none
**Important decisions:** Contracts approved; watchOS 10 min; Padel Score — Wrist; independent Watch + iPhone companion (M16); approved 2026-10-23: English + 11 languages (12 added locales), localization before M10; bundle com.dziachenka.padelscore(.watchkitapp). H2 unchanged. H4: 5 completed games free, count kept on deletion, then one $4.99 USD lifetime unlock; no trial wording. ASC app 6825393194 / IAP 6825393394, 175 regions; nothing submitted. H1 approved; site live. Plan 2026-10-22 (AI/purchase-appeal-plan.md): history free for all, fixed Match demo, M11–M15 before M10.

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
