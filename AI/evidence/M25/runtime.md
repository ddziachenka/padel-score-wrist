# M25 digital runtime evidence

**Final status:** Digital M25 complete under the explicit M25-only owner exception.
[Verification](milestone-verification.md) and [authorization](owner-verification-exception.md)
supersede earlier pending-gate notes below. Raw full reports remain FAILED;
physical evidence remains PENDING_M29.

Builder self-review, not independent audit or release approval. Baseline
`be4ef5a1554a54bac1d5ccd7cb4188c013e62406`; current frozen app/test source
`f097a52d6a1154cf431156c30a81013a34d3cd47` (localized Reset, neutral Watch
next-server wording and added Help/reset coverage). The complete unchanged
`make milestone ID=M25` remains required. No M28 reuse exception applies.

## Current execution state

Frozen f097 source passes fresh minimum-phone4/4, minimum-Watch492/942,
current-Watch498/948 and complete current-phone20/20. Each has zero failed,
skipped, expected failures and native runtime warnings. Exact source, native UTC
times, device configurations and definition/invocation counts are retained in
native-supplements.json. Both gallery4 bundles and final material/site validation/review also pass as
recorded below. The unchanged complete REVIEW milestone gate remains required. No partial or failed result is
credited as a pass.

Older67f results are historical. Final content review then found untranslated
Reset and wider next-server agreement problems; f097 fixes both and adds missing
all-language maximum-text Help coverage. The strict material validator deliberately
rejected stale gallery3 after changed shipping catalogs, exit1. The completely new
gallery4 pair is captured/imported and validates; no fingerprint is relaxed.

## Current-source accepted result

The new minimum first-install bundle phone-clean-v4.xcresult passes4/4 definitions
and invocations, exit0, zero failed/skipped/expected/runtime warnings, on
f097a52d6a1154cf431156c30a81013a34d3cd47. Command:
`bash .artifacts/M25/runtime-profile.sh phone-clean-v4 run bash .artifacts/M25/run-clean-phone-v4.sh`.
Native listapps confirms the app was absent before installation. The bundle
includes normal appearance/Help and largest centering plus all26 Help language/
theme pairs with maximum Dynamic Type, native audits and a reachable44pt footer.
Exact times/configuration are in native-supplements.json.

Unmodified minimum Help originals in [Light](help-largest-minimum-light.png) and
[Dark](help-largest-minimum-dark.png) are8763F020-2328-4E5A-895C-140D2F8AFE2D.png
and793DB580-3902-4D66-949F-85FBAC65C565.png from that bundle. EN/DE/RU tops and
footer examples were visually inspected; large content scrolls normally and
retains full-size readable text. These checks do not activate external links.

The complete declared minimum-Watch supplement at the same f097 source passes
492/492 definitions and942/942 invocations, exit0, zero failed/skipped/expected/
runtime warnings. It retains all previous selected core/Journal/KnownScore/
PlayerNames/first-launch/About/fallback cases and adds compiled-copy13-language
checks plus actual practice1:0→localized Reset→0:0 with largest text and native
audits in all13 languages. Command:
`M25_SUPPLEMENT_RUN=watch-minimum-v4 bash .artifacts/M25/runtime-profile.sh watch-clean run bash .artifacts/M25/run-supplement.sh watch-minimum`.
Bundle: .artifacts/M25/watch-minimum-v4.xcresult. Exact times/configuration and
definition/invocation counts are in native-supplements.json.

The corresponding current-Watch27 supplement passes498/498 definitions and
948/948 invocations, exit0, zero failed/skipped/expected/native runtime warnings.
It runs the full GestureScoring class, Journal/KnownScore/PlayerNames UI and
Watch unit suite, including installed13-language copy and actual localized reset.
Command: `M25_SUPPLEMENT_RUN=watch-current-v4 bash .artifacts/M25/runtime-profile.sh watch-current run bash .artifacts/M25/run-supplement.sh watch-current`.
Bundle: .artifacts/M25/watch-current-v4.xcresult. Exact native times and device
configuration are in native-supplements.json.

