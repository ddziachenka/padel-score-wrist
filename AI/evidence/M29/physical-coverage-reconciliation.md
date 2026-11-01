# M29 — owner acceptance of manual physical coverage

**Record type:** evidence reconciliation; no milestone verdict or release approval.
**Date:** 2026-11-01.
**Initial inspected checkpoint:** `445859bde0740737ccd580ca0fb95dba429fb534`, with the
Builder's pending StoreMaterials UI timing correction preserved. This record
does not bind an unobserved Watch installation to that source SHA.

## Current scope — all manual M29 coverage accepted by decision

After the initial narrow reconciliation below, the Builder explicitly separated
the already accepted gesture/play checks from the remaining manual categories.
The full question and answer are recorded in the canonical
[owner acceptance decision](owner-physical-acceptance.md):

> Жесты и поведение в реальной игре я уже засчитал по твоему подтверждению, повторять их не прошу. Уточни только остальные отдельные пункты M29: VoiceOver, ввод имён и сохранение/восстановление данных, Sandbox-покупка/Restore/отзыв — что из этого ты тоже проверил? Они перечислены в AI/evidence/M25/M29-hardware-inventory.md; их результатов у меня пока нет.

The owner's exact answer:

> все засчитываем

The Builder accepts this clarified instruction as a **new M29-only owner
acceptance decision closing all manual physical coverage**, with outcome
**OWNER_ACCEPTED_BY_DECISION**. It includes the remaining VoiceOver, native-name,
storage/recovery and Sandbox purchase/Restore/revocation categories as well as
gesture/play behavior and the other manual physical inventory rows. The earlier
narrow interpretation is superseded as a statement of current acceptance scope.
No further repeat-test or manual-evidence request is required for those rows.

Acceptance by decision does not create measurements or artifacts. Exact per-team
attempt/success/miss denominators, measured percentages, elapsed hour, zero-event
counts and continuous real Watch video remain **not recorded/supplied**. Watch6
identity is not independently observed merely because this decision is accepted.
Those disclosures describe the evidence that exists; they are not renewed manual
coverage blockers under the clarified owner decision. Do not turn them into
invented numeric results, a claimed video file, or independent device readback.

This record documents scope; the Builder owns the corresponding milestone/plan
amendment and final-domain records. It changes no tests, parsers, scripts or Git.
The complete unchanged **`make milestone ID=M29` remains mandatory** with its exact
SHA, native counts, report and exit. No M25 or other historical exception is
inherited. This manual acceptance does not mark the milestone DONE, establish
release readiness, or authorize upload, publication, App Review reply/submission
or distribution. Later release/distribution scopes and their own authorization
requirements remain unchanged.

Current bookkeeping uses **OWNER_ACCEPTED_BY_DECISION** for manual outcomes and
**not recorded/supplied** for absent measurements/artifacts. Preserve every raw
earlier report and observation; distinguish manual acceptance from automated
verification and from independently observed device facts.

## Historical initial reconciliation — before the clarified scope

The following narrow interpretation and row mapping are retained as history.
Any wording here limiting acceptance to gestures/play or calling other manual
rows outstanding describes that earlier stage and is superseded by the current
all-manual decision above. The underlying facts and unrecorded details remain
valid disclosures, without a request to repeat the accepted manual work.

### Initial owner confirmation

The owner explicitly instructed:

> мы проверили жесты, также проверил как приложение ведет себя во время игры, поэтому засчитай это как за пройденные испытания на физическом устройстве.

Record the described **gesture tests and behavior during real play as
OWNER_ACCEPTED physical checks**. Do not demand repetition merely because earlier
notes say play was postponed. That earlier availability statement is superseded
by the owner's report that play has now been checked.

This is a first-party manual acceptance, not a Simulator inference. Earlier
feedback also specifically reports correct THEM scoring when the first series
shows Pending: US and the second series follows it. The owner found this stable,
but the required cadence was initially unclear; build6 addresses that teaching.

The confirmation does not contain attempt counts, a measured percentage, elapsed
duration, a count of accidental/wrong-team/duplicate points, a video attachment,
or a separate result for every physical inventory row. Those facts remain
**not recorded**. Acceptance must not be rewritten into invented measurements.

### Historical acceptance versus evidence detail

Use two separate fields where necessary:

- **Manual outcome:** OWNER_ACCEPTED for gestures and ordinary gameplay behavior.
- **Measurement detail:** not recorded for exact per-team denominators/percentages,
  duration and accidental/wrong-team counts; video not supplied.

At this historical stage, the initial instruction alone was not an explicit
blanket acceptance of VoiceOver, player-name entry, storage/recovery or Sandbox
purchase/revoke. It did not waive final six-domain records or the full automatic
gate, nor expressly rewrite the separate quantitative,
one-hour or continuous-video clauses in the current milestone/approved plan.
If a later owner-acceptance exception is used to close such clauses, it must be
identified with its actual approved scope; it cannot be described as collected
numeric/video evidence. This reconciliation changes no acceptance criterion.

### Historical physical inventory mapping

