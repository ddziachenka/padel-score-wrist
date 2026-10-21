# M08 StoreKit hardware investigation

**Policy status:** current

## Milestone

M08 — Access and Purchase; **BLOCKED**. This updates the current blocker in
[the earlier hardware handoff](M08-hardware-handoff.md), preserving its evidence.

## Summary

Reproduced the original four StoreKit tests on the real Watch, investigated the
local environment and compared it with Sandbox. Disabling the configuration in
both Run and Test did not clear the installed app's Xcode StoreKit environment.
After the owner explicitly authorized reinstalling only Padel Score and restoring
its data, reinstall reached the real Sandbox password prompt. After the owner
interacted privately, the prompt closed, but AppTransaction.refresh returned
StoreKitError.unknown. Successful Sandbox login is **not confirmed**.

Direct Product.products lookup then returned an empty array, without throwing,
for com.dziachenka.padelscore.lifetime; Storefront.current was USA. A production
purchase-client probe also received no product. No Sandbox purchase or restore
passed. Returning to the original local configuration and running a UI test
reactivated local StoreKit, but the original four tests still passed only 1/4.
No upload, App Review submission, support message or account reset was performed.

## Changed files

- This handoff, PROJECT_STATUS, DEVELOPMENT_PLAN, M08 contract and M08 handoff
  pointer record the evidence. No retained implementation or test changes.
- All temporary test probes, app diagnostics, StoreKit identity settings, signing
  settings, test-plan/scheme changes and Xcode-generated catalog formatting were
  restored. Diagnostic source copies remain in ignored artifacts.
- The pre-existing scheme diff remains byte-for-byte: SHA256
  `6b19770fb56b152ab94d13891606f8b5118b82e9f040509498517eec948dd3c8`.

## Validation

| Field | Evidence |
| --- | --- |
| Source SHA | `7fbd670fa474f14925d3a3882d4a3d28dabf4a07`, plus pre-existing scheme diff; not a clean verified candidate |
| Timestamp | 2026-10-21 UTC; final run ended 2026-10-21T20:46:24Z (October 22 in Asia/Tbilisi) |
| Environment | Xcode 27.0 (27A266a), Watch Ultra 3 / watchOS 27.0.1 (24R365), UDID `00008310-000823642660E01E` |
| Evidence directory | `.artifacts/M08-hardware-fix/`; each run has exact invocation in `.log`, numeric `.exit`, `.xcresult` and exported `.summary.json`; combined `test-counts.json` |
| Baseline original tests | `baseline`: exit 65; **1 passed / 3 failed / 0 skipped**, 4 tests |
| Local identity experiment | `identity-awake`: exit 65; **1/3/0**, 4 tests; app/team IDs in config did not fix the discrepancy |
| New entitlement API probe | `product-api`: exit 65; **0/1/0**; currentEntitlements(for:) also empty |
| No-config UI | `no-config-ui`: exit 0; **1/0/0**; did not clear the Xcode StoreKit environment |
| Clean Sandbox authentication probe | `sandbox-clean-awake`: exit 65; **0/1/0**, AppTransaction.refresh unknown after real password prompt closed |
| Direct Sandbox purchase probe | `sandbox-direct-purchase`: exit 65; **0/1/0**, no product, purchase not reached |
| Direct Sandbox catalog probe | `sandbox-catalog`: exit 65; **0/1/0**, rawProducts=[] and storefront=USA |
| Interrupted local attempt | `local-clean-install`: exit 75, TEST INTERRUPTED; bundle reports **0/1/0**, remaining 3 tests not run; interrupted because restore opened real Sandbox authentication despite local disableDialogs=true |
| Local reactivation UI | `local-reactivation-ui`: exit 0; **1/0/0**, About navigation/version |
| Final original local tests | `local-final`: exit 65; **1 passed / 3 failed / 0 skipped**, 8 assertion failures across the 3 failed tests |
| Declared milestone command | `make milestone ID=M08`: Make exit 2 / verifier 65; existing scheme diff rejected by clean-tree precondition; zero gate builds/tests; `milestone.log` |
| Records checks | `make static`, `./Scripts/project-status.sh validate`, `git diff --check`: exit 0; static.log and static.exit retained |

