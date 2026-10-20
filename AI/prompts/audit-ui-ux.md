# Audit — user interface and experience

The second domain inside the `Final Product Polish` milestone. The same Builder
session that completed the functional domain audits and fixes this one, records it in
the consolidated final-polish record, and then continues to Content / Copy. Judge the
product as one coherent experience, not as a collection of screens.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, this milestone's contract, and the
   contracts and concise handoffs of the milestones it depends on.

Inspect the running app in Simulator; reading source alone is not enough when the
app can be launched. Drive it with a specialized iOS interface or view-performance
tool where this session has one and the surface calls for it, and with the Simulator
and Instruments directly where it does not — neither is a prerequisite for this audit,
and an absent tool is named rather than treated as a pass.

The interface-state, appearance, and layout domains of
`Config/release-requirements.v3.tsv` are the maintained inventory here. That
inventory is minimum maintained coverage, not the limit of what to inspect: walk the
product as a user and report what the rows never anticipated.

Complete every applicable `ui-ux` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- Each applicable state on the screens that matter: first launch, populated, empty,
  loading, error, disabled, permission denied, and free against subscribed.
- Layout on the smallest supported screen, in every supported orientation and
  appearance, and at the largest Dynamic Type size, with realistic content lengths.
- Clipping, truncation, overlap, controls the keyboard hides, and content that
  becomes unreachable once real data fills the screen.
- Unclear information hierarchy, an ambiguous primary action, unnecessary steps, and
  navigation that goes somewhere the user did not intend.
- Missing feedback, unconfirmed destructive actions, dead ends, and components that
  behave differently on two screens.
- Screens that look default rather than designed — the visual personality
  `AI/DESIGN.md` states is nowhere in evidence, or spacing, type, and component use
  differ between screens that the design says should match.
- An action with no acknowledgement, feedback slow enough to read as a defect, or a
  change of screen or major state with no transition where the design asks for one.
- Animation and haptics that decorate instead of explaining, that are missing where
  the design requires them, or that delay a result the person is waiting for.
- Visible jank: dropped frames while scrolling, loading images, or animating, and
  anything that stutters on the smallest supported device.
- A delight opportunity `AI/DESIGN.md` records that the shipped app never delivers, a
  signature moment weaker than the design claims, and a premium surface that reads as
  unfinished where the product asks a person for money.
- Decorative clutter, and artwork that reads as generic, stock, or obviously generated;
  an illustration or icon style that changes between screens; and an asset that crops,
  scales, or renders badly in a supported size or appearance.
- Divergence from `AI/DESIGN.md`, including any pattern it prohibits.

## Report and fix

Do not redesign the visual identity from personal preference, do not replace a
native pattern without a concrete user benefit, and do not raise a spacing
preference as P1. "Generic" is a finding only where the result diverges from what
`AI/DESIGN.md` states or leaves the hierarchy unclear; taste is not a defect, and
this audit does not restyle a product it merely likes less. The absence of
custom imagery is not a finding: a clean native screen can be better than an
illustrated one, and adding artwork to a screen that is already resolved is the defect
this audit exists to catch rather than a fix it recommends. Where jank is real,
measure it before changing anything, with a profiling tool if the session has one.
An absent capability is recorded `INAPPLICABLE` with a reason, not as a finding.
Fix the valid P0 and P1 findings here, and a P2 only where the result is clearly
better and low-risk. Record the outcome in the UI / UX section of
`AI/audits/<ID>-final-polish.md`. The orchestrator re-inspects changed screens during
the single targeted re-audit after all six domains; do not start another session,
milestone, pass, or domain record here.

For watchOS Watch-only, exercise the smallest supported Watch screen, Digital Crown
where used, supported text sizes and VoiceOver, background/foreground recovery, and
independent operation without an iPhone app. Check readable legal/support content
on the Watch. HealthKit, complications and background modes apply only when approved.
REL-208 and REL-209 are INAPPLICABLE with a Watch-only reason; iOS still verifies
them. Missing hardware never makes an applicable requirement inapplicable.
