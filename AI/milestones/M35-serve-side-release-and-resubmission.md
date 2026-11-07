# M35 — Serve-side Release and Resubmission

**ID:** M35
**Status:** BLOCKED
**Depends on:** M34
**Validation:** make milestone ID=M35
**Handoff:** AI/handoffs/M35-handoff.md

## Objective

Distribute the verified build1.0(8) and submit the updated L/R experience with a
factual response to App Review4.3(a), under explicit owner instruction.

## Scope

Record owner human acceptance, preserve M34 readiness/source identity, validate a
signed archive/export and upload once, save/read back current store assets/notes,
send the updated response and four-page guide before ordinary app+IAP resubmission.
Bind existing source provenance and monitor to actual results. Preserve AFTER_APPROVAL.

## Non-goals

No app/test/configuration change, unsupported exclusivity claim, price change,
submission bypass or publication/launch countdown before genuine availability.

## Acceptance criteria

- [x] Owner confirmation and distribution authorization are recorded; M34 DONE and its exact readiness evidence validates against unchanged inputs.
- [x] Signed1.0(8) archive/export, three bundled executable/profile/signature identities, IPA reinspection and Apple validation pass; one upload processes VALID and is selected.
- [ ] Actual metadata/images, L/R Review Notes and four-page guide are saved and read back; updated factual response is sent before ordinary joint app+first lifetime IAP resubmission.
- [ ] Actual server submission/build/IAP state, source provenance and the existing monitor identity agree, with no promotion countdown before public availability.
- [ ] Distribution evidence validation and post-DONE static/status/continuity pass; exact commands, exits, SHA and reports are recorded.

## Validation for unchanged verified release

[Owner instruction](../evidence/M35/owner-release-authorization.md) authorizes
release after accepted M34, retaining prior full-test reuse for unchanged inputs.
Generic Validation metadata is not a claim of executing the full make command.
Actual preflight: `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/preflight.py`.
It must validate genuine M34 padel-m34-reuse-gate/1 success, all bound artifacts,
complete reused results, current clean main/source continuity and current static.
Final: `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/validate-distribution.py`.
Require actual signed archive/upload/metadata/reply/submission/monitor evidence;
no placeholder receipts. Preserve prior failures and M33/M29 physical limits.

## Current external dependency

Preparation passed `validate-distribution.py --prepared-only`, exit0, at source
`85e49918d004d73b526ae04582d6b18e3250e3b7`. Build8 is VALID and selected;
42 metadata records,238 ordered image placements and the COMPLETE PDF are verified.
The browser session has expired and requires the owner to sign in. Reply and joint
submission have not happened. This is an authentication dependency, not a request
to approve routine release work. Resume this same milestone after login; do not
re-upload the binary or recreate existing assets. [Evidence](../evidence/M35/distribution-preparation.md).
