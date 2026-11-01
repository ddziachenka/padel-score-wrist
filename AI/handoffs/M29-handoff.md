# Milestone handoff

**Policy status:** current

## Milestone

`M29` — Physical Device Validation; status `IN_PROGRESS`, **not DONE**.

## Summary

Owner-confirmed Watch 1.0 (4) and phone 1.0 (4) installed locally. Agent performed
available physical phone checks via iPhone Mirroring and restored the exact phone
appearance settings after owner approval. Owner performed actual Watch gestures.
Two native series can select THEM, but recognition is intermittent and has no
numeric trial record. Owner asks about another gesture; the required product
choice is recorded in [the decision](../evidence/M29/gesture-input-decision.md).
One-hour play and real gesture video were postponed, not passed.

Fixed Try gestures from result-based Play again/New game setup. Two regressions
fail before and pass after. The minimum-runtime follow-up exposed an existing
clipped-button test tap; baseline reproduction and video prove the missed input.
Test now scrolls to the visible control, asserts Pending: US, and retains the same
3.3-second wait and exact saved score. No production timing change.

## Changed files

- `App/PadelScoreWatch/Features/Game/GestureScoringView.swift` — route setup
  practice through its existing flow in both navigation-stack contexts.
- `App/PadelScore.xcodeproj/project.pbxproj` and two installed-version assertions —
  distinguish local phone/Watch build 4, preserving exact version checks.
- `App/PadelScoreWatchUITests/GestureScoringUITests.swift` — two result-flow
  regressions and strict visible-input correction to existing practice coverage.
- `AI/evidence/M29/` — physical observations, correction/reproduction evidence and
  pending mechanic decision; `AI/PROJECT_STATUS.md` and milestone — actual blockers.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | No fully verified M29 SHA. Production correction `0d535ac26a543d37333f3c457bbfba1316663d90`; test-only follow-up `9659e7c3017faf8dc4530c46ad49cb97f3c0eec9`. |
| Exact command | Full required `make milestone ID=M29` **not run**: physical acceptance incomplete, product decision pending, source-bound galleries stale, no eligible clean REVIEW candidate. Exact targeted commands in [correction evidence](../evidence/M29/setup-practice-regression.md); physical build/install commands in [hardware evidence](../evidence/M29/physical-validation.md). |
| Exit code | Current Watch supplement 0; two navigation regressions 0 after / 65 before; focused corrected minimum test 0 after / 65 on both original baseline and current before. First two complete minimum supplements 65, preserved; final complete minimum supplement 0. No full-gate exit exists. |
| Timestamp | Final minimum: 2026-11-01T10:59:06.656Z–11:01:25.818Z. Other exact native start/finish timestamps in linked records and native summaries. |
| Report | Final minimum `.artifacts/M29/setup-practice-minimum-supplement-3.xcresult`; earlier `.artifacts/M29/setup-practice-{before,after,current-supplement,minimum-supplement,minimum-supplement-2}.xcresult`; `.artifacts/M29/practice-tap-{current-before,baseline-before-2,current-after}.xcresult`. |
| Counts | Final minimum at 9659e7c: **15/15 definitions / 41/41 invocations**, zero failed/skipped/expected/runtime warnings. Navigation: 2/2 passed after, 0/2 before. Current supplement: 13/13 definitions, 39 invocations, zero adverse counts. Focused corrected minimum: 1/1 passed. Original minimum: 13/15 definitions passed / 41 invocations; second: 14/15 / 41. Zero skipped/expected/runtime warnings in these bundles. Build/install commands run no tests. Physical per-team denominators, hour/video and required remaining rows are absent. |

`make static` after shipping correction fails Make 2 / source validator 65 because
old build-3 material fingerprints no longer match the changed shipping inputs;
`.artifacts/M29/static-fix.log`. No validator was weakened or hash updated without
captures. Full Watch/phone galleries, localized creative composition and site-copy
validation must be refreshed at one final frozen shipping source after the product
choice, retaining old provenance. This failure is not a pass or a release waiver.

## Tests

Builder self-review covered flow/path ownership, result/draft preservation,
per-new-game OFF, isolated practice, exact build identity, native accessibility and
minimum-runtime touch compatibility. New result-flow tests reproduce both missing
navigation destinations against unchanged baseline production, then pass with the
single route fix. Existing timing assertion remains intact after input correction.
This is Builder self-review, not independent review or release approval.

## Known issues

- Intermittent physical THEM recognition; no ≥95% measurement, zero-wrong-team proof,
  wrist/racket hand or continuous real Watch video. Setup entry retest not separately
  described in owner's compound gesture response.
- One-hour test deferred by owner and the remaining physical inventory incomplete.
- Direct Mac→Watch CoreDevice Bluetooth L2CAP tunnel unavailable; paired-phone
  installation succeeded with owner's narrowly authorized test-data removal.
- Store material source guard correctly fails until fresh complete captures.
- Six final domain records and full unchanged milestone verification are pending.
- Temporary phone settings restored; no outstanding settings-restore approval.

## Next step

Owner resolved the choice: **test a five-second prototype (Recommended)**.
The current candidate uses a fixed five-second window with no motion detector;
one/two/third-series semantics and all thresholds remain. Build/test/install the
distinguishable 1.0 (5) prototype, gather affected hardware evidence,
refresh final-source galleries, finish all required physical rows and six-domain
records, then run the full clean REVIEW/main milestone gate. Do not advance M26.
No upload, submission, publication, App Review reply or distribution is authorized
by this handoff.
