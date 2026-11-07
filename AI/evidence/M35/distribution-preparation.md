# M35 distribution preparation

**Policy status:** current

Prepared successfully; not yet submitted. Owner authority is in
[owner-release-authorization.md](owner-release-authorization.md). The later request
to act autonomously removes redundant confirmations, not the need for a valid
browser login. M34 is DONE and its three human rows are accepted. M35 remains
BLOCKED pending authentication; no release/submission success is inferred.

## Identity and preparation result

- Readiness: `38c5e0ee38ae076df8264210c2d0c65c5058f580`.
- Archive/source: `85e49918d004d73b526ae04582d6b18e3250e3b7`, clean main at execution.
- Actual preflight: `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/preflight.py`, exit0; `.artifacts/M35/evidence/preflight.json`,17:29:01–17:29:39Z on2026-11-07.
- Actual preparation validation: `/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M35/validate-distribution.py --prepared-only`, exit0; `.artifacts/M35/evidence/prepared-validation.json`,18:25:00.409191–18:25:00.428000Z.
- Verdict: DISTRIBUTION_PREPARED_NOT_SUBMITTED. Receipt binds original archive,
  upload, metadata, images and guide records by SHA256.
- Reused full M33 native coverage via accepted M34: Watch650definitions/1104
  invocations, phone unit21/30, phone UI22/22; total693/1156, zero failures,
  skips, expected failures or runtime warnings. Fresh tests0. M34 retained four
  fresh Debug/Release builds. No app/test/configuration/material source changed.
- Full `make milestone ID=M35` NOT RUN under the owner-approved unchanged-input
  route. Final `validate-distribution.py` without arguments NOT RUN: required
  actual reply/submission evidence does not yet exist. Neither is claimed passed.

## Archive, signing, validation and single upload

Helper: `.artifacts/M35/archive-preparation/driver.py` with the direct Xcode Python
interpreter and `--gate-evidence .artifacts/M35/evidence/preflight.json`.
Actual modes `build-and-export`, `inspect-ipa` and `validate-server` all exited0.
The latter two used `--archive-run` pointing to the build/export directory below.
Every directory retains before/result/after receipts and actual native command
arguments,stdout/stderr/exit records; these are the primary execution evidence.

Common run root:
`.artifacts/M35/archive-preparation/runs/85e49918d004d73b526ae04582d6b18e3250e3b7/`.

| Actual mode | Run directory | Result |
| --- | --- | --- |
| build-and-export | `20261107T173016Z-7512ab78-build-and-export` | LOCAL_ARCHIVE_EXPORT_VERIFIED |
| inspect-ipa | `20261107T175551Z-02dafe24-inspect-ipa` | IPA_REINSPECTED |
| validate-server | `20261107T175551Z-dbfb46a4-validate-server` | APPLE_VALIDATED_NOT_UPLOADED |

Three executable bundles match1.0(8), bundle/profile/certificate identities,
iOS17/watchOS10 deployment minimums and archive/export Mach-O UUIDs. Deep signatures
validate, distribution profiles have no debug entitlement, and test fixtures are
absent. Signed IPA SHA256:
`8101dcc9b2907a3f456482baec4bc5abcea8fc10132a28448c7c2a13552c45ab`.

Actual uploader: `ruby .artifacts/M35/upload-build8.rb upload` with the three
successful run directories supplied as `--archive-run`, `--inspection-run`,
`--validation-run`. Exit0. Immutable attempt:
`.artifacts/M35/build8-upload/attempt.json`. Actual `xcrun altool --upload-package`
arguments and exit0 are recorded with credentials redacted in
`.artifacts/M35/build8-upload/20261107T180109Z-d6abf4b4-upload/upload-result.json`.
Upload acknowledged18:02:37.605524Z; VALID confirmed18:05:13.816592Z in `valid.json`.
No duplicate upload or uncertain-attempt retry.

## App Store materials and readback

| Actual command | Exit | Evidence/result |
| --- | --- | --- |
| `ruby .artifacts/M35/scripts/upload_metadata.rb` | 0 |42 saved/read-back records,14locales; `evidence/*Localizations-saved.json` |
| `ruby .artifacts/M35/scripts/assets_parallel.rb .artifacts/M35/assets-upload` | 0 |233 unique images processed; `assets-upload/result.json` |
| `ruby .artifacts/M35/scripts/assets.rb place` | 0 |238 placements in exact order; `evidence/placements-*.json`, `assets-placement.log` |
| `ruby .artifacts/M35/scripts/apply_release_build.rb da38d24f-dd8f-4c6e-a512-7c2771b3262b` | 0 |Build8 selected, AFTER_APPROVAL and exact Review Notes saved/read back |
| `ruby .artifacts/M35/review-attachment-v2/attach-guide.rb poll` | 0 |Guide COMPLETE,18:20:49.342339Z; `review-attachment-v2/complete.json` |
| `ruby .artifacts/M35/scripts/read-state.rb .artifacts/M35/evidence/asc-prepared.json` | 0 |Actual final preparation state18:25:10Z |

