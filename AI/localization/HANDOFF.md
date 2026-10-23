# Localization handoff

**Status:** implementation, complete coordinator editorial/visual review and final exact integration passed for all twelve added locales. No release verdict.

## Scope

Owner-approved localization before M10; not a milestone. English plus eleven added languages, twelve added locales: es, it, fr, pt-PT, pt-BR, nl, de, sv, da, fi, nb, ru. Portuguese used two sequential locale worktrees; language tasks ran at most three at once. Shared preparation and integration were performed on main.

## Summary

Translated all 330 Watch keys and four launcher keys in every new locale (4,008 added catalog entries), including 31 existing About/legal/support strings missing from the original catalog inventory. Added native plurals, offline help, VoiceOver labels/announcements, localized website links, all 48 new website pages, thirteen local App Store variants (Spain/Mexico share the app/site Spanish) and lifetime-purchase fields. System language selection, English defaults, product name, score rules, saved-data models and purchase conditions are preserved.

Prepared 72 new raw 44-mm screenshots and refreshed six English screenshots after common layout corrections. Site copies are byte-identical. No composited translations or edited image text. Manifests bind fixture/actions, source SHA, sole 40→44-mm configuration delta, device, xcresult attachment, timestamp and SHA-256.

## Changed files

- `App/PadelScoreWatch/Localizable.xcstrings`, launcher catalog and project locale registry — translations and installed resources.
- About/legal URL selection, score labels and result layout — local routes and readable expanded copy.
- `App/PadelScoreWatchUITests/StoreMaterialsUITests.swift`, launch helper, resource/grammar tests — real locale journeys and capture stability.
- `Config/localizations.json`, localization/site/material validators and regression tests — completeness, parameters, routes, field limits and original assets.
- `Web/public`, `AI/store-assets` — unpublished localized pages and screenshot originals/copies.
- `AI/localization` — input SHAs, terminology, complete editorial review, numeric evidence, store drafts and reports.
- Product/design/workflow/M10 records — explicitly approved timing exception and multilingual final audit.

## Validation

