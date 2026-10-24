# M16 self-test fixture provenance

The full self-test invoked directly in the product checkout consumes product-owned documents as though they were an uninitialized universal template. M00 already documented this incompatible input and a separate reconstruction; its recorded temporary reconstruction SHA is not available in this Git object database. The unmodified `make self-test` was reproduced at baseline feed3ea7ceb1f5c2ce08075b434dbca4ed9a718f in /private/tmp/padel-m16-selftest-baseline: Make exit2 / script65, 97 cases, 1868 checks passed and 262 failed. Report: .artifacts/M16/self-test-baseline-feed3ea.log. The failures include product DONE M00 used as a PLANNED fixture, duplicate original/product milestones, existing initialization marker and absent generic English template wording. They predate M16; this is now reproduced evidence, not an inference. The first development run in the mutable product checkout was additionally invalidated by editing the executing harness; it is not a passing or exact-source run.

The first local import bc0ccd55b9893d2ee863f8d85e29f339e465a937 contains the universal English contracts, original PLANNED M00, no application and the template site. The new tooling_fixture_source_commit marker binds synthetic fixtures to this available ancestor. fixture_copy exports that tree, removes the product brief handoff identified by M00, and overlays the current shell/lease tooling, Makefile, config schema, requirements and pre-commit hook. Product Swift, translations, completed milestones and app-specific Python checks are not template fixture inputs. The actual product static gate continues to run those app-specific checks.

No assertion, skip rule, required test or gate outcome was relaxed. New companion-profile tests construct their own fake profile. Immutable candidate runs can reconstruct the same seed from the shared Git object database; a missing or invalid source commit fails closed.

## Owner-approved complete fixture run

The owner explicitly approved the temporary M00 procedure without assertion changes. The first all-source reconstruction incorrectly included Padel-specific Python guards without their actual App/store assets; its run was aborted and diagnostic outputs preserved. The corrected universal fixture includes byte-identical shell/Perl tooling and original English template inputs. Padel-specific Python validators and regressions run unchanged in primary `make static` and `make site-check`; they are not generic fake-project inputs.

Fixture084b34f4cb7b17fe9210c6be253700344cc9e248 completed98 cases:2153 checks passed,1 failed (Make2/script65; `.artifacts/M16/self-test-approved-generic-full.log`). The failing synthetic cleanup probe copied common/platform/simulator/lease modules but omitted the new companion.sh dependency sourced by common.sh. Baseline feed3ea passed this exact case, so this is an M16 fixture dependency regression, not a pre-existing failure. The correction adds companion.sh to that synthetic fixture's module copy. Every assertion stays unchanged; the probe must actually plant and clean its cache root. Targeted and complete corrected runs follow.

## Recorded passing runs

- Corrected initial M16 tooling at `eb50a028c87bc5e523cc34096c46a581dbbd6690`:
  fixture `a0ab5cc52df6d3eed7541b4fd2b63c6b3677de66`, `make self-test` exit0,
  98 cases/2155 passed/0 failed (`self-test-approved-corrected-full.log`).
- Self-review then reproduced a separate readiness regression: current companion
  rating applicability was incorrectly imposed on the historical Watch-only M10
  audit. Baseline feed3ea accepted that audit; current code rejected it. The new
  transition regression requires six current domain records and an exact historical
  Verified SHA/configuration; it rejects missing/ambiguous source, an actual
  companion source falsely claiming a Watch-only exception, partial domain coverage
  and missing current iPhone rating evidence. Targeted six checks passed.
- The first complete run with that new case failed99 cases (1874 passed/281 failed):
  a newly introduced `printf ... | grep -Eq` tripped the existing pipeline-early-exit
  guard and cascaded into fixture gate failures. This was our new defect. The fix
  removes grep's early exit and drains the same input; no assertion changed.
- Final generic source checkpoint `b2a30e091d423d3414a59d1d2c9c2a65daeb59e5`,
  byte-matched fixture `76aa09b05613156708b304bdc65bf4ed8911c0e6`:
  **`make self-test` exit0,99 cases/2161 passed/0 failed**, log completion
  2026-10-24T13:51:43.750295Z, `.artifacts/M16/self-test-approved-final-corrected.log`.
  All28 generic tooling files were hash-compared again after the run. Committed
  provenance: `AI/evidence/M16/tooling-fixture-manifest.json`.

New product-specific iPhone gallery validation runs in primary static/site checks;
it is not copied into the universal fake-project fixture. Actual device/simulator
suites and the exact M16 milestone gate remain independently required.
