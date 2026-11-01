# M29 full-gate preparation review

**Date:** 2026-11-01
**Inspected HEAD:** `1367217b30ce0c5ffa2c464ea977786e28139439`
**Scope:** delegated read-only preparation; not a gate result or release approval.
Only this report was written. No simulator, UI, build, tests, Git mutation, or
configuration change was performed. HEAD stayed frozen for the gallery captures.

## Before the expensive command

The declared command remains exactly `make milestone ID=M29` in the primary
checkout on `main`. Do not use historical candidate mode to evade dirty state.

1. Finish the frozen-source galleries and their validation before committing
   material/evidence changes. Current HEAD is the primary checkout on `main`;
   `.git` and common Git directory both resolve to `.git`.
2. Set M29 to `REVIEW` and commit all intended work. It is currently
   `IN_PROGRESS`, which the gate rejects before static checks/builds. Untracked
   review/reconciliation files also cause an earlier clean-tree refusal; this
   report itself must be included or deliberately removed before invocation.
3. Keep HEAD and the tracked/untracked checkout clean throughout the run.
   Final success repeats both checks; no new evidence Markdown may be created
   under `AI/` mid-gate. Gate output belongs under ignored `.artifacts/`.
4. Run `make static` on the final candidate before spending hours in the full
   gate. It includes project-status and offline site checks. A separate
   `./Scripts/project-status.sh validate` passed here, exit 0. No full static
   pass is claimed by this preparation review.
5. Complete the M29 contract's six current domain records before treating a
   passing automatic command as milestone completion. All six M29 records were
   absent at inspection. M29 has no `Audit prompt`/`Audit record` fields;
   `verify-milestone.sh` therefore does not itself invoke the domain coverage
   validator for this milestone. The acceptance requirement still applies.

No hidden tracked inputs were found (`git ls-files -v`: zero lowercase/S flags).
Ignored files under protected directories consisted only of `.DS_Store` and the
two expressly tolerated Xcode interface-state/scheme-order files. No prohibited
ignored build input was found in that inspection. The gate will check again.

## Six-domain format and checks

Use `AI/templates/domain-audit-template.md` separately for:

| File suffix after `AI/audits/M29-` | Domain | Required app-store rows |
| --- | --- | ---: |
| `functional-revalidation.md` | functional | 34 |
| `ui-ux-revalidation.md` | ui-ux | 22 |
| `content-revalidation.md` | content | 13 |
| `accessibility-revalidation.md` | accessibility | 8 |
| `product-revalidation.md` | product | 19 |
| `release-revalidation.md` | release | 32 |

Each standalone record requires exactly one `**Coverage result:** COMPLETE`,
one `**Open P0/P1:** 0`, and exactly one `## Coverage` section. Include every
assigned/channel-applicable row exactly once and no extra domain's rows. Row form:

```text
- REL-NNN | OUTCOME=VERIFIED | EVIDENCE=<concrete command, environment, or observation>
- REL-NNN | OUTCOME=INAPPLICABLE | EVIDENCE=reason=<specific permitted product reason>
```

`VERIFIED_DIGITAL`, `PENDING_M29`, and `OWNER_ACCEPTED` are not supported typed
coverage outcomes. Actual owner acceptance can be stated accurately in concrete
evidence; it must not invent measurements or imply unrelated checks occurred.
`INAPPLICABLE` requires schema permission and cannot mean missing hardware,
account, service, or other required environment. Because this is a companion
product, REL-208/209 do **not** get the Watch-only rating-flow exception.

Retain template context, candidate/build/environment identity, findings/fixes,
deferred P2, targeted re-audit and exact validation fields. The parser's limited
syntax checks do not establish the truth of an evidence statement.

Once the records exist, the existing read-only functions can validate all six
explicitly, without altering or bypassing the full gate:

