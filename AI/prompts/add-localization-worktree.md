# Add one localization in its own worktree

Use this after the last milestone, once per language, in a worktree of its own. The
product is already finished when this session starts, so the session translates, reads
its own work again, validates it in the running app, commits, and stops without merging
anything. Other languages may be running right now in their own worktrees from the same
baseline, and this session never touches them.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Run `git worktree list`, note whether this session started in the language's
   worktree or in the main checkout, take `<LANGUAGE>` and `<LOCALE>` from the message
   that started this session, then read `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
   `AI/DESIGN.md` — whose `## Localization` section settles tone, formality, plurals,
   and right-to-left — and the pages under `Web/`.

`<LANGUAGE>` is the language's English name and `<LOCALE>` its identifier: `German`
and `de`, or `Portuguese (Brazil)` and `pt-BR`. The branch, the worktree directory,
and the site route use that identifier lowercased — `localization/pt-br`,
`../<repository-directory>-pt-br`, `/pt-br/` — because Git refs are files and a macOS
filesystem usually cannot tell `pt-BR` from `pt-br`. The application's own resources
keep the identifier's own casing. One language per session: if the message named two,
do the first and stop.

## Before you translate anything

The milestones build one language, English, and `Final Product Polish` establishes
an English candidate. This session is what adds a second language, and it starts only
once all of that is behind it:

- every milestone the candidate depends on is `DONE` in `AI/PROJECT_STATUS.md`, the
  release readiness milestone that established it included, with no P0 or P1 open —
  a milestone appended after that candidate is later work and does not hold this up;
- that candidate reached `READY_FOR_HUMAN`;
- the developer asked for this language.

Stop and name whichever precondition is missing rather than assuming it. Translating
earlier means translating strings that are still about to change.

This language's branch is cut from the main commit that finished the last milestone.
Record that commit's full SHA now: the session that combines the languages needs it.

Localization is not a milestone. Do not create a milestone file, change any
`**Status:**` line, write a record under `AI/audits/` or `AI/handoffs/`, or run
`make milestone ID=<ID>` — there is no milestone ID for this work and the gate would
refuse it. Nothing here reopens, invalidates, or re-verifies a completed milestone.

## Isolation

This language belongs to a worktree of its own, cut from the completed main:

```sh
./Scripts/create-worktree.sh <locale>
```

The developer may have created it already and started this session inside it. If this
session started in the main checkout instead, create the worktree and continue there.
Either way nothing is translated in the main checkout. The script refuses an uppercase
locale and names the lowercase form to use, so `pt-BR` is rejected before a branch
exists rather than after a second one appears.

- Never edit, commit, rebase, or reset the main checkout or another language's
  worktree, and never merge this branch anywhere. Combining the languages is a
  separate session with its own prompt.
- Where a shared file already carries another locale's data — a string catalog, a
  locale registry, a test, a route table — add yours beside it and leave theirs byte
  for byte unchanged.
- Keep those edits minimal. Do not reformat a catalog, reorder unrelated entries,
  normalize another translation, refactor, or change English copy unless a genuine
  localization defect requires it. A shared file touched for convenience becomes a
  conflict somebody else has to resolve.
- A conflict you cannot avoid belongs to integration. Report it rather than reaching
  into another branch to prevent it.
- A broader product or copy problem is a finding for the developer, not a reason for
  this session to grow.

## What to localize

Every shipping surface a person can reach, where this product has one:

- Every screen, alert, sheet, menu, empty state, and error the app can show.
- Onboarding, the primary journeys, settings, history, and destructive confirmations.
- The paywall and its store messaging, and the purchase, restore, recovery, and
  failure text around it.
- Notifications, Screen Time shields and extensions, Live Activities, the Dynamic
  Island, and widgets.
- Accessibility labels, values, hints, and announcements. A translated screen with
  English VoiceOver labels is not localized.
- The app-owned routes under `Web/`, including `/privacy`, `/support`, and any help or
  legal page.

The App Store listing is not one of these surfaces. Its description, subtitle,
keywords, promotional text, What's New, and screenshot captions are authored and
translated in App Store Connect, by a workflow outside this repository, and this
session neither writes them nor creates a file to hold them.

