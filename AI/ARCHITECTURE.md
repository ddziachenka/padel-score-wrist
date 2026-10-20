# Architecture

**A record of decisions, not a prescribed architecture.** This template does not
choose a persistence layer, a navigation pattern, or a module boundary for you —
the right answer depends on the product, and a template that guesses is a template
that has to be fought.

What the template *does* insist on: every choice below is written down, with what
was rejected and why. A decision nobody recorded gets re-litigated in every review.

Record the reasoning and rejected alternatives here so the repository remains the
complete project memory without a separate decision-record system.

**Status:** not initialized
**Approved by:** TBD
**Updated:** TBD

---

## Selected technologies

| Concern | Choice | Rationale | Notes |
| --- | --- | --- | --- |
| UI framework | TBD | TBD | SwiftUI only, or mixed with UIKit — say which, and where the boundary is |
| Swift language mode | TBD | TBD | |
| Concurrency | TBD | TBD | |
| Persistence | TBD | TBD | |
| Networking | TBD | TBD | Or "none" |
| Dependency injection | TBD | TBD | |
| Navigation | TBD | TBD | |
| Testing frameworks | TBD | TBD | |

**Nothing above has a default.** "SwiftUI + SwiftData" is a common answer, not an
assumed one.

## Deployment target

| Field | Value |
| --- | --- |
| App platform: iOS or watchOS Watch-only | TBD |
| Minimum iOS or watchOS version | TBD |
| Why that version | TBD |
| Devices | TBD |
| Orientations | TBD |
| Additional surfaces supported by the chosen platform | TBD |

**Toolchain** — recorded here rather than pinned by the template, so it can be kept
current:

| Field | Value |
| --- | --- |
| Xcode version | TBD |
| Swift version | TBD |
| SDK used to build | TBD |
| Oldest runtime tested against | TBD |

Note the distinction between the SDK you build with and the oldest runtime you
actually test on. Newer APIs need availability guards; the deployment target alone
does not prove they are safe.

## Dependency boundaries

**The layering, and which way dependencies point.** An arrow that goes the wrong
way is a review finding.

```
TBD

Example:
Domain      pure value types; no UI, no persistence, no framework imports
   ↑
Services    protocols + implementations; depends on Domain only
   ↑
Features    screens and view models; depends on Services through injection
   ↑
App         composition root; the only place that knows every concrete type
```

| Layer | May import | May never import | Why |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |

### External dependencies

**The default is none.** Every dependency is a permanent maintenance obligation, a
supply-chain surface, and a build-time cost. Adding one is a human decision (H5).

| Dependency | Version | What it does | Why not Apple's framework | Approval/rationale |
| --- | --- | --- | --- | --- |
| — | — | — | — | — |

If Swift Package Manager is used, note it: `xcodebuild` resolves packages over the
network, which is the one place local verification touches the internet. See
"Failure and evidence rules" in [WORKFLOW.md](WORKFLOW.md).

## State ownership

**Exactly one owner per piece of state.** Duplicated ownership is the most common
architectural defect in a SwiftUI codebase, and it shows up as stale views rather
than as a crash.

| State | Owner | Lifetime | Who may mutate it | Observed by |
| --- | --- | --- | --- | --- |
| TBD | TBD | TBD | TBD | TBD |

| Question | Answer |
| --- | --- |
| Where does app-wide state live? | TBD |
| How does a view get it? | TBD |
| What survives a launch? | TBD |
| What survives backgrounding but not termination? | TBD |
| Single source of truth for each piece of derived data | TBD |

## Business-logic placement

| Question | Answer |
| --- | --- |
| Where does business logic live? | TBD |
| What may a view contain? | TBD |
| What may a view model contain? | TBD |
| How is logic made testable without a UI? | TBD |

The practical test: **could this rule be tested without launching a view?** If not,
it is in the wrong place.

## Persistence

| Question | Answer |
| --- | --- |
| Mechanism | TBD |
| What is stored | TBD |
| What is deliberately not stored | TBD |
| Where large binary data lives | TBD |
| Schema versioning approach | TBD |
| Migration strategy | TBD (see below) |
| Encryption at rest | TBD |
| What deleting user data removes | TBD |

