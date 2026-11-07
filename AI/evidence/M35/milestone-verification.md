# M35 final distribution verification

**Policy status:** current

M35 distribution is verified. App1.0(8) and the first lifetime IAP were submitted
together through the ordinary enabled App Store Connect UI. Apple confirmed
"2 Items Submitted"; independent GET-only server readback confirmed the actual
submission and product identities. This is not App Review approval or public launch.

## Exact validation

| Field | Evidence |
| --- | --- |
| Closure candidate | `0f4a649fb8893d6d78f17bf8f68a8ef202354d56` |
| Canonical archive source | `85e49918d004d73b526ae04582d6b18e3250e3b7` |
| M34 readiness | `38c5e0ee38ae076df8264210c2d0c65c5058f580` |
| Command | `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/validate-distribution.py` |
| Exit | 0 |
| UTC interval | 2026-11-07T19:04:10.792761+00:00–2026-11-07T19:04:11.101797+00:00 |
| Report | `.artifacts/M35/evidence/distribution-validation.json` |
| Verdict | M35_DISTRIBUTION_VERIFIED |
| Counts | Reused693definitions/1156invocations; fresh tests0;42metadata records,238placements/233unique images/14locales; one signed archive/export,IPA reinspection,Apple validation and upload;6PDF pages |

The final helper requires clean HEAD and AI-Markdown-only continuity from the
archive source. It validates the genuine prior readiness/preparation artifacts,
archive/upload identity, image order and metadata contents, complete guide/package,
actual UI observation, raw server readbacks and the existing monitor binding.
Reused results: Watch650/1104,phone unit21/30,phone UI22/22; all passed, no failures,
skips, expected failures or runtime warnings. No application, test or configuration
change. Full `make milestone ID=M35` NOT RUN under the explicit owner reuse route;
no full-make result is invented. Earlier failures remain preserved in
[preparation evidence](distribution-preparation.md).

## Actual submission

- Submitted at2026-11-07T18:53:50.524Z.
- Submission `1827bb2a-e66d-4ef9-9b01-9faf11baafd3`: WAITING_FOR_REVIEW.
- App6825393194/version1.0 ID`c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3`: WAITING_FOR_REVIEW.
- Selected build8 ID`da38d24f-dd8f-4c6e-a512-7c2771b3262b`: VALID, not expired.
- First lifetime IAP6825393394/product`com.dziachenka.padelscore.lifetime`: WAITING_FOR_REVIEW.
- Exactly two related server items; IAP version`d96baf47-39f7-4632-856e-b2cd28ec458f` belongs to this product. Item resources themselves retain READY_FOR_REVIEW while the submission/app/IAP are WAITING_FOR_REVIEW; both actual representations are preserved.
- Release policy AFTER_APPROVAL unchanged. No price mutation or public availability claimed.

Actual GET-only command:
`ruby .artifacts/M35/closure/read-final-submission.rb --submission-id 1827bb2a-e66d-4ef9-9b01-9faf11baafd3`,exit0.
Receipt/raw paginated responses:
`.artifacts/M35/final-submission-readback/20261107T185755Z-e90815be/receipt.json`.
A second read,`ruby .artifacts/M35/scripts/read-state.rb .artifacts/M35/evidence/asc-submitted.json`,exit0,
confirmed the same selected build, submission, products, exact final Notes and
COMPLETE attachment at18:58:22Z. Normalized receipts are in
`.artifacts/M35/evidence/submission-confirmed.json` and `ui-submission-observation.json`.

## Updated response delivered with the submission

Both historical submissions were Removed/COMPLETE and offered no Reply control.
This matches Apple's documented reply flow for unresolved rejected submissions:
[Reply to App Review messages](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/reply-to-app-review-messages).
The owner requested autonomous completion. The response therefore uses the ordinary
Review Information attachment channel, explicitly referenced in final Review Notes.
No conversation message was sent and no Apple message ID is fabricated.

The exact3991-character [response](app-review-response.md) occupies two PDF pages,
followed by the four original guide pages. The original guide content streams and
image bytes are unchanged; PDF text extraction confirms every response paragraph;
all six rendered pages were visually inspected. Final package:
`.artifacts/M35/output/pdf/build8-review-response-and-guide.pdf`,344997bytes,
SHA256`be7767caabd4f43f68231dd5c05f6e3cace75f4e81a54ccd9a3ba05799183268`.

Actual attachment`6dfe136b-2b91-43e0-8887-96d6ac5e757e` became COMPLETE at
18:52:22.674074Z, before submission; server MD5`50345c1188b922d915e5dabb9fa8c0ec`
matches uploaded bytes. Command:`ruby .artifacts/M35/review-package-attachment/attach-guide.rb upload`,exit0.
The previous guide-only attachment's bytes/receipt were retained before replacement;
the new package includes that same guide. UI removal attempts timed out without
changing the old attachment; the official API performed the verified replacement.
Initial local PDF text-check failure was due to page headings between paragraphs;
per-paragraph exact comparison now passes, without altering the response text.

Exact delivery record:`.artifacts/M35/evidence/response-delivery.json`,
SUBMITTED_AS_REVIEW_ATTACHMENT,`messageSent:false`.
Final [Review Notes](review-notes.md):3856characters. Preparation receipts remain
historical and still refer to the earlier guide-only attachment/Notes.

## Monitoring and closure

Existing hourly heartbeat`padel-score-lifetime` remains ACTIVE with the same name,
schedule and target thread. Its exact configuration was read back after updating
actual submission/build/response bindings. Phase SUBMITTED_AWAITING_PUBLICATION;
no stale login blocker or fictional sent message. Evidence:
`.artifacts/M35/evidence/monitor-readback.json`, `automation-submitted-readback.json`,
`monitor-guard.json`. It remains read-only; no price/countdown starts from submission.
Before future price writes, a compatible M34/M35 proof package is required; the
historical M30 scheduler/frozen package must not be applied to build8.

Builder self-review only. No new product defect or independent audit is claimed.
After marking DONE, run static/status/continuity on the exact closure commit and
retain logs/receipts under`.artifacts/M35/post-done/`; final evidence-commit checks
under`.artifacts/M35/post-done-final/`. Synchronize final AI-only records with public
main, preserving the actual archive source identity above.
