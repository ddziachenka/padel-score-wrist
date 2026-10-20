# Migrate an unstarted final audit plan

Use this only when the developer asks to adopt the current single Final Product
Polish workflow in a project generated with separate final audit milestones.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Inspect every final audit/readiness contract, dependency, record, and handoff.

Proceed only if all replaced milestones are `PLANNED`, no audit or handoff exists,
no implementation or audit work is recorded, and no downstream milestone depends
on the old sequence. Otherwise preserve all work and evidence and ask for a
project-specific decision. Started and completed history is never deleted or
renumbered automatically.

Replace only that unstarted tail with the one `Final Product Polish` contract in
`AI/prompts/initialize-product.md`, at the next sequential ID after implementation.
It depends on every earlier milestone, names `AI/prompts/final-polish.md`, records
`AI/audits/<ID>-final-polish.md`, and includes both milestone and exact-SHA release
gates. Keep it `PLANNED`. Update the next milestone reference in project status.
Do not change application code or create audit/handoff evidence.

Run `make template-check` and `./Scripts/project-status.sh validate`; report the
replaced IDs, new path, and both exit codes. Migration does not start the milestone.
