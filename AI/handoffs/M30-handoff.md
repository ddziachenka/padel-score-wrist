# Milestone handoff

**Policy status:** current

## Milestone

M30 — App Review Response and Resubmission. **DONE.**
Verification/source candidate `2d0e71b92592937c746a942d375b22e6e647eb96`; release/M26 candidate `263be849dd7981b192bb6f4de49887b953007420`.

## Summary

The verified 1.0 (7) archive was exported, reinspected, validated by Apple, uploaded once and processed VALID. The new build is selected in ASC. The new factual 4.3(a) reply and three-page illustrated guide were sent before ordinary resubmission. The same PDF is also attached directly to the new version’s App Review Information with server COMPLETE/checksum verification. Public GitHub history matches the exact source. All 42 localized metadata records were saved and read back. All 238 placements across14 locales were verified (236 unique READY images; two identical-image pairs shared source-bound IDs). The ordinary joint app+first lifetime IAP submission `7b10fa14-57eb-4f1d-9811-b26a1aebd857` was sent `2026-11-02T21:22:35.821Z`; API and UI confirm WAITING_FOR_REVIEW. [Exact English reply sent](../evidence/M30/app-review-response-sent.md).

## Changed files

- Closure files: `AI/handoffs/M30-handoff.md`, `AI/evidence/M30/milestone-verification.md`, M30 contract/status and `AI/evidence/M30/app-review-response-sent.md` (raw bytes identical to the actual sent reply).
- Actual ignored distribution evidence/scripts: M30 impact receipts; archive/upload runs; reply/guide/selection/metadata readbacks; GitHub publication; current monitor guard/index. No app behavior, storage schema or gesture mechanic changed in M30.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `2d0e71b92592937c746a942d375b22e6e647eb96`; M26/release `263be849dd7981b192bb6f4de49887b953007420` |
| Exact command | Actual direct-Xcode-Python `run.py --stage m30-preflight` command and all arguments copied verbatim into [verification record](../evidence/M30/milestone-verification.md); typed receipt `m30-preflight-t1ynz1em/receipt.json` |
| Exit code | M26 preflight/release/final 0/0/0; M30 preflight 0; archive/export, IPA reinspection, Apple validation, single upload/poll 0/0/0/0 |
| Timestamp | M30 preflight 2026-11-02T20:16:07.978352Z–20:17:00.655142Z; VALID observed 20:43:32.988206Z |
| Report | `.artifacts/M30/archive-preparation/archive-upload-handoff.json`; `.artifacts/M30/build7-upload/20261102T203733Z-c9387a5a-upload/valid.json`; complete paths/commands in [verification record](../evidence/M30/milestone-verification.md) |
| Counts | 682 definitions (680 reused +2 fresh); 1143 normalized required /1151 actual evidence invocations; 4 unique Watch/iPhone Debug/Release builds; 3 signed shipped bundles; 42 metadata records; 238/238 image placements from236 unique READY images,14 locales; actual joint submission2 items |

## Tests

Owner-approved affected verification retains the genuine native union and every unique Release/package/signature/distribution check; original full failures stay failed. No successful `make milestone ID=M30` is fabricated. Three failed archive attempts are preserved: historical development-profile wildcard was treated as exact AppID, optional codesign prefix used wrong argument attachment, and diagnostic IPA component output collided with final identity envelope. Bounded corrections preserve exact final distribution profile UUID/certificate/no-debug constraints and all component/UUID checks. Actual fresh final archive and reinspection passed. Root independently reviewed the profile correction; six offline cases and a real exported-certificate probe verified the specific fixes. These checks do not constitute an independent audit of the product.

## Known issues

No known open product P0/P1. The selected build `20d3b56c-bf42-46b1-93e8-7a980dfd9db3` is VALID; new submission/app version and lifetime product are WAITING_FOR_REVIEW. Both included item resources report READY_FOR_REVIEW; these exact item states are retained. Apple's review decision and public release remain future states. Final repository audit commands, exact closure SHA and numeric exits are recorded in `.artifacts/M30/closure-checks/receipt.json`; final ordinary push/public SHA readback in `.artifacts/M30/github-final-publication/receipt.json`.

M29 owner physical acceptance stays within its original bounds: no video, timing/recognition measurements or new physical evidence claimed. No exclusivity or unsupported competitor-price claim. AFTER_APPROVAL remains. The existing owner-restored heartbeat `padel-score-lifetime` was updated/read back under the same ID, without a duplicate; scheduling remains disabled until actual public availability. Final guard/index installed at `2026-11-02T21:24:29.473696+00:00` with phase SUBMITTED_AWAITING_PUBLICATION, the actual build/submission IDs and 326 hash-bound files. Scheduling remains false; no public availability is claimed. Receipt `.artifacts/M30/monitor-install-M30-submitted-ui-proof/receipt.json`. Exact final handoff binding is recorded in `.artifacts/M30/monitor-install-M30-final-handoff/receipt.json`; it does not enable promotion scheduling.

## Closure verification

Post-DONE commands: `make static`, `Scripts/project-status.sh validate`, and `Scripts/project-status.sh continuity 2d0e71b92592937c746a942d375b22e6e647eb96`. `.artifacts/M30/closure-checks/receipt.json` records the exact closure HEAD, commands, UTC times, logs and exit codes. These are documentation/status checks, not repeated native suites. The release source remains the SHA above; the later public documentation SHA is separately recorded in `.artifacts/M30/github-final-publication/receipt.json`.

## Next step

Await Apple's review decision. The existing monitor reports meaningful changes; preserve AFTER_APPROVAL and start the promotion countdown only after actual public availability. No development milestone remains and no duplicate submission or upload is needed.
