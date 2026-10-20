# Review a milestone again, optionally

Use the Reviewer role defined in `AI/WORKFLOW.md`. This pass is optional and is
never a precondition for `DONE` — use it when the developer asks for a second
opinion on something consequential. Do not review work you built.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read the milestone, its handoff, contracts, existing audits, and the complete
   baseline-to-candidate diff.

Treat the handoff as a claim. Confirm its dependencies are `DONE` and rerun the
verification against the SHA the handoff names:

```sh
make milestone ID=<ID> CANDIDATE=<verified-full-SHA>
```

Check every acceptance criterion, scope, test quality, architecture, data and
privacy, concurrency, accessibility, localization, and relevant UI states. Record
reproducible findings in a new audit using the audit template.

With no P0/P1, the milestone stays `DONE`. With any P0/P1, set it to
`IN_PROGRESS`, list exact corrections, preserve its earlier handoff, audit, SHA, and
verification evidence, and leave it for a new Builder session to add correction
evidence. This correction exception applies only to a defect against the milestone's
original acceptance criteria; new scope is appended as a new milestone.
Never repair the implementation during this review.
