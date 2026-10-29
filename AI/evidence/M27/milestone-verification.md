# M27 exact milestone verification

Clean REVIEW/main candidate `488809d6c06b29233e7c1d1f7687c9cec03bbab4` passed
**make milestone ID=M27**, **exit0**, UTC
**2026-10-29T09:23:11Z–2026-10-29T13:30:22Z**.
Raw verdict: **PASSED milestone verification**. Report:
`.artifacts/milestone/M27/20261029T092309Z-73441/report.md`.
Both Debug builds and independent Watch/launcher/companion packaging guards pass.

| Bundle | Passed definitions | Invocations | Failed | Skipped | Expected | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| Watch | 591/591 | 1013 | 0 | 0 | 0 | 0 |
| iPhone unit | 21/21 | 30 | 0 | 0 | 0 | 0 |
| iPhone UI | 13/13 | 13 | 0 | 0 | 0 | 0 |

Aggregate: **625 definitions/1056 invocations**, zero failed/skipped/expected/
runtime warnings. Counts come from native summaries/per-device configurations,
not console events. Summaries: `.artifacts/M27/final-watch-summary.json`,
`final-phone-unit-summary.json`, `final-phone-ui-summary.json`. Bundles:

- `.artifacts/milestone/M27/20261029T092309Z-73441/milestone.xcresult`
- `.artifacts/milestone/M27/20261029T092309Z-73441/companion/unit.xcresult`
- `.artifacts/milestone/M27/20261029T092309Z-73441/companion/ui.xcresult`

Final mutable-source **make fast** passed exit0,454/454 definitions/876 invocations,
zero failed/skipped/expected/runtime warnings. Report:
`.artifacts/fast/20261029T082750Z-84551/report.md`, bundle fast.xcresult there;
summary `.artifacts/M27/fast-final-summary.json`. Its reported HEAD is
`aa638e4629a711d5be5e5a0610c6d73dee0285f9`; the uncommitted corrections were then
committed as the final candidate above. This is development feedback, not clean
candidate evidence. Temporary scope included all Watch unit tests and five new UI
tests; Config/project.env was restored byte for byte before the candidate. Both
FAST_TEST_ARGUMENTS/MILESTONE_TEST_ARGUMENTS are empty at the verified candidate;
the full gate runs every test in both platforms' schemes.

Final-candidate watchOS10/27 supplements each pass exit0,454/454 definitions/
876 invocations, zero failed/skipped/expected/runtime warnings. Exact commands,
UDIDs, timestamps, bundles and captures: [runtime](runtime.md). Focused final
SessionFileTests pass exit0,21/21/57; `.artifacts/M27/schema-final.xcresult` and
schema-final-summary.json. All affected tests rerun in the complete candidate gate.

App/Config/Scripts stayed unchanged throughout final verification. No required
suite, assertion, parser, native audit category or skip policy was weakened.
[Development](development.md) retains failed/partial runs and actual outcomes;
none is called pre-existing or accepted into this pass. [Builder self-review](self-review.md)
is not independent review or release approval.

No additional scanner is configured beyond static; disabled optional SwiftLint/
SwiftFormat are not claimed as passes. One non-blocking deprecation warning comes
from Apple's StoreKitTest SDK header, SKPaymentTransactionState. AppIntents metadata
extraction reports no linked framework for these targets. These build messages
are separate from the zero native runtime warnings.

M25 owns all physical-Watch checks before M26 by explicit owner direction. They did
not pass in M27 and are not waived for release. App Review4.3(a) and unsent/on-hold
reply remain unchanged. No release gate/upload/submission/pricing/Promotional Text/
public-release action occurred.

## Raw successful gate report

# Milestone M27 verification

**Generated:** 20261029T092310Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `488809d6c06b29233e7c1d1f7687c9cec03bbab4`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M27
**CANDIDATE_COMMIT:** `488809d6c06b29233e7c1d1f7687c9cec03bbab4`
**Verification mode:** current-head
**Verification started:** 20261029T092311Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M27-player-names.md`

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
| Milestone tests | milestone tests: total=591 passed=591 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M27/20261029T092309Z-73441/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** 51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M27/20261029T092309Z-73441/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=13 passed=13 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M27/20261029T092309Z-73441/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `488809d6c06b29233e7c1d1f7687c9cec03bbab4`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261029T133022Z

## Exact companion commands

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination "platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhoneUnit -configuration Debug -destination "platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/milestone/M27/20261029T092309Z-73441/companion/unit.xcresult
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test -project /Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination "platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -resultBundlePath /Users/Shared/D/ios/padel-score/.artifacts/milestone/M27/20261029T092309Z-73441/companion/ui.xcresult
```
