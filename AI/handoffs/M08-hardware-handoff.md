# M08 real-Watch handoff

**Policy status:** current

## Milestone

M08 — Access and Purchase; `BLOCKED` by failing real-device StoreKit coverage.
Hardware is now available. This supersedes the hardware-unavailable blocker in
the older M08 handoff, not its historical test evidence.

## Summary

Connected the owner's Apple Watch Ultra 3 and ran the existing tests on it.
Developer Mode was already enabled. The initial network tunnel was unstable;
after Xcode preparation the device became connected with usable DDI services.
Registered the Watch through Xcode automatic provisioning and refreshed the
development profiles for the app and UI runner. A clean rebuild of this session's
dedicated DerivedData resolved a stale reference to a replaced profile.

Three access UI tests and 16 access-policy/ledger/owner tests passed on hardware.
The final unmodified four-test StoreKit run passed only the unverified-purchase
test; purchase/restore/refund, pending approval and network/offline coverage failed.
Nothing was uploaded or submitted for App Review. The installed Debug app was
launched normally without UI-test seeds at the end.

## Changed files

- This handoff, PROJECT_STATUS, DEVELOPMENT_PLAN, M08 contract and the earlier
  M08 handoff pointer record the new hardware evidence and precise blocker.
- No retained app, test, project or configuration changes. Temporary diagnostic
  prints in StoreKitPurchaseTests were removed byte-for-byte after use.
- The existing unowned scheme changes remain untouched: XML version 1.7 and
  omitted BlueprintName attributes in Run/Profile. They still prevent a clean gate.

## Validation

| Field | Evidence |
| --- | --- |
| Source SHA | `4c330c8d35018e0828c83eb73963823ec2eff1f4`, with the pre-existing scheme diff; not a clean candidate |
| Timestamp | 2026-10-21T19:45Z–20:04Z (October 21–22 in Asia/Tbilisi) |
| Environment | Xcode 27.0 (27A266a); physical Apple Watch Ultra 3, watchOS 27.0.1 (24R365), UDID `00008310-000823642660E01E` |
| Report | `.artifacts/M08-hardware/report.md`, logs, `.exit`, summaries and `.xcresult` bundles in that directory |
| Source binding | `source.json`, `existing-scheme.patch`; scheme SHA256 `6b19770fb56b152ab94d13891606f8b5118b82e9f040509498517eec948dd3c8` |
| Initial destination | `initial.log`: exit 70, zero tests; Xcode preparing-device timeout |
| Signed build | `build.log`: exit 0; generic build-for-testing; first install rejected the profile (`retry.log`, exit 65, zero tests) |
| Profile repair | `provisioned.log`: exit 65, stale profile path; `clean-device.log` then built and ran tests successfully but assertions failed |
| First StoreKit run | `clean-device.xcresult`: exit 65, **0 passed / 4 failed / 0 skipped**; missing local product and Sandbox login, cancelled by owner |
| UI | `access-ui.xcresult`: exit 0, **3 passed / 0 failed / 0 skipped**; five screenshots exported to `ui-screenshots/` |
| Final unchanged StoreKit run | `after-ui.xcresult`: exit 65, **1 passed / 3 failed / 0 skipped** |
| Policy/ledger/owner | `policy-owner.xcresult`: exit 0, **16 passed / 0 failed / 0 skipped** after removing diagnostics |
| Declared validation | `make milestone ID=M08`: Make exit 2 / verifier 65, clean-tree precondition rejected existing scheme diff; zero gate tests, `milestone.log` |
| Ordinary launch | `xcrun devicectl device process launch --device 00008310-000823642660E01E --terminate-existing --json-output .artifacts/M08-hardware/standalone-launch.json com.dziachenka.padelscore.watchapp`: exit 0 |
| Records checks | `make static`, `./Scripts/project-status.sh validate`, `git diff --check`: exit 0; `static.log` retained |

Every xcodebuild log begins with the exact invocation. The main final commands were:

