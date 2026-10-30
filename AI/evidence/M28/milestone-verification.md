# M28 exact verification under owner exception

The owner explicitly approved [one-time component reuse](owner-verification-exception.md)
for M28. The accepted evidence combines source-identical passing Watch results
and complete new iPhone verification; it is not a newly passing full milestone gate.

Candidate: `e21875871773f9b47419d526a9cb22e2a4d66fb1`, clean REVIEW/main throughout.
Command: `bash .artifacts/M28/verify-phone-complete.sh owner-verification-5`.
Exit: **0**. UTC wrapper interval: **2026-10-30T00:08:36.860730Z–2026-10-30T01:33:12.794777Z**.
Report: `.artifacts/M28/owner-verification-5/report.md`.
The unchanged `verify_companion_profile milestone` runs Debug/package guards,
complete unit/UI schemes and original strict native result/count parsing, without
selectors or skipped checks. Fresh `make static` is part of this command.

| Evidence | Source | Passed definitions / invocations |
| --- | --- | --- |
| Reused complete Watch | `3db256e040e4306477d63f2e75b0223561c1e240` |619/619 /1057 |
| Fresh complete iPhone unit | candidate above |21/21 /30 |
| Fresh complete iPhone UI | candidate above |16/16 /16 |

Every accepted component has zero failed/skipped/expected failures and native runtime warnings. Fresh phone coverage is37 definitions/46 invocations; the reused Watch component is619/1057. These are composed evidence, not one newly passing full gate. Native summary/tree exports: `.artifacts/M28/final-results/`.
Phone bundles: `.artifacts/M28/owner-verification-5/companion/{unit,ui}.xcresult`.
Watch bundle: `.artifacts/milestone/M28/20261029T151440Z-2914/milestone.xcresult`.
The original full `make milestone ID=M28` ran at3db and remains FAILED, with
complete passing Watch619/1057 and phone units21/30, failed/interrupted phone UI.
Its command exits and original report are preserved; the exception does not turn
that report into a pass or accept any iPhone failure.

## Watch input identity

Before and after the new complete phone verification, every tracked path/mode/blob
matched3db except Markdown under AI and the explicitly permitted phone guide/test
files. Protected574-path manifest SHA256:
`91ea566c380ab29ff378880d9a084b2004ec35cfdc4cd26869b3754fd1624ac8`.
The fail-closed proof and both manifests live under the accepted report directory.
No Watch code/test, project membership, resources, configuration or gate script
changed. Verification procedure SHA256:
`f12860e849cf37b989a7478a0efba313eeb2ed18ad97b073009682423d034eac`;
input-proof SHA256:
`f75cef823a241df33e88657d9bcce510d33ca116307b38a03a386adbbbe0193d`.
The original phone native-audit helper remains byte-identical to3db:
`59b724954af987c3a0e72eb272b2b48b91700006e1ed992ddb7fe57d2aed8b5d`.
New visibility/height assertions and one deliberate post-audit picker press retain
all existing audit categories, deferred full-visibility rechecks and score/Undo
expectations. No assertion, count parser, timeout or skip policy was weakened.

## Runtime and failed runs

Minimum/current Watch supplements pass469/907 and471/909 on Watch inputs identical
to the accepted candidate. Current-iOS affected supplement passes2/2 definitions/invocations, exit0, same SHA. Exact command: `M28_PHONE_RUN=phone-current-v3 bash .artifacts/M16/runtime-profile.sh phone-current run bash .artifacts/M28/check-phone-current.sh`. Wrapper UTC interval: `2026-10-29T23:26:59.870630Z–2026-10-29T23:32:46.430483Z`.
Exact commands, devices, UTC native times and inspected captures: runtime.md.
Failed and partial attempts, including contrast/clipping corrections, the picker
interaction and framework timeout, remain development.md. None is called a pass.
The owner exception accepts only reuse of the unchanged Watch result.

Both fresh iPhone package guards pass. No additional problem scanner is configured;
optional disabled format/lint tools are not claimed as passes. Apple StoreKitTest
SDK-header deprecation and AppIntents metadata messages are build messages, kept
separate from native runtime-warning counts.

Builder self-review is recorded in self-review.md, not independent review or release
approval. All physical checks remain mandatory in M29. M26 retains its complete
milestone and exact-SHA release gates. M30 owns the separately authorized App Review
response/resubmission. No external upload/reply/submission or pricing change occurred.


## Simulator environment and pixel evidence

