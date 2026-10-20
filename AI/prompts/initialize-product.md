# Initialize product contracts

Use this in a fresh session before product implementation.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `AI/PRODUCT_BRIEF.md` completely.

Turn the brief into concrete proposals in `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
and `AI/DESIGN.md`. Keep product purpose and behavior in PRODUCT, technical and
privacy choices in ARCHITECTURE, and journeys/screens/states/visual/accessibility/
localization rules in DESIGN.

Before proposing any of that, settle what would make this product worth using rather
than merely functional. Answer six questions from the brief, and challenge the brief
where it has no answer:

- The core loop: what the person does, what they get back, and what brings them back
  to do it again — one sentence.
- First-use value: what the very first run delivers, before any setup, account, or
  accumulated history.
- Repeat-use value: what is better on the fifth visit than on the first, and why.
- Friction to remove: the taps, decisions, waits, and setup steps this product can do
  without, and what happens in their place.
- Three to five candidate mechanics specific to this product — the details that would
  make it more useful, more satisfying, more memorable, or more obviously native.
- One candidate `Signature Experience`: the interaction or moment that should make the
  product feel unusually well made.

Then keep only the mechanics that genuinely fit the approved MVP — one to three of
them — and write down why each earns its scope. Everything else is recorded in
`AI/PRODUCT.md` as a `FUTURE_PRODUCT_IDEA` and is not built. A mechanic borrowed from
other apps is not a mechanic: streaks, points, badges, gamification, social features,
AI features, and notifications belong here only where this product's own loop is
clearly better with one, and "clearly better" is an argument written down rather than
an assumption. Bolting a generic mechanic onto a product that did not need it is the
fastest way to make a considered idea feel like every other app.

`AI/PRODUCT.md` records the loop, both values, the friction removed, the selected
mechanics, and the ideas that were not selected. `AI/DESIGN.md` records the
`Signature Experience` and how it behaves. A product with nothing that deserves one
records `None` and the reason: what is wanted is a product that feels made on purpose,
not a feature quota, and an invented signature moment is bloat wearing the word.

Then name this product's `Delight Opportunities` — normally two to four, and no more for
an initial product. Each is a moment where a bespoke visual treatment, an illustration,
motion, a haptic, or a micro-interaction would materially improve comprehension,
personality, feedback, or delight. The signature experience is the first candidate; the
rest are drawn from the first-value moment, an important empty state, a completed result,
the core repeated interaction, the paywall where there is one, meaningful progress, and a
destructive or recovery action whose feedback carries the reassurance. `AI/DESIGN.md`
records them with the treatment each one is worth. They are opportunities rather than
features: for most moments the simplest native UI is the better answer, an empty table is
a valid answer, and no artwork or animation is proposed because the section exists.

Ask separately what this product can do especially well because it is an iOS app. App
Intents and App Shortcuts, Siri and Spotlight, widgets and controls, Live Activities,
deep links, notifications, share and export, the system pickers, and native haptics are
opportunities to weigh, never a list to satisfy. Propose one only where it carries clear
user value for this product. Each one that survives becomes scope inside a milestone the
plan already needs, or an unresolved decision the developer settles; each one that does
not is a `FUTURE_PRODUCT_IDEA` like any other, and none of them generates a milestone of
its own.

Decide everything the brief and these contracts can settle, and propose it rather than
asking. What genuinely belongs to the developer goes in the unresolved decisions of
the document that owns it, written so it can be answered in one reading: the
Options column offers two to four real alternatives, the one you recommend is marked
Recommended, and a few words say why. Resolve none of them, and let no milestone
depend on a particular outcome.

Then create small dependency-ordered milestone files from the milestone template.
Use only the five uppercase states, begin with `PLANNED`, and make dependencies
testable. Size each one so a single Builder session can carry it to `DONE`; do not
add a field or a criterion that makes a milestone depend on a second session. Do
not write application code.

Include managed simulator preparation in M00: inspect installed device types and
runtimes with `xcrun simctl list -j`, choose identifiers compatible with the approved
deployment target, pass `--simulator-device-type` and `--simulator-runtime` to
`configure-project.sh`, and run `make simulator-setup` before build/test gates.
New products default to managed mode; do not reuse another project's device.
Choose `--platform iOS` or `--platform watchOS` from the approved brief. For watchOS,
use the modern Xcode Watch-only App template: one executable Watch target and its
Xcode packaging container, a shared scheme building both, and tests for the Watch
app. Keep the container’s version/build synchronized with the app. Configure
APP_TARGET and BUNDLE_IDENTIFIER for the Watch app, not the container. Pin a
compatible watchOS runtime and Watch device type; no paired iPhone simulator is
needed. HealthKit, complications and background modes are product scope only.

For Watch-only design, settle small-screen layouts, Digital Crown interaction,
VoiceOver, supported text sizes, lifecycle recovery, and independent operation.
Legal and Support remains a required milestone: readable on-watch content with
public URLs and contact details replaces an assumption of an iOS browser.

For iOS, exactly one implementation milestone owns the review request, titled
`Review Request` and carrying the next sequential ID like any other. Generate it
for every iOS product: asking for a rating is a decision the template already made, and
what initialization decides is the qualifying moment, not whether there is one. It
depends on the milestone that delivers that moment, and being an implementation
milestone it is already behind the first final audit. Its scope is the eligibility
rule, the state that rule persists, the manual entry point, and unit tests over the
rule — the answers in `AI/PRODUCT.md` and the rules in `AI/DESIGN.md`, not a new
journey and not a screen of its own.

watchOS does not generate Review Request. Its product, architecture and design
sections record the platform exception; REL-208 and REL-209 are INAPPLICABLE with
a specific Watch-only reason, never silently omitted.

Exactly one implementation milestone owns the legal and support links, titled
`Legal and Support` and carrying the next sequential ID like any other. Generate it
for every product: Apple requires a working privacy policy URL and support URL of
every App Store app, and Terms and Privacy links inside any app that sells a
subscription, so what initialization decides is where the links live, not whether
there are any. Its scope is the four pages in `Web/` written for this product, the
three site values in `Config/project.env`, the settings or about surface that carries
all three links, and the paywall's Terms and Privacy links when there is a paywall.
Terms of use is Apple Standard EULA for every product — the `/terms` page links to
it and no product writes its own licence. It depends on the milestones that build the
surfaces it adds links to, and publishing the site stays a human step that no gate
performs.

No milestone of its own owns the development-only premium override. The milestone
that delivers the entitlement source of truth delivers the override with it, in the
same session: it is one flag and one seam, too small to size a session around, and
building both together is what makes it resolve through the single entitlement owner
instead of becoming a check a later session retrofits into views. A product that
sells nothing has no override to build, and no milestone gains scope.

No milestone of its own owns price presentation either. The milestone that delivers
the paywall delivers its price presentation with it: which offer is recommended, the
comparison it is measured against, and the offer terms are three answers on one
screen rather than a session's worth of work. The price points stay an `H6` decision
the developer approves; what initialization proposes is how they are shown. No
milestone file, acceptance criterion, or design answer states a price — every price
comes from StoreKit at runtime — and a product with no genuine comparison to make
presents its actual price plainly instead of decorating it.

The milestone plan ships one language, English, however many the brief hopes for. What
the milestones settle is the structure a translation needs — resources, expansion
allowance, plural handling, right-to-left — and `AI/DESIGN.md` records those answers.
The translations themselves are not milestone work: which languages a product adds is
decided after the developer has verified the finished build on a real device, and each
one is then built in its own worktree as `AI/WORKFLOW.md` describes. Do not generate a
milestone for a translation, and do not make any milestone depend on one.

Then append exactly one final milestone after every implementation milestone, using
the next sequential ID rather than a hard-coded one, because how many implementation
milestones a product needs varies:

```text
Final Product Polish -> AI/prompts/final-polish.md
```

Make the boundary structural: this milestone depends on every implementation
milestone that must be complete before release, so it cannot start over unfinished
implementation. It is one Builder session end-to-end like every other milestone and
is always the last milestone in the generated plan.

The contract carries `**Audit prompt:** AI/prompts/final-polish.md` and
`**Audit record:** AI/audits/<ID>-final-polish.md`. Its acceptance criteria require
one ordered pass through Functional Correctness, UI / UX, Content / Copy,
Accessibility, Product Experience, and Release / App Store / Privacy / Monetization;
same-session correction of every valid P0/P1; only clearly beneficial low-risk P2
changes; one targeted re-audit of changed behavior; successful
`make milestone ID=<ID>`; and `make release CANDIDATE=<verified-full-SHA>` against
that exact verified commit, ending at `READY_FOR_HUMAN`. It writes one consolidated
record from `AI/templates/final-polish-audit-template.md`, not six domain records.
Require complete typed coverage of every applicable domain/channel row in
`Config/release-requirements.v3.tsv`, with no required environment missing.
Do not create that record now.

This final milestone closes the plan you are generating now and starts nothing after
it. Work requested later is appended then as a new milestone; do not anticipate it
here. A later release candidate uses an appended `Release Readiness Revalidation`
milestone and `AI/prompts/final-release-readiness.md` without changing the original
Final Product Polish record.

Update the six fields in `AI/PROJECT_STATUS.md`, then run `make template-check`
and `./Scripts/project-status.sh validate` and fix what either reports: the second
checks the milestone graph and status fields you just wrote, which the first M00
gate would otherwise reject after the developer approved them. Then stop for the
developer to approve the direction. Do not infer approval.
