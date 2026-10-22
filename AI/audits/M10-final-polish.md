# Final Product Polish audit — M10

**Policy status:** current
**Candidate:** pending; baseline e009fdb9b9565f241bac3db724d7bd54d9e9c50b
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
- Evidence: `make fast` runs the complete unchanged shared scheme (FAST_TEST_ARGUMENTS empty). Console `.artifacts/M10-final-polish/fast.log`; report `.artifacts/fast/20261022T084728Z-80046/report.md`. Generic Debug build-for-testing into `/private/tmp/padel-m10-minimum-derived` succeeded, exit 0 (`minimum-build.log`, `minimum-build.exit`). That build alone does not prove watchOS 10 compatibility.
- Owner physical check requested in Russian: scoring and haptics, exact Undo, Crown does not score, wrist-down/wake and lock/unlock preserve score/server, focused Crown edit and discard. Owner answered “все сработало” for all five requested checks. This is manual owner-observed evidence, not an automated screenshot or test count. On-court context was not stated; explicitly requested again. Owner subsequently answered “все работает” for finish cancellation, finish/Saved/haptic, resume and Americano 4/2 draw/extra-point rejection/Undo. Owner asked to continue on simulator and will test hardware separately later. Court context remains unstated; spoken VoiceOver journeys are not performed. Structured observation: `.artifacts/M10-final-polish/physical-observations.json`.

## Coverage: functional

Pending: enter typed rows only after the assigned checks have evidence.

## UI / UX

- Source assessment: semantic dark palette, 44-point minimum controls, adaptive column/stack score, explicit save/error feedback and native navigation follow DESIGN. No design change justified from source. Runtime visual assessment waits for the current managed-device suite to release its lease.
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
| — | — | — | — | — | none |

Use `P0`, `P1`, or `P2`. Record an absent capability as `INAPPLICABLE` with a
reason, and an out-of-scope opportunity as `FUTURE_PRODUCT_IDEA`; neither is a
finding. For a deferred P2, state why its benefit, risk, or scope did not justify a
change in this milestone.

## Targeted re-audit

- Changed area: one permanent StoreKit USD/EUR regression added from the previous isolated currency experiment; production code is unchanged. Checks active storefront, actual currency code, exact Product.displayPrice passthrough and distinct localized strings. The local EUR amount is not claimed to equal ASC regional pricing.
- Build-for-testing passed; runtime targeted run pending device lease. Test sessions reset StoreKit state in defer; original four scenarios/assertions untouched.
- No production fix requiring a second behavioral pass so far; no independent audit claimed.
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
- Manual work still pending:
- Handoff: `AI/handoffs/M10-handoff.md`
