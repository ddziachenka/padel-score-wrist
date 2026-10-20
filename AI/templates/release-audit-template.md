# Release record

**Policy status:** current
**Policy:** `solo-workflow/2`
**Record type:** developer release record, or optional independent release audit
**Candidate:** full 40-character SHA
**Recorded by:** the developer, or the auditor's name or fresh session
**Recorded at:** UTC ISO-8601

Two uses share this form, one file each as `AI/audits/release-<version>.md`. The
developer writes the release record once the human checklist is complete, because the
checklist and the release report otherwise live only in ignored `.artifacts/`. An
optional independent Release Auditor uses the same form for a second opinion.

## Verdict

`RECOMMEND_DISTRIBUTION` or `DO_NOT_DISTRIBUTE`.

In a developer release record this is the developer's own distribution decision. From
an independent Release Auditor it is advice, and it never replaces that decision.
Neither changes the release gate or uploads a build.

## Candidate evidence

| Field | Evidence |
| --- | --- |
| Release verdict | `READY_FOR_HUMAN` or other |
| Exact command and exit | command; numeric exit |
| Release report | path bound to candidate |
| Human checklist | candidate-bound copy; pending/completed steps |
| Audit coverage | `COMPLETE` or the report's exact failure |
| Build/test counts | exact values |

## Human checklist

The three `HUMAN-0N` rows exactly as they stand in
`.artifacts/release-checklists/<full-SHA>/checklist.md`. An independent audit copies
them as it found them and treats every `PENDING` row as not performed.

## Findings

| ID | Severity | Location | Reproduction and required correction |
| --- | --- | --- | --- |
| — | — | — | No findings |

## Distribution readiness

Record checks for product journeys, privacy and permissions, purchases,
accessibility, localization, upgrade behavior, channel rules, store presence, and
the release report's coverage result.

## Distribution recommendation

State whether the evidence supports distribution and name any blocking finding.