The complete current-phone scheme passes20/20 definitions/invocations, exit0,
zero failed/skipped/expected/native runtime warnings, at the same f097 source.
Command: `bash .artifacts/M25/runtime-profile.sh phone-current-clean run bash .artifacts/M25/run-phone-prepared.sh .artifacts/M25/run-current-ui-final.sh phone-current-ui-final-v4`.
Bundle: .artifacts/M25/phone-current-ui-final-v4.xcresult. Native UTC interval is
2026-10-30T23:21:24.118Z–2026-10-31T01:31:38.881Z. The unfiltered20-case scheme
includes all26 gesture/reset language/theme pairs (1571.405s), all26 largest Help
pairs (1698.962s), both recovery journeys through all26 largest language/theme
pairs (2589.898s), actual eight-surface themes, centered EN/DE/RU, ordinary input,
Undo/cancellation/tab/relaunch,14-region galleries and genuine StoreKit-verified
ownership. Full20 is accepted from strict summary AND invocation-leaf export,
not inferred from console progress. The complete gallery4 pair and material review now pass below; the unchanged
complete milestone gate remains pending.

All13 minimum-Watch Reset originals were also visually inspected at their native
324×394 size. Translations are visible and complete; German wraps normally onto
two lines at maximum Dynamic Type. System navigation titles remain in the native
scrolling header. The unmodified attachment identities/timestamps are retained in
[the inspection manifest](watch-reset-minimum-v4-attachments.json); the diagnostic
contact sheet is .artifacts/M25/watch-reset-minimum-v4-contact.jpg.

The corresponding13 current-Watch27 Reset originals were also visually inspected
at native324×394; translations remain fully visible, German uses two lines and the
system scrolling header/fade remains native. Exact originals are listed in
[the current inspection manifest](watch-reset-current-v4-attachments.json).
The diagnostic sheet is .artifacts/M25/watch-reset-current-v4-contact.jpg.

The new f097 Watch gallery4 passes14/14 definitions/invocations, exit0, zero
failed/skipped/expected/native runtime warnings. Command:
`bash Scripts/capture-store-materials.sh watch capture watch-gallery-4`.
Bundle: .artifacts/M25/watch-gallery-4.xcresult. Strict native summary/tests export
passes. All112 originals were visually inspected in14 fresh native-size contact
sheets; neutral next-server labels, scores, serving and locale story states agree.
Long native form/result viewports continue below the screenshot boundary; no
original is cropped/reconstructed. The matching phone gallery4 passes2/2 definitions/invocations, exit0, all zero
adverse native counts. Command:
`bash Scripts/capture-store-materials.sh phone-current capture phone-gallery-4`.
Bundle: .artifacts/M25/phone-gallery-4.xcresult. Both source files equal f097;
the entire frozen v4 pipeline exits0. All210 native originals/28 compositions are
imported/regenerated and visually reviewed through42 final contact sheets.
Strict source/attachment/hash/dimension/opaque-RGB/site-copy validation and
make site-check pass exit0. Final53 HTML/CSS files match the208-combination
browser proof source byte-for-byte; site-layout-identity.json records the exact
comparison. The unchanged full milestone gate remains required.

## Historical scoped results

Native summaries, exact UTC times, device configurations, definition/invocation
counts and original result paths are retained in [native-supplements.json](native-supplements.json).
Each accepted row below has zero failed/skipped/expected/native runtime warnings.
Build/SDK notes retained in console logs are not claimed absent.

| Scope / source | Bundle under .artifacts/M25/ | Definitions / invocations | Result |
| --- | --- | --- | --- |
| Minimum Watch; c178abf12c7dd6ff0f1c6c0b2669611556375831 | watch-minimum-v2.xcresult | 490/490;928/928 | exit0 |
| Current Watch; 5551a9f6b3bb315d145a6933854be7ca1cf23f5d | watch-current.xcresult | 496/496;934/934 | exit0 |
| Current phone Start/Help/centering;9a4dcdd15a4cfc280103e7366eed0e80ce1888ae | phone-help-centered-current-v15.xcresult | 2/2;2/2 | exit0 |
| Minimum phone Start/Help/centering;same9a4 source | phone-help-centered-minimum-v15.xcresult | 2/2;2/2 | exit0 |
| Current recovery toolbar;affb77170e60be36ff3c105c08f70c8ceb345ece | phone-close-icon-current.xcresult | 1/1;1/1 | exit0 |
| Minimum recovery toolbar;sameaffb source | phone-close-icon-minimum.xcresult | 1/1;1/1 | exit0 |
| Complete current phone UI;67f9975c16689c3494e83443b81b7b48a9999ae0 | phone-current-ui-final-v3.xcresult | 19/19;19/19 | exit0 |
| Final Watch gallery;same67f source | watch-gallery-3.xcresult | 14/14;14/14 | exit0 |

Commands executed in their recorded managed leases:

