# M18 handoff — Release Readiness Revalidation

**Policy status:** current

## Milestone

M18 — DONE under exact explicit owner acceptance. Raw VERIFICATION_FAILED,
not an automated READY_FOR_HUMAN or independent approval.

## Summary

Established current candidate-bound companion release evidence after six M17
domains. Both full platforms, clean Debug/device Release builds, strict packaging
and release policies retained. Prepared signed server-validated new1.0(2) for the
owner-authorized upload/TestFlight/normal joint app+lifetime submission.

## Changed files

- AI/milestones/M18-release-readiness-revalidation.md and WORKFLOW: before-start
  consolidation of redundant unstarted milestone rerun into full immutable release.
- AI/evidence/M18/release-verification.md, handoff/status: exact current evidence.
- No App/Config/Scripts change since M17 `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77`.

## Validation

| Field | Evidence |
| --- | --- |
| Exact candidate | `572e3524157154f9104edab61b1d4311de437857`, clean REVIEW/main |
| Exact command | `make release CANDIDATE=572e3524157154f9104edab61b1d4311de437857` |
| Raw exits/verdict | Make2/verifier1/UI65; VERIFICATION_FAILED |
| UTC | 2026-10-24T23:45:37.836428+00:00–2026-10-25T02:20:49.384672+00:00 |
| Report | `.artifacts/release/20261024T234539Z-52536/report.md` |
| Counts | Watch510/884 passed; phone unit14/20 passed; UI6executed,4passed/2native Contrast failed;0 skipped/expected/runtime warnings |
| Accepted disposition | OWNER_ACCEPTED_FOR_SUBMISSION; exact M16/M17 owner acceptance only |
| Distribution package | New02ec9c9source IPA `820e0ab32614f429225b67ab78ce614f23f7a65a4db77a1b0ca48cc24d823e0d`, archive/export/package/signature/Apple validation all0 |

Generated human checklist `.artifacts/release-checklists/572e3524157154f9104edab61b1d4311de437857/checklist.md` has3pending manual rows at gate
time, retained as pending, not automated passes. Full native per-platform timestamps,
commands, bundles and
preserved raw result: AI/evidence/M18/release-verification.md. The unstarted extra
make milestone ID=M18 was consolidated before M18; not executed/not passed.
Closing static/status/continuity commands are preserved under .artifacts/M18/.

## Tests

No tests or parsers changed in M18. All required Watch/iPhone suites executed.
Known optional-review UI interference corrected and verified in M17, production
behavior unchanged. Strict package guards retained; owned Watch cache cleaned
before full release to remove prior hosted XCTest injection. No retry into a pass.

## Known issues

Only two native SE3/iOS17 Contrast failed tests remain owner-accepted based on
passed current-iOS27 audits. Accepted existing physical-pair coverage stands;
fresh Sandbox acquisitions/reinstall/additional physical AT scenarios not executed
or labelled passed. Generated manual checklist state remains separate evidence.

## Next step

Upload current IPA, wait VALID build2, owner TestFlight check, selectnewbuild/notes/
AFTER_APPROVAL, update monitor with exact IDs, then normal ASC app+first IAP Submit
under existing authorization. Confirm Waiting for Review/In Review; record exact
build/submission ID in a distribution handoff. No public offer clock until actual
public availability. Keep neutral promo and original175regional price baselines.
