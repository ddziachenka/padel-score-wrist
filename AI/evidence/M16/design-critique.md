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