```sh
bash -c '
set -euo pipefail
. ./Scripts/lib/common.sh
load_project_config
validate_release_coverage_schema
for domain in functional ui-ux content accessibility product release; do
  validate_domain_audit_coverage \
    "$IOSAI_ROOT/AI/audits/M29-${domain}-revalidation.md" "$domain" app-store
done
'
```

The schema validation and exact required-row enumeration were run read-only here,
exit 0. The six record validators were not run against absent records.

The six ordered `## Coverage: <domain>` headings belong to the **consolidated
Final Product Polish** format, not these six standalone M29 records.

## Gate runtime and contention

The existing full runner executes in this order:

1. Contract/dependencies, static checks, configuration and test-scope validation.
2. Managed Watch Debug build, packaging guard, complete `PadelScore` suite.
3. Release Watch lease, load committed `Config/companion.env`, acquire companion
   lease, Debug build/packaging, complete `PadelScorePhoneUnit`, then complete
   `PadelScorePhone` UI suite.
4. Strict native result counts and final unchanged-source/clean-tree checks.

Both committed profiles have empty `MILESTONE_TEST_ARGUMENTS`. Required result
bundles cannot be zero, missing, failed, malformed or skipped. No test retry,
filter, accepted-component substitution, or M25 exception applies to M29.

| Profile | Committed runtime / type | Existing manifest UDID |
| --- | --- | --- |
| Watch | watchOS 26.1 / Watch SE 40mm, second generation | `A7CBB23C-F823-4850-BE4B-CAD76922DD08` |
| Companion | iOS 17.0 / iPhone SE, third generation | `B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2` |

The two manifests match the committed profiles and primary-checkout owner.
Installed runtime/device availability was not queried; the gate checks it live.
Other current/minimum runtime supplements are scoped evidence, not additional
profiles automatically invoked by this full command.

Both profiles reserve the same `checkout:/Users/Shared/D/ios/padel-score`
resource, in addition to their device. A second ordinary wrapper/gate cannot run
alongside the first just because it addresses a different device. Contention
returns 75 (Make reports 2). Release gallery/desktop reservations before invoking
the full gate; never bypass/nest the lease to force concurrency.

Safe parallel work is source/evidence review, gallery output inspection and
read-only analysis of completed bundles. Finish intended source/AI writes before
starting the full gate. Do not create milestone verification worktrees. Existing
Xcode test plans set all targets `parallelizable: false`; enabling parallel UI
execution would change the candidate and requires separate safety/validation,
so it is not an available zero-change acceleration here. Xcode's usual build
parallelism remains available through the existing build configuration.

## Historical elapsed time for planning

Comparable M25 candidate: `5eb65bbc17e9540d3922a520b44d3c8731947432`.

| Existing component | Logged native elapsed |
| --- | ---: |
| Complete Watch test command | 14,175.413 s = 3 h 56 m 15 s |
| Complete phone unit command | 6.267 s |
| Complete phone UI command | 8,235.376 s = 2 h 17 m 15 s |

Sources: `.artifacts/milestone/M25/20261031T083305Z-38339/test.log` and
`.artifacts/M25/phone-complete-same-candidate/companion/companion-{unit,ui}-tests.log`.
Each native command says `TEST SUCCEEDED`; the original monolithic M25 report
remains FAILED/130 and is not relabelled here. Its phone-only report records
2026-10-31T14:27:08Z–16:45:19Z including static/build overhead.

The historical sequential test sum is approximately 6 h 13 m 37 s. Allow roughly
6.5–7 hours for a comparable full M29 attempt including preparation/static/build
overhead, plus any failure correction and rerun. This is an estimate from existing
logs, not a promise: M29 adds tests, hardware load changes timing, and a failure can
require another exact-candidate run. Native gallery/material work and remaining
domain evidence are additional to that full-gate estimate. The subsequent
[canonical owner decision](owner-physical-acceptance.md) accepts every M29 manual
physical row without fabricated measurements/media; no further physical-device
action is required for this accepted manual scope. The automatic gate is unchanged.
