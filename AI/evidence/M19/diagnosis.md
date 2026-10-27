# M19 contrast diagnosis and self-review

Builder self-review, not independent review. Baseline source:
`fc9bf30a2913de8e253acae0c6331aa79504f2eb` on primary main; the preserved review research
and handoff documentation did not change compiled inputs. Plan registration commit:
`600e64446f8ba0c35efe5deabe2a807fee3549a3`.

## Reproduction and diagnosis

The unchanged English `testLargestTextAccessibility` and Spanish
`testSpanishTeamNamesAtLargestTextAreNotClipped` both reproduced native
`Contrast failed` on the owned iPhone SE3 / iOS17.0. Command:

```sh
xcodebuild test -quiet -project App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination 'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion -resultBundlePath .artifacts/M19/contrast-before.xcresult -only-testing:PadelScorePhoneUITests/CompanionUITests/testLargestTextAccessibility -only-testing:PadelScorePhoneUITests/CompanionUITests/testSpanishTeamNamesAtLargestTextAreNotClipped
```

Exit65; 2 executed / 0 passed / 2 failed; no skipped, expected failures or runtime
warnings. Raw bundle/log and exported screenshots/descriptions are in
`.artifacts/M19/contrast-before*` and `before-attachments/`. XCTest reported
`No element`, so no particular glyph is asserted as the root cause. Native
Accessibility Inspector could not be used while the Mac was locked; the automated
native audits and their actual screen captures remain the evidence.

Simple ScrollView clipping did not solve the issue (`viewport-clip`, exit65).
An accessible menu picker passed the original two checks once (`accessible-picker`,
exit0), but failed when tests also brought the lower score fully into the viewport
(`picker-lower-visible`, exit65). The picker experiment was removed, not shipped;
this was not sufficient evidence of a fix. All failed experiments remain retained.

Opaque semantic navigation/tab backgrounds, retaining the original segmented
picker, passed both strengthened tests (`opaque-bars`, exit0). The runtime
comparison isolates the remedy to native bar presentation around scrolling content;
it does not prove which internal contrast sample Apple's unmapped issue selected.
An initial dark check also passed3/3 including both audits and real demo scoring.
Visual review caught the default inactive tab color becoming too light with the
SwiftUI tab-background override. Final configuration instead uses an opaque native
UITabBarAppearance with the existing PhoneSecondaryText for normal icons and titles
in stacked/inline/compact layouts, including scroll-edge appearance. The demo
navigation bar uses the matching opaque semantic background. Final light/dark
checks are recorded separately; only their final result and full gate close M19.

Apple's documented native audit API and Inspector workflow:
https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app
The documentation supports inspecting rendered contrast and retaining native audits;
it does not identify this app's unmapped issue.

## Regression and craftsmanship review

- All six original audit categories and all assertions remain. Both existing
  largest-text tests additionally reveal the lower score fully, repeat the same
  native audit, and assert scrolling did not change either score. No issue is
  newly excluded, audit callback weakened, or parser/suite/configuration changed.
- Original segmented picker, scoring gestures, accessibility names/values, card
  typography, layouts, localization, demo boundaries and Undo/Reset remain intact.
- Both appearances use semantic native surfaces; inactive tabs keep the already
  verified semantic secondary color. No static light-only color, forced theme or
  change to Dynamic Type settings enters production.
- No scoring, persistence, StoreKit, entitlement or privacy data changes. No iPad
  target, version/build, launch price, metadata or submission changes.
- Roadmap/contracts and prior competitive research were preserved. M20–M26 remain
  PLANNED; only M19 is implemented in this Builder session. The monitor was updated
  in place and read back to reflect the approved plan, unsent reply and new-candidate
  guard; it remains observation-only and suppresses the known rejection.
- Physical-device/new StoreKit and six-domain release reassessment belong to M25/
  M26. No old M18 readiness or failure waiver is claimed for this new source.

## Final development checks

`bash .artifacts/M19/check-appearances.sh` (exact xcodebuild commands retained in script), exit0:

- `light`: exit0,3/3 passed, zero failed/skipped/expected/runtime warnings; UTC 2026-10-27T17:46:32.912000+00:00; `.artifacts/M19/final-light.xcresult`.
- `dark`: exit0,3/3 passed, zero failed/skipped/expected/runtime warnings; UTC 2026-10-27T17:47:18.723000+00:00; `.artifacts/M19/final-dark.xcresult`.

Actual exported light/dark regular Match and Spanish largest-text screens were inspected: labels wrap fully, score and foreground colors remain readable, inactive tab labels keep their semantic secondary color, both score buttons retain their names/values. The simulator was restored to light. `make static` exited0 (`.artifacts/M19/static-implementation.log`); optional SwiftLint/SwiftFormat/ShellCheck remain disabled by existing configuration, not claimed run. Required full milestone gate follows on the clean REVIEW candidate.
