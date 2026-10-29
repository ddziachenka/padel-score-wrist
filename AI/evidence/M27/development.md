# M27 development evidence

Baseline: `6af2a23aff82bca6df20fe80d58ffdc7c949a4ac`, clean main. Development
commands ran on mutable source and establish no verified candidate. No failure
below is called pre-existing, accepted, skipped into a pass or release evidence.

| Run | Command scope | Exit | Native definitions (passed/total; failed/skipped) | Result |
| --- | --- | --- | --- | --- |
| unit-1 | xcodebuild test, all PadelScoreWatchTests | 65 | 443/447; 4/0 | New schema makes old future-version=4 fixtures obsolete; the new backup test omitted the existing uncertain-usage rule. Updated future-version fixtures to current+1 and asserted the complete correct recovered session. Nine assertion issues across four definitions retained. |
| ui-1 | PlayerNamesUITests, initial one test | 65 | 0/1; 1/0 | Test began on Result but queried New game directly; corrected the actual route. Only post-failure simctl diagnostics collection was terminated, not tests or CoreSimulator. |
| ui-2 | PlayerNamesUITests, one complete setup/relaunch test | 0 | 1/1; 0/0 | Native text entry, name/role service selection, start and cold relaunch passed; screenshot visually inspected. |
| ui-3 | All five PlayerNamesUITests | 65 | 1/5; 4/0 | Generic scroll helper could not center the fixed footer Menu button. Adopted the existing live/journal UI-test convention: tap when hittable, otherwise scroll. |
| dev-4 | All Watch unit tests and five new UI tests | 65 | 450/452; 2/0 | All 447 unit definitions passed. UI failure 1 queried a system large-title descendant instead of the actual navigation-bar identity; retained exact localized-title assertion using its bar. UI failure 2 proved the ancestor result.players accessibility identifier overwrote per-row IDs; moved it to the heading and retained roster assertions. Native editor audit, failure/retry/cancel and setup/relaunch passed. |
| ui-5 | Two corrected UI cases | 65 | No tests executed | Component extraction initially omitted new source from the StoreKit host. The unchanged parity guard refused; added the same source to shipping and test-host targets. |

Raw summaries/logs and result bundles are under `.artifacts/M27/`; no result bundle
or failed report is deleted. Development xcodebuild logs include the exact command,
UDID, result path and timestamps. The primary Watch is the managed 40mm SE2,
`A7CBB23C-F823-4850-BE4B-CAD76922DD08`, watchOS26.1.

## Physical attempts and owner validation direction

Both `xcodebuild test` attempts targeting physical Watch
`00008310-000823642660E01E` failed before test execution with exit70:
“A networking error occurred.” CoreDevice apps query narrowed it to an invalidated
Bluetooth connection before tunnel creation, RemotePairingError1007/L2CAP open
channel failure. Device is paired, developer mode enabled, Mac Bluetooth on;
standard pairing returned available/paired but did not establish a test tunnel.
No app install or successful physical test is claimed. The intermediate signed
Watch Debug build itself passed; it is not final-candidate hardware evidence.

Owner subsequently directed: “давай все проверки на физических часах сделаем перед
подготовкой к релизу”. All physical-Watch checks, including native name input,
VoiceOver and lifecycle, are now explicitly owned by M25 before M26. This changes
coverage ownership, not assertions or release requirements. No further hardware
operations occur in M27. Raw logs: `.artifacts/M27/physical-ui-1.log`,
`physical-ui-2.log`, `physical-connection.log`.

## Development-loop scope

The ordinary permitted fast-loop scope is all Watch unit tests plus the five new
name UI tests. `.artifacts/M27/run-fast.sh` temporarily selects those targets,
runs the exact `make fast` command and restores Config/project.env byte for byte.
It refuses to overwrite any concurrent external config edit. The milestone gate
retains empty MILESTONE_TEST_ARGUMENTS and both full platform suites; fast results
never establish completeness or release readiness.

## First fast-loop attempt

`bash .artifacts/M27/run-fast.sh` ran exact `make fast` and returned Make2 /
verifier1 before tests. The Debug build passed, then the unchanged packaging guard
found a retained PadelScoreWatchTests.xctest in this checkout's mutable DerivedData.
Report: `.artifacts/fast/20261029T073713Z-78243/report.md`; no test counts or pass
are claimed. File inventory: `.artifacts/M27/cache-packaging.txt`. The original
Config/project.env was restored by the wrapper. `make clean-derived-data` removes
only the owned disposable cache; raw reports/bundles remain. A fresh fast loop is
required. This is a diagnosed cache artifact, not a pre-existing source failure.

## Corrected targeted UI run

`ui-6` ran the two corrected UI cases on the primary 40mm Watch and passed exit0:
2/2 definitions, zero failures/skips. The locale/largest-text case passed in
569.532s, including all thirteen locales; live/cancel/background/clear/Undo/result/
Play-again/archive passed in157.493s. Full source/command/bundle provenance remains
in the raw log and native summary. Subsequent source adjustments only add a
remembered-roster setup summary, a precise name-save error, an actual-file deletion
regression and explicit frozen-schema-3 missing-journal coverage; these must run
in the final fast/compatibility/full-gate checks rather than inheriting a pass.

## Final fast and focused schema checks

The clean-cache fast run passed exit0: **453/453 definitions,874 invocations**,
zero failed/skipped/expected/runtime warnings. Exact command `make fast`, invoked
by the documented temporary-scope wrapper; report
`.artifacts/fast/20261029T074113Z-85655/report.md`, bundle `fast.xcresult` there;
native summary `.artifacts/M27/fast-summary.json`. Config/project.env was restored
byte for byte, including empty FAST/MILESTONE_TEST_ARGUMENTS before the candidate.

Self-review added the explicit old-schema-3 strict-journal regression while that
mutable fast run was executing. The entire affected SessionFileTests suite then
ran on final source with exit0, `.artifacts/M27/schema-final.xcresult` and native
`schema-final-summary.json`; the full candidate gate still reruns everything.
