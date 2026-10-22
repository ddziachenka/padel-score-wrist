# M14 handoff — Watch Face and Smart Stack Launch

**Policy status:** current

## Milestone

`M14` — Watch Face and Smart Stack Launch; status `DONE`.

## Summary

A static WidgetKit launcher supports accessoryCircular and accessoryRectangular, including
Smart Stack. Its racket symbol and Padel Score name identify the app; the accessibility
label is Open Padel Score. WidgetKit opens the containing app through its ordinary lifecycle,
without a URL, navigation handler or App Intent. The extension has no game data, storage,
App Group, network requests or scheduled refresh: one date-only entry uses policy .never.

About now explains adding the button to a watch face and Smart Stack and says it does not
show the score. The extension ships inside the Watch app with matching version/build.
Storage and migrations are unchanged; M14 introduces no schema or compatibility layer.

## Changed files

- App/PadelScoreLauncher/{LauncherWidget.swift,LauncherBundle.swift,Info.plist,Localizable.xcstrings}
  — static widget, native layout, English copy and extension declaration.
- App/PadelScore.xcodeproj/project.pbxproj — extension target, dependency, embedding and
  test-only compilation of the provider/view; shipping StoreKit host boundaries stay enforced.
- App/PadelScoreWatch/Features/About/AboutView.swift and Localizable.xcstrings — offline help.
- App/PadelScoreWatchTests/Features/LauncherTests.swift and
  App/PadelScoreWatchUITests/LauncherUITests.swift — timeline, installed package and lifecycle/help regressions.
- Scripts/verify-launcher.py, Scripts/tests/test_launcher.py, Scripts/verify-static.sh and
  Scripts/lib/platform.sh — target graph and strict built-package checks in static/Debug/Release paths.
- AI/ARCHITECTURE.md, AI/DESIGN.md and milestone/status/handoff records — implementation and continuity.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | e8c3f79bb7ca01695371be33ce037b3d48c29fdf, main |
| Verified SHA | `201de5646a84871755723914b40e24793df7c665`, clean REVIEW on main |
| Exact command | `make milestone ID=M14` |
| Exit code | **0** — PASSED milestone verification |
| Timestamp | 2026-10-22T22:32:47Z–2026-10-22T23:32:21Z (UTC) |
| Report | .artifacts/milestone/M14/20261022T223247Z-65150/report.md |
| Result bundle | .artifacts/milestone/M14/20261022T223247Z-65150/milestone.xcresult |
| Counts | **470 total, 470 passed, 0 failed, 0 skipped, 0 expected failures**; 384 unit/policy + 5 StoreKit + 81 UI; one clean Debug build including the embedded extension |

Supplemental validation on the same shipping source:

- Minimum watchOS 10, owned 40 mm SE simulator FB2949AC-F57D-49D5-AD93-3DB345D44CDC:
  primary-checkout build-for-testing and six actual Launcher tests passed, exit 0,
  6 total/6 passed/0 failed/0 skipped/0 expected failures. UTC
  2026-10-22T22:30:06.678Z–2026-10-22T22:32:06.577Z. Bundle
  .artifacts/M14-development/minimum-final.xcresult and minimum-final-summary.json.
  Exact build command: xcodebuild build-for-testing -quiet -project App/PadelScore.xcodeproj
  -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=FB2949AC-F57D-49D5-AD93-3DB345D44CDC'
  -derivedDataPath /private/tmp/padel-m14-primary-minimum.
  Exact test command: xcodebuild test-without-building -quiet -xctestrun
  /private/tmp/padel-m14-primary-minimum/Build/Products/PadelScore-M14-minimum-compatible.xctestrun
  -destination 'platform=watchOS Simulator,id=FB2949AC-F57D-49D5-AD93-3DB345D44CDC'
  -resultBundlePath "$PWD/.artifacts/M14-development/minimum-final.xcresult"
  -only-testing:PadelScoreWatchTests/LauncherTests -only-testing:PadelScoreWatchUITests/LauncherUITests.
  A copy of the generated xctestrun prefixes only the UI target's
  UITargetAppEnvironmentVariables.DYLD_FRAMEWORK_PATH with
  /Applications/Xcode.app/Contents/Developer/Platforms/WatchSimulator.platform/Developer/Library/PrivateFrameworks:
  while preserving its original value. No SDK/runtime files, assertions, diagnostics or
  TestingEnvironmentVariables are disabled or patched. This is the documented local
  bootstrap workaround used by the earlier watchOS 10 audit.
- Unsigned Release archive, exit 0: xcodebuild archive -quiet -project App/PadelScore.xcodeproj
  -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS'
  -derivedDataPath /private/tmp/padel-m14-release -archivePath
  /private/tmp/padel-m14-verified-shipping.xcarchive CODE_SIGNING_ALLOWED=NO.
  Archive created 2026-10-22T22:31:06Z; strict package verification at 22:34:48Z passed:
  python3 Scripts/verify-launcher.py --built-app
  /private/tmp/padel-m14-verified-shipping.xcarchive/Products/Applications/PadelScore.app/Watch/PadelScoreWatch.app.
  The complete container was also inspected: three identifiers match 1.0 (1), zero
  StoreKit hosts and zero .xctest bundles. Evidence: verified-release-archive.log,
  verified-release-package.log and verified-release-archive-evidence.json under .artifacts/M14-development/.
  This unsigned packaging check is not Organizer validation or a human distribution step.

