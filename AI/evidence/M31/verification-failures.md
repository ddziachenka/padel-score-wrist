# M31 preserved verification failures

Candidate `16a7a094ac863a416b61aa701d3c7b37d14f445d`, clean REVIEW/main.
No failure below is waived or reclassified as a pass. No prior automatic exception
applies; the complete command must pass before DONE.

| Attempt | Command / exit | Evidence |
| --- | --- | --- |
| Cached build | `make milestone ID=M31`; Make2/verifier1; UTC2026-11-01T21:26:18Z–21:26:47Z | .artifacts/milestone/M31/20261101T212619Z-6534/report.md; build succeeded, package guard rejected cached PlugIns/PadelScoreWatchTests.xctest |
| Sandbox | `make milestone ID=M31`; Make2/verifier69; UTC2026-11-01T21:30:41Z–21:31:05Z | .artifacts/milestone/M31/20261101T213042Z-27265/report.md; CoreSimulator inventory access denied, no tests |
| Full Watch run | `make milestone ID=M31`; Make2/verifier65/xcodebuild65; UTC2026-11-01T21:31:36Z–2026-11-02T01:32:25Z | .artifacts/milestone/M31/20261101T213138Z-46135/report.md; Debug/package passed, Watch639/640 definitions and1091/1092 invocations passed,1failure,0skips/expected/runtime warnings; phone suites never reached |

Owned disposable cache cleanup `make clean-derived-data` exited0, removing441M
from the checkout's DerivedData. Raw reports and bundles were retained. Sandbox
access was resolved with the same command using required system permissions;
no CoreSimulator restart/global erase, test filtering or parser change.

The complete Watch failure is
`GestureScoringUITests/testSeriesTouchUndoAndSavedPreferenceOnRelaunch`, line72:
expected Their score30 after a manual team tap, observed15. Native summary at
`.artifacts/M31/full-native-counts/watch-failed-summary.json`.

The log places the prior saved15 observation at14.66s, next gesture tap at14.68s,
manual team event at15.02s. Production LiveScore.award intentionally suppresses
new points inside500ms after the previous saved rally. The scenario starts a new
rally inside that interval. Existing unit `LiveScoreTests.settleTime` explicitly
checks ignored input through499ms and new input at500ms. The intended gesture
cancellation assertion must run after that prior-rally interval, with no wait
between the new pending gesture and the overriding team tap.

Targeted unchanged-source repetition is diagnostic, not a replacement full gate.
Its first iteration additionally failed the initial Pending: US observation; later
iterations advanced normally. Final exact target-command result and correction
verification will be recorded separately once the native bundle closes.

The subsequent7f49552 full run passed Watch640/1092 and phone unit21/30, then
failed native phone accessibility audit and was interrupted by the coordinator.
See [exact failure and bounded recovery](native-phone-audit-failure.md).
No component reuse; the next full command remains mandatory.
