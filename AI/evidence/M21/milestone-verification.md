# M21 exact-candidate verification

Verified clean REVIEW/main candidate: `9b10f99b6b96a45fc91bff736b68ff9d4df243ac`.
Session baseline: `bb182fba19662570fe8cf0490ce3d712814b9453`.

`make milestone ID=M21` exited **0**, UTC **2026-10-28T06:07:52Z–08:34:50Z**.
Both Debug builds, independent Watch/iPhone/launcher packaging guards, complete
Watch scheme, complete companion unit/UI suites and final clean-source checks
passed. No narrowed scope, omitted platform, repetition change, skipped mandatory
test or historical contrast waiver. This is Builder verification, not an
independent audit or release readiness.

## Native result bundles

All bundle paths below are under `.artifacts/milestone/M21/20261028T060751Z-15101`.

| Bundle | Definitions passed/total | Invocations | Failed | Skipped | Expected failures | Runtime warnings |
| --- | --- | --- | --- | --- | --- | --- |
| `milestone.xcresult` — Watch | 536/536 | 940 | 0 | 0 | 0 | 0 |
| `companion/unit.xcresult` — iPhone unit | 14/14 | 20 | 0 | 0 | 0 | 0 |
| `companion/ui.xcresult` — iPhone UI | 6/6 | 6 | 0 | 0 | 0 | 0 |

Aggregate: **556 definitions / 966 invocations**. Watch includes 413 Swift Testing
definitions / 817 invocations, 5 StoreKit cases and 118 UI cases, including all existing
localized journeys. Both native iPhone contrast audits pass. Native summaries:
`.artifacts/M21/final-watch-summary.json`, `final-phone-unit-summary.json` and
`final-phone-ui-summary.json`. All results are Passed; runtime warning arrays empty.

UTC native intervals, all 2026-10-28:

- Watch:06:08:32.980–08:29:15.045.
- iPhone unit:08:29:45.949–08:29:52.098.
- iPhone UI:08:29:53.906–08:34:48.727.

Managed WatchSE/watchOS26.1 and iPhoneSE3/iOS17.0 UDIDs are retained in the original
report. Gates held their checkout/device leases; no shared desktop interaction.

## Exact underlying commands

All exited 0. Original command files and logs are retained beside the report.

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M21/20261028T060751Z-15101/milestone.xcresult'
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhone' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M21/20261028T060751Z-15101/companion/ui.xcresult'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScorePhoneUnit' '-configuration' 'Debug' '-destination' 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData-companion' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M21/20261028T060751Z-15101/companion/unit.xcresult'
```

## Coverage and measurement

The 13 new definitions/22 invocations cover change/remove/insert under every deuce
mode; game/set/tie-break replay; multiple explicit serving clarifications; checkpoints,
stale revision/identity, repeated edits and inserted IDs; cancel/no publication;
all write faults/retry/reopen; manual finish/resume/timestamps; Americano draw,
partial service block, overflow, completion/Undo and once-per-game usage; corrupted
patch/snapshot disagreement; old archive boundaries; and 4000-rally retention.
The existing 400 Watch definitions and all prior UI/StoreKit/phone tests remain.
The companion source-graph tooling suite now runs 7 checks, including a mutation
that removes the shared replay file from both phone production/test-host phases.

Final gate measurement: 4000-rally pure preview plus apply **0.016634106636047363s**,
encoded session **1,945,791 bytes**. Every later winner/ID remains, journal grows by
one flat correction event, roundtrip is exact and storage growth stays below 10%.
This is a Simulator measurement, not physical-Watch latency. No journal cap or
truncation. New physical-device recovery experience remains owned by M25.

## Earlier attempts and correction

First clean REVIEW candidate `822b97bc0497d2f6094cbbdf3066be738680960b` ran the same
unchanged full command and failed overall: **Make 2 / verifier 1 / companion build 65**.
Its Watch phase passed 536 definitions/940 invocations with zero failures/skips/
expected/runtime warnings; iPhone tests were not reached, not passed.
Report: `.artifacts/milestone/M21/20261027T232244Z-23664/report.md`.
The iPhone sources omitted `RallyCorrection.swift`, causing unresolved types and
extensions. This was caused by this milestone, not claimed pre-existing.

Both missing iPhone source memberships were added. A new static completeness guard
failed before repair (exit 1) and passes after repair. The unchanged old host-parity
and package tests remain; the 7-case tooling suite passes. Direct corrected iPhone
Debug/package, unit 14/20 and UI 6/6 runs passed 0 before the new clean candidate.
Those mutable runs and first-candidate Watch passes were not reused as final
verification. The full new-candidate command above ran again and passed.

Development fixture mistakes, their corrections, commands and raw result paths are
preserved in [self-review.md](self-review.md). No failed run is called a pass, no
assertion or test was weakened. Only the owned disposable Watch build cache was
cleared before each complete gate, to remove hosted test-bundle residue; all
`.artifacts/` evidence remains. Xcode SDK/debugger metadata console messages are
recorded separately from native runtime warnings; no application failure is inferred.
Optional SwiftLint/SwiftFormat/ShellCheck are configured off, not claimed run.
No additional problem scanner is configured beyond `make static`.

## Limits and scope

Competitor correction-flow equivalence remains **unknown**, as the approved plan
allows when native access is unavailable; exact version/date/access evidence is in
[competitor-check.md](competitor-check.md). No absence or uniqueness claim.
No new user-facing UI or copy in M21; M22 owns Watch presentation. No new review
submission, upload, pricing/Promotional Text change or release-readiness verdict.
No blocking M21 self-review finding remains.

## Original passing gate report

Report: `.artifacts/milestone/M21/20261028T060751Z-15101/report.md`. Retained verbatim below.

---

# Milestone M21 verification

**Generated:** 20261028T060751Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `9b10f99b6b96a45fc91bff736b68ff9d4df243ac`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M21
**CANDIDATE_COMMIT:** `9b10f99b6b96a45fc91bff736b68ff9d4df243ac`
**Verification mode:** current-head
**Verification started:** 20261028T060752Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M21-selective-replay.md`

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
| Milestone tests | milestone tests: total=536 passed=536 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M21/20261028T060751Z-15101/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** 51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=14 passed=14 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M21/20261028T060751Z-15101/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=6 passed=6 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M21/20261028T060751Z-15101/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `9b10f99b6b96a45fc91bff736b68ff9d4df243ac`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261028T083450Z
