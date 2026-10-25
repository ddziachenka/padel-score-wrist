# ASC companion distribution handoff — 2026-10-25

**Policy status:** current

## Result

New signed **1.0 (2)** is uploaded, processed **VALID**, selected for version1.0,
with **AFTER_APPROVAL** and current companion Review Notes saved/read back exactly.
Internal TestFlight state **IN_BETA_TESTING**, only the existing owner tester.
**SUBMITTED jointly through ordinary ASC on 2026-10-25T06:33:55.103Z
(10:33 Tbilisi). App1.0(2) and Lifetime unlock both Waiting for Review.**
Owner unlocked Mac and signed in. New exact TestFlight build2 installed and opened;
focused runtime checks below completed. Fresh StoreKit restoration required an
Apple Account password and was cancelled, not counted as a successful restore.
Existing bounded owner-accepted hardware exceptions remain.

## Candidate and readiness

- Release candidate: `572e3524157154f9104edab61b1d4311de437857`.
- M18 DONE closing commit: `a602c589fbfe3e887357957489f9342ab1bf62eb`.
- Archive source: `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77`; App/Config/Scripts inputs
  identical at candidate and closing commit, confirmed by continuity.
- Exact command: `make release CANDIDATE=572e3524157154f9104edab61b1d4311de437857`.
  Raw **VERIFICATION_FAILED**, Make2/verifier1/phone UI65. Watch510definitions /
  884invocations passed; phone unit14/20passed; UI6executed,4passed/2native Contrast
  failed. No skips/expected/runtime warnings. Only the exact two owner-accepted
  cases remain. Disposition **OWNER_ACCEPTED_FOR_SUBMISSION**, not automated
  READY_FOR_HUMAN or independent approval.
- Full run23:45:37.836428Z–02:20:49.384672Z across2026-10-24/25;
  `.artifacts/release/20261024T234539Z-52536/report.md` and `.artifacts/M18/release.log`.
  Exact per-platform times/commands/counts: `AI/evidence/M18/release-verification.md`.
- Closing static/site/status/continuity exit0, logs `.artifacts/M18/close-*.log`.
  Generated human checklist had3pending rows at gate time, preserved honestly;
  current-pair acceptance, owner distribution decision and signed CLI archive/
  Apple validation are separate evidence. No Organizer/manual clicks invented.

## Uploaded artifact and server identity

| Field | Exact value |
| --- | --- |
| App | `6825393194` / `com.dziachenka.padelscore` |
| Version record | `c4b5fdd4-c48d-4b6b-ab00-60f16d9cf0f3`,1.0,IOS |
| New selected build / delivery UUID | `283096f1-80fe-4114-93c1-6fb9f2ace782`,2,VALID |
| IPA | `.artifacts/asc-companion-20261024/export-02ec9c9/ipa/PadelScore.ipa` |
| IPA SHA256 | `820e0ab32614f429225b67ab78ce614f23f7a65a4db77a1b0ca48cc24d823e0d` |
| Apple upload | altool --upload-package,exit0,02:22:31.146179Z–02:23:53.784396Z |
| Server uploadedDate | 2026-10-24T19:24:46-07:00 =2026-10-25T02:24:46Z |
| Release | AFTER_APPROVAL; PREPARE_FOR_SUBMISSION |
| Export compliance | usesNonExemptEncryption=false, already set by Apple |
| IAP | `6825393394` / `com.dziachenka.padelscore.lifetime`,NON_CONSUMABLE |
| First IAP version | `d96baf47-39f7-4632-856e-b2cd28ec458f` |
| Existing draft | `17c2964a-e72b-4558-983f-4a40c5545d9f`,READY_FOR_REVIEW,submittedDate=null |

Archive/export/actual package/signature and server validation exit0; real iPhone
executable, independent Watch companion and launcher1.0(2), no tests/debug entitlement
in IPA. Provenance `export-02ec9c9/PROVENANCE.md`. **Do not reupload build2.**
Old build1 and older fc118f8 export remain historical, not the current candidate.

