# M24 handoff

**Policy status:** current

## Milestone

`M24` — Interactive iPhone Recovery Scenarios; status `DONE`.

## Summary

Start and the existing Demo offer two isolated interactive recovery guides.
Historical correction selects change/delete/insert, previews complete Before/After
and the effective journal, applies atomically, and undoes the whole correction.
Known-score Match/Americano examples validate real editable input, confirm an
immutable summary, then score/Undo to the initial checkpoint and explicitly
confirm next-set service. Close/reopen/Reset discard only the demo. Original demos
and review eligibility remain intact; real storage, settings, usage and entitlements
are unreachable. Full copy ships in all thirteen locales.

## Changed files

- `App/PadelScorePhone/RecoveryScenario.swift` — disposable shared-domain session and pure previews.
- `App/PadelScorePhone/PhoneRecoveryView.swift` — guided input/review/result, visible field labels, native measured typography and readable actions.
- `App/PadelScorePhone/PadelScorePhoneApp.swift`, `PhoneStartView.swift`, `PhoneDemoView.swift` — entry points, presentation lifetime and review guard; native scroll identifiers.
- `App/PadelScorePhone/Localizable.xcstrings` — localized guidance and shared recovery messages.
- `App/PadelScore.xcodeproj/project.pbxproj` — production/test-host source parity.
- `App/PadelScorePhoneTests/CompanionDemoTests.swift`, `App/PadelScorePhoneUITests/CompanionUITests.swift` — domain isolation and real UI regressions.
- `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, milestone/status, `AI/evidence/M24/` and this handoff — current product memory and reproducible evidence.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `9831216685a4bbcf8e9c567cf1c11cebb7b57e85` |
| Exact command | `make milestone ID=M24` |
| Exit code | 0 |
| Timestamp | `2026-10-29T00:49:37Z`–`2026-10-29T04:28:38Z` UTC |
| Report | `.artifacts/milestone/M24/20261029T004936Z-77579/report.md` |
| Counts | Watch 568/568 definitions/976 invocations; phone unit 21/21/30; UI 13/13/13; aggregate 602/1019; zero failed/skipped/expected/runtime warnings; both Debug/package guards passed |

Exact bundles/commands and retained raw report: [verification](../evidence/M24/milestone-verification.md).
Final-source large-phone supplement:7/7 definitions/invocations, exit 0;
complete phone-unit supplement:21/21 definitions/30 invocations, exit 0.
[Runtime](../evidence/M24/runtime.md) records all locales, appearances, text sizes,
owned devices and visually inspected captures. Post-DONE command logs are
`.artifacts/M24/post-done-static.log`, `post-done-status.log`,
`post-done-continuity.log` and `completion.json`.

## Tests

Seven new domain definitions/ten invocations cover selective replay IDs/winners,
pure cancel/no-op rejection, immutable known-score confirmation, checkpoint Undo,
completion without usage, set service, reset/reopen/defaults and real-owner isolation.
Seven new UI definitions drive editable input, preview/cancel/apply/whole Undo,
lifecycle/reset/tab return, invalid/completed Americano and draw/Undo, explicit
serving/Undo in normal Light/Dark, thirteen-locale/two-mode largest-text journeys,
German full titles/scaling and Russian rules/scaling. All six legacy phone UI
cases and the complete existing Watch suite run.

Builder self-review fixed retained-tab navigation, spoken/painted-label mismatch,
actual appearance selection, disabled-action readability, localized text measurement,
missing visible input names and unstable field association metadata. Native scroll
identifiers and full-context rechecks retain every interaction/audit assertion;
filled actions and simple field containers clear the native regressions. Prior
failed/interrupted and audit-timeout runs remain [failed evidence](../evidence/M24/development.md).
This is self-review, not an independent audit.

## Known issues

No known blocking M24 issue. M25 owns fresh physical-device/VoiceOver and full-product
six-domain/review-material work. Existing App Review 4.3(a) rejection and unsent/on-hold
reply remain unchanged. No new release readiness or distribution is claimed.

## Next step

A new Builder session owns `M25` — Recovery Experience and Review Materials.
M25–M26 remain planned. Stop after the DONE commit passes static/status/continuity
against `9831216685a4bbcf8e9c567cf1c11cebb7b57e85`.
