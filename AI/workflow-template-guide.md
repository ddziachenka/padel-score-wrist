# iOS AI project template

**Workflow policy:** `solo-workflow/2`

A local-first iOS and Watch-only watchOS development system for one indie developer working with Claude
and Codex. Development is milestone-driven, and one AI session takes one milestone
from start to `DONE` and then stops.

- Everything builds, tests, and verifies on this Mac. There is no cloud CI.
- GitHub is storage and synchronization, never a verifier.
- No pull request, protected branch, or mandatory hook is part of the workflow.
- Independent review stays optional and never blocks a milestone.
- Final quality is one Final Product Polish milestone with six ordered domains.
- App Store publication stays manual, and stays yours.

## Core model

```text
PRODUCT_BRIEF
    → initialize the product: PRODUCT + ARCHITECTURE + DESIGN + milestones
    → you approve the direction
    → M00 connects a real Xcode project and proves the harness
    → M01 → DONE → M02 → DONE → ...
    → Final Product Polish in one session:
      functional → UI/UX → content → accessibility → product → release
      → fixes → one targeted re-audit → exact release verification
    → READY_FOR_HUMAN
    → your review → Product > Archive → Organizer → you distribute
```

The six final domains are methods inside the last milestone, not six milestones or
sessions. Their one Builder session fixes blocking findings before it verifies the
candidate.

A commit saves progress. A push backs it up or synchronizes it. Neither claims that
the code is verified. There is no CI, pull-request requirement, protected-branch
assumption, mandatory hook, or pre-push gate.

## The three prompts you need

Once the repository is set up, three short prompts drive the whole application
lifecycle. Send each to a fresh Claude or Codex session; the session reads the
repository's own instructions and supplies the rest.

### 1. Initialize the product

Use this once, after you have filled in `AI/PRODUCT_BRIEF.md`.

```text
Initialize the product from AI/PRODUCT_BRIEF.md.
Stop when my approval is required.
```

The session turns your brief into `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
`AI/DESIGN.md`, a dependency-ordered milestone plan, and an updated
`AI/PROJECT_STATUS.md`. It stops for your approval instead of quietly making the
product decisions that are yours, and it never infers that approval. Full contract:
[AI/prompts/initialize-product.md](prompts/initialize-product.md).

### 2. Develop a milestone

Use a fresh session for each implementation milestone, and repeat it until Final
Product Polish is next-ready.

```text
Execute the next ready milestone end-to-end.
```

One session owns exactly one milestone: implement → test → self-review → fix →
verify → the configured extra problem scan where one applies → fix and reverify →
`DONE` → stop. It does not pause for a separate reviewer session, and it does not
start another milestone once this one is done. The sequence lives in
[AI/WORKFLOW.md](WORKFLOW.md) and
[AI/prompts/execute-next-milestone.md](prompts/execute-next-milestone.md).

When you want more work after a completed plan, ask for a milestone to be appended and
use this prompt for it too.

### 3. Run final product polish

Use this once, when the generated plan's last milestone is next-ready:

```text
Run the final product polish workflow end-to-end.
```

One Builder session runs Functional Correctness, UI / UX, Content / Copy,
Accessibility, Product Experience, and Release / App Store / Privacy / Monetization
in order. It fixes every valid P0/P1, makes only clearly beneficial low-risk P2
changes, performs one targeted re-audit, writes one consolidated record, verifies the
milestone and exact release candidate, reaches `READY_FOR_HUMAN`, and stops. Full
contract: [AI/prompts/final-polish.md](prompts/final-polish.md).

Every milestone builds and verifies English alone. Translating the finished app sits
outside that milestone lifecycle, has its own prompts, and you send them yourself
once you have reviewed the finished build on a real device and decided which languages
to add — see [localization](#localization-after-the-milestones).

## What you own

The workflow owns implementation, tests, self-review, fixes, and verification. Four
things stay yours:

- **The idea.** `AI/PRODUCT_BRIEF.md` is written by you, in plain language, before
  any session starts.
- **Genuine product decisions**, when a session stops to ask — see
  [when a session stops to ask you](#when-a-session-stops-to-ask-you).
- **The subjective judgement.** No gate can tell you the app is good.
- **App Store publication and the store listing.** Nothing here uploads or submits
  anything, and the listing itself — description, subtitle, keywords, promotional
  text, What's New, screenshots, and their translations — is a separate App Store
  Connect workflow this template does not do and never waits for.
- **Publishing the support site.** `Web/` is written and checked for you; putting it
  on the internet is `make site-deploy`, run by you, with your Cloudflare account.

## Start a project

You need Git, Bash, Make, and the macOS base utilities the scripts name explicitly
(`find`, `sed`, `awk`, `grep`, `shasum`, `perl`, `tar`). Product builds additionally
need Xcode command-line tools, `xcodebuild`, `xcrun`, and `jq`. Nothing is ever
installed for you; a missing tool fails with the reason.

**1. Initialize the copied template.**

```sh
make setup
make initialize OWNER='Your Name' EMAIL='you@example.com'
```

This replaces the template's history with one root commit, removes its remotes,
clears its audit and handoff records, and replaces this README with a short one for
your product — which keeps all three prompts above, verbatim. It installs no hooks and
creates no worktree.

**2. Write `AI/PRODUCT_BRIEF.md`.** Your idea, your users, the MVP scope, the
non-goals, and whatever you have not decided yet. This is the one document no agent
writes for you.

**3. Initialize the product.** Send prompt 1 in a fresh session. It produces the
product, architecture, and design contracts plus the milestone plan, which always
ends with exactly one `Final Product Polish` milestone. The plan
contains a milestone for the review request on iOS: that the app asks for a
rating is settled here, and what the session proposes is the moment it asks. It also
always contains one for the legal and support links, because Apple requires a working
privacy policy URL and support URL of every App Store app — what the session proposes
is where they live, not whether there are any.

**4. Approve the direction.** Read what it proposed and approve it explicitly.
Nothing proceeds on inferred approval.

**5. Run M00.** `./Scripts/project-status.sh next` names it. M00 connects a real
Xcode product to the harness and proves it, and one part is only yours: create the
project or workspace under `App/` with a shared scheme and at least one real test
target. Xcode work is yours; the template does not generate or shape it. If Xcode
offers to create a Git repository for the new project, decline: this repository
already tracks `App/`, and `make static` and every build gate refuse a nested one
there. Then switch the repository into product mode:

```sh
./Scripts/configure-project.sh \
    --project App/YourApp.xcodeproj \
    --scheme YourApp \
    --name 'Your App' \
    --bundle-id com.example.yourapp \
    --simulator-device-type com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro \
    --simulator-runtime com.apple.CoreSimulator.SimRuntime.iOS-26-5
