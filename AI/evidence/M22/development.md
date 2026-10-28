# M22 development evidence

Baseline: `116a22c8b418412e08998fb07cd3bbf4a840a361` on primary `main`.
Implementation recovery point: `d0abfa0390cea60009d1f53f5ed655303031fe7f`.
These mutable development runs are not milestone verification. Every early
failure remains in `.artifacts/M22/`; no historical exception is carried forward.

| Command | Exit | Evidence and result |
| --- | --- | --- |
| `bash .artifacts/M22/run-unit.sh 1` |69| Sandbox could not access CoreSimulator; no tests ran. Authorized Xcode execution outside that sandbox followed. |
| `bash .artifacts/M22/run-unit.sh 2` |65| Build failed: new Journal views missing from shared StoreKit host membership. |
| `bash .artifacts/M22/run-unit.sh 3` |65| Build failed: LocalizedStringResource supplied to a LocalizedStringKey-only heading. |
| `bash .artifacts/M22/run-unit.sh 4` |65| Build failed: initial pbxproj helper registered views in the wrong phase. Anchored object matching corrected the membership. |
| `bash .artifacts/M22/run-unit.sh 5` |0| `development-5.xcresult`:418 unit definitions/822 invocations,0 failed/skipped/expected/runtime warnings. Includes the first5 Journal unit cases. |
| `bash .artifacts/M22/run-ui.sh 1` |65| `ui-1.xcresult`:1/7 passed,6 failed. New helper tried to scroll a fixed live-score footer; legacy History identifier was wrong. Production assertions were retained. |
| `bash .artifacts/M22/run-ui.sh 2` |65| Build failed on Swift Testing's key-path/rethrows macro inference in the new long-journal assertion; explicit predicate closure fixed it. |
| `bash .artifacts/M22/run-ui.sh 3` |65| `ui-3.xcresult`:7/8 passed; only failed-save fixture's incorrect rally43 target failed. Actual fixture has39 rallies. All three edits, ambiguity, cancel/Undo, largest text, archived/legacy detail, long scrolling and native audit passed. No skipped/expected/runtime warnings. |
| `bash .artifacts/M22/run-minimum.sh` (initial) |2| `minimum.xcresult`:14/14 passed,0 failed/skipped/expected/runtime warnings on watchOS10. Outer shell failed after the Builder changed the helper while it was running. Not counted as a passing shell command. Complete final rerun is separate. |
| `make static` (first) |2| `static-development.log`: French native word Journal required an explanation in the existing unchanged-word registry. Added explanations for native French/Swedish Journal and Dutch Rally; verifier unchanged. |
| `make static` (corrected) |0| `static-development-2.log`, `static-pre-review.log`; source graphs, locale completeness/placeholders, site/materials and repository policy pass. |
| `python3 Scripts/verify-localizations.py` |0| `localization-development.log`: all existing locales pass with39 new keys, all13 language values present. |
| `make clean-derived-data` |0| Removed only this checkout's disposable353MB primary build cache, preserving every result bundle and supplemental-runtime cache. Prevents a development unit-test plug-in from contaminating the strict package check. |

Final minimum-runtime, visual inspection and exact clean REVIEW gate evidence are
recorded in `milestone-verification.md` after completion. All implementation,
configuration and test bytes will be frozen for that candidate. Self-review is
Builder review, not independent review or release approval.
