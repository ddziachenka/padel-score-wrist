# Fast verification

**Generated:** 20261023T112919Z
**Repository:** `/private/tmp/padel-l10n-sv`
**Mode:** product
**HEAD:** `ae20e0790b93401fd58bc654d9cfbbc82ec35930`
**Branch:** localization/sv

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-sv-adc030cfd975/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 4E0E5059-C2AB-40BF-BB0C-586FD2F9C950
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-sv
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

Exact command: `make fast` in the recorded worktree. Exit 0. Original report: `/private/tmp/padel-l10n-sv/.artifacts/fast/20261023T112919Z-15324/report.md`. Command log: `/private/tmp/padel-sv-fast-coordinator.log`. This verifies the original language commit; final combined resources and locale journeys are verified by the separate exact integration gate.
