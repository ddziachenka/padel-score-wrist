# Polish every shipped language against the others

Use this once every language the product intends to ship has been combined into main,
in the main checkout, on the integration commit. It is optional and recommended, and it
runs once for all of them rather than once per language: every language was already
localized and read again in its own session, and what no single-language session could
see is how the languages compare with each other.

1. Run `git status` and preserve unrelated work.
2. Read `AGENTS.md`.
3. Read `AI/WORKFLOW.md`.
4. Read `AI/PROJECT_STATUS.md`.
5. Confirm the integration gate passed on the current HEAD — its report is under
   `.artifacts/integration/` — then read `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`,
   `AI/DESIGN.md`, and the report each language's session left behind.

This does not replace the pass each language already made over its own strings, and it
is not a domain audit: it owns no milestone, writes no record under `AI/audits/`, and
changes no `**Status:**` line. English and the approved product, architecture, and
design contracts are the source of truth. Do not change product behavior, do not
change English copy, and do not reopen a completed milestone.

## Compare, then fix

Read the same string across every language side by side, over every surface the app
ships: screens and alerts, onboarding, the primary journeys, settings, history, the
paywall, errors and recovery, shields and extensions, notifications, Live Activities
and the Dynamic Island, accessibility text, and the app-owned routes under `Web/`.
The App Store listing and its translations are a separate App Store Connect workflow
and are not compared here.

- A concept named one way in one language and differently in the next.
- A language whose register drifts from the tone `AI/DESIGN.md` sets while the others
  hold it, or that reads as translated where the others read as written.
- Word-for-word, awkward, overly formal, machine-translated, or culturally odd
  phrasing, and a call to action in wording that language would not normally use.
- Placeholders, interpolation, plural categories, dates, durations, numbers, currency,
  and formats that one language preserved and another quietly dropped.
- Grammar, spelling, punctuation, capitalization, and quotation conventions applied
  inconsistently inside a single language.
- Strings that fell back to English, and coverage one language has and another lacks.
- A screen that is comfortable in one language and clipped in the longest one.
- Web routes that say different things in different languages.

Replace what you find with the language a native speaker would expect, preserving the
approved product meaning exactly. Keep the glossary consistent within each language
while allowing the grammatical and contextual variation the language requires. Check
`/privacy` and `/support` in every language for natural wording and for saying the
same thing the English pages say. Never modify, translate, or host Apple's Standard
Terms; only confirm the link still leaves the site.

Fix what you find here rather than reporting it. A record of cross-language
inconsistency that nobody applies is the inconsistency plus a document.

## Validation

1. Build and run representative languages, and capture Simulator screenshots of the
   surfaces each one changes.
2. Fix clipping, truncation, awkward wrapping, copy that is too long, poor balance, and
   right-to-left layout problems, changing localized copy and layout rather than
   redesigning the product.
3. Run the localization, content, build, and UI tests, and fix what they report.
4. Rescan every language for missing translations, English fallbacks, and inconsistent
   coverage.
5. Read the changed strings once more, in every language you touched. A locale is not
   validated because every key has a value.

The quality target is that a native speaker can use the product without feeling it was
translated from English.

## Finish

Everything this pass changed goes in one commit, and there is no commit at all if
nothing needed changing: an empty one would create a candidate the existing evidence
no longer describes, for nothing. If you committed, verify the new tip:

```sh
polish_sha="$(git rev-parse HEAD)"
make integration CANDIDATE="$polish_sha"
```

Then report one row per language:

```text
Locale | Quality before | Main issues fixed | Quality after | Remaining native/legal review
```

Quality before and after are one short phrase each, never a score: nothing here
measures a localization grade, and inventing one would claim a measurement no check
performed. Add the files changed, the cross-language inconsistencies fixed, the layout
problems fixed, the commands you ran with their results, and the routes checked. Any
required environment or expertise that remains unavailable blocks completion.
