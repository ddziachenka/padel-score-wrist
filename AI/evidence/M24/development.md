# M24 development evidence

All runs below are mutable development feedback, not milestone readiness. Initial baseline/main was `2c6b4c7552968f034417428d8461b7e93bc3979c`; recovery commits were `57556a851627797b14326bdb078bc89e74fac518` and `82eef6f81922dce90a4a3d2360f3b5bac82ef733`. The strict candidate is recorded separately. Failed/interrupted bundles remain raw evidence. No historical exception applies.

| Run | Outer exit | Native result | Definitions total/passed/failed/skipped | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- | --- |
| `unit-development` | 0 | Passed | 7/7/0/0 | 10 | 2026-10-28T19:42:12+00:00–2026-10-28T19:42:19+00:00 |
| `ui-journeys-development` | 65 | Failed | 2/1/1/0 | 2 | 2026-10-28T19:43:21+00:00–2026-10-28T19:53:03+00:00 |
| `ui-targeted-v2` | 75 | Failed | 4/2/2/0 | 4 | 2026-10-28T19:53:14+00:00–2026-10-28T19:57:51+00:00 |
| `ui-targeted-v3` | 75 | Failed | 4/2/2/0 | 4 | 2026-10-28T19:58:54+00:00–2026-10-28T20:03:22+00:00 |
| `navigation-v4` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T20:05:16+00:00–2026-10-28T20:07:11+00:00 |
| `navigation-v5` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T20:08:02+00:00–2026-10-28T20:10:53+00:00 |
| `navigation-v6` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T20:10:59+00:00–2026-10-28T20:12:56+00:00 |
| `ui-targeted-v7` | 73 | Failed | 4/3/1/0 | 4 | 2026-10-28T20:13:41+00:00–2026-10-28T20:20:50+00:00 |
| `ui-targeted-v8` | 75 | Failed | 4/3/1/0 | 4 | 2026-10-28T20:21:29+00:00–2026-10-28T20:29:03+00:00 |
| `ui-targeted-v9` | 75 | Failed | 5/3/2/0 | 5 | 2026-10-28T20:30:24+00:00–2026-10-28T20:34:56+00:00 |
| `style-regression` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T20:37:25+00:00–2026-10-28T20:38:38+00:00 |
| `style-fullscreen` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T20:40:13+00:00–2026-10-28T20:40:57+00:00 |
| `style-context` | 0 | Passed | 1/1/0/0 | 1 | 2026-10-28T20:43:56+00:00–2026-10-28T20:44:33+00:00 |

Each run is `.artifacts/M24/<run>.xcresult` with `<run>.log` and `<run>-summary.json` alongside it. `unit-development` used `-only-testing:PadelScorePhoneTests/RecoveryScenarioTests`; initial UI used the correction and known-score cases; `ui-targeted-v2/v3/v7/v8` used the four original new UI cases; v9 added the next-set regression. `navigation-v4/v5/v6` targeted the retained correction/cancel/Undo/leave assertion case. Style runs targeted `testKnownScoreSetBoundaryRequiresServingAndExactUndo`. Exact shell arguments are retained in `run-targeted*.sh`, `run-style-*.sh` and the logs. No mandatory final gate was narrowed.

The first failure selected a hidden retained TabView scroll view. The helper now drives the visible viewport. Subsequent return-path failures were reproduced with recordings and resolved by independent full-screen guide presentations. A fresh UUID/key isolates every opening. Native clipping from a spoken label replacing the painted Review heading was fixed with actual labels plus announcements. Screenshot review caught an unsupported appearance argument; only later native `XCUIDevice.appearance` runs count as light/dark evidence. Old v8 captures labelled Dark do not establish Dark Mode.

Normal-text audits then found faded disabled Undo and a score label while its card was partly under the bar. Guide buttons now use readable opaque semantic colors. Each score label has a unique context identifier. When its card fits the viewport, the exact same native audit rechecks that label with the entire card visible; large cards retain individual-label rechecks. There is no new ignored audit category or accepted failure. `style-context` passed the serving/whole-Undo journey including disabled controls.

Interrupted runs were stopped to correct reproduced failures or strengthen appearance validation. Native diagnostic collectors for completed/interrupted development runs sometimes stalled; only the matching owned `simctl diagnose` collector was stopped to finalize the retained bundle. No required test was deleted, skipped, retried into a pass, or loosened. No failure is labelled pre-existing.


