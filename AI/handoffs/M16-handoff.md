# M16 handoff — Compact iPhone Companion

**Policy status:** current

## Milestone

M16 — Compact iPhone Companion; **BLOCKED, not DONE**. Continue this same milestone.
No independent review or release approval is claimed.

## Summary

Implemented Start, real-engine Match/Americano demos and the existing lifetime flow
on iOS17, retaining independent watchOS10 operation and the launch offer. All app
languages/store drafts are updated. Fixed invisible explanatory text/spacing and
Spanish largest-text truncation; Home Screen label is PadelScore. Prepared56 native
phone store images, a signed1.0(2) archive, dual-platform harness and passing tooling
regressions. Small-phone native contrast audits and mandatory physical scenarios
remain incomplete; Mac is locked and the physical pair is unavailable.

## Changed files

- App/PadelScorePhone, PhoneTests, PhoneUITests and Xcode targets/plans: companion,
  localized UI, shared score engines/StoreKit and isolated test host.
- Watch shared-value/message extraction and independent companion packaging;
  actual identity/build/launcher assertions are preserved and updated for build2.
- Scripts/lib/companion.sh, common/platform/simulator/gates and product Python
  guards: both required platforms, actual packaging and failure-closed results.
- AI/store-assets/iphone-m16/manifest.json and56 native PNGs:14 locales,1320×2868,
  opaque, unmodified captures with source SHA and hashes. Old Watch/Header/Search
  assets are preserved; site/store/review texts remain local drafts.
- Product/architecture/design/workflow/status/M16 contracts; evidence and monitor
  guard. Historical milestones/readiness records were not rewritten.

## Validation

| Field | Evidence |
| --- | --- |
| Current tested implementation SHA | `fc118f8a0b357d52e0b06f8ba1f17449297ca623`; later handoff/status changes are evidence only |
| Required exact milestone command | `make milestone ID=M16` — **not yet run on a qualified clean REVIEW candidate**: two full iOS UI failures and required hardware remain open; no passing M16 gate |
| Full iPhone unit / exit | `Scripts/simulator.sh --profile companion run -- bash .artifacts/M16/check-phone-complete.sh`, first xcodebuild action schemePadelScorePhoneUnit, exit0 |
| Unit counts / report | 14 definitions/20 invocations,0 failed/skipped/expected/warnings; `.artifacts/M16/ios-unit-current-complete.xcresult`, summary alongside; UTC2026-10-24T14:00:44.129Z–14:00:53.949Z |
| Full iPhone UI / exit | Same driver, second action schemePadelScorePhone, **exit65**;6 cases,4 passed/2 failed,0 skipped/expected/warnings; `.artifacts/M16/ios-ui-current-complete.xcresult`; UTC14:00:54.672Z–14:04:42.148Z |
| Watch supplements | Managed watchOS10 and27 drivers under `.artifacts/M16/`; each exit0,13 definitions/24 invocations,0 failed/skipped/expected/warnings. `watch10-smoke.xcresult` UTC13:54:17.177Z–13:58:05.467Z; `watch27-smoke.xcresult` UTC13:47:43.320Z–13:52:22.895Z. Explicit scope: AppConfigurationTests, LauncherTests, BootstrapUITests, LauncherUITests; **not the complete primary Watch suite** |
| Current iOS supplement | `ios27-smoke.xcresult`, exit0,4/4,0 failures/skips on large iPhone at checkpointb2a30e0; no transfer to minimum-OS coverage |
| Generic tooling command / exit | `make self-test` in owner-approved byte-matched M00 fixture, exit0;99 cases/2161 checks/0 failures; log completion2026-10-24T13:51:43.750295Z |
| Tooling provenance / report | Sourceb2a30e091d423d3414a59d1d2c9c2a65daeb59e5; fixture76aa09b05613156708b304bdc65bf4ed8911c0e6;28 generic files byte-matched; `AI/evidence/M16/tooling-fixture-manifest.json`, `.artifacts/M16/self-test-approved-final-corrected.log` |
| Product static/site | `make static` and `make site-check` exit0: `.artifacts/M16/static-gallery-final.log`, `site-gallery-final.log`. Closing runs follow this handoff |
| Store captures | `iphone-gallery-m16-v2.xcresult`, exit0,1/1; sourceb2a30e091d423d3414a59d1d2c9c2a65daeb59e5;56 native images/14 regions; seven inspected contact sheets plus local Vision OCR of all score figures. Production delta since capture is limited to the accessibility-size neutral card background |
| Current signed archive | `.artifacts/M16/PadelScore-M16-fc118f8.xcarchive`; archive exit0, `verify-companion.py --phone-app` and `codesign --verify --deep --strict` each exit0; logs `archive-fc118f8.log`, `archive-fc118f8-packaging.log` |
| Overall result | BLOCKED; full primary Watch suite, exact milestone verification and required hardware are not established. No READY_FOR_HUMAN, upload, submission or public launch |

