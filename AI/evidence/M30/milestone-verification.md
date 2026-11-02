# M30 verification and distribution evidence

**Status: DONE.** Ordinary app+IAP submission and material delivery are confirmed below. Final repository closure and public documentation identity are recorded in the linked actual receipts.

Exact M30/archive/public GitHub source `2d0e71b92592937c746a942d375b22e6e647eb96` is an allowed AI-Markdown-only successor of M26/release `263be849dd7981b192bb6f4de49887b953007420`. Version1.0/build7. Fresh owner affected-test policy: `AI/evidence/M31/owner-impact-verification-authorization.md`; no historical automatic/contrast waiver inherited and no original full make command fabricated.

## Actual candidate gate commands

### m26-preflight

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/Shared/D/ios/padel-score/.artifacts/M30/impact-validation/run.py --stage m26-preflight --candidate 263be849dd7981b192bb6f4de49887b953007420 --coverage-manifest .artifacts/M31/impact-reuse-policy/coverage-manifest-M26-263be849.json --authorization AI/evidence/M31/owner-impact-verification-authorization.md
```

Exit 0; M26_PREFLIGHT_VERIFIED; 2026-11-02T19:56:46.841662+00:00 to 2026-11-02T19:57:42.447085+00:00.
Receipt: `.artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/m26-preflight-miy67uq_/receipt.json`; SHA256 `536d80dc9ac7cc64c3457e66e27e22bf1c370c22cd72e29231ed70cea4de11e3`.

### release

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/Shared/D/ios/padel-score/.artifacts/M30/impact-validation/run.py --stage release --candidate 263be849dd7981b192bb6f4de49887b953007420 --coverage-manifest .artifacts/M31/impact-reuse-policy/coverage-manifest-M26-263be849.json --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt .artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/m26-preflight-miy67uq_/receipt.json
```

Exit 0; READY_FOR_HUMAN; 2026-11-02T19:58:01.422238+00:00 to 2026-11-02T20:00:34.685044+00:00.
Receipt: `.artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/release-4quzr2m9/receipt.json`; SHA256 `6c01e7f17cc79515fd4edc40021ecb6aa21c0ffd8f5fca71d2b98b41ce9924aa`.

### m26-final

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/Shared/D/ios/padel-score/.artifacts/M30/impact-validation/run.py --stage m26-final --candidate 263be849dd7981b192bb6f4de49887b953007420 --coverage-manifest .artifacts/M31/impact-reuse-policy/coverage-manifest-M26-263be849.json --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt .artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/release-4quzr2m9/receipt.json
```

Exit 0; M26_DELTA_VERIFIED; 2026-11-02T20:01:15.665557+00:00 to 2026-11-02T20:02:08.204560+00:00.
Receipt: `.artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/m26-final-1ionljw0/receipt.json`; SHA256 `a2067f5637a19d90b1a50c87e10e62a3090a4a6616e1b6921f60660b5589534e`.

### m30-preflight

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/Shared/D/ios/padel-score/.artifacts/M30/impact-validation/run.py --stage m30-preflight --candidate 2d0e71b92592937c746a942d375b22e6e647eb96 --coverage-manifest .artifacts/M31/impact-reuse-policy/coverage-manifest-M30-2d0e71b9.json --authorization AI/evidence/M31/owner-impact-verification-authorization.md --prior-receipt .artifacts/M30/impact-validation/runs/263be849dd7981b192bb6f4de49887b953007420/m26-final-1ionljw0/receipt.json
```

Exit 0; M30_PREFLIGHT_VERIFIED; 2026-11-02T20:16:07.978352+00:00 to 2026-11-02T20:17:00.655142+00:00.
Receipt: `.artifacts/M30/impact-validation/runs/2d0e71b92592937c746a942d375b22e6e647eb96/m30-preflight-t1ynz1em/receipt.json`; SHA256 `20fb7233a6edb11f4b093ebdb81930121f325d8ef4042e4ec5c43f1717b37131`.

