# M09 — Legal and Support: publication preparation

## Milestone

M09, BLOCKED by the unfinished M08 hardware requirement. The owner's explicit
2026-10-21 instruction authorized all feasible preparation without real Watches,
then approved H1 and publication of a Cloudflare Pages site. No dependency,
verification, or App Review submission requirement has been waived.

## Summary

Prepared full offline English Privacy/Terms/Support on Watch, including readable
public addresses and contact email. About lists all three; Access links to the same
Terms/Privacy before purchase. Published four corresponding Pages documents.
Prepared the English App Store listing, three genuine 368×448 Watch screenshots,
Sports/Utilities categories, 4+ age questionnaire, and private review contact/notes.
Added the shipping privacy manifest after checking Release API usage.

## Changed files

AboutView.swift, AccessView.swift, their UI tests; project resources and privacy
manifest; Config/project.env; Web pages/config/README; PRODUCT/ARCHITECTURE/status;
AI/app-store-listing.md and AI/store-assets/en-US/watch-44mm.

## Validation

Evidence root: `.artifacts/publication-prep/`. Baseline:
`703428c2ed55e6ca0e3a5793e953f5a3da4696f5` (verified M08 app inputs before this work).
Final candidate/test evidence is appended after verification below.

- `make site-check`: exit 0; site-check.log. All four live pages exactly match
  Web/public and return success: padel-live-check.json; response headers saved.
- `make static`: exit 0; static.log. Configured optional analyzer skips remain skips.
- Screenshot capture: capture-screenshots.sh; screenshots.xcresult and
  screenshots-summary.json; exit 0; 4 passed, 0 failed, 0 skipped on managed 44mm.
- Release build command: `xcodebuild build -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-publication-release CODE_SIGNING_ALLOWED=NO`; exit 0; release-build-final.log.
- `python3 .artifacts/publication-prep/check-release.py`: exit 0;
  release-inspection.json verifies watch-only bundle, minimumOS 10.0, privacy
  manifest present, no DebugPremiumOverride or NSUserDefaults symbols in Release.
- Initial new UI check failed because contact/EULA targets were overshot during
  long fling scrolling. Contacts moved to the start for practical access; test
  uses the existing direction-aware short-drag helper and preserves all visibility
  assertions. Failed bundles legal-tests.xcresult and legal-tests-fixed.xcresult
  are retained; neither is recorded as a pass.

## Public and App Store evidence

- https://padel-score-wrist.pages.dev/ and /privacy/, /terms/, /support/ live;
  deployment https://e3e93a8c.padel-score-wrist.pages.dev; padel-deploy.log.
- Support email corrected per owner: dzmitry.dziachenka@gmail.com. Retention:
  within 90 days after closure, except legal obligation/active dispute.
- App 6825393194, version 1.0, remains PREPARE_FOR_SUBMISSION. Lifetime purchase
  6825393394 already configured at $4.99 USA, automatic local prices, 175 regions.
- Screenshot set 8bbf1611-4245-4079-b744-be813012c1dc: three COMPLETE assets,
  no errors. screenshots-final.json; actual screenshots saved in AI/store-assets.
- Listing/info/category/version API saves: HTTP 200; age V2 HTTP 200 gives 4+.
- Review detail created HTTP 201 after owner supplied phone. Private phone is in
  ASC and ignored local request/readback, intentionally omitted from tracked docs.
- No custom EULA. No Game Center or in-app review request API. No third-party SDK.
- App Privacy “Data Not Collected” published after explicit owner confirmation of
  Apple’s accuracy/compliance/update attestation; UI reads “Published … by Dzmitry
  Dziachenka”. Screenshot asc-privacy-published.png. This was not App Review.

## Tests / self-review

This is a Builder's self-review, not an independent audit. Gameplay and commercial
rules unchanged. New UI coverage checks reachable email, public URLs and EULA,
back navigation, and legal access without buying; existing large-text Access test
retained. Public and bundled copy checked against actual local-storage/StoreKit
behavior. No verification gate deploys; site deployment was separately authorized.

## Known issues

M08 requires real-Watch purchase/restore/refund/offline tests; hardware unavailable.
M09's declared `make milestone ID=M09` cannot verify through that dependency.
M10 release audit and exact release gate are not complete. watchOS 10.0 and 10.5
runtime downloads both return exit 70, unavailable from Apple; logs retained.
A deployment target and successful compile are not minimum-runtime evidence.
Real on-court readability, haptics, VoiceOver speech, wrist-down/lifecycle and other
required physical-device checks remain pending. No archive/build upload/App Review.

## Next step

Finish the unavailable M08 real-Watch checks, verify M08 on a clean REVIEW SHA,
then run M09's full declared gate and M10's required audit/release evidence. Do not
mark READY_FOR_HUMAN or submit based solely on this preparation.
