# Fast verification

**Generated:** 20261023T132313Z
**Repository:** `/private/tmp/padel-l10n-nb`
**Mode:** product
**HEAD:** `3121bc4973a7766b69a82e36332571502c466fbc`
**Branch:** localization/nb

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-nb-bf62a60eeb42/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 5CB5B23C-F271-4AA3-955D-37F6CC486A87
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-nb
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

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-nb/.artifacts/fast/20261023T132313Z-84004/report.md`. Command log: `/private/tmp/padel-nb-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
