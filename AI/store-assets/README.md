# App Store screenshots — M15

Six English screenshots are direct XCTest captures of the real Watch app. No scaling,
compositing, text overlays, device frame, or reconstructed interface was applied.
Website copies under `Web/public/images/` are byte-identical originals, resized only
by CSS in the page. The prepared set replaces the earlier three-image set in Git;
App Store Connect still needs the owner's separate update.

## Source and requirements

- Source app/test commit: `2f3bec3befa685973f80e6ed4da2dc1bc76c4d7d`.
- Debug-only isolated stores: `App/PadelScoreWatch/App/UITestStore.swift`.
- Capture: `App/PadelScoreWatchUITests/StoreMaterialsUITests.swift`,
  `testCaptureSixStoreScreens`; seed correctness: `UITestStoreTests/storeMaterialsSeeds`.
- Managed Apple Watch SE (2nd generation), 44 mm, watchOS 26.1 (23S36),
  UDID `DF6ED19D-1461-4A25-975B-1A4995E8AA20`; English / en_US.
- All PNGs are **368 × 448 pixels**. This is an accepted size for Series 4–6 and SE
  in [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications),
  checked 2026-10-23. Apple requires one consistent Watch size across localizations.
- Per-file SHA-256, fixture, UI actions, attachment filename and capture timestamp:
  [`manifest.json`](manifest.json). Simulator clock is system UI; game scores and
  history dates/order are fixture data. Test stores cannot replace real data in Release.

## Order

| File | Fixture | Real screen |
| --- | --- | --- |
| 01-match.png | storeMatch | Set 2, games 3–2, points 30–15, one completed set 6–4; Opponent 2 serves |
| 02-golden-point.png | storeGoldenPoint | 40–40 Golden point, games 3–2, sets 1–0 |
| 03-americano.png | storeAmericano | 13–10 of 32 rallies, nine remaining, four per server |
| 04-edit-score.png | storeMatch | Game menu → Edit score, points and games |
| 05-result.png | storeResult | Finished Match, sets 6–4, 4–6, 6–3; no invented match winner |
| 06-history.png | storeHistory | Three fixed dated results; Match and next Americano entry visible |

## Reproduction and evidence

Capture command (from the primary checkout, under a managed-device reservation):

```sh
xcodebuild clean test -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=DF6ED19D-1461-4A25-975B-1A4995E8AA20' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData -resultBundlePath .artifacts/M15-development/screenshots.xcresult -only-testing:PadelScoreWatchUITests/StoreMaterialsUITests -only-testing:PadelScoreWatchTests/UITestStoreTests
xcrun xcresulttool export attachments --path .artifacts/M15-development/screenshots.xcresult --output-path .artifacts/M15-development/screenshots-export
```

The ignored `.artifacts/M15-development/capture-screenshots.sh` records the complete
session: reserve the checkout, temporarily select its previously registered 44 mm
binding, run, and restore the 40 mm verification binding and both names on exit. It
creates no simulator and never uses another project's device or a shared desktop.
Do not run the capture command without that reservation/binding procedure.

Result: exit 0; **9 passed, 0 failed, 0 skipped, 0 expected failures** (8 fixture tests,
1 interactive capture). Original attachments and manifest remain in the ignored result
bundle/export directory; summary: `.artifacts/M15-development/screenshots-summary.json`.
Export the six named `store-*` attachments and copy them without image processing.
`make site-check` verifies dimensions, SHA-256, ordering, provenance and website copies.
No screenshot or metadata was uploaded, and the site was not published in M15.
