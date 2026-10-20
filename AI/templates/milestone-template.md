# MNN — Milestone title

**ID:** MNN
**Status:** PLANNED
**Depends on:** none
**Validation:** make milestone ID=MNN
**Handoff:** AI/handoffs/MNN-handoff.md

## Objective

One observable outcome.

## Scope

- Work required for the objective.

## Non-goals

- Work explicitly deferred.

## Acceptance criteria

- [ ] User-visible or machine-verifiable behavior.
- [ ] Tests fail when the behavior regresses.
- [ ] The declared validation command passes at clean `REVIEW` HEAD.

One Builder session carries this milestone to `DONE`. There is no review-gating
field: an extra independent review is optional and is never a precondition.

When milestone test arguments deliberately narrow the suite, add both fields:

```text
**Milestone test arguments:** <exact arguments>
**Test scope rationale:** <why the narrower run is sufficient>
```

The one final `Final Product Polish` milestone uses this same shape, depends on every
implementation milestone required for release, and adds two fields and four criteria:

```text
**Audit prompt:** AI/prompts/final-polish.md
**Audit record:** AI/audits/MNN-final-polish.md

- [ ] One Builder session ran all six domains in the required order, fixed every
      valid P0/P1, and made only clearly beneficial low-risk P2 changes.
- [ ] One targeted re-audit covered changed behavior and did not start another pass.
- [ ] The one consolidated record has COMPLETE coverage and Open P0/P1 0, includes
      every applicable typed row in all six domains, and states findings, fixes, deferred P2,
      INAPPLICABLE capabilities, FUTURE_PRODUCT_IDEA, and exact evidence.
- [ ] make release CANDIDATE=<verified-full-SHA> reports READY_FOR_HUMAN for the
      verified commit.
```

A milestone appended after that plan is finished uses this same shape with nothing
added: the next sequential ID, `PLANNED`, and a dependency on the milestone that
finished last. A `Release Readiness Revalidation` milestone is one of those — it
depends on the follow-up work whose candidate it establishes, follows
`AI/prompts/final-release-readiness.md`, and requires `READY_FOR_HUMAN` for its own
new SHA.

For revalidation, also declare each affected domain and its completed targeted audit:

```text
**Revalidated domains:** functional,ui-ux
**functional revalidation record:** AI/audits/MNN-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/MNN-ui-ux-revalidation.md
```

A targeted audit uses `AI/templates/domain-audit-template.md`; its milestone names
that domain's prompt and record and completes its full applicable coverage. The
revalidation milestone itself names no `**Audit prompt:**`: an audit prompt is either
`AI/prompts/final-polish.md` or one domain's `AI/prompts/audit-<domain>.md`, always
together with its `**Audit record:**`.

The fenced blocks above are examples. Fields are read only outside fences, so copy
the lines you need out of a block rather than leaving them inside one.
