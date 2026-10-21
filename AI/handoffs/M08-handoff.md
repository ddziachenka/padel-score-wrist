# M08 handoff

**Policy status:** current

## Milestone

M08 — Access and Purchase; status `BLOCKED` for required real-Watch coverage.
Automated milestone verification **passes**; live App Store Connect setup is complete. Nothing was submitted for review.

## Summary

Configured the live App Store Connect app and lifetime purchase on 2026-10-21,
after the owner explicitly authorized setup without review submission and confirmed
free download plus availability in all 175 regions. API readbacks verify:

| Setting | Saved value |
| --- | --- |
| App | `6825393194`, `Padel Score — Wrist`, `com.dziachenka.padelscore`, SKU `padel-score-wrist`, `en-US` |
| Registered bundle IDs | Container `7T9U2U93B6`; Watch `YL54982QR2`; both include `IN_APP_PURCHASE` |
| Lifetime product | `6825393394`, `com.dziachenka.padelscore.lifetime`, `NON_CONSUMABLE`, Family Sharing off |
| Price | USA base **$4.99 USD**, one manual price without end date; **174** automatic regional prices |
| Availability | App and purchase each **175** territories; new territories enabled; no pre-order |
| Download price | **Free**, verified US customer price `0.0` |
| Localization | `en-US`: `Lifetime unlock`; `Unlimited games. One-time lifetime purchase.` |
| Draft version | `d96baf47-39f7-4632-856e-b2cd28ec458f`, `PREPARE_FOR_SUBMISSION` |
| Review screenshot | `2834a750-4f15-445c-9e1e-ecc89d47c9ab`, genuine 368×448 Watch capture, asset state **COMPLETE** |
| Final state | IAP **READY_TO_SUBMIT**; app version 1.0 **PREPARE_FOR_SUBMISSION**; review submissions **0** |

Review notes describe the automatic five completed games, one-time purchase,
About → Access restore path, continued access to an existing game, and retained
usage after local-data deletion. No build was uploaded and no review action was taken.
Public app listing/legal/contact details still belong to later milestones.

The earlier StoreKit repair remains unchanged: fixed the local StoreKit test environment without changing production purchase
logic or weakening test assertions. The shared scheme now uses an explicit test
plan, so local StoreKit is active before the hosted app initializes its client.
The managed runtime is pinned to watchOS 26.1 (`23S36`). After a simulated purchase
network error, the test resets session defaults and re-enables dialog suppression;
transaction history stays intact and the same owner retries the purchase.

The approved behavior remains five completed games free automatically, followed
by a one-time lifetime unlock at $4.99 USD, with the count retained on Delete local
data. Price comes from StoreKit. No activation step or trial wording was added.

## Changed files

- Current ASC session: only `AI/PRODUCT.md`, `PROJECT_STATUS.md`, `DEVELOPMENT_PLAN.md`, M08 and this handoff. All app/build inputs and the original 40 mm managed binding were restored unchanged.
- Earlier StoreKit repair below remains the verified implementation.
- `App/PadelScore.xctestplan`, shared scheme and `project.pbxproj` — both original test targets, serial execution, English/US settings and StoreKit configuration before launch; no test exclusions.
- `App/PadelScoreWatchTests/Services/StoreKitPurchaseTests.swift` — reset test-server settings after the simulated outage; every original assertion retained, no transaction clearing before retry.
- `Config/project.env` — watchOS 26.1 on the same SE 2 40 mm device type.
- `App/README.md`, `AI/ARCHITECTURE.md`, plan/status/M08 records — reproduction, environment choice and remaining blockers.

## Validation

### App Store Connect session evidence

