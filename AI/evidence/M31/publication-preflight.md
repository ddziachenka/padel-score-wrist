# Public repository preflight — in progress

Read-only GitHub API: ddziachenka/padel-score-wrist is PUBLIC and empty;
current authenticated viewer has ADMIN permission. No visibility change needed.

At d4fd56eed1ec786b7558b5f64907291bb0f16aee, the reachable-main-history pattern
scan examined2297 text blobs and found0 embedded private-key/provider-token/
credential-URL matches. Exact script/output: .artifacts/M31/scan-history.py and
.artifacts/M31/history-secret-scan.json. Pattern coverage is bounded, not proof
that arbitrary sensitive content cannot exist. Signing/credential file-name scan
and final static check remain required before public push. Existing .gitignore
excludes signing files, local simulator state and build/distribution artifacts.
No history blob exceeds GitHub's100MiB limit. No push has occurred yet.

The supplied ChatGPT page opens without a login wall and documents original
score-editing, unrestricted-set and lifetime-payment requirements. It describes
early Watch-only development; response correctly labels it as historical.

ASC read-only placement inspection confirms current en-US groups:
IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE (4 old screenshots), WATCH_SERIES_10_PROFILE
(6 old screenshots), DEFAULT_PROFILE with PRODUCT_PAGE_HEADER_ASSET and
APP_STORE_SEARCH_RESULTS_ASSET. New expected counts are7+8+2=17 per locale,
238 placements for14locales. Reuse category/digest upload cache semantics, but
adapt old hard-coded6/8count guards and ordering to the new explicitly intended
inventory in a separate distribution script; never change test-suite count guards.

Ordinary ASC UI readback also confirms the logged-in browser can access submission
17c2964a-e72b-4558-983f-4a40c5545d9f. Exactly1 message (Apple2026-10-27), no sent
reply; app1.0(2) Rejected4.3, lifetime IAP Ready for Review. Resubmit button disabled
in unchanged rejected state; no click or API bypass attempted. Reply button available.
Browser Chrome tab1733851052 currently at the observed submission details URL.

Origin configured to the exact owner-provided HTTPS repository; no push yet.

Live ASC reference data GET `/v1/appAssetLibraryRefData` saved at
.artifacts/M31/asc-asset-reference.json. New native368×448 Watch screenshots map
to WATCH_SERIES_4_PROFILE;1320×2868 phone maps to IPHONE_DYNAMIC_ISLAND_LARGE_PROFILE.
Header3840×1646 and search1920×1280 map to their creative DEFAULT_PROFILE slots.
The search specification is a3:2 dimension range; the Watch spec permits alpha,
which does not require alpha. Original opaque PNGs need no resizing or alteration.
Apple's discovery documentation was read at
https://developer.apple.com/documentation/appstoreconnectapi/discovering-asset-specifications.
Prepared .artifacts/M30/scripts/assets.rb binds all238 intended placements to the
manifest SHA, derives profiles from live specs, separately orders both native
platforms and verifies exact17placements per locale. Ruby syntax passes. It has
NOT uploaded or changed placements; distribution modes require actual readiness.
