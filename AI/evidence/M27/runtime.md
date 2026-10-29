# M27 runtime evidence

Final REVIEW/main source: `488809d6c06b29233e7c1d1f7687c9cec03bbab4`.
Builder inspection/self-review is not independent review or release approval.

## Managed Simulator coverage

| Run | Device / runtime / UDID | Passed definitions / invocations | Exit |
| --- | --- | --- | --- |
| Full Watch gate | SE 40mm / watchOS26.1 / `A7CBB23C-F823-4850-BE4B-CAD76922DD08` | 591/591 / 1013 | 0 |
| Minimum supplement | SE 40mm / watchOS10.0 / `D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C` | 454/454 / 876 | 0 |
| Current supplement | SE3 40mm / watchOS27.0 / `36C94878-A329-4B51-92E9-4D72A40B178B` | 454/454 / 876 | 0 |
| Full phone unit | SE3 / iOS17.0 / `51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7` | 21/21 / 30 | 0 |
| Full phone UI | Same managed phone | 13/13 / 13 | 0 |

Every row has zero failed/skipped/expected failures/runtime warnings. Supplements
run all Watch unit tests plus all five PlayerNamesUITests; they do not replace the
complete gate. Native summaries: `.artifacts/M27/watch-minimum-summary.json`,
`watch-current-summary.json`, `final-watch-summary.json`,
`final-phone-unit-summary.json`, `final-phone-ui-summary.json`.

Exact supplement invocations, under managed profile leases:

```sh
bash .artifacts/M16/runtime-profile.sh watch-minimum run bash .artifacts/M27/check-runtime.sh watch-minimum > .artifacts/M27/watch-minimum.log 2>&1
bash .artifacts/M16/runtime-profile.sh watch-current run bash .artifacts/M27/check-runtime.sh watch-current > .artifacts/M27/watch-current.log 2>&1
```

The retained check-runtime.sh checks SHA and unchanged App/Config/Scripts, builds
for testing and runs xcodebuild test-without-building on the explicit owned UDID,
selecting PadelScoreWatchTests and PlayerNamesUITests with diagnostics collection
disabled. Only watchOS10 uses the established M23 test-runner private-framework
compatibility path in its generated xctestrun. No production dependency, assertion,
native audit category or shipping setting changes. Bundles:
`.artifacts/M27/watch-minimum.xcresult`, `watch-current.xcresult`.
Native test UTC on2026-10-29: minimum08:48:14.876–09:03:21.856;
current09:04:35.005–09:21:00.781. Both outer commands exit0. The current device was
restored to its original shutdown state; the already booted minimum device was
left as found. No shared simulator reset.

## Actual journeys

Five new UI cases drive native text input and role-labelled serving, normal Match
creation/cold relaunch, active Americano rename, long/duplicate names, background
draft, Cancel, clearing to role fallback, score Undo, completion, per-game archive
and Play again. Failed roster writes retain the old game and support retry/cancel.
The native editor audit passes without ignored categories. All thirteen locales
traverse the editor at maximum Dynamic Type and assert literal custom names,
including a string that is itself a localization key.

Domain/store/flow tests cover both formats and zero/known-score starts; service,
manual/replay corrections; invalidated old previews; independent archives;
revision/idempotence; real-file restart, backup, failed writes, retry and deletion.
Complete legacy Watch journeys, StoreKit and full iPhone suites also run. The
phone matrix traverses both recovery guides in thirteen locales, actual Light/Dark
and maximum text, with native accessibility audits.

## Final visual inspection

Export completed with exit0:

```sh
xcrun xcresulttool export attachments --test-id PlayerNamesUITests --path .artifacts/milestone/M27/20261029T092309Z-73441/milestone.xcresult --output-path .artifacts/M27/final-watch-attachments
```

The manifest maps names/timestamps to captures. Inspected files under that folder:

- `40B2F015-C823-4070-9FD2-F7926D5908DB.png` — Russian maximum text: labelled fields appear first, native scrolling reaches remaining fields/actions.
- `634B630B-91FA-43EC-9170-8A16C9F081C1.png` — German maximum text: roles remain visible and literal names unchanged.
- `14C4CCF2-D0B7-4B1E-8239-7266441C1AFB.png` — native input: long entered name and system Cancel/Done visible.
- `1EA369BF-E938-43E0-A2FC-C6A564465CCD.png` — long serving name: compact two-line truncation preserves score/Undo/Menu; complete value remains accessible.
- `F13F5A21-F050-49D7-95EC-0C02679C5A6F.png` — named partner Marta on the real Match board.
- `B42CBFC0-ADF4-4EB1-90AD-407EFE8CA7C9.png` — archived Americano result top; roster below is verified by UI assertions, not visible in this top capture.

Earlier maximum-text inspection exposed explanation copy displacing all fields.
It was moved below them; fast, both supplements and full gate reran. Failed old
watchOS10 UI queries remain in [development](development.md), never counted as a pass.

## Physical Watch ownership

Owner2026-10-29: “давай все проверки на физических часах сделаем перед подготовкой
к релизу”. M25 owns all physical-Watch checks before M26, including native input,
VoiceOver, lifecycle, small-screen/large-text interaction and player-name journeys.
CoreDevice Bluetooth tunnel attempts executed no tests; development.md retains
them. No physical pass, hardware waiver or release readiness is claimed.
