# M25 final development preflight

App/test source `f097a52d6a1154cf431156c30a81013a34d3cd47`, main. This is mutable
Builder preflight before the clean REVIEW candidate; it is not milestone or
release verification. The exact full `make milestone ID=M25` still remains required.

| Exact command | Exit | Evidence |
| --- | --- | --- |
| make static | 0 | Completed2026-10-31 around02:38UTC, all configured checks pass; optional SwiftLint/SwiftFormat/Shellcheck disabled and not run. |
| Scripts/project-status.sh validate | 0 | Milestones/dependencies/compact project status valid. |
| bash .artifacts/M25/finalize-materials.sh | 0 | New gallery4 pair imported,28 creatives regenerated, site prepared, strict provenance/format/source checks and make site-check pass. |
| python3 .artifacts/M25/check-site-layout-identity.py | 0 | Final52 HTML pages and CSS match the recorded208-combination browser proof source; site-layout-identity.json. |
| git diff --check | 0 | No whitespace errors. |
| Scripts/simulator.sh run -- make clean-derived-data | 0 | Removed only computed checkout cache /private/tmp/padel-score-1acada2a5b10/DerivedData,413MB; .artifacts evidence preserved. |
| Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/prepare-milestone-phone.sh | 0 | Reserved owned B9D3F5BC-7C0B-4F3B-A65F-3C1B67ACCEF2; Dark compositor initialized by rebooting only this device, original appearance/boot state restored. |

Owned phone preparation finished `2026-10-31T02:41:05.107946+00:00`. Original state was
Booted/light; preparation and restoration exits are
both0. Raw record: .artifacts/M25/milestone-phone-preparation.json. No erase,
global service restart or data deletion. Actual native Light/Dark pixel assertions
remain mandatory in the complete gate; preparation is not a theme-test pass.

All14 Watch,14 phone and14 creative final contact sheets were visually inspected;
[material review](materials-review.md) bounds that proof. Scoped native summaries,
exact source/times/device configurations and counts are in
[native-supplements.json](native-supplements.json). The additional current StoreKit
probe stays FAILED/P2 with exact baseline reproduction; it is not accepted as a
passing component. All physical proof remains PENDING_M29. No release approval,
external reply, upload, submission, price change or site publication is claimed.

## Second exact-gate preflight after traversal repair

Reviewed App/test source `4720028cffdabc4082385506578f8af25c61450d` preserves
all shipping f097 gallery4 inputs. The bounded current-runtime native regression
passes1/1 definitions/invocations, exit0, zero adverse native counts, with exact
commands/time/summary in native-supplements.json. Development minimum regression
also passes1/1 after its reproduced failure; compiled test patch identity is
recorded in minimum-gesture-audit-traversal.md. Neither substitutes for the full gate.

`make static > .artifacts/M25/audit-fix-static-2.log 2>&1` passes, exit0;
`Scripts/project-status.sh validate` passes, exit0. The first repair static attempt
returned Make2 because the new Blockers field exceeded the unchanged600-byte
limit; that compact field was shortened, then the exact static check reran and
passed. Raw `.artifacts/M25/audit-fix-static.log` remains failed evidence.
`git diff --check` and strict active gallery4 validation pass, exit0.

`Scripts/simulator.sh run -- make clean-derived-data` passes, exit0, removes
only `/private/tmp/padel-score-1acada2a5b10/DerivedData` (437M); .artifacts and all
other caches/data remain. `Scripts/simulator.sh --profile companion run -- bash .artifacts/M25/prepare-milestone-phone-2.sh`
passes, exit0: only owned B9/iOS17 Dark compositor initialization and own reboot,
then original Booted/light restored, restoration0, UTC
`2026-10-31T07:41:16.008267Z`. Raw record:
`.artifacts/M25/milestone-phone-preparation-2.json`. No pending restoration, erase,
foreign device or global service reset. Actual theme-pixel/audit assertions remain
mandatory in the new complete gate. M25 returns to REVIEW with all acceptance
boxes unchecked until that fresh exact committed candidate passes.
