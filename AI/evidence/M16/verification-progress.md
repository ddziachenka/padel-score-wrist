# M16 verification progress — 2026-10-24

Builder evidence; M16 is BLOCKED. This record is not an independent audit, a
passing milestone gate, or release readiness. Historical M10 evidence remains intact.

## Source and artifact checkpoints

- UI/archive/capture source: `b2a30e091d423d3414a59d1d2c9c2a65daeb59e5`.
- Gallery + corrected Watch identity assertions: `a153f21b991d2144a6c2cc52e90b3e3e43a405c2`.
  The Watch assertions now require an absent WKWatchOnly key, the exact companion ID,
  independent execution and build2. The About UI must show Version1.0(2). These
  replace obsolete Watch-only/build1 expectations; no test is removed or skipped.
- `make static` exit0: `.artifacts/M16/static-b2a30e0.log`.
- `make site-check` exit0: `.artifacts/M16/site-b2a30e0.log`.
- `python3 Scripts/verify-store-materials.py` exit0 after adding the iPhone gallery:
  `.artifacts/M16/store-materials-final.log`; original Watch and website guards remain.

## Actual iPhone store gallery

`iphone-gallery-m16-v2.xcresult`: exit0, 1 test/1 passed/0 failed/0 skipped/0 expected
failures. Start 2026-10-24T13:35:43Z, finish13:39:05Z. Four screenshots for each of14
ASC locales, iPhone16 Pro Max/iOS18.5, dark appearance, status9:41. Native screenshots
are copied byte-for-byte: `AI/store-assets/iphone-m16/manifest.json` carries their
source SHA, raw attachment names, timestamps and SHA256. All56 are opaque RGB
1320×2868; order Start, Match, Americano, Access. Access uses a real verified local
StoreKit transaction, followed by a settled relaunch; no entitlement override or
short-lived price is painted into the images.

Seven inspection contact sheets cover all14 locales. Where the conversation image
renderer omitted large glyphs, a direct native-pixel crop confirmed the original
file contains them. Local Apple Vision OCR independently recognized40/30 in every
Match capture and two10 scores in every Americano capture, across all56 PNGs:
`.artifacts/M16/gallery-native-ocr.json`. Originals were never modified.

The previous ASC assets are preserved. Their existing final manifest was re-read:
84 Watch images,14 Headers and14 Search images retain their dimensions, opaque RGB
format and SHA256. Header text has no obsolete Watch-only promise or temporary
price. Watch view changes are extraction of existing shared values/messages;
scoring, correction, result/history and launcher presentation source remains intact.
This source/asset check does not substitute for the new full Watch suite.

## Signed archive

`xcodebuild archive -quiet -project App/PadelScore.xcodeproj -scheme PadelScorePhone
-configuration Release -destination 'generic/platform=iOS' -derivedDataPath
/private/tmp/padel-m16-archive-final -archivePath
.artifacts/M16/PadelScore-M16-b2a30e0.xcarchive DEVELOPMENT_TEAM=WW8JPY8B94
CODE_SIGN_STYLE=Automatic -allowProvisioningUpdates` — exit0.

`python3 Scripts/verify-companion.py --phone-app
.artifacts/M16/PadelScore-M16-b2a30e0.xcarchive/Products/Applications/PadelScore.app`
and `codesign --verify --deep --strict` for that app — both exit0. Logs:
`archive-b2a30e0.log`, `archive-b2a30e0-packaging.log`. Actual iOS executable,
independent embedded Watch and launcher, matching1.0(2), PadelScore iPhone label;
no test host, xctest or local StoreKit configuration in distribution. No upload.

## Runtime supplements

- iOS27.0 iPhone17 Pro Max: `ios27-smoke.xcresult`, exit0,4/4 UI cases, zero
  failures/skips/expected failures/warnings. Both demos, optional Access and English/
  Spanish largest-text native audits. This is supplemental; it does not replace iOS17.
- iOS18.5 iPhone16 Pro Max: `ios18-largest-native.xcresult`, exit0,2/2 largest-text
  native audits, zero failures/skips. The same tests failed on the smaller SE in
  `ios18-small-largest-native.xcresult`; therefore the issue is not classified as
  specific to iOS17 on the basis of differing device sizes.

## Open accessibility diagnostic

The original Spanish largest-text run reproduced NOSOTROS truncation. The production
layout now gives accessibility sizes full-width score cards and full team labels;
regular sizes retain side-by-side scoring. Text, Undo/Reset and the context header
wrap rather than truncate. Inactive native tab labels use the verified semantic
secondary color. The original invisible-copy defect remains fixed and was confirmed
by the owner on hardware.

Strict small-iPhone native audits still report Contrast failed, including an
unmapped issue. This is an unresolved validation failure, not a pass and not a
proven false positive. Native textClipped checks remain required too. No category
or unknown issue is excluded. A broader recheck experiment triggered XCTest-injected
runtime logging/quarantine crashes; its crash stacks and failed bundles are retained,
and that experimental helper was removed. No production scoring/purchase crash is
inferred from this automation failure. The retained helper still fails immediately
on an unmapped native issue.

