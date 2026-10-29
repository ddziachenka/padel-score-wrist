# M28 runtime evidence

Builder inspection/self-review, not independent review or release approval.

## Frozen-source supplements

App/Config/Scripts source: `872ed0f06599dc13a3b4e758b40f8a7f257d19fe`.

| Run | Owned device / OS | Definitions / invocations | Exit |
| --- | --- | --- | --- |
| Minimum Watch | SE40mm / watchOS10.0 / D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C | 469/469 /907 | 0 |
| Current Watch | SE3 40mm / watchOS27.0 /36C94878-A329-4B51-92E9-4D72A40B178B | 471/471 /909 | 0 |

Both rows have zero failed/skipped/expected failures. Native summary/test-tree JSON
and result bundles live in `.artifacts/M28/watch-{minimum,current}-v2*`. Exact commands:

```sh
M28_RUNTIME_RUN=watch-minimum-v2 bash .artifacts/M16/runtime-profile.sh watch-minimum run bash .artifacts/M28/check-runtime.sh watch-minimum
M28_RUNTIME_RUN=watch-current-v2 bash .artifacts/M16/runtime-profile.sh watch-current run bash .artifacts/M28/check-runtime.sh watch-current
```

Minimum runs every Watch unit definition plus the new minimum-runtime UI journey:
OFF setup, disabled unsupported switch, disposable training, normal touch input.
Current runs every Watch unit definition and three actual UI journeys covering
both teams, immediate touch/Undo/relaunch, menu opt-in/disable/background and
native accessibility audits. Only watchOS10's generated test-runner xctestrun uses
the established M23/M27 host private-framework compatibility path; no shipping
dependency or check changes. Owned devices retain their original boot state.
UTC native test times: minimum2026-10-29T15:11:30.329Z–15:12:03.615Z;
current2026-10-29T15:09:09.351Z–15:10:32.836Z.

## Inspected application captures

Current-source captures exported from watch-current-v2.xcresult:

- `watch-current-v2-attachments/5C8BACA7-46AD-4D8B-9709-D757F3E937EC.png`: normal40mm score, games/sets, serving, visible gesture button, Undo/Menu fit together.
- `watch-current-v2-attachments/63F3BA30-D89D-4C9C-B89A-1D823D048164.png`: pending team uses hourglass/US without wrapping into the score or changing saved points.

Paths above are beneath `.artifacts/M28/`; their export manifest records source
test/device/timestamps. Earlier primary26.1 development captures inspected Russian
live/practice and German practice at largest text; the complete thirteen-locale
Watch matrix passed in fast-2. Final full gate evidence follows independently.

## Physical boundary

Simulator button activations prove the software sequence, not actual finger
recognition or haptic comfort. All physical Watch/iPhone checks, including existing
M27 checks, belong to M29 and remain required before release readiness.
