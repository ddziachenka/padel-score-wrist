# Execute the next ready milestone end-to-end

Use the Builder role defined in `AI/WORKFLOW.md`. This session takes exactly one
milestone from its current state to `DONE` and then stops — one milestone per
session.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Run `./Scripts/project-status.sh next`, select that single milestone, and read
   its complete contract plus every product, design, and architecture section it
   depends on.

The selector resumes an existing `IN_PROGRESS` or `REVIEW` milestone before starting
new work. Preserve its prior implementation and evidence. `IN_PROGRESS` continues
implementation or correction; `REVIEW` resumes the clean-candidate verification and
handoff steps, returning to `IN_PROGRESS` only if corrections are needed. A genuinely
`BLOCKED` current milestone requires its recorded decision or external dependency to
be resolved; a restart never resolves that implicitly.

When the selected milestone is `Final Product Polish`, read its `**Audit prompt:**`
field and follow `AI/prompts/final-polish.md` instead of the ordinary sequence below.
For a later release readiness revalidation, follow
`AI/prompts/final-release-readiness.md`. A targeted audit milestone names its own
`**Audit prompt:**`; read it as the method for implementation and correction.
In every case this session owns one milestone and stops after taking it to `DONE`.

If step 5 reports that no milestone is ready, read why before doing anything else.
Every milestone `DONE` means the plan is finished: say so and stop, unless this session
was asked for specific new work. In that case write one new milestone contract from
`AI/templates/milestone-template.md` first — the next sequential ID, status `PLANNED`,
depending on whichever milestone finished last, scoped to exactly what was asked — and
then carry that single milestone through the sequence below.
Append the next sequential milestone rather than reopening a finished one for new
scope. A completed milestone's status, handoff, records, and verified SHA stay exactly
as they are, and a finished audit is not re-run to cover new work: if the change
genuinely needs auditing, that is another appended milestone after this one. The sole
exception is a documented later P0/P1 proving the original acceptance criteria were
not met; then follow `AI/WORKFLOW.md`, preserve the prior evidence, and correct that
milestone from `IN_PROGRESS`. If instead some
milestone is unfinished and nothing is ready, the graph is blocked rather than complete
— name that milestone and stop.

Then own it to the end. For an interrupted `REVIEW`, resume at step 7 with the
committed candidate; return to implementation only when a correction is needed:

1. Set `IN_PROGRESS`. Read the existing code before editing and write a short plan.
2. Implement the whole scope, and only that scope.
3. Add or update the tests that fail when the behavior regresses.
4. Run the fast, targeted checks while you work and commit coherent recovery points.
5. Self-review the entire baseline-to-tip diff against the acceptance criteria and
   the applicable categories in `AI/WORKFLOW.md`, including the craftsmanship pass
   when this milestone changes what a person sees or does. Go deeper for purchasing,
   migrations, authentication, sensitive data, permissions, concurrency, backend
   integration, and release infrastructure. Self-review is not independent review.
6. Fix every valid blocking finding, rerun the affected tests, and review the
   correction. Repeat 5 and 6 until nothing blocking is known.
7. Set `REVIEW`, commit, and run `make milestone ID=<ID>` from a clean checkout.
8. If it fails, classify the failure as described in `AI/WORKFLOW.md` and act on it
   here, then verify again. Never weaken a test to obtain a pass.
9. Run any additional problem scanner this repository configures beyond `make
   static`, fix its valid findings, rerun the affected tests, and verify again.
10. Write the compact handoff with the exact evidence, set `DONE`, update
    `AI/PROJECT_STATUS.md`, commit, and validate that commit with `make static`,
    `./Scripts/project-status.sh validate`, and
    `./Scripts/project-status.sh continuity <verified-full-SHA>`, which proves the
    commit changed only continuity records. Then stop.

Judge user-facing work in the running application rather than in the diff: build,
launch, drive the flow this milestone changed, look at its loading, empty, error, and
success states, fix what that shows, and re-check once. A bespoke visual, motion, or
haptic moment is judged the same way, in the state it belongs to, and removed when it
does not improve the experience. Use whichever specialized iOS, design, image, or
runtime tool this session actually has when it applies to the work, and the ordinary
read-the-code-and-run-the-app path when it does not. `AI/WORKFLOW.md` holds both rules
together with what stays a check on real hardware and how far performance work goes,
and neither of them adds a capability to the product that the contracts did not
already require.

A visual treatment, illustration, motion, or micro-interaction that is clearly within the
approved product and design scope is yours to implement without asking, and several
technical ways to produce one effect is a choice to settle rather than a question to
raise.

Do not start another milestone in the same session, and do not return control
merely to ask for another review session — no worktree is required for any of this,
and milestone work never runs in one: this milestone is developed in the primary
checkout, on the primary branch, and committed there. `make milestone` refuses any
other branch, so a worktree would only stop the gate from running.

Decide implementation questions from `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
`AI/DESIGN.md`, the acceptance criteria, the existing code, and Apple's platform
conventions. SwiftUI structure, state ownership, API and library use, naming,
decomposition, navigation, test strategy, error handling, animation and haptic detail
already consistent with `AI/DESIGN.md`, and minor UX detail are yours to settle:
choose the option you would recommend and proceed, preferring the simplest
high-quality one the approved product allows. Say in one line what you chose and why
rather than asking which to choose.

Stop only for a genuine product decision: ambiguous product behavior, MVP scope,
monetization, privacy, destructive behavior, a major UX change the design does not
resolve, a significant product mechanic, an external service, account, or cost
commitment, a legal or compliance decision, or a trade-off the approved contracts
leave genuinely balanced. Ask one precise question with two to four options, the
trade-off in a sentence each, and exactly one option marked Recommended with one line
of why. Set `BLOCKED`, name the decision and those options on the `**Blockers:**` line
of `AI/PROJECT_STATUS.md`, and stop until the developer chooses. Ordinary defects
remain `IN_PROGRESS` and are fixed in this session.
