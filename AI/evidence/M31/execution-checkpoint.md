# M31 execution checkpoint — IN_PROGRESS

Task remains end-to-end M31 → M26 → M30, already authorized. No external reply,
upload, submission or GitHub push yet. Do not ask again for those permissions.
Baseline: a946fac88619405e42c11d47f6e2a6fab1cc575c, clean main.
Preparation/frozen capture source: d4fd56eed1ec786b7558b5f64907291bb0f16aee.

Active Watch capture: `bash Scripts/capture-store-materials.sh watch capture m31-watch-gallery-1`.
Tool session95520; console .artifacts/M31/watch-capture-console.log;
native output .artifacts/M25/m31-watch-gallery-1.*. The wrapper holds the managed
checkout/device reservation. Do not touch UI, change App/Config/Scripts or commit
until BOTH Watch and subsequent phone captures finish at this same source.
Next phone command: `bash Scripts/capture-store-materials.sh phone-current capture m31-phone-gallery-1`.

Self-review found one remaining exact-build UI assertion to update AFTER capture:
App/PadelScoreWatchUITests/BootstrapUITests.swift:41 still Version1.0(6); change to7.
This is test-only and excluded from shipping gallery fingerprint; no assertion weakened.
AppConfigurationTests exact CFBundleVersion already7. Production build settings all7.

Then import both native results, compose creatives, prepare site and strict validate
using AI/store-assets/m25/tools/{import-captures,compose-creative,prepare-site,validate}.py.
Recreate contact sheets using existing M29 helper adapted for M31; inspect all14
Watch/phone/creative sheets, runtime launcher icon and circular mask. Update affected
domain records honestly from current evidence + bounded unchanged M29 coverage.
M26 must point at completed current domain records; do not invent completed audits.

Artwork originals App/Design/M31, B selected; exact prompts AI/evidence/M31/icon-prompts.md.
32px/64px previews inspected. Both active1024px PNGs opaque, identical.
Metadata subtitle/promotionalText/evergreenPromotionalText updated all14locales.
Composition now uses concise localized promo instead of long gesture instructions.
README product-focused; original scaffold guide preserved under AI with corrected links.

Reply draft3065chars and Review Notes3553chars under AI/evidence/M31, not sent.
PDF skill read; runtime dependencies available. Required authoring marker ran successfully
once before authoring .artifacts/M31/create-review-guide.py. Do not repeat marker.
Generator refuses old captures; run after import, then render all3pages and inspect.
No new PDF has been generated yet.
Bundled Python: /Users/dima/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.
PDF guide must use NEW source-matched captures, not old build2 materials.

GitHub PUBLIC/empty/ADMIN verified; origin added as https://github.com/ddziachenka/padel-score-wrist.git; no push. History scan2297textblobs,
zero pattern matches; .artifacts/M31/{scan-history.py,history-secret-scan.json}.
Final scan/static still required before push. ASC GET shows only builds1/2; build7 free.

Full gates remain REQUIRED: make milestone ID=M31; M26 milestone and release same
fullSHA; M30 milestone before external sending. Each DONE requires handoff plus
static/status/continuity. All current changes are preparation, not passing gates.

Continuation tools: functions.exec cell g7:51 is polling Watch session95520 and
launches the phone capture ONLY if Watch exits0; it stores phone launch result as
m31phoneCapture. Resume with functions.wait(cell_id=g7:51), do not poll95520 from
another caller. After phone success run `bash .artifacts/M31/refresh-materials.sh`;
that pipeline imports/composes/validates/site-checks/builds contact sheets and PDF.
It preserves all historical M29 artifacts. Inspect42contact sheets and3PDFpages.
PDF authoring marker was already run once successfully. Pipeline not run yet.
Chrome ascTab variable points to existing logged-in user tab1733851052, submission
details. Browser ascBrowser id1, session named Padel review. UI confirmed1Apple
message, no sent reply, app2 rejected, IAP ready; no mutation performed.

Watch gallery COMPLETED exit0,14/14, all adverse0, native summary saved.
Phone launched automatically, session49167. NEW active orchestration cell g7:96
owns its polling; use functions.wait(g7:96), do not separately poll49167.
On phone exit0 it launches refresh-materials.sh and stores result as m31materials.
Still preserve frozen shipping source/HEAD until phone finishes.
Asset upload preparation .artifacts/M30/scripts/assets.rb has syntax pass only,
no external mutation; it requires actual readiness.json for upload/place.
Live ASC specs confirm WATCH_SERIES_4_PROFILE for368x448; new gallery need not
be resized. Existing Apple Distribution identity is valid. Read file-upload CUA
documentation; use filechooser before native picker when attaching guide later.

CURRENT checkpoint2026-11-01T21:26Z: BOTH captures and refresh pipeline finished exit0.
No active capture/pipeline cells remain. Watch14/14;phone2/2,all adverse0.
112Watch+98phone+28creative+104sitecopies strict/source/dimension/opaque checks pass.
All42contact sheets and3PDF pages reviewed; evidence files now written.
Guide committed-source copy AI/store-assets/m31-review/review-guide.pdf with generator;
SHA2562cbf0fe67f6078f4e43b42daced94cfe88c3e4939226bad076e419c048f69271.
BootstrapUITests About assertion nowexact7. README adds architecture and precise
series cadence. make static passes0 (static-materials-final.log).
System launcher/circular icon runtime inspection is STILL PENDING: Mac locked,
CUA getApp Simulator invalid/listApps explicitly reports lock. Owner asked through
request_user_input_async to unlock and reply ready. Direct simctl screenshot under
owned phone lease produced no file; interrupted, leaseexplicitlyreleased, leases{}.
Do not count that as pass or bypass Mac lock. Full automatic M31 gate is independent
and can proceed at the committed REVIEW candidate while waiting; do not mark DONE
or advanceM26 until required icon runtime evidence exists. Any needed production
correction means fresh source/captures/gate, no waiver.
