# Active Store materials — local draft, M29 build 6 refresh

Current copy targets **1.0 (6)**: a fixed five-second window and an explicit cue
to wait for the localized Pending: US preview, then repeat the series (two finger
contacts). The target set is 14 ASC locales, 112 Watch and 98 iPhone native captures,
plus 28 localized creative compositions.

**Refresh status: local material-refresh scope PASS.** Both native galleries,
210 originals, 28 compositions, 104 site copies, strict material validation,
site-check, static and all 42 contact-sheet visual reviews passed. Current
[manifest.json](manifest.json) identifies build 6 capture source
`1367217b30ce0c5ffa2c464ea977786e28139439`. Final browser binding passes 208 layout
rows, 12 palette pairs (minimum 5.778:1) and five final visual spot checks. See
[M29 refresh](../../evidence/M29/material-refresh.md). Full M29 gate/DONE and any
release/distribution approval are separate; they are not claimed here.

The unchanged manifest/importer/validator schema retains the literal markers
`LOCAL_DRAFT_PENDING_M29` and `PENDING_M29`. These are legacy M25 schema values;
they do not reopen manual acceptance. M29's whole manual physical scope is
**OWNER_ACCEPTED_BY_DECISION** in the [canonical owner record](../../evidence/M29/owner-physical-acceptance.md).
No measured percentages, elapsed-hour/event counts or supplied real Watch video
are implied. Keep guards unchanged and do not manufacture measurement/media proof.
Nothing here authorizes upload, publication or submission.

## Native galleries

Watch order: gesture-enabled real score; optional per-game OFF setup; agreed-score
Points editor; selective rally correction After preview; unrestricted Match sets;
Americano; known-score start review; local History. Each language/region requires
its own actual XCTest attachments, not translated overlays. Natural scroll
viewports are retained; remaining app text stays reachable by scrolling.

Phone order: explicit gesture simulation; correction preview; known-score preview;
Start; ordinary Match demo; Americano demo; permanent StoreKit-verified owned Access.
Real games run on Watch; the phone does not recognize Watch Double Tap. All seven
images per locale are fresh build 6 captures in this refresh.

Locales: en-US, es-ES, es-MX, it, fr-FR, pt-PT, pt-BR, nl-NL, de-DE, sv, da, fi, no, ru.
The thirteen public-site routes use es-ES for Spanish; the separate es-MX native
Store capture is retained. Watch PNGs 368×448; iPhone PNGs 1320×2868; opaque RGB.
All 104 site Watch images are verified byte-identical copies, scaled only
by CSS. Old M15/M16 sets remain historical evidence checked separately.

## Artwork and composition

[Selection](artwork/selection.md), [original direction prompts](artwork/prompts.json),
[refinement prompt](artwork/refinement-prompt.txt), [selected hand](artwork/selected-hand.png).
The original imagegen directions and refined hand are retained. A fingertip-contact
pose illustrates the action; localized words explicitly define TWO contacts per
series. One/two/third-series semantics, fixed 5 s and the first-preview cue are words,
not inferred from a pose. No generated/reconstructed UI or fictional display is used.

Per locale, header 3840×1646 and search 1920×1280 combine the original hand, an actual
native Watch capture and localized catalog text. The updated rules block includes
the second-series cue. Copy-fit preflight passed all 28 blocks at 37–61 pt inside the
existing boxes and unchanged 24 pt minimum; this is not final visual approval.
Fresh composition and all 14 creative contact-sheet reviews PASS; see the
[hash-bound review](../../evidence/M29/creative-visual-review.md). Final transforms,
fonts, boxes and hashes are recorded in the manifest. Composites remain
separate from unmodified native galleries.

## Current freeze and reproduction

Both complete native runs used unchanged App/Config/Scripts at main SHA
**`1367217b30ce0c5ffa2c464ea977786e28139439`**, build 1.0 (6). This includes the gallery
test's corrected 5.3 s wait and extra pending/no-early-Undo assertions. Shipping bytes
remain unchanged from `ff87edd550f376b618d44ebb7904ef29f769b686`. The full milestone
gate verifies its own clean final implementation/assets commit separately.

| Run/check | Required result | Recorded result |
| --- | --- | --- |
| `m29-watch-gallery-2` | 14/14 definitions/invocations, zero adverse native counts | PASS, exit 0 |
| `m29-phone-gallery-2` | 2/2 definitions/invocations, zero adverse native counts | PASS, exit 0 |
| 112 Watch + 98 phone originals | Exact attachments/source/device/hash/dimensions | PASS import and strict validation |
| 28 creatives and 104 site copies | Exact new-native identity/composition/byte checks | PASS, strict validator exit 0 |
| 14 Watch + 14 phone + 14 creative sheets | Actual final visual review | PASS, all 42 current sheets |

