# Release readiness verification

Use this procedure only as the closing phase of `Final Product Polish`, in that same
Builder session, or as the contract for a later appended `Release Readiness
Revalidation` milestone. It never creates an extra final milestone during product
initialization.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Read `CLAUDE.md` when working in Claude Code, then the active milestone contract,
   the relevant audit record and handoffs, and the release prerequisites.

For Final Product Polish, confirm the six ordered domains are complete in the one
consolidated record and no known P0 or P1 remains. Do not redo them here. For a later
revalidation, confirm its dependencies are `DONE` and no known P0 or P1 remains in
their records or `AI/PROJECT_STATUS.md`. A known blocker must be corrected before a
candidate can be established.

All six domains must have complete typed coverage from
`Config/release-requirements.v3.tsv` before readiness. An unavailable required
environment blocks this work; it cannot become a pending distribution step.

For a later revalidation, declare `**Revalidated domains:**` with comma-separated
domain names. For each affected domain, add `**<domain> revalidation record:**
AI/audits/<ID>-<domain>-revalidation.md`. Each referenced record uses the complete
coverage format from `AI/templates/domain-audit-template.md` and belongs to a `DONE`
targeted audit milestone. Preserve the original final-polish record and candidate.

## Establish and verify the candidate

Set the active milestone to `REVIEW`, commit, and run `make milestone ID=<ID>` from a
clean primary checkout. Verify the exact full SHA reported by that successful run:

```sh
make release CANDIDATE=<verified-full-SHA>
```

Diagnose a failure and fix the underlying defect in the active Builder session. A
code or configuration correction creates a new candidate and requires the applicable
targeted audit and verification again; never weaken a gate or reuse evidence from old
bytes. Stop only when release verification reports `READY_FOR_HUMAN` or a genuine
external or product decision blocks progress.

## Finish

Write the compact handoff with the exact candidate, commands, exit codes, reports,
counts, release verdict, checklist path, and outstanding manual rows. Set the active
milestone to `DONE`, update `AI/PROJECT_STATUS.md`, commit those continuity records,
and validate them with `make static`, `./Scripts/project-status.sh validate`, and
`./Scripts/project-status.sh continuity <verified-full-SHA>`.

Nothing is uploaded, submitted, archived, or published. `READY_FOR_HUMAN` is a
candidate-bound automated verdict, never a milestone status or release approval. The
developer performs the subjective review, pending manual rows, Product > Archive,
Organizer validation, and distribution. An optional independent review or Release
Auditor pass remains optional.

When this closes Final Product Polish, start no next milestone and no second audit
cycle. When it closes a later Release Readiness Revalidation milestone, its verdict
belongs only to that new SHA and does not alter the historical final-polish evidence.