make simulator-setup
```

Use `--workspace` instead of `--project` for a `.xcworkspace`; exactly one of the two
is required, and so is `--scheme`. The identifiers above are examples: select installed
types and runtimes with `xcrun simctl list -j`, add `--distribution internal` if you do
not ship through the App Store, and run `./Scripts/configure-project.sh --help` for
the rest.

New products default to managed simulator isolation: each checkout gets its own
device, and all gates use its UDID. `make simulator-context` returns context for
agent tools. Multi-step UI sessions reserve the device and, for mouse/keyboard
control, the shared desktop; see [Simulator isolation](WORKFLOW.md#simulator-isolation-on-one-mac).
Older projects keep their existing template version; there is no migration step.

Configuring writes `Config/project.env` and sets `TEMPLATE_REPOSITORY="false"`.
Until it runs, `make fast`, `make milestone`, and `make release` correctly report
that there is no application to build. With the project in place, prompt 2 carries
M00 to `DONE` like any other milestone, and it finishes with:

```sh
make milestone ID=M00
```

**6. Then work milestone by milestone**, prompt 2 in a fresh session each time.

**7. Run Final Product Polish**, prompt 3 once its milestone is next-ready. That one
session finishes the generated plan and hands the verified candidate back to you.

## Daily development

```sh
make static
make fast
git commit
git push        # backup and synchronization only
```

`make help` lists every target and is the authoritative map. Four verification
levels matter day to day:

| Level | Command | What it is for |
| --- | --- | --- |
| Fast | `make fast` | Development feedback while you work. Never evidence. |
| Milestone | `make milestone ID=M03` | Evidence that a finished milestone passed, on a clean current HEAD |
| Integration | `make integration CANDIDATE=<full-SHA>` | Only when independently developed streams are combined |
| Release | `make release CANDIDATE=<full-SHA>` | Strict verification of one exact release candidate |

`make static` and `make template-check` are lightweight repository checks that need
no build and no simulator. Exact semantics for every level are in
[AI/WORKFLOW.md](WORKFLOW.md#verification-levels).

The optional pre-commit hook runs only lightweight static checks:

```sh
make install-hooks
make uninstall-hooks
```

Setup and initialization never install it. No pre-push hook exists.

### Testing the paid build

A product that sells anything gets `DebugPremiumOverride` — a `Force Premium` toggle
that exists only inside `#if DEBUG`, persists in `UserDefaults` under `forcePremium`,
and makes the entitlement owner report a paid user, so a Debug build installed from
Xcode behaves like one across relaunches on a real device. It resolves through the
entitlement source of truth rather than through checks scattered in views, and it
never creates or alters a StoreKit transaction: a sandbox purchase stays the only
evidence that the purchase path itself works.

