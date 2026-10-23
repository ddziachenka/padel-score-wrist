# M10 release verification evidence

**Policy status:** current
**Verified SHA:** `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`
**Exact command:** `make release CANDIDATE=93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`
**Exit code:** 0
**Verdict:** READY_FOR_HUMAN
**Report:** `.artifacts/release/20261023T211900Z-47259/report.md`
**Result bundle:** `.artifacts/release/20261023T211900Z-47259/release.xcresult`
**Command log:** `.artifacts/M10-completion/release-final.log`
**Raw summary:** `.artifacts/M10-completion/release-summary.json`
**Summary extraction:** `xcrun xcresulttool get test-results summary --path .artifacts/release/20261023T211900Z-47259/release.xcresult --format json` — exit 0.

510/510 test definitions passed; 884 device invocations passed; 0 failed, skipped, expected failures or runtime warnings. 74 parameterized definitions produced 448 runs. Full scheme, no selection or exclusions.

Result-bundle start: 2026-10-23T21:19:59.568000+00:00; finish: 2026-10-23T23:37:34.828000+00:00; duration: 8255.260 seconds. Managed Watch SE 40 mm, watchOS 26.1, UDID A7CBB23C-F823-4850-BE4B-CAD76922DD08. Physical acceptance is separate owner-observed evidence in `AI/evidence/M10/device-confirmation.md`.

## Preserved gate report

# Release verification

**Generated:** 20261023T211901Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Verified source:** `/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-release-candidate.hVca0agX2k/source` (read-only candidate worktree)
**Mode:** product
**HEAD:** `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`
**Branch:** main

**Gate:** release (strictest local verification)
**Policy version:** solo-workflow/2
**CANDIDATE_COMMIT:** `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`
**Candidate source:** read-only detached worktree materialised from the candidate commit
**Distribution:** app-store
**Candidate:** 1.0 (1) 93b7d26a5d1a
**MARKETING_VERSION:** 1.0
**CURRENT_PROJECT_VERSION:** 1
**Audit coverage:** COMPLETE

**App platform:** watchOS
**Simulator UDID:** A7CBB23C-F823-4850-BE4B-CAD76922DD08
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug launcher:** WidgetKit extension embedded; version/build/platform match; test hosts absent
**Debug Watch app:** com.dziachenka.padelscore.watchkitapp 1.0 (1)
**Debug packaging container:** com.dziachenka.padelscore 1.0 (1)
**Release launcher:** WidgetKit extension embedded; version/build/platform match; test hosts absent
**Release Watch app:** com.dziachenka.padelscore.watchkitapp 1.0 (1)
**Release packaging container:** com.dziachenka.padelscore 1.0 (1)
**Human checklist:** /Users/Shared/D/ios/padel-score/.artifacts/release-checklists/93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f/checklist.md
**Pending human steps:** 3
Manual sequence: subjective review; Product > Archive and Organizer validation; developer distribution decision.
Archive this commit. A checkout that has since moved on by continuity records alone archives the same bytes, which ./Scripts/project-status.sh continuity 93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f confirms.
## Release verification

| Check | Result |
| --- | --- |
| Candidate source immutable during the run | passed |
| Final audit coverage | passed |
| Static verification | passed |
| Release configuration | passed |
| Clean Debug build | passed |
| Clean Release build, generic watchOS device, unsigned | passed |
| Complete test suite | complete suite: total=510 passed=510 failed=0 skipped=0 expectedFailures=0 |

## Exact commands

```sh
'xcodebuild' 'clean' 'build' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-release-candidate.hVca0agX2k/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'clean' 'build' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-release-candidate.hVca0agX2k/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Release' '-destination' 'generic/platform=watchOS' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' 'CODE_SIGNING_ALLOWED=NO'
'xcodebuild' 'test' '-project' '/private/var/folders/24/tn2qd0k97zj4nwg9crvj7m_h0000gn/T/iosai-release-candidate.hVca0agX2k/source/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/release/20261023T211900Z-47259/release.xcresult'
```
## Result

**VERIFIED_COMMIT:** `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`
**Audit coverage:** COMPLETE
**VERDICT:** READY_FOR_HUMAN

Nothing was archived, uploaded, submitted, pushed, or published.

## Preserved candidate-bound human checklist

# Human release checklist

**Schema:** human-release/1
**Candidate commit:** 93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f
**Candidate:** 1.0 (1) 93b7d26a5d1a
**Distribution channel:** app-store

READY_FOR_HUMAN is not publication approval. Complete these steps in order.
For VERIFIED, replace - with who=<person>; date=<UTC date>; result=<observation>.
Preserve this checklist with the release report in a committed release record.

## Human work

1. Subjective review of this candidate on a real device.
2. Product > Archive in Xcode from this candidate; validate in Organizer.
3. Developer decides whether to distribute through the configured channel.

- HUMAN-01 | OUTCOME=PENDING | EVIDENCE=-
- HUMAN-02 | OUTCOME=PENDING | EVIDENCE=-
- HUMAN-03 | OUTCOME=PENDING | EVIDENCE=-

Three PENDING rows remain unperformed by this gate. Earlier owner hardware confirmation satisfies the required audit rows; it is not rewritten as a new post-readiness subjective review, Archive/Organizer validation or distribution decision. No independent review or distribution approval claimed. The separate prepared-site deployment was explicitly owner-authorized and is recorded in `site-publication.md`.