## Coverage and unique builds

Current six-domain audits retain128 applicable mappings with no known product P0/P1. Native union682definitions:640Watch/1092invocations +21unit/30 +19otherUI/19 reused, plus2affected UI definitions/10fixed fresh invocations. Required normalized1143; actual evidence1151. Failed original runs are not in the passed union. All six native audit types and both appearances remain covered; snapshot state capture changed only test querying, not app behavior.

Four actual unique release-stage builds passed: Watch Debug, Watch Release, phone Debug, phone Release. Package inventories2Watch bundles/config and3phone+Watch+launcher bundles/config, all1.0(7), privacy manifests source-matched. These builds alone do not assert signing. M26's initial historical-schema preflight failure remains recorded; historicalM10 uses its exact verified schema/config and closed record lineage, while current128 mappings stay mandatory.

## Signed archive, IPA and actual upload

All successful runs share `.artifacts/M30/archive-preparation/runs/2d0e71b92592937c746a942d375b22e6e647eb96/`:

| Stage | Run | Actual result / exit |
| --- | --- | --- |
| Archive/export | `20261102T203436Z-1671ff39-build-and-export` | LOCAL_ARCHIVE_EXPORT_VERIFIED /0 |
| Re-extract/reinspect IPA | `20261102T203540Z-6938e568-inspect-ipa` | IPA_REINSPECTED /0 |
| Apple validation | `20261102T203555Z-8f36dc77-validate-server` | APPLE_VALIDATED_NOT_UPLOADED /0 |

Actual direct Xcode Python driver modes are `build-and-export`, `inspect-ipa`, `validate-server`, all with `--readiness .artifacts/M30/evidence/readiness-receipt-collision.json --gate-evidence .artifacts/M30/evidence/impact-archive-proof-receipt-collision.json`; latter two also specify the exact successful archive run above. PATH preferred `/Applications/Xcode.app/Contents/Developer/usr/bin`. All exact xcodebuild/codesign/security/altool commands and numeric exits are retained inside numbered run records; private key contents were never emitted.

Final driver SHA256 `c45af3f01a21b88443ae85ba25bb20c716937b557b1d887badc5a30bfcaf92ed`; readiness SHA256 `5b697e419e7448804e465a4f8e2a0589631ba7a213d8c449e5c4e5801dce2296`; proof SHA256 `3154d8a1ff0f0dc1bcdaea710a97efc65a541ae613bd6d0f015e2faf77809a56`. Every refresh preserved old immutable proofs/failures and revalidated actual source coverage, without rerunning unrelated native suites.

Three earlier failed archive runs remain FAILED_NOT_UPLOADED: `20261102T201819Z-c2b5efa2` (development wildcard authorization mismatch), `20261102T202855Z-d189a5f8` (codesign optional-prefix syntax), `20261102T203148Z-fa63cde3` (diagnostic/final identity filename collision). Corrections are bounded: recognize same-team development archive allowlist with exact signed identity; attach optional certificate prefix using `=`; save IPA diagnostic components separately. Exact final profile IDs/three UUIDs/certificate membership/no-debug/no-device-list, deep signature, bundle/version/OS, no test payloads and archive→IPA executable UUID equivalence all remain enforced.

Final IPA SHA256 `156774d0e68e7b09245a9b0a0311029ee32455420143055483c98958ca254371`,7054549bytes. One durable upload command:

```sh
ruby .artifacts/M30/upload-build7.rb upload --archive-run .artifacts/M30/archive-preparation/runs/2d0e71b92592937c746a942d375b22e6e647eb96/20261102T203436Z-1671ff39-build-and-export --inspection-run .artifacts/M30/archive-preparation/runs/2d0e71b92592937c746a942d375b22e6e647eb96/20261102T203540Z-6938e568-inspect-ipa --validation-run .artifacts/M30/archive-preparation/runs/2d0e71b92592937c746a942d375b22e6e647eb96/20261102T203555Z-8f36dc77-validate-server
```

