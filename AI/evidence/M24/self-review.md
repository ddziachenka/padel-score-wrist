# M24 Builder self-review

Baseline: `2c6b4c7552968f034417428d8461b7e93bc3979c` on clean `main`.
This is Builder self-review, not independent review or release approval.

Scope: only two isolated interactive iPhone recovery routes and their localized
presentation/tests. Shared Watch domain behavior, StoreKit, real persistence,
usage, pricing, review eligibility and external review materials are unchanged.

- Domain ownership: a disposable value `Session`, uncounted access, no repository,
  file, preference, entitlement or review dependency. Original demos alone retain
  their existing eligibility callback. Preview is pure and confirmation uses the
  same domain command as Watch; whole-correction Undo retains stable rally IDs.
- Input: correction selects change/delete/insert, winner, target and insertion
  side. Known-score examples state fixed rules, validate both formats, confirm an
  immutable snapshot, stop Undo at its typed checkpoint, and require explicit
  serving after a set boundary. They do not claim to replace full Watch setup.
- Lifecycle: back/Close discards the destination; leaving Demo clears its path;
  reset starts fresh. Background keeps memory, cold launch keeps no demo state.
- Craftsmanship: existing cards/palette and native menu controls, vertically
  wrapping content, persistent Demo navigation title, complete before/after score,
  serving and finish status, explicit unknown earlier history. Preview starts at
  the top. VoiceOver focus follows the step; before/after and scoring/Undo have
  localized spoken summaries; errors are announced. No decorative animation,
  bespoke asset or new haptic is warranted by this instructional flow.
- Copy: 25 new keys and reused Watch journal strings ship in all thirteen locales.
  No uniqueness claim, new paywall, entitlement flag or free-game claim is added.
- Test quality: domain tests assert actual replayed winners/IDs, purity of cancel,
  whole-record Undo, checkpoint boundaries, invalid/finished state rejection,
  service boundaries, completion/Undo without usage, and instance/defaults isolation.
  UI drives real editable input, cancellation, confirmation, scoring, Undo, resets,
  tab leave, background and cold launch. Native categories remain intact.

During review, shortened guidance that was unnecessarily long at accessibility
sizes, made step navigation return to the top, and made the initial unknown-history
boundary explicit. The first UI run also exposed a test helper selecting a hidden
retained TabView scroll view; it now drives the visible viewport, preserving every
journey assertion. Exact runtime results and any subsequent corrections are
recorded in runtime.md and milestone-verification.md after execution.

No additional problem scanner is configured beyond static; optional analyzers
remain disabled by existing product configuration. Physical-device/VoiceOver and
full-product six-domain coverage remains owned by M25; no such pass is claimed here.
