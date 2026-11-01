# M29 — owner-approved five-second timing prototype

Owner selected “Прототип 5 секунд (Recommended)” on 2026-11-01 after intermittent
physical two-series recognition on Watch build 4. [Decision](gesture-input-decision.md).
This is an experiment, not a ≥95% recognition/comfort pass or release approval.
M29 is IN_PROGRESS; the other physical requirements remain mandatory.

## Implementation and self-review

One production constant changes from three to five seconds in the existing shared
GestureInput reducer. One series proposes US, two select THEM, a third cancels.
The first activation fixes the deadline; further activations never extend it.
Visibility/lifecycle/revision cancellation, touch override, atomic commit/Undo,
no-motion architecture and schema 5 remain. Watch and explicitly simulated phone
teaching say five seconds in all 13 UI languages. Exact build identifiers advance
4 → 5 in all twenty project configurations and both version assertions.

Tests update their exact boundary from 2999/3000ms to 4999/5000ms. Expiry remains
at/after the deadline, and cancelled/stale-context observations move beyond the
new deadline so they cannot pass merely by checking too early. Timer-identity
coverage still exercises an expired old timer against a later pending sequence.
UI settle/cancellation waits move by exactly two seconds, preserving their margin;
no check is removed. A new unit regression tests second activation at 3500,4500,
4999ms, no premature award at three seconds, the unchanged 5000ms deadline and no
double commit. A new live UI regression checks Pending: US/no point after 3.2s,
then selects THEM and expects only their ordinary point.

## Mutable before/after evidence

Base main SHA `85ab8477149930025b894b68af707177242a254d`. Before run adds only the
new/updated gesture unit tests; production reducer is unchanged three seconds and
version remains 4. No production mutation occurs until this run finishes.

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/five-second-before.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/GestureInputTests -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Exit **65**, UTC2026-11-01T11:06:33.838Z–11:06:48.564Z. Five definitions / ten
invocations; three definitions pass, two fail (both exact five-second-selection
and late-second-series checks). Zero skipped/expected/runtime warnings. Raw
bundle, log and native summary retained under `.artifacts/M29/five-second-before*`.
This is the expected fail-before of the approved changed behavior, not a waived
failure of the old three-second product contract.

After five-second implementation, matching teaching and build-5 identity:

```sh
bash .artifacts/M25/runtime-profile.sh watch-current run xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScore -configuration Debug -destination 'platform=watchOS Simulator,id=36C94878-A329-4B51-92E9-4D72A40B178B' -derivedDataPath /private/tmp/padel-score-1acada2a5b10/DerivedData-m16-watch-current -resultBundlePath .artifacts/M29/five-second-unit-after.xcresult -parallel-testing-enabled NO -only-testing:PadelScoreWatchTests/GestureInputTests -only-testing:PadelScoreWatchTests/GestureScoringTests -only-testing:PadelScoreWatchTests/AppConfigurationTests -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test
```

Exit **0**, UTC2026-11-01T11:08:56.165Z–11:09:09.897Z. **26/26 definitions /
67/67 invocations**, zero failed/skipped/expected/runtime warnings. Includes all
gesture integration, failure/retry, Undo, completion accounting, migrations and
exact installed identity/localizations. Bundle, log and native summary under
`.artifacts/M29/five-second-unit-after*`. Frozen 242 App/Config/Scripts hashes:
`.artifacts/M29/five-second-source-inputs.json`; next commit will bind this exact
input set before UI verification and signed local build/install.

## Remaining work

Committed-source current/minimum UI and phone simulation checks; build/sign/install
1.0 (5), owner confirmation of Watch identity, and short real gesture/comfort
probes. No build-4 recognition result proves the five-second prototype. All full
M29 physical rows, final-source localized galleries/materials and six-domain
records, followed by the full unchanged milestone gate, remain incomplete.
