# Workflow

**Policy version:** `solo-workflow/2`

This is the single source of truth for sessions, roles, milestone state, Git usage,
verification, integration, and release. Historical audits and handoffs describe
their recorded commits; they never override this file.

## The workflow

```text
idea → PRODUCT_BRIEF → PRODUCT / ARCHITECTURE / DESIGN / milestones
     → developer approves direction
     → one session: implement → test → self-review → fix → verify → handoff
     → DONE → stop
     → a new session takes the next milestone
     → one Final Product Polish session: six ordered domains → fixes → targeted re-audit
     → exact release candidate → READY_FOR_HUMAN
     → developer decision
```

### Roles

**Builder** implements, tests, self-reviews, corrects, and verifies exactly one
milestone, writes its handoff, and sets `DONE` from that evidence. A Builder may
merge reviewed parallel branches and must run integration verification on the
resulting merge SHA.

**Reviewer** is optional: a separate session that reads the complete diff, checks
every acceptance criterion, reruns the candidate validation, tests the quality of
the tests, and records reproducible findings. It never blocks `DONE`, and the
`## Independent review` section below says when it earns its cost.

**Release Auditor** is an optional independent challenge before submission. The
auditor checks product journeys, privacy, permissions, purchases, accessibility,
localization, upgrade behavior, store-presence rows, and the gate's evidence. The
developer remains the final approver.

## Sessions

One session carries one milestone from its current actionable state to `DONE`, and
then stops. Implementation complete is the middle of a session, not the end of the
session: the same session tests, self-reviews, fixes what that review finds,
verifies, and hands off. Do not start another milestone in the same session — a new
session selects the next one.

### Builder sequence

1. Read `AI/PROJECT_STATUS.md`, run `./Scripts/project-status.sh next`, and select
   exactly one milestone. Read its complete contract, the product, architecture,
   and design sections it depends on, and the existing code you will touch.
2. Set `IN_PROGRESS`, plan briefly, implement the whole scope and only that scope,
   add the tests that fail when the behavior regresses, run the fast checks, and
   commit coherent recovery points.
3. Self-review the entire baseline-to-tip diff.
4. Fix every valid blocking finding, rerun the affected tests, and review the
   correction. Repeat steps 3 and 4 until nothing blocking is known.
5. Set `REVIEW`, commit the final implementation, and from a clean checkout run
   `make milestone ID=<ID>`.
6. If this repository configures an additional problem scanner beyond the optional
   analyzers `make static` already runs, run it now. Its valid findings belong to
   this milestone: fix them, rerun the affected tests, and verify again.
7. Write the compact handoff with the exact SHA, command, exit code, counts, and
   report path.
8. Set `DONE`, update `AI/PROJECT_STATUS.md`, and commit. Validate that commit with
   `make static`, `./Scripts/project-status.sh validate`, and
   `./Scripts/project-status.sh continuity <verified-full-SHA>`.
9. Stop.

`REVIEW` gives the gate a stable committed target. It is transient and belongs to
this same session; a milestone is never parked there waiting for another model to
look at it.

### Self-review

Review what the milestone actually touches: acceptance criteria, correctness,
architecture, state ownership, concurrency, persistence, error, loading and empty
states, accessibility, localization, privacy and security, test quality,
unnecessary scope expansion, and unrelated diff. Only the applicable categories
need detail — judgment proportional to the milestone, not a checklist for a
one-line change.

A milestone that changes what a person sees or does also gets a craftsmanship pass,
proportional in exactly the same way: visual hierarchy and consistency with
`AI/DESIGN.md`, interaction feedback, the loading, empty, error, and success states
that surface can actually reach, accessibility, keyboard and focus behavior,
transitions and animation, haptics, layout at the sizes and appearances the design
covers, friction that could be removed, and consistency with the screens around it.
It belongs to this self-review and this session — never a separate polish milestone
after every feature — and it is what keeps a milestone from stopping at "it works
and the tests pass", which is how an application ends up technically correct and
cheap to use. A milestone with no user-facing surface says so in one line and moves on;
forcing these categories onto a model, data, or infrastructure change produces
paperwork rather than quality.

Where the milestone owns one of the delight opportunities `AI/DESIGN.md` records, or a
moment that deserves to be one, the same pass asks whether a bespoke visual treatment, an
illustration, motion, a haptic, or a micro-interaction would materially improve
comprehension, personality, feedback, or delight. If it would not, the simplest native UI
is the answer and the pass moves on. If it would, choose the medium `AI/DESIGN.md` prefers
— native first, a bespoke asset only where native cannot express it — build it into the
real application, judge it in the state it belongs to, and keep it only where it earned
its place. Premium is not visual busyness: one strong moment is worth more than several
decorative ones, and a screen that needed nothing is finished once it is clear.

Go deeper, and validate harder, when the milestone touches StoreKit or purchasing,
a persistence migration, authentication, sensitive data, permissions, complex
concurrency, backend integration, or release infrastructure. That is more work
inside this session, never a handover to another one.

Self-review is not independent review. It is the Builder reading its own diff, and
it is recorded as that — never as an audit.

### Runtime checks and specialized tools

Meaningful user-facing work is judged on the running application, not on source and
screenshots: build it, launch it, drive the flow this milestone changed, look at the
states that matter, fix what that shows, and re-check once. A one-word copy change
does not need a Simulator session; a new screen, a changed journey, or a state nobody
has seen does. Some behavior the Simulator cannot prove — haptics, permissions,
notifications, camera and photo access, some StoreKit flows, lifecycle behavior, and
how a gesture actually feels — is checked on real hardware by the milestone or final
audit that owns it. If required hardware is unavailable, that owner is blocked (A10).
That boundary is narrow: a still asset or a transition the Simulator renders
faithfully is judged in Simulator.

