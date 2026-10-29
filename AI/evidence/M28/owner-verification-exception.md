# M28 owner-approved verification exception

**Policy status:** current — M28 only.

## Authorization

On2026-10-30 Tbilisi (2026-10-29 UTC), the owner asked whether M28 could finish
faster. The proposal explicitly named reuse of the619 passing Watch checks only
while their inputs remain unchanged, complete new iPhone verification, static
checks, and a recorded exception before DONE. The owner selected:

> Да, разовое исключение для M28 — примерно 1–2 часа (Recommended)

This overrides the ordinary full-command prerequisite in AGENTS A6/A12 and the
Builder verification sequence **for M28 only**. It does not waive a failed test,
change a test/parser, authorize release, or extend to another milestone. M26 still
requires its complete milestone gate and exact-SHA `make release`.

## Accepted verification

1. Commit the final implementation and tests in clean REVIEW/main.
2. Compare the full tracked tree with
   `3db256e040e4306477d63f2e75b0223561c1e240`. Only Markdown under AI/ and the two
   changed iPhone files may differ: `App/PadelScorePhone/PhoneGestureView.swift`
   and `App/PadelScorePhoneUITests/CompanionUITests.swift`. Every other path,
   mode and Git blob must match. Record the protected manifest and digest; fail
   closed on any additional changed input.
3. Reuse that candidate's **Watch component only**:619/619 definitions,
   1057/1057 invocations, zero failures/skips/expected failures. Its complete
   `make milestone ID=M28` report remains FAILED because the phone UI failed;
   it is never relabelled as a full pass.
4. Run unchanged `make static` and the unchanged repository
   `verify_companion_profile milestone` implementation on the new SHA: Debug
   build/independent packaging guards, complete phone unit and UI schemes,
   original strict native counts, no narrowed filters or skipped tests.
5. Run the affected current-iOS Simulator supplement and retain the already
   passing minimum/current Watch supplements with input continuity.
6. Confirm the exact candidate is still clean, self-review, write the compact
   handoff, and record DONE **under this owner exception** only after all new
   checks pass. After the continuity-only DONE commit, run static, status
   validation and `continuity <verified-full-SHA>`, then stop.

The new command is `bash .artifacts/M28/verify-phone-complete.sh`. Its report
explicitly describes complete iPhone verification and reused Watch evidence,
not a newly passing full milestone command. The final handoff records the exact
SHA, invocation, UTC timestamps, exits, native counts and artifact paths.

## Preserved evidence and limits

Original full report:
`.artifacts/milestone/M28/20261029T151440Z-2914/report.md`.
Watch bundle: the same directory's `milestone.xcresult`.
Exported summary/tree: `.artifacts/M28/failed-gate-watch-{summary,tests}.json`.
Mutable/failed phone work remains in [development.md](development.md).

All physical Watch/iPhone checks remain mandatory in M29, including real gesture
recognition and haptics. This exception is not independent review, release
readiness, App Store acceptance or submission authorization.
