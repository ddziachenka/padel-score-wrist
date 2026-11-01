# M29 Builder self-review

**Policy status:** current
**Record type:** Builder self-review, not independent audit or release approval
**Baseline:** `d92b9e9e9250e309a074953faa10ed4c06eddffb`
**Inspected source:** `1367217b30ce0c5ffa2c464ea977786e28139439`
**Final state:** complete; no open P0/P1
**Final verified candidate:** `a908212c242663c2079427cd3d40ef923d73bd40`

## Scope and corrections

Six shipping files differ from the baseline: project build identity, Watch/phone
catalogs, shared GestureInput, Watch GestureScoringView and PhoneGestureView.
Each is byte-identical to targeted-tested build6 source
`ff87edd550f376b618d44ebb7904ef29f769b686`. A read-only assertion of this exact
membership/continuity exits0; `.artifacts/M29/self-review-source-scope.json`.
No score engine, persistence/migration, purchase, privacy/permission, player-name,
free-game or review-eligibility implementation is changed.

The result-origin practice defect was reproduced before correction. Both owning
navigation-stack contexts now route through NewGameFlow.path; new regressions
check an editable OFF draft and unchanged saved result after disposable practice.
The minimum-runtime clipped test tap was baseline-reproduced and corrected by
revealing the real control, with a stronger Pending assertion. The approved
five-second window required replacing obsolete post-deadline waits; the missed
gallery wait was then corrected with additional pending/no-early-Undo assertions.
All raw failed bundles and commands remain in the linked evidence.

The first activation fixes the five-second deadline. A second chooses THEM without
moving it, a third cancels; due input is consumed once. Existing game/revision/
timer identity, inactive/reduced-luminance/navigation/editor cancellation and
ordinary atomic-save/Undo paths remain. Tests cover3500/4500/4999ms late second
series, exact5000ms settlement, no old3s settlement and no repeat. No alternate
motion classifier, workout keep-awake bypass, continuous animation or new backend
is introduced.

Build6 explains the previously unclear sequence: wait for the actual localized
Pending: US preview, then repeat two finger contacts. Both catalogs agree across
thirteen languages; Watch instructions/hint and explicit phone simulation share
the teaching. Source/copy inspection found no new blocking issue. Further
first-series-anchor wording is a recorded P2; fixed-deadline behavior is explicit
in source/tests and current local Review Notes.

## Evidence boundaries

Current/minimum Watch32/32 definitions/73 invocations each and phone UI1/1 pass,
all adverse counts0, at ff87. These are targeted checks, not the complete gate.
Exact commands/UTC/bundles are in [prototype evidence](five-second-prototype.md).
Fresh Watch14/14 and phone2/2 galleries pass at136, all adverse counts0.
All42 contact sheets are visually reviewed,210 native captures/28 compositions/
104 site copies pass strict provenance checks, and53 HTML/CSS files exactly bind
208 browser-layout observations with12 passing palette checks. Final browser
visual samples and `make static` pass; see [materials](material-refresh.md),
[phone review](phone-gallery-visual-review.md), [creative review](creative-visual-review.md)
and [browser review](site-browser-review.md). The unchanged full `make milestone ID=M29` now passes, exit0, on clean REVIEW/
main `a908212c242663c2079427cd3d40ef923d73bd40`: Watch640/1092, phone unit21/30,
phone UI21/21; aggregate682 definitions/1143 invocations, all adverse counts0.
Both Debug/package guards pass. [Exact evidence](milestone-verification.md).

The [owner decision](owner-physical-acceptance.md) closes all manual physical rows.
It creates no recognition percentages, measured hour/zero counts, supplied video,
independent Watch6 readback or new agent-observed Sandbox/VoiceOver result. Earlier
hardware constraints are disclosures, not renewed manual blockers. No automatic
verification exception is inherited.

Separate delegated scoped [source](independent-scoped-code-review.md) and
[copy](material-copy-review.md) reviews are identified as such; this Builder's
self-review never becomes an independent full audit or release approval.
The post-capture REL-1302 prose now says five seconds; row identity/domains and
all guards are unchanged. Final full-gate/native-leaf evidence is reconciled above. Post-DONE static/status/
continuity outputs are retained under `.artifacts/M29/post-done-*.log`. No external upload/reply/publication/
submission is authorized or performed.
