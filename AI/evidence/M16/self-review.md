# M16 Builder self-review

This is the Builder reviewing its own baseline-to-tip diff, not independent review
or release approval. Baseline feed3ea7ceb1f5c2ce08075b434dbca4ed9a718f. Current
implementation checkpoint fc118f8a0b357d52e0b06f8ba1f17449297ca623; evidence-only
closing documents may follow. Final unchanged full verification and the bounded
owner acceptance are recorded in
[milestone-verification.md](milestone-verification.md). M16 is DONE under that
exception; raw automated result remains FAILED, not release approval.

- Scope/state: phone has only Start, isolated demos and Access. CompanionDemo owns
  in-memory GameFormat/history with the shared real engines. It has no real game
  repository, usage ledger or entitlement dependency. Navigation/cold-launch reset,
  point debounce, service, end/Undo and draw behavior have meaningful unit/UI tests.
- StoreKit/concurrency: existing EntitlementStore and StoreKitPurchaseClient are
  compiled into both platforms. Signed transactions are checked independently;
  foreground/start/updates/restore refresh ownership, and no WatchConnectivity flag
  grants access. Activity guards avoid concurrent purchase/restore. Tests cover
  zero/paid prices, cancellation, pending, unavailable product/network, verification,
  refund, relaunch/restore and verified ownership after price restoration. Actual
  bidirectional Sandbox acquisition and reinstall were not executed; owner explicitly
  accepts the observed current-pair coverage as sufficient for M16.
- Packaging: root target is a real iOS17 iPhone executable; embedded watchOS10 app
  requires exact companion ID and independent execution, matching versions/builds,
  existing launcher, and no test host/config in distribution. Production/test-host
  source parity and five packaging mutation regressions remain mandatory. Actual
  signed archive checks passed. Self-review caught obsolete Watch-only/build1 unit
  and About UI expectations; they now assert the approved companion/build2 identity
  more precisely, retaining all cases and adding independent-execution validation.
- UX/accessibility: no forced onboarding/paywall, real games explicitly require
  Watch, current StoreKit price and restore remain accessible before Watch install.
  Original empty areas were transparent text caused by compiled asset alpha1/255;
  decimal1.000 and actual compiled-resource AA regression fix it. Owner confirmed
  visible copy. Card/link spacing follows content; all store locales have real
  native images. Spanish largest-text truncation prompted full-width cards, wrapping
  headings/actions and an opaque contrasting neutral card at accessibility sizes.
  Two small-iPhone native Contrast failed results remain known and explicitly
  owner-accepted; no issue/category is filtered from tests. Additional physical
  VoiceOver, haptics and Reduce Motion remain unverified and accepted as omissions.
- Review/privacy: manual rating link is localized in Help. Automatic request requires
  both demos, another day, idle purchase state and365 days between attempts; no
  sentiment gate or paywall prompt. RequestReview is injected from the SwiftUI
  environment. Only local review preferences are added; required-reason manifest
  and all52 site pages reflect them. No account, server, analytics or history sync.
- Localization/store: phone catalog includes shared display strings plus48 translated
  keys; actual catalogs are checked in static/site validation. Four permanent phone
  images per14 ASC locales have native provenance/SHA256. Old84 Watch and28 creative
  assets retain hashes, accurate Watch-first promises and no temporary price. New
  descriptions/review notes distinguish phone from Watch. Site/ASC drafts are not
  falsely reported as published; the launch monitor remains gated on M16/new readiness
  and actual new public build, with no Sandbox/TestFlight promotion clock.
- Verification infrastructure: separate managed bindings/schemes/xcresults are
  mandatory; the primary full Watch suite remains intact. Current iOS unit/StoreKit
  tests pass14 definitions/20 invocations. Supplemental watchOS10 and27 tests pass13
  definitions/24 invocations each; large iOS27 smoke passes4/4. Those earlier
  supplements do not replace the final full Watch510/884 and phone14/20 plus UI6
  runs recorded separately. The approved byte-matched
  generic fixture passed99 cases/2161 checks; actual Padel Python guards still run
  in primary static/site. Historical readiness context requires a verified Watch-only
  SHA and six current companion domain audits; current rating evidence cannot be
  waived. Its six regression mutations pass. A pipeline early-exit defect found
  by the unchanged guard was corrected before the final full self-test passed.

No unrelated work was reverted/stashed. No historical milestone or readiness proof
was rewritten. All observed failed/aborted runs remain distinguishable from passing
evidence. No App Review submission or public launch has occurred.
