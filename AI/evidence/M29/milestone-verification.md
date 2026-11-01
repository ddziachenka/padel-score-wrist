# M29 exact full milestone verification

**Policy status:** current
**Verified SHA:** `a908212c242663c2079427cd3d40ef923d73bd40`
**Branch / mode:** clean primary checkout, main, current-head
**Exact command:** `make milestone ID=M29`
**Exit code:** 0
**UTC interval:** 2026-11-01T13:33:37Z–2026-11-01T19:54:49Z
**Verdict:** PASSED milestone verification; not release/submission approval
**Report:** `.artifacts/milestone/M29/20261101T133336Z-27916/report.md`
**Console:** `.artifacts/M29/full-milestone-console.log`

The entire unchanged command ran all configured Watch and iPhone suites on one
clean REVIEW/main candidate. No automatic verification waiver, component reuse,
filter, retry, count-parser change or M25/M28 exception was used. The complete
command and final unchanged-source/clean-tree check pass. Both Debug builds and
independent packaging/identity guards pass. No additional scanner is configured;
disabled optional analyzers are not represented as run.

## Native results

| Component | Passed definitions | Invocations | Failed/skipped/expected/runtime warnings | Native UTC interval |
| --- | ---: | ---: | --- | --- |
| watch | 640/640 | 1092 | 0/0/0/0 | 2026-11-01T13:34:17.224000Z–2026-11-01T17:34:05.199000Z |
| phone-unit | 21/21 | 30 | 0/0/0/0 | 2026-11-01T17:34:47.228000Z–2026-11-01T17:35:09.131000Z |
| phone-ui | 21/21 | 21 | 0/0/0/0 | 2026-11-01T17:35:13.963000Z–2026-11-01T19:54:39.979000Z |
| Aggregate | 682/682 | 1143 | 0/0/0/0 | All three complete bundles |

Every invocation leaf is Passed, not merely its parent definition. Read-only
native export/leaf validation exits0 with this exact command:

```sh
python3 .artifacts/M25/export-results.py .artifacts/M29/full-native-counts watch=.artifacts/milestone/M29/20261101T133336Z-27916/milestone.xcresult phone-unit=.artifacts/milestone/M29/20261101T133336Z-27916/companion/unit.xcresult phone-ui=.artifacts/milestone/M29/20261101T133336Z-27916/companion/ui.xcresult
```

The existing exporter is reused as a read-only tool; all result bundles are new
M29 bundles. Raw definitions, invocation counts/results, native summaries and test
trees: `.artifacts/M29/full-native-counts/`; command output:
`.artifacts/M29/full-native-counts-export.log`. All paths remain local evidence.

Watch uses owned SE40mm/watchOS26.1, A7CBB23C-F823-4850-BE4B-CAD76922DD08.
iPhone uses owned SE3/iOS17.0, B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2.
Pinned destinations, clean source and actual commands are also in the raw report
and component logs. No physical device connection is used by this full command.

## Other evidence and limits

Fresh shipping build6 source remains identical to targeted-tested ff87; all final
shipping fingerprints pass. Final native Store captures use the distinct frozen
source136, not the gate SHA: [materials](material-refresh.md), [Watch review](watch-gallery-visual-review.md),
[phone review](phone-gallery-visual-review.md), [creative review](creative-visual-review.md),
[browser review](site-browser-review.md). They contain210 original native PNGs,
28 compositions,104 byte-identical site copies and42 visual contacts. All strict
source/attachment/format/hash/site checks pass;53 exact HTML/CSS files bind208
browser-layout observations and12 computed palette checks. Dark browser work is
an isolated CSS preview, not OS appearance emulation. Source/settings/runtime
boundaries remain explicit.

All manual physical rows are OWNER_ACCEPTED_BY_DECISION under the
[exact owner instruction](owner-physical-acceptance.md). Numeric recognition
denominators/percentages, measured hour/zero-event counts, real Watch video and
independent Watch6 About readback were not recorded/supplied. They are not invented
or replaced by Simulator results. This manual-only acceptance changes no automatic
gate and does not waive M26/M30 or authorize external distribution.

Earlier failed native runs, the initial sandbox inventory exit69 and the separate
baseline-matched current-StoreKit FAILED/P2 remain preserved and are never counted
as passing components here. Scoped source/copy reviews are distinct from this
Builder validation and do not establish independent release approval.

The six final typed records are `AI/audits/M29-<domain>-revalidation.md`. Their
explicit schema/row validation is separate from this gate (M29 has no Audit prompt
field): `.artifacts/M29/domain-coverage-final.log`. After the continuity/DONE
commit the required `make static`, `./Scripts/project-status.sh validate` and
`./Scripts/project-status.sh continuity a908212c242663c2079427cd3d40ef923d73bd40`
write `.artifacts/M29/post-done-{static,status,continuity}.log`; those checks
are not fabricated as part of the earlier candidate command.

## Retained raw passing report

# Milestone M29 verification

**Generated:** 20261101T133337Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `a908212c242663c2079427cd3d40ef923d73bd40`
**Branch:** main

**Gate:** milestone finalization
**Policy version:** solo-workflow/2
**Milestone:** M29
**CANDIDATE_COMMIT:** `a908212c242663c2079427cd3d40ef923d73bd40`
**Verification mode:** current-head
**Verification started:** 20261101T133337Z
**Candidate source:** clean current HEAD in the active checkout
**Contract:** `AI/milestones/M29-physical-device-validation.md`

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
| Milestone tests | milestone tests: total=640 passed=640 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** (every test in the scheme)

## Exact commands

```sh
'xcodebuild' 'build' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData'
'xcodebuild' 'test' '-project' '/Users/Shared/D/ios/padel-score/App/PadelScore.xcodeproj' '-scheme' 'PadelScore' '-configuration' 'Debug' '-destination' 'platform=watchOS Simulator,id=A7CBB23C-F823-4850-BE4B-CAD76922DD08' '-derivedDataPath' '/private/tmp/padel-score-1acada2a5b10/DerivedData' '-resultBundlePath' '/Users/Shared/D/ios/padel-score/.artifacts/milestone/M29/20261101T133336Z-27916/milestone.xcresult'
```
**App platform:** iOS
**Simulator UDID:** B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/milestone/M29/20261101T133336Z-27916/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/milestone/M29/20261101T133336Z-27916/companion/ui.xcresult

## Result

**VERIFIED_COMMIT:** `a908212c242663c2079427cd3d40ef923d73bd40`
**Verdict:** PASSED milestone verification
**Verification completed:** 20261101T195449Z

## Post-DONE validation

First DONE continuity commit `f1d3942531ee549e9c264bc2ea1957a44eade849` passes all three required commands,
each exit0, recorded2026-11-01T19:59:54Z:

```sh
make static
./Scripts/project-status.sh validate
./Scripts/project-status.sh continuity a908212c242663c2079427cd3d40ef923d73bd40
```

Archived outputs: `.artifacts/M29/post-done-initial-{static,status,continuity}.log`.
Continuity confirms exactly the build inputs of the verified candidate and only
AI Markdown changes. Final-HEAD repeats follow this Markdown-only evidence update;
their actual outputs use `.artifacts/M29/post-done-{static,status,continuity}.log`
and `.artifacts/M29/post-done-final-head.txt`. No native result is re-labelled.
