# M20 exact-candidate verification

Verified clean REVIEW/main candidate: `98a0502e84453d66904cf13654d92850641ed497`.
Baseline: `d914d36fec5d03c4f1e5b915eafa642ea9f29eaf`.

`make milestone ID=M20` exited **0**. Both Debug builds, both packaging guards,
all three complete test commands and the final source/cleanliness check passed.
No test scope, parser, assertion, repetition setting or historical waiver changed.
This is milestone evidence, not release readiness or independent review.

## Native result bundles

| Bundle (under the report directory) | Definitions passed/total | Invocations | Failed | Skipped | Expected failures | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| `milestone.xcresult` — Watch | 523/523 | 918 | 0 | 0 | 0 | 0 |
| `companion/unit.xcresult` — iPhone unit | 14/14 | 20 | 0 | 0 | 0 | 0 |
| `companion/ui.xcresult` — iPhone UI | 6/6 | 6 | 0 | 0 | 0 | 0 |

Watch includes 400 Swift Testing definitions/795 invocations, 5 StoreKit cases,
and 118 UI cases, including every localized journey. Both existing native iPhone
contrast audits pass. Native summaries are retained as `.artifacts/M20/watch-summary.json`,
`phone-unit-summary.json` and `phone-ui-summary.json`. Their result is Passed;
all `runtimeWarnings` arrays are empty. Aggregate: 543 definitions, 944 invocations.

Gate UTC interval: **2026-10-27T20:39:05Z–2026-10-27T23:06:43Z**.
Watch tests:20:39:49.279Z–23:00:58.237Z. iPhone unit: 23:01:31.663Z–23:01:41.339Z.
iPhone UI: 23:01:42.973Z–23:06:42.004Z. All dates in this paragraph are 2026-10-27 UTC.
Owned managed UDIDs and runtimes are in the copied gate report below; gates held
the checkout/device leases. No shared desktop interaction was used.

## Additional exact companion commands

All exited0; their logs are in the report directory's `companion/` folder.

```sh
xcodebuild build -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion
xcodebuild test -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhoneUnit -configuration Debug -destination 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/milestone/M20/20261027T203904Z-88591/companion/unit.xcresult
xcodebuild test -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/milestone/M20/20261027T203904Z-88591/companion/ui.xcresult
```

## Storage measurements in this passing gate

- Ten-set Match:568 Undo steps,374233 bytes, save0.017984791s.
- Americano2000 rallies:971210 active bytes;4000:1949208 active bytes (2.007×).
- Archived4000 rallies:459659 bytes with4002 events retained and no Undo chain;
  save0.021273959s, load0.02147375s. Full roundtrip and event counts pass.

These measure the Simulator, not physical-Watch latency. No silent truncation or
arbitrary journal cap was introduced. Physical experience/upgrade evidence belongs
to M25; release validation belongs to M26.

## Earlier attempts and limitations

The first exact `make milestone ID=M20` on the same SHA stopped at the shipping
package guard: the preceding development unit run left
`PadelScoreWatch.app/PlugIns/PadelScoreWatchTests.xctest` in this checkout's build
cache. Debug build passed; tests were not reached. Make2/verifier1, report
`.artifacts/milestone/M20/20261027T203757Z-68341/report.md`, console
`.artifacts/M20/milestone-command.log`. This is session-created cache residue,
not a claimed pre-existing application failure. No baseline failure is claimed.

`Scripts/simulator.sh run -- make clean-derived-data` exited0, removing only the
owned 335 MB disposable cache, preserving all `.artifacts/` evidence. The same
unchanged candidate then passed the complete gate above. Cleanup output:
`.artifacts/M20/cache-clean.log`; final console `.artifacts/M20/milestone-command-2.log`.
Development compilation/assertion corrections and the interrupted diagnostic
collection are preserved in [self-review.md](self-review.md), not counted as passes.

No M20 blocking finding remains. The build log includes an Apple StoreKitTest SDK
header deprecation and App Intents metadata-extraction notices for targets without
that framework. Native runtime warning counts are zero. SwiftLint, SwiftFormat and
ShellCheck are configured off, not claimed run. No additional problem scanner is
configured. This milestone changes no user-facing surface and has no separate
visual craftsmanship requirement. All existing UI suites still ran.

## Original passing gate report

Report path: `.artifacts/milestone/M20/20261027T203904Z-88591/report.md`.
The report below is retained verbatim.

---

# Milestone M20 verification

**Generated:** 20261027T203904Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `98a0502e84453d66904cf13654d92850641ed497`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M20
**CANDIDATE_COMMIT:** `98a0502e84453d66904cf13654d92850641ed497`
**Verification mode:** current-head
**Verification started:** 20261027T203905Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M20-event-journal.md`

**Declared status:** REVIEW

**App platform:** watchOS
**Simulator UDID:** A7CBB23C-F823-4850-BE4B-CAD76922DD08
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug independent Watch:** verified companion ID, independent execution, executable and launcher
## Verification record

| Check | Result |
| --- | --- |
| Static verification | passed |
| Debug build | passed |
| Milestone tests | milestone tests: total=523 passed=523 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M20/20261027T203904Z-88591/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** 51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=14 passed=14 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M20/20261027T203904Z-88591/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=6 passed=6 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M20/20261027T203904Z-88591/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `98a0502e84453d66904cf13654d92850641ed497`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261027T230643Z
