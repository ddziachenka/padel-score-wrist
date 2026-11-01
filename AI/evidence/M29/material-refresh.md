# M29 — material refresh, local draft complete

**Policy status:** current
**Record type:** Builder material-refresh work record
**Status:** PASS for the local material-refresh scope; full milestone gate remains separate
**Capture freeze:** `1367217b30ce0c5ffa2c464ea977786e28139439` on main
**Target build:** 1.0 (6), fixed 5 s window and explicit second-series cue

Native capture/import/material/site-check, all 42 contact-sheet reviews, final
browser binding and static have completed. This record does not claim a full
M29 milestone-gate pass, DONE state or release/distribution approval.

## Scope and owner acceptance

Build 6 keeps the five-second reducer and adds waiting for the localized Pending:
US preview before repeating two finger contacts. Cancellation/Undo/data boundaries
remain. Fourteen Store descriptions and thirteen landing/support drafts use the
same rule/cue; pricing, Promotional Text and legal/privacy substance are unchanged.
Shipping bytes remain unchanged from `ff87edd550f376b618d44ebb7904ef29f769b686`;
later gallery-test timing changes do not alter production behavior.

The whole manual physical scope is **OWNER_ACCEPTED_BY_DECISION** in the
[canonical record](owner-physical-acceptance.md), including the explicit follow-up
accepting the enumerated remaining manual rows. No manual repetition is requested
by this refresh. No measured >=95% statistics, recorded counts/duration or supplied
real Watch video are implied or replaced by Simulator footage/artwork.

The unchanged manifest/importer/validator require legacy literal schema markers
`LOCAL_DRAFT_PENDING_M29` and `PENDING_M29`. Preserve them unchanged. They do not
reopen owner acceptance or assert measurements. Actual acceptance lives in the
canonical record; all automated source/count/attachment/format/hash/image/package
checks still apply.

## Source identity

The current imported manifest and both completed capture bundles identify exact
source `1367217b30ce0c5ffa2c464ea977786e28139439`, build 1.0 (6), using
`m29-watch-gallery-2` and `m29-phone-gallery-2`. The prior M25 build 3 import at
`f097a52d6a1154cf431156c30a81013a34d3cd47` remains historical, not current proof.

The two-run source freeze is complete: both source-matched commands passed with
App/Config/Scripts unchanged during capture. After capture, root corrected only
REL1302's queued-input three-to-five-second prose in Config; shipping App bytes
remain unchanged. Final exact-candidate validation must include that correction.
Reviewed catalogs/copy/composition inputs at
`445859bde0740737ccd580ca0fb95dba429fb534` were byte-identical at the capture SHA
(scoped read-only `git diff --name-only`, exit 0/no output).

## Capture results — PASS

| Field | Watch | Phone |
| --- | --- | --- |
| Exact command | `bash Scripts/capture-store-materials.sh watch capture m29-watch-gallery-2` | `bash Scripts/capture-store-materials.sh phone-current capture m29-phone-gallery-2` |
| Source SHA | `1367217b30ce0c5ffa2c464ea977786e28139439` | Same exact SHA |
| Owned UDID | 22C79D99-DEA7-4525-AD2D-50FDCD6B8720 | 2D44D21F-290D-4325-8DED-B98D29977585 |
| Runtime/device | watchOS 26.1, 44 mm SE | iOS 27.0, iPhone 17 Pro Max |
| Exit | 0 | 0 |
| Native start/finish UTC, 2026-11-01 | 12:30:04.524Z–13:10:27.693Z | 13:11:43.049Z–13:24:42.517Z |
| Passed definitions/invocations | 14/14 | 2/2 |
| Failed/skipped/expected/runtime warnings | 0/0/0/0 | 0/0/0/0 |
| Raw bundle |`.artifacts/M25/m29-watch-gallery-2.xcresult` |`.artifacts/M25/m29-phone-gallery-2.xcresult` |
| Summary/exports/context/source identity | PASS, matched and imported | PASS, matched and imported |
| Selected original images | 112 | 98 |
| Accepted import | PASS | PASS |

Source/device/timestamp/action fields, hashes, dimensions and opaque RGB properties
passed strict import/material checks. Raw bundles remain local evidence. Summary,
source, context, exit and attachment files use each `.artifacts/M25/{run}-` prefix;
durable summaries/attachment manifests are
`AI/store-assets/m25/provenance/m29-{watch,phone}-gallery-2-{summary,attachments}.json`.
Native stdout: `.artifacts/M29/watch-gallery-capture-2.log` and
`.artifacts/M29/phone-gallery-capture-2-authorized.log`. Exit files both read 0.

## Import, derivatives and strict checks

Root executed `.artifacts/M29/refresh-materials.sh` with `set -euo pipefail`;
the complete pipeline exited 0 after both source-matched native passes. It ran:

```sh
python3 AI/store-assets/m25/tools/import-captures.py --watch-run m29-watch-gallery-2 --phone-run m29-phone-gallery-2
python3 AI/store-assets/m25/tools/compose-creative.py
python3 AI/store-assets/m25/tools/prepare-site.py
python3 AI/store-assets/m25/tools/validate.py
python3 .artifacts/M29/make-final-contacts.py
make site-check
```

`make static` is tracked separately below; it is not credited by that pipeline.

