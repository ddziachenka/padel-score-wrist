# Milestone handoff

**Policy status:** current

## Milestone

`MNN` — title; status `DONE`.

## Summary

What changed and why.

## Changed files

- `path` — purpose.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | full 40-character commit |
| Exact command | command exactly as run |
| Exit code | numeric exit code |
| Timestamp | UTC ISO-8601 |
| Report | repository-relative artifact path |
| Counts | tests, failures, skipped, and any build counts |

## Tests

Tests added or changed and the regression each catches, plus what the self-review
found and how it was corrected.

## Known issues

`None`, or concrete non-blocking limitations and their impact.

## Next step

The next milestone ID, or the specific decision or dependency that must be
resolved first.

The Final Product Polish handoff adds its
`AI/audits/<ID>-final-polish.md` record, the release verdict for the verified
candidate, and the outstanding manual-row count. Its next step is the developer's own
review rather than another milestone. A later `Release Readiness Revalidation`
handoff records the same release evidence for its new SHA without altering the
historical final-polish handoff. These records are how later work sees that an older
`READY_FOR_HUMAN` verdict no longer describes `HEAD`.
