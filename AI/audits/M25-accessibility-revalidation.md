# M25 digital domain revalidation — accessibility

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** Builder domain audit (interim digital scope)
**Milestone:** M25
**Domain prompt:** AI/prompts/audit-accessibility.md
**Candidate:** 4f1689944480aadfad592629e3c8394a9582c6b7
**Audited at:** 2026-10-30

Builder self-review, not independent audit or release approval. The approved
2026-10-29 workflow extension assigns all physical checks to M29; this is an
interim digital record, not a COMPLETE final release-domain record consumed by M26.
PENDING_DIGITAL means the named current-source run/readback is still required;
PENDING_M29 never means passed. Generic final coverage validators are unchanged.
Final candidate/commands/counts will be bound in the M25 handoff and verification
record; capture-source inputs are recorded in the material manifest.

**Coverage result:** DIGITAL_IN_PROGRESS
**Open P0/P1:** See findings; no unresolved product defect currently known.

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

Resolved current-iOS native Contrast and Text clipped findings on Start; raw failures retained. Removed a grouping wrapper that moved action identifiers to Other; native Button identity restored. No audit categories, helper or expected failures were removed. Final small/current centered regressions pass; full matrices remain pending.

Full failure/reproduction history: [work log](../evidence/M25/work-log.md).
Final-targeted native centered checks: [runtime](../evidence/M25/runtime.md).
All applicable physical scenarios: [M29 inventory](../evidence/M25/M29-hardware-inventory.md).
Internal-channel REL-1201–1203 do not apply to the configured app-store channel;
no internal installation is inferred from Simulator.

## Deferred P2 / future product ideas

None added. No cloud sync, tournament standings or real phone scoring is introduced.
No final readiness or actual hardware result is claimed.

## Targeted re-audit

Final affected/runtime/material re-audit follows completion of current runs.

## Validation

The exact unchanged `make milestone ID=M25` on clean REVIEW/main remains required.
No previous M28 component reuse/contrast waiver applies. This draft does not claim
that unstarted or failed checks passed.
