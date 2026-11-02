# Boundary state snapshot correction and fixed validation contract

Status: proposed test-only correction; clean-candidate native validation PENDING.
This record does not establish M31 DONE, release readiness or a full make PASS.

## Preserved failure and bounded mitigation

The prior category-grouping correction at
`02d8d9f82a29689743dc3464c2299c465fe3c3d5` did not satisfy its predeclared five-each
validation. Its console records app crashes in boundary iterations3 and5; no native
failure is accepted. The root owns finalization and exports of that exact run:
`.artifacts/M31/phone-audit-diagnosis/final-boundary-correction/run-9df0faen/`.
The finalized driver receipt records exit65, sourceStabletrue, start19:07:16.778907Z
and finish19:28:00.180784Z. Native result counts remain governed by its actual
exports; the ten required invocations were not all passing.
Its original source, predeclared contract, driver and raw native evidence remain
preserved. Earlier full0c and E1/E3/E4 failures also remain failed; the original
unchanged E1/E2 acceptance route stays blocked. E5's isolated diagnostic pass was
not acceptance and does not override the later crashes.

Two saved app1.0(7) crash reports capture2026-11-02T19:15:24.7202Z and
19:17:53.9309Z on the managed companion. Both show null-pointer `strcmp` reached
through `XCTAutomationSupport.runtime_issue_os_log_fault_callback` while libtrace
handles `__LIBTRACE_CLIENT_QUARANTINED_DUE_TO_HIGH_LOGGING_VOLUME__`. The lower
paths are a QuartzCore transaction signpost and an AX/XCTest attribute-snapshot
signpost. The app frames shown are its generated entry points, not a scoring
function at the fault. This locates the immediate automation-callback failure;
it does not prove the earlier Code=-56 cause, identify the entire source of log
volume, or justify suppressing logs/runtime warnings.

Exact raw reports and symbolicated extracts:
`.artifacts/M31/phone-audit-diagnosis/fixed-run-crash-02d8/`.
IPS hashes are476f1f33181b982b2cda8904090704e7b23b5f71add87779470abc8816fd2f62
and63974e09098d48db15f213b8e6dedd21316c5e0814e0b285262cbe74c7fa7db9.

The bounded mitigation changes only the newly added before/after score-state
checks in the affected boundary method. Each check now takes one fresh public
`app.snapshot()`, traverses its captured children in memory and requires exactly
one node of the expected type for each points/context/games/sets/server/status
identifier and the Undo button. It compares the same labels and enabled state.
Missing/ambiguous nodes, snapshot errors and mismatched values still fail.
One captured snapshot is not reused across checks. This reduces additional live
state-query access from169 per appearance to13 coherent snapshots; it does not
remove the checked state or native audit coverage. Runtime improvement is unproven.

The public XCUIAutomation SDK declares `snapshotWithError` as returning hierarchical
data with standard attributes for the element and children; `XCUIElementSnapshot`
exposes captured children and the standard element attributes. Exact header paths/
hashes are recorded in the preparation source-identity.json. No private API,
debugDescription parser, warning/logging switch, error catch, added delay or native
retry is used.

## Exact scope and independent review

Previous Swift source SHA256:
`477b7870d94f0aec4afc0fe66c9517657296915c7463310ab0ac98b63d5f7ca0`.
Proposed Swift source SHA256:
`163213d8f791835962465d2c34a564fbe8e4afcff9d4a05a7646919cb45978b5`.
Preparation directory:
`.artifacts/M31/phone-audit-diagnosis/snapshot-state-correction/`.

Every byte outside the boundary method is unchanged from02d8, including the
shared helper and original six-category default union/issue handler. Both original
appearance loops, first union audit, finite original-viewport restoration, all six
singleton post-Undo categories and deferred-element rechecks remain. Original
score/serving/Undo assertions and the unchanged predecessor/control remain.
Independent scoped source review confirms those boundaries and the public SDK
contract; it does not claim compilation, runtime success or release approval.
No product, layout, scoring, storage, resource, project or dependency input changes.
Root independently typechecked the exact proposed source with the actual Swift6,
iOS17 simulator target and SDK27.1/framework/Swift-overlay paths: exit0 at
19:27:23Z, `typecheck-swift-overlay-receipt.json`/log in the preparation directory.
Two earlier standalone preparation commands omitted necessary search paths and
failed; those are preserved and not described as application source failures.
Standalone typecheck is not native acceptance.

## One predeclared fixed validation

Under the [explicit affected-only owner authorization](owner-impact-verification-authorization.md),
root reviews/commits the correction and evidence on clean primary main. Once the
prior failed02d8 run is actually closed and exported, invoke ONCE:

```sh
python3 .artifacts/M31/phone-audit-diagnosis/snapshot-state-correction/run.py --candidate <full-40-character-SHA> --run
```

One xcodebuild invocation runs the unchanged predecessor/control and corrected
boundary with fixed `-test-iterations 5`. Actual XCTest order must be control
iterations1–5, then boundary iterations1–5; not five interleaved pairs. Require
**2 distinct definitions,10 invocations, all Passed**, both boundary appearances
and all six categories each time, zero skipped/expected failures/runtime warnings,
and exact source/environment identity. The guard must bind the prior failed run's
actual finalized receipt/native counts before execution. No separate E6 single-case
diagnostic is needed; no extra unaltered run is authorized if this fixed run fails.

The driver retains managed companion ownership, before/after clean-source proof,
exact source hash, prior failure bindings, commands/exits and unique output. An
exit-zero wrapper alone is insufficient: independently verify actual native
Repetition1–5 nodes, strict `started (Iteration N of 5).` console records, category/
appearance completion markers and immutable source/runtime/toolchain evidence.
The prior unused validator must remain archived and a new exact-source route must
be reviewed. No old source failure becomes a pass through this new route.

Eligible unaffected reuse remains640Watch+21phone-unit+19otherphoneUI definitions,
with the control and boundary freshly validated:682 unique definitions total.
Accepted coverage, final P0/P1 disposition and M31 closure are still pending.
The canonical full-gate parser remains unchanged; the raw full gate stays FAILED.
All real Release builds, package/signature checks and ASC processing/submission
checks remain required. This evidence authorizes no warning suppression, failed
coverage acceptance or new live App Store mutation.