Clean REVIEW candidate `bbf9b0bca1823f58c8187e6074107560c34ac395` stopped in its
small-phone supplement after four functional cases passed and German maximum-text
headings failed native clipping. Outer exit75; raw bundle `.artifacts/M24/small-complete.xcresult`,
summary `small-failed-summary.json`. No large-phone/unit supplement or `make milestone ID=M24`
ran on that candidate. Focused `german-heading` and `german-heading-v2` retained their
native clipping failures (outer65 each); `german-heading-native` then passed both
full-wording titles across both modes and all three states, outer0. The actual
scaled rendering was inspected. The passing implementation uses a native multiline
UILabel with metrics, Dynamic Type updates and hyphenation, not an audit exception.
A permanent size assertion was added before freezing the new candidate.

Second REVIEW candidate `8bdaa7a7978b63b13182e6ef0a563bb51c5752d2` stopped in the small supplement before the declared gate. Its interrupted matrix counts as a failure; no readiness is claimed. Follow-up focused tests changed only navigation helper behavior.

| Run | Outer exit | Native result | Definitions total/passed/failed/skipped | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- | --- |
| `small-v2-complete` | not retained | Failed | 6/4/2/0 | 6 | 2026-10-28T21:42:53.048000+00:00–2026-10-28T21:51:53.321000+00:00 |
| `german-heading-precise` | not retained | Failed | 1/0/1/0 | 1 | 2026-10-28T21:51:59.344000+00:00–2026-10-28T21:55:24.623000+00:00 |
| `german-heading-margin` | 73 | Failed | 1/0/1/0 | 1 | 2026-10-28T21:55:29.244000+00:00–2026-10-28T21:57:55.294000+00:00 |
| `german-heading-scrollview` | 0 | Passed | 1/1/0/0 | 1 | 2026-10-28T21:59:11.670000+00:00–2026-10-28T22:02:16.877000+00:00 |

All four bundles have zero expected failures and runtime warnings. Slower coordinate gestures and margin drags failed the same reachability requirement. Targeting `phone.recovery.scroll` with native XCTest swipes passed both guides through input/preview/result in both actual modes at largest text, retaining the visibility/full-copy/scaled-height assertions and all twelve native audits. Temporary diagnostic captures were removed before the final candidate.

The v3 pipeline runs the full large-phone six-case supplement and all phone unit definitions. The exact unchanged milestone command owns the complete small-phone suite, including the same locale/appearance matrix; a duplicate separate small-phone supplement is not required. No mandatory check is narrowed.

For these two interrupted development runs the native failed bundles and commands are retained, but the outer tool exit was not recovered. They are failures, never passes; no numeric exit is inferred.

Third REVIEW candidate `713fd5fba1f19b6c2860a9060663bf2e92c6c159` stopped in its large supplement before unit/full milestone verification.

| Run | Outer exit | Native result | Definitions total/passed/failed/skipped | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- | --- |
| `large-v3-complete` | 75 | Failed | 6/4/2/0 | 6 | 2026-10-28T22:03:26.013000+00:00–2026-10-28T22:09:35.212000+00:00 |
| `large-badge-primary` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T22:10:36.138000+00:00–2026-10-28T22:11:39.892000+00:00 |
| `large-audit-settled` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T22:12:52.207000+00:00–2026-10-28T22:13:53.088000+00:00 |
| `large-badge-text` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T22:14:30.848000+00:00–2026-10-28T22:16:26.632000+00:00 |
| `large-hard-edge` | 0 | Passed | 1/1/0/0 | 1 | 2026-10-28T22:17:39.597000+00:00–2026-10-28T22:18:28.154000+00:00 |

The contrast finding named the fully visible Demo badge. Primary color alone, settled-frame capture and split text/icon experiments failed; no failure was ignored. The split was reverted. Disabling iOS26 automatic scroll-edge effects on the guide resolved the exact next-set/Undo native regression. The toolbar already has an opaque semantic background. The final badge uses primary color, audits wait one second for compositor updates, and all existing categories/issue handling/assertions remain. The raw large matrix was interrupted after the reproducible failure and counts as failed.

Fourth REVIEW candidate `992bd0d6080bc571f6e4b46807bdafd304359fe6` passed the five focused large-phone cases, including the unchanged native serving/Undo audits. The matrix then failed navigation to the original Demo's recovery link and was interrupted. Outer exit75; native Failed; 6/5/1/0 total/passed/failed/skipped definitions, six invocations; zero expected/runtime warnings. UTC 2026-10-28T22:19:50.363000+00:00–2026-10-28T22:28:53.626000+00:00. Raw bundle `.artifacts/M24/large-v4-complete.xcresult`, summary `large-v4-failed-summary.json`. No unit supplement or declared gate ran.

Stable ScrollView identifiers were added to Start and both original Demo layouts. The helper now selects the named current screen and uses native swipes for all routes; coordinate fallback is removed, all forty attempts and visibility/journey assertions remain. Root layouts and original demo behavior are unchanged. Final frozen validation is recorded separately.

