# CLAUDE.md — Claude Code guidance

[AGENTS.md](AGENTS.md) and [AI/WORKFLOW.md](AI/WORKFLOW.md) are the operating
contract. Start with `git status`, `AI/PROJECT_STATUS.md`, the active milestone,
and the code in scope.

## Session roles

Use the Builder, Reviewer, or Release Auditor definition in `AI/WORKFLOW.md` and
the matching prompt under `AI/prompts/`.

A Builder session takes exactly one milestone from its current state to `DONE` —
implement, test, self-review, fix what that review finds, verify, hand off — and
then stops without starting another. An extra independent review is optional, runs
in its own session, and never blocks `DONE`; self-review is never recorded as one.

Reversible implementation choices are the session's own: pick the option you would
recommend, say in one line what you chose and why, and keep going. Stop only for a
genuine product decision, and when you do, offer two to four options with one marked
Recommended and wait for the developer to pick one. `AI/WORKFLOW.md` holds both halves
under `### Questions for the developer`, and obligations A13 and A16 in `AGENTS.md`
carry the same rule.

The initial plan ends with one `Final Product Polish` milestone. Its single Builder
session runs the six domain prompts in order, fixes every valid P0/P1, performs one
targeted re-audit, writes one consolidated record, verifies the milestone, runs
`make release` for that same SHA, and ends at `READY_FOR_HUMAN`. It starts no next
milestone. No new role or milestone state comes with it.

That is the end of the initial plan, not the end of the project. Work that appears
afterwards is appended as a new milestone with the next sequential ID and run exactly
like every earlier one. Completed evidence stays history; only a later P0/P1 proving
the original acceptance criteria failed may reopen that milestone for correction,
with its prior evidence preserved. `AI/WORKFLOW.md` holds the rule, including the
`Release Readiness Revalidation` milestone a later candidate needs.

## Checkouts and Git

Every milestone is developed in this checkout, on the primary branch, and committed
there. They run one after another, one session each, and `make milestone` refuses to
run from any other branch or from a detached HEAD.

A worktree and branch outside the primary one may isolate genuinely parallel
localization, an independent read-only review, or a bounded experiment. The supplied
`./Scripts/create-worktree.sh <locale>` helper remains localization-specific. No
milestone is implemented or verified in a worktree, and no checkout touches another
checkout's uncommitted work.

Commit often. Push when useful for backup or synchronization. Neither operation is
verification. Run integration verification whenever independently developed streams
are combined.

## Evidence honesty

Do not claim commands you did not run. Counts come from `.xcresult`, not log prose.
Zero or skipped mandatory tests fail strict gates. A suspected pre-existing failure
is new until reproduced at the baseline with the same command.

Every applicable coverage row belongs to a milestone or final domain audit. An
unavailable required environment blocks that owner. The human distribution checklist
does not defer required audit coverage past release readiness.

Template gate changes require matching cases in `Scripts/self-test.sh` and the full
`make template-check`, `make static`, and `make self-test` sequence.

Order that sequence rather than repeating it after every edit. While the change is
still being written, run the self-test cases it touches with
`./Scripts/self-test.sh --case <name>` (`--list` prints them), plus
`make template-check` and `make static`. The full `make self-test` runs once, when the
intended change is complete, against the final bytes; a targeted run is feedback and
never stands in for the suite. An edit after that run repeats the affected targeted
checks and then the full suite again, so the commit carries exactly the bytes the full
suite passed on.

The full suite runs its cases concurrently at a width taken from the machine. That is
a performance property only: the verdict, the case list and the check totals do not
depend on it. Reproduce a failure with `IOSAI_TEST_JOBS=1`, which runs one case at a
time and streams its checks; do not treat a parallel run as weaker evidence than a
serial one, and do not report a serial run you did not perform.
