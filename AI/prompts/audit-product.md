# Audit — product experience

The fifth domain inside the `Final Product Polish` milestone. The same Builder
session audits and fixes it, records it in the consolidated final-polish record, and
then continues to Release / App Store / Privacy / Monetization. Judge the application
as its target user would, not as software. `AI/PRODUCT.md` is the approved contract.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, this milestone's contract, and the
   contracts and concise handoffs of the milestones it depends on.

Walk the product from a cold first launch as someone who has never seen it. The
journey and monetization domains of `Config/release-requirements.v3.tsv` are the
maintained inventory here.
That inventory is minimum maintained coverage, not the limit of what to inspect:
the questions below are not rows anyone can tick.

Complete every applicable `product` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- A value proposition that is not obvious, or a first run that delays value instead
  of delivering it.
- A primary action that is unclear, a primary journey longer than it needs to be, or
  an important capability nobody would discover.
- Onboarding that helps nobody, friction with no purpose, and screens carrying little
  user value.
- A free and paid boundary the user cannot predict, monetization that arrives at the
  wrong moment, or a paywall that does not explain what it sells.
- Premium that is not visibly better than free: a paid tier whose value is never
  demonstrated before the paywall asks for money, or a boundary a person would not
  describe the same way after a week of using the app.
- A recommended plan that is not actually the better value, a saving or crossed-out
  price no pair of real prices produces, or an offer whose ending price a person
  cannot see before deciding to buy.
- A rating asked for at a moment the application has not earned — mid-task, after
  an error, during a purchase, or again in the same version — or a request the
  contract promises and nothing ever makes.
- Anything the product contract promises that the application does not deliver.
- Empty and error states that leave the user stuck, and any point where trust is
  damaged.
- The mechanics `AI/PRODUCT.md` approved: whether each one is still doing real work
  for this product, or has become decoration any other app could carry unchanged.
- The signature experience: whether `AI/DESIGN.md` names one, whether the shipped app
  delivers it, and whether it still holds up the third time somebody meets it. A
  design that records `None` has nothing to find here.
- The craftsmanship the product actually carries: whether each bespoke visual, motion,
  or haptic moment strengthens comprehension, emotional quality, differentiation, trust,
  repeat-use satisfaction, or the signature experience — and whether one that does none
  of those is worth what it costs. A plainer screen that answers its moment is the
  stronger result, and a product is not better because it has more custom visuals.
- A first run that reads as a demonstration rather than as the product, and friction
  that exists only because nobody removed it.
- Whether the whole thing feels coherent and finished, and whether there is a reason
  to come back when retention matters.
- A product that is correct in every detail and still reads as assembled rather than
  made — copy, spacing, and choices that look produced by rote. Name what is missing
  in one sentence, then make the smallest change that alters the impression.

## Report and fix

Challenge implementation choices, but never expand the approved scope. A useful
capability the contract does not require is recorded as `FUTURE_PRODUCT_IDEA`: never
P0 or P1, and not built here. A missing capability is P0 or P1 only when the contract
already requires it or the shipped behavior breaks a promise the product makes.
An absent capability is recorded `INAPPLICABLE` with a reason, not as a finding.

Where the correction is a genuinely strategic choice — pricing, the free and paid
boundary, removing a feature, changing the core journey or the positioning, or a new
privacy commitment — do not quietly change the product. Ask the developer one
precise question with two to four options, the trade-off in a sentence each, and the
one you recommend marked Recommended. Everything else in this domain is yours to
decide and correct in this session.

Fix the valid P0 and P1 findings here and rerun affected tests. Record the outcome in
the Product Experience section of `AI/audits/<ID>-final-polish.md`. The orchestrator
re-walks changed behavior during the single targeted re-audit; do not start another
session, milestone, pass, or domain record here.

For watchOS Watch-only, exercise the smallest supported Watch screen, Digital Crown
where used, supported text sizes and VoiceOver, background/foreground recovery, and
independent operation without an iPhone app. Check readable legal/support content
on the Watch. HealthKit, complications and background modes apply only when approved.
REL-208 and REL-209 are INAPPLICABLE with a Watch-only reason; iOS still verifies
them. Missing hardware never makes an applicable requirement inapplicable.