Paths in this table are relative to `.artifacts/M35/` unless fully written.
Guide: `AI/store-assets/m33-review/review-guide.pdf`, four pages,278180bytes,
SHA256 `fc98bf5dcacc2576bf52dad871ac4069cad9726840f8b957c991e3b7fafd1f3e`.
Actual attachment `42b7c21d-acb3-457a-a791-1d4905453189`,filename
review-guide-build8.pdf; server MD5 `53305f37a97814f90971261185d6ef1a` matches bytes.

Original second-attachment create failed409 (one-attachment limit),exit2; it did
not create a duplicate. Existing build7 attachment record and matching old PDF
were preserved before its necessary replacement. New reservation upload succeeded;
initial polling exited3 while UPLOAD_COMPLETE, then GET-only reconciliation above
confirmed COMPLETE. One later sandbox-network read failed2 and was rerun with
network permission; original failures/pending receipts remain. No failure is
reported as a pass and no processing requirement was relaxed.

L/R semantics in description/notes/reply follow approved M33: next rally, server's
view facing the net; golden point receivers' choice; every Americano server block
startsR even with odd length; undo/correction derive restored side; indicator hidden
after Finish/while serving confirmation is pending. VoiceOver reads the full side.
German/French descriptions were shortened to fit4000characters. Store metadata
contains no new promotional-price promise.

Exact response draft: [app-review-response.md](app-review-response.md),3991characters,
identical to `.artifacts/M35/reply.txt`. It is NOT SENT. Review Notes3616characters
are saved on Apple; [review-notes.md](review-notes.md). The planned reply guide is
already attached to Review Information, but no sent-message attachment is claimed.

## Actual external state and continuation

App6825393194/version1.0 ID`c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3` is
PREPARE_FOR_SUBMISSION, AFTER_APPROVAL. Selected build8 ID
`da38d24f-dd8f-4c6e-a512-7c2771b3262b` is VALID. Lifetime IAP6825393394 remains
READY_TO_SUBMIT. Historical submissions are COMPLETE; no new submission exists.
Browser observed the Apple Sign In page; owner authentication is required to send
the response and use ordinary joint submission. No disabled control or private
submission endpoint was bypassed.

`git push origin main`,exit0, published source85e49918d004d73b526ae04582d6b18e3250e3b7;
`git ls-remote origin refs/heads/main`,exit0, confirmed it. Initial source-sync logs
are `.artifacts/M35/github-push.log` and `github-readback.txt`. Later AI-only
handoff commits may advance public main without changing the uploaded binary.

Existing hourly heartbeat `padel-score-lifetime` was updated and its full saved
configuration read back exactly. Same ID/name/hourly schedule/target thread,
ACTIVE, BUILD_BOUND_AWAITING_SUBMISSION. Evidence:
`.artifacts/M35/evidence/monitor-readback.json`, `automation-before.json`,
`automation-after.json` and `monitor-guard.json`. New source/build/guide/preparation
proofs are bound. Monitor stays read-only; no reply, new submission, launch
countdown or price write. Historical M30 frozen guard is unchanged. A later actual
submission must update this same binding; future price writes additionally require
a compatible M34/M35 proof package, not the old M26/M30 scheduler.

Resume this milestone after login. Preserve successful binary/material operations,
send the prepared response+guide, observe actual sent evidence, submit app+first
IAP normally, verify actual server IDs, bind monitor, run final validation and only
then mark M35 DONE. Required closure checks remain explicit; preparation alone is
not a completed distribution milestone.

Checkpoint `c10d5928deb155b9d19954be1dfe1fa002f7de8b` passed `make static`,
`./Scripts/project-status.sh validate` and
`./Scripts/project-status.sh continuity 85e49918d004d73b526ae04582d6b18e3250e3b7`,
all exit0. Exact UTC intervals, commands and log hashes:
`.artifacts/M35/checkpoint/receipt.json`. This verifies the blocked handoff and
AI-only continuity; it does not turn preparation into completed submission.
