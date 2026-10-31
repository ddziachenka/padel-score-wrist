# M25 minimum-phone native audit traversal

The first exact full gate at `fa70662919cfddffa643de97c0036043c5a102e1`
exposes a genuine verification-coverage failure: Portuguese-largest opt-in copy
never reaches full visibility for the mandatory native re-audit. The run is
interrupted after that failure, Make exit130, and remains raw FAILED at
`.artifacts/milestone/M25/20261031T024708Z-29088/report.md`. Watch635/1085 and
phone unit21/30 are successful components, never credited as a full pass or reused
under an exception. Phone UI has4 passed/1 failed definitions; remaining cases did
not execute. See [work log](work-log.md) for exact original scope and timestamps.

## Reproduction and diagnosis

The added bounded `testM25PortugueseGestureAuditAfterResetAtLargestText` retains
the real Light/Dark, maximum-text, practice1:0→localized Repor→0:0 sequence and
original six native audit categories. It reproduces the same failure without
running all26 locale/theme pairs. The complete existing matrix remains enabled.
Every diagnostic is based on `fa70662919cfddffa643de97c0036043c5a102e1` plus its
preserved exact test-source patch. No production source changes in this repair.

Exact wrapper per row:
`Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/gesture-audit-repro.sh <run>`.
The actual full xcodebuild arguments are retained in `<run>.command`, the source
patch in `<run>-source.patch`, and native result/summary in `<run>.xcresult` and
`<run>-summary.json`, all under `.artifacts/M25/`. Owned SE3/iOS17 UDID
`B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2`; original appearance/boot state restored.
All failed rows have zero skipped/expected/native runtime warnings.

| Run | Exit | Definitions | Native UTC interval | Test source patch SHA256 |
| --- | --- | --- | --- | --- |
| portuguese-audit-before | 65 | 0/1; failed1 | 2026-10-31T07:09:54.732000+00:00–2026-10-31T07:12:59.352000+00:00 | `e5ae9b221e37bb3aa62f7de80740b6a7ab5f9ca2bcfd8054b2c97aee852f844e` |
| portuguese-audit-gutter | 65 | 0/1; failed1 | 2026-10-31T07:15:11.168000+00:00–2026-10-31T07:18:10.027000+00:00 | `c27e61b5f6137c8a49f7402faaa507bf81b987bc81f8b7a815703917f3a42101` |
| portuguese-audit-swipe | 65 | 0/1; failed1 | 2026-10-31T07:19:34.919000+00:00–2026-10-31T07:22:07.856000+00:00 | `0f943cafba9514d656364cf3e9e43bcf5914884c16a71b0c56319fed6ba5c98e` |
| portuguese-audit-geometry | 65 | 0/1; failed1 | 2026-10-31T07:22:37.561000+00:00–2026-10-31T07:25:00.827000+00:00 | `4e2edaeb2fd2bd9cd03bbca53ade404129c5ffa73a27b15b60fdb16ea3e7d82f` |

The gutter-origin and stationary-swipe hypotheses were unsuccessful and discarded.
Measured geometry proves actual scrolling: the Portuguese heading begins at
`y2148.5`, height249.5pt. Each original150pt drag moves it140pt. Twelve moves end
at `y468.5`, bottom718pt; the unobscured viewport is `y65...617`, height552pt.
The target is moving normally and the fresh query agrees with the audit element;
this is neither a stale AX frame nor a proven Simulator-cleanup effect.

## Corrected minimum-runtime reproduction

Increase only the bounded deferred-target traversal from12 to64 short drags,
breaking at the unchanged full-visibility predicate. Original coordinate origin,
direction, velocity, native categories, pending identity, final native re-audit and
failure assertion stay intact. Failure-only screenshot/hierarchy diagnostics are
additive. No smaller text, hidden element, skipped category, special locale waiver
or expected failure is introduced. The original26-pair matrix and the new bounded
regression both remain in the full scheme. Existing gallery4 shipping membership
and bytes remain unchanged; no native screenshot is modified or regenerated.

`Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/gesture-audit-repro.sh portuguese-audit-64`
passes, exit0, one definition/one invocation, zero failed/skipped/expected/native
runtime warnings. Native UTC interval `2026-10-31T07:26:48.739Z`–
`2026-10-31T07:29:32.749Z`. Bundle `.artifacts/M25/portuguese-audit-64.xcresult`;
strict summary/leaf export `.artifacts/M25/accepted-audit-64/`, exit0.
It uses the same committed base plus exact test patch SHA256
`958e99931d66edef367ab75cd0c58bf9a55fb980bb62666e5efa48e0a2f1e4ef`.
This is development fail-before/pass-after evidence, not the full milestone gate.

The unmodified [before Light](audit-traversal-before-light.png) and
[fully visible after Dark](audit-traversal-after-dark.png) native attachments were
visually inspected. Byte hashes, exact original attachment names, source patches,
test and device are recorded in audit-traversal-native-provenance.json. The closed
native result requires every pending element to receive its real full-visibility
audit; the screenshots are not a substitute for that assertion.

Current-runtime regression and the fresh complete exact milestone gate remain
required. No DONE is claimed from this diagnosis.