Bespoke visual and motion work is held to the same rule, more strictly. Such a moment is
not finished because the asset exists in the asset catalogue or the animation compiles:
build, launch, reach the real state, interact with it, look at it, judge the motion and
the feedback in the context they belong to, fix or remove what does not work, and
re-check once. Where the session has a tool that drives the running application, prefer
it; where it does not, this repository's ordinary Simulator path is the fallback. Source
inspection alone does not settle whether a visual moment works.

Performance is judged in proportion too. An ordinary static screen needs a runtime
sanity check and nothing more. A scrolling list, an image-heavy surface, an animated
one, or a screen holding a lot of state is inspected deliberately for dropped frames
and for view updates nothing needs — and, where images and animation carry the surface,
for main-thread work, image decode and scale cost, scrolling smoothness, memory
pressure, layers and effects nothing needs, and continuous animation that keeps the
device awake. Profiling belongs to a problem that was actually observed; optimizing a
screen nobody has measured spends the session's time on a guess and usually costs
clarity as well. Craftsmanship that makes the application feel worse is not
craftsmanship.

Where the session has a specialized iOS skill or tool that applies to the work, use
it: SwiftUI composition, navigation and state ownership; driving the real interface
in Simulator; auditing view performance; runtime profiling; investigating memory
growth; App Intents; restructuring a view that has become structurally unhealthy; a
system visual style, where the deployment target and the approved visual direction
justify it.

The same rule covers a design, image-generation, animation, or runtime-inspection tool
as much as a Swift one: use one where it materially improves the implementation or the
validation of this work. Recognize what this session actually has — a Figma or other
design MCP server, an image-generation capability, a build-and-drive server such as
XcodeBuildMCP, a SwiftUI or iOS skill, a Simulator inspection tool — and reach for it on
the cases that repay it. A design tool is worth opening to explore the signature
experience, compose an illustration, refine a visual hierarchy, check proportions and
layout, build a reusable bespoke asset, or compare a small number of directions where the
direction is genuinely uncertain. It is not worth opening to redraw a screen the approved
design already settles.

No screen has to exist in a design file before it is built in SwiftUI, and nothing here
adds a design-handoff step: code is the implementation source of truth, and a design tool
is an instrument for quality rather than another stage that approves work.

A specialized skill is an accelerator, and it is not a dependency of this template:
the gates here need only the tools `### Repository modes and prerequisites` already
names, and a workflow that assumed an optional skill would break on the first machine
without it. When one is absent the fallback is the ordinary path — read the code, run
the app, inspect the states — and an applicable check that still cannot run blocks
its owning milestone or audit (A9).
Missing design or image-generation tooling is never a reason to block a milestone;
the fallback is native SwiftUI and SF Symbols, or shipping the moment without the asset.
No product configuration names a design file, a design URL, an API key, an image
provider, or a server for any of them, and nothing here assumes which agent implements
the milestone.

Never add a capability to the product because a skill for it exists: `AI/PRODUCT.md`
decides what is built, and a tool is only ever how the work is done. An asset follows
the same rule: a bespoke visual exists because a moment earned one, never because a tool
that could generate it happens to be connected. Never download web imagery into the
application because it looks about right — an asset is original, generated, or clearly
licensed.

### Simulator isolation on one Mac

`APP_PLATFORM` selects iOS (also the default for older configurations) or watchOS
Watch-only. A Watch-only scheme builds the executable Watch app and its Xcode
packaging container; gates validate the built plists and matching version/build.
It needs one Watch simulator, no iPhone companion and no simulator pair.

New products pin `SIMULATOR_DEVICE_TYPE` and `SIMULATOR_RUNTIME` identifiers from
`xcrun simctl list -j` when running `configure-project.sh`; its product default is
`SIMULATOR_MODE="managed"`. Preparation is explicit: `make simulator-setup` creates
one device for the physical checkout and reuses it thereafter. Gates never install
runtimes or create devices. Existing projects using older template versions are not
updated by this workflow. An explicit destination mode remains available for a
purposefully unmanaged environment; it has no isolation guarantee.

The device binding lives in ignored `.iosai-local/simulator.json`, independently of
build caches and evidence cleanup. A persistent worktree prepares its own device.
A temporary immutable candidate uses its publishing checkout's binding and leases,
but validates it against the candidate's committed type/runtime. Do not copy the
binding to another checkout. If configuration changes or a device is deleted, gates
fail without a fallback. Preserve the old binding for diagnosis; deliberately move
it aside before preparing a replacement. Renamed/unregistered devices are never
adopted automatically, and preparation never erases or deletes a device.

`make simulator-context` returns JSON with owner, UDID, runtime, destination and
DerivedData path. `make simulator-status`, `make simulator-boot` and
`make simulator-shutdown` operate on that device. `Scripts/simulator.sh install`,
`launch`, and `screenshot` take an app path, bundle identifier, and output path
respectively. `Scripts/simulator.sh run -- COMMAND ...` reserves the checkout/device
for a synchronous tool and exports `IOSAI_SIMULATOR_UDID` and
`IOSAI_SIMULATOR_DESTINATION`. No tool may substitute `booted` or the first available
device. Never issue `shutdown all`, `erase all`, kill the shared Simulator app, or
restart CoreSimulator while cooperating projects are running.

For a multi-call tool session, acquire with
`Scripts/simulator.sh acquire --pid <live-agent-PID> [--desktop]`, retain the JSON
token, and explicitly release with `Scripts/simulator.sh release <token>`. Use a
long-lived agent/session process, not the transient shell that invokes acquisition.
The reservation covers the complete inspection, not individual clicks. Inside it,
use direct tool calls targeted to the context's UDID; wrappers and gates refuse
nested acquisition. Tools that manipulate the shared mouse, keyboard, focus, or
capture the desktop must also acquire `--desktop` before selecting a window, keep it
through result inspection, and release afterward. `desktop-acquire --pid PID` and
`desktop-release TOKEN` expose the same desktop lease for tools with an existing
device reservation. Always reserve the device before the desktop.