Watch uses owned 44 mm SE/watchOS 26.1, `22C79D99-DEA7-4525-AD2D-50FDCD6B8720`.
Phone uses owned iPhone 17 Pro Max/iOS 27.0, `2D44D21F-290D-4325-8DED-B98D29977585`.
Preserve raw bundles under `.artifacts/M25/m29-watch-gallery-2.xcresult` and
`.artifacts/M25/m29-phone-gallery-2.xcresult`. The two-run freeze is complete.
Watch native UTC: 2026-11-01T12:30:04.524Z–13:10:27.693Z; phone:
13:11:43.049Z–13:24:42.517Z. After capture, root corrected REL1302 queued-input
three-to-five-second prose in Config; shipping App bytes remain unchanged.

The completed pipeline imported only after both passing source-matched runs:

```sh
bash Scripts/capture-store-materials.sh watch capture m29-watch-gallery-2
bash Scripts/capture-store-materials.sh phone-current capture m29-phone-gallery-2
python3 AI/store-assets/m25/tools/import-captures.py --watch-run m29-watch-gallery-2 --phone-run m29-phone-gallery-2
python3 AI/store-assets/m25/tools/compose-creative.py
python3 AI/store-assets/m25/tools/prepare-site.py
python3 AI/store-assets/m25/tools/validate.py
python3 .artifacts/M29/make-final-contacts.py
make site-check
```

Root's `.artifacts/M29/refresh-materials.sh` uses `set -euo pipefail` and completed
exit 0. Logs: `.artifacts/M29/material-{import,compose,site-prepare,validate,contacts}.log`
and `.artifacts/M29/site-check-final.log`. The importer/validator retain all source,
attachment, provenance, image and site-copy guards. `make static` separately
passed exit 0 in `.artifacts/M29/static-materials-final.log`.

[Watch](../../evidence/M29/watch-gallery-visual-review.md),
[phone](../../evidence/M29/phone-gallery-visual-review.md) and
[creative](../../evidence/M29/creative-visual-review.md) records bind all 42 sheets
and final image hashes. [Browser review](../../evidence/M29/site-browser-review.md)
records `python3 .artifacts/M29/prove-site-identity.py`, exit 0: all 53 HTML/CSS files
match source `445859bde0740737ccd580ca0fb95dba429fb534`, the 208-row layout matrix
passes, and all 12 computed palette pairs pass (minimum 5.778084694407478:1). Dark is an
isolated CSS preview, not OS preference emulation. Five final post-import visual
PNG spot checks pass for EN 375-wide Light and RU 1280-wide isolated Dark; exact
hashes/dimensions are in [capture identity](../../evidence/M29/site-final-captures.json),
including the 1280×581 RU recovery image. DOM/palette coverage, raster identity and
visual spot checks retain their separate scope; no complete browser accessibility
audit or full milestone-gate result is implied.

## Historical evidence retained

Previous imported M25 source `f097a52d6a1154cf431156c30a81013a34d3cd47`, build 1.0 (3),
used `watch-gallery-4` 14/14 and `phone-gallery-4` 2/2; all 42 sheets were reviewed.
Their durable summaries/export manifests remain in `provenance/` and raw bundles
in `.artifacts/M25/`. Those passes do not prove this new build 6 refresh.

The first phone/iOS 26.5 gallery remains **FAILED** because its local StoreKit guard
refused purchase setup; it was not imported. Current 27 later passed a genuine
purchase/owned/relaunch smoke and the complete M25 gallery. No StoreKit guard was
removed. Raw cancelled/failed attempts remain preserved.

M29 `m29-watch-gallery-1` remains **FAILED** / exit 65, 0/14 passed: the old 3.3 s Undo
check preceded the approved 5 s save. A focused English scenario passes 1/1 after
correcting to 5.3 s and adding assertions; it does not replace the full 14-locale result.
See [prototype history](../../evidence/M29/five-second-prototype.md).

## Copy and external boundary

Fourteen local metadata JSON drafts stay within Apple's field limits. Title,
subtitle, keywords, pricing and neutral evergreen Promotional Text are retained.
Descriptions teach 5 s/first-preview cadence, touch/Undo, correction boundaries,
unknown earlier rallies, independent Watch, five completed games and the lifetime
purchase. No exclusivity, guaranteed recognition or review-outcome claim is added.
Existing format/history/offline and legal facts remain in `site-preserved-copy.json`.

The [current M29 Review Notes draft](../../evidence/M29/review-notes-draft.md)
updates build 6's five-second first-series deadline and second-series cue. It stays
local; future M30 owns final candidate/material matching and separately authorized
external use. The [M25 draft](../../evidence/M25/review-notes-draft.md) remains
historical. M25 ASC/privacy readbacks are historical observations, not a fresh
ASC-state claim. New local site copy is not deployed. The baseline-matched current Simulator
StoreKit probe remains FAILED/P2 in [its record](../../evidence/M25/storekit-current-runtime.md),
not accepted as passing here. M26 retains full readiness verification; M30 retains
separately authorized distribution/review work.
