# Integration verification

**Generated:** 20261023T134109Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Verified source:** `/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.3tOBpV28WB/source` (read-only candidate worktree)
**Mode:** product
**HEAD:** `b6cbb53163027283e8466b97b0f35e67b8ae62f4`
**Branch:** main

**Gate:** integration
**Policy version:** solo-workflow/2
**CANDIDATE_COMMIT:** `b6cbb53163027283e8466b97b0f35e67b8ae62f4`
**Candidate source:** detached read-only worktree materialised from the candidate commit

**App platform:** watchOS
**Simulator UDID:** A7CBB23C-F823-4850-BE4B-CAD76922DD08
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug launcher:** WidgetKit extension embedded; version/build/platform match; test hosts absent
**Debug Watch app:** com.dziachenka.padelscore.watchkitapp 1.0 (1)
**Debug packaging container:** com.dziachenka.padelscore 1.0 (1)
## Checks performed

| Check | Result |
| --- | --- |
| Candidate source immutable | passed |
| Static verification | passed |
| Debug build | passed |
| Complete test suite | complete suite: total=510 passed=510 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** every test in scheme `PadelScore`, including UI tests.

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.3tOBpV28WB/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.3tOBpV28WB/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T134109Z-94630/integration.xcresult'
```

## Result

**VERIFIED_COMMIT:** `b6cbb53163027283e8466b97b0f35e67b8ae62f4`
**Verdict:** PASSED integration verification

This exact combined SHA passed integration verification. The command did
not push, publish, or contact a remote.

## Coordinator execution evidence

Exact outer command: `make integration CANDIDATE=b6cbb53163027283e8466b97b0f35e67b8ae62f4`. Exit 0. Original report: `/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T134109Z-94630/report.md`. Bundle: `/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T134109Z-94630/integration.xcresult`. Command log: `/private/tmp/padel-verified-localization-integration.log`.

Canonical counts: 510 definitions passed, 0 failed, 0 skipped, 0 expected failures. Device/configuration records 884 passed invocations, including 448 parameter runs across 74 parameterized tests. No runtime warnings or recorded test failures. Start 2026-10-23T13:41:54.329000+00:00; finish 2026-10-23T15:59:41.507000+00:00; elapsed 8267.178 s.

## Unmodified xcresulttool summary

```json
{
  "devicesAndConfigurations": [
    {
      "device": {
        "architecture": "arm64",
        "deviceId": "A7CBB23C-F823-4850-BE4B-CAD76922DD08",
        "deviceName": "iosai-padel-score-1acada2a5b10847bfaf2560f32b377e90644a8e36834e70e0bb178b50151ae99",
        "modelName": "Apple Watch SE",
        "osBuildNumber": "23S36",
        "osVersion": "26.1",
        "platform": "watchOS Simulator"
      },
      "expectedFailures": 0,
      "failedTests": 0,
      "passedTests": 884,
      "skippedTests": 0,
      "testPlanConfiguration": {
        "configurationId": "1",
        "configurationName": "Default"
      }
    }
  ],
  "environmentDescription": "PadelScore · Built with macOS 27.0.1",
  "expectedFailures": 0,
  "failedTests": 0,
  "finishTime": 1792771181.507,
  "passedTests": 510,
  "result": "Passed",
  "runtimeWarnings": [],
  "skippedTests": 0,
  "startTime": 1792762914.329,
  "statistics": [
    {
      "subtitle": "448 test runs",
      "title": "74 tests ran with dynamic parameters"
    }
  ],
  "testFailures": [],
  "title": "Test - PadelScore",
  "topInsights": [
    {
      "category": "Longest Test Runs",
      "impact": "17% of duration",
      "text": "1 longest test run with outlier durations exceeding 0.02s (three standard deviations)"
    }
  ],
  "totalTestCount": 510
}
```