Cooperative leases live in a user-owned directory under `/private/tmp`, shared by
all checkouts. Acquisition of multiple resources is atomic. Busy returns 75 (Make
still returns 2); work on independent code or builds instead of stealing the lease.
A live PID and its start time keep the lease indefinitely. Explicit release, normal
gate completion, or recovery after the owning process dies makes it available again.
`Scripts/simulator.sh leases` shows owners. This coordinates compliant agents; it
cannot isolate CPU, memory, CoreSimulator failures, or a person moving the mouse.

### When verification fails

Decide which of three things happened before changing anything:

- **Caused by this milestone.** Fix it here and verify again.
- **Pre-existing.** Reproduce it at the baseline commit with the same command and
  record that evidence concisely.
- **Environment or tooling.** Diagnose locally. Stop only when the blocker cannot
  be resolved safely.

Never delete, skip, loosen, or rewrite a test to obtain a pass.

### Questions for the developer

Decide implementation questions yourself from `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
`AI/DESIGN.md`, the milestone's acceptance criteria, the existing code, Apple's
platform conventions, and what stays simple to maintain. Where several options are
reasonable, choose the one you would recommend and proceed: SwiftUI structure, state
ownership, which API or library to use, naming, component decomposition, how
navigation is implemented, test strategy, error handling, animation and haptic detail
already consistent with `AI/DESIGN.md`, and a minor UX detail are the session's to
settle, and so is any other reversible implementation choice. Prefer the simplest
high-quality option the approved product allows, say in one line what you chose and
why, and do not stop to present a choice this session can responsibly resolve. A
question asked to look careful spends the developer's attention and returns no
decision.

Interrupt the milestone only for a genuine product decision: user-visible behavior
with several defensible interpretations, MVP scope, monetization or pricing, privacy
or data collection, destructive or irreversible behavior, a major UX direction
`AI/DESIGN.md` does not resolve, a significant product mechanic, a commitment to an
external service, account, or cost, a legal or compliance decision, or a trade-off
where the approved contracts make neither option clearly preferable.

Ask once and ask well: two to four genuine options, the trade-off that separates them
in a sentence each, and exactly one marked Recommended with one short sentence saying
why. Then set `BLOCKED`, name the decision and the options as offered on the
`**Blockers:**` line of `AI/PROJECT_STATUS.md` so the repository carries the question
rather than a previous chat, and wait for that choice before continuing. Silence is
not an answer, the recommendation is not an answer, and beginning a different
milestone instead is not an answer.

## Independent review

Independent review is optional. It is not a milestone state, not a gate, and never
blocks `DONE`. The default is the Builder's own self-review inside the one session
that owns the milestone.

A separate pass is worth requesting when the developer wants a second opinion on
something consequential — purchasing, a persistence migration, authentication, a
backend integration, HealthKit, camera or photo access, complex concurrency, or
release infrastructure. Run it in a fresh session against the already-`DONE`
milestone, using [review-milestone.md](prompts/review-milestone.md) and
[audit-template.md](templates/audit-template.md).

That session reruns `make milestone ID=<ID> CANDIDATE=<verified-full-SHA>`, records
reproducible findings, and never repairs what it finds. A later P0/P1 proving that a
`DONE` milestone did not meet its original acceptance criteria is the narrow
correction exception to append-only history: return that milestone to `IN_PROGRESS`,
keep its prior SHA and evidence intact in its records, and let a new Builder session
add correction evidence and take it back to `DONE`. New scope is always appended as a
new milestone instead.

## Final Product Polish and release readiness

Product initialization appends exactly one `Final Product Polish` milestone after all
implementation milestones. It takes the next sequential ID, depends on every
implementation milestone required for release, and is always last in the generated
plan. The developer starts it with the third canonical prompt: `Run the final product
polish workflow end-to-end.`

One Builder session owns that milestone from `PLANNED` to `DONE`. It reads
[final-polish.md](prompts/final-polish.md) and runs the six specialist prompts as
ordered domain methods inside the same session:

1. Functional Correctness / Bug Hunt
2. UI / UX
3. Content / Copy
4. Accessibility
5. Product Experience
6. Release / App Store / Privacy / Monetization

Each domain gets one full runtime-informed pass. The Builder reproduces and fixes
every valid P0/P1 in the same session, including a concrete blocker noticed outside
the current domain, and reruns affected tests. P2 is non-blocking and is fixed only
when the benefit is clear and the risk and scope are low; every other P2 is recorded
with its disposition. After all domain fixes, the Builder performs one targeted
re-audit of changed behavior. A P2 first noticed there is deferred, and no third pass
or endless polish loop begins.

The six prompts provide depth without creating roles, states, sessions, milestones,
or records of their own. The milestone writes one consolidated
`AI/audits/<ID>-final-polish.md` from
[final-polish-audit-template.md](templates/final-polish-audit-template.md). A session
that only reports findings leaves this milestone undone.

After the targeted re-audit and any configured additional problem scan, the Builder
sets `REVIEW`, commits, and runs `make milestone ID=<ID>`. Without changing code or
configuration, it passes that exact verified full SHA to
`make release CANDIDATE=<verified-full-SHA>`. Release success is
`READY_FOR_HUMAN`, never a `**Status:**` value or permission to publish. The Builder
records both gates, sets the milestone to `DONE`, validates the continuity records,
and stops without starting another milestone or audit cycle.

The developer then completes the human checklist: subjective review,
Product > Archive, Organizer validation, and the distribution decision. Automation uploads,
submits, archives, and publishes nothing. Optional independent milestone review and
the independent Release Auditor remain optional.

This milestone ends the generated plan, not the project. Later requested work is
appended under `### Appending work after a plan is finished`; the original
final-polish record and its candidate remain historical evidence. A later change that
needs another audit gets a new targeted audit milestone. An old `READY_FOR_HUMAN` is
evidence for its candidate SHA and no other. A later configuration change invalidates that verdict
for `HEAD`; so does a later code change. A new candidate needs an appended
`Release Readiness Revalidation` milestone using
[final-release-readiness.md](prompts/final-release-readiness.md).

