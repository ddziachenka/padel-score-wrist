# M00 — Template bootstrap

**ID:** M00
**Status:** PLANNED
**Depends on:** none
**Validation:** make milestone ID=M00
**Handoff:** AI/handoffs/M00-handoff.md

## Objective

Connect a real Xcode product to the template and prove the local build, test, and
release harness before product features begin.

## Scope

- The developer creates the product project or workspace under `App/` in Xcode, with
  a shared scheme and at least one real test target; Xcode work is theirs, and the
  template does not generate or shape it. If `App/` holds no project when this
  milestone starts, set `BLOCKED`, name that step on the `**Blockers:**` line of
  `AI/PROJECT_STATUS.md`, and stop until it exists. A Git repository Xcode created
  inside `App/` is not kept: this repository tracks those files itself, and
  `make static` and every build gate refuse a nested one.
- Connect that project to the harness: add a real unit test and include UI tests when
  the product uses them.
- Generate committed project configuration and record the actual toolchain.
- Select `--platform iOS` or `--platform watchOS`. Watch-only uses the modern
  SwiftUI Watch app plus Xcode’s packaging container, a shared scheme that builds
  both, and a real Watch test target. APP_TARGET and BUNDLE_IDENTIFIER name the
  Watch executable. No user-facing iPhone companion or paired simulator is added.
- Prove clean-HEAD milestone verification, exact-SHA integration behavior, and that
  release refuses a product before its final audit workflow is complete.
- Keep Git hooks optional, and develop this milestone in the primary checkout.

## Non-goals

- No product feature, third-party dependency, remote CI, or automatic hook install.
- No worktree for this milestone: milestone implementation and verification stay in
  the primary checkout. Optional review, experiment, and localization worktrees are
  outside M00 scope.
- No weakening of template checks to accommodate the product.

## Acceptance criteria

Each of these is about *this product*. The template's own behaviour — that a gate
rejects zero, failed, skipped, missing or inconsistent result counts, that a
candidate must be a full SHA, that release success requires completed audit coverage
and readiness state, that an unverified commit pushes without a gate, that no pre-push
hook exists, and that a candidate snapshot is always cleaned up — is proved
by `make self-test` in the template repository, whose regression cases assert those
behaviours against deliberately broken fixtures and stub Xcode tooling
(`./Scripts/self-test.sh --list` prints the current set; the run reports its own case
and check totals). Re-proving it here would mean breaking this product's suite five
ways on purpose, and `make self-test` is a template-maintenance command: its fixtures
copy the working tree, so it is not meant to be run inside a product repository.
Record the template commit instead and inherit the proof: initialization writes it to
`.iosai-project` as `template_commit=`.

- [ ] Product configuration uses managed simulator mode with installed device-type and
      runtime identifiers; `make simulator-setup` prepares its own device and
      `make simulator-context` names that checkout's UDID before any runtime check.
- [ ] For watchOS, the runtime/device are Watch-compatible; the built app has
      WKWatchOnly enabled, and its packaging container embeds it with matching
      version/build. Inspect launch and a primary interaction on the owned Watch
      simulator. The template self-tests do not establish this runtime evidence.
- [ ] `xcodebuild -list` shows the configured shared scheme and required tests.
- [ ] `make template-check`, `make static`, and `make fast` pass in product mode.
- [ ] From clean `REVIEW` state, `make milestone ID=M00` verifies current HEAD on the
      primary branch and records that branch, SHA, time, commands, and non-zero
      result-bundle counts.
- [ ] Explicit full-SHA reproduction — `make milestone ID=M00 CANDIDATE=<full-SHA>` —
      verifies that same commit from a detached read-only worktree.
- [ ] `make release CANDIDATE=<full-SHA>` reports `NOT_READY` because the final audit
      workflow does not exist yet; the template self-test proves the later
      `READY_FOR_HUMAN` path.
- [ ] If the developer has configured a remote, a commit is pushed to it without any
      gate running, confirming that push is synchronization here too. A remote is
      optional and initialization removes the template's; with none configured, the
      handoff says so and nothing is pushed.
- [ ] `core.hooksPath` is unset unless the developer chose otherwise, and no worktree
      was created to get here.
- [ ] `.artifacts/` is ignored and holds the reports these runs produced.
- [ ] `./Scripts/project-status.sh validate` passes.
- [ ] `AI/ARCHITECTURE.md` records the real toolchain and deployment target.
- [ ] The handoff names the template commit this project was created from — the
      `template_commit=` line in `.iosai-project` — as the evidence for the inherited
      harness behaviours listed above.

## Validation

```sh
make milestone ID=M00
```

The Builder records exact evidence in the handoff, sets `DONE`, and stops.
Integration is run only when independently developed streams are combined, which is
outside this milestone.

## Handoff

Write `AI/handoffs/M00-handoff.md` from the compact handoff template. Include the
verified SHA, command, exit code, timestamp, report path, counts, known issues, and
next step.
