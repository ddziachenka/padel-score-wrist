# Audit — accessibility

The fourth domain inside the `Final Product Polish` milestone. The same Builder
session audits and fixes it, records it in the consolidated final-polish record, and
then continues to Product Experience. Accessibility is judged on its own, not as a
by-product of visual polish.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, this milestone's contract, and the
   contracts and concise handoffs of the milestones it depends on.

Use the Simulator's accessibility settings and Accessibility Inspector where they
are available. The accessibility domain of `Config/release-requirements.v3.tsv` is
the maintained inventory here, alongside the accessibility section of `AI/DESIGN.md`.
That inventory is minimum maintained coverage, not the limit of what to inspect: run
each primary journey with the assistive technology actually turned on.

Complete every applicable `accessibility` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- A primary journey VoiceOver cannot complete, or completes only in an illogical
  focus order.
- Controls without a meaningful name, value, or state; decorative images that are
  still announced; meaningful images that are not.
- Grouping that reads as noise, and modals or sheets that do not move focus.
- Content that clips, overlaps, or becomes unreachable at the largest accessibility
  text sizes.
- Contrast below the standard `AI/DESIGN.md` sets, and anything conveyed by color
  alone.
- Tap targets below the platform minimum, and custom controls, charts, or forms with
  no accessible equivalent.
- Reduce Motion and Reduce Transparency that are declared but not honored.
- A custom or signature interaction that assistive technology cannot reach, complete,
  or skip — the more deliberate the moment, the more it has to work for everybody.
- Bespoke visual and motion work that assistive technology reads wrong: meaningful
  artwork with no accessible equivalent, decorative artwork announced as content, meaning
  carried only by animation or color, a bespoke moment that ignores Reduce Motion, and
  real UI text baked into artwork instead of staying localizable text.

## Report and fix

Each P0 or P1 names the affected user, the screen or journey, how it was inspected,
the concrete impact, the expected accessible behavior, and how the correction was
validated. Do not demand light mode from an approved dark-only product, landscape
from a portrait-only one, or localization from a single-language MVP.
An absent capability is recorded `INAPPLICABLE` with a reason, not as a finding.
Fix the valid P0 and P1 findings here and rerun affected tests. Record the outcome in
the Accessibility section of `AI/audits/<ID>-final-polish.md`. The orchestrator
re-inspects changed behavior with the relevant setting during the single targeted
re-audit; do not start another session, milestone, pass, or domain record here.

For watchOS Watch-only, exercise the smallest supported Watch screen, Digital Crown
where used, supported text sizes and VoiceOver, background/foreground recovery, and
independent operation without an iPhone app. Check readable legal/support content
on the Watch. HealthKit, complications and background modes apply only when approved.
REL-208 and REL-209 are INAPPLICABLE with a Watch-only reason; iOS still verifies
them. Missing hardware never makes an applicable requirement inapplicable.
