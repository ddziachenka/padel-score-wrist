# Integration verification

**Generated:** 20261023T161644Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Verified source:** `/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.Y3BE1odp7b/source` (read-only candidate worktree)
**Mode:** product
**HEAD:** `8dd50d72b04689da93bfaed2599eb28bd26e3591`
**Branch:** main

**Gate:** integration
**Policy version:** solo-workflow/2
**CANDIDATE_COMMIT:** `8dd50d72b04689da93bfaed2599eb28bd26e3591`
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
'xcodebuild' 'build' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.Y3BE1odp7b/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-integration-candidate.Y3BE1odp7b/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T161643Z-52611/integration.xcresult'
```

## Result

**VERIFIED_COMMIT:** `8dd50d72b04689da93bfaed2599eb28bd26e3591`
**Verdict:** PASSED integration verification

This exact combined SHA passed integration verification. The command did
not push, publish, or contact a remote.

## Coordinator execution evidence

Exact outer command: `make integration CANDIDATE=8dd50d72b04689da93bfaed2599eb28bd26e3591`. Exit 0. Original report: `/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T161643Z-52611/report.md`. Bundle: `/Users/Shared/D/ios/padel-score/.artifacts/integration/20261023T161643Z-52611/integration.xcresult`. Command log: `/private/tmp/padel-danish-final-integration.log`.

Canonical counts: 510 definitions passed, 0 failed/skipped/expected; 884 passed device invocations, including 448 parameter runs across 74 parameterized tests. Runtime warnings: 0. Start 2026-10-23T16:17:17.887000+00:00; finish 2026-10-23T18:35:09.925000+00:00; elapsed 8272.038 s.

This is the final exact gate after four Danish banner corrections. Previous b6cbb53163027283e8466b97b0f35e67b8ae62f4 report is retained separately in integration.md. No publication, upload, App Review submission or release readiness is implied.

## Unmodified xcresulttool summary

```json
{
  "devicesAndConfigurations" : [
    {
      "device" : {
        "architecture" : "arm64",
        "deviceId" : "A7CBB23C-F823-4850-BE4B-CAD76922DD08",
        "deviceName" : "iosai-padel-score-1acada2a5b10847bfaf2560f32b377e90644a8e36834e70e0bb178b50151ae99",
        "modelName" : "Apple Watch SE",
        "osBuildNumber" : "23S36",
        "osVersion" : "26.1",
        "platform" : "watchOS Simulator"
      },
      "expectedFailures" : 0,
      "failedTests" : 0,
      "passedTests" : 884,
      "skippedTests" : 0,
      "testPlanConfiguration" : {
        "configurationId" : "1",
        "configurationName" : "Default"
      }
    }
  ],
  "environmentDescription" : "PadelScore · Built with macOS 27.0.1",
  "expectedFailures" : 0,
  "failedTests" : 0,
  "finishTime" : 1792780509.925,
  "passedTests" : 510,
  "result" : "Passed",
  "runtimeWarnings" : [

  ],
  "skippedTests" : 0,
  "startTime" : 1792772237.887,
  "statistics" : [
    {
      "subtitle" : "448 test runs",
      "title" : "74 tests ran with dynamic parameters"
    }
  ],
  "testFailures" : [

  ],
  "title" : "Test - PadelScore",
  "topInsights" : [
    {
      "category" : "Longest Test Runs",
      "impact" : "17% of duration",
      "text" : "1 longest test run with outlier durations exceeding 0.03s (three standard deviations)"
    }
  ],
  "totalTestCount" : 510
}

```
