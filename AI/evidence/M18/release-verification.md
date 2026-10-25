# M18 candidate-bound release verification

Candidate `572e3524157154f9104edab61b1d4311de437857`, clean REVIEW/main. Exact unchanged command:
`make release CANDIDATE=572e3524157154f9104edab61b1d4311de437857`. Read-only immutable candidate; source continuity
from M17/archive `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77` confirmed. Only AI Markdown differs.

**Raw VERDICT: VERIFICATION_FAILED; Make exit2, release verifier1, phone UI xcodebuild65.**
Only the exact two native Contrast failed cases accepted by the owner remain.
No new failure, skip, missing suite, expected failure or runtime warning.
Disposition: **OWNER_ACCEPTED_FOR_SUBMISSION**, never automated READY_FOR_HUMAN.
Authorization: AI/evidence/M17/owner-release-authorization.md and the exact
AI/evidence/M16/owner-acceptance-20261024.md scope. Unperformed physical scenarios
remain unperformed, not passed. No independent review is claimed.

Report `.artifacts/release/20261024T234539Z-52536/report.md`; console `.artifacts/M18/release.log`;
actual command/Make exit/UTC start–finish `.artifacts/M18/release-exit.json`.
The unchanged gate emits VERDICT=VERIFICATION_FAILED on stdout after companion UI
failure; its report ends before the final verdict footer. Preserve both report
and console; do not fabricate a verdict line in the raw report.
All exact native xcodebuild commands saved beside report as *.command.

| Platform | Definitions | Invocations | Passed | Failed | Skipped / expected / runtime warnings | UTC start–finish |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Watch | 510 | 884 | 510 | 0 | 0 / 0 / 0 | 2026-10-24T23:46:41.650000+00:00–2026-10-25T02:04:46.776000+00:00 |
| iPhone unit/StoreKit | 14 | 20 | 14 | 0 | 0 / 0 / 0 | 2026-10-25T02:05:43.266000+00:00–2026-10-25T02:05:51.737000+00:00 |
| iPhone UI | 6 | 6 | 4 | 2 | 0 / 0 / 0 | 2026-10-25T02:05:53.060000+00:00–2026-10-25T02:20:48.134000+00:00 |

The complete Watch and phone unit/StoreKit suites passed. Phone UI has4 passed,
only testLargestTextAccessibility and testSpanishTeamNamesAtLargestTextAreNotClipped
failed with native Contrast failed. Original categories/assertions retained.
Six current typed domain records, strict preflight/static, clean Debug builds,
unsigned clean device Release builds and actual package guards ran unchanged;
release report and logs retain the exact outcome of every step. Archive/export/
actual IPA package/signature checks and Apple altool validate-app all exit0:
.artifacts/asc-companion-20261024/export-02ec9c9/PROVENANCE.md.
IPA SHA256 `820e0ab32614f429225b67ab78ce614f23f7a65a4db77a1b0ca48cc24d823e0d`. Version/build1.0(2) match root iPhone,
independent Watch and launcher; no distribution test components/debug entitlement.

## Deliberate command consolidation

Before M18 started, its declared validation was changed to the stricter unchanged
full immutable release command under the owner's time-saving direction. The extra
planned make milestone ID=M18 was not executed and is not called passed. M17 had
already run both complete platforms on identical build inputs. No generic script,
parser, assertion, native category, test filter, platform or release check changed.
AI/WORKFLOW.md and M18 contract preserve this bounded scheduling decision.

## Distribution boundary

This evidence establishes new candidate readiness only under explicit owner
acceptance. Upload/select VALID2, actual owner TestFlight verification where possible,
normal app+first lifetime IAP submission and server build/submission IDs are the
following authorized actions, not claimed completed by this gate. TestFlight does
not start the public-launch-day-plus-seven-full-regional-days0-price period.
Neutral promo remains feature-only all14 locales; no automatic offer text.

Generated human checklist: `.artifacts/release-checklists/572e3524157154f9104edab61b1d4311de437857/checklist.md`, **3 pending manual rows**
at gate time;
manual rows are not automated passes. Existing owner current-pair acceptance,
explicit distribution decision and authorized signed CLI archive/server validation
are recorded separately; Product>Archive/Organizer clicks are not falsely claimed.
