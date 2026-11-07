# M33 visual review — digital preparation

Builder review, source `8eeec63f5287639b86e637803b436b005a6901da`, build1.0(8).
This is not physical acceptance or independent release approval.

## Compact Watch runtime

`Scripts/simulator.sh run -- bash .artifacts/M33/inspect-watch.sh` exits0.
Managed40mmSE/watchOS26.1 UDID A7CBB23C-F823-4850-BE4B-CAD76922DD08; actual build,
install, launch, screenshots and termination use that explicit UDID inside the
checkout/device reservation. No shared desktop input/capture was used.

Inspected Match start, golden point, Americano, tie-break and gesture-enabled
Match, then native golden-point screens in all13languages. The original PNGs and
comparison contact are `.artifacts/M33/{watch-*,golden-*,golden-locales.png}`.
Scores, server/number, side and controls remain visible at ordinary Large size;
receivers' choice remains readable in the full-width row. Literal L/R remains
unchanged. Goldenpoint can wrap the server into two lines without losing its number
or L/R. No clipping/overlap defect found in these observed states. Largest text,
interaction and speech-label regressions are separate native tests, not inferred
from these stills. Actual VoiceOver audio/on-wrist readability remains BLOCKED.

## Fresh Watch Store gallery

Native14/14tests pass with0failures/skips/expected failures/runtime warnings.
All14raw contact sheets were visually inspected,8native frames each:
EN-US,ES-ES,ES-MX,IT,FR-FR,PT-PT,PT-BR,NL-NL,DE-DE,SV,DA,FI,NO,RU.
Contacts: `.artifacts/M33/raw-watch-review/<language_region>.jpg`; exact112
attachment names/hashes: `raw-watch-review/inputs.json`. Originals stay unmodified
in `.artifacts/M25/m33-watch-gallery-1-attachments/`.

In each locale the gesture live-score frame shows R; Americano shows L with the
actual next server. Known-score previews show R. Finished-result/history frames
remain truthful; three completed sets do not invent an overall Match winner.
Gesture opt-in is visibly OFF. Score editors show actual editable fields.

Viewport limits retained explicitly: opt-in explanatory text, correction preview,
known-score rules, history continuation and some result controls extend below the
captured viewport. The correction capture is an After viewport, not a claim that
all Before/After/service fields appear simultaneously. Full teaching or physical
recognition is not proven by those screenshots. The new separate golden-point
capture and guide cover L/R and receivers' choice directly. No material P0/P1
found in the112reviewed Watch frames.

## Phone, creatives and PDF

All14 phone contacts (98 native frames) and14 creative contacts (28 images) were
visually inspected under `.artifacts/M33/contacts/`, covering the same14 Store
locales. Phone Match40–30 shows L; Americano10–10 shows R; correction Before/After
shows L/R respectively. Demo and simulated-gesture disclaimers remain explicit.
All28 creative images retain optional/off-by-default and compatible-device limits;
no uniqueness, recognition-rate or guaranteed-approval claim is introduced.
Scrollable content continues beneath the tab bar or viewport in some phone
captures; these are viewport images, not proof of complete text visibility.
No material P0/P1 found in the reviewed phone/creative frames.

The112 reviewed raw Watch attachment hashes exactly match all112 canonical Watch
PNGs: `.artifacts/M33/visual-hash-binding.json`. Strict import/composition/site
preparation/material validation and `make site-check` all exit0 via
`bash .artifacts/M33/refresh-materials.sh`. Canonical manifest source is8eeec63;
210 native originals,28 creatives and104 local website copies remain local.
Legacy manifest status labels PENDING_M29 are schema text, not a new acceptance.

Generated `AI/store-assets/m33-review/review-guide.pdf`:4pages,
SHA256 fc98bf5dcacc2576bf52dad871ac4069cad9726840f8b957c991e3b7fafd1f3e.
Rendered all4pages with pdftoppm and inspected each image at1400px. Body text,
captions, screenshots and footer fit without overlap or clipping. Page1 directly
explains R/L/receivers' choice; pages2–4 preserve accurate gesture/recovery/Match
teaching. Native screenshot viewport limits remain visible and disclosed.
The first sandbox render exited0 with Fontconfig cache errors; the unrestricted
render exited0 with only a missing-default-config warning and produced the four
inspected pages (`.artifacts/M33/review-guide-final-1.png` through `-4.png`).

The guide and14 localized snippets are local review drafts, not sent to Apple.
Digital visual review does not establish physical VoiceOver/readability acceptance.
