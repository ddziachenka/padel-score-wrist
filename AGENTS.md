# AGENTS.md — operating contract

**Policy version:** `solo-workflow/2`

This repository is a local-first development system for one developer using AI
agents. The repository is the memory: current product truth lives under `AI/`,
not in a previous chat.

## Start every session

1. Run `git status` and preserve work already present.
2. Read [AI/WORKFLOW.md](AI/WORKFLOW.md).
3. Read [AI/PROJECT_STATUS.md](AI/PROJECT_STATUS.md).
4. Read the milestone and the code you will touch.
5. Work as the role implied by the task: Builder, Reviewer, or Release Auditor.
6. A Builder session takes exactly one milestone to `DONE` and then stops.
   [AI/WORKFLOW.md](AI/WORKFLOW.md) defines that sequence.

## Obligations

- **A1 Inspect first.** Read existing code and state before proposing or changing it.
- **A2 Stay in scope.** Adjacent improvements go in the handoff, not the change.
- **A3 Preserve unrelated work.** Never revert, stash, reformat, or overwrite work
  you did not create.
- **A4 Preserve product decisions.** Changes to approved behavior require the
  developer's decision and an update to the owning product document.
- **A5 Never weaken verification.** Do not delete, skip, loosen, or condition away
  a test or check to obtain a pass.
- **A6 Run the milestone's declared validation.** Use the exact command it names.
- **A7 Reproduce before calling a failure pre-existing.** Use the same command at
  the baseline commit and record the result.
- **A8 Report evidence.** Include the command, exit code, exact SHA, report path,
  and result-bundle counts when applicable.
- **A9 A skipped check is not a pass.** State why it did not run.
- **A10 Complete required coverage where it belongs.** Every applicable check runs
  in its owning milestone or final audit. An unavailable required environment blocks
  that work; it is never deferred beyond release readiness.
- **A11 Leave a handoff.** Use the compact template and fill every field.
- **A12 Update status only from evidence.** `DONE` requires a passing milestone
  verification whose exact evidence is recorded in the handoff.
- **A13 Stop for genuine human decisions.** Product direction, destructive choices,
  and App Store submission remain human decisions. Ask about one with
  two to four options, one marked Recommended, and no progress until one is chosen.
- **A14 Separate synchronization from verification.** Commits save progress and
  pushes synchronize it. When branches are combined, verify the exact merge SHA.
- **A15 Self-review is not independent review.** A Builder reviews and corrects its
  own diff, and never records that as an independent audit or a release approval.
- **A16 Decide reversible choices yourself.** Where several implementation options
  are reasonable, pick the one you recommend and proceed. A13 is the boundary, and
  presenting a choice you can responsibly settle is not caution.

## Checkouts and branches

Every milestone is developed in the primary checkout, on the primary branch, and
committed there; milestone verification refuses any other branch. Optional worktrees
may isolate genuinely parallel localization, independent read-only reviews, or bounded
experiments, but never milestone implementation or verification. When independently
developed streams are combined, verify the exact merge SHA.
[AI/WORKFLOW.md](AI/WORKFLOW.md) holds the boundaries in full.

## Local commands

`make help` lists every target and is the authoritative map — read it rather than
trusting a copy. These are the ones used most often, not the whole set:

```sh
make static                                   # lightweight repository checks
make fast                                     # mutable Debug development loop
make milestone ID=M03                        # clean current HEAD
make milestone ID=M03 CANDIDATE=<full-SHA>   # reproduce an earlier candidate
make integration CANDIDATE=<full-SHA>        # only when streams are combined
make release CANDIDATE=<full-SHA>            # exact release candidate
```

A candidate is always a full 40-character SHA; an abbreviation or a ref is rejected.

Git hooks are optional conveniences. There is no pre-push verification and no
remote CI assumption. Release success means `READY_FOR_HUMAN`; only the
developer decides whether to submit to the App Store or use the configured internal
channel.

## Simulator and desktop ownership

New products use managed simulators. Follow the simulator isolation section of
`AI/WORKFLOW.md`: prepare once with `make simulator-setup`, read
`make simulator-context`, and pass the returned UDID to every tool. Never use
`booted`, the first available device, `shutdown all`, `erase all`, `killall Simulator`,
or restart CoreSimulator. Reserve the checkout/device for a multi-step inspection
with `Scripts/simulator.sh acquire --pid <live-agent-PID>` and release its token.
Add `--desktop` when using shared mouse, keyboard, window focus, or desktop capture;
hold it across the entire interaction. If busy (75), continue independent work.
Use direct UDID-targeted tool calls inside a reserved session; the ordinary wrappers
acquire their own leases and intentionally refuse a nested acquisition.

## Sources of truth

| Question | Document |
| --- | --- |
| Product behavior and business decisions | [AI/PRODUCT.md](AI/PRODUCT.md) |
| Technical boundaries and privacy architecture | [AI/ARCHITECTURE.md](AI/ARCHITECTURE.md) |
| UX, visual design, accessibility, and localization | [AI/DESIGN.md](AI/DESIGN.md) |
| Workflow, roles, gates, Git, and release process | [AI/WORKFLOW.md](AI/WORKFLOW.md) |
| Current milestone, blockers, and important decisions | [AI/PROJECT_STATUS.md](AI/PROJECT_STATUS.md) |
