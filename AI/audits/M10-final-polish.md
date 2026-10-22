# Final Product Polish audit — M10

**Policy status:** current
**Candidate:** pending; baseline e009fdb9b9565f241bac3db724d7bd54d9e9c50b; first checkpoint f1f96d99aa62151b4ac0336685ce998f24167908
**Milestone:** M10
**Distribution channel:** app-store
**Coverage result:** INCOMPLETE
**Open P0/P1:** not yet established; audit in progress
**Record:** `AI/audits/M10-final-polish.md`

Use this one record for all six domains. For each `## Coverage: <domain>` section,
copy every row assigned to that domain and channel in
`Config/release-requirements.v3.tsv`, exactly once, using:

```text
- REL-NNN | OUTCOME=VERIFIED | EVIDENCE=<command, environment, or observation>
- REL-NNN | OUTCOME=INAPPLICABLE | EVIDENCE=reason=<approved product-specific reason>
```

`INAPPLICABLE` requires the schema to permit it. An unavailable required environment
blocks completion. Set coverage to `COMPLETE` and open P0/P1 to `0` only from evidence.
This is Builder self-review, not independent release approval.

## Scope and environment

- Baseline and inspected build: clean main at `e009fdb9b9565f241bac3db724d7bd54d9e9c50b`. App, Scripts and Config are identical to M08 verified candidate `1f9b96c78a1f09470d6b7e574d19a55f1c71f816` (`git diff` saved as the empty `.artifacts/M10-final-polish/source-continuity.patch`).
- Simulator/device, OS, appearance, accessibility settings, and storefronts: managed SE2 40mm / watchOS 26.1, UDID `A7CBB23C-F823-4850-BE4B-CAD76922DD08`. watchOS 10.0 (21R355) is installed. Physical Ultra 3 / watchOS 27.0.1 was offline at discovery, then available to CoreDevice; owner completed two groups of manual checks in this session. Existing ordinary Release app from M08 has identical production sources. Environment inventory: `.artifacts/M10-final-polish/{devices.txt,runtimes.txt,simulator-context.json}`.
- Primary journeys and product-specific risk areas: J1 creation/scoring, J2 full correction/Undo, J3 finish/result/resume, J4 purchase/restore/legal. One advantage second deuce, tie-break serving, shortened Americano service block, atomic storage/recovery, retained usage and verified entitlement.
- Checks not run and why: current runtime suite is in progress; minimum-OS runtime, final six-domain coverage, physical observations and both final gates remain pending. Initial sandboxed Xcode device discovery was denied host cache/service access; authorized host discovery succeeded. This is a tooling restriction, not an app defect.

## Functional Correctness / Bug Hunt

- IN_PROGRESS — first domain. Read audit-functional.md, product/architecture/design, predecessor contracts and handoffs. Source checks of session commands, storage publication/recovery, correction drafts and entitlement ownership found no reproduced blocking issue so far. This is not a completed domain verdict.
- Baseline `make fast` finished with make exit 2 / XCTest 65: 387 total, 386 passed, 1 failed, 0 skipped/expected failures. Failure: CorrectionUITests/testAmericanoTotalsBlockAndServingAreCorrected, expected transient Changes saved but second label query observed Americano. Activity timestamps show first query at 1792659518.967, second at .983, assertion at .992: the five-second loop exited immediately, then the assertion queried again across message expiry. This establishes a test observation race, not failed persistence. Fixed shared waitForLabel to assert its cached actual observation; no assertion/timeout/selector removed or relaxed. Full corrected run pending.
- Evidence: original `make fast` ran the complete unchanged shared scheme (FAST_TEST_ARGUMENTS empty). Console `.artifacts/M10-final-polish/fast.log`; report `.artifacts/fast/20261022T084728Z-80046/report.md`. Generic Debug build-for-testing into `/private/tmp/padel-m10-minimum-derived` succeeded, exit 0 (`minimum-build.log`, `minimum-build.exit`). That build alone does not prove watchOS 10 compatibility.
- Owner physical check requested in Russian: scoring and haptics, exact Undo, Crown does not score, wrist-down/wake and lock/unlock preserve score/server, focused Crown edit and discard. Owner answered “все сработало” for all five requested checks. This is manual owner-observed evidence, not an automated screenshot or test count. On-court context was not stated; explicitly requested again. Owner subsequently answered “все работает” for finish cancellation, finish/Saved/haptic, resume and Americano 4/2 draw/extra-point rejection/Undo. Owner asked to continue on simulator and will test hardware separately later. Court context remains unstated; spoken VoiceOver journeys are not performed. Structured observation: `.artifacts/M10-final-polish/physical-observations.json`.