`make static` fails when the override appears anywhere outside `#if DEBUG`, so it
cannot reach a Release build, and REL-1101 is what a person confirms about the shipped
one. It is not a way to give App Review access to paid features — that is a sandbox
account or a promo code in the review notes.

### Prices and discounts

Every price a product shows is the StoreKit product it loaded, formatted the way
that person's own storefront formats money, and a comparison is computed rather
than typed: the twelve-month equivalent of a monthly plan is twelve times its real
price, and `Save 40%` is the real difference against the real annual one. There is
no other kind of discount here — no crossed-out "regular price" nobody ever charged
to make the offer look better — and an introductory offer always says how long it
lasts and what is charged when it ends. A product with nothing genuine to compare
shows its actual price and nothing else, which is a finished paywall rather than a
missing one.

`make static` fails when a price or a currency symbol is written into a source or a
string catalog — `"$9.99"`, `"4,99 €"`, `"$\(price)"` — because those render
perfectly in the storefront you develop in and wrong in every other one, and nothing
else in the project would notice until the content audit. REL-408 is then what a
person confirms about the finished screen, since no offline check can see which
number it leads with.

## Milestones and review

**One AI session = one milestone, end to end.** That session implements, tests,
self-reviews, fixes what its own review finds, verifies, hands off, sets `DONE`, and
stops. Self-review and its corrections belong to that same session.

When the milestone changes what a person sees or does, that self-review includes a
craftsmanship pass — hierarchy and consistency with `AI/DESIGN.md`, interaction
feedback, the loading, empty, error, and success states, accessibility, motion,
haptics, and friction worth removing — and the session judges the result in the
running app rather than in the diff. It is proportional: a backend or model change
says so and moves on, and there is no polish milestone afterwards.

At the few moments that matter, that pass also asks whether a bespoke illustration, a
piece of motion, a haptic, or a small interaction would genuinely make the product
clearer or nicer to use — and most of the time the answer is that plain native UI is
better, because premium means resolved rather than decorated. `AI/DESIGN.md` records the
two to four moments worth it as `Delight Opportunities`, and anything built for one is
judged in the running app before it is kept. Design and image-generation tools are used
where a session happens to have them and they help; none is required, and nothing here
needs a Figma file, a design URL, an API key, or an image provider.

A milestone has exactly five states — `PLANNED`, `IN_PROGRESS`, `REVIEW`, `DONE`,
`BLOCKED`. `REVIEW` is transient and belongs to the same session; it exists to give
the gate a stable committed target. Commit the implementation, set `REVIEW`, then
verify the clean current HEAD:

```sh
make milestone ID=M03
```

The gate refuses mutable input, records the branch and exact SHA, and writes local
evidence under `.artifacts/milestone/`. Any later session can reproduce an earlier
candidate without switching the primary checkout:

```sh
make milestone ID=M03 CANDIDATE=<full-SHA>
```

The same session then records that evidence in its handoff and sets `DONE`.

Independent review is optional. It runs in its own session, it is not a milestone
state, and it never blocks `DONE`; its P0/P1 findings return the milestone to
`IN_PROGRESS` for a new Builder session. Any extra audit or scanner you choose to run
yourself is assurance you opted into, not a step in the milestone state machine. An
external impediment uses `BLOCKED`.

### Final Product Polish and release readiness