| Inventory scenario | Actual evidence now available | Boundaries / unrecorded detail |
| --- | --- | --- |
| Double Tap setup/system availability | Actual Ultra3/watchOS27.0.1; paired-phone Gestures/Tap Gestures On; owner native series produce US/THEM. | System setting says Left Wrist; actual worn/racket hand not reported. Unsupported-model behavior remains digital evidence. |
| One series / US | OWNER_ACCEPTED gesture feature; earlier owner explicitly confirmed two total finger contacts award US. | No actual attempts/successes/misses or zero-wrong-team count; no measured >=95% claim. |
| Two series / THEM | OWNER_ACCEPTED; owner specifically reports stable US-preview then second-series selection of THEM. | No numeric denominator/percentage; longer window and learned cadence were tried together, so their separate effects are not measured. |
| Third-series cancellation | Gesture feature accepted in general; physical phone simulation cancels after three activations. | Native Watch third-series outcome/count is not separately described. A phone simulation is not native gesture-recognition proof. |
| Ordinary recreational play | OWNER_ACCEPTED real-game behavior; owner says it was checked during play. | Duration, format/environment and accidental/wrong-team counts are not supplied. Do not label this a measured one-hour zero-event result. |
| Feedback/comfort | Owner reports stable use and identifies the recognition-cue usability issue. | Distinguishability of pending/save/Undo haptics and comfort of save latency are not separately reported. |
| Touch override/revision changes | Agent physically exercised phone Match/Americano/correction/Undo and simulated gesture cancellation/background. | Watch pending→touch override near deadline, Watch revision/menu/edit/Undo cancellation outcomes are not itemized. |
| Wrist down/Always On/lock/app switch | Agent reads actual Watch display/wake/return settings; owner accepts real-game behavior. | Settings are not an actual lowered-wrist/lock/competing-app cancellation trial. Exact outcomes remain unrecorded. |
| OFF defaults / current-game option | Current/minimum automated setup/route/relaunch coverage passes; owner used actual gesture feature. | All physical Match/Americano/known-score/Play-again defaults and restart/Undo option persistence are not separately reported. |
| Native player names | No current real-Watch entry/cancel/edit/Unicode/max-length/archived-roster trial is recorded. | Outside the owner's stated gesture/play acceptance; retain physical coverage as outstanding. |
| VoiceOver | Native Simulator accessibility audits pass; source label/hint work is tested. | No real VoiceOver order/focus/audio/announcements across required Watch/phone journeys is recorded. |
| Display/accessibility preferences | Physical phone Light/Dark, largest-text Match scoring/Undo and temporary transparency settings observed; originals restored. Watch Always On/Show Apps for Padel/Wrist Raise/70s are read On. | Largest-text Start traversal was explicitly not credited. Watch largest text/Reduce Motion/Crown/touch reachability and affected new guidance need their actual applicable evidence. |
| Storage/recovery | In-place phone updates and owner-approved test Watch reinstall are recorded. | Reinstall permission or a successful install is not backup/migration/failed-write/retry/cancel/restart/deletion-with-retained-rights validation. |
| Long-session performance | Ordinary gameplay behavior is OWNER_ACCEPTED. | No measured long-history/journal/repeated-correction performance observation or elapsed session duration is given. |
| Purchase/restore/revoke | Agent saw existing verified phone lifetime and successful existing-install Restore. | Sandbox environment was not shown. Fresh acquisition/cancel/pending/error/fresh-install restore/refund/offline/currency cases on both platforms remain outside that one restore observation. |
| Independence/installation | Local signed phone installation and paired-phone Watch installation are evidenced. | No explicit Watch-without-phone result is given. Later authorized distribution-channel work belongs to its owning release/submission scope; no TestFlight/App Store installation is inferred. |
| Rating/external legal | Agent opened actual phone Support/Privacy/Terms destinations and found usable content. | Physical Watch destinations and qualifying/no-prompt rating behavior are not separately reported. |
| Continuous Watch video | No factual Watch+hand continuous video is supplied in current records. | Simulator recordings/artwork/manual prose cannot be relabelled as that artifact. |

### Build identity and source continuity disclosures

Phone1.0(6) is independently read back. The owner's last separately enumerated
Watch About confirmation in the existing record is 1.0(4); later qualitative
feedback follows delivery of the five-second prototype, without a separate About5
or About6 response. Build6 changes teaching/build identity only; its reducer is
recorded as identical to build5. Preserve the owner's actual observations and
their affected-source scope rather than silently relabelling them as Watch6.

The earlier physical phone demo, correction, known-score, restore and legal
observations are useful scoped evidence. The relevant behavior/source continuity
must be recorded when carrying them forward; the new gesture timing/teaching
needs its own affected evidence. An all-App hash difference does not by itself
turn an observed unchanged demo into an unperformed test, but it also cannot prove
new physical behavior that was never observed.

### Historical recommendations before clarified acceptance

1. Add the exact owner statement and OWNER_ACCEPTED gesture/play outcome to the
   current physical record/status/handoff; remove unqualified wording that no
   real play has been checked.
2. Preserve measurement/video fields as unrecorded, without converting them to
   failed user trials or fabricated passing counts. Do not ask for repeat work
   just to reproduce an already accepted qualitative observation.
3. Keep unrelated physical rows and final automatic verification distinct from
   that acceptance. If broader acceptance is intended later, record its explicit
   scope, leaving all raw test results and unknown facts intact.
4. The full unchanged `make milestone ID=M29`, exact-SHA evidence and final
   six-domain records are still required before DONE; none ran as part of this
   read-only reconciliation.

Sources: [M29 contract](../../milestones/M29-physical-device-validation.md),
[approved plan](../../gesture-differentiation-plan.md),
[physical inventory](../M25/M29-hardware-inventory.md),
[physical observations](physical-validation.md),
[prototype/current-build evidence](five-second-prototype.md), and
[read-only Watch settings](watch-activity-settings.md).
