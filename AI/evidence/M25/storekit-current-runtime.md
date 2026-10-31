# Current-runtime StoreKit compatibility probe

This additional iOS27 probe is **FAILED**, not an accepted passing component.
The unchanged declared `make milestone ID=M25` gate remains required on its
configured Watch26.1 and phone17 environments. No test expectation, assertion,
native audit category, result parser or required gate was modified for this probe.

| Input | Candidate | Baseline |
| --- | --- | --- |
| SHA | 2a297d05f66ea8b8449cb1021c459808a7e3bafa | be4ef5a1554a54bac1d5ccd7cb4188c013e62406 |
| Command | bash .artifacts/M25/runtime-profile.sh phone-current-clean run bash .artifacts/M25/run-current-unit-final.sh phone-current-unit-final | bash .artifacts/M25/runtime-profile.sh phone-current-clean run bash .artifacts/M25/run-baseline-all.sh |
| Exit | 65 | 65 |
| Native definitions | 19 passed / 21 total; 2 failed | 19 passed / 21 total; 2 failed |
| Native invocations | 28 passed / 30 total; 2 failed | 28 passed / 30 total; 2 failed |
| Skipped / expected / runtime warnings | 0 / 0 / 0 | 0 / 0 / 0 |
| Bundle | .artifacts/M25/phone-current-unit-final.xcresult | .artifacts/M25/phone-storekit-baseline-all.xcresult |

Both execute the same full `xcodebuild test -quiet -project
App/PadelScore.xcodeproj -scheme PadelScorePhoneUnit -configuration Debug` scope,
without a test filter, on the same managed iPhone17ProMax/iOS27.0/24A434,
53FFFA81-4A4C-4257-BD1D-1C4C59AEA96C, Xcode27.1/27A9275. Artifact and isolated
DerivedData paths differ to preserve evidence and avoid sharing build caches.
The baseline ran in a clean detached bounded-experiment checkout, never milestone
implementation or verification. Results were copied to the primary artifacts
before that temporary checkout was removed. Primary main was never switched.
Exact native times, failures and device configuration are retained in
[candidate summary](storekit-current-summary.json) and
[baseline summary](storekit-baseline-summary.json).

The identical failures are:

- `testNetworkFailureKeepsVerifiedOfflineAccessAndRestoreRemainsAvailable`:
  `.failed` instead of `.offline`. A separate diagnostic forwards the actual
  client error unchanged: injected network failure arrives as
  `StoreKitError.unknown`, bridged domain `StoreKit.StoreKitError`, code2, with no
  underlying NSError. The generic retry message accurately represents that error;
  classifying every unknown error as offline would fabricate a cause.
- `testPriceFollowsUSAndGermanStorefronts`: the SDK's `Storefront.current` remains
  USA after the synthetic DEU override. The preceding native Product currency and
  display-price checks pass in both USD and EUR. Shipping code uses Apple's
  Product.displayPrice and does not read Storefront.current.

These are P2 compatibility-probe discrepancies reproduced at the baseline, with
no wrong entitlement, price formatting or M25 source regression demonstrated.
Verified purchase, restore, refund/revocation, unverified handling and free-to-paid
rights otherwise pass in this native probe. They are not a release waiver or a
claim that the failed probe passed. M29 still owns actual current-device StoreKit,
lossy-network, storefront, restore and revocation observations before readiness.

Initial current attempts instead waited at a native Apple Account sign-in sheet;
only our named xcodebuild processes were interrupted, with raw exits75 retained.
After an owned device restart, purchases returned and the bounded failures above
became observable. No credentials were entered. The owner reports Simulator
cleanup during this period; cause is therefore recorded as this observed test
environment, not a universal Apple SDK defect. All relevant managed bindings were
read back intact. A temporary Run-scheme experiment and test-only diagnostics were
removed; the production StoreKit client, entitlement logic and original unit tests
are byte-identical to the baseline. No global service restart or erase occurred.
