# M08 handoff

**Policy status:** current

## Milestone

M08 — Access and Purchase; status `BLOCKED` before implementation.

## Summary

The milestone selector returned M08, whose M07 dependency is DONE. Its explicit
entry condition H4 is unresolved: approval of the overall direction did not choose
a commercial model. Recorded the human decision blocker without changing app code.

## Changed files

- `AI/milestones/M08-access-purchase.md` — BLOCKED status.
- `AI/PROJECT_STATUS.md` — current milestone and exact H4a choices.
- `AI/DEVELOPMENT_PLAN.md` — reflects the blocked current milestone.
- `AI/handoffs/M08-handoff.md` — decision and validation record.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | No milestone candidate verified. Baseline: `9ebf054fa19e9b06828f4702d9509cc4e981239c`; documentation checks ran on the working tree above it. |
| Exact command | `./Scripts/project-status.sh next`; `./Scripts/project-status.sh validate`; `make static`; `git diff --check` |
| Exit code | 0 for each command |
| Timestamp | 2026-10-21T11:22:36Z — validation in progress |
| Report | This handoff and command output in the chat; no milestone report or result bundle |
| Counts | 0 app builds/tests executed; no result-bundle counts. `make milestone ID=M08` not run because H4 blocks implementation and there is no REVIEW candidate. |

## Tests

No tests added or changed: only workflow records changed. Self-review confirmed
the blocker against PRODUCT H4a–H4d, M08 scope, and WORKFLOW's human-decision rule.
Static checks passed; optional linters, template-only README structure and
unconfigured site identity checks reported their configured skips, not passes.

## Known issues

M08 cannot select monetization, a price, a trial quota/unit or reset policy for the
owner. Other recorded blockers remain: H1 public particulars for M09, minimum
watchOS runtime coverage, and App Store Connect name availability.

## Next step

Owner chooses H4a: (1) free trial then one lifetime unlock (Recommended: matches
the recorded product direction), (2) fully free v1, monetization in a later task,
or (3) paid download with no trial. Paid choices also need an approved price;
trial needs the explicit quota, counting unit and reset policy. Record the chosen
contract before resuming M08 as IN_PROGRESS; do not start M09.
