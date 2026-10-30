# M28 runtime evidence

Builder inspection/self-review, not independent review or release approval.

## Frozen-source supplements

Watch App/Config/Scripts inputs at `872ed0f06599dc13a3b4e758b40f8a7f257d19fe` remain identical for the accepted M28 Watch evidence. Only AI Markdown differs through3db; the574-path protected manifest then proves continuity to final `e21875871773f9b47419d526a9cb22e2a4d66fb1`. Phone-specific guide/tests changed and are freshly verified separately.

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


## Final phone runtime

Final source: `e21875871773f9b47419d526a9cb22e2a4d66fb1`.

| Run | Device / OS | Definitions / invocations | Exit |
| --- | --- | --- | --- |
| Complete phone unit | SE3 / iOS17.0 /B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2 |21/21 /30 |0 |
| Complete phone UI | same |16/16 /16 |0 |
| Current phone affected supplement |17ProMax / iOS27.0 /2D44D21F-290D-4325-8DED-B98D29977585 |2/2 /2 |0 |

Every row has zero failures/skips/expected failures/native runtime warnings.
Complete command: `bash .artifacts/M28/verify-phone-complete.sh owner-verification-5`,
UTC2026-10-30T00:08:36.860730Z–01:33:12.794777Z. Current command:
`M28_PHONE_RUN=phone-current-v3 bash .artifacts/M16/runtime-profile.sh phone-current run bash .artifacts/M28/check-phone-current.sh`,
UTC2026-10-29T23:26:59.870630Z–23:32:46.430483Z. Native summaries, trees and
counts are `.artifacts/M28/final-results/`; report and exact source continuity are
recorded in milestone-verification.md.

Current native supplement covers all10 EN/ES/PT-PT/PT-BR/DE locale/appearance
variants of the explanation/header and real single/double/third-series input,
three-second commits, reset/navigation, intermediate teams and unchanged action
position. Actual current Light/Dark pixels were separately viewed:
`current-v3-captures/8CE7BC5F-C848-4026-979B-2DA5C1D73A43.png` (Dark),
`7CA55492-ECB5-456D-8755-F543393EAF3A.png` (Light),
`9D5437DA-B866-419B-92B1-9398E67703A8.png` (normal1:1 after both teams/cancel).

The complete minimum-phone suite runs both full13-locale requested-theme matrices,
all original recovery/known-score/serving/draw/Undo cases, new guide/input and
native audits. Inspected final minimum captures include normal1:1
`final-normal-captures-v5/A6660414-19CF-458D-AB2C-4B57E6116A97.png`, plus full
Russian maximum-font guidance in `final-guide-captures-v5/CECAA043-F49F-4D00-93C5-AFFFE8EBB98F.png`
and `80D461A6-D6C3-44B5-A2EA-B52C73BB083C.png`. Both latter frames render Light
although one carries a Dark test label. This is a retained appearance-automation
limitation; XCTest getter assertions and capture names are not alone proof of
actual Dark pixels. No exhaustive minimum-phone Dark visual claim is made. Actual
current-phone both-theme inspection is above; M25's comprehensive digital
appearance/localization/gallery domain must resolve and confirm all advertised
surfaces before M29/M26. No production theme override or audit exemption was added.

All paths above are below `.artifacts/M28/`. Original PNG manifests and90 image
hashes/dimensions live in `final-capture-provenance.json` (750×1334/1320×2868),
not future Store assets. The owner3 captures remain separately preserved.

## Owned Simulator environment repair

Owner4 preserved a repeated native Code-56 audit timeout at the known-score set
boundary, after its score/Undo assertions, with no source/test change from the
final current pass. Former primary51FD3DAD was shut down and renamed
`iosai-padel-score-companion-M28-preserved-51FD3DAD`; its data and original binding
remain in `old-companion-simulator-binding.json`/`preserved-old-simulator.json`.
Official `bash Scripts/simulator.sh --profile companion setup` prepared the new
primaryB9D3F5BC, same pinned model/runtime/configuration. Unchanged focused boundary
check then passed1/1 in both requested themes (75.167s, exit0), followed by the
complete successful phone suite. No asserted root cause, erase, global service
restart, or foreign-device action. Three own unused managed devices were temporarily
stopped for isolation and restored Booted, all exit0 in `restore-owned-results.json`.
The new primary binding remains; all earlier native evidence retains its actual UID.


Supplemental theme diagnostic: `bash Scripts/simulator.sh --profile companion run -- bash .artifacts/M28/check-minimum-dark-matrix.sh`
passed exit0 at the same E218 source,2026-10-30T01:36:53.719071Z–01:55:01.506474Z,
1/1 native definition/invocation, all26 internal requested-theme variants and original
audits; zero failed/skipped/expected/runtime warnings (`minimum-dark-matrix.xcresult`,
summary/exit JSON). It did not establish actual Dark pixels solely from the labels.
A separate leased manual app launch/system-theme comparison also returned exit0;
the system Settings app itself rendered Light after the Dark setting, captured in
`minimum-system-settings-dark.png`. This observation supports a Simulator-environment
limitation rather than silently treating its getter as visual proof. Diagnostic
helpers restore the original style; no production theme/source change was made.
Actual current-iOS both-theme evidence remains valid; M25 owns the comprehensive
actual-theme/store-image follow-up. Five original diagnostic PNGs have dimensions
and hashes in `.artifacts/M28/appearance-diagnostic-provenance.json`.
