# M31 full-gate failure — native phone accessibility audit and subsequent interruption

Command: `make milestone ID=M31` on clean `main`, full candidate
`7f49552f437ca6a6bb0225327b832080048ded37`.
Wrapper start `2026-11-02T06:38:43Z`, finish `2026-11-02T11:32:02Z`, exit **2**.
The generated milestone report records **FAILED (exit 1)**; this is the inner
verification exit surfaced by make as exit 2, not a discrepancy or a pass.

Report: `.artifacts/milestone/M31/20261102T063844Z-30076/report.md`.
Console: `.artifacts/M31/full-milestone-final-console.log`.
Wrapper identity/exit: `.artifacts/M31/full-milestone-final-exit.json`.

## Observed results

- Static verification and Debug Watch build passed in this invocation.
- Complete Watch result: **640/640 test definitions**, **1,092/1,092 invocations**,
  zero failed/skipped/expected failures, no runtime warnings in exported summary.
  Bundle: `.artifacts/milestone/M31/20261102T063844Z-30076/milestone.xcresult`.
  Export: `.artifacts/M31/full-native-counts/watch-completed-summary.json`.
- Companion unit result: **21/21 definitions**, **30/30 invocations**, zero
  failed/skipped/expected failures, no runtime warnings in exported summary.
  Bundle: `.artifacts/milestone/M31/20261102T063844Z-30076/companion/unit.xcresult`.
  Export: `.artifacts/M31/full-native-counts/phone-unit-completed-summary.json`.
- Companion UI suite is **incomplete and failed**, not an accepted partial pass.
  Persisted counts: **total 10, passed 8, failed 2, skipped 0, expected failures 0**.
  These are the interrupted bundle's reported counts, not the intended full suite
  size and not evidence that all other UI tests passed.
  Bundle: `.artifacts/milestone/M31/20261102T063844Z-30076/companion/ui.xcresult`.
  Counts: `.artifacts/milestone/M31/20261102T063844Z-30076/companion/ui-counts.txt`.

## Failure before interruption

The native iOS 17 small-phone run reached
`CompanionUITests.testKnownScoreSetBoundaryRequiresServingAndExactUndo`.
At `CompanionUITests.swift:687`, XCTest reported:

> Error Domain=com.apple.xcode.xctest.accessibilityAudit Code=-56 "Audit failed to complete in time"

The test failed after **39.252 seconds**. This is recorded at lines 16844–16846 of
`companion/companion-ui-tests.log`. It is an observed native-audit timeout; neither
an app defect nor a harmless infrastructure-only failure is established solely by
this message. The required audit did not pass. No existing check or assertion was
removed, skipped, relaxed, or accepted by exception.

The run subsequently continued through `testLargestTextAccessibility` and into
`testLocalizedGallery`. After the known failure, the coordinator/root deliberately sent
SIGINT to xcodebuild PID **5480** at approximately **11:21:56Z**, stopping an
already-failed full run. This was the coordinator's operational decision, **not a
user request**; the user requested parallelization. Signal identity and timing come
from the coordinator's session record. The log independently establishes
**TEST INTERRUPTED** and a later diagnostic collection
timeout, “Timed out after 600.0 seconds while waiting for a response from the
invoked process,” at local **2026-11-02 15:31:56** (11:31:56Z). It does not by itself
identify who requested the interruption. Cleanup completed with the wrapper's
11:32:02Z exit. The console additionally records the companion UI command exiting
**75**, followed by failure of the UI suite and make Error 1.

## Consequence and next verification

M31 remains unpassed; this invocation cannot support DONE, M26 readiness, release
approval, or M30 external execution. Preserve its report, bundles and console as
failed evidence. Completed Watch and phone-unit portions remain useful diagnostic
history, but are **not reused to assemble a pass** for a different invocation or
candidate. Targeted recovery/reproduction can diagnose the timeout; a fresh full
`make milestone ID=M31` must pass on the final clean candidate with all declared
coverage before milestone completion. No later recovery result is asserted here.

## Bounded recovery and unchanged diagnostic

After the failed gate released its lease, two idle devices owned by this checkout
were temporarily shut down under their managed leases: Watch gallery
`22C79D99-DEA7-4525-AD2D-50FDCD6B8720` and current iPhone
`2D44D21F-290D-4325-8DED-B98D29977585`. Both were previously Booted and their
restoration remains pending until verification is finished. No foreign device,
data erase or shared CoreSimulator service was touched.

The companion `B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2` was already Shutdown after
Xcode cleanup. The initial shutdown attempt returned149 (already Shutdown), then
managed boot completed with exit0 at2026-11-02T11:34:30Z. The failed gate and all
raw diagnostics remain preserved. Recovery details and device inventories:
`.artifacts/M31/phone-audit-diagnosis/recovery.json`.

At the same unchanged7f49552 candidate, the original single scenario ran once:

```sh
bash Scripts/simulator.sh --profile companion run -- /bin/bash -c 'exec xcodebuild test -project App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination "$IOSAI_SIMULATOR_DESTINATION" -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -only-testing:PadelScorePhoneUITests/CompanionUITests/testKnownScoreSetBoundaryRequiresServingAndExactUndo -resultBundlePath .artifacts/M31/phone-audit-diagnosis/focused-after-reboot/test.xcresult'
```

UTC2026-11-02T11:34:43Z–11:36:00Z, exit0. Native results:1/1 definition and
1/1 invocation passed, zero failed/skipped/expected failures/runtime warnings.
Both existing Light/Dark loops and every original native audit category ran;
`known-score-set-serving-and-undo-light` and `-dark` attachments were captured.
Console, receipt and native count exports are under
`.artifacts/M31/phone-audit-diagnosis/focused-after-reboot/`.

This pass supports attempting a new complete gate after bounded environment
recovery; it does not establish the root cause, waive the earlier failure, prove
baseline reproduction, or replace full milestone coverage. No source/assertion/
audit/parser change was made for this recovery. The new frozen candidate also
contains reviewed reply/Review Notes wording and this evidence only.
