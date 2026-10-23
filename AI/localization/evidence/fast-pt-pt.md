# Fast verification

**Generated:** 20261023T093452Z
**Repository:** `/private/tmp/padel-l10n-pt-pt`
**Mode:** product
**HEAD:** `f32092741356f46c29337a4fdc39b232bdccadc3`
**Branch:** localization/pt-pt

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-pt-pt-cdfe8398816e/DerivedData`

**App platform:** watchOS
**Simulator UDID:** 7C38F687-058B-4DC6-B61C-A49ED47BD2AB
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-pt-pt
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

Exact command: `make fast` in the repository recorded above. Exit 0. Source log: `/private/tmp/padel-pt-pt-fast-coordinator.log`. The later best-effort simulator shutdown returned 149 because the managed device was already shut down; this was after the successful gate and did not change its verdict.