## Tests

Three unit tests pin the static timeline, supported families and installed extension identity,
versions, minimum OS and English resources. Three UI tests audit/read the largest-text help,
cold-relaunch New game/current game/result, and preserve a nested unsaved editor through
background activation, then confirm Serving and save it. Six Python graph mutation checks
reject missing dependency/embedding, version drift, shared entitlements and session source injection.

Builder self-review covered the complete baseline-to-tip diff, isolation/privacy, packaging,
state ownership, localization, tests and runtime craftsmanship. An early editor test correctly
failed until it confirmed Serving before Save; the assertion was preserved. Runtime review
found that the circular accessibility button covered only the glyph (24 x 23.5 pt); it now fills
the WidgetKit canvas (42 x 42 pt on the tested 40 mm model). The face itself owns its transformed
37.2 x 37.2 pt slot. This is native complication geometry, not a claim of a custom 44 pt control.
The change was installed, measured and rechecked on watchOS 10 and 26.1. Native SF Symbols,
semantic fonts and system activation are sufficient; no animation, haptic or bespoke asset was needed.

Manual runtime accessibility audit of both families used their actual system-rendered surfaces,
AX name/role/geometry, readable unclipped text, white-on-black contrast and actual taps:

| Surface | Runtime evidence under .artifacts/M14-development/ |
| --- | --- |
| Circular, watchOS 10 | min-circular-final-ax.xcresult and its diagnostics: Button Open Padel Score, 42 x 42; min-circular-outside-glyph-tap: a tap outside the racket opens New game |
| Circular, watchOS 26.1 | main-circular-active-ax.xcresult and diagnostics: same name/role/canvas; actual face render and earlier tap preserve the unsaved Match setup |
| Rectangular/Smart Stack, watchOS 10 | min-widget-renderer-tree: Button Open Padel Score, 138 x 55.5; readable two-line name; min-smart-stack-draft-confirmed asserts the same unsaved One advantage screen after an actual card tap |
| Rectangular/Smart Stack, watchOS 26.1 | main-rectangular-final-ax: Button Open Padel Score, 138 x 55.5; single-line name and Open app; main-smart-stack-final-tap opens New game |

Widget AX is published by WidgetRenderer/ClockFace, separately from Carousel. Apple's automated
audit API on WidgetRenderer returned accessibilityAudit -902, Invalid target app: exit 65,
1 failed/0 passed/0 skipped in min-widget-renderer-audit.xcresult. That attempt is not a pass.
The manual widget audit above supplies this surface coverage; unfiltered automated audits of
the app's About help ran in the real six-test suites. Native system audit log collection stalled
and was stopped only after the test outcome existed, preserving the failure and diagnostics.
Temporary inspection drivers are archived in .artifacts/M14-development/, never shipped or
counted as the milestone's regression suite; their shipping source matches the final candidate.

An earlier clean REVIEW gate at 814048029cbfaee321341d9aefded0f10eddeb61 was deliberately
interrupted for the circular geometry correction: make exit 2, gate exit 69, xcodebuild 143;
report .artifacts/milestone/M14/20261022T214113Z-27670/report.md. Its incomplete counts are not
authoritative. No test or packaging check was removed, skipped, loosened or conditioned away.
The owned Debug cache was cleaned instead of exempting test bundles. No additional problem
scanner is configured beyond static/build checks. This is Builder self-review, not independent
review or release approval.

Post-DONE continuity validation uses `make static`, `./Scripts/project-status.sh validate`,
and `./Scripts/project-status.sh continuity 201de5646a84871755723914b40e24793df7c665`.
Logs are retained under `.artifacts/M14-development/done-*.log`; only continuity records
change after the verified SHA.

## Known issues

The local AuditServer rejected WidgetRenderer as a target (-902), as recorded above;
do not relabel that failed attempt as success. Widget accessibility coverage here is manual
Simulator evidence. Spoken VoiceOver, real on-court activation, Always On/Low Power and the
real-Watch M14 launcher remain concretely BLOCKED in M10 under the existing owner exception
until M11–M15 are DONE. No hardware success or release-readiness verdict is claimed.

At the largest text size on the 40 mm watchOS 26.1 simulator, the native navigation title
uses a trailing fade/truncation; its full accessibility title is available and the help
paragraphs wrap and scroll. The unfiltered app audit passes.

The unsigned archive emits Xcode warnings about orientation/launch configuration of the
Watch packaging container; the archive and strict identities/host-isolation checks pass.
No App Store upload, submission, human Organizer validation or distribution was performed.

## Next step

M15 — Store/site materials. Stop after M14 DONE; a new session owns M15.
