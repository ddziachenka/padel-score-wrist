# M08 local StoreKit host repair

**Policy status:** current

## Milestone

M08 — Access and Purchase; REVIEW is transient during this session's complete
gate and remaining hardware verification. Nothing is submitted for App Review.

## Summary

A dedicated local host aligns SKTestSession with the canonical container bundle
ID while the shipping Watch executable retains `.watchkitapp`. The host compiles
production files, except for a minimal test `@main` that makes no early StoreKit
calls. All four original StoreKit test bodies/assertions are preserved; setup
additionally rejects any unverified, non-Xcode or mismatched app identity before
purchase. Unit/policy and UI tests still run the shipping executable.

## Changed files

- Xcode project/scheme/plan: test-only host and serial StoreKit test target.
- `App/PadelScoreStoreKitTests/StoreKitPurchaseTests.swift`: moved original four
  scenarios, awaited/strengthened environment guard, same deterministic GameID helper.
- `App/PadelScoreStoreKitHost/StoreKitTestApp.swift`: inert test entry point.
- `Scripts/verify-storekit-host.py`: mandatory build guard for production-source,
  resource/settings parity, permitted entry-point substitution and archive exclusion.
- Architecture and M08 workflow records describe this test arrangement.
- No production application source, purchase behavior, UI or business rule changed.

## Validation

Starting SHA: `54e27eea188c6617a7fe44bd9b888830809c3bd8`, clean main.
Evidence: `.artifacts/M08-local-repair/`; each xcodebuild log contains the exact
command, with `.exit` and `.xcresult` beside it. Xcode 27.0 (27A266a); managed
Watch SE2 40mm / watchOS 26.1; physical Ultra3 / watchOS 27.0.1.

- `named-config`: original four tests fail; documented filename initialization
  and app-bundled StoreKit file do not fix the namespace mismatch. Probe removed.
- `isolated-host`: exit 0, 7/7 passed (four StoreKit + three shipping access UI),
  zero failures/skips.
- `host-guard`, `guarded-isolation`: each exit 0, 4/4 StoreKit passed, zero skips.
  The latter includes inert entry point and verified Xcode-environment guard.
- Validator negative checks reject production source drift and archive inclusion.
- `hardware-host`: local namespace fixed, but Watch currentEntitlements remains
  empty after switching from Sandbox; network error still generic.
- `hardware-isolated-start`: build rejected by parity guard due to a wrong source
  reference; corrected rather than bypassing the guard.
- `hardware-isolated-start-v2`: guarded inert host still reproduces hardware failures.
- `rich-error`: wrong generated manifest filename, no tests; corrected next run.
- `rich-error-run`: diagnostic reached existing Sandbox ownership, not Xcode;
  **not coverage**. This prompted the explicit environment guard now in every test.
- Complete clean `make milestone ID=M08`: pending in this session.

## Tests

Self-review checks that shipping sources are unchanged, original scenario bodies
match byte-for-byte after accounting for `await environment()`, and that only
local targets compile the moved test. Build guard checks the real project graph
and fails on drift. New targets are excluded from run/profile/analyze/archive.
No skipped check, mocked purchase, private API, unknown-as-offline mapping or
transaction-history fallback is accepted as a pass. Not an independent audit.

## Known issues

Required physical local StoreKit coverage and the complete current-SHA gate are
not yet passing. Device restart requested to clear the stale entitlement cache;
checking a supported Device Support refresh for the remaining error transport.
No beta OS update or App Store submission is authorized/performed.

## Next step

Complete the full gate and physical four-test matrix in this session; record
exact candidate SHA, commands, exit codes and counts before deciding DONE.
Restore the ordinary device state after tests, preserving game data.
