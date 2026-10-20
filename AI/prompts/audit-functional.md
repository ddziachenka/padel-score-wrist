# Audit — functional correctness and bug hunt

The first domain inside the `Final Product Polish` milestone. The orchestrating
Builder session reads this file, audits and fixes this domain, records it in the
consolidated final-polish record, and then continues to UI / UX. This is a bug hunt,
not a code-style review: try to break the finished product the way a real user would.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, this milestone's contract, and the
   contracts and concise handoffs of the milestones it depends on.

Build the product, launch it in Simulator, drive the real UI, and read the runtime
logs. The clean-install, launch, upgrade, migration, journey, and network-behavior
domains of `Config/release-requirements.v3.tsv` are the maintained inventory here.
That inventory is minimum maintained coverage, not the limit of what to inspect: the
defects that matter are usually the ones nobody wrote a row for.

Complete every applicable `functional` inventory row with typed evidence in this
record's matching coverage section. An unavailable required environment blocks
completion. When used for a later targeted audit, apply this same domain method in
its owning milestone and use the domain-audit record template instead.

## Look for

- Every primary journey in `AI/PRODUCT.md` run twice, cancelled, retried,
  interrupted, backed out of, and resumed after relaunch.
- State that goes stale, updates twice, disagrees between two screens, arrives after
  its screen was dismissed, or is lost across termination.
- Persistence exercised through create, read, edit, delete, repeat, relaunch,
  ordering, restoration, migration, and partially completed flows.
- Rapid repeated taps, double submission, a sheet dismissed mid-flight, empty and
  boundary inputs, and an action started while it is already running.
- Loading that can never end, a failure that corrupts state or reads as success, a
  retry that does not retry, and the offline or unavailable-service paths.
- Permission granted, denied, previously denied, and changed in Settings; purchase
  success, cancellation, failure, restore, and entitlement across relaunch.
- Work that grows without bound: memory climbing across a long session, a list that
  slows as data accumulates, or a screen that gets heavier every time it is opened.
  Investigate one with a profiling or memory tool when the session has one, and by
  measuring the running app when it does not — but only once the behavior was
  actually observed, because a speculative hunt here finds nothing and costs the
  audit its time.
- Interactions between features that separate milestones built separately.

## Report and fix

Each finding names its severity, the affected journey, exact reproduction steps,
expected and actual behavior, and its runtime or code evidence. Do not report a
theoretical race with neither a reproduction nor direct code evidence.
An absent capability is recorded `INAPPLICABLE` with a reason, not as a finding.
Fix the valid P0 and P1 findings here, cover them with tests wherever the behavior
can be automated, and rerun the original reproduction. Record the outcome in the
Functional Correctness section of `AI/audits/<ID>-final-polish.md`. The orchestrator
runs the single targeted re-audit after all six domains; do not start a separate pass,
session, milestone, or domain record here.

For watchOS Watch-only, exercise the smallest supported Watch screen, Digital Crown
where used, supported text sizes and VoiceOver, background/foreground recovery, and
independent operation without an iPhone app. Check readable legal/support content
on the Watch. HealthKit, complications and background modes apply only when approved.
REL-208 and REL-209 are INAPPLICABLE with a Watch-only reason; iOS still verifies
them. Missing hardware never makes an applicable requirement inapplicable.
