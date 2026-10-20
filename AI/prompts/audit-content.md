# Audit — content and copy

The third domain inside the `Final Product Polish` milestone. The same Builder
session audits and fixes it, records it in the consolidated final-polish record, and
then continues to Accessibility. Every user-facing string should read as clear,
truthful, and written by one person.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, this milestone's contract, and the
   contracts and concise handoffs of the milestones it depends on.

Read the strings in the resources and then again in the running app, where context
and available width are real. The finished-copy and localization domains of
`Config/release-requirements.v3.tsv` are the maintained inventory here. That
inventory is minimum maintained coverage, not the limit of what to inspect.

The subject is the copy inside the application, plus the pages under `Web/` that the
app links to. The App Store listing is not: its description, subtitle, keywords,
promotional text, What's New, screenshot captions, and their translations are written
in App Store Connect by a separate workflow. Do not audit them, do not draft them, and
do not record their absence as a finding.

Complete every applicable `content` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- Placeholder, debug, or unfinished text anywhere a user can reach.
- Onboarding, titles, buttons, empty states, loading text, errors, alerts, hints,
  settings, and permission explanations that do not say what happens next.
- Terminology, capitalization, and punctuation that change between screens.
- Robotic or obviously generated phrasing, unnecessary jargon, repeated
  explanations, and misleading certainty.
- Copy that reads as produced by rote rather than written: every empty state built
  from the same sentence, hedged instructions that avoid saying what happens, a
  heading that only restates the screen it sits on, and encouragement nobody asked
  for. One person writing this app would not have phrased six screens identically.
- Paywall copy: what is bought, the price, recurring billing, any trial or
  introductory offer, cancellation, restore, and the legal links. The amount that
  will be charged is the number that stands out, and every crossed-out price,
  saving, and offer sentence is read against the real StoreKit values rather than
  against itself.
- A paywall promise the product does not actually keep.
- Text that truncates or breaks layout once translated or lengthened.
- The published pages under `Web/`: they are user-visible copy that this app's App
  Store listing links to, so unfinished text, a privacy policy describing behaviour
  the app does not have, and copy contradicting what the app says about itself are
  all in scope here.

## Report and fix

Change copy only where it materially improves comprehension, trust, consistency,
brevity, or subscription transparency — not because an alternative sounds slightly
nicer. Never invent a performance, health, or outcome claim, and never rewrite legal
text substantially without the developer's approval. Record a capability this product
does not have as `INAPPLICABLE` with a reason, not as a finding. Fix the valid P0 and
P1 findings here and rerun affected tests. Record the outcome in the Content / Copy
section of `AI/audits/<ID>-final-polish.md`. The orchestrator reads changed strings
back in context during the single targeted re-audit; do not start another session,
milestone, pass, or domain record here.
