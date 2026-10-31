# M25 verification path — owner decision pending

**Status:** awaiting a new M25-only decision; not DONE and no exception inferred.
**Candidate:** `5eb65bbc17e9540d3922a520b44d3c8731947432`, clean main throughout both component runs.

## Concrete completed evidence

| Component | Passed definitions | Passed invocations | Failed/skipped/expected/runtime warnings | Native UTC interval |
| --- | --- | --- | --- | --- |
| watch | 635/635 | 1085 | 0/0/0/0 | 2026-10-31T08:34:00.441000+00:00–2026-10-31T12:30:24.450000+00:00 |
| phone-unit | 21/21 | 30 | 0/0/0/0 | 2026-10-31T14:27:43.460000+00:00–2026-10-31T14:27:51.270000+00:00 |
| phone-ui | 21/21 | 21 | 0/0/0/0 | 2026-10-31T14:27:52.708000+00:00–2026-10-31T16:45:11.806000+00:00 |

Aggregate677 definitions/1136 invocations. Strict native summaries AND invocation
leaves are retained in `.artifacts/M25/same-candidate-component-counts.json` and
its source exports; every accepted leaf is Passed. Both Debug/independent package
guards pass. Fresh `make static` passes, exit0. No original test, category,
assertion, source scope, parser or skip policy changed after this candidate.

Watch was fully executed by `make milestone ID=M25 > .artifacts/M25/full-gate-2.log 2>&1`;
its bundle is `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult`.
The complete monolithic report remains FAILED/exit130. Its first phone attempt
records8 passed/2 failed of10 definitions: native audit Code-56 and cancellation
after that known failure. Those phone results are not accepted as passes.

The bounded unchanged-code reproduction then hangs inside the native audit and
fails its30-minute allowance, exit65. Only owned B9/iOS17 is restarted, preserving
data. The same known-score serving/Undo test then passes1/1 in both themes with
all six strict native audit categories, exit0, about87seconds. No product or test
code was changed to obtain that result, and no pre-existing/universal SDK cause
is claimed. Raw diagnostics: `.artifacts/M25/known-score-audit-{unchanged,reboot}*`.

After restoration, complete new phone verification passes, exit0:
`bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`.
It invokes unchanged `verify_companion_profile milestone`, including complete unit
AND UI schemes, Debug build, package guards and original strict result parser.
Report `.artifacts/M25/phone-complete-same-candidate/report.md`, UTC
2026-10-31T14:27:08Z–2026-10-31T16:45:19Z. The report explicitly says complete
iPhone verification only, not a newly passing full milestone command.

Both reports record exactly the same candidate SHA. All1212 tracked entries,
including modes/blobs, have tree `b696c4e290bdba3ec31b4028f9ed91071b264d28`;
the raw tracked manifest SHA256 is
`b593dbeeb1c917f19e5b3536719bfb890a123efc91eac55a03679d5c11c4ceee`.
Ignored proof: `.artifacts/M25/same-candidate-inputs.json` and
`same-candidate-input-manifest.bin`. Clean same-HEAD guards passed before/after
full phone verification. B9 remains in its original Booted/light state; no other
simulator or global service was reset. There is no pending restoration.

All required digital experience/material work is ready: centered recovery,
all26 gesture/Help/recovery locale/theme matrices, minimum/current runtime
supplements,14locale gallery4,210 raw native/28 creative assets,42 visual contact
reviews, strict source/provenance/site checks and authenticated App Privacy readback.
See runtime.md, materials-review.md and minimum-gesture-audit-traversal.md.

## Why the decision is necessary

The current M25 contract requires “Full make milestone ID=M25 passes” and a clean
REVIEW run of that exact command. AGENTS A6/A12 and the Builder sequence require
its passing verification before DONE. The M28 owner exception explicitly applies
only to M28 and does not extend to later milestones. A new M25 exception cannot
be inferred from routine Simulator-recovery approval or the request to accelerate.

## Options

1. **Accept same-candidate components (Recommended).** A new explicit M25-only
   exception accepts the fully passing Watch result plus the fresh COMPLETE phone
   unit/UI result on exactly the same unchanged SHA. Retain all raw failures,
   record the exception and native evidence, complete MD handoff/DONE and closing
   static/status/continuity checks. No failed phone result or required coverage is
   waived. Approximately several minutes after the decision.
2. **Repeat the complete monolithic gate.** Run `make milestone ID=M25` again on
   a clean REVIEW candidate, including the already passing Watch and the complete
   phone suites. Approximately6hours if the native environment stays healthy.

Neither option authorizes publication, App Review submission, an external reply,
pricing or physical-check waivers. Every physical case/video remains M29; M26
still requires complete milestone and exact-SHA release verification. Additional
current-runtime StoreKit probe remains FAILED/P2 with baseline-matched evidence.
This is Builder self-review, not independent review or release approval.