Findings are graded:

| Severity | Meaning | Blocks the milestone |
| --- | --- | --- |
| `P0` | Crash, data loss, security or privacy failure, unusable critical journey, or wrong entitlement | Yes |
| `P1` | Reproducible defect that must be corrected before release | Yes |
| `P2` | Real but non-blocking polish or edge-case improvement | No |
| `Note` | Observation needing no correction; `P3` in the independent review template | No |

Final Product Polish runs one full pass per domain and one targeted re-audit of all
changed behavior, and is then complete. P2 never blocks, and a P2 raised during the
re-audit is recorded and deferred rather than starting another pass. A personal
stylistic preference is not a defect, and acceptable copy or layout is not rewritten
twice.

A capability this product does not have is recorded `INAPPLICABLE` with a reason,
not as a finding. A useful capability the approved product contract does not require
is classified `FUTURE_PRODUCT_IDEA`: it is never P0 or P1, it does not block the
release, and it is not implemented in this milestone.

[../Config/release-requirements.v3.tsv](../Config/release-requirements.v3.tsv) holds
the maintained inventory each domain covers. That inventory is minimum maintained
coverage, not the limit of what to inspect: the Builder also exercises the running
application and reports what the inventory never anticipated.

## Git and recovery

- Commit whenever a coherent recovery point exists. A commit means saved progress.
- Push when backup or synchronization is useful. A push means nothing was verified.
- Hooks are optional conveniences and are never security or release boundaries.
- The supplied pre-commit hook runs static checks only. There is no pre-push hook.
- Preserve unrelated uncommitted work. Never stash, revert, or clean it for another
  session.

Milestone work is one branch and one checkout: every milestone is developed in the
primary checkout, on the primary branch, and committed there. They run one after
another, one session each, and milestone verification refuses to run anywhere else.
Optional worktrees are useful for genuinely parallel localization, independent
read-only reviews, or bounded experiments. They never carry milestone implementation
or milestone verification evidence, never modify another checkout's uncommitted work,
and never make sequential work parallel by default. The supplied worktree helper is
localization-specific; a review or experiment may use ordinary `git worktree` commands
when isolation is worth the overhead. One agent owns one checkout at a time.

## Milestones

Exactly five `**Status:**` values exist:

| Status | Meaning |
| --- | --- |
| `PLANNED` | Defined and waiting for its dependencies or start |
| `IN_PROGRESS` | Builder is implementing or correcting it |
| `REVIEW` | Transient: a clean committed implementation is being verified inside the Builder's own session |
| `DONE` | Milestone verification passed and its evidence is recorded in the handoff |
| `BLOCKED` | External input or a decision prevents progress |

Only `DONE` satisfies a dependency. Review defects return to `IN_PROGRESS`, not
`BLOCKED`. A resolved blocker resumes at `IN_PROGRESS`. Tooling validates values
and dependency graphs but does not impose a Jira-like transition engine.

Every milestone has ID, status, dependencies, validation command, handoff path,
objective, scope, non-goals, and observable acceptance criteria. If configured
milestone arguments narrow the suite, the milestone also records the exact
arguments and why the narrower scope is safe.

Dependencies must be acyclic, must name a milestone that exists, and — when an
`M00` exists — every other milestone must reach it directly or through the graph.
`M00` is what proves the verification harness works; everything after it inherits
that proof, so a milestone that does not depend on it fails validation.

### Appending work after a plan is finished

The milestone list is append-only, and a finished plan is not a closed project.
A completed milestone is history: new work is appended as a new milestone.
It takes the next sequential ID, starts at `PLANNED`, depends on whichever milestone
finished last, and reaches `DONE` through the ordinary Builder session above — in the
primary checkout, on the primary branch, with no worktree. Several follow-up tasks
stay sequential, one milestone and one session each, exactly as the generated plan
ran. Nothing about this
re-runs product initialization: the contracts, the finished milestones, and
`AI/PROJECT_STATUS.md` carry forward, and that file records the current phase from the
same closed set of values it always used — moving back from `released` to
`implementation` is an ordinary edit to it rather than a new state.

A finished milestone is never reopened, renumbered, or reused for new scope. Its
status line, handoff, records, and verified SHA remain the account of what happened.
The sole correction exception is a later P0/P1 proving the original acceptance
criteria were not met: the milestone returns to `IN_PROGRESS`, its prior evidence is
preserved rather than overwritten, and correction evidence is added before it returns
to `DONE`. An already completed audit or final-polish record likewise remains intact;
new scope and later release candidates are appended as new milestones.

### Records

| Record | Location | Written from |
| --- | --- | --- |
| Milestone handoff | `AI/handoffs/<ID>-handoff.md`, as the milestone's `**Handoff:**` field names | [handoff-template.md](templates/handoff-template.md) |
| Optional independent review | `AI/audits/<ID>-review.md` | [audit-template.md](templates/audit-template.md) |
| Builder Final Product Polish audit | `AI/audits/<ID>-final-polish.md` | [final-polish-audit-template.md](templates/final-polish-audit-template.md) |
| Release record, or an optional independent release audit | `AI/audits/release-<version>.md` | [release-audit-template.md](templates/release-audit-template.md) |

Every file under `AI/audits/` and `AI/handoffs/` carries exactly one
`**Policy status:**` line — `current` for a record written against the policy in
force, or `superseded` for one whose policy has been replaced. A `superseded`
record additionally needs a `HISTORICAL RECORD` banner before its body and must
name the policy that replaced it. The supplied templates already carry the field;
`make template-check` rejects a record without it. A `current` audit whose findings
have since been closed may add `**Resolved by:**` pointing at the record that
closed them, but `AI/PROJECT_STATUS.md` remains authoritative for what is open.

