# M29 local-site browser review

**Policy status:** current
**Result:** PASS within the stated layout/palette/final visual scope
**HTML/CSS observed source:** `445859bde0740737ccd580ca0fb95dba429fb534`
**Final native-capture source:** `1367217b30ce0c5ffa2c464ea977786e28139439`
**Publication:** none; these are local drafts

Chrome actual-browser observations covered52 pages ×375/1280 CSS-pixel widths ×
Light/isolated Dark CSS preview =208 combinations. The thirteen language routes
and four navigation destinations came from actual visible page links. Every row
has one h1, no empty image alt, exact requested innerWidth/scrollWidth and no
heading/paragraph/figure/list horizontal text overflow. Actual computed body
background is white or rgb(19,19,21), respectively.

Chrome exposed viewport controls but no supported color-scheme emulation here.
The Dark preview is an isolated file copy with only the single dark-media
condition replaced by @media all; it is **not an OS Dark Mode observation**.
All non-CSS files were byte-compared to the real source, and after native import
only its PNG copies were refreshed and compared again. Original system/browser
appearance settings were not changed for this preview.

## Exact binding and checks

`python3 .artifacts/M29/prove-site-identity.py`, exit0,
`.artifacts/M29/site-identity-final.log`, proves all53 current HTML/CSS files are
byte-identical to the browser-observed source and its recorded hashes. It checks
the full208 unique path/width/theme combinations, every passing condition and
all12 computed palette pairs (minimum contrast5.77808, all≥4.5). This is computed
palette review, not a complete browser accessibility audit. The changed localized
five-second/cue text is present in that observed source.

Durable exact data: [binding](site-layout-identity.json),
[browser rows](site-browser-matrix.json), [preview identity](site-preview-identity.json),
[palette](site-palette-contrast.json). This source proof concerns DOM/CSS layout,
not final raster provenance; strict material validation separately passes all210
native captures/28 composites and104 byte-identical site Watch copies. No old
capture is relabelled as build6.

After final import, the Builder inspected actual browser pages with the fresh
native images: EN375 Light hero/cue/recovery and RU1280 isolated-Dark hero/recovery.
The visible images loaded at native368×448 intrinsic size; the explicit first
preview→repeat-two-contacts sequence, team labels, opt-in and recovery boundaries
are readable without horizontal overflow. Lazy images below the viewport are not
called broken or claimed visually checked by that browser spot check. All112
Watch originals have a separate complete fourteen-contact visual review.

Five actual PNGs are under `.artifacts/M29/site-final-*.png`;
[dimensions/hashes](site-final-captures.json) record them exactly. Four are900px
high; the final RU recovery screenshot is1280×581. No900px claim is made for that
last PNG. Final screenshots are visual samples, not another208-combination run.
The prior208 DOM rows remain applicable because every HTML/CSS byte matches and
strict native dimensions/aspect ratios are unchanged.

## Cleanup and limits

Temporary viewport override reset, agent QA tab closed, desktop lease released
(exit0). Both task-created local HTTP servers were deliberately stopped by Ctrl-C
(exit130 each); their keeper stopped with KeyboardInterrupt(exit1). These are
cleanup outcomes, not test failures. No physical phone/watch setting was changed
by this local-site review. No public deployment, upload or external message was
performed. The unchanged full M29 automatic gate remains a separate requirement.
