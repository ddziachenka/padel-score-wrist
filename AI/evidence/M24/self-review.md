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
- Lifecycle: Close or accessibility escape destroys the example; reopening
  and Reset start fresh. Original Demo tab-leave behavior is preserved. Background keeps memory, cold launch keeps no demo state.
- Craftsmanship: existing cards/palette and native menu controls, vertically
  wrapping content, persistent Demo navigation title, complete before/after score,
  serving and finish status, explicit unknown earlier history. Preview starts at
  the top. Step transitions and before/after, scoring, serving confirmation and Undo have
  localized native announcements; errors are announced. No decorative animation,
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
journey assertion. The tab-leave assertions then reproduced a noninteractive recovery entry/return
control on iOS17 after navigation across retained tab stacks (captured in recordings).
Guided scenarios now use native full-screen presentations with their own lifetime, preserving the
original tab navigation. Dismiss/reopen, cancellation, score and Undo assertions
remain. Native auditing also found that replacing the small Review heading's
accessibility label with its entire spoken summary looked clipped; visible labels
now remain accurate and localized summaries use native announcements. No audit
category or issue is suppressed.

Repeated presentations have a fresh UUID and keyed view tree. UI assertions check
which input form opened. The appearance matrix now sets and reads XCTest's native
device appearance; the earlier unsupported launch argument was caught by visual
inspection and is not accepted as Dark Mode evidence. Navigation addresses the presented guide by its stable ScrollView identifier;
native issue rechecks retain precise slow positioning.
The explicit new-set regression checks valid serving choices and exact Undo.
Normal-text auditing caught a faded disabled Undo; guide actions now keep opaque
semantic text/borders in disabled states. The original scoring/purchase styles
are unaffected. A visible score label in a partially clipped card receives its
same native audit again with the whole card visible when it fits. Oversized cards
still recheck individual labels. Every score label has a unique context identifier,
so Before/After cannot share a recheck. The complete-card serving/Undo regression
then passed with zero failed/skipped/expected/runtime warnings. Invalid input and
Reset return the guide to the top; serving confirmation is announced.

Exact runtime results and any subsequent corrections are
recorded in runtime.md and milestone-verification.md after execution.

No additional problem scanner is configured beyond static; optional analyzers
remain disabled by existing product configuration. Physical-device/VoiceOver and
full-product six-domain coverage remains owned by M25; no such pass is claimed here.


The first clean REVIEW candidate `bbf9b0bca1823f58c8187e6074107560c34ac395`
passed the four functional UI cases, but its small-phone supplement found German
heading clipping at maximum Dynamic Type. The pipeline stopped before the large
phone, unit supplement and declared milestone gate; that candidate is not verified.
Raw failure: `.artifacts/M24/small-complete.xcresult`, outer exit75. Padding and a
compact SwiftUI title alone did not resolve the finding; their failed focused
bundles remain. A native multiline UILabel with preferred-font metrics and natural
hyphenation then passed both German titles through input/preview/result in both
appearances, with actual large rendering inspected. The permanent regression also
requires a scaled heading height, full copy and visible bounds. No title was
shortened, font cap added, audit filtered or mandatory check removed. A new clean
candidate must run all supplemental and declared validation afresh.


The second clean REVIEW candidate `8bdaa7a7978b63b13182e6ef0a563bb51c5752d2`
stopped in its small-phone supplement with four passing functional cases and a
failed German visibility assertion; the locale matrix was interrupted, so its
bundle records four passed/two failed, with no skipped/expected/runtime warnings.
It never reached the large supplement or declared gate. Native heading audits and
size assertions did not fail. Slower coordinate gestures and side-padding drags
also failed to move the presented scroll view reliably; both failed focused runs
remain recorded. The helper now resolves the guide's uniquely identified native
ScrollView and uses XCTest's swipe gesture, re-resolving the target and retaining
all journey assertions. An explicit viewport assertion also checks the exhausted
helper path. This correction changes only test navigation; product, audit categories,
heading wording and font scaling are unchanged.

The named-scroll-view German regression then passed on the small iOS17 phone,
exit0, one definition/invocation and all twelve native state audits. Temporary
scroll-position diagnostics were removed; no assertion or interaction was removed.
The final clean candidate runs the full six-case large-phone supplement and full
phone-unit supplement, followed by the exact unfiltered milestone gate. That gate
owns the complete small-phone UI suite, including the same thirteen-locale/two-mode
largest-text matrix, so a redundant separate small-phone supplement is unnecessary.

The third clean candidate `713fd5fba1f19b6c2860a9060663bf2e92c6c159`
passed the large-phone heading, editable-score, Americano and correction journeys,
but its normal-size next-set audits found contrast on `phone.recovery.badge`.
The large supplement was stopped before its matrix, unit supplement and declared
gate; raw exit75 and four-passed/two-failed bundle remain. The recorded badge was
fully visible (19.3pt high), so this finding is fixed in the UI: its text and
symbol now use opaque semantic primary color. Branded lime primary actions stay
intact. No test or native issue handler changed for this correction.

Changing badge color alone, capturing a settled frame, and splitting text from its
redundant icon did not clear the large-phone native result; those failed focused
bundles remain. The split-label experiment was reverted. iOS26's automatic
scroll-edge effect was then disabled for the guide, whose toolbar already has an
opaque semantic background. With this sole final comparison, the exact serving/Undo
case passed, exit0, including both native state audits. The conditional native API
keeps the iOS17 path intact; the guide badge retains high-contrast semantic primary
color. Audits wait one second for compositor updates, as screenshot capture already
does, and all categories/issue handling/assertions remain. Apple's API explanation:
https://developer.apple.com/documentation/swiftui/view/scrolledgeeffecthidden(_:for:).
A new clean candidate must run all supplements and the declared gate; none of these
focused passes is substituted for milestone verification.

Candidate `992bd0d6080bc571f6e4b46807bdafd304359fe6` passed all five
focused large-phone cases, including both native serving/Undo audits. The matrix
then reproduced failed test navigation to `phone.recovery.openStart` below the
original Demo at maximum text; it was interrupted and remains failed evidence.
The helper had still used coordinate gestures on the two original root screens.
Start and both original Demo layouts now expose stable ScrollView identifiers,
and every reveal uses the explicitly named current screen's native swipe. This
adds only test identifiers to existing screens and retains their layout, behavior,
all visibility assertions and the complete matrix. The final large supplement
rechecks all six cases before the declared full gate.
