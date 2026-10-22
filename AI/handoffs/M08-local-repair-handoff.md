# M08 local StoreKit host repair

**Policy status:** current

## Milestone

M08 — Access and Purchase; IN_PROGRESS for the owner-approved real offline
Watch check. Complete simulator gate passes. Nothing is submitted for App Review.

## Summary

A dedicated local host aligns SKTestSession with the canonical container bundle
ID while the shipping Watch executable retains `.watchkitapp`. The host compiles
production files, except for a minimal test `@main` that makes no early StoreKit
calls. All four original StoreKit test bodies/assertions are preserved; setup
additionally rejects any unverified, non-Xcode or mismatched app identity before
purchase. Unit/policy and UI tests still run the shipping executable.

## Changed files

- Xcode project/scheme/plan: test-only host and serial StoreKit test target.
- `App/PadelScoreStoreKitTests/StoreKitPurchaseTests.swift`: moved original four
  scenarios, awaited/strengthened environment guard, same deterministic GameID helper.
- `App/PadelScoreStoreKitHost/StoreKitTestApp.swift`: inert test entry point.
- `Scripts/verify-storekit-host.py`: mandatory build guard for production-source,
  resource/settings parity, permitted entry-point substitution and archive exclusion.
- Architecture and M08 workflow records describe this test arrangement.
- No production application source, purchase behavior, UI or business rule changed.

## Validation

Starting SHA: `54e27eea188c6617a7fe44bd9b888830809c3bd8`, clean main.
Evidence: `.artifacts/M08-local-repair/`; each xcodebuild log contains the exact
command, with `.exit` and `.xcresult` beside it. Xcode 27.0 (27A266a); managed
Watch SE2 40mm / watchOS 26.1; physical Ultra3 / watchOS 27.0.1.

- `named-config`: original four tests fail; documented filename initialization
  and app-bundled StoreKit file do not fix the namespace mismatch. Probe removed.
- `isolated-host`: exit 0, 7/7 passed (four StoreKit + three shipping access UI),
  zero failures/skips.
- `host-guard`, `guarded-isolation`: each exit 0, 4/4 StoreKit passed, zero skips.
  The latter includes inert entry point and verified Xcode-environment guard.
- Validator negative checks reject production source drift and archive inclusion.
- `hardware-host`: local namespace fixed, but Watch currentEntitlements remains
  empty after switching from Sandbox; network error still generic.
- `hardware-isolated-start`: build rejected by parity guard due to a wrong source
  reference; corrected rather than bypassing the guard.
- `hardware-isolated-start-v2`: guarded inert host still reproduces hardware failures.
- `rich-error`: wrong generated manifest filename, no tests; corrected next run.
- `rich-error-run`: diagnostic reached existing Sandbox ownership, not Xcode;
  **not coverage**. This prompted the explicit environment guard now in every test.
- Complete clean `make milestone ID=M08`: **exit 0, 387/387 passed**, zero failed,
  skipped or expected failures. 328 unit/policy + 4 StoreKit + 55 UI tests.
  xcresult expanded device count is 731/731 (parameterized runs); 387 is the
  logical test count used by the gate.
  Candidate `1f9b96c78a1f09470d6b7e574d19a55f1c71f816`; clean main.
  UTC 2026-10-21T22:09:15Z to 22:53:06Z; Xcode 27.0 (27A266a).
  Report `.artifacts/milestone/M08/20261021T220913Z-80382/report.md`;
  result `milestone.xcresult` in the same directory.
- Physical `hardware-xcode271-ready`: **exit 65, 3 passed / 1 failed / 0 skipped**,
  UTC 2026-10-22T07:20:06Z to 07:20:24Z, same candidate sources.
  Xcode 27.1 (27A9275), CoreDevice 651.13.5, Ultra 3 watchOS 27.0.1 (24R365).
  `hardware-xcode271-ready-summary.json` and `.xcresult` retain the result.
  Only the synthetic network-error message assertion fails (`failed` vs `offline`).
  Purchase/fresh-owner restore/refund/price, pending approval, and unverified
  rejection pass; no additional assertion fails in the network scenario.
- Earlier 27.0 `hardware-after-reboot` and `hardware-clean-config`: same 3/4.
  Direct Product.purchase probes lose injected URLError details as unknown even
  with verified Xcode identity. Four richer errors and Xcode-authored schema 6.3
  configuration reproduce it; logs report ASDServerErrorDomain 511. This is an
  observed tool/runtime incompatibility, not an Apple-confirmed diagnosis.
