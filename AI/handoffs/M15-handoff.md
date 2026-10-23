# M15 handoff — App Store and Site Materials

**Policy status:** current

## Milestone

`M15` — App Store and Site Materials; status `DONE`.

## Summary

Prepared the final English store/site materials without publishing. App Store copy
opens with “Keep your focus on the game.” and describes the implemented offline
scoring, Undo, five completed free games, one lifetime purchase, fixed Match demo,
free local history, latest-result Play again and static launcher. Purchase/restore
network requirements and local-only data limitations are explicit.

Six direct real-app captures show Match set 2 at 3–2/30–15 with a completed set,
Golden point, Americano 13–10 of 32, score correction, a three-set result and dated
history. Their 368 × 448 dimensions match Apple's current Watch specifications.
SHA-256 and per-image fixture/attachment provenance are committed. The static site
uses identical image files, three product sections, availability text without a
false download control, and updated Support/Privacy/Terms.

## Changed files

- `AI/app-store-listing.md` — prepared English metadata and reviewer instructions.
- `AI/store-assets/` — six PNGs, hash/provenance manifest, reproduction instructions
  and rendered site validation evidence; superseded three-image set retained in Git history.
- `Web/public/` and `Web/README.md` — product landing page, image copies, responsive
  styles, accessible keyboard skip targets and updated history/demo/deletion content.
- `App/PadelScoreWatch/App/UITestStore.swift`, `UITestStoreTests.swift`,
  `StoreMaterialsUITests.swift` and `App/PadelScore.xcodeproj/project.pbxproj` —
  Debug-only isolated screenshot fixtures and actual UI capture/interaction coverage.
- `Scripts/verify-store-materials.py`, `Scripts/verify-site.sh` — validate capture
  ordering, PNG dimensions, SHA-256, provenance and byte-identical website copies.
- Milestone/status/handoff records — completion and continuity.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | `fe83dc4efc60d5caf6c78410fd219f697c18b8ad`, clean main |
| Verified SHA | `9294a59f00ccdc9b697097786d3d43507518d5c8`, clean REVIEW on main |
| Exact command | `make milestone ID=M15` |
| Exit code | **0 — PASSED** |
| Timestamp | 2026-10-23T07:10:36Z–2026-10-23T08:07:45Z UTC |
| Report | .artifacts/milestone/M15/20261023T071034Z-85593/report.md |
| Result bundle | .artifacts/milestone/M15/20261023T071034Z-85593/milestone.xcresult |
| Counts | **472 total, 472 passed, 0 failed, 0 skipped, 0 expected failures**; 385 unit/policy + 5 StoreKit + 82 UI; one Debug build including the launcher |

Supplemental evidence:

- Capture app/test SHA `2f3bec3befa685973f80e6ed4da2dc1bc76c4d7d`; exact clean-test and
  attachment-export commands in `AI/store-assets/README.md`. Exit 0; **9 total,
  9 passed, 0 failed, 0 skipped, 0 expected failures**. Result bundle:
  `.artifacts/M15-development/screenshots.xcresult`; exported six original attachments
  and summary in that directory. The reserved session temporarily used the existing
  owned 44 mm simulator and restored the 40 mm verification binding and both names.
- `node .artifacts/M15-development/check-site.cjs`, exit 0: **32 combinations** of
  four pages × four widths × two appearances, plus 200% text checks on all four
  routes. No overflow, image-load, alt, skip-link/focus or contrast failures. Minimum
  text contrast **5.78:1**. Evidence: `AI/store-assets/site-validation.md` and ignored
  `.artifacts/M15-development/site-validation.json`, `site-{light,dark}-{390,1024}.png`.
- `make site-check`, exit 0; `.artifacts/M15-development/site-check.log`.
- `make static`, exit 0; `.artifacts/M15-development/static.log`. Optional tooling
  remains as configured; no additional problem scanner is configured beyond the
  static checks and build's shared StoreKit source check.

## Tests

Fixture tests assert valid real scoring states, set scores, round total, completion
and fixed history dates. The new UI test navigates and captures all six screens,
awards a point, and verifies Undo restores the pictured score. It runs again in the
full mandatory scheme. Shipping views and behavior are unchanged; fixtures remain
inside `#if DEBUG` and cannot seed Release data.

Builder self-review covered the complete baseline-to-tip diff, all M15 acceptance
criteria, purchase/storage claim accuracy, fixture isolation, Xcode source membership,
image integrity and UI/site craftsmanship. Inspected all six native captures and
rendered site layouts. Corrected two inaccurate alt descriptions and a 200% narrow
text grid overflow, then reran the complete browser matrix. The original UI and
native imagery needed no new illustration, animation or haptic. This is self-review,
not an independent audit or release approval.

Development `make fast` stopped at package verification (make exit 2) because this
checkout's shared DerivedData held the prior test bundle. The first clean-source
M15 gate at the same REVIEW SHA also stopped before tests with that cache residue
(make exit 2, gate exit 1); report
`.artifacts/milestone/M15/20261023T070914Z-71163/report.md`, zero tests executed.
Diagnosed the concrete leftover
`PadelScoreWatch.app/PlugIns/PadelScoreWatchTests.xctest`; no pre-existing-source claim
was made. A reserved `xcodebuild clean` on the owned cache (exit 0) removed it, then
the unchanged full candidate passed. No gate, test, assertion or package check was
removed, skipped or loosened.

Post-DONE validation: `make static`, `./Scripts/project-status.sh validate`, and
`./Scripts/project-status.sh continuity 9294a59f00ccdc9b697097786d3d43507518d5c8`;
exit codes and output retained in `.artifacts/M15-development/done-*.log`.

## Known issues

None known in M15. The new website and App Store materials are prepared locally;
the live site and ASC still carry their previously published/uploaded versions.
No site deployment, metadata/screenshot upload, Archive, distribution, App Review
submission or release-readiness verdict was performed.

M10 remains BLOCKED on its real-Watch evidence: on-court use, spoken VoiceOver,
Always On/Low Power, oldest-device launch performance, adverse-network StoreKit and
the M14 watch-face/Smart Stack launcher. Earlier M10 evidence describes its own
historical SHA, not the updated app.

## Next step

Stop after M15 DONE. A new session resumes M10's final-polish workflow on the updated
app once the required real-Watch checks can be performed. After readiness, the owner
separately decides whether to publish `Web/`, update ASC metadata and replace its
screenshots in manifest order, then handles Archive/Organizer/distribution/App Review.