- `M25_SUPPLEMENT_RUN=watch-minimum-v2 bash .artifacts/M25/runtime-profile.sh watch-clean run bash .artifacts/M25/run-supplement.sh watch-minimum`
- `bash .artifacts/M25/run-supplement.sh watch-current` (inside the recorded current-Watch managed context)
- `bash .artifacts/M16/runtime-profile.sh phone-current run bash .artifacts/M25/run-phone-recheck.sh phone-help-centered-current-v15`
- `Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/run-phone-recheck.sh phone-help-centered-minimum-v15`
- `bash .artifacts/M25/runtime-profile.sh phone-current-clean run bash .artifacts/M25/run-phone-prepared.sh .artifacts/M25/run-close-targeted.sh phone-close-icon-current`
- `Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/run-phone-prepared.sh .artifacts/M25/run-close-targeted.sh phone-close-icon-minimum`
- `bash .artifacts/M25/runtime-profile.sh phone-current-clean run bash .artifacts/M25/run-phone-prepared.sh .artifacts/M25/run-current-ui-final.sh phone-current-ui-final-v3`
- `bash Scripts/capture-store-materials.sh watch capture watch-gallery-3`

The historical Watch command's wrapper/context and exact source are retained in
its log. Watch input identity held before the copy refinement. Source f097 changes
Watch review/copy and tests deliberately, so new minimum/current Watch supplements
are required and running. No old Watch component replaces any platform in the
complete final milestone command.

## Centered recovery card and native semantics

The owner-requested heading and three actions share the full-width central axis;
multiline labels remain centered with44pt targets. The decorative leading glyph
no longer shifts only the gesture label. Normal English and maximum English,
German and Russian are measured and audited. The [current original capture](centered-recovery-current.png)
isCFC657F0-3579-4B31-B238-42B8C64E1B5F.png from the complete current UI-v4 run
onf097. The normal English card and maximum German/Russian originals were visually
inspected after export; all labels share the central axis and remain scrollable.

Start/Help long text, headings and action labels use measured native UILabels with
opaque semantic surfaces, preferred Dynamic Type and native header/label traits.
Primary demo artwork stacks above its title at accessibility sizes. Legal links
retain their URLs and Link roles in one vertical44pt layout. Help keeps its normal
NavigationLink and Back behavior. The selected tab explicitly controls retained
navigation content's accessibility visibility, correcting the minimum-iOS zero AX
container frame observed after tab switching without recreating navigation state.
Minimum Help [Light](help-after-light.png) and [Dark](help-after-dark.png) are
unmodified originals6D3F0163-AFB1-4334-BDA1-F5B6FD38370D.png and
4F989497-A4D3-4539-B993-9A1B9882FE4F.png from minimum-v15.

The final recovery dismissal is a familiar native xmark with the localized Close
accessibility name/ID and44pt target. It retains dismissal and Escape. All twelve
native-audit checkpoints in the German-largest input/preview/result scenarios pass in both
themes on each runtime. Current original examples are
[Light](close-current-light.png) and [Dark](close-current-dark.png), exported from
22C75287-7FFD-44F5-BCE1-D0DD68EC88EA.png and
AB36EB45-6AB7-487A-BB67-E5F0B1A7B887.png. No audit category or strict occlusion
predicate was changed. The earlier semantic-primary word still failed native
Contrast and is not called a fix.

Current maximum-text Help top/footer originals for EN/DE/RU in both themes were
also visually inspected after full20 completed. Text wraps/scrolls normally and
all final links are visible. Durable unmodified EN top examples are
[Light](help-largest-current-light.png),68E894E4-13AB-455F-924C-75B9361F0C9F.png,
and [Dark](help-largest-current-dark.png),0FDCD8B6-E43B-4019-9A5D-2527B89FCA78.png.
[Attachment selection](phone-current-v4-attachment-selection.json) records all52
Help and12 centering originals, source/bundle, and durable-image hashes. Normal
EN and maximum DE/RU centering originals were visually rechecked at this final
source. Diagnostic sheets are .artifacts/M25/help-largest-current-v4-{false,true}-contact.jpg;
no native evidence image was edited.

## Actual appearance and managed-device preparation

The M28 getter/filename discrepancy was investigated using real pixels, including
a separate Settings observation. Acknowledged Dark could still render Light.
Setting Dark and restarting only the reserved owned device initializes a working
compositor; actual Light/Dark is then checked, with original style/boot state
restored afterward. The same behavior was later observed on the newly created
current27 profile and corrected by this preparation. No global service restart,
erase or shipping theme override is used.

