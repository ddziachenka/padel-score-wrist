# M26 — Release Readiness Revalidation

**ID:** M26
**Status:** DONE
**Depends on:** M31
**Validation:** make milestone ID=M26
**Handoff:** AI/handoffs/M26-handoff.md
**Revalidated domains:** functional, ui-ux, content, accessibility, product, release
**functional revalidation record:** AI/audits/M31-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/M31-ui-ux-revalidation.md
**content revalidation record:** AI/audits/M31-content-revalidation.md
**accessibility revalidation record:** AI/audits/M31-accessibility-revalidation.md
**product revalidation record:** AI/audits/M31-product-revalidation.md
**release revalidation record:** AI/audits/M31-release-revalidation.md

## Objective

Establish fully passing release evidence for the new exact candidate and prepare the next binary.

Approved owner scope: [recovery plan](../recovery-differentiation-plan.md), 2026-10-27.

## Scope

Current six-domain records, migration/package validation, new archive/build identity and candidate continuity; exact-candidate impact verification with all unique Release/build/package checks preserved; prepare resubmission evidence and launch-monitor guard for the new candidate.

## Acceptance criteria

- [x] M29 DONE and all six domain records current with no missing required coverage or unaccepted failure.
- [x] Actual m26-preflight, release and m26-final stages pass on the same clean exact candidate, with validated reused/affected coverage and every unique Watch/iPhone Debug/Release build/package check preserved.
- [x] Actual package/version/build/provenance and migration evidence match the candidate; historical M18 acceptance is not transferred.
- [x] Monitor candidate/build guard is updated and read back before future publication work; submission remains a separate owner decision.

## Non-goals

No M18 gate consolidation, contrast waiver, automatic submission or promotion before public availability.

## Validation

[Fresh owner decision](../evidence/M31/owner-impact-verification-authorization.md)
replaces duplicated unchanged Debug suites, not unique release checks. The generic
Validation header remains parser metadata; do not claim an unexecuted original
make command passed. Actual sequence, using final real paths:

```sh
python3 .artifacts/M30/impact-validation/run.py --stage m26-preflight --candidate <SAME_FULL_SHA> --coverage-manifest <ACTUAL_MANIFEST> --authorization AI/evidence/M31/owner-impact-verification-authorization.md
python3 .artifacts/M30/impact-validation/run.py --stage release --candidate <SAME_FULL_SHA> --coverage-manifest <ACTUAL_MANIFEST> --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt <ACTUAL_M26_PREFLIGHT_RECEIPT>
python3 .artifacts/M30/impact-validation/run.py --stage m26-final --candidate <SAME_FULL_SHA> --coverage-manifest <ACTUAL_MANIFEST> --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt <ACTUAL_RELEASE_RECEIPT>
```

Receipts use padel-impact-gate/1 and distinguish executed steps from validated
reuse. Preflight is not READY_FOR_HUMAN. Release retains unique Debug/Release builds,
independent Watch/iPhone packaging, version/channel/secret/privacy checks, migration
compatibility, current six-domain coverage and no open known P0/P1. M26 final must
consume successful release evidence for that same SHA. Record actual commands,
exits, reports/hashes, native reused/fresh counts and retained failure/risk history.
No old contrast acceptance is imported; changed inputs invalidate affected reuse.
Finalize handoff/DONE/static/status/continuity, then continue the already-authorized
M30. Its archive/signature/upload/distribution checks remain mandatory.

Owner authorizes subsequent M30 distribution under [the current plan](../evidence/M31/owner-authorization.md); readiness remains mandatory. Actual stage outputs, not this contract, establish completion.