Exit0. Build7 absence verified immediately before attempt; `.artifacts/M30/build7-upload/attempt.json` created20:37:34.329620Z. Altool ACK0 at20:40:56Z; delivery/build ID `20d3b56c-bf42-46b1-93e8-7a980dfd9db3`. Server uploadedDate `2026-11-02T12:42:01-08:00`; VALID observed20:43:32.988206Z. Actual valid receipt `.artifacts/M30/build7-upload/20261102T203733Z-c9387a5a-upload/valid.json`, SHA256 `e7efcc1016fc1c00b602d7e999aea439b0980fa9dcb8caa3ca40aa13f3ed4497`. ASC does not expose the IPA hash; correlation is fresh absence +one durable upload+unique new build/date. No second upload attempt.

Selected-version API readback `.artifacts/M30/evidence/version-selected-build.json` links app version `c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3` to this VALID build, APP_STORE_ELIGIBLE, usesNonExemptEncryption=false, AFTER_APPROVAL. That earlier PREPARE_FOR_SUBMISSION snapshot is historical; final readback `.artifacts/M30/final-submission-readback/20261102T212237Z-31f94c07/selected-version.json` now confirms the same selected build with WAITING_FOR_REVIEW.

## Metadata, materials, reply and ordinary UI workflow

`ruby .artifacts/M30/scripts/upload_metadata.rb` ran20:38:40.060700–20:39:37.071457Z, exit0. Actual stdout and saved readbacks confirm42 records:14 appInfoLocalizations +14 appStoreVersionLocalizations +14 inAppPurchaseLocalizations. Evidence `.artifacts/M30/metadata-assets-run-20261102T203836000Z/metadata.result.json`, metadata.stdout.log, and three `*-saved.json` files under evidence. Review Notes were saved/read back in `review-notes-saved.json`. Title remains Padel Score — Wrist; gestures subtitle/promotional copy are localized without exclusive claims or temporary price promises.

All actual materials verified at `2026-11-02T21:21:03.693169+00:00`:238/238 placements across14 ASC locales,17 each (112 Watch +98 iPhone screenshots;14 search +14 header creatives). The inventory contains236 unique READY images because two byte-identical es-ES/es-MX phone pairs share image IDs with strict source binding; this is not missing coverage. `ruby .artifacts/M30/scripts/assets_parallel.rb .artifacts/M30/assets-parallel-20261102T204505484Z` passed0 at21:10:29Z after waiting for all236READY; unchanged `ruby .artifacts/M30/scripts/assets.rb place` passed0 at21:21:03Z and read back all238placements. Completion `.artifacts/M30/metadata-assets-run-20261102T203836000Z/completion.json`, SHA256 `cd1b8a6e652ad375a073c43d8f743d334b98f3fc9db0f6c9779f0085899d68fc`, binds every14 locale readback, before-state backups, source/cache and actual command exits. Original serial upload exit1 while awaiting image processing remains preserved; subsequent four-worker transport reconciled existing images and retained exact dimensions/specs/source checks. No ambiguous create was retried and no unverified old image was reused.

New reply was observed sent at20:36:07.764Z in old rejected submission `17c2964a-e72b-4558-983f-4a40c5545d9f`, sender Dzmitry Dziachenka, attached `review-guide.pdf`; message ID not exposed by observed UI. `reply-sent.json` plus DOM/screenshot prove sent state and absent draft controls; full actual text is preserved byte-for-byte in [the exact sent English response](app-review-response-sent.md), tracked target `AI/evidence/M30/app-review-response-sent.md` (SHA256 `cd5a86cc123950a2dac525d5174305a741b9848023c66a26d89d6e02b13b2f92`,3237characters including final newline). Guide3pages, SHA256 `2cbf0fe67f6078f4e43b42daced94cfe88c3e4939226bad076e419c048f69271`.

