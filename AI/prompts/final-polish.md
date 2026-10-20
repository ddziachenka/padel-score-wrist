# Run Final Product Polish end-to-end

Use the Builder role defined in `AI/WORKFLOW.md`. This is the last milestone in the
generated plan and one Builder session owns all six audit domains, their corrections,
milestone verification, release verification, handoff, and `DONE` transition.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Run `./Scripts/project-status.sh next`; select the ready milestone named `Final
   Product Polish`, and read its complete contract plus `AI/PRODUCT.md`,
   `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, and the handoffs it depends on.

If that milestone is not next-ready, report the dependency or blocker and stop. Do
not skip unfinished implementation. Resume existing work and evidence when already `IN_PROGRESS` or `REVIEW`; only
start a new record for a new milestone. Set `IN_PROGRESS` when implementing or
correcting, and use its single record, `AI/audits/<ID>-final-polish.md`, from
`AI/templates/final-polish-audit-template.md`.

On restart, use the existing record to resume the unfinished phase. Do not overwrite
completed domain evidence or repeat a full pass solely because the session stopped.
If already in `REVIEW` with complete coverage, resume candidate verification below;
corrections return to `IN_PROGRESS` and receive the affected checks.

## Run the six domains in order

Run exactly one full pass through these domains, in this order:

1. Functional Correctness / Bug Hunt — `AI/prompts/audit-functional.md`
2. UI / UX — `AI/prompts/audit-ui-ux.md`
3. Content / Copy — `AI/prompts/audit-content.md`
4. Accessibility — `AI/prompts/audit-accessibility.md`
5. Product Experience — `AI/prompts/audit-product.md`
6. Release / App Store / Privacy / Monetization — `AI/prompts/audit-release.md`

Read the named prompt immediately before its domain and apply its method as a section
of this milestone. The repeated preflight in a domain prompt is a safety reminder, not
a new session or milestone. Exercise the running application wherever that prompt
requires runtime judgment. `Config/release-requirements.v3.tsv` is minimum maintained
coverage, not a substitute for using the product.

Record each domain's coverage, findings, corrections, and evidence in the matching
section of the consolidated record. Do not create six domain audit records. A
capability the approved product does not have is `INAPPLICABLE` with a reason. A
useful capability outside the approved contract is `FUTURE_PRODUCT_IDEA`, never a
defect and never implementation scope for this milestone.

Each domain must include every assigned row for the configured channel, exactly
once, under its `## Coverage: <domain>` heading. Use the typed `VERIFIED` and
permitted `INAPPLICABLE` forms in the record template. Set `**Coverage result:**
COMPLETE` and `**Open P0/P1:** 0` only when all six domains support those claims.
An unavailable required device, service, account, or other environment blocks this
milestone; it is not an inapplicable capability or deferred human distribution work.
For appearance rows, cover every appearance approved in `AI/DESIGN.md`; cite that
contract when an unsupported appearance is inapplicable. Contrast remains required
in every supported appearance.

## Fix and converge

Reproduce and fix every valid P0 and P1 in this session, including a concrete blocker
noticed outside the domain currently being audited. Rerun the affected tests after
each correction. P2 is non-blocking: fix it only when the benefit is clear, the risk
and scope are low, and the change does not displace blocking work; otherwise record it
as deferred with the reason.

After all six full passes and their fixes, run one targeted re-audit covering only the
behavior changed during this milestone. Fix any P0 or P1 it reveals and validate that
specific correction, but do not start another full pass. A P2 first noticed during
the targeted re-audit is recorded and deferred. This is the convergence boundary: no
third pass and no endless polish loop.

If this repository configures an additional problem scanner beyond the optional
analyzers in `make static`, run it once after the targeted re-audit. Reproduce and fix
its valid P0/P1 findings here, run affected tests, and record the exact command and
result. Missing optional tooling is reported as not run, never as a pass.

## Verify and finish

Read `AI/prompts/final-release-readiness.md` for the candidate-bound release
procedure, and apply it as the closing phase of this same milestone and session.
Complete the consolidated record through its findings, corrections, targeted
re-audit, and scanner sections; leave only candidate-bound verification fields to be
filled from the commands that follow. Set the milestone to `REVIEW` and commit the
final implementation and substantive audit record. From the clean primary checkout
run:

```sh
make milestone ID=<ID>
```

Take the full SHA verified by that successful command and, without changing code or
configuration, run:

```sh
make release CANDIDATE=<verified-full-SHA>
```

Release success is `READY_FOR_HUMAN`, not a milestone status and not permission to
publish. Diagnose a gate failure, fix the underlying defect, and repeat the necessary
audit/test/verification steps against a new committed candidate; never weaken a gate.

Complete the audit record's candidate-bound verification section and write the compact
handoff with the exact SHA, commands, exit codes, report paths, result-bundle counts,
consolidated audit path, release verdict, and outstanding manual rows. Set the
milestone to `DONE`, update `AI/PROJECT_STATUS.md`, commit those continuity records,
and run `make static`, `./Scripts/project-status.sh validate`, and
`./Scripts/project-status.sh continuity <verified-full-SHA>` on that commit, so the
commit is proven to carry exactly the candidate's build inputs. Then stop. Start no next
milestone and no second audit cycle.

`READY_FOR_HUMAN` hands the candidate to the developer for the subjective product
review, the pending manual checklist rows, Product > Archive, Organizer validation,
and distribution. Nothing in this workflow uploads, submits, archives, or publishes.
Optional independent milestone review and the independent Release Auditor remain
optional and are never retrofitted into this session as another gate.
