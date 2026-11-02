# Native boundary audit: category grouping correction and fixed validation

Status: correction prepared/applied; fresh clean-candidate validation PENDING.
This is not a full milestone PASS, release approval or App Store submission.

## Preserved observations

The complete M31 invocation at `0c2dab8d17f3212e3c426d715fd1297d57cb021c`
finished naturally at 2026-11-02T18:13:58Z: make exit 2, verifier exit 1,
phone UI xcodebuild exit 65. Watch 640 definitions/1092 invocations and phone
unit 21/30 passed. Phone UI executed all 21 definitions/invocations: 20 passed,
one failed, zero skipped/expected failures/runtime warnings. The sole failure was
`testKnownScoreSetBoundaryRequiresServingAndExactUndo`, native accessibility
Code=-56 after the second Undo. Raw report remains FAILED:
`.artifacts/milestone/M31/20261102T113829Z-42676/report.md`; finalized native exports
are `.artifacts/M31/native-full-failed-0c2dab8/`.

The unchanged E1 predecessor/boundary pair failed (1/2 passed, exit 65); its planned
E2 prefix was therefore not run. Instrumented E3 and whole-card/lower-control E4
pairs also failed (each 1/2 passed, exit 65). E3 showed successful combined Light
calls taking about 2.42/1.73 seconds, while Dark timed out after 15.015 seconds.
E4's whole-card audit passed and lower-control audit failed despite all four
controls being visible. These observations do not establish clipping as sole cause,
aggregate work exceeding a deadline, a product defect, or an infrastructure-only cause.

E5 split the six original categories while restoring the original post-Undo viewport
before each. The diagnostic pair finished 2026-11-02T19:01:31Z, exit 0, two of two
native definitions/invocations passed, all adverse counts zero; both Light/Dark
loops completed. Its dirty source stayed hash-identical. E5 is diagnostic evidence,
not acceptance of the final uninstrumented correction. Evidence directories:

- `.artifacts/M31/phone-audit-diagnosis/sequence-E1-0c2dab8d17f3212e3c426d715fd1297d57cb021c-5fg_v39r/`
- `.artifacts/M31/phone-audit-diagnosis/E3-preparation/run-k2wt7m1r/`
- `.artifacts/M31/phone-audit-diagnosis/E4-preparation/run-kc5d5ft3/`
- `.artifacts/M31/phone-audit-diagnosis/E5-preparation/run-78xobxxx/`

Earlier interrupted 7f49552 and Watch failures remain preserved separately. No
failed native invocation is reclassified as passed or baseline-reproduced.

## Exact correction and affected scope

Baseline test file SHA256:
`077c100a42d65763bfff1c2a42ec27db9ad706c022c6f18f8adc23c3fd1e1c15`.
Final prepared test file SHA256:
`477b7870d94f0aec4afc0fe66c9517657296915c7463310ab0ac98b63d5f7ca0`.
Prepared patch/source/identity/driver:
`.artifacts/M31/phone-audit-diagnosis/final-boundary-correction/`.

Only the boundary method's second post-Undo audit uses the original six categories
individually: contrast, textClipped, elementDetection, hitRegion,
sufficientElementDescription and trait. Before each category, a finite maximum
24 short drags restores the original card offset and viewport; changed layout or
an unreachable position fails. Original assertions and both appearance loops stay.
Before/after every category, points/context/games/sets/server/status labels and Undo
enabled state must match the captured post-Undo state. XCTContext names identify
each appearance/category; diagnostic print statements and catch/rethrow timing
instrumentation are removed. No native retry, omitted category or accepted issue
is added. Six uses of the existing helper's one-second delay change timing and are
disclosed; they are not proof of the underlying timeout cause.

The shared helper changes only by adding an optional `auditTypes` parameter whose
default is exactly the previous six-category union, and passing that parameter to
the original native call. Every other helper byte, including strict issue handling
and mandatory occluded-element rechecks, remains identical to baseline. Every other
test method is byte-identical. All existing callers retain the same default native
union and behavior. The boundary's first audit and the fresh predecessor exercise
that unchanged default. No product, gameplay, storage, layout, resource, project,
scheme, dependency or configuration input changes in this correction.

## Predeclared finite validation and acceptance boundary

Under the [explicit affected-only owner authorization](owner-impact-verification-authorization.md),
commit reviewed source and evidence on clean primary `main`, then invoke ONCE:

```sh
python3 .artifacts/M31/phone-audit-diagnosis/final-boundary-correction/run.py --candidate <full-40-character-SHA> --run
```

This obtains the existing managed companion lease and runs one `xcodebuild test`
with exactly the predecessor `testKnownScoreRealInputPreviewCancelScoreUndoAndRelaunch`
and the boundary method, using fixed `-test-iterations 5`. It is predeclared
five-iteration affected validation, not retry-on-failure or run-until-success.
All five invocations of both definitions must pass: **2 distinct definitions,
10 invocations**. Each boundary invocation must retain both appearances and all
six categories. A failure, skip, expected failure, runtime warning, missing
invocation, incomplete bundle or source/environment change blocks acceptance;
there is no automatic extra unaltered attempt. The canonical full-gate parser and
its rejection of repeat arguments remain unchanged. This focused evidence must
be explicitly labeled as owner-directed impact validation, never full make PASS.

The driver binds clean source before/after, exact corrected file, only allowed AI
Markdown delta from the original base, exact selectors/configuration/destination,
and prior finalized E5 evidence. Actual native repetition nodes, counts and console
must be independently parsed and hash-bound before coverage is accepted; an exit-zero
wrapper alone is insufficient. All historical failures remain in the evidence.

Proposed reuse after that validation: the exact-source-continuous 640 Watch,
21 phone unit and 19 other phone UI definitions from the completed full invocation.
The predecessor is freshly rechecked as control. Final coverage union is therefore
680 reused plus 2 freshly validated definitions, 682 distinct definitions total;
no failed definition is reused as a pass. Runtime/toolchain/build-input continuity,
reviewed corrected-route coverage, domain disposition and required non-test checks
remain pending. Real Release builds, package/signature checks and external build/
submission checks remain required under the owner decision. No DONE, accepted
coverage, clean candidate SHA, or no-open-P0/P1 conclusion is recorded here yet.