The reply distinguishes new two-team gesture selection/selective journal/known-score start from retained current editor/unlimited sets; explains fixed five-second gesture sequence, preserved later winners/checkpoint limits, phone simulation, Batumi4–6monthly games, fivefree+lifetime purchase, and workflow-scaffold disclosure. GitHub/ChatGPT links are supplementary provenance, not exclusivity proof.

Ordinary Update Review was used; after sending this reply+PDF, ordinary Cancel Submission/Confirm canceled the old submission to restore editing. `evidence/ui/editing-workflow.txt`, editing-enabled DOM and `ui-editing.json` record this sequence, enabled controls and apiBypassUsed=false. This old cancellation is not a new submission or missing reply. The new ordinary joint submission is now confirmed: `7b10fa14-57eb-4f1d-9811-b26a1aebd857`, submittedAt `2026-11-02T21:22:35.821Z`, observed `2026-11-02T21:22:42.973129Z`. Submission, app version and IAP product state are WAITING_FOR_REVIEW. Exactly2 items are included: app version `c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3` selected build `20d3b56c-bf42-46b1-93e8-7a980dfd9db3`, and lifetime product `6825393394`/`com.dziachenka.padelscore.lifetime` via actual IAP version `d96baf47-39f7-4632-856e-b2cd28ec458f`. App item ID `N2IxMGZhMTQtNTdlYi00ZjFkLTk4MTEtYjI2YTFhZWJkODU3fDZ8ODkzNjA2NDg5`; IAP item ID `N2IxMGZhMTQtNTdlYi00ZjFkLTk4MTEtYjI2YTFhZWJkODU3fDE3fGQ5NmJhZjQ3LTM5ZjctNDYzMi04NTZlLWIyY2QyOGVjNDU4Zg`. Both item resources report READY_FOR_REVIEW; their membership in the submitted waiting submission and IAP product linkage were explicitly read back, without inventing different item states.

Actual post-send command `ruby .artifacts/M30/closure-preparation/read-final-submission.rb` returned0/SERVER_SUBMISSION_CONFIRMED; GET-only receipt `.artifacts/M30/final-submission-readback/20261102T212237Z-31f94c07/receipt.json`, SHA256 `ec2ab55f20f3f348e5b002dde0f18ea50090f9055dd26d822c4895eab7cc42f6`, binds6server responses for submission/items/product+versions/selected version/build. UI observation `.artifacts/M30/evidence/joint-submission-ui.json` at `2026-11-02T21:23:15.960Z` confirms the same new submission, version1.0/build7, twoitems, app+lifetime, WAITING_FOR_REVIEW and apiBypassUsed=false; DOM/screenshot paths are preserved. The reply and both guide destinations predate this submission. AFTER_APPROVAL is unchanged; this is not public availability.


### Supplemental guide on the new version — confirmed

The same approved PDF was additionally attached directly to current version App Review Information through Apple's documented App Store review attachments API, after fresh reconciliation found0existing attachments. This is separate from the PDF in the already-sent old rejection reply and is not an IAP screenshot. One POST reservation, one part PUT and one checksum/uploaded PATCH; no deletes or duplicate reservations.

Attachment `65ca94ee-6346-4e30-bc70-b0facc7fd6da`, review detail `60eb1661-5811-4775-a0b4-1e95d4ce9d04`, version `c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3`. Server COMPLETE confirmed2026-11-02T21:09:26.394643Z;252219bytes, server MD5 `2b985588a22f97c01e8ddd95a672981e`, same approved PDF SHA256 `2cbf0fe67f6078f4e43b42daced94cfe88c3e4939226bad076e419c048f69271`.

