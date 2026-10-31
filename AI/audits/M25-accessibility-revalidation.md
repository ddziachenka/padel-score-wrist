# M25 digital domain revalidation — accessibility

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-accessibility.md
**Candidate:** f097a52d6a1154cf431156c30a81013a34d3cd47
**Audited at:** 2026-10-31

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is an
interim digital record, not a COMPLETE final release-domain record consumed by M26.
PENDING_DIGITAL means the named current-source run/readback is still required;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Final candidate/commands/counts will be bound in the M25 handoff and verification
record; capture-source inputs are recorded in the material manifest.

**Coverage result:** DIGITAL_IN_PROGRESS
**Open P0/P1:** None currently identified in reviewed source. C1/C2 are corrected; f097 minimum/current Watch and complete current-phone20 pass. Both new gallery4 bundles, strict provenance/site checks and all42 visual reviews pass. The exact full milestone gate remains mandatory before DONE.

## Coverage

- REL-601 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Native labels/traits/announcements and full XCTest accessibility audits are digital evidence only. Actual VoiceOver traversal of every journey is PENDING_M29.
- REL-602 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Watch LargeText/Journal/KnownScore/PlayerNames/Gesture matrices and phone recovery/gesture13locale Light/Dark maximum-size matrices, plus centered EN/DE/RU regression.
- REL-603 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Source/DesignSystem checks preserve information without animation. Actual assistive-display preference and haptic behavior remain M29.
- REL-604 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Original native contrast categories retained on both supported phone themes and Watch dark surface; Start findings corrected with measured opaque semantic labels.
- REL-605 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Native hit-region audits and explicit44pt centered controls; Watch scrolling/reflow tests preserve tap reachability.
- REL-606 | OUTCOME=PENDING_DIGITAL | EVIDENCE=Labels, numbers, disabled states, Pending team text, score/service/Undo announcements carry meaning independently of lime.
- REL-1306 | OUTCOME=PENDING_DIGITAL | EVIDENCE=PlayerNames native UI/model/real-file tests and archived roster immutability; actual dictation/Scribble/VoiceOver belongs to M29.
- REL-1308 | OUTCOME=PENDING_M29 | EVIDENCE=PENDING_M29: at least95% each-team success, zero wrong-team/accidental points in one-hour actual supported-Watch play, exact attempts and real video.

## Findings and fixes

Resolved current-iOS native Contrast and Text clipped findings on Start; raw failures retained. Removed a grouping wrapper that moved action identifiers to Other; native Button identity restored. No audit categories, helper or expected failures were removed. Final small/current centered regressions and standard Help reachability pass. Selection-bound tab accessibility repairs the retained minimum-iOS navigation AX frame; the native xmark dismissal with localized Close label passes both German-largest/Light/Dark cases. Both earlier67f current-phone locale/theme/largest matrices pass within UI19/19; new f097 current UI20 passes, and the configured-floor full milestone gate remains pending.

Full failure/reproduction history: [work log](../evidence/M25/work-log.md).
Final-targeted native centered checks: [runtime](../evidence/M25/runtime.md).
All applicable physical scenarios: [M29 inventory](../evidence/M25/M29-hardware-inventory.md).
Internal-channel REL-1201–1203 do not apply to the configured app-store channel;
no internal installation is inferred from Simulator.

## Deferred P2 / future product ideas

None added. No cloud sync, tournament standings or real phone scoring is introduced.
No final readiness or actual hardware result is claimed.

## Targeted re-audit

Frozen f097 fresh minimum-phone4/4, minimum-Watch492/492 definitions/942
invocations, current-Watch498/498/948 and complete current-phone20/20 pass,
exit0, all zero failed/skipped/expected/native runtime-warning counts. This
includes26 language/theme pairs each for gesture/reset, maximum-text Help and
both recovery journeys, actual eight-surface theme pixels and centered EN/DE/RU.
The strict accepted native summaries/leaf counts are in runtime.md and
native-supplements.json. Both gallery4 bundles, strict material/site checks and all42 final visual contact
reviews pass. The unchanged full milestone gate remains required. The additional baseline-matched current StoreKit
probe stays FAILED/P2; storekit-current-runtime.md records the exact boundaries.
Physical evidence remains PENDING_M29.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
