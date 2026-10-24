# M16 final verification — 2026-10-24

Candidate: `b671bb1d611daebb03718429f1036eab569a1cca`, clean REVIEW on main.
The unchanged full `make milestone ID=M16` ran on this exact SHA.
**Raw result: FAILED. Make exit2; verifier exit1; iPhone UI xcodebuild exit65.**
M16 is DONE under the owner's explicit, narrowly bounded acceptance in
[owner-acceptance-20261024.md](owner-acceptance-20261024.md), not an automated pass
or READY_FOR_HUMAN.

Report: `.artifacts/milestone/M16/20261024T143428Z-49481/report.md`.
Console: `.artifacts/M16/milestone-owner-accepted-clean.log`.
Verification began2026-10-24T14:34:30Z; final result bundle ended17:07:22.459Z.
No test filters, skipped cases, assertion changes or retry-to-pass were used.

| Complete platform suite | xcodebuild exit | Definitions | Invocations | Passed definitions | Failed | Skipped / expected / runtime warnings | UTC start–finish |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Watch, watchOS26.1 / managed SE40 | 0 | 510 | 884 | 510 | 0 | 0 / 0 / 0 | 14:35:12.189–16:53:02.802 |
| iPhone unit + StoreKit, iOS17 / managed SE3 | 0 | 14 | 20 | 14 | 0 | 0 / 0 / 0 | 16:53:30.205–16:53:36.375 |
| iPhone UI, same managed SE3 | 65 | 6 | 6 | 4 | 2 | 0 / 0 / 0 | 16:53:37.726–17:07:22.459 |

Bundles under the report directory: `milestone.xcresult`,
`companion/unit.xcresult`, `companion/ui.xcresult`; native summaries copied to
`.artifacts/M16/final-{watch,phone-unit,phone-ui}-summary.json`.
Exact xcodebuild commands are saved alongside each bundle as `*.command`.
UI execution finished16:57:21.976Z; Xcode's normal post-failure simulator diagnostics
account for the additional10 minutes in the bundle duration. No process was killed.

The two and only two failures are target `PadelScorePhoneUITests`, each with native
failure text **Contrast failed**:

- `CompanionUITests/testLargestTextAccessibility()`
- `CompanionUITests/testSpanishTeamNamesAtLargestTextAreNotClipped()`

These match the owner acceptance exactly. They are not proven false positives.
No clipped-text, functional, StoreKit, packaging, crash or missing-suite failure is
accepted. Current-iOS27 supplemental coverage passed4/4 including both audits;
actual Spanish truncation was fixed before this candidate. Physical scope follows
the owner's acceptance of observed entitlement/restore on both devices, visible
copy, Watch update and disconnected scoring; unperformed acquisition/reinstall/
additional assistive-technology scenarios remain unperformed, not passes.

## Other required evidence

- Static verification and Debug packaging for both platforms passed in the exact
  milestone run. `make site-check` exit0 on this candidate:
  `.artifacts/M16/site-owner-final.log`.
- Owner-approved `make self-test` in original template fixture exit0:99 cases,
  2161 checks,0 failed. Source `b2a30e091d423d3414a59d1d2c9c2a65daeb59e5`,
  fixture `76aa09b05613156708b304bdc65bf4ed8911c0e6`; log
  `.artifacts/M16/self-test-approved-final-corrected.log`, finished13:51:43.750295Z.
  All28 generic tooling files still match the recorded SHA256 manifest at the final
  candidate. Actual product Python guards ran in the primary static/site checks.
- Supplemental watchOS10 and27: each13 definitions/24 invocations, all passed,
  exit0,0 skipped/expected/warnings; `.artifacts/M16/watch10-smoke.xcresult` and
  `watch27-smoke.xcresult`. See [verification-progress.md](verification-progress.md)
  for commands, timestamps and the explicit bounded scope.
- Signed archive source `fc118f8a0b357d52e0b06f8ba1f17449297ca623`:
  `.artifacts/M16/PadelScore-M16-fc118f8.xcarchive`; archive, actual packaging guard
  and `codesign --verify --deep --strict` exit0. Source diff for App/Config/Scripts
  between archive source and final candidate is empty. It contains real iPhone
  executable1.0(2), independent Watch and launcher, with no test components/config.
- Store captures:56 opaque native1320×2868 images/14 ASC locales; source
  `b2a30e091d423d3414a59d1d2c9c2a65daeb59e5`,
  `.artifacts/M16/iphone-gallery-m16-v2.xcresult`, exit0,1/1. Original SHA/provenance
  in `AI/store-assets/iphone-m16/manifest.json`; seven contact sheets inspected and
  local OCR verified score figures. Later production delta is AX-size neutral-card
  background only; these captures use regular size. Old84 Watch and28 creative
  assets remain hash-identical. Site/store/review updates are local drafts.

## Preserved initial attempt and cache diagnosis

The first same-SHA `make milestone ID=M16` returned Make2/verifier1 before tests:
`.artifacts/milestone/M16/20261024T143044Z-30534/report.md`, console
`.artifacts/M16/milestone-owner-accepted.log`. Strict packaging found a stale
build1 Watch test bundle in an old Debug build2 product. Timestamps/plists are in
`.artifacts/M16/stale-watch-testbundle.json` and `stale-watch-testbundle-info.plist`.
`Scripts/simulator.sh run -- make clean-derived-data` exit0 removed only this
checkout's owned Watch cache; log `.artifacts/M16/clean-owned-watch-cache.log`.
The unchanged full command then rebuilt and completed both platforms as above.
No source/check was altered. Future strict gates should clean this owned Watch
DerivedData before the build because hosted unit tests leave injected XCTest
components in Debug products; do not loosen the distribution guard.

## Completion boundary

M16 DONE is the owner-accepted milestone disposition, with the raw FAILED result
preserved. Separate Release Readiness Revalidation must assess the new candidate,
carry these results/decision and establish its own distribution evidence. No new
build was uploaded/selected/submitted and no public launch or offer-end schedule
exists. The hourly monitor remains read-only until its M16/readiness/build guards
are met. Lifetime offer remains launch day plus seven full regional days; Sandbox
and TestFlight do not start it.