- Xcode 27.1 installed via Mac App Store; required components installed successfully
  and `xcodebuild -checkFirstLaunchStatus` subsequently exits 0. Initial readiness
  exit 69 and an asleep-Watch run with zero tests are not passes. Prior Xcode 27.0
  retained in `/private/tmp/padel-xcode27-backup/Xcode.app`.
- Release archive/build exit 0; inspection finds no test host, test bundles,
  StoreKit configuration/test link or debug override symbols. See
  `release-archive.log`, `release-inspection.json`, `normal271-release-build.log`.

Exact final physical command (log/result prefix under `.artifacts/M08-local-repair/`):

```sh
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS,id=00008310-000823642660E01E' -destination-timeout 30 -derivedDataPath /private/tmp/padel-m08-xcode271 -resultBundlePath .artifacts/M08-local-repair/hardware-xcode271-ready.xcresult -only-testing:PadelScoreStoreKitTests -parallel-testing-enabled NO -collect-test-diagnostics never -test-timeouts-enabled YES -default-test-execution-time-allowance 60 -maximum-test-execution-time-allowance 60 DEVELOPMENT_TEAM=WW8JPY8B94 test
```

## Owner-approved physical coverage change

On 2026-10-22 the owner explicitly approved: keep the original synthetic network
scenario on the simulator, replace hardware error injection with real offline
access/relaunch. All test source/assertions and the full gate remain unchanged.
The previous physical 3/4 run remains a failed run. Other physical purchase,
restore, refund, pending and unverified coverage is retained. No mapping of
unknown errors to offline is added. Real offline acceptance remains pending.

The ordinary Release app (same production source, no debug unlock) is being
installed outside the Xcode StoreKit session. Online Access must show Unlocked;
all Watch network routes must then be disabled, including paired-phone routing.
After a cold relaunch, Access must still show Unlocked and permit a game; after
reconnection access must remain. This requires the owner's physical actions
because disabling every route also disconnects automation.

## Tests

Self-review checks that shipping sources are unchanged, original scenario bodies
match byte-for-byte after accounting for `await environment()`, and that only
local targets compile the moved test. Build guard checks the real project graph
and fails on drift. New targets are excluded from run/profile/analyze/archive.
No skipped check, mocked purchase, private API, unknown-as-offline mapping or
transaction-history fallback is accepted as a pass. Not an independent audit.

## Device preparation and data preservation

The test-only `com.dziachenka.padelscore` host was removed, then the ordinary
shipping app was reinstalled as Release using Xcode 27.1 outside a StoreKit test
launch. This uses the owner's existing reinstall/restore authorization. The new
Release binary contains no DebugPremiumOverride/forcePremium symbols. Build,
uninstall, install and restore commands/results are preserved in this repair's
artifact directory. Some connection attempts failed with CoreDevice 4000; retries
completed and failures remain logged rather than counted as successful actions.

Fresh complete backup: `/private/tmp/padel-m08-repair-final-backup`.
Restoration payload preserves Documents, temporary game stores, Application Support
and preferences. Readback: `/private/tmp/padel-m08-repair-restored-check`.
`restored-release-hashes.json` proves **3/3 game files identical**, including their
usage ledgers. These were the existing synthetic UI-test stores; no ordinary
Session repository was present before the test. No entitlement was fabricated.

Before disabling connections, the owner opened the ordinary Release app's
About → Access and reported **Unlocked** (2026-10-22 around 07:31 UTC).
This is an online preparation observation, not yet the offline result.
During the requested radio-off/reboot check, `offline-device-snapshot.json` records
this physical Watch as unavailable to CoreDevice. This corroborates loss of the
Mac connection; only the owner's on-device observations can establish offline
Unlocked, game creation/scoring and later reconnection. Those remain pending.

## Known issues

The local hardware service loses the injected network error type with Xcode 27.0
and 27.1. Required real offline coverage is pending under the explicitly approved
plan. No beta OS update or App Store submission was performed.

## Next step

Complete and record the real Watch offline/relaunch/reconnection check. Preserve
all saved game files and remove the diagnostic host. Only then may M08 be DONE;
run documentation validation and continuity against the passing candidate.
