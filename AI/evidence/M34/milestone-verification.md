# M34 exact-candidate readiness verification

**Policy status:** current
**Verified SHA:** `38c5e0ee38ae076df8264210c2d0c65c5058f580`
**Baseline:** `a80826a35ddd319875ef18b000c099ee95fba353`
**Reused full M33 SHA:** `fd27bdc459a23e7880b3beb16711b92e6fc962aa`
**Verdict:** READY_FOR_HUMAN under fresh owner-authorized M33 reuse
**Exit code:** 0
**UTC interval:** 2026-11-07T16:57:46.980347+00:00–2026-11-07T17:00:11.863695+00:00
**Report:** `.artifacts/M34/reuse-validation/run-0d106av7/report.md`
**Typed receipt:** `.artifacts/M34/reuse-validation/run-0d106av7/receipt.json`
**Receipt SHA256:** `ad98a073464edee2a2611b0964bd82f7ca8702afbd0e6f3522c86f9f7e99484d`

## Actual command and scope

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/Shared/D/ios/padel-score/.artifacts/M34/reuse-validation/run.py --candidate 38c5e0ee38ae076df8264210c2d0c65c5058f580
```

[Exact owner instruction](owner-verification-reuse.md) permits crediting full M33
verification when inputs remain unchanged. `make milestone ID=M34` and
`make release CANDIDATE=38c5e0ee38ae076df8264210c2d0c65c5058f580` were NOT RUN under that instruction;
no exit code or full-make pass is attributed to them. This actual helper completed
both M34 continuity/coverage validation and fresh release-specific validation on
the same clean REVIEW/main candidate. No app/configuration/test/material change.

## Reused native coverage, revalidated from original bundles

| Component | Passed definitions | Invocations | Failed/skipped/expected/runtime warnings |
| --- | ---: | ---: | --- |
| Watch | 650/650 | 1104 | 0/0/0/0 |
| iPhone unit | 21/21 | 30 | 0/0/0/0 |
| iPhone UI | 22/22 | 22 | 0/0/0/0 |
| Aggregate | 693/693 | 1156 | 0/0/0/0 |

Fresh test execution: 0. These are reused M33 results, not new invocations.
Original full command `make milestone ID=M33` exited0 at
fd27bdc459a23e7880b3beb16711b92e6fc962aa, UTC2026-11-07T08:24:19Z–14:47:43Z.
The full report is `.artifacts/milestone/M33/20261107T082418Z-12381/report.md`;
bundles are `milestone.xcresult`, `companion/unit.xcresult`, `companion/ui.xcresult`
beneath that directory. Their actual summaries, test trees, legacy runtime/host/SDK
identities, every invocation leaf and all bundle bytes were checked before and
after release builds. Hash-bound coverage JSONs and raw reads live under the run.
Ancestry and every non-AI-Markdown tracked input are identical to M33. Saved M33
compiled-product plists match current Xcode/SDK metadata; original managed devices
and runtimes remain available. No manufactured historical tool binary hash.

## Fresh release-specific results

| Build | Exit | UTC interval | Log |
| --- | ---: | --- | --- |
| Watch Debug | 0 | 20261107T165834Z–20261107T165848Z | `.artifacts/M34/reuse-validation/run-0d106av7/clean-debug.log` |
| Watch Release | 0 | 20261107T165850Z–20261107T165912Z | `.artifacts/M34/reuse-validation/run-0d106av7/clean-release.log` |
| iPhone Debug | 0 | 20261107T165915Z–20261107T165934Z | `.artifacts/M34/reuse-validation/run-0d106av7/companion/companion-debug.log` |
| iPhone Release | 0 | 20261107T165936Z–20261107T170005Z | `.artifacts/M34/reuse-validation/run-0d106av7/companion/clean-release.log` |

All four builds use `clean build`; device Release uses CODE_SIGNING_ALLOWED=NO.
Actual command files and raw exit receipts are adjacent to each log. Canonical
Watch and iPhone package guards pass. Every built executable, embedded Watch and
launcher is1.0(8), with expected identifiers and independent-Watch packaging;
packaged privacy manifests match source and test payloads are excluded.
Current static/material/site/localization, all six M33 domains, channel, version,
secret/endpoint checks, immutable snapshot and clean-primary integrity pass.
Disabled optional analyzers did not run and are not credited as passes.
No additional scanner is configured. No streams were combined, so integration is
inapplicable. Existing M33 physical acceptance and source-bound materials remain.

The first exploratory readiness preflight failed because current REL-1301–1308
were applied to historical M10; its log remains `.artifacts/M34/readiness-preflight.log`.
The reviewed existing historical-schema adapter preserves exact M10 record/schema
ancestry and checks all current M33 coverage under the current schema. No tracked
gate was edited. Negative smoke checks reject missing current REL-1301, skipped
native tests, runtime warnings and wrong counts; `.artifacts/M34/schema-negative.log`
and `parser-smoke.json`. Original failed preparatory results remain FAILED.

## Candidate-bound human checklist

Path: `.artifacts/release-checklists/38c5e0ee38ae076df8264210c2d0c65c5058f580/checklist.md`.
3 pending steps. Exact generated copy:

```text
# Human release checklist

