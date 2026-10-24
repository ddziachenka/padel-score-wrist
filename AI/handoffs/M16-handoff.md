# M16 handoff — Compact iPhone Companion

**Policy status:** current

## Milestone

M16 — Compact iPhone Companion; **DONE under explicit owner acceptance**.
Raw automated gate: FAILED, solely the two accepted native contrast audits.
No independent review or release approval is claimed.

## Summary

Added Start, real-engine Match/Americano demos and the existing lifetime flow on
iOS17 while retaining independent watchOS10 operation. All app languages and store
copy are updated. Fixed invisible explanatory text and spacing, Spanish largest-text
truncation, and named the Home Screen icon PadelScore. Prepared56 native phone store
images, signed1.0(2) archive and dual-platform verification. The launch offer remains
unchanged; Sandbox/TestFlight do not start its clock.

## Changed files

- App/PadelScorePhone, PhoneTests, PhoneUITests and Xcode targets/plans: companion,
  localized UI, shared engines/StoreKit, rating eligibility and isolated test host.
- Watch shared display/message extraction and independent companion packaging;
  precise identity, build and launcher assertions retained.
- Scripts/lib/companion.sh and common/platform/simulator/gates: mandatory complete
  platform suites, actual packaging and failure-closed results; regression fixtures.
- AI/store-assets/iphone-m16/manifest.json and56 native PNGs:14 locales,1320×2868,
  opaque, original captures with SHA/provenance. Old Watch/Header/Search assets kept.
- Product/architecture/design/workflow/M16 contracts, local store/site/review drafts
  and guarded launch monitor. Historical milestones/readiness remain unchanged.

## Validation

| Field | Evidence |
| --- | --- |
| Exact verified candidate | `b671bb1d611daebb03718429f1036eab569a1cca`, clean REVIEW on main |
| Exact command | `make milestone ID=M16` |
| Actual exit codes | Make2, verifier1, iPhone UI xcodebuild65; raw verdict FAILED |
| UTC verification | 2026-10-24T14:34:30Z–17:07:22.459Z (last bundle finish) |
| Report | `.artifacts/milestone/M16/20261024T143428Z-49481/report.md` |
| Full Watch | exit0;510/510 definitions,884 invocations,0 failed/skipped/expected/warnings; `milestone.xcresult` under report directory |
| Full iPhone unit/StoreKit | exit0;14/14 definitions,20 invocations,0 failed/skipped/expected/warnings; `companion/unit.xcresult` |
| Full iPhone UI | exit65;6/6 executed,4 passed/2 Contrast failed,0 skipped/expected/warnings; `companion/ui.xcresult` |
| Owner disposition | Exactly those two audits and existing physical coverage accepted; `AI/evidence/M16/owner-acceptance-20261024.md`. No test/parser changed |
| Supplemental runtimes | watchOS10 and27 each13 definitions/24 invocations passed, exit0; current iOS27 smoke4/4 passed, including both native audits |
| Generic tooling | Owner-approved original-template fixture `make self-test` exit0,99 cases/2161 checks;28 file hashes still match `AI/evidence/M16/tooling-fixture-manifest.json` |
| Product static/site | Exact gate static/Debug packaging passed; `make site-check` exit0, `.artifacts/M16/site-owner-final.log` |
| Archive | `.artifacts/M16/PadelScore-M16-fc118f8.xcarchive`; archive/packaging/codesign exit0; source `fc118f8a0b357d52e0b06f8ba1f17449297ca623`, App/Config/Scripts unchanged at final candidate |
| Store assets |56 native phone images/14 locales; `AI/store-assets/iphone-m16/manifest.json`; capture source `b2a30e091d423d3414a59d1d2c9c2a65daeb59e5`; old84 Watch/28 creative assets hash-identical |

Complete commands, per-platform timestamps, source/fixture SHAs and limits:
[final verification](../evidence/M16/milestone-verification.md).
Earlier failures/checkpoints are preserved in
[verification progress](../evidence/M16/verification-progress.md).
The first same-candidate attempt failed strict packaging due to a stale old Debug
XCTest bundle; only the owned Watch DerivedData was cleaned, then the same complete
gate ran unchanged. Clean that owned cache before future strict gates; preserve the
guard. Closing Markdown commit is followed by static, status and production-input
continuity checks; their logs remain under `.artifacts/M16/`.

## Tests

Real engine initial state/service/end/Undo/reset/navigation/isolation; StoreKit
free/paid/cancel/pending/unavailable/network/unverified/refund/relaunch/restore and
ownership after price return; rating day/365-day eligibility and localized links;
compiled text-opacity/AA regression; full phone gallery and native UI audits.
Harness tests require both complete platforms, reject missing/skipped results and
mutated packages, preserve source/test-host parity and verified historical context
plus six current readiness domains. All2161 tooling checks passed. Full Watch was
not reduced. Builder self-review and fixes: [self-review](../evidence/M16/self-review.md).

## Known issues

`CompanionUITests/testLargestTextAccessibility()` and
`CompanionUITests/testSpanishTeamNamesAtLargestTextAreNotClipped()` report native
**Contrast failed** on SE3/iOS17. These are not proven false positives; owner accepts
them as nonblocking based on passed current-iOS27 audits. No other error is waived.

Owner confirmed visible text/Watch update, restore on both devices and Watch scoring
without phone connection. Fresh acquisition in both directions, reinstall, deletion
of only the phone app and additional physical accessibility/haptics scenarios were
not executed; the owner explicitly accepts existing physical coverage as sufficient.
No new Sandbox testers were created or purchase histories reset.

## Next step

Stop this Builder session. A separate **Release Readiness Revalidation** must assess
the new candidate with this owner decision and actual raw test result. Do not inherit
M10 READY_FOR_HUMAN. Then upload/select the new build and verify app plus first IAP
submission through ordinary ASC under existing submission authorization. The former
Watch-only restriction is not proven resolved until that actual normal path works.

No new upload/submission/publication occurred. Old build1 remains selected, draft
READY_FOR_REVIEW; not Waiting for Review. New store/site/review texts remain drafts.
Keep `.artifacts/M16/` and `.artifacts/asc-launch-20261024/` for xcresults, archives,
regional baseline prices and monitor inputs. The monitor stays read-only until its
new readiness/build guards are met. Promotion has no public start/end date yet.
