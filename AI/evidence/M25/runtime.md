# M25 digital runtime evidence

Builder self-review; no independent audit or release approval. Baseline
`be4ef5a1554a54bac1d5ccd7cb4188c013e62406`; frozen capture source
`4f1689944480aadfad592629e3c8394a9582c6b7`. Final immutable milestone evidence
will be recorded separately after the complete required gate; targeted passes
below do not substitute for it. No M28 reuse exception applies to M25.

## Centered recovery card and native text measurement

The owner's screenshot request is implemented in PhoneStartView: heading and all
three links share the same full-width central axis, with centered multiline
labels,44pt minimum target height and native action identity. Decorative leading
art no longer shifts only the first entry. Main demo/access labels and long Start
instructions use measured UILabel text on opaque semantic surfaces. At the largest
accessibility sizes, the demo icon stacks above its label. Step digits have primary
contrast and are announced within their combined step. Navigation and approved
product behavior are unchanged.

| Command (managed lease) | Native result bundle | Environment | Result |
| --- | --- | --- | --- |
| Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/run-phone-centered-small-v2.sh | .artifacts/M25/phone-centered-small-v2.xcresult | iPhone SE3,iOS17.0,B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2 | exit0;1/1;0 failed/skipped/expected/runtime warnings |
| bash .artifacts/M16/runtime-profile.sh phone-current run bash .artifacts/M25/run-phone-centered-large-v4.sh | .artifacts/M25/phone-centered-large-v4.xcresult | iPhone17ProMax,iOS27.0,2D44D21F-290D-4325-8DED-B98D29977585 | exit0;1/1;0 failed/skipped/expected/runtime warnings |

Both run testM25CenteredRecoveryEntriesRemainReachableAtLargestText: normal EN
and largest EN/DE/RU, real controls and all original native audit categories.
The final shipping source was mutable during diagnosis and committed as4f16899
before gallery capture; these are development evidence, not an exact-SHA gate.
[Unmodified large-phone attachment](centered-recovery-current.png) shows the full
card, exported from2C9A786C-CBF1-4728-A346-AF4F4793A03C.png. Original exports,
manifest and failures remain under .artifacts/M25/. See work-log.md for failed
reproductions and fixes; none is labelled a pre-existing failure.

## Minimum-iOS appearance discrepancy

M28's Dark-labelled/Light-rendered captures were investigated with actual pixels.
A blank launch frame was rejected as evidence. System Settings also rendered
Light despite Dark readback. After setting Dark and rebooting only the owned idle
SE3 simulator, both Settings and the app rendered Dark. Original preference was
restored. No erase, global restart or production theme override was used.

Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/run-phone-appearance.sh passed
exit0,1/1 in phone-appearance-smoke.xcresult. Fourteen original captures cover
Start, gestures, historical correction, known-score input, Match, Americano and
Access in both appearances. assertRenderedAppearance checks five opaque page
margin pixels in every themed capture, with bounded compositor settling; getter
assertions remain in addition. The full locale/largest matrices now use this same
check and must pass again in the final required gate. SDK build-version/debugger
notes in xcodebuild logs are retained; native runtimeWarnings is empty, which is
not a claim that compilation emitted no warnings.

## Localized native galleries and runtime supplements

Pending complete current runs. Only a complete14/14 Watch and2/2 phone gallery
can be imported. Capture scripts hold managed leases and verify unchanged HEAD
and App/Config/Scripts before/after. Each image retains native attachment name,
source SHA, device, time, fixture/actions, original dimensions and byte hash.

## Physical boundary

All actual Double Tap recognition, actual VoiceOver/haptics, wrist/lock behavior,
real purchase/restore and remaining M27 scenarios are PENDING_M29. See
[M29 inventory](M29-hardware-inventory.md). Simulator button activations and native
accessibility audits never prove these physical requirements.
