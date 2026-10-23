# Localization handoff

**Status:** final layout batch and repeated visual checks in progress; no completion or release verdict yet.

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
| Final candidate | PENDING after complete 40-mm visual findings; b03098d integration interrupted |
| Exact integration command | `make integration CANDIDATE=b03098d66ec2948b2c840501773078a83c7dd896` |
| Integration result/counts/time/report | PENDING; command log `/private/tmp/padel-layout-final-integration.log` |
| Per-language commands | `make static` and `make fast` in each recorded worktree; `inputs.json` records full source SHAs |
| Baseline `make fast` | Exit 0; 472 passed, 0 failed/skipped/expected; `evidence/fast-baseline.md` |
| Language `make fast` reports | es, fr, it, pt-PT, pt-BR, nl passed, each 472/472 with zero failed/skipped/expected; remaining streams PENDING |
| Final static | `make static`, exit 0 before candidate freeze; final continuity static PENDING |
| 44-mm captures | Source `615a98d7e5d549bd4574f07537b3eefb50c14d69`; full run exit 0, 13/13 tests; Dutch replacement exit 0, 1/1; zero failed/skipped/expected |
| Capture command | `evidence/capture-command.txt`; every manifest records its exact result bundle and source |
| Visual count | All 78 final PNGs individually inspected; all 52 website routes opened in browser |
| Numeric proof | `xcrun xcstringstool compile` plus `Scripts/probe-localized-plurals.swift`; both messages at 0,1,2,4,5,11,21,22,25,101,999 in every locale; catalog SHA-256 in each `plural-review.txt` |

## Tests and review

Original regression scheme remains intact. New runtime coverage uses all twelve installed locales, real Match/Americano creation, scoring/Undo, corrections, finish, history/replay, data deletion, offline legal/support pages and localized URLs, launcher instructions, restore, save failures and the largest accessibility text on the managed 40-mm Watch. Shared StoreKit and original free-limit/error journeys remain in the complete scheme.

Coordinator read every catalog value/plural, all four complete pages and every store field in every locale, first without English and then against its meaning. Re-read all corrected passages and inspected the runtime screenshots. Terminology and concrete correction examples are recorded in each locale review. This is coordinator editorial review, not an invited native-speaker certification or independent release audit.

Rejected failed/black/incomplete capture attempts instead of accepting structural success alone. Corrected long score/result labels, native Russian denominator grammar, Brazilian zero plural, service-order ambiguity and contextual legal/purchase wording. Full failure/recheck history: `runtime-findings.md`. The interrupted earlier integration is not a pass.

## Known issues and boundary

M10 remains BLOCKED on real-Watch evidence: spoken VoiceOver, on-court operation, Always On/Low Power, oldest-device launch performance, adverse-network StoreKit and the watch-face launcher. Simulator evidence does not replace these checks. No `make milestone ID=M10` or release-ready claim for this candidate. Those gates require the completed hardware audit on the same candidate.

No App Store Connect upload, site publication, App Review submission or archive was performed. Store materials remain local drafts. Original language branches/worktrees and ignored result bundles remain available for reproduction.

## Next step

Finish the pending automated verification and record its exact evidence. Then follow `REAL-WATCH.md` to obtain required real-Watch evidence before M10's six-domain final audit, `make milestone ID=M10` and `make release CANDIDATE=<full-SHA>`. Publication and submission remain separate owner actions.
