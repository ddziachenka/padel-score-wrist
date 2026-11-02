# M31 verification — owner-directed impact completion

Verified native/impact source: `cb6bc1243e49cd51f1817d1d263e09e9028a7fe9`.
The [explicit owner decision](owner-impact-verification-authorization.md) replaces
duplicate unaffected Debug runs with source-bound reuse, retaining all real Release,
package, signature and submission checks. The raw full `make milestone ID=M31` at
`0c2dab8d17f3212e3c426d715fd1297d57cb021c` remains **FAILED**, make2/verifier1/UI65;
its report is `.artifacts/milestone/M31/20261102T113829Z-42676/report.md`.

## Actual fresh native validation

```sh
python3 .artifacts/M31/phone-audit-diagnosis/snapshot-state-correction/run.py --candidate cb6bc1243e49cd51f1817d1d263e09e9028a7fe9 --run
```

The one fixed run closed19:40:18.805743Z(start19:29:15.431191Z): wrapper/native/
effective exits0, unchanged clean source. Bundle/receipt/actual xcodebuild argv:
`.artifacts/M31/phone-audit-diagnosis/snapshot-state-correction/run-r48w6z0h/`.
Selectors are `testKnownScoreRealInputPreviewCancelScoreUndoAndRelaunch` and
`testKnownScoreSetBoundaryRequiresServingAndExactUndo`, with fixed5 iterations.
Actual order: control1–5, boundary1–5. Native2definitions/10invocations **all Passed**,
zero skipped/expected failures/runtime warnings; both appearances and all six
categories verified in each boundary invocation. The [snapshot correction](native-audit-snapshot-correction.md)
preserves original assertions/viewport/issue handling and public API boundaries.
Earlier full/focused failures, including02d8's two crashes, remain preserved.

## Exact accepted coverage

```sh
python3 .artifacts/M31/impact-reuse-policy/prepare-manifest.py --consumer cb6bc1243e49cd51f1817d1d263e09e9028a7fe9 --pair .artifacts/M31/phone-audit-diagnosis/snapshot-state-correction/run-r48w6z0h --output .artifacts/M31/impact-reuse-policy/coverage-manifest-cb6bc124.json
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M31/impact-reuse-policy/validate-coverage.py --manifest .artifacts/M31/impact-reuse-policy/coverage-manifest-cb6bc124.json --output .artifacts/M31/impact-reuse-policy/coverage-result-cb6bc124-direct-python.json
```

Both commands exited0. Validator outcome **IMPACT_COVERAGE_VERIFIED** at
19:42:52.292098Z, no pending cases,70 hash-bound inputs and43 recorded read-only
commands. Exact source/configuration/dependency, native runtime, Xcode/SDK and
immutable original build-metadata continuity are checked; no fabricated historical
compiler binary hash is claimed. All phone results use iOS17.0(21A328)/SDK27.1.

- Reused:640 Watch definitions/1092 invocations,21 phone-unit/30,19 other UI/19.
- Fresh:2 definitions/10 invocations; unique union682definitions(680reused+2fresh).
- Normalized required invocation coverage1143; actual evidence invocations1151.
- Manifest SHA256:`70b28de6dd1cf54780bbbb775d3a1a4fc4c35ae5f07f7e2ef3678f7765a9c540`.
- Result SHA256:`696bb9174adfe72d8d7ce8226c49f364ed292e5a503ed5e40ebc17ef49c85de6`.

The first sandbox native-export attempt exited1 due to TestReport cache permissions;
authorized read-only elevated export succeeded. The first validator exited65 because
`/usr/bin/python3` injects MacSDKROOT despite an unset shell environment. Direct
Xcode Python had no overrides; the unchanged validator passed. Both failures remain
recorded; `sdkroot-launcher-review-cb6bc124.json` documents actual SDK identities.
No native rerun, skipped check, warning suppression or validator relaxation occurred.

Current cb6 `make static`, status and continuity checks exited0; receipts reside in
`.artifacts/M31/snapshot-correction-static-cb6bc12/`. Six Builder-reviewed domain
records cover128 rows, no known open product P0/P1. Final closure commit and its
post-installation checks are recorded by the owning Builder. Future AI-only consumer
commits require new immutable manifests; existing inputs/contracts remain frozen.
M29 physical acceptance, unavailable metrics/video and all historical diagnostic
limits remain intact. This evidence is neither a fullmakePASS nor App Store approval.