The physical Mac/pair became unavailable; automatic device inventory reports the
owner iPhone and Watch unavailable. Earlier owner confirmations cover visible text,
Watch update, restores on both and scoring without phone connectivity only. Fresh
purchase in both directions, reinstall restore, Watch with companion absent and
physical VoiceOver/haptics/Reduce Motion remain unverified. No Sandbox account has
been created and no existing tester purchase history reset.

## Outstanding gates

Full existing Watch suite, final complete iOS suites and exact clean-REVIEW
`make milestone ID=M16` are not yet a passing M16 result. Required hardware is also
incomplete. Separate Release Readiness Revalidation and normal ASC joint-submission
verification remain after M16; nothing has been submitted to App Review.

## Tooling and current Watch supplement completed

The approved final template fixture run passed: `make self-test` exit0,99 cases,
2161 checks passed,0 failed. Generic source checkpointb2a30e091d423d3414a59d1d2c9c2a65daeb59e5;
fixture76aa09b05613156708b304bdc65bf4ed8911c0e6. All28 generic source hashes match.
See self-test-fixture.md and tooling-fixture-manifest.json; this is not real Xcode evidence.

Current watchOS27.0 SE3 40mm supplement passed, exit0:13 definitions/24 invocations,
0 failed/skipped/expected failures/runtime warnings. Bundle `watch27-smoke.xcresult`,
summary `watch27-smoke-summary.json`, UTC13:47:43.320–13:52:22.895. Command driver:
`bash .artifacts/M16/runtime-profile.sh watch-current run bash .artifacts/M16/check-watch-current.sh`.
Its explicit scope is AppConfigurationTests, LauncherTests, BootstrapUITests and
LauncherUITests. It validates actual independence/companion/version/localizations
and launcher journeys; it does not replace the complete primary Watch suite.

## Minimum Watch supplement and current iPhone unit suite

watchOS10.0 SE40mm supplement: `watch10-smoke.xcresult`, exit0,13 definitions/
24 invocations,0 failures/skips/expected failures/warnings. UTC13:54:17.177–13:58:05.467.
Driver `runtime-profile.sh watch-minimum run bash check-watch-minimum.sh` performs
build-for-testing, then test-without-building for the same four explicit classes as
watchOS27. The generated xctestrun copy adds only the previously documented M14 UI
DYLD_FRAMEWORK_PATH bootstrap prefix; assertions, SDK/runtime files and diagnostics
remain unchanged. The copy stays alongside its original Products/test paths.

Full iPhone unit/StoreKit suite on sourcefc118f8a0b357d52e0b06f8ba1f17449297ca623:
`ios-unit-current-complete.xcresult`, exit0,14 definitions/20 invocations,0 failures/
skips/expected failures/warnings. UTC14:00:44.129–14:00:53.949. Exact command driver:
`Scripts/simulator.sh --profile companion run -- bash .artifacts/M16/check-phone-complete.sh`;
its first action uses schemePadelScorePhoneUnit with no only-testing/skip-testing or
retry arguments. Full companion UI suite is the next separate xcresult.

## Current full UI outcome and desktop blocker

Full iPhone UI suite on fc118f8a0b357d52e0b06f8ba1f17449297ca623 completed:
`ios-ui-current-complete.xcresult`, exit65,6 definitions/invocations,4 passed/2 failed,
0 skipped/expected failures/runtime warnings; UTC14:00:54.672–14:04:42.148. Failures:
`testLargestTextAccessibility` and `testSpanishTeamNamesAtLargestTextAreNotClipped`,
both Contrast failed. Both demos, optional Access, StoreKit-owned relaunch and the
14-regional-context gallery passed. The full suite has no only-testing/skip-testing
or retry arguments. This failed suite blocks M16 verification.

At14:05–14:06Z the Builder acquired the owned iPhone SE + desktop reservation and
attempted the normal Xcode UI route for a visual audit. Computer Use returned:
“The Mac is locked and automatic unlock could not unlock it.” No UI action was
performed and no lock was bypassed. The reservation was explicitly released.
Manual Mac unlock and physical pair reconnection are required to continue that
inspection/hardware work; previous questions remain unanswered.

A current signed archive at the same fc118f8 source also completed, exit0:
`.artifacts/M16/PadelScore-M16-fc118f8.xcarchive`. Its exact archive command matches
the earlier command with that archive path; packaging guard and deep strict
codesign verification both exited0 (`archive-fc118f8.log`,
`archive-fc118f8-packaging.log`). This is a local archive, not an ASC upload or
release-readiness verdict. The b2a30e0 permanent gallery remains accurate at regular
text sizes; the subsequent production delta only distinguishes the neutral card's
background at accessibility sizes. Its original capture provenance is preserved.
