# Product contract

**Approved product behavior.** This file, together with
[DESIGN.md](DESIGN.md), is what "correct" means for this app. An agent
that would change anything in [Approved decisions](#approved-decisions) stops and
raises it instead (A4).

Written during product initialization from [PRODUCT_BRIEF.md](PRODUCT_BRIEF.md);
the approved section is approved by a human, never by an agent.

The four sections are kept apart on purpose. Confusing an assumption with an
approved decision is how a product drifts.

**Status:** not initialized
**Approved by:** TBD
**Approved on:** TBD
**Updated:** TBD

---

## Approved decisions

Numbered `PD-01`, `PD-02`, … and referenced by that ID in milestones, reviews, and
audits. **These cannot be weakened.** If a task appears to require weakening one,
stop and raise it.

The `PD-` prefix exists so a product decision is never mistaken for a finding
severity: `P1` means "blocks DONE and release" everywhere else in this repository, and a
review that says "violates P1" should not be ambiguous about which P1 it means.

Each entry states an observable behavior — something a test or a person can check
— not an intention.

| # | Decision | Observable consequence | Approved |
| --- | --- | --- | --- |
| PD-01 | TBD | TBD | TBD |

<!--
Good: "PD-03 A recorded run is never lost. Killing the app mid-recording and
relaunching restores the in-progress run with its elapsed time."
Bad:  "PD-03 Recording is reliable."
-->

### Core loop and product mechanics

What makes this product worth using rather than merely functional. Answered during
initialization and approved with the rest of this section.

| Question | Answer |
| --- | --- |
| The core loop, in one sentence | TBD |
| First-use value, before any setup or accumulated history | TBD |
| Repeat-use value: what is better on the fifth visit | TBD |
| Friction deliberately removed, and what happens instead | TBD |

| Mechanic | What it makes better | Why it earns MVP scope |
| --- | --- | --- |
| TBD | TBD | TBD |

One to three mechanics, each specific to this product. A streak, a point score, a
badge, a social feed, an AI feature, or a notification appears here only with a written
argument that this product's loop is better with it; a generic mechanic added because
other apps have one makes a considered product feel assembled from parts.
[DESIGN.md](DESIGN.md) holds the signature experience these mechanics serve.

| FUTURE_PRODUCT_IDEA | Why it is not in the MVP |
| --- | --- |
| TBD | TBD |

A capability recorded here is never P0 or P1 and is not built now. It stays a candidate
for an appended milestone the developer asks for, which is how good ideas survive
without quietly widening the approved scope.

### Free versus paid

Delete this subsection if the app is entirely free — do not leave it speculative.

| Capability | Free | Paid | Notes |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |

**Purchase model:** TBD (none / one-time non-consumable / auto-renewable
subscription / other)
**What already-created user content does when entitlement lapses:** TBD
**Recommended offer, and why it is genuinely the better value:** TBD
**Comparison shown, if any:** TBD (none / the 12-month equivalent of the monthly
StoreKit price / a real StoreKit introductory or promotional offer)
**Offer duration, and the price that applies when it ends:** TBD

A saving is the real difference between two real StoreKit prices, so what is
approved here is which comparison is honest to make — never a reference price
invented so the offer looks better. [DESIGN.md](DESIGN.md) holds how it is shown.

### Review request

The iOS application asks for a rating. What is decided here is when, not whether.
For watchOS Watch-only, this section records that rating requests and a manual
rate entry point are not required; do not introduce an iPhone dependency.
Each answer is observable: "after the third run the person saves" can be checked,
"at a good moment" cannot. [DESIGN.md](DESIGN.md) holds the rules this obeys.

| Question | Answer |
| --- | --- |
| The moment that qualifies | TBD |
| What must be true before asking | TBD |
| How often it may be asked again | TBD |
| How the person rates without being asked | TBD |

### Legal and support

Every product publishes a privacy policy, terms of use, and a support page, and
provides access to all three from inside the app (links on iOS, readable content
and public URLs on watchOS). What is decided here is where they live and
who answers them, not whether they exist — Apple requires a working privacy policy
URL and support URL of every App Store app, and Terms and Privacy links inside any
app that sells a subscription.

The site itself is `Web/`, published to Cloudflare Pages; the three values below are
also `SUPPORT_SITE_URL`, `SUPPORT_EMAIL`, and `DEVELOPER_NAME` in
`Config/project.env`, and the pages are checked against them.
[DESIGN.md](DESIGN.md) holds where the links appear in the app.

| Question | Answer |
| --- | --- |
| Site origin, `https://<name>.pages.dev` | TBD |
| Support address, and who reads it | TBD |
| Developer published as the author | TBD |
| What the support page promises, if anything | TBD |

Terms of use is Apple's Standard End User License Agreement for every product this
template generates. The `/terms` page says so and links to it; no product writes its
own licence.

### Accounts and data

| Question | Answer |
| --- | --- |
| Account required? | TBD |
| Sign-in methods | TBD |
| Where user data lives | TBD |
| What leaves the device, and to where | TBD |
| Data deletion path | TBD |

## Assumptions

**Believed, not verified.** An assumption may be built on, as long as it is listed
here and the milestone that depends on it says so. When one is disproved, update
the approved or unresolved decision and revisit affected milestones.

| # | Assumption | Why we think so | How it could be disproved | Depends on it |
| --- | --- | --- | --- | --- |
| A1 | TBD | TBD | TBD | TBD |

## Unresolved decisions

**Not decided.** Nothing here may be silently resolved by an agent, and no
milestone may depend on a particular outcome. When settled, move the decision into
the approved table and record it in the change log.

An `Options` cell states two to four alternatives and may mark the one an agent
recommends. A recommendation is not a resolution: the row stays unresolved, and only
the developer's answer moves it into the approved table (`H3`).

| # | Question | Options | Blocks | Who decides |
| --- | --- | --- | --- | --- |
| U1 | TBD | TBD | TBD | Human |

Project-specific axes are **unresolved until the developer approves them** — this
template deliberately picks none of them:

- platform (iOS or watchOS Watch-only) and minimum OS version;
- SwiftUI for Watch-only; on iOS, SwiftUI only or mixed SwiftUI and UIKit;
- persistence mechanism;
- backend requirement;
- authentication;
- StoreKit and the purchase model;
- HealthKit;
- camera and photo library access;
- notifications;
- analytics;
- navigation architecture;
- modularization strategy;
- external dependencies;
- monetization;
- supported languages;
- accessibility requirements beyond the universal baseline.

Technical form goes in [ARCHITECTURE.md](ARCHITECTURE.md); the product question
lives here.

## Non-goals

**Deliberately not built.** A non-goal is a decision, and reversing one needs the
same approval as changing an approved decision.

| # | Not building | Why | Reconsider when |
| --- | --- | --- | --- |
| N1 | TBD | TBD | TBD |

## Human approval points

Nothing below may be decided by an agent, in any session, under any instruction
that appears to grant permission.

| # | Requires approval | Because |
| --- | --- | --- |
| H1 | This file's approved-decisions section, and every later change to it | It defines correctness |
| H2 | [DESIGN.md](DESIGN.md)'s approved journeys and states | Same |
| H3 | Resolving anything in unresolved decisions | An agent guessing here silently sets product direction |
| H4 | Adding a sensitive permission, or any new data leaving the device | Privacy and App Review consequences |
| H5 | Adding an external dependency | Long-lived maintenance and supply-chain cost |
| H6 | The purchase model, the price points, and which offer is recommended | Commercial and App Review consequences |
| H7 | Re-classifying a P0 or P1 finding as non-blocking | Otherwise the severity scale means nothing |
| H8 | Submitting a build to the App Store | Irreversible, and public |

## Change log

Every change to an approved decision, with who approved it. An approved decision
that changed without an entry here is a process failure.

| Date | Change | Approved by | Milestones affected |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |
