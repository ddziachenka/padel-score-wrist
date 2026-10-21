# M08 Sandbox identity repair

**Policy status:** current

## Milestone

M08 — Access and Purchase; **BLOCKED** only for remaining local StoreKit
automation/clean milestone validation. Real-Watch Sandbox purchase and restore
now pass. This supersedes the empty-catalog hypothesis in the earlier handoffs.

## Summary

After the owner signed into the new Sandbox tester on the paired iPhone, the old
Watch bundle `.watchapp` still returned an empty catalog. AppStore.sync logged
Sandbox/USA with server error 4040003. Apple's App Store Server API documents
that code as [AppNotFoundError](https://developer.apple.com/documentation/appstoreserverapi/appnotfounderror).
The installed Xcode 27 watchOS template uses `.watchkitapp`. An isolated A/B
build with that suffix immediately loaded the same $4.99 non-consumable. Buying,
creating a fresh entitlement owner and restoring passed; the test required a
verified, non-revoked lifetime entitlement whose environment was Sandbox.

The owner privately completed the password and iPhone-code prompts. No password
or verification code was requested or received in chat. No review submission,
upload or support message occurred. The ASC app, container and product ID remain
unchanged. Bundle selection was already delegated in PRODUCT; this fixes the
technical identity without changing the approved watch-only product or pricing.

## Changed files

- Xcode project, Config/project.env, AppConfigurationTests and App/README.md:
  correct the executable ID to `com.dziachenka.padelscore.watchkitapp`.
- PRODUCT, ARCHITECTURE and status/handoff records: identity and evidence.
- Production purchase/entitlement code and all four StoreKit assertions unchanged.
  Temporary additive Sandbox probes are retained only under ignored artifacts.
- Existing unowned scheme diff is preserved byte-for-byte, SHA256
  `6b19770fb56b152ab94d13891606f8b5118b82e9f040509498517eec948dd3c8`.

## Validation

| Field | Evidence |
| --- | --- |
| Fix SHA | `86043c4ec99b912cd65ac5ea37174c74024f409e` |
| A/B source | `007e4921ee3e3ce620ed77953caf16d796eb57a8` + preserved scheme diff; successful diagnostic adds only Watch bundle suffix and temporary catalog/purchase/restore test. Probe source and original project saved in evidence directory. Not a clean milestone candidate. |
| Timestamp | 2026-10-22 Asia/Tbilisi; Sandbox pass 01:03:11, identity/policy pass 01:13:46 (2026-10-21 UTC) |
| Environment | Xcode 27.0 (27A266a); Watch Ultra 3, watchOS 27.0.1 (24R365), UDID `00008310-000823642660E01E` |
| Report | `.artifacts/M08-sandbox-new-account/`; each log starts with exact xcodebuild command; `.exit`, `.xcresult`, `.summary.json` and counts.json retained |
| Old-ID sync | sandbox.xcresult: exit 65, **0 passed / 1 failed / 0 skipped**, Sandbox server code 4040003 |
| Old-ID direct catalog | catalog.xcresult: exit 65, **0/1/0**, rawProducts=[]; purchase not reached |
| Correct-ID Sandbox | suffix.xcresult: exit **0**, **1 passed / 0 failed / 0 skipped**, product $4.99, unlocked, fresh owner unlocked, restored, verified Sandbox entitlement |
| Correct-ID UI | local-ui.xcresult: exit **0**, **1/0/0**, About navigation and installed version |
| Correct-ID identity/policy | identity-policy.xcresult: exit **0**, **19/0/0**, four suites including exact app identity, ledger and fake-client entitlement owner |
| Local automation attempts | local-fixed and local-final: each exit **75**, TEST INTERRUPTED, bundle **0/1/0**; first network test did not complete, other three did not run. These are failures, not coverage passes. |
| Ordinary Debug build | normal-build.log: exit **0**, no tests, original production source with corrected ID |
| Declared gate | `make milestone ID=M08`: Make exit **2** / verifier **65**, zero tests; milestone-committed.log at fix SHA rejected the preserved unowned scheme diff |
| Final device state | Ordinary Debug app reinstalled with devicectl, saved game files restored/read back (3/3 SHA256 matches), old-ID duplicate removed only after a fresh backup confirmed every game file was preserved; launch exit 0, normal-launch.json and final-app.png |
| Records checks | `make static`, `./Scripts/project-status.sh validate`, `git diff --check`: exit 0; static-final.log retained |

Successful Sandbox command:

```sh
xcodebuild test-without-building -xctestrun /private/tmp/padel-m08-sandbox-suffix/Build/Products/PadelScore_PadelScore_watchos27.0-arm64.xctestrun -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 60 -only-testing:PadelScoreWatchTests/StoreKitPurchaseTests/testHardwareSandboxCatalogPurchaseAndRestore -parallel-testing-enabled NO -collect-test-diagnostics never -resultBundlePath .artifacts/M08-sandbox-new-account/suffix.xcresult
```

## Tests

Self-review: exact bundle assertion updated with the identity; no entitlement,
signature, revocation, environment or offline assertion weakened. No debug unlock
or transaction-history fallback. The Sandbox probe was additive and restored
after building. The 19 policy/identity checks do not replace real StoreKit tests.

The first local attempt retained the Sandbox purchase and ignored simulated
errors. UI activation then selected Xcode, but the next original network test
opened a Buy dialog despite disableDialogs=true. Both attempts were interrupted
explicitly rather than reported as passing. The owner was told to cancel the
Xcode dialog. These local-control failures are separate from the passing actual
Sandbox purchase/restore and still block the required remaining hardware matrix.

## Known issues

- Local Xcode StoreKit controls still do not reliably govern the app on this
  Watch. Pending approval, refund/revocation and offline hardware checks remain
  incomplete under the repaired ID. Historical simulator gate success is not a
  fresh gate for this fix.
- Apple's Watch IAP submission documentation remains a release-path question
  for M10; it was not the cause of this catalog failure. The earlier unsent
  support draft's empty-catalog section is now obsolete.
- No production game Session existed in either installation. Three historical
  synthetic UI-test game files were backed up and moved to the corrected app;
  all three final readback hashes matched. No purchase entitlement was copied or
  fabricated. Full backups remain local; StoreKit cache preferences were omitted.

## Next step

Resolve the remaining local StoreKit-control issue, run every required hardware
scenario and verify a clean REVIEW candidate with `make milestone ID=M08`.
Retain the passing real Sandbox evidence. Do not submit to App Review.
