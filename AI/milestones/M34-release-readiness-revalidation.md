# M34 — Release Readiness Revalidation

**ID:** M34
**Status:** DONE
**Depends on:** M33
**Validation:** make milestone ID=M34
**Handoff:** AI/handoffs/M34-handoff.md
**Revalidated domains:** functional, ui-ux, content, accessibility, product, release
**functional revalidation record:** AI/audits/M33-functional-revalidation.md
**ui-ux revalidation record:** AI/audits/M33-ui-ux-revalidation.md
**content revalidation record:** AI/audits/M33-content-revalidation.md
**accessibility revalidation record:** AI/audits/M33-accessibility-revalidation.md
**product revalidation record:** AI/audits/M33-product-revalidation.md
**release revalidation record:** AI/audits/M33-release-revalidation.md

## Objective

Establish fresh exact-candidate release readiness for the serve-side build after
DONE M33's audits, physical acceptance and local material preparation.

## Scope

Follow AI/prompts/final-release-readiness.md. Verify complete current six-domain
coverage, build/material identity, owner-authorized reuse of the complete M33 gate and fresh
exact-SHA release-specific checks. Preserve historical failure and physical-evidence limits.

## Non-goals

No inherited affected-only waiver, App Review submission, upload, price change or
publication. Build 7's withdrawal and monitor hold remain historical facts.

## Acceptance criteria

- [x] M33 is DONE with complete applicable six-domain coverage, affected physical
      acceptance and zero open P0/P1 findings.
- [x] Owner-authorized M33 reuse validates complete native coverage and unchanged
      inputs at clean REVIEW/main.
- [x] Fresh release-specific checks report owner-authorized READY_FOR_HUMAN for
      the same exact SHA, with commands, exits, reports and counts in the handoff.
- [x] Static/status/continuity validate the DONE record; candidate-bound human
      checklist rows are reported honestly and distribution remains the owner's decision.

Owner approved this split on 2026-11-07; AI/evidence/M33/planning-blocker.md.

## Current validation exception

The fresh [owner instruction](../evidence/M34/owner-verification-reuse.md) permits
reuse of complete M33 verification only for identical inputs. Actual command:
`/Applications/Xcode.app/Contents/Developer/usr/bin/python3 .artifacts/M34/reuse-validation/run.py --candidate <FULL_SHA>`.
Keep all unique release-specific checks and post-DONE closure. Generic Validation
metadata remains for parsers; original full M34 make commands are not executed
or claimed passed. This is a new M34 decision, not an inherited waiver.