## Verification levels

| Level | Command | Purpose |
| --- | --- | --- |
| Template | `make template-check` | Structure, config, shell, hook, and document checks |
| Static | `make static` | Lightweight repository checks; optional pre-commit-safe |
| Fast | `make fast` | Mutable Debug development feedback; never evidence |
| Milestone | `make milestone ID=M03` | Clean current HEAD, Debug build, declared tests, counts |
| Historical milestone | `make milestone ID=M03 CANDIDATE=<full-SHA>` | Immutable reproduction of an earlier candidate, for history or an optional review |
| Integration | `make integration CANDIDATE=<full-SHA>` | Exact merged SHA; complete shared scheme in product mode, repository self-test in template mode |
| Release | `make release CANDIDATE=<full-SHA>` | Exact release SHA, strict builds/tests and complete audit coverage |
| Self-test | `make self-test` | Disposable regression suite using Xcode stubs |

### Milestone evidence

Normal milestone verification requires a clean tracked and untracked tree, no
relevant ignored build input, no merge/rebase/cherry-pick, `REVIEW` status, and the
primary branch — the one `.iosai-project` records, which is where milestones are
developed and committed. A detached HEAD or any other branch is refused before the
tree is even inspected. It runs in the current checkout, records the branch and
current full SHA, and rechecks both HEAD and cleanliness before success. Reports
live under `.artifacts/milestone/<ID>/`.

Finder's `.DS_Store` and Xcode's per-user interface state are not build inputs, so
neither blocks it, and Xcode may stay open while it runs: `UserInterfaceState.xcuserstate`,
the Find navigator's `IDEFindNavigatorScopes.plist`, `xcschemes/xcschememanagement.plist`,
and the breakpoint and watch-expression lists under `xcdebugger/`, each inside an
`xcuserdata/<user>.xcuserdatad/` directory. A user scheme,
per-user workspace settings, or any other ignored file under `App/`, `Config/`,
`Scripts/`, `AI/`, or `.githooks/` still refuses.

Explicit candidate mode accepts only a full commit SHA and materializes that commit
in a detached read-only worktree. Dirty caller bytes cannot affect it. Reports name
`CANDIDATE_COMMIT`; `VERIFIED_COMMIT` appears only after success.

Strict test counts come from `.xcresult`. Zero, failed, missing, malformed, or
skipped mandatory results fail. An unavailable environment blocks required coverage.
No gate accepts a test argument that retries or repeats a failing test —
`-retry-tests-on-failure`, `-test-iterations`, `-run-tests-until-failure` — because
the counts would then describe a rerun rather than the run; milestone arguments may
still narrow which tests run, under the contract above. The same setting written into
the project is refused as well: `make static`, and so the first stage of every strict
gate, rejects a committed test plan or scheme whose `testRepetitionMode` is anything
but `none`.

Arguments that change only HOW the suite runs are a different matter and are allowed
through the complete-suite allowlist, Xcode's own test parallelism among them. That is
the mechanism to reach for when an application suite is slow: the scheme and its test
plans decide it, this repository never substitutes a scheme of its own, and
`Config/project.env.example` carries the guidance on which targets can take it.

Any code or configuration change after verification creates a new candidate and
requires another clean-HEAD run. The `DONE` status line, the handoff, the
`AI/PROJECT_STATUS.md` update, and any Markdown record written about the verified
commit are continuity records rather than code or configuration: they are written
after that commit and describe it, so they do not create a new candidate. Validate that commit with `make static` and
`./Scripts/project-status.sh validate` instead of re-running the whole suite
because Markdown changed, and prove it is only that with
`./Scripts/project-status.sh continuity <verified-full-SHA>`: it refuses any change
outside Markdown under `AI/` since the verified commit, a verified commit that is not
an ancestor of HEAD, and a checkout that is not clean.

Fast verification is the one exception, and only because it is not evidence. It is
development feedback: it may run a narrowed suite, it accepts skipped tests, and it
never establishes milestone or release readiness. Milestone, integration, and release
verification reject a skipped mandatory test outright. If a gate accepted a skip, the
sentence "the suite passed" would stop being true.

### Repository modes and prerequisites

`TEMPLATE_REPOSITORY="true"` means no app target exists: template/static/self-test
checks run, M00 cannot pass, and release reports `NOT_APPLICABLE_TEMPLATE_MODE`.
Product mode requires exactly one committed project or workspace under `App/`, a
shared scheme, managed simulator identifiers (or explicit build/test destinations),
distinct Debug/Release configurations, and the configured tools.

