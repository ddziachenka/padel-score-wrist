# M17 exact candidate verification

Clean REVIEW candidate `02ec9c97b1c6e1d2c1c58aec64f990ed76399f77`; unchanged `make milestone ID=M17`.
Raw result FAILED: Make2/verifier1/iPhone UI xcodebuild65. Full Watch510/510
definitions,884 invocations; phone unit/StoreKit14/14,20 invocations; phone UI6/6
executed,4 passed/2 native Contrast failed. Zero skipped/expected/runtime warnings.
Only the two exact owner-accepted contrast cases failed; no new failure remains.

Report: `.artifacts/milestone/M17/20261024T210958Z-41758/report.md`. Bundles: `milestone.xcresult`,
`companion/unit.xcresult`, `companion/ui.xcresult`. Native summaries:
`.artifacts/M17/final-{watch,phone-unit,phone-ui}-summary.json`.
Console: `.artifacts/M17/milestone-corrected-clean.log`.
All original assertions and complete platform suites ran; no retry-to-pass.
Owner disposition: OWNER_ACCEPTED_FOR_SUBMISSION after separate M18 readiness;
M17 DONE under bounded acceptance, not an automated pass or READY_FOR_HUMAN.

The first full candidate exposed a native optional review prompt. The correction
and fail-before/pass-after evidence are in review-prompt-regression.md. Only UI
setup changed; production behavior is unchanged. A same-candidate early packaging
attempt found an injected stale Watch XCTest bundle; owned cache cleaned via
make clean-derived-data, exit0. Strict guard retained, whole gate rebuilt unchanged.
All attempts remain in .artifacts/M17/ and .artifacts/milestone/M17/.

Signed new distribution export source is this candidate, IPA SHA256
820e0ab32614f429225b67ab78ce614f23f7a65a4db77a1b0ca48cc24d823e0d.
Archive/export/actual package/signature and Apple altool validation all exit0;
.artifacts/asc-companion-20261024/export-02ec9c9/PROVENANCE.md. iPhone executable,
independent Watch companion and launcher1.0(2), no distribution test components.
No new binary upload, selection or submission claimed by M17.

ASO14 locales and42 records read back exactly,56 native phone+84 Watch+28 creative
placements verified. Neutral feature-only promo saved; ASO decisions and full copy
in AI/launch-20261024/companion-aso-final.md. Old app-only draft item was removed
through normal ASC UI to unlock editing, IAP retained. App is PREPARE_FOR_SUBMISSION;
new build must be selected and app re-added for ordinary joint submission. Owner
internal TestFlight group prepared,1 existing owner tester,0 builds; no TestFlight
pass yet. Agreement/bank Active, all175 regions. Publication clock not started.

## Exact bundle timestamps and counts

| Platform | Definitions | Invocations | Passed | Failed | skipped / expected / warnings | UTC |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| watch | 510 | 884 | 510 | 0 | 0 / 0 / 0 | 2026-10-24T21:10:31.134000+00:00–2026-10-24T23:28:29.540000+00:00 |
| phone-unit | 14 | 20 | 14 | 0 | 0 / 0 / 0 | 2026-10-24T23:28:55.019000+00:00–2026-10-24T23:29:00.913000+00:00 |
| phone-ui | 6 | 6 | 4 | 2 | 0 / 0 / 0 | 2026-10-24T23:29:02.189000+00:00–2026-10-24T23:43:53.026000+00:00 |
