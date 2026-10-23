# Fast verification

**Generated:** 20261023T093452Z
**Repository:** `/private/tmp/padel-l10n-it`
**Mode:** product
**HEAD:** `d87c2c08d8046c2941af4dc7f355748ffbfb278a`
**Branch:** localization/it

**Gate:** fast (development loop — not a completeness gate)
**DerivedData:** `/private/tmp/padel-l10n-it-444c929d687f/DerivedData`

**App platform:** watchOS
**Simulator UDID:** CD268542-2A67-4D1E-81DC-8E57265CA93B
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.watchOS-26-1
**Simulator owner:** /private/tmp/padel-l10n-it
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

Exact command: `make fast` in the repository recorded above. Exit 0. Source log: `/private/tmp/padel-it-fast-coordinator.log`. The later best-effort simulator shutdown returned 149 because the managed device was already shut down; this was after the successful gate and did not change its verdict.
