# Fast verification

**Generated:** 20261023T122609Z
**Repository:** `/private/tmp/padel-l10n-fi`
**Mode:** product
**HEAD:** `c3cb82c24b4911c513d697ae0a15b482ae72ef64`
**Branch:** localization/fi

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-fi-9943c159467a/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 196C109E-D6D2-4C9B-B4B9-779C5F0069F1
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-fi
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

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-fi/.artifacts/fast/20261023T122609Z-13728/report.md`. Command log: `/private/tmp/padel-fi-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
