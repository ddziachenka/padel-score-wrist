# M08 local StoreKit environment investigation

**Policy status:** current

## Milestone

M08 — Access and Purchase; **BLOCKED**. Neither the physical-Watch local matrix
nor the current shipping-ID milestone gate passes. Nothing was submitted or
uploaded for App Review. No OS update, account change or purchase charge occurred.

## Summary

The shipping-ID Sandbox purchase/restore pass in
[M08-sandbox-identity-handoff.md](M08-sandbox-identity-handoff.md) remains historical
valid evidence. This session isolates two different local-testing failures:

1. With the correct executable ID `com.dziachenka.padelscore.watchkitapp`,
   SKTestSession targets that executable, while public AppTransaction identifies
   `com.dziachenka.padelscore`. Session history and app entitlements therefore
   disagree. On the simulator the original tests also cannot clear the app's
   existing rights or inject errors, and access UI sees the wrong ownership state.
2. A separately installed diagnostic host with the container ID aligns those
   identities. Initially its currentEntitlements was empty although latest(for:)
   returned a verified Xcode purchase. After the owner restarted the Watch,
   purchase/fresh-owner restore/refund, pending approval and invalid-signature
   rejection pass: **3/4 original tests**. The remaining network test expects
   `.offline`, but StoreKit returns `.unknown` and the app correctly reports
   generic failure. A direct Product.purchase() probe reproduces this for five
   public error-injection variants, independently of application error mapping.

No history fallback, grant from an unverified transaction, unknown-as-offline
classification, skipped original test or weaker assertion was introduced.
The isolated host is diagnostic evidence, not a shipping-identity verification.

## Changed files

- The owner's existing Xcode scheme-format rewrite was committed unchanged as
  `c05a717` (SHA256
  `6b19770fb56b152ab94d13891606f8b5118b82e9f040509498517eec948dd3c8`).
- Workflow records: this handoff, M08 main handoff/contract and PROJECT_STATUS.
- All temporary project, app, configuration and test edits were restored. The
  committed production code and all four StoreKit tests are byte-identical to
  starting SHA `97d949e76ac132f23e3feaab256bf67f1de528b2`.

## Validation

| Field | Evidence |
| --- | --- |
| Candidate SHA | `52182dfb8bc8380afc9fd1445b6429cbef31a98c`, clean main, REVIEW |
| Exact command | `make milestone ID=M08` |
| Exit code | Make **2**, gate **65**, xcodebuild **75** after scoped SIGINT |
| Timestamp | Gate started `2026-10-21T21:35:54Z`; test result ended `2026-10-21T21:49:36Z` |
| Report | `.artifacts/milestone/M08/20261021T213552Z-95330/report.md` — FAILED |
| Counts | xcresult: **348 total / 340 passed / 8 failed / 0 skipped / 0 expected failures**. Four StoreKit + three access UI failures occurred before interruption; the eighth is the UI test canceled by SIGINT. Remaining tests did not run. One Debug build passed. **Not a complete gate.** |
| Environment | Xcode 27.0 (27A266a), managed Watch SE2 40mm / watchOS 26.1, UDID `A7CBB23C-F823-4850-BE4B-CAD76922DD08` |

The failed gate was deliberately stopped after the local namespace failure and
all three access UI failures were recorded, while unrelated correction UI tests
were still running. It must be rerun in full after repair; the historical
386/386 pass used the old executable ID and does not validate this candidate.

Physical device: Watch Ultra 3, watchOS 27.0.1 (24R365),
UDID `00008310-000823642660E01E`. Evidence root:
`.artifacts/M08-local-session/`. Each log begins with its exact xcodebuild command;
`.exit`, `.xcresult` and `*-summary.json` preserve exit/count evidence.

| Run | Result | Meaning |
| --- | --- | --- |
| `activate` | exit 0, 1/1 UI passed | About UI activation switches to local Xcode environment |
| `binding-after-ui`, `binding-app-id`, `binding-parent`, `parent-configured`, `isolated-host`, `app-transaction`, `root-host`, `root-diagnostic` | each exit 65, 0/1 passed, 0 skipped | Isolated namespace/currentEntitlements failures before restart |
| `binding` | exit 65, no tests | Diagnostic compile error, corrected in binding2 |
| `binding2` | count assertion passed against an existing Sandbox purchase | **Not local coverage**; later probes explicitly require Xcode environment |
| `after-restart` | exit 65, test body did not run | Watch clock/display policy blocked launch |
| `reboot-awake` | exit 65, **3 passed / 1 failed / 0 skipped**, 4 total | Original four scenarios in aligned diagnostic host after restart; only offline-message assertion fails |
| `error-probe` | exit 65, 0/1 passed | Original network test with diagnostic logging confirms StoreKitError.unknown |
| `error-serialization` | exit 0, 1 diagnostic method completed | Prints five direct failures; **not an acceptance pass**, no assertion of network behavior |
| `normal-build` | exit 0, build succeeded | Ordinary corrected-ID Debug app rebuilt from clean candidate source |

