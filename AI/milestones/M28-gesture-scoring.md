# M28 — Gesture Scoring

**ID:** M28
**Status:** REVIEW
**Depends on:** M27
**Validation:** make milestone ID=M28
**Handoff:** AI/handoffs/M28-handoff.md

## Objective

Deliver the approved M28 outcome.

## Scope

Owner-approved [gesture plan](../gesture-differentiation-plan.md),2026-10-29.

Implement the approved gesture input, per-game opt-in/persistence, explicit schema5
migration, Watch practice and iPhone simulation in all thirteen app locales.

## Acceptance criteria

- [ ] Every new setup defaults OFF; toggles survive active-game restart/resume and fail atomically.
- [ ] One/two/three series select US/THEM/cancel, fixed3s, exactly one ordinary committed rally.
- [ ] Pending input is never persisted; touch/navigation/lifecycle/revision changes cancel it.
- [ ] Dedicated visible primary action exists only on playable active score; watchOS10 fallback works.
- [ ] Retry, Undo, all scoring boundaries, migrations1–4, isolation and usage are covered.
- [ ] All new copy is translated and inspected; actual Simulator flows and minimum/current OS pass.
- [ ] Full make milestone ID=M28 passes with exact handoff evidence. Physical checks belong to M29.

## Non-goals

No physical validation, store asset replacement, external reply/upload/submission or release approval.

## Validation

`make milestone ID=M28` on clean REVIEW/main, full suites, strict counts and no
waivers. Self-review, corrections, exact SHA/exits/reports/counts, compact handoff,
DONE commit and static/status/continuity checks; stop after this milestone.

## Development feedback scope

Mutable `make fast` may temporarily select all Watch unit tests and the complete
GestureScoringUITests class via FAST_TEST_ARGUMENTS. Restore Config/project.env
before committing. This is bounded development feedback; full unchanged milestone
validation still runs both complete platform suites with empty milestone filters.
