# M23 development record

Baseline clean `main`: `86e6bcc978814398e5607edcdd9936ac557a92ec`.
Scope: approved M23 start from a known Match/Americano score only.

- Initial sandboxed `bash .artifacts/M23/run-unit.sh 1` could not contact
  CoreSimulator. No test pass claimed; raw output retained in development-1.log.
- `bash .artifacts/M23/run-unit.sh 2` with normal Simulator access exited 0;
  `.artifacts/M23/development-2.xcresult`: 430 definitions / 838 invocations,
  zero failed/skipped/expected/runtime warnings. This is development evidence,
  not the immutable milestone gate.
- First `make static` exited 2 because Italian/Portuguese correctly translated
  “Zero” identically to English, requiring an explanation under the unchanged
  English-match verifier. Chose clearer “From zero” and its actual translations;
  no allowlist/check was weakened. Second `make static` passed exit 0 at
  `.artifacts/M23/static-development-2.log`; all seven added strings are translated
  in the thirteen existing locales. `Scripts/verify-localizations.py` exit 0,
  `.artifacts/M23/localization-final.log`.
- Self-review correction: shared points editor must explain that a completed
  Americano round cannot start, rather than promising that Save finishes it.
  Existing correction copy/behavior remains its own context.
- Native controls and shared score/serving editors are sufficient for this careful
  input-and-confirmation flow. No animation or artwork earns a place here.

Further runtime and clean candidate evidence is recorded separately.

The initial new UI set (`bash .artifacts/M23/run-ui.sh 1`) exited65:
Americano and largest-text/background/cancel passed; Match scoring, service and
Undo passed before its new checkpoint assertion looked for StaticText although
Journal deliberately exposes that row as a combined NavigationLink/Button. The
assertion now taps the correctly typed checkpoint row and requires its exact title
in detail; no production check or assertion intent was removed. Final new-scope
minimum-runtime suite includes the whole journey again. The initial failed
`.artifacts/M23/ui-1.xcresult` remains evidence, never counted as a pass.

Self-review also moved the actual score first in Review, removed duplicate point
and error presentations, made Cancel discard the score draft, and constrained the
Access sheet to the visible confirmation (the underlying setup/overview do not
also try to present it). No production scoring behavior was relaxed.

A further state-ownership review found that returning to setup to change a rule
silently cleared the entered known score. The flow now preserves games/sets/points,
updates only the chosen rules/service, and revalidates conflicts with the shared
draft. The regression requires preserved score plus changed rule; explicitly
choosing From zero still clears that alternative draft. Cancellation coverage now
uses the production Cancel method and checks that it discards only the draft.

## Late checkpoint-detail finding

The initial clean REVIEW candidate `0f337a4551a6f518b0a1cec42aa744e09177508b`
started `make milestone ID=M23`. During a further reading of the runtime capture,
self-review found that its known-score checkpoint detail reused the manual-boundary
explanation “Earlier rallies can be viewed”, contradicting this start's unknown
past. The Watch test process was deliberately interrupted with SIGINT; this partial
run is not accepted as a passing milestone, and its raw report/bundle remain at
`.artifacts/milestone/M23/20261028T144716Z-40213/`.

The detail now reuses the existing translated statement that earlier rally detail
is unavailable. A UI regression requires that exact statement after opening the
known-score checkpoint, in addition to its existing title/score/Undo/relaunch
assertions. No existing checkpoint/correction statement is changed for other
reasons; no suite/assertion/parser/category was weakened. M23 returned to
IN_PROGRESS for correction and fresh targeted/full verification.

Interrupted gate actual disposition: Make2 / verifier65 / xcodebuild73, raw
FAILED. Partial bundle535 definitions:534 passed,1 failed (“Testing was canceled”,
StoreMaterialsUITests/testLocalizeddeCreation);943 invocations:942 passed/1
failed; no skips/expected/runtime warnings. Static and Debug passed, iPhone suites
not reached. Xcode also reported incomplete action-log import after interruption.
The raw JSON is `.artifacts/M23/interrupted-gate-summary.json`; these partial
counts and builds are never substituted for the required fresh complete gate.

The same final copy audit found that PointsSummary still showed the ordinary
correction's “Saving finishes the round” notice for an invalid known-score start.
New-game score rows now suppress that notice, keep the explicit cannot-start
explanation and disabled Review, and preserve ordinary correction behavior. A
fifth UI case builds an invalid completed known round from blank setup, checks
both editor and overview explanations, absence of a finish offer, cancellation
and cold-launch proof that no game started. The blank current-score service
chooser also uses neutral Choose under After them rather than asking for an
unknown game's historical first server. All text is reused from translated keys.