## Concurrency

| Question | Answer |
| --- | --- |
| Model | TBD |
| Default actor isolation | TBD |
| Which types are `Sendable` | TBD |
| What must run on the main actor | TBD |
| How long-running work is cancelled | TBD |
| Known reentrancy hazards | TBD |

## Networking

Delete this section if the app makes no network requests, and say so.

| Question | Answer |
| --- | --- |
| Does the app make network requests? | TBD |
| Client | TBD |
| Base URLs per configuration | TBD |
| Authentication | TBD |
| Retry policy | TBD |
| Timeouts | TBD |
| Offline behavior | TBD (see [DESIGN.md](DESIGN.md)) |
| Certificate pinning | TBD |
| How responses are validated | TBD |

## External integrations

| Integration | Present? | Purpose | Fallback when unavailable | Approval/rationale |
| --- | --- | --- | --- | --- |
| Backend service | TBD | TBD | TBD | TBD |
| Authentication provider | TBD | TBD | TBD | TBD |
| StoreKit | TBD | TBD | TBD | TBD |
| Review request (StoreKit) | TBD | TBD | TBD | TBD |
| HealthKit | TBD | TBD | TBD | TBD |
| Push notifications | TBD | TBD | TBD | TBD |
| Analytics | TBD | TBD | TBD | TBD |
| Crash reporting | TBD | TBD | TBD | TBD |
| AI / LLM | TBD | TBD | TBD | TBD |
| CloudKit / iCloud | TBD | TBD | TBD | TBD |
| Published site (Cloudflare Pages) | yes | privacy, terms, and support pages | TBD | required by the App Store |

The published site is present in every product, so its row records how rather than
whether. It is a separate deployable in `Web/`, not part of the application bundle:
static files with no server code, no forms, and no analytics, published by
`./Scripts/deploy-site.sh` and never by a verification gate. The app links to it and
reads nothing from it, so the site being down degrades a link, never a feature. Its
origin, support address, and developer name are `SUPPORT_SITE_URL`,
`SUPPORT_EMAIL`, and `DEVELOPER_NAME` in `Config/project.env`.

The review request is present in every iOS product, so its row records how rather than
whether. The system prompt is asked for through an injected dependency instead of
being called from a view, and the eligibility state it reads is persisted: no test
can observe the system dialog, so the rule that decides to ask is proved by unit
tests against that dependency, and the product and release audits verify the real
interaction through REL-208. For watchOS, record this integration as inapplicable:
no required rating request or manual rate entry point exists on that platform.

A product that sells anything carries a development-only premium override, and its
shape is decided here rather than per product, because a developer who cannot reach
the paid build on a real device improvises the way in. `DebugPremiumOverride` is
wrapped in `#if DEBUG` and resolves through the single entitlement owner, so no view
ever tests it and turning it off leaves StoreKit behavior exactly as it was. It
persists one flag in `UserDefaults` under `forcePremium`, so a build installed from
Xcode keeps its entitlement across a relaunch. It never creates, alters, or finishes
a transaction — it changes only what the entitlement owner reports, so a sandbox
purchase stays the only evidence that the purchase path itself works. Being an
override it is compiled out of Release, which is what keeps REL-1101 true of every
shipped build and is also the limit of what its tests can show: the suite runs in
Debug in every gate, so it proves the rule and never the absence of the override
from a shipped binary. The source gate, clean Release build, and release audit cover
that absence through REL-1101.

Its unit tests cover four things: the entitlement owner reports paid with the
override on, reports exactly what the store says with it off, calls no purchase or
transaction API in either case, and reads the flag from an injected defaults suite
rather than `.standard`, so a test run cannot leave a developer's simulator
entitled. A test wrapped in `#if !DEBUG` asserting the override is absent is
compiled out of the only configuration any gate ever runs, so it can never fail —
do not write one.

