# M30 — App Review Response and Resubmission

**ID:** M30
**Status:** PLANNED
**Depends on:** M26
**Validation:** make milestone ID=M30
**Handoff:** AI/handoffs/M30-handoff.md

## Objective

Deliver the approved M30 outcome.

## Scope

Owner-approved [gesture plan](../gesture-differentiation-plan.md),2026-10-29.

Separate distribution task: prepare new factual4.3(a) response/Review Notes and attach
an illustrated current-build guide (no video, explicitly approved2026-11-02); correct the obsolete no-competitor-research assertion. Review
accessible GitHub history/selected ChatGPT links as supplementary provenance.

## Acceptance criteria

- [ ] M26 candidate/build/readiness and all new assets match; prior draft stays superseded.
- [ ] Owner explicitly instructs distribution for this candidate before external reply/submission.
- [ ] Actual metadata/screenshots/build and monitor identity are uploaded/read back.
- [ ] Reply and ordinary resubmission are confirmed by actual server state, never inferred.
- [ ] Actual owner-approved m30-preflight passes before external reply/submission, all unique archive/signature/distribution checks complete, and exact evidence/handoff are recorded.

## Non-goals

No monetization change or unsupported uniqueness claim. Preserve previously authorized AFTER_APPROVAL; no separate publication action.

## Validation

[Fresh owner decision](../evidence/M31/owner-impact-verification-authorization.md)
replaces repeated unchanged Debug suites. The generic Validation header remains
parser metadata, not a fabricated successful full-make receipt. Before external
sending/submission, run the actual current-candidate stage:

```sh
python3 .artifacts/M30/impact-validation/run.py --stage m30-preflight --candidate <M30_FULL_SHA> --coverage-manifest <ACTUAL_MANIFEST> --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt <ACTUAL_M26_FINAL_RECEIPT>
```

Require completed M26, genuine same-release-candidate readiness, current domain/
static/source coverage and proved AI-Markdown-only continuity for an allowed M30
successor. Typed padel-impact-gate/1 receipts must retain actual command/exits/hashes
and identify reused versus freshly executed checks. Any affected input change needs
fresh verification; original failed full runs remain failed and disclosed.

Preserve signed archive/export and identity/provisioning/signature checks, actual
upload/VALID/selected build, all14 metadata/image readbacks, first lifetime IAP,
public matching GitHub history, sent reply+guide BEFORE ordinary joint resubmission,
and server-confirmed submission. Preserve AFTER_APPROVAL and existing monitor:
no duplicate, no promotion countdown before actual public availability. Adapters
must validate actual new receipts, never synthesize old make reports or unchecked
readiness flags. Self-review is not independent approval. Record exact candidate,
commands/exits/reports/counts and distribution identities; DONE and final static/
status/continuity only after the entire authorized outcome is confirmed.

Owner distribution/public GitHub authorization remains [the original2026-11-02 decision](../evidence/M31/owner-authorization.md). No external success is asserted by this contract.
