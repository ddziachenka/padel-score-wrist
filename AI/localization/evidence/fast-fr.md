# Fast verification

**Generated:** 20261023T083810Z
**Repository:** `/private/tmp/padel-l10n-fr`
**Mode:** product
**HEAD:** `1dcf9fe8eacf21af80ecece67ca3823f0a529345`
**Branch:** localization/fr

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-fr-9bb81bbfa091/DerivedData`

**App platform:** watchOS
**Simulator UDID:** BA44AE8B-5A0B-4BD3-AC9B-9A863A822994
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-fr
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
