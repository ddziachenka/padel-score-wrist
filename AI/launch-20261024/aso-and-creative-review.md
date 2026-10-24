# ASO and creative review — 2026-10-24

This is the release-preparation self-review, not an independent release audit. The app implementation remains the verified candidate `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f`; build inputs match preparation HEAD `aeed4c6c9dd910e77189155ceabda753c344e901`.

## Positioning comparison

The following live App Store pages and their first images were inspected on 2026-10-24. No keyword-volume, conversion or popularity data was available or invented.

| Reference | Observed presentation | Decision for our listing |
| --- | --- | --- |
| [Padel Score Watch Counter](https://apps.apple.com/us/app/padel-score-watch-counter/id6742797108) | Blue/yellow sports framing, several device views, many feature badges and broad scoring/fitness claims. | Lead with one legible actual Watch scoreboard; avoid badge clutter and unsupported fitness claims. |
| [PadelWrist](https://apps.apple.com/us/app/padelwrist-padel-score/id6799725420) | Black/blue/orange Watch imagery, scoring plus iPhone setup/synchronization. | Explain standalone Watch use and offline scoring; do not suggest phone setup or cloud sync. |
| [Efecto](https://apps.apple.com/us/app/efecto-padel-americano/id6813393257) | Black/lime cards, prominent iPhone screens, Americano/tournament and lock-screen framing. | Keep the app's existing lime identity, but show the Watch interface prominently. Our Americano claim covers the user's own round, not tournament scheduling. |

The core promise is “focus on the game; see the score and next server at a glance.” Match and Americano, Undo/corrections, offline scoring, local history and one lifetime purchase support it. None is presented as an exclusive feature or an unverified market-leading claim.

## Locale selection

Full A/B subtitle and opening alternatives, selected strings and field lengths are in `.artifacts/asc-launch-20261024/metadata/comparison.json`. Selected complete copy is in the adjacent per-locale JSON files. Read-back from ASC matches all 42 localization records exactly.

| Locale | Selected subtitle | Selection reason |
| --- | --- | --- |
| en-US | Match & Americano scorekeeper | Names both modes and the primary job within 30 characters. |
| es-ES | Marcador de pádel y Americano | Familiar Spanish scoring term and mode; accented pádel. |
| es-MX | Pádel y Americano en tu Watch | Direct regional phrasing with device context; preserves pádel accent. |
| it | Segnapunti Match e Americano | Familiar compact segnapunti; both modes remain explicit. |
| fr-FR | Compteur de padel et Americano | Clear functional wording without an abstract productivity promise. |
| pt-PT | Marcador de padel no pulso | European Portuguese marcador and concise wrist framing. |
| pt-BR | Placar de padel no pulso | Brazilian placar instead of European marcador. |
| nl-NL | Puntenteller voor je Watch | Plain Dutch function plus device; short and readable. |
| de-DE | Punktezähler für deine Watch | Concrete function; avoids an overlong compound marketing slogan. |
| sv | Poängräknare på din Watch | Natural scoring terminology and device context. |
| da | Pointtæller på dit Watch | Plain local terminology and direct personal phrasing. |
| fi | Padelin pisteet ranteessasi | Concise natural Finnish while retaining padel relevance. |
| no | Poengteller på Apple Watch | Clear Bokmål function and device, with localized nb interface/site. |
| ru | Счёт матчей и американо | Immediately explains scoring and both game formats. |

The selected openings describe the player's benefit first and then the visible score/server and tap/Undo behavior. Alternative generic app introductions were less immediate. Longer descriptions cover deuce modes, serving order, resuming, detailed results, local history, Play again, the isolated one-game demo, static launcher behavior, five completed free games, purchase/restore connectivity and local-data limits. No account, iPhone UI, workout, tournament manager or cloud history is promised.

All fields pass Apple length limits. Keywords have no internal duplicates or repeated title/subtitle words and use no competitor names. Launch Promotional Text is separate from evergreen Promotional Text; the long description has no temporary dates or price. Support, Marketing, Privacy and IAP name/description are localized. All 39 unique public URLs returned HTTP 200.

## Screenshot selection

New capture set: 13 actual UI languages, shared Spanish UI for es-ES/es-MX, 78 original attachments copied into 84 locale placements. Every file is 416 × 496 RGB PNG without alpha, captured on an isolated Apple Watch Series 11 46 mm simulator, watchOS 26.1. ASC now labels this same 416 × 496 size family “Apple Watch Series 12”; its API group remains WATCH_SERIES_10_PROFILE. The actual capture device and hashes are recorded accurately, not renamed to the ASC display label.

Order: Match → Americano → Golden point → score correction → result → history. Compared with the previous 44 mm set, the larger canvas better exposes the score, serving player and three result sets. Original approved files remain untouched. Separate scroll experiments in English, Russian and Dutch showed that swiping the result hid the scores and swiping History cut off the latest entry; the original top positions communicate the feature better and were retained. Natural Watch navigation-title truncation and the continuation of scrollable content are visible in the actual UI; no screen was reconstructed or cosmetically altered.

Capture tests: 13 passed, 0 failed, 0 skipped. The additional Access/scroll checks each passed (4 cases); the combined diagnostic run also contained one erroneous new StoreKit assertion, corrected and rerun separately with 1 passed/0 failed. See handoff for exact reports and limits.

All 13 six-image contact sheets were inspected. ASC verifies six ordered placements per locale. English, Russian and Finnish galleries were also inspected in ASC, including long labels. Asset provenance, SHA-256, candidate commit and attachment timestamps are in `screenshots/manifest.json`; the final file manifest is `evidence/final-asset-manifest.json`.

## Header and Search Results

Three compositions were compared: interface-led, court-led, and sports still life with racket/ball. The interface-led composition won because it communicates scoring most directly, leaves the headline readable at small size and crops predictably. Court geometry provides context without competing with the real screen. The sports still life was attractive but made equipment compete with the app's function.

Selected: real localized score screen on graphite with lime court geometry, short localized two-line promise, no temporary promotion or unsupported awards. Header 3840 × 1646; Search Results 1920 × 1280 with a relatively larger scoreboard. All 28 files are opaque PNGs. Generated backgrounds are separate from the unaltered real screenshots; final composition and typography are deterministic.

All 14 Header variants were viewed in the ASC mobile preview in dark mode; all 14 Search Results variants in light mode. English was additionally checked in light/dark and iPad landscape layouts for both surfaces. The English header remains readable in the wide crop; headline and score are not obscured by navigation controls. Local contact sheets cover all text lengths. Preview screenshots: `evidence/asc-header-*.png`, `asc-search-*.png`, `asc-preview-en-US-*.png`. The preview can briefly retain the previous locale's subtitle while loading; final metadata was verified separately via API, and the Search Results captures show the correct localized subtitles.

## Submission blocker

The complete draft contains both intended items, but ASC disables Submit for Review for Watch-only + IAP. This is also stated in current [ASC submission help](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/), while [watchOS documentation](https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps/) describes direct Watch purchases. This conflict needs Apple clarification or an owner-approved product change. No submission was completed and no Waiting for Review status is claimed.