- Source HEAD: `2fbadddba04924dc373805e53a206a07d4b76b55`; passing milestone candidate remains `14fffe5b70fcf859841a89c1363992fee313eafc`.
- Evidence directory: `.artifacts/M08-asc-setup/`. `asc.mjs` uses the configured environment credentials, signs JWT in memory, and saves HTTP status/timestamp/request path with each response; it never saves the private key or JWT.
- Exact API command form: `node .artifacts/M08-asc-setup/asc.mjs METHOD PATH REQUEST_JSON_OR_DASH RESPONSE_JSON`. The response files retain every exact method/path; request JSON files retain bodies. Successful creates returned 201, updates/readbacks 200, replacement of this session's rejected screenshot 204. CLI exit 0 for final successful operations.
- Readback reports: `app-created.json`, `bundles-verified.json`, `iap-final.json`, `price-verified.json`, `automatic-prices-verified.json`, `free-app-price-verified.json`, `availability-verified.json`, `app-availability-verified.json`, `screenshot-44-verified.json`, `app-version-final.json`, `review-submissions-verified.json`.
- Initial 324×394 screenshot was rejected with `IMAGE_INCORRECT_DIMENSIONS`. It was replaced by a fresh native 368×448 capture; no resizing or synthesized UI. Final screenshot processed with `COMPLETE`, no errors/warnings.
- Capture command: `bash .artifacts/M08-asc-setup/capture-44-storekit.sh`, exit **0**. Exact xcodebuild invocation is in that script and the head of `capture-44-storekit.log`; selects `StoreKitPurchaseTests/testPurchaseRestoreRefundAndLocalizedPrice` and `AccessUITests/testSixthGameShowsAccessAndClosingKeepsResultAndDraft`.
- Capture result: `capture-44-storekit.xcresult`, `capture-44-storekit-summary.json`: **2 passed, 0 failed, 0 skipped**, 2026-10-21T15:09:10Z–15:10:13Z. Initial UI-only capture also passed 1/1 but displayed product unavailable because local StoreKit had not been initialized; that image was not uploaded. This focused capture is additional evidence, not a replacement milestone gate.
- Capture simulator: managed Watch SE 2 44 mm / watchOS 26.1 (`23S36`), `DF6ED19D-1461-4A25-975B-1A4995E8AA20`. It is retained as `-asc-44mm` with `.iosai-local/simulator-asc-44mm.json`; original Config and 40 mm binding restored, no devices/data erased.
- App/build source unchanged; full `make milestone ID=M08` was not repeated for AI Markdown continuity edits. Static/status/continuity validation is recorded below after the session commit.

### Existing full milestone gate

| Field | Evidence |
| --- | --- |
| Verified SHA | `14fffe5b70fcf859841a89c1363992fee313eafc`, clean `main`, declared `REVIEW` |
| Baseline SHA | `dc134cc92c95f081788e1809a31c82def3db337a`; original failed implementation gate below remains preserved |
| Exact command | `make milestone ID=M08` |
| Exit code | **0**; build and test xcodebuild both **0** |
| Timestamp | Gate `2026-10-21T14:07:27Z` → `2026-10-21T14:44:37Z`; tests finished `2026-10-21T14:44:27Z` |
| Report | `.artifacts/milestone/M08/20261021T140724Z-29203/report.md` — PASSED |
| Counts | **386 logical tests passed, 0 failed, 0 skipped, 0 expected failures**: 328 Swift tests, 4 StoreKit tests, 54 UI tests. Expanded device summary: **730 passed**, 0 failed/skipped. One Debug gate build passed. |
| Bundle and logs | `.artifacts/milestone/M08/20261021T140724Z-29203/{milestone.xcresult,counts.txt,build.command,build.log,test.command,test.log}`; `.artifacts/M08-storekit-fix/{milestone-console.log,milestone-summary.json}` |
| Environment | Xcode 27.0 (`27A266a`), watchOS SDK 27.0, runtime 26.1 (`23S36`), Apple Watch SE 2 40 mm; managed UDID `A7CBB23C-F823-4850-BE4B-CAD76922DD08` |

Diagnostic evidence is under `.artifacts/M08-storekit-fix/`. Each xcodebuild log
starts with its exact invocation; corresponding `.xcresult` and `*-summary.json`
files retain counts. `diagnosis.json` records the experiments and source changes.

| Run | Result / exit | Finding |
| --- | --- | --- |
| `baseline` on baseline SHA, runtime 26.5 | 0/4 passed, 4 failed, 0 skipped / 65 | `SKInternalErrorDomain Code=3`; system log says host is not installed for development although `simctl listapps` reports `IsDeveloperApp=1` |
| `identity-experiment`, `no-distributor` | Each 0/4 passed / 65 | Temporary bundle suffix and removal of the distributor environment variable do not fix setup; both experiments discarded |
| `runtime-27` | 0/4 passed / 65 | Session configuration works, but app's early Sandbox client cannot find the local product |
| `testplan-27` | 3/4 passed, 1 failed, 0 skipped / 65 | Pre-launch test configuration fixes products; injected network purchase error surfaces as `StoreKitError.unknown` |
| `testplan-26-5` | 0/4 passed, 4 failed, 0 skipped / 65 | Explicit test plan does not repair the 26.5 configuration rejection |
| `testplan-26-1` | 3/4 passed, 1 failed, 0 skipped / 65 | Network classification works; clearing only the error code leaves `cancel-purchase-batch=1` in the local server response |
| `reset-26-1` | **4/4 passed**, 0 failed/skipped / **0** | Resetting session defaults restores the server response, without clearing transactions; final gate above verifies the committed result |

