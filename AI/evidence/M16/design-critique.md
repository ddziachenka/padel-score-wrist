# Design critique — M16 iPhone companion

Builder self-review using design:design-critique; not independent review. Owner supplied two actual iPhone screenshots on 2026-10-24, showing Start and owned Access.

## Overall impression

The main actions and court/watch illustration communicate the app, but secondary copy is almost invisible. Text still participates in layout, producing large apparently empty areas and hiding essential installation/purchase explanations.

## Usability

| Finding | Severity | Correction |
| --- | --- | --- |
| Installation, scoring and lifetime explanations are invisible | P1 | Repair the compiled semantic color, verify actual opacity and AA contrast |
| Access legal actions occupy three rows at ordinary text sizes | P2 | Fit one horizontal row; keep a vertical fallback for long translations and accessibility text |
| Excess separation between already distinct cards | P2 | 16pt outer separation and 12pt spacing inside cards; preserve readable padding and 44pt controls |

## Visual hierarchy

Start reads promise → explanation → demo, then three useful steps. Access reads ownership/offer → Watch requirement → explanation/restore → help/legal. The native court mark and lime primary action remain. No fixed empty spacer is added and paragraph height follows content. Demo keeps score and next server dominant, with persistent Demo and visible Undo/Reset.

## Consistency

Named semantic light/dark colors remain the source of truth. The problem was alpha serialized as integer "1": the compiled UIKit asset resolves to alpha 0.00392156862745098. It must be decimal "1.000". Color values stay dark gray in light mode and light gray in dark mode; this is an opacity correction, not removal of the explanatory copy.

## Accessibility

PhoneDesignTokenTests reproduces the actual compiled-resource failure before the correction (color-regression-before.xcresult, exit65). It asserts opacity 1 and contrast >=4.5 against the resolved card background in both appearances. The original full UI audit also reports Contrast failed (ios-ui-isolated-6.xcresult: 3 passed / 1 failed, no skips). These are preserved failures, not passing evidence.

After repair, rerun the token test and live UI audit at largest Dynamic Type, plus both appearances and locale captures. Final results and screenshots are recorded in the handoff; no pass is implied by this preparation record alone.

## Priority recommendations

1. Restore all secondary copy by correcting compiled alpha.
2. Verify Start, both demos and owned/unowned Access on iPhone SE and the connected large iPhone.
3. Refresh the store capture set from the repaired candidate and verify every locale before upload.

## Repair verification — 2026-10-24

Compiled-resource regression after repair: `.artifacts/M16/color-regression-after.xcresult`, exit0, 1/1 test, zero failures/skips. `make static` passed (exit0; `.artifacts/M16/static-precommit.log`). A signed Debug build was installed on the connected iPhone; the owner confirmed “Текст виден, приложение на часах обновлено”. The old invisible-copy photographs and failing bundles remain preserved. Native large-text audit and full candidate gates are still pending.

Read-only DEBUG diagnostics on the connected iPhone show a verified StoreKit Sandbox entitlement and USD price0 (`.artifacts/M16/iphone-console-visual-fix.log`). This proves the phone is using Apple Sandbox; it does not substitute for the remaining bidirectional hardware scenarios.

## Second runtime pass

The first post-alpha native audit still reported contrast for labels underneath translucent system bars. Diagnostic attachments identified their exact rectangles below the usable viewport, rather than a failing foreground color. UI tests now queue every such label, scroll it fully into view, and run the same native audit again; every queued element must be rechecked or the test fails. All visible issues still fail immediately. No audit type or required element was excluded. Slow controlled drags keep inspection from flinging past the target. The layout retains native scrolling.

Demo now leads with the real scoreboard, moves its repeated introduction below it, fits the Demo/context header vertically where needed, and keeps team labels on one line with horizontal padding. A stacked large-text experiment was rejected because it hid the comparison between scores. The iPhone Home Screen label is PadelScore per the owner's clarification; ASC title is unchanged.

Complete development UI suite: `.artifacts/M16/ios-ui-final-development.xcresult`, exit0, 4/4 cases, zero failures/skips, including13-language gallery and largest-text native audit. This is development evidence, not the clean-REVIEW milestone result. Earlier failed experiments remain preserved. Dark appearance and final source verification follow.

The full phone unit/StoreKit suite passed at checkpoint9fbbef5: `.artifacts/M16/ios-unit-final-development.xcresult`, exit0,14 definitions/20 invocations,0 failures/skips. The largest-text native audit also passed in dark appearance (`ios-dark-ax.xcresult`, exit0,1/1), including assertions that audit scrolling did not award a point. The managed simulator appearance was restored to light. `make static` passed with all Padel-specific Python validators and their regressions (`static-final-development.log`, exit0).

The final capture test adds a separate es_MX launch and region-specific attachment names, producing14 regional placements from the actual supported app languages. This does not add a new app language or change Spanish copy.

## Store gallery choice

Compared unowned-price and verified-owned Access screens. The first candidate displays the launch price0; keeping it in permanent store screenshots would become misleading after the offer ends. The final gallery uses actual StoreKit-verified lifetime ownership, acquired through the local SKTestSession controller and read by the unchanged production entitlement owner. It uses no bought flag or premium override. The local controller is test-only, and its configuration remains excluded from the shipping app. A separate UI test proves ownership appears through transaction updates and survives a relaunch (`ios-ui-owned-access.xcresult`, exit0,1/1).

All56 preliminary large-iPhone captures are preserved. Their 1320×2868 native PNGs are already RGB with no alpha. An Apple Intelligence setup banner affected the earliest English frames in the first pass; the final capture reruns use a warmed simulator and uniform system status time9:41, full battery and signal. No app UI pixels are painted or replaced. A settled relaunch keeps transient purchase feedback out of the permanent gallery.

Dark and light large-phone previews were compared. The dark set was selected for permanent store images: it matches the Watch/Header black-lime identity while preserving readable secondary copy. Preview `iphone-dark-preview.xcresult` passed2/2 UI cases on the compatible iOS18.5 capture device; real Start/Match/Americano/owned Access screens were inspected. Final captures use the native full-screen screenshot API for consistent system chrome, not composited artwork. Light appearance remains the system-selected in-app presentation and was separately audited.

## Final regular-size gallery and remaining largest-text work

The later Spanish SE check exposed a real truncated NOSOTROS label. The chosen
accessibility layout uses full-width score cards; the regular side-by-side design
is preserved. Context and Undo/Reset have a vertical fallback. A plain persistent
Demo label avoids making a decorative hand dominate the largest-text screen.
Earlier rejected experiments and failed bundles remain preserved, including a
broad repeated-audit helper that triggered XCTest logging/quarantine crashes and
was removed. Unknown native contrast issues still fail; none is excluded.

Final source b2a30e091d423d3414a59d1d2c9c2a65daeb59e5 produced56 native dark captures
for14 ASC locales (gallery test exit0,1/1). Seven contact sheets were inspected;
long German, Portuguese, Finnish and Russian copy wraps within cards, and action/
legal links fall back vertically. Local Vision OCR recognized40/30 and10/10 in
all28 demo screenshots; the original PNG bytes, not contact sheets, are committed.
Header/Search and Watch assets retain their original hashes and accurate promises.
See verification-progress.md for the unresolved small-iPhone native audit and
remaining hardware/gate requirements. Large iOS27 smoke passed4/4; it does not
substitute for a complete minimum-OS suite.
