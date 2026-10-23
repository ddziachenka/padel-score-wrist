# Fast verification

**Generated:** 20261023T083807Z
**Repository:** `/private/tmp/padel-l10n-es`
**Mode:** product
**HEAD:** `a3b6161e7b05a2391aaa86b7584a64dd316a5537`
**Branch:** localization/es

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-es-04f25546281a/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 87245DBA-0BC8-480A-A218-58D1DC3B5BBB
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-es
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