## Tests

Real engine initial states/serving/end/Undo/reset/isolation; live StoreKit free/paid,
cancel/pending/unverified/unavailable/refund/relaunch/restore/price-return; local
rating eligibility and localized links; compiled text-opacity/AA regression; native
UI audits and14-locale gallery. Harness covers separate profiles and rejects missing
or incomplete platform results; package mutations and source/test-host parity are
mandatory. New readiness regression preserves verified historical Watch-only context
only with six current domains and current iPhone rating evidence. The initial new
pipeline failure was fixed and all2161 unchanged/added assertions subsequently passed.
Self-review: AI/evidence/M16/self-review.md. All failed experiments are retained and
are never counted as passes.

## Known issues

Two current small-iPhone UI cases fail Contrast failed, including an unmapped native
issue: testLargestTextAccessibility and testSpanishTeamNamesAtLargestTextAreNotClipped.
These have not been proven false positives. No category/unknown issue is excluded.
An experimental broad recheck helper triggered XCTest injected logging/quarantine
crashes and was removed; no normal production crash is inferred from that experiment.

Computer Use's normal Xcode path reports the Mac locked. No lock was bypassed; the
owned simulator/desktop lease was released. Physical CoreDevice inventory reports
the owner pair unavailable. The owner previously confirmed visible text, Watch
update, restore on both and scoring disconnected from phone only. Fresh acquisition
in both directions, reinstall/restore, Watch with the iPhone app absent and physical
VoiceOver/haptics/Reduce Motion remain required. No testers were created or existing
purchase histories reset; the proposed two isolated Sandbox testers need the pending
owner choice. Preserve actual Watch data.

## Next step

Unlock Mac/reconnect the pair; resolve the native small-phone audit through normal
visual inspection and finish the isolated Sandbox scenarios. Fix/retest any finding;
complete full primary Watch and phone coverage, then set REVIEW, commit and run the
exact M16 milestone command. Only a passing gate plus all hardware evidence permits
DONE/continuity and stopping this Builder session. Separate Release Readiness
Revalidation, normal ASC app+first-IAP verification and submission follow afterward
under the existing owner authorization. Do not re-ask for submission permission.

Keep `.artifacts/M16/` and `.artifacts/asc-launch-20261024/`: they hold xcresults,
archives, price backups and active monitor inputs. Promotion has no start/end date;
Sandbox/TestFlight do not start it. Monitor stays read-only until M16/new readiness
and the new actual public build meet its guards. No new App Review status is claimed.

Closing checks: `make static` exit0 (`static-handoff-final.log`), `make site-check`
exit0 (`site-handoff-final.log`), `Scripts/project-status.sh validate` exit0 and
`git diff --check` exit0. Canonical PRODUCT/DESIGN/ARCHITECTURE rating/packaging/device
sections were then reconciled with M16 so current documents do not instruct a future
auditor to treat iPhone rating rows as INAPPLICABLE or the iOS executable as a stub;
`make static` passed again (`static-contract-final.log`). Historical milestones,
audits and verified SHAs remain intact. Final documentation commit remains BLOCKED;
no milestone continuity or DONE claim is made from these lightweight checks.
