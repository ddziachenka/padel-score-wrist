# M27 Builder self-review

This is Builder self-review, not independent review or release approval.
Baseline: `6af2a23aff82bca6df20fe80d58ffdc7c949a4ac`.

## Correctness, ownership and persistence

Player identity/team/service order remain enums. Optional names live outside score
snapshots, in current/archive/recent metadata; all scoring changes copy the record.
Rename uses the ordinary revision/command-ID/atomic-save path, increments revision,
adds no rally/checkpoint/history/usage event, and cannot edit a finished or archived
game. Score Undo preserves names. Archive publication copies the same record's
roster; reading old results never consults recent settings. Play again uses its
own record, both normal and known-score starts pass the chosen roster.

The editor keeps unnormalized text in a private in-memory draft; whitespace is
normalized only on confirmation so typing a surname separator is safe. Cancel/Back
publish nothing, setup cancellation persists nothing, the live route survives
background, and failed writes retain saved values and retry the same request.
Stale revisions are refused instead of retargeting another game. Cold launch reads
only saved state. Failed-request cancellation checks ownership before discarding.

Schema 4 explicitly migrates versions 1–3 to empty names; journals/history/usage and
notices survive. Required current roster objects never silently default away.
Frozen old fixtures remain unchanged; schema-4 encoding has its own frozen fixture.
Future-version tests now use current+1, retaining their protection. Self-review
added an explicit frozen-schema-3 missing-journal regression alongside the current
schema checks, preserving the old strict decoder assertions after changing writer
version. Named restart/backup/failure/retry/deletion tests exercise the real files.

## User experience and accessibility

Players is optional in setup and the active menu. Setup summarizes the remembered
roster, with no new required setup field. The native scrolling editor has persistent
role labels, three native text inputs, Save and Cancel, normal save-wait feedback,
precise name-save errors and accessibility announcements after confirmation.
Selection/order/result rows retain role context for duplicate names. Custom text
is literal; only role fallback and surrounding copy are localized. The compact
serving block preserves its existing two-line layout/full accessible text.

Runtime development checks verified native input, background/cancel/clear, service,
Undo, finish, archived metadata and Play again. Native editor accessibility audits
passed; thirteen locales at the largest text size passed. The observed result-row
identifier inheritance was fixed at the heading, preserving per-role IDs. Large
system navigation titles are asserted through their actual bar identity. No
assertion/category was removed to make an audit pass. Final-source compatibility
and complete candidate evidence are recorded separately in runtime/verification.

This is a small native form; bespoke assets, animation or new haptic machinery do
not improve the task. The existing native typography, row/button styles, save
feedback and scoreboard transition are retained. No performance problem was
observed; adding metadata does not replay or copy rally history.

## Scope, privacy and handoff

You, teams, rules, scoring engines, purchase policy and demos keep their behavior.
No profiles, contacts, backend, phone synchronization, archived rename, dependency,
permission, analytics or external service was added. New copy is translated in all
thirteen shipped locales. M25 owns all physical-Watch checks by the owner's latest
explicit direction; no failed connection is represented as a hardware pass.

M27 precedes M25/M26, and this Builder stops after M27. The full milestone gate
retains both platform suites and strict parser counts. Development failures remain
raw failed evidence; the owned cache cleanup preserves all reports and guards.

## Minimum-OS and visual corrections

The actual watchOS10 hierarchy exposed the role ID on a wrapper around the native
TextField. Tests now resolve that exact role's editable field across both shapes,
assert a single child where wrapped, and preserve all input/value/persistence
assertions. A focused native-input/start/relaunch check passed before the complete
rerun. The optional explanation was moved below fields after maximum-text-size
screenshots showed it filled the opening screen; the useful action is now first.

## Final evidence

Final candidate `488809d6c06b29233e7c1d1f7687c9cec03bbab4` passed the complete
both-platform milestone gate:625 definitions/1056 invocations, zero failures,
skips, expected failures or runtime warnings. Minimum/current Watch supplements
each passed454/454 definitions/876 invocations on that candidate. Final native
input/large-text/live-name captures were inspected; fields appear first and
controls remain usable. Exact provenance and physical coverage ownership are
in runtime.md and milestone-verification.md. No known blocking M27 finding remains.
Stop after DONE continuity checks; this is not independent or release approval.