Evidence under `.artifacts/asc-companion-20261024/evidence/`:
`upload-2.json`, `upload-exit.json`, `build-processed.json`,
`version-selected-build.json`, `review-notes-saved.json`,
`current-version-after-preparation.json`, `current-draft-after-preparation.json`.
The first selection helper stopped409 because export compliance was already set;
no selection happened in that attempt. Helper now skips an already-false immutable
value and rejects conflicting true. Resumed selection exit0/readback exact.
No application, test, generic gate or declaration semantics changed.

## TestFlight

Owner internal group `a2d69c69-acb9-4bfb-a802-c1329822d20f`; exactly1existing owner
tester and only new build2. Automatic sharing off, no public link/external testers.
English test notes saved. `owner-testflight-build2.json`, `build2-beta-detail.json`,
`build2-test-notes.json`; share helper exit0. Internal state IN_BETA_TESTING;
external READY_FOR_BETA_SUBMISSION means no external review was requested.

Attempted normal iPhone Mirroring after full gate, with actual physical-pair and
desktop lease. Tool reported Mac locked; no phone runtime state could be inspected.
`.artifacts/M18/testflight-physical-unavailable.json`. No password entered or new
purchase/reinstall/restore success claimed. Both leases explicitly released.
Owner's previously accepted current-pair restore/offline/text/Watch observations
remain in M16/M17; do not turn this unavailable new check into a pass.

## ASO and offer

Final42records/14locales reread02:23:37Z and matched the reviewed metadata exactly;
`final-metadata-verified.json`. Title retains **Padel Score — Wrist**; Padel is
indexed from the title and intentionally not duplicated in keywords. Russian
Cyrillic падел is retained. `AI/launch-20261024/companion-aso-final.md` records
editorial alternatives, honest competitor comparison, limits and exact copy.
All14 Promotional Text fields are neutral feature-only evergreen copy without
purchase/subscription/lifetime/price/offer/deadline/urgency. Do not restore the old
launch-offer promo. Long description explains five completed free Watch games and
one-time lifetime later, accurately separating phone demos from real Watch games.

56real1320×2868phone placements plus84original Watch and28Header/Search placements
retained,168total. Canonical phone provenance `AI/store-assets/iphone-m16/manifest.json`.
All14source galleries/creative pairs visually reviewed; representative fresh ASC
English/Finnish/light/dark preview inspected, not falsely14full UI previews.

App download0 in175regions,175available territory choices verified02:09:55Z;
`app-free-availability-verified.json`. Unreleased content status does not mean public.
Existing lifetime0 in175regions and original regional base prices preserved. No
publication confirmed and no end schedule yet. Sandbox/TestFlight does not start
launch offer. Gift covers actual public launch day plus7full regional days; afterward
restore exact original175pricePoints, US4.99. Keep original `.artifacts/asc-launch-20261024/`
for baselines/scripts/offer-end verification. Monitor must bind to this exact new build,
M18 readiness and actual public release date, never discovery date. No automatic
Promotional Text changes. Apple support case103007020727 monitoring scope unchanged.

## Remaining action

1. Owner unlocks Mac and signs in in existing Chrome ASC tab1733848914. Session
   redirects to login with authResult=FAILED; `.artifacts/M18/asc-login-required.png`.
   Async sign-in request pending. No new submission permission is needed.
2. Where available inspect actual new1.0(2) via installed TestFlight on phone; preserve
   existing hardware exceptions and report exactly what is observed.
3. Reload selected version in ordinary ASC website; **Add for Review** the new app
   version to the existing draft while retaining its first lifetime IAP. Old app-only
   draft item was removed normally to allow metadata/media editing. The draft now
   contains the retained IAP only. Do not delete it or use an API submission bypass.
4. Inspect both items and enabled Submit for Review, then submit under existing
   explicit owner authorization. Prior Watch-only restriction is **not proven fixed**
   until this ordinary joint path works. Read back Waiting for Review/In Review,
   submittedDate and both item identities; append actual submission evidence here.
5. Ensure hourly monitor uses exact new build/candidate/handoff before Submit.
   Remain read-only for release pricing until submission and confirmed public
   availability. Notify only new actionable change; don't repeat current auth blocker.

No source change or full rerun is needed solely for this sign-in continuation if
production/test/config inputs retain the verified candidate's exact continuity.

## Monitor continuation guard

