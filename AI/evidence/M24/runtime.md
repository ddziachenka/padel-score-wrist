# M24 runtime verification

Source: clean REVIEW/main `9831216685a4bbcf8e9c567cf1c11cebb7b57e85`. Builder runtime verification, not independent audit or release approval.

| Run | Exit | Passed definitions | Invocations | UTC start–finish |
| --- | --- | --- | --- | --- |
| Large iPhone supplement | 0 | 7/7 | 7 | 2026-10-28T23:55:32.786000+00:00–2026-10-29T00:49:13.183000+00:00 |
| Complete iPhone unit supplement | 0 | 21/21 | 30 | 2026-10-29T00:49:22.613000+00:00–2026-10-29T00:49:33.400000+00:00 |

Each has zero failed/skipped/expected/runtime warnings. Command: `bash .artifacts/M24/run-verification-pipeline-v7.sh 9831216685a4bbcf8e9c567cf1c11cebb7b57e85`; exact xcodebuild arguments and owned simulator wrapper calls are retained in that script and raw logs. The separate exact full milestone command passed exit0 and is recorded in [milestone verification](milestone-verification.md).

Large: iPhone17 Pro Max / iOS26.5, `AB2F7A13-FEE8-4446-948D-36AA19A35B7F`. Minimum phone: SE3 / iOS17, `51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7`. The complete minimum-phone suite passed in the unfiltered milestone gate:13/13 UI definitions/invocations,21/21 unit definitions/30 invocations; zero failed/skipped/expected/runtime warnings.

The seven-case supplement drives correction input/delete/change, pure preview/cancel, atomic apply/whole Undo, reset/close/tab return; editable known score, checkpoint Undo, background/cold launch, invalid/completed Americano input, scoring/draw/Undo; explicit new-set serving and exact Undo in normal Light/Dark; full German heading/size/native audits; thirteen locales × actual Light/Dark × largest Dynamic Type through both guides; Russian body text/full wording/size/native audits. The same six native audit categories and mandatory occlusion rechecks remain.

Final-source captures inspected: normal Light `large-v7-attachments/9DD5B096-995A-44B8-A8B9-7C6477EA4466.png`; normal Dark `E84FD87F-26EE-4E39-9203-DFF535546DFA.png`; Russian largest Light input `8870A408-7862-4F48-A5C8-0578649D8B68.png`. Readable hierarchy, full copy, native wrapping, clearly named fields, opaque disabled text, separate primary action and disposable Demo state. Earlier development small normal labeled input was inspected in `small-labeled-copy-attachments/230E1C1E-D697-4C0A-9D70-2AC7133C90B5.png`; only secondary-button surfaces/field container semantics changed afterward and are reverified by the gate.

Original Watch source tree is unchanged from baseline: `a2f3669c84731402692e8ce8df3b73bdb33d2d8f`. No persistence, usage, entitlement, price, review eligibility, App Store material or external submission change. M25 owns fresh physical-device/VoiceOver and full-product six-domain work. No additional scanner beyond static is configured; optional analyzers remain disabled by existing configuration.


## Final minimum-phone visual check

The exact successful gate's captures were also inspected: visible field names and
values at normal size (`.artifacts/M24/final-phone-attachments/1DA17350-A2DF-4851-A7D6-97B7B15FB1B4.png`),
and the full Russian rules paragraph at largest text in Dark Mode
(`580A22C0-35D5-432F-87C9-8F2934A1F673.png` in that directory).
The native scroll view exposes the complete guidance without font caps; fields,
primary Review and secondary Reset remain readable. Stable native scroll-view
identifiers target the actual visible screen, preserving all interaction assertions.
The native audit categories are contrast, textClipped, elementDetection, hitRegion,
sufficientElementDescription and trait, with mandatory fully visible rechecks for
occluded text and fitting score-card context. There is no ignored visible finding.

Small and large test bundles, exact source freeze, and all corrections are retained
in `.artifacts/M24/`; [development](development.md) records every retained failed
candidate and the two unrecovered outer development exits explicitly. Optional
static analyzers were not run because existing configuration disables them; they
are not reported as passes. All mandatory checks ran in this milestone.
