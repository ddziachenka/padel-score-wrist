# M25 digital domain revalidation — release

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-release.md
**Candidate:** f097a52d6a1154cf431156c30a81013a34d3cd47
**Audited at:** 2026-10-31

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is an
interim digital record, not a COMPLETE final release-domain record consumed by M26.
PENDING_DIGITAL means the named current-source run/readback is still required;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Final candidate/commands/counts will be bound in the M25 handoff and verification
record; capture-source inputs are recorded in the material manifest.

**Coverage result:** DIGITAL_IN_PROGRESS
**Open P0/P1:** None currently identified in reviewed source. C1/C2 are corrected; f097 minimum/current Watch and complete current-phone20 pass. Both new gallery4 bundles, strict provenance/site checks and all42 visual reviews pass. The exact full milestone gate remains mandatory before DONE.

## Coverage

- REL-208 | OUTCOME=PENDING_DIGITAL | EVIDENCE=ReviewAndLinksTests later-day, both demos, idle/not purchasing, annual limit; real system prompt remains M29.
- REL-209 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PhoneLinks exact review URL and no-prompt behavior; actual device external navigation remains M29.
- REL-301 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No app-owned health/location/camera/microphone/contacts/notification permission is requested. StoreKit authorization is covered separately.
- REL-302 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission denial flow exists.
- REL-303 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No corresponding sensitive-permission revocation flow exists.
- REL-304 | OUTCOME=INAPPLICABLE | EVIDENCE=reason=No sensitive device permission requested; system Double Tap and native input do not add an app-owned collection scope.
- REL-401 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Genuine Xcode StoreKitTest verified purchase/update flow and shared Watch entitlement logic; fresh physical Sandbox acquisition remains M29.
- REL-402 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKitPurchaseTests cancellation, pending→approval, unverified and network-error paths; real Apple authorization remains M29.
- REL-403 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Fresh EntitlementStore instance restores verified Xcode transaction; physical fresh-install restore remains M29.
- REL-404 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Signed transaction refund/revocation removes new-game unlock while preserving current game/history; lifetime has no subscription expiry.
- REL-405 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKitPurchaseTests testPriceFollowsUSAndGermanStorefronts compares actual Product.displayPrice and USD/EUR; no application-formatted price.
- REL-406 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Watch offline legal pages and phone Terms/Privacy links; close/back remains available and current game/history stay free.
- REL-407 | OUTCOME=PENDING_DIGITAL | EVIDENCE=DESIGN comparison: no subscription/trial/dark-pattern savings, no paywall on phone cold launch, price comes from Apple.
- REL-408 | OUTCOME=PENDING_DIGITAL | EVIDENCE=StoreKit zero→paid-price-return test preserves acquired rights; local neutral promo contains no temporary-offer clock or invented comparison.
- REL-501 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Both privacy manifests reviewed against actual source; Watch has no release UserDefaults, phone declares own-app UserDefaults CA92.1; no analytics/custom HTTP or motion collection.
- REL-502 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Current authenticated ASC App Privacy UI says Data Not Collected and policy URL matches; asc-privacy-readback.md records direct readback, not an inference from source.
- REL-503 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Read-only live52/52 localised URL checks HTTP200; published local-only policy and prepared expanded names/journals/gesture paragraph reviewed separately.
- REL-504 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Source inspection: StoreKit diagnostic prints/debug override guarded by DEBUG; no release logger or player-name logging. Native runtimeWarnings recorded separately from SDK build notes.
- REL-505 | OUTCOME=PENDING_DIGITAL | EVIDENCE=LocalDataSettings/SessionRepository atomic erase tests preserve usage and signed entitlement; no server-side copy exists. Physical destructive checks require identified test install in M29.
- REL-506 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PhoneLinks all routes and Watch Bootstrap readable offline legal/contact/EULA; actual device external page opening remains M29.
- REL-801 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Source/catalog/site draft and all native story captions contain finished copy; debug launch fixtures remain DEBUG-only.
- REL-1004 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Live support routes return HTTP200 in52URL readback; prepared13locale support additions are local drafts, not falsely claimed published.
- REL-1005 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Current GET-only ASC category relationships: SPORTS/UTILITIES; age declaration NONE/false and no UGC/ads/chat. Build behavior agrees.
- REL-1007 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Review Notes field local draft3381characters: ordinary five small Americano rounds reproduce gate; no account/debug shortcut; real Watch video pendingM29.
- REL-1008 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Live and local13locale terms retain Apple Standard EULA link and governance; no new legal or pricing policy introduced.
- REL-1101 | OUTCOME=PENDING_DIGITAL | EVIDENCE=DEBUG fixture/premium guards and mandatory package checks; no production test path or credential added.
- REL-1102 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Marketing1.0/local build3 consistently across targets; exact installed bundle/About expectations updated2→3, not loosened.
- REL-1103 | OUTCOME=PENDING_DIGITAL | EVIDENCE=No known unresolved product P0/P1 after scoped fixes; current ASC privacy evidence now agrees; the exact full gate is still pending.
- REL-1105 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Frozen explicit schemas1–4 migrate to5, validate before write, preserve backup/future files and local names/journal/usage. Physical previous-data recovery remains M29.
- REL-1303 | OUTCOME=PENDING_DIGITAL | EVIDENCE=SessionFile/GestureScoring migration tests freeze1–4 shapes and preserve independent current/archive rosters, journal, score, usage; gestures OFF.
- REL-1307 | OUTCOME=PENDING_DIGITAL | EVIDENCE=GesturePractice and CompanionDemo/Recovery models are memory-only with no real store/usage/entitlement/review dependencies; tab/cold-launch reset.
- REL-1308 | OUTCOME=PENDING_M29 | EVIDENCE=PENDING_M29: at least95% each-team success, zero wrong-team/accidental points in one-hour actual supported-Watch play, exact attempts and real video.

## Findings and fixes

GET-only ASC readback confirms SPORTS/UTILITIES and harmless age declaration; current App Privacy nutrition label UI readback confirms Data Not Collected after owner sign-in. No write/upload/reply/submission/site publication or price action. All real hardware proof remains M29.

Full failure/reproduction history: [work log](../evidence/M25/work-log.md).
Final-targeted native centered checks: [runtime](../evidence/M25/runtime.md).
All applicable physical scenarios: [M29 inventory](../evidence/M25/M29-hardware-inventory.md).
Internal-channel REL-1201–1203 do not apply to the configured app-store channel;
no internal installation is inferred from Simulator.

## Deferred P2 / future product ideas

P2 current StoreKit probe:19/21 definitions and28/30 invocations passed; two synthetic error/storefront assertions identically fail at the baseline. Raw failures and exact scope are in ../evidence/M25/storekit-current-runtime.md; no test, required gate or product error is excused. No cloud sync, tournament standings or real phone scoring is introduced.
No final readiness or actual hardware result is claimed.

## Targeted re-audit

Frozen f097 fresh minimum-phone4/4, minimum-Watch492/492 definitions/942
invocations, current-Watch498/498/948 and complete current-phone20/20 pass,
exit0, all zero failed/skipped/expected/native runtime-warning counts. This
includes26 language/theme pairs each for gesture/reset, maximum-text Help and
both recovery journeys, actual eight-surface theme pixels and centered EN/DE/RU.
The strict accepted native summaries/leaf counts are in runtime.md and
native-supplements.json. Both gallery4 bundles, strict material/site checks and all42 final visual contact
reviews pass. The unchanged full milestone gate remains required. The additional baseline-matched current StoreKit
probe stays FAILED/P2; storekit-current-runtime.md records the exact boundaries.
Physical evidence remains PENDING_M29.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