Other diagnostic runs are not additional passes: identity-config and
sandbox-clean-install failed to launch while the screen was asleep (each bundle
reports one failed test, no test assertions ran). sandbox, sandbox-refresh,
sandbox-after-ui, sandbox-after-run and sandbox-refresh-after-run each failed
their Xcode-environment guard; sandbox-ui-probe timed out at its simulated Xcode
prompt. Each exited 65 with 0 passed / 1 failed / 0 skipped. The separate
sandbox-build-for-testing exited 0 and ran zero tests.

Final test command, also used for baseline with the corresponding result path:

```sh
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 60 -derivedDataPath /private/tmp/padel-m08-hardware -resultBundlePath .artifacts/M08-hardware-fix/local-final.xcresult -only-testing:PadelScoreWatchTests/StoreKitPurchaseTests -parallel-testing-enabled NO -collect-test-diagnostics never DEVELOPMENT_TEAM=WW8JPY8B94 test
```

The final UI command uses the same options with result path
local-reactivation-ui.xcresult and selection
PadelScoreWatchUITests/BootstrapUITests/testAboutNavigationAndInstalledVersion.
No full release gate ran; M08 has not reached DONE.

## Tests

No test assertions removed, skipped or relaxed. Temporary probes were used only
for diagnosis and removed before the final original suite. Self-review confirmed
that a history-based entitlement fallback or debug unlock would mask the observed
failure, so neither was introduced. This is self-review, not independent approval.
Previously passing hardware UI 3/3 and fake-client policy/ledger/owner 16/16 remain
historical evidence from the earlier handoff, not new Sandbox evidence.

Reinstall backup is `watch-data-backup/`; production Session storage was absent
and Documents empty. The three existing game-state JSON files were synthetic
UI-test stores. They were restored from `restore-game-data/` and read back into
`restored-verification/`: all three SHA256 hashes matched. No claim of recovering
nonexistent production games or purchases is made. StoreKit cache preferences
were deliberately excluded from restoration. Backup/copy/install commands exited
0; see data-backup.log, data-restore.log, restore-verify.log, uninstall.json and
reinstall.json. The final installed app is the original Debug source with local
Xcode StoreKit reactivated by the UI run, not a confirmed Sandbox purchase build.

## Known issues

1. **Local current entitlements:** a verified, correct-bundle, non-revoked
   non-consumable appears in transaction history/latest, but all three current
   entitlement APIs are empty. Device and purchase dates match; no expiration.
   The app consequently remains locked. Injected network failure also surfaces
   as ASDServerErrorDomain 511 / XcodeTest and maps to generic failure. Reinstall
   and explicit config identity did not fix either issue.
2. **Sandbox catalog:** product lookup returns no product. Read-only ASC checks
   confirmed IAP 6825393394, exact product ID, NON_CONSUMABLE, READY_TO_SUBMIT;
   registered explicit bundle IDs have IAP capability, and the development
   profile matches the Watch and app. USA $4.99 / 175-region configuration was
   already verified. Paid Apps Agreement, banking, tax forms and DSA were Active
   on current readback (business-status.txt). These checks do not establish the
   cause of the empty catalog or confirm Sandbox authentication.
3. **Release path:** Apple's current [Submit an In-App Purchase help](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/)
   says Watch submissions cannot include IAPs/subscriptions. The supported path
   for this watch-only app's first non-consumable needs clarification with Apple,
   given watchOS StoreKit API availability. This is a separate documented risk,
   not proof of the Sandbox catalog failure's cause. Product architecture and
   approved five-free-games/lifetime policy were not changed.
4. The clean M08 gate remains blocked by the preserved scheme diff and required
   purchase evidence. M09/M10 and release readiness are not advanced.

## Next step

Resolve the Sandbox catalog/authentication issue and confirm the supported
watch-only first-IAP submission path with Apple before changing product scope.
A concrete draft is saved at `.artifacts/M08-hardware-fix/apple-support-draft.md`;
it has **not been sent**. Sending requires the owner's explicit instruction.
Keep local StoreKit API failures separate from Sandbox findings. After resolution,
complete all required real-Watch purchase scenarios and run the clean REVIEW
`make milestone ID=M08` gate. Do not submit to App Review without explicit approval.
