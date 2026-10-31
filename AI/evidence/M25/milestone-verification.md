# M25 exact component verification under owner exception

M25 is DONE under the explicit M25-only owner exception. Verified candidate
`5eb65bbc17e9540d3922a520b44d3c8731947432`: watch 635/635 definitions/1085 invocations; phone-unit 21/21 definitions/30 invocations; phone-ui 21/21 definitions/21 invocations.
Aggregate 677 definitions/1136 invocations, zero failed/skipped/
expected/native runtime warnings in the accepted components. Both Debug/package
guards pass. Complete new phone command `bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`, exit0,
UTC2026-10-31T14:27:08Z–2026-10-31T16:45:19Z; report `.artifacts/M25/phone-complete-same-candidate/report.md`.
The Watch component is from `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult` at exactly the same SHA.
The complete monolithic make remains FAILED/exit130, never relabelled passed.
See [owner authorization](owner-verification-exception.md) and
[exact verification](milestone-verification.md). All physical checks remain M29.


| Component | Passed definitions | Invocations | Failed | Skipped | Expected | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| watch | 635/635 | 1085 | 0 | 0 | 0 | 0 |
| phone-unit | 21/21 | 30 | 0 | 0 | 0 | 0 |
| phone-ui | 21/21 | 21 | 0 | 0 | 0 | 0 |

Counts are from completed native summaries AND every invocation leaf, using
`.artifacts/M25/export-results.py`, exit0. Combined raw counts:
`.artifacts/M25/same-candidate-component-counts.json`. Bundles:

- `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult`
- `.artifacts/M25/phone-complete-same-candidate/companion/unit.xcresult`
- `.artifacts/M25/phone-complete-same-candidate/companion/ui.xcresult`

Watch native command is recorded in the retained full report below; the complete
new phone command is `bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`, exit0, report `.artifacts/M25/phone-complete-same-candidate/report.md`.
Source App/Config/Scripts equals reviewed implementation `4720028cffdabc4082385506578f8af25c61450d`.
All images, provenance JSON and site drafts were committed before verification.
Only AI/**/*.md continuity records follow the verified SHA.

Current-source supplements: fresh minimum phone4/4; minimum Watch492/942;
current Watch498/948; whole current phone UI20/20; Watch gallery14/14 and phone
gallery2/2; bounded current traversal regression1/1. All accepted results have
zero adverse native counts; exact source/time/device/commands in runtime.md and
native-supplements.json. Strict material/site/identity checks and all42 visual
contact reviews pass.210 native originals and28 explanatory compositions cover
14ASC locales. ASC Data Not Collected/read-only52URL checks and all local drafts
are described in materials-review.md; nothing published/uploaded/submitted.

Additional current-runtime StoreKit probe remains FAILED/P2,19/21 definitions,
28/30 invocations, identically reproduced at the baseline; never counted passed.
All physical scenarios remain [M29](M29-hardware-inventory.md). Six records are
completed digital Builder records, not independent review or final release
approval. No additional scanner is configured; disabled optional analyzers are
not claimed run. Post-DONE logs: .artifacts/M25/post-done-{static,status,continuity}.log.

## Exact complete new phone commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/M25/phone-complete-same-candidate/companion/ui.xcresult'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhoneUnit' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/M25/phone-complete-same-candidate/companion/unit.xcresult'
```

## Raw successful complete phone report

# M25 complete iPhone verification — same unchanged candidate

**Generated:** 20261031T142708Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `5eb65bbc17e9540d3922a520b44d3c8731947432`
**Branch:** main

**Scope:** complete Debug/packaging/unit/UI iPhone verification using unchanged verify_companion_profile milestone.
**Limit:** not a passing full make milestone command; no verification exception or DONE is asserted.
**Candidate:** 5eb65bbc17e9540d3922a520b44d3c8731947432
**Procedure SHA256:** a47e80c41502eb6767e7ea1356c5b689d3037705dab07a479eac41526875b6f6
**Started:** 2026-10-31T14:27:08Z
**make static:** passed, exit0.
**App platform:** iOS
**Simulator UDID:** B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/M25/phone-complete-same-candidate/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/M25/phone-complete-same-candidate/companion/ui.xcresult
**Finished:** 2026-10-31T16:45:19Z
**Candidate continuity:** unchanged clean HEAD 5eb65bbc17e9540d3922a520b44d3c8731947432.
**Verdict:** PASSED complete iPhone verification only.


## Retained original monolithic FAILED report

# Milestone M25 verification

**Generated:** 20261031T083305Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `5eb65bbc17e9540d3922a520b44d3c8731947432`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M25
**CANDIDATE_COMMIT:** `5eb65bbc17e9540d3922a520b44d3c8731947432`
**Verification mode:** current-head
**Verification started:** 20261031T083306Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M25-recovery-experience-review.md`

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
| Milestone tests | milestone tests: total=635 passed=635 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M25/20261031T083305Z-38339/companion/unit.xcresult

## Result

**Verdict:** FAILED (exit 130; the console output states the reason)
