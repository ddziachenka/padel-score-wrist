# M08 handoff

**Policy status:** current

## Milestone

M08 — Access and Purchase; status `BLOCKED` after implementation and verification.
H4 is resolved; the purchase environment and real-device coverage are not.

## Summary

Five completed Match/Americano games are available automatically. A sixth new game
opens lifetime access; there is no activation step or trial wording in the app.
The owner approved a one-time $4.99 USD non-consumable, with the count preserved on
Delete local data. UI price is always `Product.displayPrice`. Only a verified
StoreKit entitlement unlocks unlimited games. Resume, corrections, Undo, the active
game and last result remain available after the limit or a refund.

The local StoreKit configuration contains the approved product and price. This is
**not** a live App Store Connect product: the account has no app record for either
bundle identifier. No upload or App Review submission occurred.

## Changed files

- `App/PadelScoreWatch/Domain/LifetimeAccess.swift`, `UsageLedger.swift` — completion-based access policy; unique game IDs remain counted through Undo/Resume/deletion.
- `App/PadelScoreWatch/Services/{PurchaseClient,StoreKitPurchaseClient,EntitlementStore,SessionStore}.swift` — verified StoreKit rights, updates, purchase/restore, failure states and fresh access at each command.
- `App/PadelScoreWatch/App/`, `Features/Access/AccessView.swift`, About/NewGame/Game/Settings views — composition, access sheet and voluntary route, preserved draft, automatic free use, localized price and deletion explanation.
- `App/PadelScoreWatch/Localizable.xcstrings`, Xcode project/scheme, `App/StoreKit/Lifetime.storekit` — English copy and test configuration; configuration is not a Release app resource.
- `App/PadelScoreWatchTests/` and `App/PadelScoreWatchUITests/` — 15 new tests, plus the updated deletion-copy assertion.
- `AI/PRODUCT.md`, `ARCHITECTURE.md`, `DESIGN.md`, plan/status/M08 — approved H4 and evidence-based blockers.

## Validation

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

## Tests

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

## Known issues

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

## Next step

Resume **M08**, not M09: obtain an authenticated App Store Connect web session and
create the approved app record, configure `com.dziachenka.padelscore.lifetime` as a
non-consumable at the approved US price, repair/use a functioning StoreKitTest
environment, and perform all required real-Watch purchase cases when hardware is
available. Rerun `make milestone ID=M08` on a clean REVIEW candidate. Only a fully
passing verification plus the required hardware evidence allows DONE.

## Earlier decision checkpoint — historical, resolved by the owner's H4 approval

The following preserves the original pre-implementation checkpoint; its open-H4
next step is superseded by the approved decision and implementation above.

### Milestone


M08 — Access and Purchase; status `BLOCKED` before implementation.

### Summary

The milestone selector returned M08, whose M07 dependency is DONE. Its explicit
entry condition H4 is unresolved: approval of the overall direction did not choose
a commercial model. Recorded the human decision blocker without changing app code.

### Changed files

- `AI/milestones/M08-access-purchase.md` — BLOCKED status.
- `AI/PROJECT_STATUS.md` — current milestone and exact H4a choices.
- `AI/DEVELOPMENT_PLAN.md` — reflects the blocked current milestone.
- `AI/handoffs/M08-handoff.md` — decision and validation record.

### Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | No milestone candidate verified. Baseline: `9ebf054fa19e9b06828f4702d9509cc4e981239c`; documentation checks ran on the working tree above it. |
| Exact command | `./Scripts/project-status.sh next`; `./Scripts/project-status.sh validate`; `make static`; `git diff --check` |
| Exit code | 0 for each command |
| Timestamp | 2026-10-21T11:22:36Z — validation in progress |
| Report | This handoff and command output in the chat; no milestone report or result bundle |
| Counts | 0 app builds/tests executed; no result-bundle counts. `make milestone ID=M08` not run because H4 blocks implementation and there is no REVIEW candidate. |

### Tests

No tests added or changed: only workflow records changed. Self-review confirmed
the blocker against PRODUCT H4a–H4d, M08 scope, and WORKFLOW's human-decision rule.
Static checks passed; optional linters, template-only README structure and
unconfigured site identity checks reported their configured skips, not passes.

### Known issues

M08 cannot select monetization, a price, a trial quota/unit or reset policy for the
owner. Other recorded blockers remain: H1 public particulars for M09, minimum
watchOS runtime coverage, and App Store Connect name availability.

### Next step

Owner chooses H4a: (1) free trial then one lifetime unlock (Recommended: matches
the recorded product direction), (2) fully free v1, monetization in a later task,
or (3) paid download with no trial. Paid choices also need an approved price;
trial needs the explicit quota, counting unit and reset policy. Record the chosen
contract before resuming M08 as IN_PROGRESS; do not start M09.