Actual upload command `PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH" ruby .artifacts/M30/review-attachment/attach-guide.rb upload` ended3 only because its bounded wait remained pending. Two GET-only `attach-guide.rb poll` continuations ended3 then0; pending was never mislabeled COMPLETE, and no reupload occurred. Receipt `.artifacts/M30/review-attachment/complete.json`, SHA256 `57c5b2bb86dd5087be131c68c9ac400f63509d6ca1c445ff56d7e0b399f17a1c`; execution-summary.json preserves actual counts/exits. Final GET record `poll-20261102T210732Z-poll-19.json` and after-attachments.json confirm exact checksum, current-version relationship and preserved existing attachment set.

## Public GitHub and monitor

Secret scan on exact source:2370textual reachable-main blobs,0pattern findings,exit0; binary content/entropy/external-secret validation not covered. `history-secret-scan-2d0e71b92592937c746a942d375b22e6e647eb96.json` and identity/execution siblings preserve scope. Ordinary `git push -u origin main` succeeded0 after a preserved sandbox DNS128 failure; no force. Both git ls-remote and unauthenticated API confirm public https://github.com/ddziachenka/padel-score-wrist at exact `2d0e71b92592937c746a942d375b22e6e647eb96`. Evidence `.artifacts/M30/github-publication/publication-receipt.json`. Any later documentation commit requires its own final synchronization/readback.

The owner-restored single heartbeat `padel-score-lifetime` was updated under the same ID and read back ACTIVE/hourly/exactprompt; duplicateCreated=false in `.artifacts/M30/monitor-install-M30-archive-1671ff39/automation-readback.json`. Earlier build/reply binding is retained historically. Final canonical guard/index are INSTALLED at `2026-11-02T21:24:29.473696+00:00`, phase SUBMITTED_AWAITING_PUBLICATION, actual build `20d3b56c-bf42-46b1-93e8-7a980dfd9db3` and submission `7b10fa14-57eb-4f1d-9811-b26a1aebd857`,326 hash-bound files. Guard SHA256 `33b095172ed6dbdf21852a6d71b704ac9fbc9d9d4393cf00ed1855ac2831bc76`; index SHA256 `c96a184ca1a707a8f0d7043ca55742ca7816ef166d4c46bd47e942f1b63b036d`. Receipt `.artifacts/M30/monitor-install-M30-submitted-ui-proof/receipt.json`, SHA256 `789cc11c6c4796a041c1ed2d499497e75b49c3e1a109f4a566b34c6eefbf6858`, exit0. SchedulingEnabled=false, publicationConfirmed=false; genuine UI-sent reply and ordinary UI+server submission proofs are bound. This historical install had FinalHandoffBound=false; the subsequent exact-byte handoff binding is separately recorded in `.artifacts/M30/monitor-install-M30-final-handoff/receipt.json`. No external action was taken by this local guard installation. AFTER_APPROVAL and original175region price baseline remain; no launch countdown until actual public availability. No promotion scheduler invoked by this work.

M29 owner physical acceptance remains bounded; no video or unmeasured recognition/timing result is represented as evidence. No product defect waiver or expanded physical claim added.

## Final repository closure

The documentation-only DONE commit preserves shipping source `2d0e71b92592937c746a942d375b22e6e647eb96`. Exact final HEAD, UTC timestamps, exit codes and logs live in `.artifacts/M30/closure-checks/receipt.json` for:

```sh
make static
Scripts/project-status.sh validate
Scripts/project-status.sh continuity 2d0e71b92592937c746a942d375b22e6e647eb96
```

Final exact handoff bytes are bound by `.artifacts/M30/monitor-install-M30-final-handoff/receipt.json`. Ordinary `git push origin main`, remote main SHA and public unauthenticated GitHub readback are recorded in `.artifacts/M30/github-final-publication/receipt.json`; this later documentation SHA is distinct from the signed binary source. No force push or second binary upload. These final local/remote receipts preserve their actual results without embedding a commit's own self-referential hash in its files.
