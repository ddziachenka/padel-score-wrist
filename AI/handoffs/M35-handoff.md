# Milestone handoff

**Policy status:** current

## Milestone

`M35` — Serve-side Release and Resubmission; status `BLOCKED`.

## Summary

Owner accepted M34 human checks and authorized release. Build1.0(8) was archived,
signed, inspected, Apple-validated, uploaded once, processed VALID and selected.
Current metadata,238 images and the four-page L/R guide are saved and verified.
Revised4.3(a) response is ready. Sending and joint app+IAP submission require the
owner to restore the expired App Store Connect browser login; neither has occurred.

## Changed files

- `AI/evidence/M35/` — owner acceptance, exact response/notes and distribution proof.
- M35 contract, `AI/PROJECT_STATUS.md`, this handoff — actual state and resume steps.
- M34 handoff — follow-up link to owner acceptance, preserving historical readiness.
- Ignored `.artifacts/M35/` — signed archive/IPA, server receipts, local helpers,
  assets/readbacks and existing monitor binding. Preserve this directory.

## Validation

| Field | Evidence |
| --- | --- |
| Verified source SHA | `85e49918d004d73b526ae04582d6b18e3250e3b7` |
| M34 readiness SHA | `38c5e0ee38ae076df8264210c2d0c65c5058f580` |
| Exact preparation command | `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/validate-distribution.py --prepared-only` |
| Exit code | 0 |
| Timestamp | 2026-11-07T18:25:00.409191+00:00–2026-11-07T18:25:00.428000+00:00 |
| Report | `.artifacts/M35/evidence/prepared-validation.json` |
| Verdict | DISTRIBUTION_PREPARED_NOT_SUBMITTED; not M35 completion |
| Counts | Reused693 definitions/1156 invocations,0 failures/skips/expected/runtime warnings; fresh tests0; signed archive/export1,IPA inspection1,Apple validation1,upload1;42 metadata records,238 placements/233 unique images/14locales |

[Detailed commands, exits and bindings](../evidence/M35/distribution-preparation.md).
Full `make milestone ID=M35` was NOT RUN under the unchanged-input owner route;
final distribution validation was NOT RUN because reply/submission evidence does
not exist. No fabricated passing receipt or UI message/submission ID.

## Tests

No app/test/configuration changes. M35 preflight validated M34 readiness, unchanged
inputs and complete prior native results; current static/status/continuity passed.
Self-review checked metadata claims and demo instructions against the approved
M33 behavior and guide. German/French descriptions were shortened within4000
characters; the response is3991 characters. Review attachment replacement preserved
the original record/bytes; Apple processing eventually reached COMPLETE. This is
Builder self-review, not independent review.

## Known issues

Expired App Store Connect browser session prevents final reply and ordinary
submission. API readback18:25:10Z: PREPARE_FOR_SUBMISSION, AFTER_APPROVAL,
build8 selected/VALID, IAP READY_TO_SUBMIT; only historical submissions COMPLETE.
No public availability or offer-end date. Existing monitor remains read-only until
actual submission binding and a compatible M34/M35 pricing-proof guard are complete;
historical M30 scheduler must not run against build8.

## Next step

Owner signs in to the existing App Store Connect Chrome tab. Resume M35 directly:
send `.artifacts/M35/reply.txt` with `AI/store-assets/m33-review/review-guide.pdf`,
observe the sent message/attachment, then ordinary app+first IAP submission. Preserve
actual evidence and update existing `padel-score-lifetime`, not a new automation.
Run final `validate-distribution.py`, mark DONE only after success, then required
static/status/continuity and source synchronization. Do not re-upload build8,
recreate COMPLETE assets or rewrite immutable upload/readiness receipts. Later
AI-only closure commits preserve the canonical archive source above.