Product initialization appends exactly one last milestone, `Final Product Polish`.
Prompt 3 runs its six domains in the required order inside one Builder session. The
session fixes every valid P0/P1, bounds P2 work, performs one targeted re-audit, and
writes `AI/audits/<ID>-final-polish.md`. It then runs milestone verification and
strict release verification against the same exact SHA, stops at
`READY_FOR_HUMAN`, and starts no next milestone. This adds no role, milestone state,
or publication step. The severities and convergence rule are in
[AI/WORKFLOW.md](WORKFLOW.md#final-product-polish-and-release-readiness).

### New work after the plan is finished

Final Product Polish ends the plan initialization generated, not the project. The milestone list
is append-only for new scope: ask for a new milestone whenever something more is wanted, and it gets
the next sequential ID, `PLANNED`, a dependency on whichever milestone finished last,
and the ordinary session above on `main`; several follow-ups stay sequential. A later
P0/P1 proving the original acceptance criteria failed is the only correction
exception: reopen that milestone to `IN_PROGRESS` while preserving its prior evidence.
All new scope is appended. `READY_FOR_HUMAN` belongs to the exact commit it was reported for, so once
you change code again the old verdict no longer describes `HEAD`; appending a
`Release Readiness Revalidation` milestone is how you get a verdict for the new
candidate, and it runs the same release readiness procedure.

## When a session stops to ask you

A session decides ordinary implementation questions itself, from the approved
contracts, the acceptance criteria, the existing code, and Apple's conventions. Where
several implementation options are reasonable — structure, state ownership, naming,
navigation, test strategy, error handling, animation detail, a minor UX choice — it
picks the one it would recommend, says so in a line, and proceeds. It sets `BLOCKED`,
names the exact decision needed, and stops only for a genuine product decision:

- product behavior with several valid interpretations;
- monetization or pricing;
- privacy or data collection;
- destructive or irreversible product behavior;
- a major UX direction change that the approved `AI/DESIGN.md` does not resolve;
- a change to the approved scope, or a significant product mechanic;
- anything needing external credentials, an account, or a cost commitment;
- a legal or compliance decision;
- a trade-off where the approved contracts make neither option clearly preferable.

When it does ask, you get one question, two to four real options, the trade-off in a
sentence each, and one of them marked Recommended with a line saying why — and nothing
proceeds until you pick one. A recommendation is a proposal, so silence is never taken
as agreement.

Product initialization also stops for your approval, and `READY_FOR_HUMAN` hands the
finished candidate back to you. Nothing else should routinely interrupt you.

## Worktrees and integration

Every milestone is built in this checkout, on `main`, and committed there. They run
one after another, and `make milestone` refuses to run from any other branch or from
a detached HEAD — so a milestone cannot be verified from somewhere you did not mean
to be.

Optional worktrees may isolate genuinely parallel localization, independent read-only
reviews, or bounded experiments. They never carry milestone implementation or
verification. The supplied helper is specifically for localization after the release
candidate, one language each:

```sh
make worktree LOCALE=de
```

`./Scripts/remove-worktree.sh de` removes one again; it refuses to discard
uncommitted or unpushed work unless you pass `--force`. Independent reviews and
experiments use ordinary Git worktree commands only when isolation earns its cost.

Integration is conditional. Run it whenever independently developed streams are
combined, against the exact commit that combined them; localization fan-in is the
supplied example:

```sh
make integration CANDIDATE=<full-SHA>
```

There is no separate integration role and no integration ceremony after an ordinary
sequential milestone.

## Release

```sh
make release CANDIDATE=<full-SHA>
```

Release verification works from an immutable snapshot of that exact commit. It
requires complete coverage of all six Final Product Polish domains in one record,
one final-polish or revalidation milestone in `REVIEW`, completed dependencies, and
no blocker. Strict static and configuration checks, a clean Debug build, a clean
Release build for a generic device of the configured platform (unsigned; signing happens in your Archive), and
the complete suite must pass. Required audit work cannot be deferred because an
environment is missing.

The gate creates or validates a candidate-bound human checklist under `.artifacts/`
and reports the remaining steps. It binds the full SHA, version/build, and channel;
an invalid or mismatched checklist is `NOT_READY`. Audit coverage comes from
`Config/release-requirements.v3.tsv`; the three subsequent human steps are separate
from that completed coverage. The exact format and verdicts are in
[AI/WORKFLOW.md](WORKFLOW.md#release).

**`READY_FOR_HUMAN` means** those checks passed for the exact candidate and its
human checklist is valid. The Builder records the evidence, marks Final Product
Polish `DONE`, and stops. You then perform:

```text
subjective device review of the verified candidate
    → Product > Archive in Xcode from that candidate
    → inspect and validate in Organizer
    → decide and distribute through the configured channel manually
```

Your checkout usually sits one commit past the candidate by then — the Builder's
`DONE` records. `./Scripts/project-status.sh continuity <candidate-SHA>` confirms that
nothing but those Markdown records changed and that the tree is clean, so an Archive
built from that checkout is built from the verified bytes.

The checklist and report are ignored local evidence. Preserve them in a committed
`AI/audits/release-<version>.md`, written from
[AI/templates/release-audit-template.md](templates/release-audit-template.md), once
human review is complete. Nothing here archives, uploads, submits, publishes, or grants
approval. An independent AI release audit remains optional; publication is your
decision.

## Localization after the milestones

Every milestone builds and verifies one language, English, and `Final Product
Polish` hands you an English candidate. If that is all your app ships, skip this
section.

Otherwise this is the supplied parallel product workflow, and it starts
only after `READY_FOR_HUMAN` and your own review of the finished build on a real
device — which is also when you decide which languages are worth adding. Nothing
routes to these prompts; you send them yourself, once that decision exists. Adding a
language reopens no milestone, invalidates no milestone, and is never part of
finishing one.

Give each language its own branch and worktree, cut from the completed `main`:

```sh
make worktree LOCALE=de
```

```text
main: every milestone DONE, English candidate verified on a real device
    → worktree ../<repo-dir>-de     branch localization/de     one session → commit
    → worktree ../<repo-dir>-ja     branch localization/ja     one session → commit
    → worktree ../<repo-dir>-pt-br  branch localization/pt-br  one session → commit
```

Then send one prompt per language, each in a fresh session started inside that
language's worktree:

```text
Localize the product into German (de).
Follow AI/prompts/add-localization-worktree.md in this worktree only.
```

Region-qualified languages name the region: `Portuguese (Brazil)` and `pt-BR`. The
branch, the worktree, and the website route use that identifier lowercased —
`make worktree LOCALE=pt-BR` refuses and tells you to use `pt-br`, because a macOS
filesystem usually cannot tell the two apart. The app's own resources keep `pt-BR`.
Those sessions can run at the same time, and none of them merges anything. Each one
translates, reads its own work again, runs the app in its language, fixes what it
finds, and commits once.

When they have all stopped, they are combined back into one branch:

```text
localization/de    ─┐
localization/ja    ─┼─→ integration into main → optional cross-language polish
localization/pt-br ─┘
```

Send this from the main checkout:

```text
Combine the finished localization worktrees into main.
Follow AI/prompts/integrate-localization-worktrees.md.
```

That session records every branch and SHA before it touches `main`, applies the
languages one at a time, resolves the shared-file conflicts that parallel work makes
inevitable, and verifies the result the same way any combined stream is verified:

```sh
make integration CANDIDATE=<full-SHA>
```

Conflicts are expected — two languages adding themselves to the same string catalog
entry is normal — and they are resolved by keeping both sides. Taking one whole side
deletes a language, so it is never how one of these is settled. Publishing the site
waits until every language is in.

One optional pass remains, worth running once when several languages ship:

```text
Polish every shipped language against the others.
Follow AI/prompts/polish-localizations.md.
```

It compares the languages against each other — terminology that drifted, a register
that slipped, a screen that only clips in the longest language — which no
single-language session can see. It does not replace the reading each language already
did of its own strings, and it is additional quality assurance rather than a gate.

Do not copy a language between worktrees by hand, and do not use a worktree this way
for anything but localization. The normative rules are in
[AI/WORKFLOW.md](WORKFLOW.md#localization-after-the-milestones).

## Repository memory

```text
AI/
  PRODUCT_BRIEF.md            your idea, in your words — the first thing you fill in
  PRODUCT/ARCHITECTURE/DESIGN the approved product contracts
  WORKFLOW.md                 the normative workflow contract
  PROJECT_STATUS.md           where the work currently stands
  milestones/ prompts/        one contract per milestone; the session prompts
  templates/                  handoff, milestone, audit, and status record formats
  audits/ handoffs/           the records a project writes; they ship empty
Config/     reproducible project and release configuration
Scripts/    local checks and boundary verification
.githooks/  optional pre-commit convenience only
.artifacts/ ignored local reports, result bundles, and release checklists
App/        your Xcode project, added during M00
Web/        the published privacy, terms, and support pages
```

Read [AGENTS.md](../AGENTS.md), [AI/WORKFLOW.md](WORKFLOW.md), and
[AI/PROJECT_STATUS.md](PROJECT_STATUS.md) at the start of an AI session.

## The support site

Apple requires a working privacy policy URL and a working support URL for every App
Store app, and Terms and Privacy links inside any app selling a subscription. The
pages are part of the template so the content and release audits can verify them.

[Web/](../Web/) holds four static pages, deployed to Cloudflare Pages:

```text
https://<yourapp>.pages.dev/          landing
https://<yourapp>.pages.dev/privacy   Privacy Policy
https://<yourapp>.pages.dev/terms     Terms of Use -> Apple's Standard EULA
https://<yourapp>.pages.dev/support   support and contact
```

Terms of use is Apple's Standard EULA for every product this template generates; no
product writes its own licence. Three keys in `Config/project.env` —
`SUPPORT_SITE_URL`, `SUPPORT_EMAIL`, `DEVELOPER_NAME` — identify the site, and the
Cloudflare Pages project name is the first label of the URL's host, so the site you
publish and the URL you ship in the app cannot drift apart.

```sh
make site-check                 # offline: pages, links, headings, and the EULA link
make site-deploy                # a preview deployment
make site-deploy PRODUCTION=1   # the live site
```

`make static` runs `site-check` every time. Deploying needs
[Wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update/) and
your own Cloudflare account; nothing installs it for you and no verification gate ever
publishes. [Web/README.md](../Web/README.md) covers filling the pages in, previewing them
locally, and adding a language.

## Watch-only applications

Select iOS (the default) or standalone watchOS when writing the product brief.
The developer creates the project in Xcode: watchOS → App → Watch-only App, using
SwiftUI and a test target. Keep Xcode's packaging container; it is not an iPhone
companion. The shared scheme must build the Watch executable and its container.
Keep their version/build values equal. `APP_TARGET` and `BUNDLE_IDENTIFIER` name
the Watch executable, while the release report also records the container identity.

Inspect `xcrun simctl list -j`, then use identifiers actually installed on this Mac:

```sh
./Scripts/configure-project.sh --platform watchOS \
    --project App/YourApp.xcodeproj --scheme 'YourApp Watch App' \
    --app-target 'YourApp Watch App' --bundle-id com.example.yourapp.watchkitapp \
    --simulator-device-type '<installed-watch-device-type-id>' \
    --simulator-runtime '<installed-watchos-runtime-id>'
make simulator-setup
make simulator-context
make fast
```

The existing milestone, integration and release commands remain unchanged. A single
managed Watch simulator is reserved by UDID. Release builds for generic watchOS
without signing; Archive and distribution remain manual. Older configurations with
no APP_PLATFORM still mean iOS. Explicit destinations must match the selected
platform. Changing platform or runtime does not replace an existing simulator binding.

Watch-only does not generate a Review Request milestone or require a manual rating
button. REL-208 and REL-209 must instead carry a reasoned INAPPLICABLE result;
iOS keeps its existing obligations. Legal and Support remains mandatory, including
readable content on the Watch and working public pages. No iPhone app is required
to read them. HealthKit, complications and background behavior are added only when
the approved product needs them. Legacy WatchKit extensions, WatchConnectivity and
iPhone companion workflows are outside this mode.

The template regression suite uses stubs. Only a real product's M00 establishes
that its Watch project builds, tests and runs with the selected Xcode/runtime.

## Updating this template

This section is about maintaining the template itself rather than building a product
with it; `make initialize` replaces this README, and this section with it.

Gate, hook, parser, or shared-library changes require matching regression cases:

```sh
./Scripts/self-test.sh --case <name>   # while you work; --list prints the names
make template-check
make static
make self-test                         # once, on the finished change
```

The first three run while the change is still moving. The full suite runs once against
the final bytes, and again after any later edit, so the commit carries exactly what
passed.

The suite's cases are independent and run concurrently, each in its own process and
temporary repository, at a width taken from this machine. `IOSAI_TEST_JOBS` overrides
it — `IOSAI_TEST_JOBS=1` runs one case at a time and streams every check as it happens,
which is what to use when a case is being debugged. The width changes only how long the
run takes; a failing case fails the same way at any of them.

The self-test uses disposable repositories and Xcode stubs. It proves the template
logic, not a real Xcode build or Simulator run.

`AI/audits/` and `AI/handoffs/` ship empty. The template's own development
history stays in its Git history rather than its tree, so a copied project starts
with no audit or remediation record of someone else's work. The records a project
writes there are evidence about their own recorded commits; they never configure
the live workflow.
