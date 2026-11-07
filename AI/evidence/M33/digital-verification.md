# M33 bounded digital preparation — not milestone verification

Historical preparatory checkpoint. The later complete full-gate pass is recorded
in [milestone-verification.md](milestone-verification.md); physical closure is in
[owner-physical-verification.md](owner-physical-verification.md). Pending statements
below describe preparation before those results and are preserved as history.

Source SHA: `8eeec63f5287639b86e637803b436b005a6901da`, main, build1.0(8).
App/Config/Scripts inputs remained unchanged throughout these runs. Only local
AI records/materials and corresponding website images changed after that commit.
No verified M33 SHA, DONE, independent audit or READY_FOR_HUMAN is established.

## Actual native runs

| Scope | Exact command | Exit | Definitions / invocations | Bundle |
| --- | --- | --- | --- | --- |
| Watch gallery | `bash Scripts/capture-store-materials.sh watch capture m33-watch-gallery-1` | 0 | 14 / 14 | `.artifacts/M25/m33-watch-gallery-1.xcresult` |
| Phone gallery | `bash Scripts/capture-store-materials.sh phone-current capture m33-phone-gallery-1` | 0 | 2 / 2 | `.artifacts/M25/m33-phone-gallery-1.xcresult` |
| watchOS10 unit/live/large-text/version | `bash .artifacts/M25/runtime-profile.sh watch-minimum run bash .artifacts/M33/test-watch-feature.sh` | 0 | 500 / 954 | `.artifacts/M33/watch-feature.xcresult` |
| watchOS27 live/large-text/version | `bash .artifacts/M25/runtime-profile.sh watch-current run bash .artifacts/M33/test-watch-current-feature.sh` | 0 | 6 / 6 | `.artifacts/M33/watch-current-feature.xcresult` |
| iOS17 phone unit + affected UI | `Scripts/simulator.sh --profile companion run -- bash .artifacts/M33/test-phone-feature.sh` | 0 | unit21 / 30; UI2 / 2 | `.artifacts/M33/phone-unit.xcresult`, `phone-feature.xcresult` |
| watchOS10 long-name recovery | `bash .artifacts/M25/runtime-profile.sh watch-minimum run bash .artifacts/M33/test-watch-minimum-name-recovered.sh` | 0 | 1 / 1 | `.artifacts/M33/watch-minimum-name-recovered.xcresult` |
| watchOS27 long-name recovery | `bash .artifacts/M25/runtime-profile.sh watch-current run bash .artifacts/M33/test-watch-current-name-recovered.sh` | 0 | 1 / 1 | `.artifacts/M33/watch-current-name-recovered.xcresult` |

Every counted native invocation above Passed; zero failed/skipped/expected failures
or native runtime warnings. Native summaries/trees, not console estimates, determine
counts. Full command arguments remain in the named scripts. Complete Watch unit
suite (478 definitions) plus22 UI definitions ran on watchOS10; no test was changed to obtain a pass.
The initial current-watchOS run passed6/6 definitions/invocations. Native tree
inspection found that both initial Watch commands specified the long-name test
under NewGameUITests, but its actual class is PlayerNamesUITests. Xcode did not
execute that selector (and did not report it as skipped). No long-name pass is
credited from these bundles. Separate correctly selected runs on both watchOS
versions preserve the originals and complete this planned preparatory coverage.
Phone affected runs and correctly selected supplements are complete as listed above.

Watch gallery UTC2026-11-07T04:24:58.019Z–05:05:54.699Z; phone gallery
UTC2026-11-07T05:08:55.880Z–05:22:05.696Z. Native summary JSONs and source/context/
attachment sidecars are adjacent to each gallery bundle, with imported provenance
under AI/store-assets/m25/provenance/. All simulator operations used checkout-owned
UDIDs inside the existing lease helpers; no global simulator or desktop operation.

## Packaging, materials and source checks

- Signed Release build/package identity/signature: exit0 outside sandbox; actual
  phone, Watch and launcher plists are1.0(8). Failed sandbox attempts and failed
  physical installation are preserved in [physical-check.md](physical-check.md).
- `python3 Scripts/verify-companion.py --phone-app .artifacts/M33/device-derived-data/Build/Products/Release-iphoneos/PadelScore.app`: exit0,
  `.artifacts/M33/device-package-check.log`.
- `bash .artifacts/M33/refresh-materials.sh`: exit0. Strict import, composition,
  website preparation, validation, contacts and `make site-check`; separate logs
  `.artifacts/M33/material-{import,compose,site,validate,contacts}.log` and site-check.log.
- `python3 Scripts/verify-localizations.py --all`: exit0, localization-check.log.
- `make template-check`: exit0, template-check.log.
- `make static > .artifacts/M33/static-preparation.log 2>&1`: exit0. Optional
  swiftformat/shellcheck remain disabled by existing configuration, not counted as passes.
- `./Scripts/project-status.sh validate` and `git diff --check`: exit0.
- Fresh source/build/link/ASC evidence: [development.md](development.md).
- Visual review: [visual-review.md](visual-review.md), including all210 native
  frames,28 creatives,13 compact golden-point locales and4 rendered PDF pages.

Paths without a directory prefix above are under `.artifacts/M33/`. These checks
are preparation, not substitution for the declared full gate.

## Required checks not run