Universal checks use Git, Bash, Make, and the macOS base utilities the scripts
name explicitly: `find`, `sed`, `awk`, `grep`, `shasum` (keys the build cache to
this checkout), `perl` (publishes a report with `rename(2)` so a destination
symlink cannot be followed), `tar` (self-test fixtures), and `xargs` (runs the
self-test's independent cases concurrently). Simulator regression cases also require
`jq`. Managed simulator commands require Perl with its bundled JSON::PP and `ps`.
Product gates also require Xcode command-line tools, `xcodebuild`, `xcrun`, and `jq`.
Optional linters run only when enabled; an enabled missing tool fails with setup
instructions. Verification never installs tools, hooks, packages, or simulators.

Xcode may resolve committed Swift package dependencies over the network. No gate
uses GitHub as a verifier or contacts App Store Connect, uploads a build, or submits
metadata.

Workspace reference validation uses the macOS `xmllint` tool. It follows workspace
groups and project references, rejects malformed XML and external paths, and inspects
each referenced project before any build.

### Xcode validation boundary

`make self-test` runs against disposable fixtures with stub `xcodebuild` and
`xcresulttool` on `PATH`. It proves this repository's own logic — argument
handling, result-bundle parsing, verdict mapping, path confinement, failure
propagation — and it proves nothing about a real build, a real test run, or the
Simulator. No report produced under template mode may be read as evidence about an
application.

Proving the harness against real Xcode is `M00`'s job in a product repository, and
`M00`'s acceptance criteria are written for exactly that. Until it passes there,
every claim about build and test behaviour in this repository rests on stubs, and
any record that says otherwise is wrong.

### Exit codes outside release

Scripts preserve precise exit codes even though Make reports recipe failures as 2:

| Exit | Meaning |
| --- | --- |
| 0 | The stated check passed |
| 1 | Automated build/test/static failure |
| 64 | Invalid invocation or unsafe configuration |
| 65 | Verification assertion or policy boundary failed |
| 66 | Required input or record is missing |
| 69 | Prerequisite unavailable or gate not applicable |
| 70 | Internal inconsistency, including invalid/zero result counts |
| 73 | Evidence output could not be created safely |
| 75 | Managed checkout/device or shared desktop is busy |

`make static` reports the precise code for what it found — 64 for an unsafe or
invalid configuration, 65 for a failed assertion, 66 for missing input. When the same
static verification runs as the first stage of a milestone or integration gate, that
gate reports one flat 1: a boundary whose exit code depended on which internal check
failed would be harder to rely on than a single answer. Run `make static` directly
when the distinction matters; the reason is printed either way.

## Conditional integration

There is no integration stage after ordinary sequential milestones, because they are
never developed apart from each other. Run the gate whenever independently developed
streams are combined — localization is the supplied example — and against the exact
commit that combined them:

```sh
merge_sha="$(git rev-parse HEAD)"
make integration CANDIDATE="$merge_sha"
```

The gate verifies the exact SHA. In a product repository that means static checks, a
Debug build, and the complete shared test scheme including UI tests.

In the universal template repository there is no application target, so there is
nothing to build or test; the gate substitutes the repository's own self-test instead.
That substitution is heavier than an application suite: it builds and removes a
throwaway repository for every regression case. Those cases are independent, so they
run concurrently, each in its own process and its own temporary repository, at a width
chosen from the machine's CPU count and memory and capped well below either.

The width is a performance knob and never part of an answer. Each case is dispatched
once, its own checks are counted in its own process, and the report walks the cases in
registry order, so the same defect produces the same failed verdict at any width.
`IOSAI_TEST_JOBS` sets it: `IOSAI_TEST_JOBS=1` runs the cases one at a time with live
per-check output, which is how a failure is reproduced serially, and an unusable value
is refused rather than rounded to something workable. A case whose assertion observes
state the machine shares — one counts temporary directories that `mktemp -t` places
outside any private root — is held back and run alone; that is the only reason a case
is not run concurrently, and narrowing such a check to gain the width would have been
weakening it.

`./Scripts/self-test.sh --list` prints the current case set, and the suite reports its
own case and check totals on the last line — no document restates those numbers,
because a copied count goes stale silently.

Either way the gate stays conditional: it is not run after an ordinary sequential
milestone or a read-only review, only after streams were actually combined. A failure
is corrected by a new commit and a new candidate; do not weaken the gate. A push
never replaces integration evidence.

## Localization after the milestones

Every milestone builds, audits, and verifies one language, English — `Final Product
Polish` included, which establishes an English candidate. Translating the product is
the supplied product workflow designed to run in parallel, and it begins only after
that candidate reached `READY_FOR_HUMAN` and the developer verified the finished build
on a real device. Which languages to add is decided at that point and by the developer,
which is why nothing routes to any of this: the three prompts below are sent explicitly
once that decision exists.

Milestones stay sequential, one session each. Adding a language reopens, invalidates,
or re-verifies none of them, is never part of milestone completion, and creates no
milestone, role, or status of its own. A product that ships English alone never runs
any of this. What localized copy must do — tone, plurals, expansion, right-to-left —
belongs to `AI/DESIGN.md` and is settled during the milestones; this section is the
workflow that adds the translations afterwards.

Each language is developed independently, in its own branch and worktree, from the
same completed baseline:

```text
main: every milestone DONE, English candidate verified on a real device
    → worktree ../<repo-dir>-de     branch localization/de     one session → commit
    → worktree ../<repo-dir>-ja     branch localization/ja     one session → commit
    → worktree ../<repo-dir>-pt-br  branch localization/pt-br  one session → commit
```

`./Scripts/create-worktree.sh de` creates one — branch, directory, and base together
— and is the workflow's localization-specific helper. The branch, the worktree
directory, and the site route all use the locale identifier lowercased, because Git
refs are files and a macOS filesystem usually cannot tell `pt-BR` from `pt-br`; the
script refuses an uppercase locale and names the form to use, so that rule is
enforced rather than remembered. The application's own resources keep the
identifier's own casing. `./Scripts/remove-worktree.sh de` removes one again, by its
locale or by its path.

One session owns one language, and everything it changes lives inside that worktree.
It never edits the main checkout or another language's worktree, and never copies,
merges, or cherry-picks another language into its own. Where a shared file already
carries a different locale's data, it adds its own beside it and leaves the rest
unchanged. Conflicts between languages in string catalogs, locale registries, tests,
and route tables are expected, and they are resolved once, at
integration, rather than avoided by editing somebody else's language. Each language's
session includes its own second reading and its own validation in the running app: a
complete key set is not a finished localization.

The finished branches are then combined into main in one sequential pass:

```text
main, clean, still the commit those branches were cut from
    → record every branch, worktree path, and tip SHA
    → apply one language at a time, resolving shared files on their meaning
    → one integration commit
    → make integration CANDIDATE=<full-SHA>
    → run the app once per language, open every localized route
    → optional cross-language pass → at most one further commit
    → the developer publishes the site
```

That gate is the one described directly above: localization fan-in is exactly the
combined stream `## Conditional integration` exists for, and in a product repository
it builds and runs the complete shared scheme against the exact combined SHA. A
conflict in a file holding more than one language is never resolved by taking one
whole side, because one of those sides is a language being deleted. Publishing the
site waits until every expected language is integrated and the gate has passed.

`make site-check`, which `make static` runs, validates the four English pages plus
the added locales in `Config/localizations.json`: catalogs, store drafts, canonical
and alternate routes, language navigation, and original screenshot provenance.
Combined validation also opens every route in a browser and inspects the localized
application; structural checks alone do not establish rendered quality.

The candidate `Final Product Polish` established describes the commit before these
languages existed, so the integration commit is what now represents the shipping
product. Establishing the next candidate is the developer's decision when they choose
to ship, and no milestone reopens to do it: what establishes it is an appended
`Release Readiness Revalidation` milestone, described under
`## Final Product Polish and release readiness` above. The
shipped-language rows in
`Config/release-requirements.v3.tsv` also stop being inapplicable once a product ships
more than one language.

## Release

Release uses one candidate and one human decision point:

```text
exact SHA → complete final-polish coverage + automated checks
          → READY_FOR_HUMAN → developer subjective review
          → manual Product > Archive and Organizer validation
          → developer distribution decision and manual distribution
```

`verify-release.sh --candidate <full-SHA>` requires Final Product Polish (or a later
Release Readiness Revalidation) in `REVIEW`, completed dependencies, no project
blockers, and complete audit coverage. It checks immutable identity, release
configuration, static policy, a clean Debug build for the configured build destination,
a clean Release build for a generic device of the configured platform with code
signing disabled — signing belongs to the developer's Archive — complete result-bundle counts, channel policy,
secrets/endpoints, and version identity. A missing required environment blocks the
owning audit; it is never deferred past readiness.

`Config/release-requirements.v3.tsv` is the minimum audit inventory. Its five columns
are `id`, `channel`, `domains`, `allow_inapplicable`, and `description`. Each owning domain records every applicable row as `VERIFIED` with
concrete evidence or permitted `INAPPLICABLE` with a product-specific reason.
REL-208 and REL-209 alone permit a platform exception: with APP_PLATFORM=watchOS,
record INAPPLICABLE and a specific Watch-only reason because no rating flow is
required. They remain mandatory for iOS; missing hardware never grants an exception.

The consolidated record contains six ordered `## Coverage: <domain>` sections and says
`Coverage result: COMPLETE` and `Open P0/P1: 0`. Later targeted revalidation audits
use `AI/templates/domain-audit-template.md` and belong to completed milestones.

After successful automated checks, the gate creates or validates
`.artifacts/release-checklists/<full-SHA>/checklist.md`. It binds the full SHA,
version/build identity, and distribution channel and preserves existing evidence.
Its three human steps are subjective device review, Xcode Archive plus Organizer
validation, and the developer’s distribution decision. These follow readiness;
they do not substitute for any of the completed audit rows. `PENDING` is counted and
reported, never claimed as performed. To record `VERIFIED`, provide who performed
the step, its date, and concrete results in the checklist’s required format. A
mismatched identity, missing or duplicate row, unknown outcome, or evidence-free
verification is `NOT_READY`. No gate creates an archive or publishes anything.

`READY_FOR_HUMAN` means automated checks passed for that exact commit, required
audit evidence is complete, and the human checklist is valid. It does not approve
publication. An optional independent Release Auditor may provide another opinion.
The developer performs Product > Archive on the verified candidate, validates it
in Organizer, and distributes manually through the configured channel. A checkout that
has moved past the candidate by continuity records alone archives the same bytes;
`./Scripts/project-status.sh continuity <full-SHA>` is what confirms it.

The checklist and report are ignored local evidence. Preserve them in a committed
release record using `AI/templates/release-audit-template.md` after completing the
human work. A push alone does not back up `.artifacts/`.

| Exit | Verdict | Meaning |
| --- | --- | --- |
| 0 | `READY_FOR_HUMAN` | Automated checks passed; audit coverage complete; pending human steps reported |
| 1 | `VERIFICATION_FAILED` | Automated build/test/configuration verification failed |
| 64 | none | Invalid invocation: `--candidate` missing, an unknown option, or a removed release interface |
| 65 | `NOT_READY` | The candidate is not the full SHA of a commit here, or workflow coverage/readiness or the human checklist is invalid |
| 69 | `NOT_APPLICABLE_TEMPLATE_MODE` | No product exists yet |

An abbreviated, symbolic, malformed, or unknown candidate is refused with
`VERDICT=NOT_READY` and exit 65 before anything is materialised. If materialising the
snapshot itself fails, the gate exits 65 without a verdict token; read the failure
message.
No gate uploads, submits, pushes, archives, or grants publication approval.

An optional independent release audit is separate from milestone completion. It
never turns the Builder’s self-review into independent approval.

## Failure and evidence rules

- New failures block the relevant transition.
- A failure is pre-existing only after identical reproduction at the baseline SHA.
- A known P0/P1 defect blocks `DONE`: the session that found it fixes it. One raised
  later against a `DONE` milestone invokes the documented correction exception,
  returns it to `IN_PROGRESS`, preserves its prior evidence, and belongs in the
  project blockers.
- Reports must state exact commands, exit codes, SHA, counts, and pending work.
- Ignored evidence lives under `.artifacts/`; use `make clean-artifacts` only for
  repository-owned artifacts.
- The credential scans in `make static` have no inline suppression. A committed file
  that only looks like a secret — Firebase's `GoogleService-Info.plist`, a pinned
  public certificate, a model named `Credentials.swift` — is listed once in
  `Config/credential-scan-allowlist.txt` with its exact path, the one rule it is
  excused from, a reason, and an expiry. A private key, a provider secret token, or
  signing material can never be listed.
- Repository-wide scans read this checkout's own files. A nested checkout inside it —
  a Claude Code worktree under `.claude/worktrees/`, a submodule, a cloned dependency —
  has its own `.git`, is skipped, and runs its own gates. `App/` is the exception: it
  holds this repository's build inputs, so its files are always scanned, and
  `make static` and every build gate refuse a nested repository or submodule there,
  because no commit would carry its files and no candidate snapshot could verify them.
- Result bundles and archives are build outputs, never committed evidence.
- No gate creates an archive. The developer archives in Xcode after the release
  verdict, and `*.xcarchive` stays ignored so a manual one is never committed.
- DerivedData lives outside the repository in a checkout-keyed owned directory so
  the parallel localization worktrees do not share mutable caches.
- Cleanup accepts only repository-owned artifact/cache roots, rejects symlink and
  broad-path escapes, and never derives deletion authority from configuration.
- Candidate snapshots are temporary, detached, read-only, and removed on success,
  failure, or interruption.

## Session prompts

| Task | Prompt |
| --- | --- |
| Initialize product contracts | [initialize-product.md](prompts/initialize-product.md) |
| Execute the next ready milestone end-to-end | [execute-next-milestone.md](prompts/execute-next-milestone.md) |
| Review a milestone again, optionally | [review-milestone.md](prompts/review-milestone.md) |
| Run the final product polish workflow end-to-end | [final-polish.md](prompts/final-polish.md) |
| Revalidate a later release candidate | [final-release-readiness.md](prompts/final-release-readiness.md) |
| Audit release readiness, independently and optionally | [audit-release.md](prompts/audit-release.md) |
| Add one localization in its own worktree | [add-localization-worktree.md](prompts/add-localization-worktree.md) |
| Combine finished localization worktrees | [integrate-localization-worktrees.md](prompts/integrate-localization-worktrees.md) |
| Polish every shipped language, optionally | [polish-localizations.md](prompts/polish-localizations.md) |

The first two carry initialization and ordinary implementation. The third canonical
prompt carries the one final milestone and its six ordered domain methods. The three
localization prompts are the only others the developer
sends, they belong to `## Localization after the milestones` above, and none of them
starts before the release candidate they translate is established. Appending a
follow-up milestone needs no prompt of its own: the developer asks for it, and the
second prompt runs it like any other.

## Owner exception — localization before M10, 2026-10-23

The owner explicitly approved implementation of the 11-language localization plan
before M10: es, it, fr, pt-PT, pt-BR, nl, de, sv, da, fi, nb, ru, in addition to en.
The Portuguese language task owns its two locale worktrees sequentially. The
coordinator prepares shared infrastructure on main, freezes one baseline SHA, then
each language works independently. App Store and IAP copy is prepared as local
reviewable drafts under AI/localization; nothing is uploaded or published. This
explicit product exception overrides the English-only timing and store-draft
exclusions in the generic localization prompts, not any verification requirement.

Localization is not a milestone and does not complete or reopen another one.
M10 audits the integrated multilingual candidate. Every applicable language and
layout check remains required; real-Watch evidence is still mandatory, and M10
remains BLOCKED until that evidence exists. Earlier evidence describes its own SHA.
The coordinator performs a full editorial second pass after the language agents.
All routes, screenshots and store drafts are validated before delivery. No App
Review submission, App Store Connect upload or site publication is authorized.

## Independent Watch with iPhone companion — M16

The owner approved M16 on 2026-10-24. `WATCH_APP_MODE="companion"` adds a mandatory
committed `Config/companion.env` iOS profile to the primary Watch profile. Milestone,
integration and release run the existing complete Watch suite first, then the full
iOS suite in its own scheme, simulator binding, DerivedData and xcresult. Neither
suite can be omitted, narrowed, retried into a pass or treated as optional. The
Watch-only path and its regression fixtures remain supported for historical work.

`Scripts/simulator.sh --profile companion` manages the iOS17 SE binding separately;
`--profile capture` manages the iOS26.5 large iPhone screenshot binding. Both keep the
same checkout lease and distinct device leases; captures do not replace mandatory
minimum-OS coverage. The ordinary commands still address the original Watch device.
Actual built-plist checks require the iPhone executable and independent Watch with
`WKRunsIndependentlyOfCompanionApp=true`, correct companion ID, versions and launcher.
The iOS rating rows are mandatory for companion mode too. Hardware StoreKit exchange
must be observed on the owner-connected pair; Simulator results cannot claim it.
M16 does not reopen M10 or authorize carrying its old candidate evidence forward.

## Owner exception — M16 current-device acceptance, 2026-10-24

The owner explicitly accepts the already observed current physical pair and the two
named SE/iOS17 native contrast audit failures, relying on the passing iOS27 checks.
Scope: AI/evidence/M16/owner-acceptance-20261024.md. For M16 only, after the unchanged
full milestone command executes, these exact two contrast failures may remain
nonblocking. Any other failure, skipped/missing suite or crash still blocks DONE.
Report actual command exits and counts; never call the failed automated gate a pass.
No assertion/parser/suite is changed. This explicit decision supersedes the earlier
all-green/extra-physical-scenario requirements for these items only. Separate release
readiness remains necessary and must carry the actual results plus owner decision.

## Owner extension — separate companion readiness and submission, 2026-10-24

The owner explicitly requested separate Release Readiness Revalidation with the
already agreed exceptions, followed by TestFlight checking, upload and ordinary
app+first lifetime IAP submission. AI/evidence/M17/owner-release-authorization.md
contains the quote. The same exact two native SE/iOS17 Contrast failed cases and
accepted current-pair coverage carry into M17/M18. Unchanged complete milestone
and release commands still run; raw FAILED/VERIFICATION_FAILED exits are preserved
and never called automated READY_FOR_HUMAN. Only those bounded failures may have an
owner-accepted completion/submission disposition; any new failure remains blocking.
No test, assertion, parser or gate is changed. Six current domain records belong to
M17, then M18 binds candidate readiness; these sequential phases implement the
explicit end-to-end owner request without reopening historical M10/M16 records.
