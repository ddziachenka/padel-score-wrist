# Fast verification

**Generated:** 20261023T103159Z
**Repository:** `/private/tmp/padel-l10n-pt-br`
**Mode:** product
**HEAD:** `75a839a04c30e716480db419d397e21bed42c2b5`
**Branch:** localization/pt-br

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-pt-br-546c5b8f8565/DerivedData`

**App platform:** watchOS
**Simulator UDID:** AA43FEAE-4247-4983-B4ED-7560CAC680C1
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-pt-br
**Debug launcher:** WidgetKit extension embedded; version/build/platform match; test hosts absent
**Debug Watch app:** com.dziachenka.padelscore.watchkitapp 1.0 (1)
**Debug packaging container:** com.dziachenka.padelscore 1.0 (1)
## Result

**Verdict:** PASSED

| Step | Result |
| --- | --- |
| Debug build | passed |
| Fast tests | fast tests: total=472 passed=472 failed=0 skipped=0 expectedFailures=0 |

**Test scope:** `(every test in the scheme)`

## Scope guard

This gate is narrow by design. It does not run static checks, does not
build Release, and does not establish milestone or release readiness.
Use an explicit milestone or integration candidate gate for that.

## Coordinator execution

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-pt-br/.artifacts/fast/20261023T103159Z-18740/report.md`. Command log: `/private/tmp/padel-pt-br-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