English and every other locale stay exactly as they are, and no product behavior
changes: this session translates what the product already says and does. The terms
route links to Apple's Standard EULA in every language — link to that same Apple URL
and never translate, restate, host, or replace it, because no product here writes its
own licence.

## Translation quality

Translate meaning, not words. A sentence that is correct and still reads as a
translation has failed. The product should read as though it had been written in
`<LANGUAGE>` — natural, idiomatic, and concise, in the register a polished consumer
app uses on this platform.

- Preserve product meaning, positioning, privacy claims, warnings, feature semantics,
  and what each call to action asks for.
- Preserve every placeholder, interpolation, plural category, and formatting token.
  Never assemble a sentence from fragments to fit the grammar.
- Let dates, durations, numbers, currency, and units come from the locale rather than
  from English defaults.
- Use the platform's own terminology in `<LANGUAGE>` — the words the system itself
  uses for its own features.
- Right-to-left is layout as well as text: leading and trailing, mirrored directional
  images, mirrored navigation.
- Settle the terminology for recurring product concepts once, write it down as you go,
  and apply it everywhere, allowing the grammatical variation the language requires.

Short copy carries the most weight: onboarding headlines, the words for the product's
central concept, session and timer language, privacy statements, shield text,
warnings, buttons, destructive and recovery actions, and paywall copy.

## Read it again

When every key has a value, read every string again as a person who speaks only
`<LANGUAGE>` and knows nothing about this app. This pass is not optional and does not
move to another session: it is where a mechanically complete localization becomes a
written one.

Look for grammar, spelling, and punctuation; literal, machine-translated, or overly
formal phrasing; wording that is culturally odd; terminology that drifts between
screens; platform terms that are wrong; meaning invented or lost; a call to action
that no longer asks for the same thing; broken plurals, placeholders, or formatting;
and strings that quietly fell back to English. Fix what you find rather than record it.

## Validation

A complete key set is not a finished localization. This session is done when the app
has been run in `<LOCALE>` and every screen it reaches reads as though it had been
written in `<LANGUAGE>`.

1. Rescan the repository for missing `<LOCALE>` values, English fallbacks, strings
   still hard-coded in English, and locale resources that were never added.
2. Build and run with the device language set to `<LOCALE>`, then walk onboarding, the
   primary journeys, settings, history, the paywall, purchase and restore, errors and
   recovery, and every empty state.
3. Fix clipping, truncation, overlap, awkward wrapping, broken alignment, and labels
   that are simply too long at real translated lengths.
4. Check the smallest supported iPhone, the largest Dynamic Type size, light and dark
   appearance, and — for a right-to-left language — the mirrored layout.
5. Run VoiceOver over the primary journeys in `<LOCALE>`.
6. Exercise the shield, notification, Live Activity, and Dynamic Island text where the
   product has them and the simulator can show them.
7. Open every localized app-owned route and confirm the language and the routing, that
   its alternates and canonical link agree, and that the terms route still leaves the
   site for Apple's Standard EULA.
8. Run `make static` and `make fast`, and the localization, content, and UI tests this
   repository has, and fix what they report.
9. Repeat whatever a fix touched. The first run validated the first attempt, not the
   corrections.

`make static` runs the site check, which knows the four English routes and the links
between them. It does not know the localized routes exist, so its passing says nothing
about them and step 7 above is what confirms them. `make fast` is development feedback
and never evidence: the gate that covers this work runs once, on the integration
commit, in the session that combines the languages.

## Finish

Commit once, with everything this language needs in that commit and nothing else, and
stop. Do not merge, rebase onto main, cherry-pick, deploy the site, or remove the
worktree. A push is synchronization and proves nothing.

Put the durable facts in the commit message body — locale, base main commit, shared
files touched, terminology settled, what was validated — because this work has no
milestone record, and the session that combines the languages reads the branch's log
to recover them.

Then report the language and locale; the branch and worktree path; the base main
commit and the resulting commit's full SHA; the files changed and which of them are
shared; the terminology you settled and anything the developer should confirm; what
reading it again found and how each was fixed; what the running app found and how each
was fixed; the screens exercised and the routes opened; every command you ran with its
result. Any required environment or language expertise that remains unavailable
blocks this session instead of becoming unfinished follow-up.

This worktree is now ready for the session that combines the languages.