The final complete run uses the new official companion bindingB9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2,
still SE3/iOS17.0 with the same committed configuration. Former51FD3DAD remains
shutdown with its data preserved under `iosai-padel-score-companion-M28-preserved-51FD3DAD`;
its original binding and rename record are in `.artifacts/M28/old-companion-simulator-binding.json`
and `preserved-old-simulator.json`. No device was erased, no foreign device or
global Simulator service was changed. Three own idle devices were temporarily
stopped and restored to their original Booted state, each exit0:
`.artifacts/M28/restore-owned-results.json`. The same unchanged set-boundary test
passed in both themes on the fresh device, then the complete native suite passed.
This records an observed environment mitigation, not a proved root cause.

The complete native matrices request Light/Dark and assert XCTest's setting. Actual
current-iOS final captures were separately inspected in both themes. Minimum-iOS
final captures exposed an automation discrepancy: some Dark-labelled frames render
Light despite the setting assertion. Native results remain as reported, but labels
are not claimed as proof of exhaustive minimum-iOS Dark pixels. See runtime.md for
actual observations and bounded supplemental checks. M25 owns comprehensive digital
appearance/localization and store-gallery inspection before M29/M26; this limitation
is carried explicitly, without changing production themes or exempting any audit.

Original final captures/manifests and90 PNG SHA256/dimension records:
`.artifacts/M28/final-capture-provenance.json`. Sizes750×1334 and1320×2868.
Minimum/current visuals and raw native audits are retained separately from future
M25 Store assets. These are real app captures, not AI-rendered interface images.

Xcode also emits `IDESchemeActionSDKRecord invalidDigitCount(94232)` for host build
24A94232 and debugger-version metadata diagnostics. They remain in raw logs; all
accepted native summaries report zero runtime warnings and command exit0. This is
separate from Apple's StoreKitTest SDK-header deprecation/AppIntents messages.

## Raw successful component report

# M28 complete iPhone verification — owner exception

**Generated:** 20261030T000838Z
**Repository:** `/Users/Shared/D/ios/padel-score`
**Mode:** product
**HEAD:** `e21875871773f9b47419d526a9cb22e2a4d66fb1`
**Branch:** main

**Acceptance:** M28-only owner-approved component verification; not a new full milestone-gate pass.
**Owner record:** AI/evidence/M28/owner-verification-exception.md
**Procedure SHA256:** f12860e849cf37b989a7478a0efba313eeb2ed18ad97b073009682423d034eac
**Input-proof SHA256:** f75cef823a241df33e88657d9bcce510d33ca116307b38a03a386adbbbe0193d
**Started:** 2026-10-30T00:08:38Z
**Watch evidence:** REUSED from 3db256e040e4306477d63f2e75b0223561c1e240; 619/619 definitions,1057/1057 invocations; protected inputs identical. Original full report remains FAILED.
**make static:** passed, exit0.
**App platform:** iOS
**Simulator UDID:** B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2
**Simulator runtime:** com.apple.CoreSimulator.SimRuntime.iOS-17-0
**Simulator owner:** /Users/Shared/D/ios/padel-score
**Debug iOS companion:** executable + independent Watch + launcher; identity and archive isolation verified
**iOS companion unit complete suite:** complete iOS companion unit suite: total=21 passed=21 failed=0 skipped=0 expectedFailures=0
**iOS companion unit result:** .artifacts/M28/owner-verification-5/companion/unit.xcresult
**iOS companion ui complete suite:** complete iOS companion ui suite: total=16 passed=16 failed=0 skipped=0 expectedFailures=0
**iOS companion ui result:** .artifacts/M28/owner-verification-5/companion/ui.xcresult
**Finished:** 2026-10-30T01:33:12Z
**Candidate continuity:** unchanged clean HEAD e21875871773f9b47419d526a9cb22e2a4d66fb1.
**Verdict:** PASSED — complete new iPhone verification with source-identical Watch evidence under the explicit M28 owner exception.


Supplemental theme diagnostic: `bash Scripts/simulator.sh --profile companion run -- bash .artifacts/M28/check-minimum-dark-matrix.sh`
passed exit0 at the same E218 source,2026-10-30T01:36:53.719071Z–01:55:01.506474Z,
1/1 native definition/invocation, all26 internal requested-theme variants and original
audits; zero failed/skipped/expected/runtime warnings (`minimum-dark-matrix.xcresult`,
summary/exit JSON). It did not establish actual Dark pixels solely from the labels.
A separate leased manual app launch/system-theme comparison also returned exit0;
the system Settings app itself rendered Light after the Dark setting, captured in
`minimum-system-settings-dark.png`. This observation supports a Simulator-environment
limitation rather than silently treating its getter as visual proof. Diagnostic
helpers restore the original style; no production theme/source change was made.
Actual current-iOS both-theme evidence remains valid; M25 owns the comprehensive
actual-theme/store-image follow-up. Five original diagnostic PNGs have dimensions
and hashes in `.artifacts/M28/appearance-diagnostic-provenance.json`.