| Check | Required evidence | Result |
| --- | --- | --- |
| Native import | 210 unmodified captures, 14 locales, exact source/attachments | PASS, exit 0; `.artifacts/M29/material-import.log` |
| Composition | 28 localized images, new-native/artwork hashes and transforms | PASS, exit 0; `.artifacts/M29/material-compose.log` |
| Site images | 104 byte-identical new Watch copies, fixed intrinsic dimensions | PASS, exit 0; `.artifacts/M29/material-site-prepare.log` and strict validator |
| Material validator | Exact command exit 0, all membership/source/format/provenance checks | PASS, exit 0; `.artifacts/M29/material-validate.log` |
| Browser layout/palette | Current HTML/CSS proof, post-import identity/visual checks | PASS; 208 layout rows, 12 palette pairs, minimum 5.778:1, five final visual PNGs; [browser record](site-browser-review.md) |
| `make site-check` | Exit 0 and report/log | PASS, exit 0; `.artifacts/M29/site-check-final.log` |
| `make static` | Exit 0 and report/log | PASS, exit 0; `.artifacts/M29/static-materials-final.log` |

Root ran `python3 .artifacts/M29/prove-site-identity.py`, exit 0. Durable
[layout identity](site-layout-identity.json) proves all 53 current HTML/CSS files
match browser source `445859bde0740737ccd580ca0fb95dba429fb534`, while native
raster source is `1367217b30ce0c5ffa2c464ea977786e28139439`. The
[208-row matrix](site-browser-matrix.json) covers 52 pages × 375/1280 widths ×
Light/isolated Dark CSS preview, all passing. The [12 palette pairs](site-palette-contrast.json)
have minimum contrast 5.778084694407478:1. [Preview identity](site-preview-identity.json)
records the single CSS media-condition substitution; Dark is a local CSS preview,
not OS color-scheme emulation or a complete accessibility audit.

Root visually passed all five post-import browser PNGs: EN 375-wide Light hero,
cue and recovery, plus RU 1280-wide isolated Dark hero and recovery. Their exact
hashes/dimensions are in [final captures](site-final-captures.json); the RU recovery
PNG is 1280×581, not 900 pixels high. These are visual spot checks in addition to
the 208 DOM rows, strict raster provenance and 104 byte-identical site copies.

Copy-fit preflight covered all 28 updated rule/cue blocks at 37–61 pt within existing
boxes and the unchanged 24 pt minimum. [Copy review](material-copy-review.md) checks
13 cross-platform translations/exact preview labels and 14 metadata limits
(maximum 3919/4000). These are source/text checks, not final image or complete
material validation. Pre-import browser layout work is not proof of final raster
provenance. The [current local Review Notes draft](review-notes-draft.md) updates
only the gesture instructions from the historical M25 field; its first-series
five-second deadline and explicit Pending: US cue match build 6. Monetization,
recovery, privacy and separate M30 response context are retained. M30 owns final
candidate/material matching and any separately authorized external use.

## Final visual review — PASS, all 42 sheets

| Final group | Required sheets | Result |
| --- | --- | --- |
| Watch locale sheets | 14 | PASS; [Watch visual record](watch-gallery-visual-review.md) |
| Phone locale sheets | 14 | PASS, 98 native PNG hashes; [phone visual record](phone-gallery-visual-review.md) |
| Creative locale sheets, two compositions each | 14 | PASS, 28 final PNGs; [hash-bound creative record](creative-visual-review.md) |

All 42 final contact sheets were generated by
`python3 .artifacts/M29/make-final-contacts.py`, exit 0, log
`.artifacts/M29/material-contacts.log`, under `.artifacts/M29/contacts/`.
The named Watch/phone/creative reviews inspected all 14 respective sheets. Creative
inspection additionally opened FI/NO/RU/FR search originals and DE header; no P0/P1
or required correction was found. It verifies readable localized rule/cue,
hierarchy, separation/cropping and native/artwork clarity, not hardware accuracy.
Phone review includes all 98 native hashes and RU/DE gesture original spot checks;
its five-second rule/cue is fully visible in all 14 gesture frames. The three
records credit all 42 current sheets, with no P0/P1 or required correction found.
Old sheets are not credited; all final browser identity and visual results are
recorded above.

## Failed and historical evidence retained

- First M29 phone capture invocation without elevated CoreSimulator access stopped
  at inventory, exit69, before native tests/result creation. Raw log:
  `.artifacts/M29/phone-gallery-capture-2.log`. The same script/run name was then
  started with authorized CoreSimulator access; its actual native outcome is
  recorded separately above. No service restart, device erase or parser change.

- M29 `m29-watch-gallery-1`, source 445859bde0740737ccd580ca0fb95dba429fb534,
  remains FAILED / exit 65, 0/14 passed. Native English failure identifies
  StoreMaterialsUITests.swift:448: old 3.3 s Undo checking preceded the approved 5 s
  save. No failed images are imported. The correction waits 5.3 s, keeps save/Undo
  assertions and adds pending/no-early-Undo assertions.
- Focused full English gallery passes 1/1, exit 0, in
  `.artifacts/M29/watch-gallery-timing-after.xcresult`; it does not replace new
  complete 14-locale evidence. [Prototype history](five-second-prototype.md) and
  raw reports preserve before/after detail.
- M25 `watch-gallery-4` 14/14 and `phone-gallery-4` 2/2 at source f097a52 remain their
  own accepted originals, with summaries/exports and old native/artwork versions.
- The first M25 phone/iOS 26.5 probe remains FAILED: its local StoreKit guard
  refused purchase setup. It was not imported/relabelled. Current 27's later
  genuine purchase/owned/relaunch smoke and complete M25 gallery are historical
  passes, not automatic credit for new runs. No StoreKit guard is changed.

## Finalization boundary

This local material-refresh scope is complete; preserve the failed reports and
exact current image/provenance bindings. The unchanged full `make milestone ID=M29` remains
mandatory on final clean REVIEW/main with strict counts/package/source checks and
six domain records. This material record, owner acceptance and targeted passes
cannot replace that gate. No reply/upload/publication/TestFlight/distribution/
submission is performed or authorized here. M26/M30 retain their boundaries.
