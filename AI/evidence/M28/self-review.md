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