| Field | Evidence |
| --- | --- |
| Common base | `809aa64036c4027d7aba141e889e90d97669e9e6` |
| Final verified candidate | `8dd50d72b04689da93bfaed2599eb28bd26e3591` |
| Previous verified candidate | `b6cbb53163027283e8466b97b0f35e67b8ae62f4`; retained automated evidence, superseded for Danish editorial acceptance |
| Exact integration command | `make integration CANDIDATE=8dd50d72b04689da93bfaed2599eb28bd26e3591` |
| Integration result/counts/time/report | Exit 0; 510/510 definitions, 884 passed invocations, 0 failed/skipped/expected; 8,272.038 s. Report `.artifacts/integration/20261023T161643Z-52611/report.md`; preserved `evidence/integration-final.md` |
| Per-language commands | `make static` and `make fast` in each recorded worktree; `inputs.json` records full source SHAs |
| Baseline `make fast` | Exit 0; 472 passed, 0 failed/skipped/expected; `evidence/fast-baseline.md` |
| Language `make fast` reports | all twelve streams passed, each 472/472 with zero failed/skipped/expected; `evidence/language-gates.md` |
| Final static | `make static`, exit 0 before candidate freeze; post-record `make static`, status validation and continuity all exit 0; evidence below |
| 44-mm captures | Source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`; full run exit 0, 13/13; replacement runs exit 0, 3/3 and 1/1; zero failed/skipped/expected |
| Capture command | `evidence/capture-command.txt`; every manifest records its exact result bundle and source |
| Visual count | All 78 shipping PNGs plus all 156 final bounded 40-mm QA PNGs and 156 combined context PNGs individually inspected, plus three fresh Danish correction frames; all 52 website routes opened in browser |
| Numeric proof | `xcrun xcstringstool compile` plus `Scripts/probe-localized-plurals.swift`; both messages at 0,1,2,4,5,11,21,22,25,101,999 in every locale; catalog SHA-256 in each `plural-review.txt` |

## Tests and review

Original regression scheme remains intact. New runtime coverage uses all twelve installed locales, real Match/Americano creation, scoring/Undo, corrections, finish, history/replay, data deletion, offline legal/support pages and localized URLs, launcher instructions, restore, save failures and the largest accessibility text on the managed 40-mm Watch. Shared StoreKit and original free-limit/error journeys remain in the complete scheme.

Coordinator read every catalog value/plural, all four complete pages and every store field in every locale, first without English and then against its meaning. Re-read all corrected passages and inspected the runtime screenshots. Terminology and concrete correction examples are recorded in each locale review. This is coordinator editorial review, not an invited native-speaker certification or independent release audit.

Rejected failed/black/incomplete capture attempts instead of accepting structural success alone. Corrected long score/result labels, native Russian denominator grammar, Brazilian zero plural, service-order ambiguity contextual legal/purchase wording and four Danish result/banner subjects. Full failure/recheck history: `runtime-findings.md`. The interrupted earlier integration is not a pass.

## Known issues and boundary

M10 remains BLOCKED on real-Watch evidence: spoken VoiceOver, on-court operation, Always On/Low Power, oldest-device launch performance, adverse-network StoreKit and the watch-face launcher. Simulator evidence does not replace these checks. No `make milestone ID=M10` or release-ready claim for this candidate. Those gates require the completed hardware audit on the same candidate.

No App Store Connect upload, site publication, App Review submission or archive was performed. Store materials remain local drafts. Localized public website routes and StoreKit/App Store metadata require their separate publication/upload before live localized-link and store validation; this work proves the local prepared materials only. Original language branches/worktrees and ignored result bundles remain available for reproduction.

## Next step

Localization preparation and required automated/editorial verification are complete. Follow `REAL-WATCH.md` to obtain required real-Watch evidence before M10's six-domain final audit, `make milestone ID=M10` and `make release CANDIDATE=<full-SHA>`. Publication and submission remain separate owner actions.

## Evidence-record checks

`make static` after final editorial/report updates: exit 0, log `/private/tmp/padel-localization-complete-static.log`; HEAD `8dd50d72b04689da93bfaed2599eb28bd26e3591` with only AI Markdown records changed. `Scripts/project-status.sh validate`: exit 0. Initial `Scripts/project-status.sh continuity 8dd50d72b04689da93bfaed2599eb28bd26e3591` returned 65 because those records were not yet committed; its clean-checkout guard is preserved. Commit records, then repeat static/validate/continuity before handoff.

At clean record commit `1a2f5e4ae252696b9da3849b0f72f93ebf81a83e`: `make static` exit 0 (log `/private/tmp/padel-post-record-static.log`), `Scripts/project-status.sh validate` exit 0, `Scripts/project-status.sh continuity 8dd50d72b04689da93bfaed2599eb28bd26e3591` exit 0. Continuity confirms exactly the verified build inputs; only AI Markdown evidence changed. All localization test/capture device reservations are released. M10 hardware blockers unchanged.

## M10 resumption update

Owner subsequently confirmed all physical checks and explicitly authorized prepared-site publication. Website deployed to production; 131/131 public files match source, including all 52 page routes and 78 PNGs (`AI/evidence/M10/site-publication.md`). Device confirmation: `AI/evidence/M10/device-confirmation.md`. Historical blocker statements above describe this handoff’s original closing checkpoint; current M10 is DONE after its own exact milestone/release gates; final update below. Store metadata upload and App Review remain unperformed.

## M10 completion update — 2026-10-23

Earlier blocker/unpublished statements describe the original localization checkpoint and its exact SHA. Owner subsequently confirmed all required physical-device checks (`AI/evidence/M10/device-confirmation.md`), including spoken VoiceOver in all twelve added locales, and authorized production site publication (131/131 exact files; `AI/evidence/M10/site-publication.md`). M10 is now DONE: milestone and strict release both exit 0 on `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`, each 510/510 definitions / 884 invocations, no failed/skipped/expected failures. Verdict READY_FOR_HUMAN; three post-readiness human checklist rows remain PENDING. See `AI/handoffs/M10-handoff.md` and `AI/evidence/M10/release-verification.md`. Store metadata upload, Archive/Organizer validation, distribution and App Review remain separate unperformed actions. Original integration evidence still proves only its named SHA.
