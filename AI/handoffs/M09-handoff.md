# M09 — Legal and Support

**Policy status:** current

## Milestone

M09 — Legal and Support; status **DONE**.

## Summary

Completed the prepared bundled Privacy/Terms/Support and four public English
pages. M08's recorded DONE resolves the former dependency blocker. Public
identity, retention, local storage and purchase terms match PRODUCT; readable
Watch addresses/contact and pre-purchase legal navigation pass runtime checks.
Reconciled stale H1-open references with the existing owner approval. No production
code, tests, product behavior, public deployment or App Store state changed in
this completion session. Historical preparation evidence is preserved verbatim in
[M09-preparation-handoff.md](M09-preparation-handoff.md).

## Changed files

- `AI/milestones/M09-legal-support.md`, `AI/PROJECT_STATUS.md` — resume and complete
  M09 from its own verification evidence.
- `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, `AI/DEVELOPMENT_PLAN.md` — reconcile resolved
  H1/M08 prerequisites with approved PRODUCT and current evidence.
- This handoff and the preserved preparation handoff — exact completion evidence
  without replacing the historical results.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | `e22172fa05838c0cfb5abe124ec382cd0ce80787`, clean main |
| Verified SHA | `1105a96720bc85114bd7f8f5c5785415f7efa235`, clean REVIEW on main |
| Exact command | `make milestone ID=M09` |
| Exit code | **0**; Debug build and full shared scheme passed |
| Timestamp | Gate 2026-10-22T07:58:38Z–08:39:44Z; test bundle 07:58:56.482Z–08:39:31.305Z |
| Report | `.artifacts/milestone/M09/20261022T075837Z-45453/report.md` |
| Result bundle | `.artifacts/milestone/M09/20261022T075837Z-45453/milestone.xcresult` |
| Counts | **387 total, 387 passed, 0 failed, 0 skipped, 0 expected failures**: 328 unit/policy + 4 StoreKit + 55 UI |
| Environment | Xcode 27.1 (27A9275); managed SE2 40mm, watchOS 26.1; UDID A7CBB23C-F823-4850-BE4B-CAD76922DD08 |

Additional evidence under `.artifacts/M09-completion/`:

- `make site-check`: exit 0, `site-check.log`; `make static`: exit 0,
  `static-before-gate.log`. SwiftLint/SwiftFormat/ShellCheck did not run because
  Config disables them; no additional problem scanner is configured.
- `python3 .artifacts/M09-completion/check-live.py`: exit 0, `live-check.log` and
  `live-pages.json`. Four approved public URLs return HTTP 200 and byte-match
  `Web/public`; Apple EULA, Apple/Cloudflare privacy and refund/sign-in pages
  respond. Headers and bodies retained. Initial urllib request returned 403;
  the ordinary curl client verified successfully; the failed request is not a pass.
- Focused runtime command: `legal-runtime.command` (exact invocation); exit 0,
  **8 passed / 0 failed / 0 skipped** (five UI + three configuration),
  `legal-runtime.xcresult`, `legal-runtime-summary.json`, `legal-runtime.log`.
  UTC 2026-10-22T07:52:19.638Z–07:56:36.244Z. Same app/test source as verified SHA;
  the completion diff contains only AI Markdown.
- Gate transcript: `milestone-verified.log`; result readback:
  `milestone-summary.json`. Exact xcodebuild commands also live in the gate report.

## Tests

Retained the prepared Bootstrap/Access regressions for reachable public URL,
email, full Apple EULA label, system Back, Terms before purchase, largest-text
Privacy, retained draft/result on dismissal and playable Resume after the quota.
The complete scheme passed without narrowing, retries, weakened assertions or skips.
Builder self-review covered the prepared code/site/config and baseline-to-tip
completion diff; the only correction was stale approved-decision documentation.
Exported runtime screenshots (`screens/`) were inspected: Privacy/Support
addresses/contact, Terms EULA and largest-text Access wrap and scroll readably on
40mm. Native typography/scrolling is appropriate; no bespoke asset or motion is
needed. Legal text is bundled and makes no network request. This is self-review,
not independent review or release approval.

## Known issues

- First `make milestone ID=M09` stopped at the ignored-input guard: make exit 2,
  verifier 65, before build/tests (`milestone.log`). Eight unrelated IDE files under
  `App/.idea` were preserved byte-for-byte at
  `.artifacts/M09-completion/preserved-App-idea/`; original paths/SHA-256 hashes
  are in `preserved-ide-hashes.json`. They remain outside App so the strict gate
  can run. No user file was discarded, edited or committed.
- A sandboxed simulator query and xcresult export lacked host access; the same
  operations succeeded with authorized host access. These were tooling failures,
  not failed app tests.
- No known M09 blocker. This gate uses watchOS 26.1; minimum-OS, physical spoken
  VoiceOver, haptics, on-court/lifecycle and other release coverage belong to M10.
  Prior partial release preparation is not a completed final audit.
- REL-208 and REL-209 are INAPPLICABLE for this standalone Watch-only product:
  neither rating-request flow nor manual rating entry is required. No rating API
  exists; M10 must carry these specific dispositions into final audit evidence.
- Ignored reports, result bundles and preserved IDE files are local evidence and
  are not backed up by the continuity commit. No App Review submission occurred.

## Next step

M10 — Final Product Polish, in a new session using `AI/prompts/final-polish.md`.
Stop after M09; release readiness and submission remain separate decisions.