Fifth REVIEW candidate `b1c1d0c202c60edc11bb8fdc0cc32689dff33d0f` completed the entire large supplement naturally. Only the matrix failed: two Russian known-score rules clipping findings, one per appearance. All other locale/appearance journeys completed. Unit and declared milestone gate never ran.

| Run | Outer exit | Native result | Definitions total/passed/failed/skipped | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- | --- |
| `large-v5-complete` | 65 | Failed | 6/5/1/0 | 6 | 2026-10-28T22:29:46.140000+00:00–2026-10-28T23:20:40.722000+00:00 |
| `large-russian-rules` | 65 | Failed | 1/0/1/0 | 1 | 2026-10-28T23:21:41.946000+00:00–2026-10-28T23:22:52.303000+00:00 |
| `large-russian-native` | 0 | Passed | 1/1/0/0 | 1 | 2026-10-28T23:23:49.101000+00:00–2026-10-28T23:24:43.744000+00:00 |
| `small-measured-copy` | 0 | Passed | 2/2/0/0 | 2 | 2026-10-28T23:25:50.225000+00:00–2026-10-28T23:29:34.024000+00:00 |
| `small-labeled-copy` | 0 | Passed | 2/2/0/0 | 2 | 2026-10-28T23:30:45.482000+00:00–2026-10-28T23:32:04.593000+00:00 |

The rules paragraph was fully visible. Explicit SwiftUI vertical sizing/padding failed; reusing native multiline body measurement passed both appearances on the large phone. Small-phone German heading and Russian body checks then both passed before field-label changes. Screenshot inspection additionally exposed menu selections without visible field names. Vertical native LabeledContent now names every field while preserving picker names and IDs. The final editable-input test reveals every field label and completes actual input/preview/cancel/score/Undo/reset/relaunch; it and the Russian native regression passed together on the small iOS17 phone. The final suite has thirteen UI definitions, including the new Russian regression.

Current clean candidate: `a096a2aad8bddfd2fec0d4e5961efe497a2ed767`. The v6 pipeline runs seven large-phone cases (including all thirteen locales/two appearances at largest text), all twenty-one phone unit definitions, then exact `make milestone ID=M24`. No earlier supplement or focused pass is substituted for that required gate.

Sixth REVIEW candidate `a096a2aad8bddfd2fec0d4e5961efe497a2ed767` stopped before the locale matrix when the normal serving/Undo result reported contrast on its three outlined secondary actions. The raw interrupted bundle remains failed; unit and full milestone gate did not run.

| Run | Outer exit | Native result | Definitions total/passed/failed/skipped | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- | --- |
| `large-v6-complete` | 73 | Failed | 5/3/2/0 | 5 | 2026-10-28T23:33:46.980000+00:00–2026-10-28T23:39:41.568000+00:00 |
| `large-filled-actions` | 0 | Passed | 1/1/0/0 | 1 | 2026-10-28T23:41:17.321000+00:00–2026-10-28T23:42:05.485000+00:00 |
| `small-filled-actions` | 65 | Failed | 2/1/1/0 | 2 | 2026-10-28T23:44:09.348000+00:00–2026-10-28T23:46:56.305000+00:00 |
| `small-filled-actions-rebooted` | 65 | Failed | 2/1/1/0 | 2 | 2026-10-28T23:48:51.222000+00:00–2026-10-28T23:51:07.766000+00:00 |
| `small-plain-fields` | 0 | Passed | 2/2/0/0 | 2 | 2026-10-28T23:51:16.587000+00:00–2026-10-28T23:53:11.417000+00:00 |

Removing the unnecessary secondary-action outline retained opaque readable text and filled surfaces and passed the exact large-phone case. The permanent regression now explicitly covers normal Light/Dark states. On iOS17 its native audit timed out after the serving selector disappeared, code-56; both that run and a repeat after restarting only the owned device failed and remain failures. The same transition passed in both appearances after the extra LabeledContent association wrapper was replaced with a plain vertical label/native picker. Russian maximum-text native checks also passed. No native category or issue is ignored, no timeout is caught or retried inside a test, and no required gate was narrowed. The native audit itself remains the oracle.

Final clean candidate: `9831216685a4bbcf8e9c567cf1c11cebb7b57e85`; pipeline `.artifacts/M24/run-verification-pipeline-v7.sh`. It must complete the seven-case large supplement, all phone unit definitions and exact full `make milestone ID=M24` before DONE.

## Final disposition

The complete final candidate `9831216685a4bbcf8e9c567cf1c11cebb7b57e85` passed exact `make milestone ID=M24`, exit0. See [milestone verification](milestone-verification.md). Earlier failed/interrupted supplements remain failures and were not substituted for the final complete gate. No historical contrast waiver applies.
