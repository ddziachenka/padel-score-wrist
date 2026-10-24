# Later-day native review interruption — M17 correction

Initial clean candidate9ab72b4fec5f657b2e606c09e5e776099a541c24 ran the unchanged
complete make milestone ID=M17: Watch510 definitions/884 invocations passed,
iPhone unit14/20 passed, UI3/6 passed. Raw Make2/verifier1/UI65. Report:
.artifacts/milestone/M17/20261024T182614Z-40349/report.md.
The third failure was not covered by owner acceptance and blocked readiness.

AX hierarchy and native screenshot prove the first Access journey was covered by
Enjoying PadelScore? / Not Now. Both demos were previously completed; the local
calendar day had changed. This is approved production review behavior, not an
entitlement or navigation failure. Production code and review eligibility remain
unchanged. No stars, review submission or Apple account operation was performed.

Correction: the UI harness explicitly identifies this optional native own-app
prompt and declines it through Not Now before continuing. It attaches the popup,
requires the decline button and asserts dismissal. Unknown dialogs are untouched.
Every existing journey assertion, all6 UI cases, all native audit categories,
StoreKit fixtures, full-suite commands and result parsers remain intact. No new
exception, skip, expected failure, production switch or entitlement override.

Bounded diagnosis command (before and after): xcodebuild test -quiet -project
App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Debug -destination
'platform=iOS Simulator,id=51FD3DAD-CE88-4961-8CFF-E1B5EF1F45F7'
-derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-companion
-resultBundlePath <bundle> -only-testing:PadelScorePhoneUITests/CompanionUITests/testAccessIsOptionalAndCanBeOpenedWithoutWatchInstallation
-collect-test-diagnostics never. Filter is diagnosis only, never a release gate.

- Before correction: review-before-fix.xcresult, exit65,1failed/0passed, no skips,
  expected failures or runtime warnings. UTC2026-10-24T21:04:10.006Z–21:04:28.154Z.
- After, normal launch: review-after-fix.xcresult, exit0,1passed/0failed, no skips,
  expected failures or runtime warnings, UTC21:06:48.933Z–21:07:01.071Z.
  Initial seeding attempt used a stale simulator container and failed; the test
  still ran and passed without a prompt. This proves only ordinary startup.
- After, qualifying launch: review-after-fix-eligible.xcresult, exit0,1passed/0failed,
  no skips, expected failures or runtime warnings, UTC21:07:28.726Z–21:07:39.566Z.
  Only owned-simulator review preferences were seeded (both demos, older first use,
  no previous attempt), preserving all other data. Screenshot attachment
  optional-native-review-before-decline proves the native popup really appeared;
  all original Access/Watch requirement/no fake balance/Demo assertions then passed.

Artifacts, summaries, attachment manifests and seed script remain in .artifacts/M17/.
No physical-device preferences were modified. A fresh clean candidate and complete
M17/M18/release gates remain required. Previous raw failure evidence is preserved.
