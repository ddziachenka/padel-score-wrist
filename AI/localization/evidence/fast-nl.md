# Fast verification

**Generated:** 20261023T103202Z
**Repository:** `/private/tmp/padel-l10n-nl`
**Mode:** product
**HEAD:** `fa49af8c0cc903273258c4710ccc7c7b05213bb5`
**Branch:** localization/nl

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-nl-14f0e41f38ea/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 69F15A0B-DD99-431D-8048-11C51A36FDEA
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-nl
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

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-nl/.artifacts/fast/20261023T103202Z-21553/report.md`. Command log: `/private/tmp/padel-nl-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
