# M25 Builder self-review

Baseline `be4ef5a1554a54bac1d5ccd7cb4188c013e62406`; reviewed shipping/test source
`f097a52d6a1154cf431156c30a81013a34d3cd47`. Builder self-review, not independent
review, release approval or physical recognition evidence. Final scoped native
runs, new gallery pair, strict material/site validation and
all42 visual contact-sheet reviews pass. The immutable full milestone gate remains
required.

## Product and implementation

The baseline-to-tip production diff is bounded to build1.0(3), phone Start/Help
presentation, recovery dismissal, selected-tab accessibility visibility, localized
Reset on both platforms and name-neutral Watch next-server wording. Scoring,
service calculation, persistence, purchase, gesture timing and reset callbacks
remain unchanged. All twenty version/build settings and exact installed-version
assertions consistently require1.0(3).

The requested recovery heading and three action labels share a full-width center.
The first-only decorative glyph no longer shifts the gesture entry. Native labels
measure wrapping at the proposed width, use preferred Dynamic Type without text
shrinking, and retain semantic opaque surfaces. Buttons/Links keep their original
roles, callbacks, labels and identifiers with44pt targets. Primary demo artwork
stacks above text at accessibility sizes. Help retains the original NavigationLink
and Back behavior; temporary native-button experiments and diagnostics are removed.
Selection-bound accessibility visibility repairs the retained iOS17 navigation
container after tabs without recreating state. Legal links retain destinations and
Link roles in a vertical layout. Recovery dismissal uses a standard44pt xmark,
localized Close accessibility name/ID, unchanged dismissal and Escape behavior.

Final visual self-review found two additional content defects. Both catalogs now
contain explicit13-language Reset resources. Watch next-server copy uses a
name-neutral label around the original literal display name. Earlier C1 deferral is
superseded by this fix. No supported locale or product behavior was removed.

## Verification quality and environment

The test diff adds actual native captures, real rendered-theme pixels, measurable
centering/reachability, all-language largest-text Help, installed localized Watch
copy and actual practice1:0→localized Reset→0:0. The original six native audit
categories and strict occluded-text handling remain unchanged. Original StoreKit
setup/assertions remain. The finite minimum-Watch scroll budget increases24→64
short drags while preserving the clear/hittable predicate and immediate exit.

Every themed phone capture checks five opaque page-margin RGB means: Dark below96,
Light above160, in addition to the appearance getter. Setting Dark and rebooting
only the reserved owned Simulator initializes actual theme rendering; original
style/boot state is restored. No shipping override, erase, foreign device or global
service restart is used. The owner reports Simulator cleanup; relevant owned
runtime/device endpoints were explicitly confirmed available. Raw failures remain
separate from subsequent passes.

Current-source fresh minimum-phone4/4 and minimum-Watch492/492 definitions/942
invocations pass, exit0, zero failed/skipped/expected/native runtime warnings.
Current-Watch also passes498/498 definitions/948 invocations, exit0, all zero
failure/skip/expected/runtime-warning counts. Complete current-phone20/20 also
passes exit0 with those same zero adverse counts, including all26 reset, all26
largest Help and all26 recovery language/theme pairs. Both gallery4 native
bundles also pass14/14 and2/2 with all zero adverse counts.
The exact unchanged full milestone command still requires its actual result. Older67f
phone19/19 and earlier Watch supplements are historical, never substitutes for
changed-source results. The full gate runs both complete platforms; no M28 reuse
or native-contrast exception applies.

The additional full current StoreKit unit probe remains raw FAILED19/21
definitions/28 of30 invocations, identically reproduced at the baseline on the
same runtime/toolchain. The two bounded synthetic error/storefront findings are P2;
see [exact evidence](storekit-current-runtime.md). Production StoreKit code and
original test expectations remain unchanged. This failed extra probe is never
credited as a passing component; the mandatory configured full gate must pass.
Actual current-device acquisition/restore/network/currency remain mandatory M29.

## Materials, privacy and coverage

Strict active-material validation requires complete shipping-file membership and
hashes,210 unmodified native attachments,28 separate creative compositions and
14 locales. It deliberately rejected the stale67f gallery after catalog fixes; the
completely new f097 gallery4 pair, import/composition/site preparation and all42
final contact reviews now pass. No screenshot is generated or reconstructed. Capture scripts reserve explicit managed UDIDs,
reject reused outputs/changing source and restore appearance/boot state.

The selected illustration retains the generated directions/refinement and exact
prompts. It illustrates fingertip contact; localized composition text explains
two contacts per series and one/two/third-series selection/cancellation. It does
not prove real recognition. Site/metadata/review materials remain local drafts,
with no uniqueness/guaranteed recognition/phone-gameplay claims. Existing factual
format/history/offline/legal/purchase statements remain. Browser layout/palette
proof has explicit system-theme limitations; final53-file HTML/CSS identity binds it
to the final prepared site without claiming a new browser run. Authenticated ASC
Data Not Collected and52 live URL
readbacks are GET-only, with no private-key contents in evidence.

The typed inventory retains existing requirements and adds REL-1301–1308.
Applicable coverage counts are functional34, ui-ux22, content13, accessibility8,
product19, release32, exactly once per owning record. Physical requirements remain
PENDING_M29, not VERIFIED. The six ordered records are interim digital Builder
records; M29 completes final current records before M26. No generic final-coverage
validator is changed. No upload, reply, submission, pricing or site publication is
part of this milestone.

## Closing checks

`git diff --check`, production-tree cleanliness during frozen execution and
`python3 Scripts/verify-localizations.py` pass. Final development `make static` and `Scripts/project-status.sh validate` pass
exit0 after final material import/review. [Preflight](preflight.md) records source,
commands and the bounded cache/device preparation. These do not replace the
unchanged immutable milestone gate. Optional SwiftLint/SwiftFormat/Shellcheck are disabled by configuration;
none is claimed run, and no additional problem scanner is configured. The handoff
must record exact gate SHA/command/exit/report and native counts, followed by DONE
static/status/continuity checks. Failed/interrupted attempts remain in
[work-log.md](work-log.md), with all physical work in the [M29 inventory](M29-hardware-inventory.md).

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
