# M28 Builder self-review

This is self-review, not an independent audit or release approval.

Reviewed baseline-to-tip scope: gesture reducer/timer ownership and cancellation,
atomic metadata/rally commands and retry identity, explicit schema1–4 migration,
new-game defaults/Play again/known-score flows, navigation/Always On/inactivity,
score boundaries, completion ledger, practice isolation, native shortcut availability,
source/host parity, localization, layout and accessibility.

Pending input never writes to score/journal/Undo/usage or survives restart. A committed
rally uses the existing command and save/retry path; metadata toggles retain score
history. The option belongs only to the current game and is not inherited by a new
game. The shortcut is bound to a visible button and no other flow. No added permission,
motion capture, network, account or real-match iPhone control.

Corrections and raw failed runs: development.md. Final exact-candidate verification,
runtime inspection and final disposition are recorded after gates below/in handoff.

Additional lifecycle review found that a retained offscreen ScoreScreen could see
foreground/luminance changes. Its explicit onAppear/onDisappear visibility flag
now participates in every reactivation check. Due timer callbacks release their
own task handle before storage, avoiding self-cancellation of the accepted writer.
New tests cover stale timer identity, named schema4 migration, frozen schema4
required fields and once-per-game completion after Undo/re-completion.

The first full candidate found visible Spanish largest-text explanation contrast.
A focused native regression failed before the fix and passed after critical guide
copy switched to primary semantic text. New matrix appearance switching now uses
the actual device with assertions/restoration, matching the established suites.
Full corrected matrix and a fresh immutable milestone gate remain required.

The initial focused contrast pass did not survive the sequential matrix. Preserved
that failed run, strengthened the regression with the English prelude and capture,
and kept all deferred-text rechecks. Opaque navigation alone was insufficient.
Removing the oversized decorative intro card (preserving every localized Text and
font scale) passed the same strengthened four-scenario regression. The guide now
follows the native grouped-background introduction used by the adjacent recovery
flow; its interactive card remains and its title has a heading trait. No native
audit helper or assertion was loosened. Full matrix/gate still required.

The next complete matrix exposed the same explanation in Portuguese (contrast)
and German (clipping). Kept that full FAILED result. Teaching paragraphs now use
native accessible UILabel measurement on explicit semantic surfaces, as already
used by recovery guidance; no text is hidden or scaled down. The strengthened
generic regression covers all failing locales, and both it and the full matrix
require the real explanation element to retain largest-size height. No audit
helper, category, exception, timing assertion or count parser changed.

The native-label regression passed all10 variants. Strengthened its coverage and
the full matrix further: the explanation must retain largest-font height, fit and
be fully visible for an explicit native audit before controls are shown. The
original audit helper stays byte-identical. The interrupted preflight is not
counted as passing; final full phone suites own these stronger checks. The later
owner-authorized Watch-result reuse is a verification-policy exception, not a
native audit exemption; it is recorded separately and expires after M28.

First owner-verification attempt passed every new gesture variant but an ordinary
post-audit picker tap in Americano failed to open its menu. Preserved the FAILED
full result and the isolated unchanged pass; no pre-existing claim. Failure event
coordinates matched the visible picker. The interaction now asserts its complete
frame visible and uses one deliberate200ms press, retaining option10, completed
score, draw and Undo expectations. No blind retry or timeout relaxation. Focused
check passed; final complete phone rerun remains required.
