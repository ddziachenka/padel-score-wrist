# M16 — proposed tooling regression run

**Status:** proposal only; not executed.

The unmodified baseline feed3ea7ceb1f5c2ce08075b434dbca4ed9a718f failed direct `make self-test`: 97 cases,1868 checks passed,262 failed, Make2/script65. M16 development run with per-case template fixtures finished98 cases,2116 passed,27 failed (Make2/script65, `.artifacts/M16/self-test-fixture-fixed-full.log`). The remaining cases include whole-root English-template prose scans that read the real Russian product contracts and a generic scan forbidding mention of the hosted beta channel in any tracked file, including immutable historical product evidence. These failures must not be converted to passes or removed from the evidence.

M00 already documented a separate reconstruction in `AI/handoffs/M00-handoff.md`, lines79 onward. Its temporary commit object is unavailable locally; the original template input bc0ccd55b9893d2ee863f8d85e29f339e465a937 is available.

## Concrete proposed next action

1. Create one disposable source fixture under `/private/tmp/iosai-m16-tooling-*` from that exact original template commit, as M00 did.
2. Overlay the current candidate's Scripts directory, Makefile, gitignore, config schema and release requirements. Preserve every current assertion and all companion checks. Generate the generic template-mode profile. Remove only the original product brief handoff from this temporary fixture (the same input correction recorded by M00).
3. Record the fixture commit, tree and SHA256 manifest, and prove every current tooling source byte matches the M16 candidate. Do not edit or remove any product contract, historical audit, handoff or application file in the primary checkout. Do not introduce a wrapper or change the invocation logic of self-test.
4. Run the exact command `make self-test` inside that fixture, preserving the full result, counts and exit code. Any remaining failure still blocks completion.
5. Independently run product `make static`, `make site-check` and the exact clean-REVIEW `make milestone ID=M16` in the primary checkout. The temporary tooling fixture cannot substitute for any actual Watch/iOS suite, StoreKit scenario or physical-device evidence.

## Automatic approval review

A combined command proposing an automatic self-test wrapper and removal of newly added English policy prose was rejected before execution because it substantially rewrote self-test and could weaken mandatory verification. Neither change executed. This revised proposal retains the current invocation and every check, and requests a bounded temporary fixture using the already documented M00 procedure. No approval of an application release or a failed test is requested.
