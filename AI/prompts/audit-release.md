# Audit — release, App Store, privacy, and monetization

Two uses share this subject matter. Inside the `Final Product Polish` milestone it is
the sixth domain run by the existing Builder session, and that Builder repairs what
it finds. As the optional independent release audit it is run later by the Release
Auditor defined in `AI/WORKFLOW.md`, in a fresh session, and repairs nothing.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then PRODUCT, ARCHITECTURE, DESIGN,
   the release schema, and the diff since the last shipped version. The independent
   Release Auditor also reads the candidate-bound report and checklist; during Final
   Product Polish those are created only after this domain, by release verification.

The permission, monetization, privacy, store-presence, and release-hygiene domains
of `Config/release-requirements.v3.tsv` are the maintained inventory here. That
inventory is minimum maintained coverage, not the limit of what to inspect. Make
every question conditional on what this product actually does and on its configured
distribution channel, and record a capability this product does not have as
`INAPPLICABLE` with a reason, not as a finding. Do not invent data collection the
app does not perform, and do not demand App Store evidence from an internal build.

Complete every applicable `release` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- Shipping configuration that still carries a debug flag, a test endpoint or
  credential, a development toggle, a reachable debug screen, or placeholder content.
  The premium override in `AI/ARCHITECTURE.md` is the one sanctioned construct here:
  it is compiled out rather than merely hidden, so finding it in the sources is not a
  finding, and finding it outside `#if DEBUG` is. It also does not answer REL-1007 —
  App Review receives a Release build, so gated functionality still needs a sandbox
  account or a promo code in the review notes.
- Bundle identifier, marketing version, build number, entitlements, and channel
  policy that do not match the intended release.
- StoreKit: product identifiers and loading, price presentation, purchase success,
  cancellation, pending and failed states, repeated taps, restore, and entitlement
  refresh on launch. Price presentation includes the comparison, the saving, and the
  offer terms, each checked against the products the store actually returns and in a
  second storefront as well as this developer's own.
- Monetization quality, not only its correctness: whether the free and paid boundary
  is one a person could predict, whether the paid value is shown before the paywall
  asks for money, whether purchase, restore, pending, and failure are finished
  surfaces rather than minimal ones, and whether every price, period, and saving is
  the localized string the store returned instead of a number the app formatted.
- Privacy: the manifest against real networking and required-reason API use, what is
  collected and logged, transmission, deletion, policy links, and purpose strings.
- Permissions: requested only when needed, explained before the system prompt where
  that helps, and usable after denial, revocation, or a change in Settings.
- Store presence the build itself must satisfy: the support and privacy policy URLs
  resolve and describe this app, the age rating matches what the app actually
  contains, and nothing the app says about itself is misleading.
- The published site: whether every in-app and App Store link resolves, whether the
  privacy policy describes THIS app and agrees with the nutrition labels, whether the
  terms page still links to Apple's Standard EULA, and whether any page reached a
  release still carrying placeholder copy.

The App Store listing is out of scope, and "App Store" in this milestone's title means
the release and compliance correctness of the application, nothing more. The listing's
description, subtitle, keywords, promotional text, What's New, screenshots and their
captions, and every translation of those are produced in App Store Connect by a
separate workflow. Do not write them, do not improve them, and do not create a file to
hold them. Their absence is not a finding at any severity — not P0, not P1, not P2 —
and the release gate never waits on them.

## Then, according to which session this is

As the sixth Final Product Polish domain, fix the valid P0 and P1 findings in this
session and rerun the affected tests. Record the outcome in the Release / App Store /
Privacy / Monetization section of `AI/audits/<ID>-final-polish.md`. The orchestrator
then runs the one targeted re-audit and strict release verification for this same
milestone; do not start another session, milestone, pass, or domain record here.

As the independent audit, require the release report to name the exact candidate and
`READY_FOR_HUMAN`, read its `**Human checklist:**` line, and treat every outstanding
row as unperformed, because it is. Write a new audit from the release audit template
and use only its advisory verdicts. Change nothing in the candidate, the gate state,
or the records it audits.

Neither session uploads, submits, pushes, publishes pricing, edits App Store Connect,
releases a version, or claims that the application is approved for release. The
developer decides what happens next.

For watchOS Watch-only, exercise the smallest supported Watch screen, Digital Crown
where used, supported text sizes and VoiceOver, background/foreground recovery, and
independent operation without an iPhone app. Check readable legal/support content
on the Watch. HealthKit, complications and background modes apply only when approved.
REL-208 and REL-209 are INAPPLICABLE with a Watch-only reason; iOS still verifies
them. Missing hardware never makes an applicable requirement inapplicable.
