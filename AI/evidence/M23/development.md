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
