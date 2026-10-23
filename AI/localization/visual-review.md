# Coordinator visual review

Shipping 44-mm screenshots: all 72 added locale images and all six refreshed English images individually inspected. Source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`; original exports and hashes are in the shipping manifests. French/Russian replacements and the two Portuguese Portugal replacements use passing result bundles at the same source, recorded per image where needed. Every final shipping image was individually inspected and 78/78 matched the exact original attachment bytes.

Final product source under integration: `b6cbb53163027283e8466b97b0f35e67b8ae62f4`. Additional bounded QA source `43a2d7460d21d785fed6dc193f8aab2d094a2398` has identical product files; the only difference under App is added test-only probes in StoreMaterialsUITests.swift. Both devices use managed Apple Watch SE 40-mm simulators on watchOS 26.1.

The full final scheme supplies largest-text rules, demo, privacy, terms, support, launcher help, access/restore, live score and save-error captures, plus actual Match/Americano completion and data-deletion states. Additional QA supplies six normal-size 40-mm captures and seven expanded Americano/result/history captures per locale. Captures are read as complete rendered screens; an accessibility tree alone does not establish that glyphs fit.

| Locale | Shipping 44 mm (6 each) | Additional 40 mm normal/expanded (13 each) | Final journeys and creation (13 each) |
| --- | --- | --- | --- |
| es | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| it | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| fr | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| pt-PT | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| pt-BR | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| nl | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| de | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| sv | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| da | reviewed | reviewed, corrected source cbe452 | reviewed; four banner phrases corrected, fresh proof pending |
| fi | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| nb | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |
| ru | reviewed | reviewed, corrected source cbe452 | reviewed, no new finding |

Real spoken VoiceOver is not covered here; all required Watch rows remain unverified in REAL-WATCH.md until M10 records hardware evidence.

The complete 156-image first pass found Spanish team-name/editor clipping at maximum text and Dutch/Swedish server-number clipping at normal 40-mm size. All corrections are tracked in runtime-findings.md; affected surfaces are repeated before acceptance.

Final bounded QA: `/private/tmp/padel-final-expanded-command.sh`, source `43a2d7460d21d785fed6dc193f8aab2d094a2398`, product files identical to `cbe452b0efda5c1c06aac97cc6b5132817876cd8` and candidate `b6cbb53163027283e8466b97b0f35e67b8ae62f4`. Exit 0; 24 passed, 0 failed/skipped/expected; 1,609.868 s. Result `/private/tmp/padel-l10n-layout-qa/.artifacts/localization/final-expanded.xcresult`; exports in `final-expanded-exports`. All 156 images individually inspected again (72 normal, 84 expanded). Spanish full team names/editor alignment and all twelve locales’ full metric labels/server numbers are readable. Native scrolling/marquee navigation titles and offscreen rows remain available through normal scrolling; body/action copy is preserved.

Some tool presentations suppress unchanged image regions. Pixel inspection confirmed apparently absent normal Americano role text/controls were byte-identical to the complete preceding Match regions (Danish, French, both Portuguese variants). This was a presentation artifact, not missing pixels in the original PNG or a product defect; no speculative layout adjustment was retained.

All 156 combined-scheme frames read; hashes and Danish correction disposition: `evidence/final-context.md`. Corrected Danish copy requires a fresh exact candidate gate.