**Schema:** human-release/1
**Candidate commit:** 38c5e0ee38ae076df8264210c2d0c65c5058f580
**Candidate:** 1.0 (8) 38c5e0ee38ae
**Distribution channel:** app-store

READY_FOR_HUMAN is not publication approval. Complete these steps in order.
For VERIFIED, replace - with who=<person>; date=<UTC date>; result=<observation>.
Preserve this checklist with the release report in a committed release record.

## Human work

1. Subjective review of this candidate on a real device.
2. Product > Archive in Xcode from this candidate; validate in Organizer.
3. Developer decides whether to distribute through the configured channel.

- HUMAN-01 | OUTCOME=PENDING | EVIDENCE=-
- HUMAN-02 | OUTCOME=PENDING | EVIDENCE=-
- HUMAN-03 | OUTCOME=PENDING | EVIDENCE=-
```

No human row is credited by reused tests. M33 affected physical acceptance remains
owner-reported with original speech/device/measurement limits; M29 unchanged
physical acceptance retains its unmeasured-hour/video/recognition limits.
No known product P0/P1. Historical current-iOS synthetic StoreKit P2 and App Review
4.3(a) uncertainty remain disclosed. No independent audit or release approval.
Nothing archived, uploaded, submitted, pushed, published, repriced or changed in
the monitor. Build7 withdrawal/monitor hold are preserved.

## Post-DONE closure

Run `make static`, `./Scripts/project-status.sh validate` and
`./Scripts/project-status.sh continuity 38c5e0ee38ae076df8264210c2d0c65c5058f580` after the DONE commit.
Actual completion-commit receipt: `.artifacts/M34/post-done-initial-receipt.json`.
Final evidence-commit receipt: `.artifacts/M34/post-done-final-receipt.json`.
These are not claimed successful until their actual recorded exit0 results.

Completion commit `9a9b31378423fb210800ae2ee978893dd6a05050` passed all three exact closure commands,
exit0 each, UTC 2026-11-07T17:01:12.793425+00:00–2026-11-07T17:01:43.434874+00:00.
Only AI Markdown continuity records changed since the verified candidate.
The final evidence commit repeats the same checks in the final receipt above.

## Validation helper bindings

| File | SHA256 |
| --- | --- |
| `.artifacts/M34/reuse-validation/run.py` | `9ec4fd3c8dd182d1ca84590afc199d442927bbe02d2f287deea1de4e2ca6820e` |
| `.artifacts/M34/reuse-validation/worker.sh` | `176a50b5203bac4e7873a5d548167ead1fa97ac4b8cbe6fa1f2beb81d6b7503f` |
| `.artifacts/M34/reuse-validation/package.py` | `02592d1854bb1379a157d5208af65d85c9643316e5b9e3df1e21ddaf3c125e29` |
| `.artifacts/M31/impact-reuse-policy/validate-coverage.py` | `90a162f65ebfc27a5459862931f32db900bce5ea41219862a15a3aab4604a7c8` |
| `AI/evidence/M34/owner-verification-reuse.md` | `c4b083635b663b4bd3d2daafe80d0a4267157c8b677dd99d36ea7fde72b76921` |