Every themed capture checks five opaque page-margin RGB means: all below96 for
Dark, all above160 for Light, with bounded settling. Getter assertions remain in
addition. The final appearance case covers Start, gestures, historical correction,
known score, Match, Americano, Access and Help in both themes, plus initial/post-tab
Help geometry/hittability and all six original native audit categories. The full
locale/largest matrices use the same real-pixel checks.

The new final first-install profile is7C65E86E-4A9B-4715-981D-B7A31A28F358/iOS17;
D24D4F58-5AE8-42CD-B838-3D86E97B64EC is the successful historical67f first install.
Managed endpoints: minimum Watch E28D3B30-45A1-4731-BA01-CBEFDB123059/watchOS10;
current Watch36C94878-A329-4B51-92E9-4D72A40B178B/watchOS27;
minimum phoneB9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2/iOS17;
original current phone2D44D21F-290D-4325-8DED-B98D29977585/iOS27;
new isolated current phone53FFFA81-4A4C-4257-BD1D-1C4C59AEA96C/iOS27.
Original bindings/data remain intact. The owner reports Simulator cleanup during
execution; explicit readback confirms all relevant devices still available.

## StoreKit compatibility observation

The additional full current-runtime unit probe is **FAILED19/21 definitions,
28/30 invocations**, identically reproduced by the same scope at the baseline.
No native result is relabelled passed. [Bounded evidence](storekit-current-runtime.md)
records two P2 synthetic error/storefront discrepancies, successful remaining
purchase/right checks, exact commands/raw exits and the possible machine-state
confounder. All temporary diagnostics and ineffective scheme changes were removed;
production StoreKit logic and original unit expectations are unchanged. The
mandatory complete milestone gate still has to pass in its configured environments.

## Physical boundary

Actual Double Tap recognition, VoiceOver/haptics, wrist/lock behavior, real
purchase/restore and remaining M27 scenarios are **PENDING_M29**. See the
[M29 inventory](M29-hardware-inventory.md). Simulator activations, accessibility
audits and generated artwork never prove those physical requirements. All failed,
interrupted and diagnostic attempts remain distinct in [work-log.md](work-log.md).

## Post-gate test traversal correction

The first full fa70662 gate remains FAILED after its minimum-phone traversal
failure; successful Watch/unit components are not reused. Source
`4720028cffdabc4082385506578f8af25c61450d` changes only the phone UI test:
bounded64 short drags, a fail-before/pass-after Portuguese-largest regression and
failure-only diagnostics. The original six native audit categories, full-target
visibility predicate, native re-audit and all existing matrices remain intact.
Minimum development regression1/1 and clean current-runtime regression1/1 pass,
exit0, zero failed/skipped/expected/native runtime warnings. The current run is
`2026-10-31T07:35:35.957Z`–`2026-10-31T07:38:57.184Z`, owned iPhone17ProMax/iOS27
53FFFA81-4A4C-4257-BD1D-1C4C59AEA96C; exact commands/summary/leaf counts are
in native-supplements.json and [the repair evidence](minimum-gesture-audit-traversal.md).
Production App file membership/bytes equal the f097 gallery4 fingerprints;
strict active material validation passes, exit0. Existing42 visual reviews remain
applicable. The fresh exact full gate still must pass before DONE.

## Owner-authorized component completion

M25 is DONE under the explicit M25-only owner exception. Verified candidate
`5eb65bbc17e9540d3922a520b44d3c8731947432`: watch 635/635 definitions/1085 invocations; phone-unit 21/21 definitions/30 invocations; phone-ui 21/21 definitions/21 invocations.
Aggregate 677 definitions/1136 invocations, zero failed/skipped/
expected/native runtime warnings in the accepted components. Both Debug/package
guards pass. Complete new phone command `bash .artifacts/M25/runtime-profile.sh phone-companion verify phone-complete-same-candidate`, exit0,
UTC2026-10-31T14:27:08Z–2026-10-31T16:45:19Z; report `.artifacts/M25/phone-complete-same-candidate/report.md`.
The Watch component is from `.artifacts/milestone/M25/20261031T083305Z-38339/milestone.xcresult` at exactly the same SHA.
The complete monolithic make remains FAILED/exit130, never relabelled passed.
See [owner authorization](owner-verification-exception.md) and
[exact verification](milestone-verification.md). All physical checks remain M29.
