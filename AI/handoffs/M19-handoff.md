# M19 handoff — Companion Contrast Repair

**Policy status:** current

## Milestone

M19 — Companion Contrast Repair; status DONE.

## Summary

Fixed both native largest-text contrast failures with opaque semantic navigation
and tab surfaces, preserving the original segmented picker, layout and inactive
tab colors. Registered the approved M19–M26 recovery roadmap and product contracts;
only M19 is implemented in this Builder session.

## Changed files

- App/PadelScorePhone/PadelScorePhoneApp.swift — opaque native tab appearance in
  standard/scroll-edge states, existing secondary foreground in all item layouts.
- App/PadelScorePhone/PhoneDemoView.swift — opaque semantic navigation background.
- App/PadelScorePhoneUITests/CompanionUITests.swift — both existing largest-text
  tests additionally reveal/audit the lower score and ensure scrolling changes no score.
- AI/recovery-differentiation-plan.md, milestones/M19–M26, PRODUCT, ARCHITECTURE,
  DESIGN and PROJECT_STATUS — approved contracts, sequence and current evidence.
- AI/competitive-review-20261027.md and handoffs/ASC-review-20261027.md — preserved
  prior research and on-hold review draft; no App Review message sent.
- AI/evidence/M19 — reproduction, Builder self-review and full passing gate.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `227a1c43be1fc8cbfe12178683beaeb1308732d8`, clean REVIEW/main |
| Exact command | `make milestone ID=M19` |
| Exit code | 0; both Debug builds and all three native test commands succeeded |
| Timestamp | 2026-10-27T17:48:07Z–2026-10-27T20:15:45Z |
| Report | `.artifacts/milestone/M19/20261027T174806Z-55052/report.md`; retained copy with exact companion commands and native counts in `AI/evidence/M19/milestone-verification.md` |
| Counts | Watch510/510 definitions,884 invocations; phone unit14/14,20 invocations; phone UI6/6;0 failed/skipped/expected/runtime warnings |

Raw bundles, logs and all failed diagnosis experiments are retained. Final targeted
`bash .artifacts/M19/check-appearances.sh` exited0: light3/3 and dark3/3, zero
failed/skipped/expected/runtime warnings. Closing documentation validation records:
`.artifacts/M19/closing-checks.json` and `close-*.log` (`make static`, status validate,
continuity against the verified SHA). Optional configured-off SwiftLint, SwiftFormat
and ShellCheck are not claimed run.

## Tests

Both original failures reproduced on baseline
`fc9bf30a2913de8e253acae0c6331aa79504f2eb`, exit65. Native XCTest reported
unmapped `No element`; the record does not invent a particular offending glyph.
All original audit categories/assertions remain, and unknown issues still fail.
Added fully-visible lower-card audits caught the insufficient picker experiment,
which was removed. Visual self-review caught an inactive tab color regression;
the final native appearance preserves the existing semantic color. Actual runtime
light/dark, English/Spanish largest text and both demos with Undo/Reset passed.

Detailed commands, exits, screenshots and reasoning: `AI/evidence/M19/diagnosis.md`.
Builder self-review is not independent review or release approval. No scoring,
persistence, StoreKit policy, localization, version/build or verification-policy change.

## Known issues

No M19 blocking finding remains. The Watch bundle records one build warning in
Apple WatchSimulator27.0 SDK StoreKitTest's SKTestTransaction.h for deprecated
SKPaymentTransactionState; analyzer/test/runtime warnings are zero.

Apple's existing4.3(a) rejection remains unresolved; the reply/PDF remain unsent/on
hold. M19 does not establish release readiness or transfer M18 owner exceptions.
Final physical-device and six-domain release reassessment, including migration and
StoreKit, belongs to M25/M26; each implementation milestone retains its own tests.

## Next step

M20 — typed event journal, checkpoints, compatible persistence and retained archive
journals, as approved. This Builder session stops after the DONE commit and
static/status/continuity checks, per AI/WORKFLOW.md. M20–M26 remain PLANNED.
