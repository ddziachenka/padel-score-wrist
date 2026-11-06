# M32 — Next serve side

**ID:** M32
**Status:** IN_PROGRESS
**Depends on:** M30
**Validation:** make milestone ID=M32
**Handoff:** AI/handoffs/M32-handoff.md

## Objective

Show the next serving side beside the server in Match and Americano. Owner
approved the implementation plan on 2026-11-06 and personally withdrew build 7.

## Scope

Pure derived domain value, Watch live/demo and recovery previews, iPhone demo and
recovery previews, localized explanations and VoiceOver, bundled help, regression
tests and Simulator inspection. No persisted side or schema migration.
The strict static source-to-capture guard also requires fresh local gallery captures
and import before this gate; M33 retains release/editorial readiness and submission
material preparation. No source fingerprint is relabeled without fresh captures.

## Non-goals

No new scoring format, receiver selection, side toggle, court-end tracking, archive
change, upload or resubmission. M33 owns fresh release readiness and store materials.

## Acceptance criteria

- [ ] Match regular points alternate from R; deuce R, advantage L, deciding point
      L/R with receivers' choice. Tie-break uses total-point parity.
- [ ] Americano begins every server's block at R, using rallyInBlock after edits;
      arbitrary block lengths and shortened final blocks work.
- [ ] Ended games and unconfirmed set service show no side. Undo, correction,
      selective replay, known-score start, restart, resume and failed saves stay exact.
- [ ] Watch, demos and recovery previews agree. Long names, compact Watch, largest
      text, Always On and phone light/dark retain readable score and controls.
- [ ] All thirteen app locales include full side/choice/help text; L/R stays literal.
      VoiceOver reads the side in full. No extra interaction is required.
- [ ] Full make milestone ID=M32 passes on clean REVIEW/main; handoff records exact
      SHA, command, exits, counts and reports. Closing static/status/continuity pass.

## Validation

Use targeted mutable development tests before the complete two-platform gate.
No M31/M26/M30 affected-only waiver is inherited. Simulator proves this static
derived display; fresh physical VoiceOver/readability acceptance belongs to M33
before release readiness, not beyond it. No new haptics or gesture behavior.

## Builder review

Self-review the entire baseline-to-candidate diff and inspect actual Simulator
screens. This is not an independent audit or App Store approval.