`network-error-27` directly reproduced `StoreKitError.unknown` with no underlying
error through `Product.purchase()`, independently of the application's mapping.
`network-codes-27` was a temporary diagnostic probe, **not** a regression-test pass:
all four requested URLError variants read back as network error but purchases
returned unknown. Temporary instrumentation was removed before the verified commit.
The related [Apple DTS discussion](https://developer.apple.com/forums/thread/826971)
is background; the Watch diagnosis rests on the recorded local comparisons.

## Tests

ASC Builder self-review compared live product ID/type to the production client and
local StoreKit file, checked $4.99/USD and $0 download readbacks, all-region counts,
English metadata, screenshot processing and zero review submissions. It found and
corrected the unsupported screenshot size and the restore-path wording. This is
self-review, not an independent audit or release approval.

The four StoreKit scenarios now pass against real local StoreKit transactions:
purchase/localized price/restore/refund updates, pending approval through updates,
invalid signatures refusing access, and network failure/retry/verified offline
access/restore. All 54 UI regressions also pass, including automatic free use,
the sixth-game purchase sheet, retained drafts/results, deletion retaining usage,
Resume after the limit, large text and accessibility.

Builder self-review, not independent review: compared the full repair diff and
original test targets/assertions; checked pre-launch configuration, serial session
ownership, unchanged product IDs and production access rules, resource membership,
and configuration-only reset before retry. No user-facing surface changed in this
repair. The full UI suite verifies the existing journeys on the pinned runtime.

## Known issues

1. **Blocking:** required real-Watch purchase coverage did not run; the owner again
   confirmed hardware is unavailable. Local StoreKit success does not replace it.
2. Live purchase configuration is complete and verified above. App metadata, legal/support particulars, build upload and eventual submission remain separate work; this session does not claim release readiness.
3. watchOS 26.5 and 27.0 StoreKitTest failures above are retained environment
   limitations. Their simulators/data were preserved with `-retained-26-5` and
   `-retained-27-0` names; original bindings are in ignored
   `.iosai-local/simulator-watchOS-{26-5,27-0}.json`. Reproduction on an older
   candidate requires an explicit managed-binding/name switch per WORKFLOW.
4. H1 public particulars and minimum watchOS 10 coverage remain existing project
   dependencies; the chosen public name is now accepted in App Store Connect. Earlier Release containment evidence is
   preserved below; this repair's gate proves Debug/test behavior, not Release UI
   or device purchases. No tests were skipped to cover an unavailable environment.

## Next step

Resume **M08** when real hardware is available. Complete required Watch
purchase/restore/revocation/pending/offline coverage using the configured product.
Reverify any changed candidate. Do not submit the app or IAP without a new explicit instruction.
Do not mark DONE or start M09 on the strength of simulator tests alone.

## Earlier implementation verification — historical

The following record describes `5760247a971eecd7151c92209cdd14291c032bd3` and the
previous blockers. Its StoreKit environment blocker is superseded by the passing
repair evidence above; the original evidence and earlier H4 checkpoint are retained.

### Milestone

M08 — Access and Purchase; status `BLOCKED` after implementation and verification.
H4 is resolved; the purchase environment and real-device coverage are not.

### Summary

Five completed Match/Americano games are available automatically. A sixth new game
opens lifetime access; there is no activation step or trial wording in the app.
The owner approved a one-time $4.99 USD non-consumable, with the count preserved on
Delete local data. UI price is always `Product.displayPrice`. Only a verified
StoreKit entitlement unlocks unlimited games. Resume, corrections, Undo, the active
game and last result remain available after the limit or a refund.

The local StoreKit configuration contains the approved product and price. This is
**not** a live App Store Connect product: the account has no app record for either
bundle identifier. No upload or App Review submission occurred.

### Changed files

- `App/PadelScoreWatch/Domain/LifetimeAccess.swift`, `UsageLedger.swift` — completion-based access policy; unique game IDs remain counted through Undo/Resume/deletion.
- `App/PadelScoreWatch/Services/{PurchaseClient,StoreKitPurchaseClient,EntitlementStore,SessionStore}.swift` — verified StoreKit rights, updates, purchase/restore, failure states and fresh access at each command.
- `App/PadelScoreWatch/App/`, `Features/Access/AccessView.swift`, About/NewGame/Game/Settings views — composition, access sheet and voluntary route, preserved draft, automatic free use, localized price and deletion explanation.
- `App/PadelScoreWatch/Localizable.xcstrings`, Xcode project/scheme, `App/StoreKit/Lifetime.storekit` — English copy and test configuration; configuration is not a Release app resource.
- `App/PadelScoreWatchTests/` and `App/PadelScoreWatchUITests/` — 15 new tests, plus the updated deletion-copy assertion.
- `AI/PRODUCT.md`, `ARCHITECTURE.md`, `DESIGN.md`, plan/status/M08 — approved H4 and evidence-based blockers.

### Validation

| Field | Evidence |
| --- | --- |
| Candidate SHA | `5760247a971eecd7151c92209cdd14291c032bd3` on clean `main`; baseline `b60156329b921d7e2ae7a4b91ea6f0dcdb44872d` |
| Exact command | `make milestone ID=M08` |
| Exit code | Make **2**; milestone script **65**; underlying test xcodebuild **65** |
| Timestamp | Started `2026-10-21T12:05:31Z`; tests completed `2026-10-21T12:44:24Z` |
| Report | `.artifacts/milestone/M08/20261021T120528Z-97148/report.md` — FAILED |
| Counts | **386 logical tests: 382 passed, 4 failed, 0 skipped, 0 expected failures**. 328 Swift tests and 54 UI tests passed. 68 parameterized tests contain 412 runs; expanded device summary is 730 runs: 726 passed, 4 failed. |
| Bundle and logs | `.artifacts/milestone/M08/20261021T120528Z-97148/{milestone.xcresult,counts.txt,build.command,build.log,test.command,test.log}`; console `.artifacts/M08/milestone-final-console.log`; exported summary `.artifacts/M08/milestone-final-summary.json` |
| Build results | Gate static checks and one Debug build passed. One unsigned Release build on the same SHA passed (exit 0), command below. |
| Environment | Xcode 27.0; watchOS Simulator 26.5, Apple Watch SE 40 mm; managed UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92` |

Release command (exit 0), log `.artifacts/M08/release-candidate.log`:

```sh
xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Release -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/padel-score-m08-release CODE_SIGNING_ALLOWED=NO build
```

Release binary inspection passed: `DebugPremiumOverride`, `setDebugPremium`,
`forcePremium`, and `PADEL_UITEST` absent; zero `.storekit` resources in the app.
`.artifacts/M08/release-candidate-containment.json` binds the scan to the candidate
and its artifact path. This proves compilation containment, not device purchases.

The pre-candidate targeted run in `.artifacts/M08/targeted-final.xcresult` recorded
15 tests: 11 passed, 4 failed, 0 skipped, exit 65. It used the same app code except
catalog restoration/whitespace; final gate evidence above supersedes it. Its exact
xcodebuild command is the first command in `.artifacts/M08/targeted-final.log`.
Optional simulator diagnostics were stopped after those tests completed to allow
bundle finalization; test failures were retained. An earlier Xcode launch experiment
and the first milestone attempt on `0100bbd64e7a59be1fa3541e634cbd44c08a9d94`
were interrupted, not passed. The latter was restarted after restoring a catalog entry.

### Tests

Policy tests cover the first five completions/sixth refusal, Americano automatic
and corrected finishes, idempotent game IDs, deletion, paid completions/refund and
uncertain ledgers. Owner tests cover verified-only rights, wrong products,
unverified results not being finished, pending/cancel/offline/product unavailable,
restore, updates/revocation, isolated Debug override and persisted session integration.

Four real StoreKitTest scenarios remain failing: purchase/restore/refund/localized
price; pending approval via updates; invalid signatures; network failure/offline
verified rights. All fail while configuring `SKTestSession`, with
`SKInternalErrorDomain Code=3` (Error saving configuration file). The explicit
`disableDialogs` guard fails them rather than letting an inactive test configuration
contact the real store. No tests were skipped, removed or loosened.

UI tests drove automatic free access, the sixth-game sheet, close/back preserving
setup and result, Resume after the limit, deletion retaining usage, About → Access,
legal routes and largest text. All existing UI regression suites also passed.

Builder self-review (not independent review) checked ownership/concurrency,
transaction validation, persistence, active-game continuity, states, localization,
accessibility and Release containment. Corrected actor isolation, removed an unused
route, fixed project grouping, shortened purchase copy after runtime inspection,
and restored the existing `Keep playing` catalog entry. Re-inspected the resulting
screens in `.artifacts/M08/ui-final-screenshots/`:
`AD61905E-ECC0-44CE-8C8B-F1FBD678EFC1.png` (paywall),
`7C8350F9-692E-43BA-9726-62A7AB90FE75.png` (largest text),
`972198DA-2D05-4CD1-BD4D-46A6EEA11696.png` (deletion),
`3783FB4D-5DFC-4184-BFA9-60F91E0AE0B2.png` (Resume).

### Known issues

1. **Blocking:** StoreKitTest configuration fails in this installed runtime. Launching
   the scheme through Xcode did not repair CLI `SKTestSession`. This is an observed
   environment failure, not a claim of a pre-existing repository defect. A related
   [Apple forum report](https://developer.apple.com/forums/thread/826971) discusses
   iOS 26.5 CLI failures; it does not prove the cause on this Watch runtime.
2. **Blocking:** required real-Watch purchase testing did not run. The owner explicitly
   said hardware testing is unavailable; connected-device inspection showed the Watch
   offline. Simulated clients and Release compilation do not replace this coverage.
3. **Blocking purchase setup:** API GET app lookups returned no records for
   `com.dziachenka.padelscore` and `com.dziachenka.padelscore.watchapp`
   (`.artifacts/M08/asc-app-records.jsonl`). [Apple's Apps API](https://developer.apple.com/documentation/appstoreconnectapi/apps)
   cannot create the initial app record. The browser reached App Store Connect `/login`;
   no authenticated web session was available. No app/product/production price created.
4. Existing project dependencies remain: H1 public particulars for M09, minimum
   watchOS 10 runtime coverage and public-name availability. Full legal/support copy
   belongs to M09. Local count retention after reinstall or changing Watches is not promised.

### Next step

Resume **M08**, not M09: obtain an authenticated App Store Connect web session and
create the approved app record, configure `com.dziachenka.padelscore.lifetime` as a
non-consumable at the approved US price, repair/use a functioning StoreKitTest
environment, and perform all required real-Watch purchase cases when hardware is
available. Rerun `make milestone ID=M08` on a clean REVIEW candidate. Only a fully
passing verification plus the required hardware evidence allows DONE.

### Earlier decision checkpoint — historical, resolved by the owner's H4 approval

The following preserves the original pre-implementation checkpoint; its open-H4
next step is superseded by the approved decision and implementation above.

#### Milestone


M08 — Access and Purchase; status `BLOCKED` before implementation.

#### Summary

The milestone selector returned M08, whose M07 dependency is DONE. Its explicit
entry condition H4 is unresolved: approval of the overall direction did not choose
a commercial model. Recorded the human decision blocker without changing app code.

#### Changed files

- `AI/milestones/M08-access-purchase.md` — BLOCKED status.
- `AI/PROJECT_STATUS.md` — current milestone and exact H4a choices.
- `AI/DEVELOPMENT_PLAN.md` — reflects the blocked current milestone.
- `AI/handoffs/M08-handoff.md` — decision and validation record.

#### Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | No milestone candidate verified. Baseline: `9ebf054fa19e9b06828f4702d9509cc4e981239c`; documentation checks ran on the working tree above it. |
| Exact command | `./Scripts/project-status.sh next`; `./Scripts/project-status.sh validate`; `make static`; `git diff --check` |
| Exit code | 0 for each command |
| Timestamp | 2026-10-21T11:22:36Z — validation in progress |
| Report | This handoff and command output in the chat; no milestone report or result bundle |
| Counts | 0 app builds/tests executed; no result-bundle counts. `make milestone ID=M08` not run because H4 blocks implementation and there is no REVIEW candidate. |

#### Tests

No tests added or changed: only workflow records changed. Self-review confirmed
the blocker against PRODUCT H4a–H4d, M08 scope, and WORKFLOW's human-decision rule.
Static checks passed; optional linters, template-only README structure and
unconfigured site identity checks reported their configured skips, not passes.

#### Known issues

M08 cannot select monetization, a price, a trial quota/unit or reset policy for the
owner. Other recorded blockers remain: H1 public particulars for M09, minimum
watchOS runtime coverage, and App Store Connect name availability.

#### Next step

Owner chooses H4a: (1) free trial then one lifetime unlock (Recommended: matches
the recorded product direction), (2) fully free v1, monetization in a later task,
or (3) paid download with no trial. Paid choices also need an approved price;
trial needs the explicit quota, counting unit and reset policy. Record the chosen
contract before resuming M08 as IN_PROGRESS; do not start M09.
