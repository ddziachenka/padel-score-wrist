# M28 — Gesture Scoring

**ID:** M28
**Status:** REVIEW
**Depends on:** M27
**Validation:** Owner-approved M28 component verification; see AI/evidence/M28/owner-verification-exception.md
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
- [ ] Owner-approved M28 verification passes: identical Watch inputs/reused complete result, complete new iPhone suites, static/runtime/continuity and exact handoff evidence. Physical checks belong to M29.

## Non-goals

No physical validation, store asset replacement, external reply/upload/submission or release approval.

## Validation

The original `make milestone ID=M28` report remains FAILED. The owner explicitly
approved the narrow [M28 exception](../evidence/M28/owner-verification-exception.md):
unchanged complete Watch inputs/results may be reused; complete new iPhone suites,
static, runtime, clean exact SHA and continuity checks remain required. No test or
count parser is changed. Record the exception in the handoff and stop after DONE.
M26 retains the full milestone/release commands.

## Development feedback scope

Mutable `make fast` may temporarily select all Watch unit tests and the complete
GestureScoringUITests class via FAST_TEST_ARGUMENTS. Restore Config/project.env
before committing. This is bounded development feedback; full unchanged milestone
configuration retains empty milestone filters. M28's final verification follows
the later owner exception above; other milestones retain their full gates.
