# M23 exact milestone verification

Clean REVIEW/main candidate `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e` passed **`make milestone ID=M23`**, **exit 0**.
UTC `2026-10-28T16:28:52Z`–`2026-10-28T19:16:57Z`. Raw verdict **PASSED milestone verification**.
Report `.artifacts/milestone/M23/20261028T162851Z-63137/report.md`. Both Debug builds and the independent Watch/launcher/
companion packaging guards passed. Static includes unchanged localization,
source-membership, site/material and test-repetition checks.

| Bundle | Passed definitions | Invocations | Failed | Skipped | Expected | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| Watch | 568/568 | 976 | 0 | 0 | 0 | 0 |
| iPhone unit | 14/14 | 20 | 0 | 0 | 0 | 0 |
| iPhone UI | 6/6 | 6 | 0 | 0 | 0 | 0 |

Aggregate: **588 definitions / 1002 invocations**, zero failed/skipped/
expected/runtime warnings. Bundle paths:

- `.artifacts/milestone/M23/20261028T162851Z-63137/milestone.xcresult`
- `.artifacts/milestone/M23/20261028T162851Z-63137/companion/unit.xcresult`
- `.artifacts/milestone/M23/20261028T162851Z-63137/companion/ui.xcresult`

Raw JSON summaries: `.artifacts/M23/final-watch-summary.json`,
`final-phone-unit-summary.json`, `final-phone-ui-summary.json`. Counts come from
native result bundles, not console progress. Exact commands, environments and
owned simulator identities are preserved in the raw report below. No test,
assertion, native audit category, parser or required suite was weakened. No
historical contrast waiver applies.

## Targeted runtime and Builder review

Source `818c1fc59dffef164b66c4622422a8113a560753` has identical App/Config/Scripts trees to this verified
candidate (checked against `.artifacts/M23/frozen-complete-runtime.json`).
`bash .artifacts/M23/run-minimum.sh` exited0 on owned Watch SE 40mm/watchOS 10.0:
17/17 definitions / 21 invocations, zero failed/skipped/expected/runtime warnings.
Bundle `.artifacts/M23/minimum-complete-final.xcresult`; timestamps, captures and
exact command/environment: [runtime.md](runtime.md). Builder self-review:
[self-review.md](self-review.md); development and interrupted evidence:
[development.md](development.md).

Coverage includes all deuce modes, completed sets, extended tie-break/service,
Americano explicit partial-block positions, invalid/complete states, access and
once-per-game ledger, atomic failed-save retry/restart, checkpoint-limited Undo
and later selective corrections, setup-rule changes preserving score, cancellation,
background and cold-launch boundaries, largest text and all native audit categories.
All seven added strings have actual translations in thirteen supported locales;
unchanged structural localization checks and the full existing localized UI set pass.
The final copy pass corrected unavailable earlier-history detail and suppressed
ordinary-correction finish promises during invalid new-game entry, with exact UI
regressions. No blocking finding remains known. No additional scanner is configured
beyond static; existing optional analyzers remain disabled by product configuration.

The earlier clean candidate 0f337a4 gate was deliberately interrupted for that copy
correction. Its raw FAILED/Make2/verifier65/xcodebuild73 report and cancelled test
are retained in development.md, not accepted or substituted for this complete pass.
Earlier targeted runs describe only their own sources.

This is Builder verification, not independent audit or release approval. M25 owns
fresh physical-device/VoiceOver and all-locale six-domain evidence. App Review
reply remains unsent/on hold and 4.3(a) unresolved; no upload, submission, pricing,
Promotional Text or public-release action occurred.

## Raw successful gate report

# Milestone M23 verification

**Generated:** 20261028T162851Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M23
**CANDIDATE_COMMIT:** `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e`
**Verification mode:** current-head
**Verification started:** 20261028T162852Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M23-start-from-score.md`

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
| Milestone tests | milestone tests: total=568 passed=568 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M23/20261028T162851Z-63137/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** 51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=14 passed=14 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M23/20261028T162851Z-63137/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=6 passed=6 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M23/20261028T162851Z-63137/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `ec20c1f8a02fbfe640cbe18e65871e92b75e5a6e`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261028T191657Z

## Exact companion commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M23/20261028T162851Z-63137/companion/ui.xcresult'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhoneUnit' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M23/20261028T162851Z-63137/companion/unit.xcresult'
```
