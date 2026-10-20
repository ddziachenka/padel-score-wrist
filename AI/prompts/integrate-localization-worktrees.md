# Combine finished localization worktrees into main

Use this once two or more languages have been localized in parallel and every one of
those sessions has stopped. This session integrates finished work: it adds no
translation of
its own, and a language that is missing or wrong when it arrives is missing or wrong
when this session ends. The fix for that is a new session for that one language, in
its own worktree.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Run `git worktree list` and `git branch --list 'localization/*'`, confirm you are in
   the main checkout, and read the tip commit message of every localization branch.

## Record what exists before you touch main

Write down, for every language, its branch, its worktree path, its tip commit's full
SHA, and the main commit it was cut from. An integration whose inputs were never
recorded cannot be reproduced, explained, or undone.

Treat a worktree as ready only when its changes are scoped to one locale and it
carries that language's finished commit. Leave a stale or experimental worktree out,
and say in the report which ones you left out and why.

Main must be clean, and must still be the commit those branches were cut from. If it
has moved, stop and say so: those languages were validated against a product that has
since changed.

## Integrate one language at a time

Integrate in a fixed order, one language at a time, and finish each before starting
the next. The per-language commits were made independently from the same baseline, so
conflicts in shared localization infrastructure are expected rather than a sign that
something went wrong — string catalogs, locale registries, tests, locale lists, route
tables, generated resources that are committed, and UI test expectations are where
they land.

Prefer one integration commit. Applying each language without committing, resolving as
you go, validating the combined tree once, and then committing gives the gate a single
candidate and history a single entry to revert:

```sh
git cherry-pick --no-commit <full-SHA>
```

Use another safe approach if the repository's state makes that one wrong. What must
hold either way is that every source language stays traceable, no language is lost,
the combined tree is validated before the commit, and main ends with one clear
integration commit where that is practical.

Resolve every conflict on its meaning. In a file that carries data for more than one
language, taking one whole side is wrong by construction, because one of those two
sides is a language being deleted — so taking `ours` or `theirs` wholesale is
forbidden there. Keep the entries from both sides and reconcile the structure around
them by hand. If one branch added Spanish to a catalog entry and another added German,
the integrated entry carries English, Spanish, German, and every language that was
already there. Route tables, tests, manifests, and locale arrays follow the same rule.

Where two languages changed something that is not locale data, decide it once on the
merits against `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`, and `AI/DESIGN.md`, not by
preferring whichever language arrived first. Do not change English copy or product
behavior while resolving, and do not reopen a completed milestone. A localization
defect that only the combined tree reveals is fixed here.

Never amend, rebase, force-update, or delete another language's branch. Those branches
are the only copy of work this session did not do.

## Verify the combined commit

```sh
integration_sha="$(git rev-parse HEAD)"
make integration CANDIDATE="$integration_sha"
```

That is the gate for this work. In a product repository it verifies the exact combined
SHA with static checks, a Debug build, and the complete shared scheme including the UI
tests — which is what a tree holding every language at once needs, and what no
single-language session could have run. A failure belongs to the combined stream: fix
it here, commit, and verify the new SHA. Never weaken the gate, never run it against a
dirty tree, and never treat a push as evidence.

## Combined validation

List every language the product now ships and confirm each one is present everywhere
it belongs. Scan for missing translations, strings that fell back to English, values
a conflict resolution deleted, duplicated keys, malformed catalog data, a locale
registered in one place and not another, and routes that no longer resolve.

Then run the app once per language and confirm each still reads the way its own
session left it, walking onboarding, the primary journeys, settings, history, the
paywall, and the error and recovery states. Exercise the shield, notification, and
Live Activity text where the product has them and they can be observed. Open every
localized `/privacy`, `/support`, and help or legal route, confirm the app's own links
reach the right language, and confirm the terms route still leaves the site for
Apple's Standard EULA, untranslated and unduplicated. Fix every integration
regression, re-run whatever the fix touched, and verify the final SHA again if you
committed one.

Publishing comes last, and only once every expected language is integrated and the gate
has passed on the final commit: a half-integrated site offers one language a page the
others do not have. Deploying with `make site-deploy PRODUCTION=1` stays the
developer's step, as publishing does everywhere else in this workflow, and never runs
from a language's worktree. If the developer publishes while this session is still
open, open the live localized routes afterwards and confirm each one resolves in its
own language.

## Finish

`git status` must be clean when you stop, with no worktree left mid-apply and no
language half-integrated. Leave the source worktrees and branches in place;
`./Scripts/remove-worktree.sh de` is the developer's call, and it takes either the
locale or the worktree's path.

Then report every language integrated with its branch and tip SHA; the base main
commit and the integration commit's full SHA; the worktrees you left out and why;
every conflict and how each meaningful one was resolved; the gate command, its exit
code, its report path, and its counts; what the per-language run and the missing-value
scan found; the site validation and whether it was published; and any blocking
environment or product decision. Required validation cannot be deferred.

Close the report by telling the developer that main has moved past the commit
`Final Product Polish` verified, that this integration commit is what now
represents the shipping product, and that establishing the next release candidate is
their decision when they choose to ship. Adding a language reopens no milestone and
this session runs no release gate. Note too that the shipped-language rows in
`Config/release-requirements.v3.tsv` are no longer inapplicable to a product that
ships more than one language.