`make milestone ID=M33` is NOT RUN: implementation/audit scope is incomplete because
the owner confirms the Watch is unavailable. Required fresh physical side readability
and VoiceOver cannot be observed; M33 remains BLOCKED, not clean REVIEW or DONE.
No inherited M25/M28/M29/M31 automatic waiver is used. After actual affected physical
acceptance, finish all domain rows, commit clean REVIEW/main and run the full gate.

M34's full milestone and exact-SHA release commands are NOT RUN: dependent M33 is
not DONE. No upload, public deployment, review reply, submission or promotion change.

## Preserved minimum-watchOS launch failure

`bash .artifacts/M25/runtime-profile.sh watch-minimum run bash .artifacts/M33/test-watch-minimum-name.sh`
exited65. Bundle `.artifacts/M33/watch-minimum-name.xcresult`:1 definition,0 passed,
1 failed; no skipped/expected failures/runtime warnings. Native summary/tests and
activities are saved beside the bundle. Activities show failure inside app launch:
“Application 'com.dziachenka.padelscore.watchkitapp' has not loaded accessibility”,
after system quiescence/accessibility wait and diagnostic spindump, before the test
reaches any scoring/name action. This is not a product assertion pass, not waived,
and not claimed pre-existing (no baseline reproduction). The original stays FAILED.

A bounded recovery restarts only the owned watchOS10 UDID inside its existing
checkout/device lease, then runs the same unmodified test in a new result bundle.
No erase, global simulator restart, test change or broader retry loop is used.
The separate current-watchOS result remains independent.

The first recovery helper returned149 before testing because the owned watchOS10
simulator was already Shutdown. The helper now inspects only the exact bound UDID,
shuts down only if Booted, and boots/waits from Shutdown; other states fail closed.
The corrected recovery command
`bash .artifacts/M25/runtime-profile.sh watch-minimum run bash .artifacts/M33/test-watch-minimum-name-recovered.sh`
exited0,1/1 definition/invocation passed, no adverse counts. Bundle suffix
watch-minimum-name-recovered.xcresult; original FAILED bundle is unchanged.
Native export initially hit TestReport cache permissions (exporter1 / xcresulttool64);
the same strict exporter outside sandbox exited0.

## Preserved current-watchOS scoring failure

`bash .artifacts/M25/runtime-profile.sh watch-current run bash .artifacts/M33/test-watch-current-name.sh`
exited65:1 definition failed,0 passed/skipped/expected/runtime warnings. Activities
show the first game.us tap was synthesized but the label remained “Our score, 0”
instead of “Our score, 1”; the long-name actions were not reached. Native recording
exported in watch-current-name-attachments/ and frame at12seconds show the dimmed
Americano0–0 screen. This observation does not prove the root cause or a baseline
defect. No assertion/timing/source change is made. A separate correctly leased
owned-device restart then repeats exactly the same test once in a new bundle.
The original current-watchOS bundle also remains FAILED.

For frame inspection ffmpeg was unavailable (exit127); native AVFoundation extraction
first failed under sandbox video-decoder restrictions (exit133), then the same
Swift extraction outside sandbox exited0. These diagnostic-tool failures are not
test results and do not change the original native verdict.

## Final bounded result

Eight successful bundles total547 definitions /1010 invocations (summed across
bundles, not deduplicated coverage). Every invocation in those bundles Passed;
zero failed/skipped/expected/runtime warnings. The two earlier failed attempts
remain FAILED and are not included in this passing sum. Actual compact native
counts, exact UTC intervals and original failures: [native-results.json](native-results.json).
The current-watchOS recovery exited0 and its unchanged long-name test passed1/1;
the original first-tap failure remains unexplained beyond the observed dim screen.

Strict exporter command, exit0:
`python3 .artifacts/M25/export-results.py .artifacts/M33/native-counts watch-gallery=.artifacts/M25/m33-watch-gallery-1.xcresult phone-gallery=.artifacts/M25/m33-phone-gallery-1.xcresult watch-minimum=.artifacts/M33/watch-feature.xcresult watch-current=.artifacts/M33/watch-current-feature.xcresult phone-unit=.artifacts/M33/phone-unit.xcresult phone-ui=.artifacts/M33/phone-feature.xcresult watch-minimum-name=.artifacts/M33/watch-minimum-name-recovered.xcresult watch-current-name=.artifacts/M33/watch-current-name-recovered.xcresult`.
This existing parser requires nonzero all-passed native leaves and zero adverse counts.
Raw summaries/trees stay in `.artifacts/M33/native-counts/`.

All246 App/Config/Scripts files are byte-identical to the stated source SHA:
`.artifacts/M33/preparation-input-identity.json`. This is a bounded build-input
comparison, not post-DONE continuity and not acceptance of an unverified candidate.

Final preparation checks recorded 2026-11-07T06:32:23.092225+00:00:
`make static > .artifacts/M33/static-final.log 2>&1`, exit0;
`./Scripts/project-status.sh validate`, exit0; `git diff --check`, exit0.
Only the evidence sentence was appended after those checks. A post-commit
status/diff receipt is retained in `.artifacts/M33/closure-receipt.json`.

The staged diff check subsequently exited2 because Git treated the new ASCII85
PDF as text and flagged its generated stream/xref whitespace. The material commit
2454d6901f137180875a3694166e07e35c585c72 preserved that exact reviewed PDF. An exact-path
`.gitattributes` binary declaration now classifies this PDF correctly; no PDF bytes,
source checks, tests or assertions are changed. The original staged failure is
disclosed here, rather than described as a passing check. Final closure checks use
the corrected file classification and preserve the PDF's recorded SHA256.
