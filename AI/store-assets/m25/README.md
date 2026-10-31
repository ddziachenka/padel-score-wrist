# M25 active Store materials — local draft

This is the current prepared gesture/recovery set:14 ASC locales,112 Watch and98
iPhone original native captures,28 localized creative compositions. Hardware claims
remain **PENDING_M29**; nothing is uploaded, published or sent by M25. Old M15/M16
sets are historical source evidence and remain byte-checked separately.

## Native galleries

Watch order: gesture-enabled real score; optional per-game OFF setup; agreed-score
Points editor; selective rally correction After preview; unrestricted Match sets;
Americano; known-score start review; local History. Each language/region has its
own actual XCTest attachments, not translated overlays. Screenshots retain natural
scroll viewports; the app's remaining text is reachable by scrolling.

Phone order: explicit gesture simulation; correction preview; known-score preview;
Start; ordinary Match demo; Americano demo; permanent StoreKit-verified owned Access.
Real games run on Watch; the phone does not recognize Watch Double Tap. All seven
images per locale are new actual captures of build3's final shipping UI.

Locales: en-US,es-ES,es-MX,it,fr-FR,pt-PT,pt-BR,nl-NL,de-DE,sv,da,fi,no,ru.
The thirteen public-site routes use es-ES for Spanish; the separate es-MX native
Store capture is preserved. Watch PNGs368×448; iPhone PNGs1320×2868; opaque RGB.
The104 site Watch images are byte-identical copies, scaled only by CSS.

## Artwork and creative composition

[Selection](artwork/selection.md), [three exact direction prompts](artwork/prompts.json),
[refinement prompt](artwork/refinement-prompt.txt), [selected hand](artwork/selected-hand.png).
Built-in imagegen tool mode; the three directions and refined original are retained.
One hand pose illustrates fingertip contact; programmatically typeset localized
copy explicitly says TWO contacts per series. One/two/third series and fixed3s
rules are words, never inferred from a single pose. No generated/reconstructed UI
or fictional device display is used.

Per locale, header3840×1646 and search1920×1280 combine the selected hand, an actual
native Watch image and localized app-catalog text. Artwork/native transforms,
font sizes, text boxes and source hashes are in [manifest.json](manifest.json).
These are marketing compositions, distinct from the unmodified native galleries.

## Provenance and reproduction

Capture source: `f097a52d6a1154cf431156c30a81013a34d3cd47` on main, build1.0(3).
All shipping App file membership/bytes match the current material fingerprints;
the complete final App/test source is frozen for both new captures. The full
immutable gate verifies its own final source/tests/assets commit separately;
these targeted captures are not its replacement.

- Watch: `bash Scripts/capture-store-materials.sh watch capture watch-gallery-4`,
  exit0,14/14 definitions/invocations, zero failures/skips/expected/runtime warnings.
  Owned44mm SE/watchOS26.1,22C79D99-DEA7-4525-AD2D-50FDCD6B8720.
- Phone: `bash Scripts/capture-store-materials.sh phone-current capture phone-gallery-4`,
  exit0,2/2, zero failures/skips/expected/runtime warnings. Owned17ProMax/iOS27.0,
  2D44D21F-290D-4325-8DED-B98D29977585. The same current capture profile is
  reproducible through `bash Scripts/capture-store-materials.sh phone-current capture <new-safe-run-name>`.
- The first phone/iOS26.5 gallery remains FAILED because its local StoreKit guard
  refused purchase setup; it is not imported. Current27 first passed a genuine
  purchase/owned/relaunch smoke, then the complete gallery. No StoreKit guard was
  removed. Raw cancelled/failed earlier runs remain in .artifacts/M25/.

Durable native summaries/export manifests are in provenance/. Every native image
records attachment, exact source SHA, device, timestamp, fixture/actions, dimensions
and hash. Raw result bundles remain .artifacts/M25/watch-gallery-4.xcresult and
phone-gallery-4.xcresult, never in Git. Rebuild after complete new native runs:

```sh
python3 AI/store-assets/m25/tools/import-captures.py --watch-run watch-gallery-4 --phone-run phone-gallery-4
python3 AI/store-assets/m25/tools/compose-creative.py
python3 AI/store-assets/m25/tools/prepare-site.py
python3 AI/store-assets/m25/tools/validate.py
make site-check
```

## Copy and external boundary

metadata/ contains fourteen local JSON drafts under Apple's field limits. Title,
subtitle, keywords and neutral evergreen Promotional Text are retained. Descriptions
are gesture-first and explain touch/Undo, correction boundaries, unknown earlier
rallies, independent Watch, five completed games and the lifetime purchase; no
exclusivity or guaranteed review outcome. Existing truthful format/history/offline
and legal site facts are preserved in site-preserved-copy.json.

[Review Notes draft](../../evidence/M25/review-notes-draft.md) has a separate field
under4000characters and factual M30 response context. Published support/privacy/
terms were read back separately; local new site texts have not been deployed.
The current authenticated ASC declaration says Data Not Collected, while build2
and its old notes remain selected/live. M29 supplies actual recognition/video/
physical checks; M26 verifies readiness; M30 requires its distribution instruction.

All14 final Watch,14 phone and14 creative contact sheets were visually reviewed.
Strict provenance/format/source/site validation passes; site-layout-identity.json
binds the final52 HTML pages and CSS to the recorded208-combination browser proof.
This is local draft preparation. The extra current-Simulator full StoreKit unit
probe remains FAILED/P2 with identical baseline reproduction; see
[bounded runtime evidence](../../evidence/M25/storekit-current-runtime.md).
Actual recognition/VoiceOver/purchases and other hardware observations remain M29.
