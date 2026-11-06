# M32 exact full milestone verification

**Policy status:** current
**Verified SHA:** `793268631ce273284b8bbd67b1dc0179ae9fe3f5`
**Branch / mode:** clean primary checkout, main, current-head
**Exact command:** `make milestone ID=M32`
**Exit code:** 0 (Make and verifier)
**UTC interval:** 2026-11-06T14:56:22Z–2026-11-06T21:20:58Z
**Verdict:** PASSED milestone verification; not release or submission approval
**Report:** `.artifacts/milestone/M32/20261106T145621Z-96942/report.md`
**Console:** `.artifacts/M32/milestone-corrected-full.log`

The entire unchanged gate ran fresh Watch and iPhone suites on the same clean
REVIEW/main candidate. No component reuse, test filter, parser change or earlier
milestone exception was used. The source/clean-tree check at completion passed.
Both Debug builds, independent Watch packaging and iPhone/embedded-Watch identity
and archive-isolation checks passed. All five xcodebuild build/test invocations
returned 0. No additional problem scanner is configured; disabled optional
analyzers are not represented as executed.

The exact outer shell invocation first ran `make clean-derived-data`, exit 0,
then `make milestone ID=M32`, exit 0, joined with `&&`. The cleanup only removed
the owned default build cache. Its log is
`.artifacts/M32/cache-clean-before-corrected-gate.log`.

## Native results

| Component | Passed definitions | Invocations | Failed/skipped/expected/runtime warnings | Native UTC interval |
| --- | ---: | ---: | --- | --- |
| watch | 650/650 | 1104 | 0/0/0/0 | 2026-11-06T14:57:08.092000Z–2026-11-06T18:57:21.293000Z |
| phone-unit | 21/21 | 30 | 0/0/0/0 | 2026-11-06T18:57:47.937000Z–2026-11-06T18:58:11.189000Z |
| phone-ui | 22/22 | 22 | 0/0/0/0 | 2026-11-06T18:58:15.727000Z–2026-11-06T21:20:48.600000Z |
| Aggregate | 693/693 | 1156 | 0/0/0/0 | All three complete bundles |

Every invocation leaf is Passed, including parameterized runs. Read-only native
export/leaf validation exited 0 with the exact command:

```sh
bash .artifacts/M32/collect-final-results.sh > .artifacts/M32/full-native-counts-export.log 2>&1
```

The collector requires the successful full report and exact verified SHA, then runs
the existing read-only exporter over all three fresh bundles:

```sh
python3 .artifacts/M25/export-results.py .artifacts/M32/full-native-counts watch=.artifacts/milestone/M32/20261106T145621Z-96942/milestone.xcresult phone-unit=.artifacts/milestone/M32/20261106T145621Z-96942/companion/unit.xcresult phone-ui=.artifacts/milestone/M32/20261106T145621Z-96942/companion/ui.xcresult
```

Native summaries, test trees, leaf results and counts are in
`.artifacts/M32/full-native-counts/`. Watch uses owned SE40mm/watchOS26.1,
`A7CBB23C-F823-4850-BE4B-CAD76922DD08`; phone uses owned SE3/iOS17,
`B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2`.

## Other evidence and limits

[Development and self-review](development.md) records scoring/state coverage,
compact Watch and long-name inspection, all thirteen app locales, Always On,
phone appearances, and actual failures followed by corrections. The full phone
run now passes the unchanged six-category native boundary audit in both themes,
including server-side speech across pending service, confirmation and Undo.
The long-name failure and the earlier phone accessibility failure remain failed
historical results; neither is counted in the accepted components above.

The original full runs on 125d807 remain FAILED: packaging-cache contamination,
then a new phone recovery accessibility finding followed by explicit interruption
of obsolete remaining UI work. The optional Watch-reuse proposal was never
accepted or applied; the current full pass makes that proposal obsolete.

Final material capture source is `424a7e2019d4d033e92866ab00819f94d477bc86`,
with the same shipping inputs as this candidate. Complete Watch 14/14 and phone 2/2
captures, strict import/composition/provenance/site checks passed for 112 Watch+
98 phone native originals, 28 creatives, 14 Store locales and 104 local web copies.
These are fresh captures on their recorded source, not relabelled gate results.
Exact commands and paths are in the development record. No public site deployment.

[ASC readback and monitor hold](asc-withdrawal.md) records the owner-withdrawn
build 7, DEVELOPER_REJECTED app, COMPLETE submission and READY_TO_SUBMIT IAP.
The existing monitor cannot start the withdrawn build's promotion. No resubmission.

Fresh physical VoiceOver/readability acceptance and new release readiness belong
to M33 before release. This is Builder self-review and Simulator validation, not
an independent audit, physical acceptance or an App Review 4.3(a) resolution claim.
M33 remains separate and retains its complete milestone and exact-SHA release gates.

## Retained raw passing report

# Milestone M32 verification

**Generated:** 20261106T145621Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `793268631ce273284b8bbd67b1dc0179ae9fe3f5`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M32
**CANDIDATE_COMMIT:** `793268631ce273284b8bbd67b1dc0179ae9fe3f5`
**Verification mode:** current-head
**Verification started:** 20261106T145622Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M32-serve-side.md`

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
| Milestone tests | milestone tests: total=650 passed=650 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M32/20261106T145621Z-96942/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M32/20261106T145621Z-96942/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=22 passed=22 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M32/20261106T145621Z-96942/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `793268631ce273284b8bbd67b1dc0179ae9fe3f5`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261106T212058Z

## Exact companion commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhoneUnit' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M32/20261106T145621Z-96942/companion/unit.xcresult'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M32/20261106T145621Z-96942/companion/ui.xcresult'
```

## Post-DONE validation

The first DONE commit is followed by `make static`,
`./Scripts/project-status.sh validate`, and
`./Scripts/project-status.sh continuity 793268631ce273284b8bbd67b1dc0179ae9fe3f5`.
Their actual results will be recorded after execution; they are not part of the
earlier candidate's native gate. Only AI Markdown closure records follow the
verified candidate.
