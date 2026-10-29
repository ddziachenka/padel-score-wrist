# M27 — Player Names

**ID:** M27
**Status:** REVIEW
**Depends on:** M24
**Validation:** make milestone ID=M27
**Handoff:** AI/handoffs/M27-handoff.md

## Objective

Optional personal names for the partner and two opponents throughout real Watch games.

Owner approved the complete implementation plan in chat on 2026-10-29.

## Scope

Watch Players editor in setup and active games; per-game names, remembered roster,
all serving/correction/journal/result/VoiceOver surfaces; schema 4 migration from
1–3; all thirteen locales; tests and runtime validation.

## Non-goals

No editable You, player profiles, contacts, archived-game editing, phone roster
management/synchronization, purchase restriction, upload or App Review submission.

## Acceptance criteria

- [ ] Both formats support optional names before/during play, native input, save/cancel,
      whitespace cleanup and localized role fallback; duplicate names retain role context.
- [ ] Last saved roster is proposed next time; Play again copies its game's roster;
      cancelling setup changes no persisted settings. Each archived result keeps its roster.
- [ ] All real serving, correction, journal, result and VoiceOver surfaces use game-local
      names; demos keep roles. Long names and largest text preserve usable controls.
- [ ] Rename saves atomically/revision-bound, supports retry/cancel, survives background
      drafts, creates no Undo/journal event and changes no score/usage. Undo retains names.
- [ ] Schema 1–3 migrate explicitly to schema 4 without loss; backup/restart/delete
      and failed writes are covered by regression tests.
- [ ] New copy ships in all thirteen locales. Small-watch/minimum OS/current OS,
      large text and native audits have Simulator runtime evidence. All physical-Watch
      checks, including native input and VoiceOver, belong to M25 before release
      preparation, by explicit owner direction on 2026-10-29.
- [ ] make fast and full make milestone ID=M27 pass; exact SHA/exits/counts/reports
      are recorded in the handoff. Static/status/continuity close the DONE commit.

## Validation

`make milestone ID=M27` on clean REVIEW/main HEAD, both complete platforms,
without skipped mandatory checks. Builder self-review is not independent approval.

## Owner validation direction — 2026-10-29

“давай все проверки на физических часах сделаем перед подготовкой к релизу”

All physical-Watch checks are owned by M25, before M26 release preparation. This
is not a hardware pass or a release waiver. M27 still runs its full automated gate
and Simulator runtime checks. Failed physical connection attempts remain evidence
of an unexecuted test, not product failures or successful hardware coverage.

## Development feedback scope

The permitted mutable `make fast` loop runs all Watch unit tests plus the five new
PlayerNamesUITests using temporary FAST_TEST_ARGUMENTS:
`-only-testing:PadelScoreWatchTests -only-testing:PadelScoreWatchUITests/PlayerNamesUITests`.
The original Config/project.env is restored before committing the candidate. This
selects relevant development feedback; `make milestone ID=M27` still runs both
complete platform suites with empty MILESTONE_TEST_ARGUMENTS and strict counts.
