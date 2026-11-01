# M29 — explicit owner acceptance of the manual physical scope

**Date:** 2026-11-01.
**Scope:** M29 manual physical-device acceptance only.
**Decision outcome:** OWNER_ACCEPTED_BY_DECISION.
**Not:** measured recognition statistics, supplied physical video, an independent
audit, a full automated-gate pass, or release/submission approval.

## Exact owner instructions

The owner first stated:

> мы проверили жесты, также проверил как приложение ведет себя во время игры, поэтому засчитай это как за пройденные испытания на физическом устройстве.

The Builder credited gestures and real-game behavior, then asked the remaining
scope question exactly:

> Жесты и поведение в реальной игре я уже засчитал по твоему подтверждению, повторять их не прошу. Уточни только остальные отдельные пункты M29: VoiceOver, ввод имён и сохранение/восстановление данных, Sandbox-покупка/Restore/отзыв — что из этого ты тоже проверил? Они перечислены в AI/evidence/M25/M29-hardware-inventory.md; их результатов у меня пока нет.

The owner answered:

> все засчитываем

This explicit follow-up accepts the entire manual physical part of M29, including
the separately enumerated remaining device scenarios. The Builder uses owner
acceptance in lieu of gathering further manual evidence or requesting repetition.
The owning M29 contract/approved plan/workflow record this narrow exception.

## What is accepted and what is actually known

All manual physical inventory rows are closed for M29 by owner decision. This is
not a claim that each individual interaction was independently observed or that
all originally requested measurement/media artifacts exist. In particular:

- Exact per-team attempts, successes/misses, recognition percentages, accidental/
  wrong-team/duplicate counts and elapsed play duration were **not recorded**.
- A continuous real Watch+hand video was **not supplied**. No simulator recording
  or generated artwork is substituted for it.
- The owner qualitatively reports stable THEM selection after Pending: US appears
  and a second series follows; that cadence was initially unclear. Longer timing
  and learned cadence were tested together, not causally separated.
- Phone1.0(6) was independently read back. Watch6 About was **not independently
  read back**; the last separately enumerated owner About confirmation was4,
  followed by qualitative trials after the five-second prototype was delivered.
- Native VoiceOver audio, player-input/recovery, fresh Sandbox state/transactions
  and the other previously missing rows are accepted by decision, not relabelled
  as newly collected agent observations.

Therefore the original >=95%/one-hour-zero-event/video evidence clauses are
superseded for this M29 manual acceptance, **not represented as measured passes**.
The same treatment applies to unobserved details of the other manual rows. The
full [reconciliation](physical-coverage-reconciliation.md) retains the historical
observations and their boundaries.

## Candidate and limits

Current shipping behavior is build1.0(6), source
`ff87edd550f376b618d44ebb7904ef29f769b686`: fixed five-second reducer, clear
second-series cue, original cancellation/Undo/data boundaries. Later gallery-test
changes do not change shipping bytes. This acceptance covers the current M29
manual scope; later affected product changes require revalidation under the normal
workflow. Original raw failures and prior reports remain intact.

The entire unchanged `make milestone ID=M29` remains mandatory on clean REVIEW/
main, with all strict suites/counts/package/source guards, six final domain records
and exact-SHA evidence. No automated test is removed, skipped, loosened or reused
under the M25/M28 owner exceptions. Materials stay local drafts until separately
authorized distribution work. This decision does not authorize App Review reply,
upload, publication, TestFlight/distribution or submission, and does not waive M26's
full milestone/release gates. No further physical-device actions are requested for
this accepted M29 manual part; disconnecting the devices does not block the
remaining simulator/material/automatic verification work.
