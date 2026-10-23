# Fast verification

**Generated:** 20261023T122609Z
**Repository:** `/private/tmp/padel-l10n-da`
**Mode:** product
**HEAD:** `7e3da467c1b2fa7cee4fe287f50b8032504a3d39`
**Branch:** localization/da

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-da-751e6505bf28/DerivedData`

**App platform:** watchOS
**Simulator UDID:** B848B618-042B-4C6C-B376-A96CCDEFE0E2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-da
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

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-da/.artifacts/fast/20261023T122609Z-13423/report.md`. Command log: `/private/tmp/padel-da-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