## Coverage: functional

Pending: enter typed rows only after the assigned checks have evidence.

## UI / UX

- Reviewed all 94 named screenshots from the baseline SE2 40mm run (screenshots26/index.json and eight contact sheets). Setup, scoring, full correction, conflicts, result, recovery, large text and legal pages remain legible with native scrolling. Transient blurred numeric/server frames are mid-animation, not steady-state corruption.
- Found a real paywall close-control contrast defect: automatic sheet dismissal inherits pale accent with a white X. Measured screenshot colors (219,247,152) / (253,255,250), ratio 1.174:1 versus required 3:1. System accessibility audit passes before the fix, so it is insufficient evidence for this native chrome. Added explicit cancellation toolbar action using the existing neutral editor-close style; focused validation on 10.0/26.1 pending.
- Evidence: shared styles and LiveScoreView inspected; current UI tests execute the real app, including compact/large-text states. Screenshots will be reviewed after completion.

## Coverage: ui-ux

Pending: enter typed rows only after the assigned checks have evidence.

## Content / Copy

- Source assessment: English catalog and bundled legal text proofread; no placeholder or contradictory purchase claim found. Five completed games, one-time unlock, retained count and saved-game access are explicit. No comparison price/offer exists. Public pages return HTTP 200 and exactly match Web/public (site-readback.json). Initial Python HTTP request returned 403 and web reader could not open the site; system curl succeeded with normal TLS.
- Evidence: Localizable.xcstrings, AboutView/LegalPage, AccessView, Web/public read; runtime context remains in progress.

## Coverage: content

Pending: enter typed rows only after the assigned checks have evidence.

## Accessibility

- Source assessment: spoken score descriptions, ordered accessibility elements, adjustable number editors, textual ownership, native Dynamic Type and contrast checks inspected. Numeric motion is disabled with Reduce Motion; the permitted server opacity fade remains. Automated accessibility audits are running, but cannot prove spoken VoiceOver journeys.
- Evidence: DesignSystemTests, AccessibilityUITests, LargeTextUITests and LiveScoreUITests/testTheReadingOrderFollowsTheScreen. Required physical spoken VoiceOver remains pending by owner request.

## Coverage: accessibility

Pending: enter typed rows only after the assigned checks have evidence.

## Product Experience

- Source assessment: immediate format selection, no account/activation, visible free-game count, correction drafts, exact Undo and retained last result match PRODUCT. Native feedback is sufficient; no speculative redesign or new feature added.
- Evidence: owner manual groups 1/2 pass core scoring/finish/resume; full simulator journeys pending. Court usability is not established by an unspecified test location.

## Coverage: product

Pending: enter typed rows only after the assigned checks have evidence.

## Release / App Store / Privacy / Monetization

- Read-only ASC readback: 1.0 PREPARE_FOR_SUBMISSION, SPORTS/UTILITIES, 4+, all content-risk answers NONE/false, correct Privacy/Support URLs and concrete review access instructions. Files asc-{app-info,versions,age,categories,privacy-url,support-url,review}.json under this milestone artifact directory. No metadata edited.
- Source assessment: no developer backend, sensitive permissions, analytics/tracking or production logging; empty collection/required-reason manifest agrees with inspected sources. Debug overrides/test stores are conditionally compiled; current clean Release build passed (exit 0); release-inspection.json confirms 1.0 (1), minimum 10.0, Watch-only, no test bundle/StoreKit config/debug markers or sensitive purpose strings.
- Retained M08 physical purchase/restore/refund/pending/unverified and owner offline-reboot evidence is linked by byte-identical production sources. Prior USD/EUR displayPrice experiment is supplementary, not a new current gate.
- External release-path uncertainty: Apple’s Submit an in-app purchase documentation requires a first IAP with a version but also says to remove IAPs from Apple Watch submissions. Successful Sandbox purchases do not establish a supported submission path. No submission attempted; this is not a reproduced app defect.

## Coverage: release

Pending: enter typed rows only after the assigned checks have evidence.

## Findings