The original post-restart test command, at `2026-10-21T21:43:40Z`:

```sh
xcodebuild test-without-building \
  -xctestrun .artifacts/M08-local-session/root-host.xctestrun \
  -destination 'platform=watchOS,id=00008310-000823642660E01E' \
  -destination-timeout 30 \
  -resultBundlePath .artifacts/M08-local-session/reboot-awake.xcresult \
  -only-testing:PadelScoreWatchTests/StoreKitPurchaseTests \
  -skip-testing:PadelScoreWatchTests/StoreKitPurchaseTests/testLocalSessionBindingDiagnostic \
  -parallel-testing-enabled NO -collect-test-diagnostics never \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 60 \
  -maximum-test-execution-time-allowance 60
```

The excluded method is an added diagnostic probe; all four original tests ran
unchanged. The xcresult reports zero skipped tests. The host's temporary
bundle-ID/project delta is preserved in `root-project.pbxproj` and
`root-scheme.xcscheme`; original files are also retained. It is not the unchanged
shipping project and is not claimed as such.

The direct error serialization probe, `2026-10-21T21:47:33Z`–`21:47:48Z`, requests:

- `.networkError(URLError(.notConnectedToInternet))`
- `.systemError(URLError(.notConnectedToInternet))`
- `.systemError(NSError(domain: NSURLErrorDomain, code: -1009))`
- `.systemError(SKError(.cloudServiceNetworkConnectionFailed))`
- `.networkError(URLError(.timedOut))`

All return `StoreKit.StoreKitError.unknown` from Product.purchase(). The exact
source is `ErrorSerializationDiagnostic.swift`; the artifact-only experiment is
`/private/tmp/padel-m08-local-probe/App`. This is bounded diagnostic code, not a
change to the shipping client or regression tests. Earlier private namespace
probes were rejected by StoreKit and removed; no private API remains in source.

## Tests

Builder self-review: production purchase code and four original StoreKit tests
match the starting commit. Temporary probes/configurations were removed from the
checkout. No independent review or release approval is claimed.

Actual ASC app/team IDs in the StoreKit file and suppressing the host scene's
early StoreKit calls did not fix the `.watchkitapp` mismatch. A temporary
container-ID host made currency controls and dialog suppression work. The Watch
restart then repaired its entitlement visibility. These are observed findings,
not proof of a universal Apple workaround. Apple's related reports are context:
[CLI configuration discussion](https://developer.apple.com/forums/thread/826971),
[watchOS 27 StoreKit known issues](https://developer.apple.com/documentation/watchos-release-notes/watchos-27-release-notes).
Neither establishes a confirmed fix for the exact namespace/network failures here.

## Device cleanup and data preservation

The owner's prior authorization covers reinstalling only Padel Score and restoring
its game data. Fresh backups were taken before cleanup:

- `/private/tmp/padel-m08-local-final-backup` — ordinary executable's entire container.
- `/private/tmp/padel-m08-root-diagnostic-backup` — diagnostic app's container.

The three game files present were synthetic UI-test stores; no ordinary Session
repository was present. All three were restored, including the usage ledger in
their snapshots. SHA-256 verification is **3/3 identical**, recorded in
`game-data-manifest.json` and `restored-hashes.json`.

The temporary `com.dziachenka.padelscore` Watch app was removed. The ordinary
`com.dziachenka.padelscore.watchkitapp` was reinstalled from
`/private/tmp/padel-m08-normal/Build/Products/Debug-watchos/PadelScoreWatch.app`
and successfully launched via devicectl (exit 0), outside an Xcode StoreKit
launch. `normal-restored.png` records its screen. Sandbox purchase/restore was
not repeated after this cleanup; do not infer a fresh Sandbox pass from launch.
All cleanup/build/copy/install commands have logs/JSON and exit files here.

Final documentation checks: `make static` exit 0 (`final-static.log`), and
`./Scripts/project-status.sh validate` exit 0. These check repository consistency,
not StoreKit acceptance or release readiness. Simulator/desktop leases are released.

## Known issues

M08 is **BLOCKED**, not DONE or parked in REVIEW. The shipping-ID local harness
still addresses the wrong StoreKit namespace, and the physical OS loses injected
network-error detail even in an aligned host. The full current gate must pass
with no skipped required coverage before status can change. No OS beta update
was attempted; available disk space was approximately 11 GiB.

## Next step

Repair the local harness using a supported configuration that retains the shipping
bundle identity, or prove a separate local test-host arrangement exercises the
same production source and correctly clears the UI app's canonical namespace.
Keep shipping-ID Sandbox coverage distinct. Validate network injection on a
compatible hardware/toolchain environment; do not map unknown errors to offline
just to pass. Then repeat all four original physical scenarios and the complete
clean `make milestone ID=M08` gate. Do not submit anything for App Review.
