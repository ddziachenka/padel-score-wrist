# M15 local website validation

Prepared website only; no deployment or ASC change. The committed M15 handoff binds
this evidence to the verified REVIEW candidate. App captures have their own exact
source SHA in `manifest.json`; their shipping UI did not change in this milestone.

## Rendered inspection

Command: `node .artifacts/M15-development/check-site.cjs`, exit **0**, 2026-10-23 UTC.
Evidence: `.artifacts/M15-development/site-validation.json`, plus
`site-{light,dark}-{390,1024}.png` in that directory. Chrome headless used the installed
`/Applications/Google Chrome.app`; the script served only `Web/public` on loopback.
No remote website or user browser profile was modified.

- **32 page/width/appearance combinations**: Home, Support, Privacy, Terms at 280,
  320, 390 and 1024 CSS px, in light and dark appearances. No horizontal overflow.
- All six images loaded at native 368 × 448, with descriptive nonempty alt text;
  display preserves aspect ratio. Visual inspection of all six originals and the
  rendered 390/1024 layouts confirmed text, score ownership and image descriptions.
- Every page's first Tab reveals the skip link and a 3 px focus outline. Enter moves
  focus to `main`; subsequent Tab navigation reaches labelled page/footer links.
  Availability text is a paragraph, with no false download button or keyboard stop.
- Normal/muted/link text against both page and card surfaces: **minimum 5.78:1**.
  Focus colors against both surfaces also exceed 4.5:1. The inverted skip link uses
  the page text/background colors. Original app screenshots retain the app palette.
- 200% text at 320 px: all four pages reflow without horizontal overflow. Initial
  Home overflow came from the legal-link cards' fixed minimum column width; changed
  it to a container-bounded minimum and corrected list padding specificity, then
  reran the complete matrix successfully.
- All four local routes returned successfully. `make site-check`, exit **0**, checks
  root-relative links, required sections, EULA link and public identity. It now also
  validates six capture dimensions/hashes/provenance and identical website copies.
  Existing external Apple/Cloudflare links were retained; no live deployment or
  post-deployment HTTP-header verification was performed. `_headers` already permits
  same-origin images; its explanation now matches the imagery.

## Content and self-review

Reviewed the entire baseline-to-tip diff against M15 and implemented behavior.
App Store description: 2,514 characters; promotional text: 160; keywords: 76.
The opening promise, five free completed games, lifetime purchase, offline scoring,
network purchase/restore, fixed one-game demo, free local history, latest-result
Play again and static launcher are explicit. No new app feature, price, data
collection or privacy-retention decision was introduced. No conversion claim or
promise of tournament organization, transfer, sync or cloud backup was added.

Two alt descriptions were corrected after viewing the actual captures: the Match
server is Opponent 2, and the editor capture shows points/games (other controls are
below the viewport). The history image shows a complete Match entry and the next
Americano entry; the fixture contains three dated results. A native screenshot is
allowed to show the real screen's scroll boundary; no interface was painted in.
The unchanged native UI needed no new animation, haptic or decorative illustration.

## Owner actions

M15 does not authorize publishing. After M10's updated final-polish and required
real-Watch evidence are complete, the owner decides whether to publish Web and
replace App Store metadata/screenshots with this prepared English set. Archive,
Organizer validation, distribution and App Review remain separate owner actions.