Existing hourly heartbeat `padel-score-lifetime` updated in place and saved prompt
read back2026-10-25T02:37:16Z. New M18 candidate/build/handoff guards verified;
neutral promo and exact-case Gmail scope preserved. Evidence:
`.artifacts/M18/automation-new-build-update.json` and
`.artifacts/M18/automation-new-build-readback.json`.
Actual monitor readback02:35:30Z: selected new build2, AFTER_APPROVAL,
PREPARE_FOR_SUBMISSION, public=false. No price mutation/end-date schedule.
Known locked-Mac/ASC-login issue is already notified and must not repeat hourly.


## Actual normal-path submission and physical TestFlight — final continuation

- Human explicitly confirmed unlocked Mac/ASC login and requested TestFlight then
  app+lifetime submission. Clean main HEAD0a0338659b9a6f35e9fab6baf3112d91c69a7cc6;
  continuity572e3524157154f9104edab61b1d4311de437857 exit0. No App/Config/Scripts
  changes or repeated upload/full gate.
- Physical iPhone17ProMax via normal Mirroring, with physical-device+desktop lease.
  Opened only the exact Padel Score TestFlight invitation, installed1.0(2), confirmed
  build2 in TestFlight and first-launch notes, opened Start with visible full copy.
- Match demo40–30/games2–2/You; Them→Golden point40–40; Us→completed3–2,
  Opponent1next, scoring disabled; Undo restoresGolden point; Reset restores40–30.
- Americano10–10/4rallies/Partner/serve1of2; alternating points changes serving block
  toOpponent2, finishes12–12Draw/0remaining with disabled scoring. Undo restores
 12–11/1remaining/serve2of2; Reset restores10–10. Demo label present throughout.
- Access loads StoreKit$0.00 and one-payment/no-subscription/Watch-required copy.
  Restore presented native Apple Account password request; cancelled without entering
  credentials. Settled at No lifetime purchase was found for this Apple Account.
  This is not successful restore/acquisition/cross-device verification. Existing
  owner exceptions remain; no new Sandbox account/reinstall/Watch proof invented.
- Ordinary ASC Add for Review→existing draft retained firstIAP and app1.0(2),
  Items Ready to Submit(2), enabled Submit for Review. Clicked Submit and received
 2 Items Submitted. Detail page shows both Waiting for Review. Prior Watch-only
  submission restriction is factually resolved. No API mutation submitted anything.
- Submission ID17c2964a-e72b-4558-983f-4a40c5545d9f; API submittedDate
 2026-10-25T06:33:55.103Z; submission WAITING_FOR_REVIEW. API included-items
  attributes remain READY_FOR_REVIEW (item-level schema), while ordinary UI displays
  Waiting for Review for both. Monitor06:33:59Z confirms appWAITING_FOR_REVIEW,
  correctbuild283096f1-80fe-4114-93c1-6fb9f2ace782,AFTER_APPROVAL,public=false.
- Evidence: `.artifacts/asc-companion-20261024/evidence/joint-submission-confirmed.json`,
  `iap-after-submission.json` (IAP state WAITING_FOR_REVIEW); `.artifacts/M18/two-items-submitted.png`,
  `joint-waiting-for-review.png`, `testflight-build2-before-install.png`,
  `testflight-start.png`, `testflight-americano-draw.png`, `testflight-access-zero.png`.
- Hourly automation updated in place using automation_update, ACTIVE; new submitted
  state and real TestFlight scope replace stale login blocker. Exact new-build guards,
  original175baselineprices, public-date-based7full-days offer and no-auto-Promo rule
  preserved. `.artifacts/M18/automation-submitted-update.json`. No public release,
  promotion-end schedule or pricing/metadata mutation occurred in this continuation.

Earlier Remaining action and locked-Mac paragraphs above are historical checkpoints;
this actual submission record supersedes their unresolved status. Next: wait for
review/public release under the existing monitor, notify only meaningful change.

Continuation validation: `make static` exit0, `./Scripts/project-status.sh validate`
exit0; pre-documentation clean continuity572e3524157154f9104edab61b1d4311de437857
exit0. `.artifacts/M18/submission-continuation-checks.json`. Only these two AI
Markdown files changed; post-commit exact continuity is checked again. Physical
checkout/device/desktop lease explicitly released exit0. No full-suite rerun needed
for documentation and external distribution state; prior raw counts/exceptions
remain recorded above.
