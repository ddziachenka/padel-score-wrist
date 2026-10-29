# M28 runtime evidence

Builder inspection/self-review, not independent review or release approval.

## Frozen-source supplements

App/Config/Scripts source: `1c6860f588ea2a0a7960cd6657fe9939cf305868`.

| Run | Owned device / OS | Definitions / invocations | Exit |
| --- | --- | --- | --- |
| Minimum Watch | SE40mm / watchOS10.0 / D5A214D9-F6B8-461F-BC2E-A32C0E4FF16C | 469/469 /907 | 0 |
| Current Watch | SE3 40mm / watchOS27.0 /36C94878-A329-4B51-92E9-4D72A40B178B | 471/471 /909 | 0 |

Both rows have zero failed/skipped/expected failures. Native summary/test-tree JSON
and result bundles live in `.artifacts/M28/watch-{minimum,current}*`. Exact commands:

```sh
bash .artifacts/M16/runtime-profile.sh watch-minimum run bash .artifacts/M28/check-runtime.sh watch-minimum
bash .artifacts/M16/runtime-profile.sh watch-current run bash .artifacts/M28/check-runtime.sh watch-current
```

Minimum runs every Watch unit definition plus the new minimum-runtime UI journey:
OFF setup, disabled unsupported switch, disposable training, normal touch input.
Current runs every Watch unit definition and three actual UI journeys covering
both teams, immediate touch/Undo/relaunch, menu opt-in/disable/background and
native accessibility audits. Only watchOS10's generated test-runner xctestrun uses
the established M23/M27 host private-framework compatibility path; no shipping
dependency or check changes. Owned devices retain their original boot state.
UTC native test times: minimum2026-10-29T14:58:42.748Z–14:59:20.490Z;
current2026-10-29T15:00:54.852Z–15:02:18.041Z.

## Inspected application captures

Current-source captures exported from watch-current.xcresult:

- `watch-current-attachments/86D578FF-8D24-433D-830F-AE7BC04E28F3.png`: normal40mm score, games/sets, serving, visible gesture button, Undo/Menu fit together.
- `watch-current-attachments/8DC59C84-1B9B-4106-8B32-87A69707A045.png`: pending team uses hourglass/US without wrapping into the score or changing saved points.

Paths above are beneath `.artifacts/M28/`; their export manifest records source
test/device/timestamps. Earlier primary26.1 development captures inspected Russian
live/practice and German practice at largest text; the complete thirteen-locale
Watch matrix passed in fast-2. Final full gate evidence follows independently.

## Physical boundary

Simulator button activations prove the software sequence, not actual finger
recognition or haptic comfort. All physical Watch/iPhone checks, including existing
M27 checks, belong to M29 and remain required before release readiness.
