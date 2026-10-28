# M22 exact milestone verification

Clean REVIEW/main candidate `b52ea03978bc63664f2b43289fb950bf5d44c611` ran **`make milestone ID=M22`**, **exit 0**.
UTC start `20261028T112312Z`, completion `20261028T140420Z`. Raw verdict **PASSED milestone
verification**. Report `.artifacts/milestone/M22/20261028T112311Z-88354/report.md`; exact xcodebuild commands and owned
simulator identities are preserved verbatim below. Both Debug builds and the
independent Watch/companion/launcher package guards passed. Static includes source
membership, unchanged localization policy and site/material provenance checks.

| Bundle | Passed definitions | Invocations | Failed | Skipped | Expected | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| Watch | 551/551 | 955 | 0 | 0 | 0 | 0 |
| iPhone unit | 14/14 | 20 | 0 | 0 | 0 | 0 |
| iPhone UI | 6/6 | 6 | 0 | 0 | 0 | 0 |

Aggregate: **571 definitions / 981 invocations**, zero failed/skipped/expected/
runtime warnings. Result bundles:

- `.artifacts/milestone/M22/20261028T112311Z-88354/milestone.xcresult` — Watch.
- `.artifacts/milestone/M22/20261028T112311Z-88354/companion/unit.xcresult` — iPhone unit.
- `.artifacts/milestone/M22/20261028T112311Z-88354/companion/ui.xcresult` — iPhone UI.

JSON summaries are `.artifacts/M22/final-watch-summary.json`,
`final-phone-unit-summary.json` and `final-phone-ui-summary.json`. Native test
counts, rather than console text, determine success. No test filter, retry,
assertion, native accessibility category, result parser or contrast check was
weakened. Historical M16–M18 exceptions do not apply.

## Additional runtime and review evidence

Corrected source `f73955ad954661090a75e9f4daada906e088ba71` has identical
App/Config/Scripts inputs to this verified candidate. `bash
.artifacts/M22/run-minimum.sh` exited 0 on owned Watch SE 40mm/watchOS 10.0:
15/15 definitions/invocations, six Journal unit and all nine Journal UI cases,
zero failed/skipped/expected/runtime warnings. Bundle
`.artifacts/M22/minimum-background-final.xcresult`; exact UTC times, summaries,
frozen trees and the reused XCTest runner compatibility environment are in
`AI/evidence/M22/lifecycle.md`. The before-fix background regression fails 1/1;
the corrected same assertion passes 1/1, then the whole 15-case set and this full
gate pass. Original 14-case presentation evidence and captures remain in runtime.md.

Builder self-review: `AI/evidence/M22/self-review.md`; mutable failures:
`development.md`; interrupted first full candidate and lifecycle correction:
`lifecycle.md`. The first candidate's cancelled FAILED verdict and raw counts are
retained, never relabelled as a pass. No pre-existing failure claim or waiver.

Runtime touch journeys cover all three edits, cancel, revision-bound apply,
explicit serving, save failure/retry/relaunch, result Undo, archived and unknown
legacy detail, empty insertion, native accessibility audits, largest text,
4000-rally scrolling and partial/complete drafts across background. The final
background capture is
`.artifacts/M22/minimum-background-final-attachments/819168A2-EC58-419C-942C-7C4753E55B53.png`.
Native typography and graphite/lime rows remain; no new animation or asset earned
its place in this careful review flow. All 39 new strings ship in 13 locales and
pass the unchanged verifier. No additional problem scanner is configured beyond
static's checks; optional analyzers remain disabled by existing configuration.

M25 owns fresh physical-device/VoiceOver/haptic and all-locale six-domain evidence;
none is falsely claimed here. This is Builder verification, not independent review,
release approval or App Store submission. Existing 4.3(a) rejection/reply hold remain;
no upload, submission, price, Promotional Text or public-release action occurred.

## Raw successful gate report

# Milestone M22 verification

**Generated:** 20261028T112311Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `b52ea03978bc63664f2b43289fb950bf5d44c611`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M22
**CANDIDATE_COMMIT:** `b52ea03978bc63664f2b43289fb950bf5d44c611`
**Verification mode:** current-head
**Verification started:** 20261028T112312Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M22-watch-journal.md`

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
| Milestone tests | milestone tests: total=551 passed=551 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M22/20261028T112311Z-88354/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** 51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=14 passed=14 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M22/20261028T112311Z-88354/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=6 passed=6 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M22/20261028T112311Z-88354/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `b52ea03978bc63664f2b43289fb950bf5d44c611`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261028T140420Z
