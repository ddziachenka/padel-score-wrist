# M08 local StoreKit environment investigation

**Policy status:** current

## Milestone

M08 — Access and Purchase. REVIEW is transient for a fresh complete simulator
gate; required physical-Watch local StoreKit coverage is not yet complete.
Nothing was submitted or uploaded for App Review.

## Summary

The real Sandbox purchase/restore pass in M08-sandbox-identity-handoff.md remains
valid. This session isolates a different local-testing failure. A diagnostic
SKTestSession creates an Xcode transaction for the executable `.watchkitapp`,
but the physical Watch's public AppTransaction identifies the container
`com.dziachenka.padelscore`. After UI activation, the app uses Xcode, but cannot
see the session's purchase in currentEntitlements. Configuring the actual ASC
app/team IDs and preventing the test host scene's early StoreKit calls did not
fix it. Temporary private namespace probes were diagnostic only and rejected by
the test service; none remain in source or shipping code.

A separately installed diagnostic host using the container ID makes all three
identities agree. Dialog suppression and product currency control then work,
and Transaction.latest returns the local purchase, but currentEntitlements is
still empty. The original purchase/restore/refund test fails three assertions
(ownership, fresh owner ownership, restored message). No assertion was removed,
relaxed, skipped or replaced by transaction-history access.

## Changed files

The existing Xcode scheme-format rewrite was committed unchanged as c05a717
(SHA256 6b19770fb56b152ab94d13891606f8b5118b82e9f040509498517eec948dd3c8),
removing the dirty-checkout obstacle without reverting the owner's work.
All temporary project, app, configuration and diagnostic-test edits were restored.
Only workflow records differ beyond that preserved scheme update.

## Validation

Base SHA: 97d949e76ac132f23e3feaab256bf67f1de528b2.
Environment: Xcode 27.0 (27A266a), Watch Ultra 3 / watchOS 27.0.1 (24R365),
UDID 00008310-000823642660E01E; 2026-10-21 UTC / 2026-10-22 Asia/Tbilisi.
Evidence directory: `.artifacts/M08-local-session/`. Logs record exact xcodebuild
commands; each run has an exit file and xcresult. Diagnostic sources and original
files are retained in that ignored directory. Initial binding probe passed its
count assertion only because it saw the existing Sandbox purchase; that is NOT
a local StoreKit coverage pass. Subsequent probes require Xcode environment.

- activate: UI About test, exit 0, 1 passed / 0 failed / 0 skipped.
- binding-after-ui, binding-app-id, binding-parent, parent-configured,
  isolated-host, app-transaction, root-host, root-diagnostic:
  each exit 65, 0 passed / 1 failed / 0 skipped; no test matrix pass.
- binding: diagnostic compile error, exit 65, no tests; corrected in binding2.
- Fresh full `make milestone ID=M08`: pending in this session.

## Tests

Self-review: production purchase code and all four original StoreKit tests are
byte-identical to the starting commit. No independent review or release approval
is claimed. The identity comparison narrows the fault; it is not a substitute
for original hardware acceptance tests. A Watch restart was requested to rule
out stale system StoreKit state while full simulator verification proceeds.

## Known issues

M08 cannot become DONE until the remaining physical-Watch matrix passes.
The temporary root-ID diagnostic app must be removed after preserving any data;
the ordinary corrected-ID app must be restored after local tests. The device
has not been upgraded and no account credentials have been changed.

## Next step

Finish the clean milestone gate, retest local StoreKit after Watch restart, and
record exact final evidence/status. Do not submit to App Review.
