# M25 digital domain revalidation — functional

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-functional.md
**Candidate:** 4f1689944480aadfad592629e3c8394a9582c6b7
**Audited at:** 2026-10-30

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is an
interim digital record, not a COMPLETE final release-domain record consumed by M26.
PENDING_DIGITAL means the named current-source run/readback is still required;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Final candidate/commands/counts will be bound in the M25 handoff and verification
record; capture-source inputs are recorded in the material manifest.

**Coverage result:** DIGITAL_IN_PROGRESS
**Open P0/P1:** See findings; no unresolved product defect currently known.

## Coverage

- REL-101 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Fresh managed Watch gallery device plus pending fresh iOS17 phone profile; Bootstrap/NewGame and optional Access first-launch journeys.
- REL-102 | OUTCOME=PENDING_DIGITAL | EVIDENCE=NewGameUITests, HistoryUITests and CompanionUITests optional first launch; no forced paywall or onboarding.
- REL-103 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No previously shipped public version; app1.0 is rejected. Development schema migration is covered separately.
- REL-104 | OUTCOME=PENDING_DIGITAL | EVIDENCE=SessionFileTests/SessionRepositoryTests frozen schemas1–4, realistic history/long journals, damaged/future state and atomic backup/recovery.
- REL-105 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Minimum watchOS10/current27 and minimum iOS17/current27 managed launches; physical oldest-device timing remains M29.
- REL-106 | OUTCOME=PENDING_DIGITAL | EVIDENCE=FinishResume/NewGame/Journal/PlayerNames/GestureScoring UI relaunch/background cases and disposable phone tab reset.
- REL-201 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Full Watch journey suites and all phone interactive guide/demo cases; screenshots are actual app surfaces, not isolated mockups.
- REL-202 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PRODUCT/ARCHITECTURE review: independent Watch scoring, five completed games, one lifetime purchase, unrestricted Match sets and no phone real-game repository.
- REL-203 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Empty local History/new setup, demo actions and initial Access without a product remain usable.
- REL-204 | OUTCOME=PENDING_DIGITAL | EVIDENCE=EntitlementStore/AccessOffer/StoreKitPurchaseTests bounded unavailable/retry/pending handling; save failure retains retry/cancel.
- REL-205 | OUTCOME=PENDING_DIGITAL | EVIDENCE=NewGame/Journal/KnownScore/PlayerNames failure cases and shared PurchaseMessages preserve data/rights and explain retry.
- REL-206 | OUTCOME=PENDING_DIGITAL | EVIDENCE=History delete confirmation, manual replacement checkpoint, whole-correction Undo and known-score start cancellation.
- REL-207 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Simulator background/termination/revision tests; actual device lock/wrist behavior is PENDING_M29.
- REL-301 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No app-owned health/location/camera/microphone/contacts/notification permission is requested. StoreKit authorization is covered separately.
- REL-302 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission denial flow exists.
- REL-303 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission revocation flow exists.
- REL-401 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Genuine Xcode StoreKitTest verified purchase/update flow and shared Watch entitlement logic; fresh physical Sandbox acquisition remains M29.
- REL-402 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKitPurchaseTests cancellation, pending→approval, unverified and network-error paths; real Apple authorization remains M29.
- REL-403 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Fresh EntitlementStore instance restores verified Xcode transaction; physical fresh-install restore remains M29.
- REL-404 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Signed transaction refund/revocation removes new-game unlock while preserving current game/history; lifetime has no subscription expiry.
- REL-505 | OUTCOME=PENDING_DIGITAL | EVIDENCE=LocalDataSettings/SessionRepository atomic erase tests preserve usage and signed entitlement; no server-side copy exists. Physical destructive checks require identified test install in M29.
- REL-901 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Real scoring/recovery/history and disposable demos are local; failed product load retains verified access. No server/phone connection required for Watch scoring.
- REL-902 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKit simulated network errors/retry and transactional save failure tests; physical lossy-network purchase checks remain M29.
- REL-903 | OUTCOME=PENDING_DIGITAL | EVIDENCE=No custom server; StoreKit product/request/update errors use shared comprehensible unavailable/offline/retry messages.
- REL-904 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKit network-failure/update tests preserve signed entitlement and recover on retry; actual device disconnect transaction remains M29.
- REL-1105 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Frozen explicit schemas1–4 migrate to5, validate before write, preserve backup/future files and local names/journal/usage. Physical previous-data recovery remains M29.
- REL-1301 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GestureScoring/NewGame/PlayAgain tests: all new games OFF, active ON persists outside score Undo, restart has no pending preview.
- REL-1302 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GestureInput/LiveScore tests fixed3s, one/two/third, touch/navigation/inactive/revision cancellation, atomic ordinary rally and deadline race; physical recognition M29.
- REL-1303 | OUTCOME=PENDING_DIGITAL | EVIDENCE=SessionFile/GestureScoring migration tests freeze1–4 shapes and preserve independent current/archive rosters, journal, score, usage; gestures OFF.
- REL-1304 | OUTCOME=PENDING_DIGITAL | EVIDENCE=RallyCorrection/Journal real-file and UI change/delete/insert preview/cancel/apply/retry/whole Undo, stable IDs/later winner order and explicit serving ambiguity.
- REL-1305 | OUTCOME=PENDING_DIGITAL | EVIDENCE=KnownScore validation/UI explicit service, unknown earlier rallies/checkpoint boundary, invalid/completed inputs cannot start, one normal counted GameID.
- REL-1306 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PlayerNames native UI/model/real-file tests and archived roster immutability; actual dictation/Scribble/VoiceOver belongs to M29.
- REL-1307 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GesturePractice and CompanionDemo/Recovery models are memory-only with no real store/usage/entitlement/review dependencies; tab/cold-launch reset.

- REL-1308 | OUTCOME=PENDING_M29 | EVIDENCE=Actual supported-Watch recognition requires at least95% each-team success, zero wrong-team/accidental points in one-hour play and real video. Simulator activation is not physical proof.

## Findings and fixes

No new scoring/persistence defect found in source review. New capture-fixture underscores were rejected by the existing safe-name guard; fixed only the caller. Two exact installed build expectations were found stale after build3 increment and corrected to exactly3 after frozen captures finished. Minimum-watchOS largest-text setup navigation exposed the helper's short drag budget; the unchanged visibility predicate now passes its targeted reproduction, with full fresh minimum/current suites still required.

Full failure/reproduction history: [work log](../evidence/M25/work-log.md).
Final-targeted native centered checks: [runtime](../evidence/M25/runtime.md).
All applicable physical scenarios: [M29 inventory](../evidence/M25/M29-hardware-inventory.md).
Internal-channel REL-1201–1203 do not apply to the configured app-store channel;
no internal installation is inferred from Simulator.

## Deferred P2 / future product ideas

None added. No cloud sync, tournament standings or real phone scoring is introduced.
No final readiness or actual hardware result is claimed.

## Targeted re-audit

Final affected/runtime/material re-audit follows completion of current runs.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
