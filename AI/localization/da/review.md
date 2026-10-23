# Danish localization — editorial handoff

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`. Branch: `localization/da`.
Scope: 330 Watch keys (299 baseline plus 31 discovered source keys), four launcher
keys, four complete web pages and local Danish App Store/IAP drafts. English source
entries preserved. No publishing, App Store upload or submission.

## Glossary and register

| Meaning | Danish |
| --- | --- |
| match / real game | kamp; format label Kamp |
| game within a set | parti; plural partier |
| set | sæt (singular and plural) |
| rally | duel; plural dueller |
| server | server; next server Næste server |
| serving / serving order | serv / serverækkefølge |
| advantage | fordel; rule Fordel |
| one advantage | Én fordel |
| deuce | lige; explicit 40–40 in explanatory copy |
| golden point / tie-break | Golden point / Tie-break |
| team labels | OS / DEM; spoken Os / dem |
| wearer / partner | Dig / Makker |
| history / undo | Historik / Fortryd |
| privacy / support | Anonymitet / Hjælp |
| launcher / Smart Stack | genvej / Smart stak |

Use direct, neutral Danish with `du`, ordinary verbs and short complete sentences.
No literal server-computer translation; no match/parti ambiguity. Americano's total
is for both teams together. A match ends manually; no automatic overall winner.
The one-advantage explanation explicitly describes the second 40–40. App Store
copy calls the purchase an engangskøb/adgang for altid, never a subscription or trial.
Apple Watch, Digital Crown, StoreKit and the product brand remain unchanged.

## Full editorial second reading

Read every Danish catalog entry and all four HTML pages and store fields, first as
Danish copy, then against English for meaning and parameter order. Applied
`design:ux-copy` principles: clear, concise, consistent, useful, human. This is the
language agent's self-review; coordinator editorial audit and runtime review remain.

Concrete second-reading corrections:

- `Skift format` → `Skift spilform`, matching the format picker `Spilform`.
- `Indtast stillingen for det nye format` → `Indtast stillingen for den nye
  spilform`, avoiding inconsistent terminology in the correction flow.
- `Anden gang stillingen er lige` → `Ved anden 40–40`, so the One advantage rule
  cannot be mistaken for an earlier tied score such as 15–15.
- `Server i træk fra én spiller` → `Samme spiller server alle dueller i serien`,
  replacing a noun-heavy fragment with a natural explanation of the serve block.
- Recast English first-person purchase errors as short, direct Danish; kept all
  no-change and data-retention guarantees.
- Kept `parti` in every demo boundary: the demo ends after one game within a match,
  not a completed real match and never consumes the free-game count.

All legitimately identical source/target strings are explained individually in
`unchanged.json`. Danish plural substitutions use one/other: `duel` / `dueller`.
Danish nouns `sæt`, `point` and `serv` do not require English-style plural suffixes.
Reviewed integer cases 0, 1, 2, 4, 5, 11, 21, 22, 25, 101 and 999: only 1 takes
`duel`; all other listed values take `dueller`. This is a source-level grammar
review, not a claim that the localized runtime formatter was executed.

## Validation

- `python3 Scripts/verify-localizations.py --locale da` — exit 0: 334 catalog keys, four pages, store drafts and glossary checked.
- `make static` — exit 0 (final run log `/private/tmp/padel-da-static.log`): repository, site, locale, launcher and milestone/status checks passed; launcher helper regression suite 6/6 passed. Optional SwiftLint, SwiftFormat and ShellCheck were not enabled (reported as skips).
- `git diff --check` — exit 0. Structural comparison against the base confirms every original English localization node is unchanged.
- Manual source/translation comparison: 330 Watch + 4 launcher entries; no missing
  targets, preserved placeholder kinds and indices, and all four page routes use
  `lang="da"`, localized canonicals, navigation, alt text and image routes.

## Not performed

`make fast`, Simulator execution, screenshot capture, smallest-watch/maximum-text
layout inspection, spoken VoiceOver and real-Watch use were not run. Coordinator
owns the build/simulator queue and 72-shot capture workflow. The six Danish page
image references deliberately point to coordinator-supplied `/images/da/` captures.
Final cross-language navigation and `hreflang` are coordinator-owned after fan-in.
No release-readiness or independent/native-speaker review claimed.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- First deuce → Første 40⁠–⁠40
- Second deuce → Anden 40⁠–⁠40
- At the second deuce, the next point wins. → Anden gang stillingen er 40⁠–⁠40, afgør næste point partiet.
- Game → Kamp

Runtime context refinement: the external legal-page heading is «Webside», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading clarifies the web privacy policy/address, purchased access and permanent access in the store promotion. Official Apple Danish Anonymitet terminology retained. This is coordinator editorial review, not an invited native-speaker review.