| ID | Domain | Severity | Reproduction and impact | Correction or disposition | Status |
| --- | --- | --- | --- | --- | --- |
| M10-A1 | UI / UX; Accessibility | P1 | Sixth game opens Access sheet; white automatic X on pale accent measures 1.174:1. Baseline screenshot A28088FD…png and paywall-close-contrast.json. | Explicit labelled cancellation toolbar control with light glyph/dark background; tests cover visible dismissal, retained setup/result and full system audit. | correction under validation |
| M10-T1 | Functional verification | P1 | Shared waitForLabel observes a transient expected label, then re-queries it for XCTAssertEqual after expiry. Baseline full run fails at Americano correction. | Cache and assert the label observation that terminated the wait; same expected label/deadline and failure behavior. Current rerun pending. | correction under validation |
| M10-P2-1 | Accessibility | P2 | Circle +/- controls do not add an Increase Contrast outline; icons retain text contrast and 44-point hit areas. Unchanged M06 source evidence. | Deferred: no loss of action identification; a border would improve consistency rather than remove a demonstrated barrier. | deferred |
| M10-P2-2 | Accessibility | P2 | Compact Sets summary speaks each score without its set number; detailed Sets rows identify numbers. Retained M06 observation, unchanged source. | Deferred: explicit numbered detail is available; confirm actual speech/focus in the pending VoiceOver journey before changing grouping. | deferred |
| M10-P2-3 | UI / UX | P2 | Remove a set, change format and cancel format replacement: the draft’s Restore set shortcut disappears. Whole-draft discard and post-save Undo remain. Retained M06 observation. | Deferred: recovery stays available; preserving an additional transient shortcut is not necessary to protect the saved game. | deferred |
| M10-P2-4 | UI / UX | P2 | Largest-text collapsed result navigation title may truncate; full result meaning stays in content. Retained M07 observation. | Deferred: standard system navigation title behavior; primary result is readable. | deferred |

Use `P0`, `P1`, or `P2`. Record an absent capability as `INAPPLICABLE` with a
reason, and an out-of-scope opportunity as `FUTURE_PRODUCT_IDEA`; neither is a
finding. For a deferred P2, state why its benefit, risk, or scope did not justify a
change in this milestone.

## Targeted re-audit

- Changed area: one permanent StoreKit USD/EUR regression added from the previous isolated currency experiment; production code is unchanged. Checks active storefront, actual currency code, exact Product.displayPrice passthrough and distinct localized strings. The local EUR amount is not claimed to equal ASC regional pricing.
- Build-for-testing passed; runtime targeted run pending device lease. Test sessions reset StoreKit state in defer; original four scenarios/assertions untouched.
- No production fix requiring a second behavioral pass so far; no independent audit claimed.
- Targeted paywall baseline audit: 1/1 passed before the fix despite the measured visual contrast failure; retained as an automation limitation. Production fix changes only Access sheet dismissal chrome.
- Minimum watchOS 10 baseline full suite: 387/387 passed, 0 failures/skips, exit 0; watchos10-summary.json and watchos10.xcresult.
- New currency plus unmodified correction repeat at f1f96d99aa62151b4ac0336685ce998f24167908: 6/6 passed, exit 0; currency-and-correction.xcresult. Prices $4.99 and 4,99 € are local StoreKit formatting observations.
- Intermediate full run at 09234bc84f5b33768e69329e2b946561747f800a was intentionally interrupted via SIGINT to its own xcodebuild PID 17608 after the paywall finding; not a pass. Its exit/error bundle is retained (fast-corrected.log, make exit 2, XCTest exit 73 after cancellation).
- Full domain completion still awaits runtime/manual requirements.

## Additional scanner

- Additional scanner: not configured. SwiftLint, SwiftFormat and ShellCheck are disabled in Config; they are not claimed as passed.
- Findings and corrections:

## Verification and release

| Field | Evidence |
| --- | --- |
| Verified SHA | full 40-character commit |
| Milestone command / exit | exact command; numeric exit |
| Milestone report / counts | path; tests, failures, skipped, builds |
| Release command / exit | exact command; numeric exit |
| Release report / verdict | not run; readiness not established |
| Manual checklist | path; outstanding row count |

## Residuals and handoff

- Known P0/P1: assessment incomplete; no release verdict claimed.
- Deferred P2:
- Manual work still pending: on-court readability/tapping context, spoken VoiceOver J1–J4 (including correction escape and alert/purchase focus), and unobserved physical accessibility/Always On/Low Power cases from DESIGN. Owner explicitly requested these later; the passed checks are not repeated or erased.
- Handoff: `AI/handoffs/M10-handoff.md`

### Access correction checkpoint

- Neutral cancellation toolbar replaces the low-contrast automatic sheet X. Focused current-source check: `paywall-inner26.xcresult`, exit 0, 1/1 passed, no skipped tests. It audits accessibility, checks the innermost native control's Close label, hittability and at least 44×44 frame, taps it and verifies setup/last-result access. watchOS exposes multiple same-ID wrappers; the outer visual wrapper is 30×30, the innermost tappable button is 50×50. Earlier exploratory failures in paywall-{after26,after10,v2,native,tree,final26} remain preserved and are not counted as passing evidence. Full regression and minimum-OS correction validation follow this checkpoint.