A product that sells anything decides its price presentation here as well, because
the alternative is a number typed into a view. Every price a person sees is the
loaded `Product`'s own localized formatting: no currency symbol, price string, or
locale assumption is written into a source or a string catalog, so a storefront this
developer never opens is right for a reason rather than by luck.

A comparison price is computed, never authored — the twelve-month equivalent of a
monthly product is twelve times the price StoreKit returned for it, a stated saving
is that figure measured against the real annual price, and the rounding goes the way
that can only understate the claim. An introductory or promotional offer is shown
only where StoreKit reports this person eligible, and it carries its duration and
the renewal price that follows it. When a compared product does not load, the
paywall shows the price it has rather than a comparison it cannot justify: one price
that is true beats two that might not be.

Its unit tests cover the arithmetic, the rounding direction, that an ineligible or
missing product yields no comparison at all, and that no price string is assembled
from a symbol and a number. The content, product, and release audits cover the
finished paywall through REL-408, because correct arithmetic alone does not establish
that the charged amount is the number that stands out.

## Security and privacy

| Question | Answer |
| --- | --- |
| What personal data is processed | TBD |
| What leaves the device, and to where | TBD |
| Where secrets live | TBD (**never in the repository**) |
| Keychain usage | TBD |
| Required-reason API usage | TBD |
| Privacy manifest needed? | TBD |
| Data retention | TBD |
| How a user deletes their data | TBD |

`Config/project.env` is committed and must never hold a credential. Record permission
timing and user recovery behavior in [DESIGN.md](DESIGN.md).

The support mailbox is a real data flow, not a footnote: people send it screenshots,
device details, and sometimes more than they meant to. Say who receives it, how long
mail is kept, and that it is used only to answer the request — and say the same thing
on the published privacy policy, because the two have to agree. The Cloudflare
credential that publishes the site belongs in the developer's shell or in
`wrangler login`, never in this repository.

## Modularization

| Question | Answer |
| --- | --- |
| Single target, or several? | TBD |
| Local Swift packages? | TBD |
| Where new files go | TBD |
| Are folders synchronized groups? | TBD |

**A trade-off to decide, not a default to inherit.** One target is usually the
cheaper mistake — splitting later is straightforward, while unsplitting a premature
module boundary is not — but a project with a widget, an app clip, a share
extension, or a shared framework may need several from the start. Decide it here,
with the reason, like every other axis in this document. This template prescribes
no module layout.

## Testing strategy

| Level | Framework | What it covers | What it does not | Where it lives |
| --- | --- | --- | --- | --- |
| Unit | TBD | TBD | TBD | TBD |
| Integration | TBD | TBD | TBD | TBD |
| UI | TBD | TBD | TBD | TBD |

| Question | Answer |
| --- | --- |
| What must always have a test | TBD |
| What is deliberately not unit-tested, and why | TBD |
| How dependencies are substituted | TBD |
| How persistence is tested | TBD |
| Fixtures and their location | TBD |
| Are UI tests in the shared scheme? | TBD (strict integration and release gates run the complete scheme) |

**A test that cannot fail is worse than no test** — it reports success forever. For
each significant test, be able to say what it would catch.

## Migration strategy

| Question | Answer |
| --- | --- |
| How schema changes ship | TBD |
| How a migration is tested before release | TBD |
| Upgrade path from the last shipped build | TBD |
| What happens if a migration fails on a user's device | TBD |
| Is a rollback possible? | TBD |

Data loss on upgrade is a P0. If a build has already shipped, the functional audit
must complete the upgrade smoke test with realistic prior data.

## Rejected alternatives

**What was considered and turned down.** This section prevents the same debate in
every review, and it is the first thing to re-read when a decision starts to hurt.

| # | Alternative | Rejected because | Reconsider when |
| --- | --- | --- | --- |
| R1 | TBD | TBD | TBD |

## Unresolved decisions

Not decided. **No milestone may depend on a particular outcome**, and no agent may
resolve one silently.

| # | Question | Options | Blocks | Who decides |
| --- | --- | --- | --- | --- |
| U1 | TBD | TBD | TBD | Human |
