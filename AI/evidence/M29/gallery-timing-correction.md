# M29 — gallery timing correction

Builder correction, not independent audit or release approval. Approved behavior
changed to a five-second fixed window; one Watch Store gallery interaction still
waited3.3s before requiring Undo. This was missed in the earlier bounded change.
No app timing or product requirement is changed by this correction.

## Before

Exact main source `445859bde0740737ccd580ca0fb95dba429fb534`:
`bash Scripts/capture-store-materials.sh watch capture m29-watch-gallery-1`,
exit **65**, UTC2026-11-01T12:02:59.879Z–12:05:27.457Z. Native bundle
`.artifacts/M25/m29-watch-gallery-1.xcresult`: **14 definitions/invocations,
0 passed /14 failed**, zero skipped/expected/runtime warnings. Original log,
summary, attachments and failed preparation remain preserved and are never imported.
English native test-details identifies `StoreMaterialsUITests.swift:448`, the Undo
isEnabled assertion after3.3s, not a launch or production-navigation failure.
Details `.artifacts/M29/watch-gallery-failure-en-details.json`.

## Change and focused verification

Wait5.3s instead of3.3s, preserving the original0.3s margin beyond the approved
deadline and the strict Undo assertion. Add immediate preview-label-change and
Undo-disabled assertions so pending input cannot be mistaken for a saved point.
No assertion/filter/category/parser is removed or loosened. Whole-App search finds
only intentional3.2s/3s *no-early-save* checks after this correction.

Exact focused command on the same source plus this test-only patch:

```sh
bash .artifacts/M25/runtime-profile.sh watch-gallery run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=22C79D99-DEA7-4525-AD2D-50FDCD6B8720' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m25-watch-gallery -resultBundlePath .artifacts/M29/watch-gallery-timing-after.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchUITests/StoreMaterialsUITests/testM25GalleryenUS -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Exit **0**, UTC2026-11-01T12:10:18.701Z–12:13:10.879Z, **1/1 definition/invocation**,
zero failed/skipped/expected/runtime warnings. Complete English interaction visits
all eight actual capture states, validates first gesture commit/Undo, optional OFF,
replacement/journal/apply/Undo, sets/Americano/known-score/history. Report/log/native
summary `.artifacts/M29/watch-gallery-timing-after*`. Full fourteen locales and
complete phone captures must rerun at a single new committed source; the focused
pass does not replace them. Shipping build6 bytes are unchanged; only a UI-test
wait/extra assertions change.