```sh
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 60 -derivedDataPath /private/tmp/padel-m08-hardware -resultBundlePath .artifacts/M08-hardware/access-ui.xcresult -only-testing:PadelScoreWatchUITests/AccessUITests -parallel-testing-enabled NO -collect-test-diagnostics never DEVELOPMENT_TEAM=WW8JPY8B94 test-without-building
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 60 -derivedDataPath /private/tmp/padel-m08-hardware -resultBundlePath .artifacts/M08-hardware/after-ui.xcresult -only-testing:PadelScoreWatchTests/StoreKitPurchaseTests -parallel-testing-enabled NO -collect-test-diagnostics never DEVELOPMENT_TEAM=WW8JPY8B94 test-without-building
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 60 -derivedDataPath /private/tmp/padel-m08-hardware -resultBundlePath .artifacts/M08-hardware/policy-owner.xcresult -only-testing:PadelScoreWatchTests/LifetimeAccessTests -only-testing:PadelScoreWatchTests/UsageLedgerTests -only-testing:PadelScoreWatchTests/EntitlementStoreTests -parallel-testing-enabled NO -collect-test-diagnostics never DEVELOPMENT_TEAM=WW8JPY8B94 test
make milestone ID=M08
```

## Tests

No assertions removed, relaxed or skipped. The policy-owner tests use their
existing fake PurchaseClient and do not substitute for real StoreKit transactions.
The three UI tests drove automatic free access, large text/legal content, a sixth
game paywall, closing it without losing the result/draft, Resume, and retention of
the completion count after deletion in an isolated UI-test store. Inspected the
actual Watch screenshots: the paywall showed $4.99 and the resumed score rendered
Games/Sets labels correctly. This is self-review, not independent review.

StoreKit diagnostics retained the original assertions and only added temporary
logging/delay. Each diagnostic purchase run failed (1 test, 0 passed, 1 failed,
0 skipped, exit 65). `diagnostic-only.patch` preserves the final diagnostic diff.
`no-distributor.xcresult` used unchanged binaries with APP_DISTRIBUTOR_ID_OVERRIDE
removed only from a copy of the generated launch plan; 0/1 passed, exit 65.

## Known issues

1. **Blocking StoreKit inconsistency:** after local Xcode StoreKit became active,
   `Transaction.all` returned one **verified**, non-revoked Non-Consumable for the
   correct product in the Xcode environment. `Transaction.latest(for:)` returned
   it, but both `Transaction.currentEntitlements` and
   `Transaction.currentEntitlement(for:)` were empty, also after a two-second
   wait. Device and purchase dates matched, expiration was nil and calendar was
   Gregorian. Evidence: `entitlement-api-diagnostic.log`, `time-diagnostic.log`.
   The app consequently refused to unlock. No fallback to transaction history or
   debug override was introduced. This is a reproducible API discrepancy in the
   local test environment, not proof that production Sandbox has the same defect.
2. **Blocking injected network error:** StoreKit returned ASDServerErrorDomain 511
   with `client-environment-type=XcodeTest`, mapped to generic failure instead of
   the requested network error. The original offline assertion remains failing.
3. **Initial activation:** first hosted tests saw no local product and restore
   opened Sandbox authentication. Owner cancelled. Later UI launch loaded the
   product; the follow-up suite used XcodeTest without password entry. This is
   not a verified live Sandbox purchase/restore.
4. Full clean M08 verification and required purchase coverage remain incomplete;
   M09/M10 and release readiness are not advanced. Existing scheme changes are
   preserved. No global simulator/service reset, device erase or account reset.

## Next step

Continue M08 by resolving the real-device StoreKit test-environment discrepancy
and verifying all purchase scenarios. A live Sandbox comparison may help isolate
the issue; it needs the owner to authenticate privately on the device. Preserve
current-entitlement/signature/revocation checks. Resolve ownership of the existing
scheme diff before a clean REVIEW gate. Then run `make milestone ID=M08` on the
exact candidate. Do not submit app/IAP without a new explicit instruction.
