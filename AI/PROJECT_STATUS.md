# Project status

**Phase:** implementation
**Current milestone:** M16
**Completed milestones:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13, M14, M15
**Next milestone:** M16
**Blockers:** none
**Important decisions:** Contracts approved; watchOS 10 min; Padel Score — Wrist; Watch-only; approved 2026-10-23: English + 11 languages (12 added locales), localization before M10; bundle com.dziachenka.padelscore(.watchkitapp). H2 unchanged. H4: 5 completed games free, count kept on deletion, then one $4.99 USD lifetime unlock; no trial wording. ASC app 6825393194 / IAP 6825393394, 175 regions; nothing submitted. H1 approved; site live. Plan 2026-10-22 (AI/purchase-appeal-plan.md): history free for all, fixed Match demo, M11–M15 before M10.

Localization preparation and coordinator editorial/visual audit complete under the owner exception in WORKFLOW: 11 added languages / 12 added locales, 48 added site pages, store drafts and 72 new raw screenshots. Exact candidate `8dd50d72b04689da93bfaed2599eb28bd26e3591` passed full integration (exit 0; 510/510 definitions, 884 invocations, no failed/skipped/expected); report `AI/localization/evidence/integration-final.md`, handoff `AI/localization/HANDOFF.md`. Owner has now confirmed all physical-device checks; M10 is DONE against the multilingual build. At the M10 checkpoint the prepared multilingual site was published with owner approval; ASC archive/upload/submission had not yet been performed (see the later preparation record below).

M10 DONE: exact candidate `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f` passed `make milestone ID=M10` and `make release CANDIDATE=93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`, both exit 0, each 510/510 definitions / 884 invocations with zero failures or skips. Release verdict READY_FOR_HUMAN; three post-readiness human checklist rows PENDING (subjective candidate review, Archive/Organizer, distribution decision). No further milestone. Commands, UTC timestamps, counts and reports: `AI/handoffs/M10-handoff.md`, `AI/evidence/M10/milestone-verification.md`, `AI/evidence/M10/release-verification.md`. Owner hardware confirmation and approved production site publication are separately preserved.

## App Store preparation — 2026-10-24

Owner explicitly authorized version 1.0 submission with lifetime IAP, AFTER_APPROVAL, and a zero-price launch offer covering launch day plus seven full days. Source inputs remain identical to verified candidate `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`. Build 1 was archived, signed, server-validated, uploaded, processed VALID and selected. All 14 localizations and 112 image placements are saved and read back; lifetime price is zero in all 175 regions, original price points backed up. Hourly automation `padel-score-lifetime` is active and silent for unchanged preparation state. No public release or promotion-end date yet. The same hourly monitor also checks only the exact Apple support case for new substantive replies, without sending follow-up messages automatically.

Draft `17c2964a-e72b-4558-983f-4a40c5545d9f` contains app 1.0 (1) and IAP version `d96baf47-39f7-4632-856e-b2cd28ec458f`. Both items are READY_FOR_REVIEW, but Submit for Review is disabled: Apple says Watch IAPs cannot be included. An attempted API submission tool call was rejected by automatic approval review before execution as a bypass of the observed restriction. **Nothing submitted; not Waiting for Review.** This newly observed distribution blocker supersedes earlier preparation assumptions without rewriting historical M10 verification.

Handoff: [ASC launch](handoffs/ASC-launch-20261024.md). The owner authorized the [Apple support inquiry](launch-20261024/apple-support-draft.md), now sent and confirmed as case **103007020727**; await Apple and preserve Watch-only. All assets, API backups, scripts and archive are in `.artifacts/asc-launch-20261024/`; retain that directory for the active promotion monitor. No app/configuration change or new milestone was made.

## M16 authorization — 2026-10-24

Owner approved compact iPhone companion (iOS17+) with Start, Match and Americano demos, and existing lifetime purchase, while Watch remains independent (watchOS10+). Purchase before Watch installation is allowed with an explicit explanation. All existing locales and launch-day-plus-seven-full-days zero-price offer remain required. M16 is REVIEW on main; historical M10 evidence describes its old source only. New build requires separate release revalidation before App Review. Owner will connect the physical pair for purchase/restore verification. Contract: [M16](milestones/M16-iphone-companion.md).

## M16 implementation checkpoint

Compact companion, shared demo engines, existing lifetime flow and all locale drafts are implemented. Home Screen label is PadelScore. The invisible secondary-copy defect was repaired and owner-confirmed; accessibility sizes now use full-width score cards. Signed1.0(2) archive packaging/signature passed. Four real iPhone images per ASC locale (56 total) are committed with source SHA/hashes; old84 Watch and28 creative files remain intact. Approved generic tooling self-test passed99 cases/2161 checks; primary static/site/material checks passed. Current iOS27 smoke4/4 and watchOS27 supplement13 definitions/24 invocations passed. These development checks are not the exact M16 milestone gate. Full minimum/current suite details, unresolved native audit and hardware limits: [verification progress](evidence/M16/verification-progress.md). Complete M16 and separate Release Readiness Revalidation before selecting/submitting a new ASC build.

Current M16 handoff: [M16](handoffs/M16-handoff.md). Full iPhone unit/StoreKit suite
passed14 definitions/20 invocations; full UI suite failed2/6 native largest-text
contrast audits (4 passed,0 skips). Minimum/current Watch supplements each passed
13 definitions/24 invocations. Required clean-REVIEW milestone verification is not
a passing result and full primary Watch coverage remains required before DONE.

## M16 owner acceptance — 2026-10-24

Owner explicitly accepts existing physical-pair observations and the two SE/iOS17
native contrast audit failures based on the passed current-iOS27 checks. No new
Sandbox testers or reinstall scenarios are required. See
[evidence](evidence/M16/owner-acceptance-20261024.md). Mac is accessible again. The
raw failures remain preserved; all other mandatory checks still apply. M16 enters
clean-REVIEW verification; do not equate owner acceptance with an automated pass or
release readiness. Historical blocker paragraphs above describe their checkpoints.
