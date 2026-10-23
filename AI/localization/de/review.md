# German localization — editorial self-review

Locale: `de`; region: `de_DE`; store draft: `de-DE`.
Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.

## Voice and glossary

Direct informal singular `du`, lower-case inside prose. Buttons use short infinitives.
`Partie` is an entire saved session (either format); `Match` is the set-based format;
`Spiel` is a game within a set; `Satz` is a set; `Ballwechsel` is one rally; `Aufschläger`
is the serving player; `Aufschlag` labels the serving status; `Vorteil` is advantage;
`Einstand` is deuce; `Golden Point` is the recognizable padel rule; `Tie-Break` is the
German spelling. `Einmal Vorteil` means one advantage cycle then Golden Point on the
second deuce. `WIR / SIE` label our/opposing team. `Du`, `Partner`, `Gegner 1/2` identify
players. General `game` is never rendered as `Spiel` where that could imply one game
within a set. UI terms: `Über die App`, `Freischaltung`, `Verlauf`, `Rückgängig`,
`Noch mal spielen`, `Spielstand ausprobieren`, `Lokale Daten löschen`, `Smart-Stapel`.

## Complete second reading

Read all 330 Watch keys and 4 launcher keys, then all four German pages and the store
copy without relying on the source wording; compared meaning to English afterward.
Reviewed all nine identical source/target strings individually in unchanged.json.

Concrete corrections made on the second pass:
- `Ihre Spiele/Punkte` → `Spiele/Punkte der Gegner`: avoids confusion with formal address.
- `Tie-Break geöffnet` → `Tie-Break gestartet`: natural sports wording instead of literal UI wording.
- `Welchen Ballwechsel ... der nächste Aufschläger spielt` → `An welcher Stelle im Aufschlagblock der nächste Ballwechsel liegt`: explains the setting without awkward grammatical ambiguity.
- Winning banners use `WIR/SIE haben gewonnen` instead of a present-tense result.
- Distinguish generic `Partie` from scoring `Spiel` in demo and free-allowance prose.
- Use `Smart-Stapel` throughout app and site; do not leave English Smart Stack in instructions.

Plural substitutions retain original argument numbers and integer specifiers, with
German one/other categories. For total one, `1 von 1 Ballwechsel gespielt`; for other,
`2 von 4 Ballwechseln gespielt`. The other total phrase uses `Ballwechsel insgesamt`
for both grammatical categories. Reviewed totals 0, 1, 2, 4, 5, 11, 21, 22, 25, 101, 999.
No language-specific data/schema or behavior changes.

## Validation / compact handoff

Role: German localization Builder, not independent review or release approval.
Changed: German-only catalog entries; exact English entries for the 31 newly found
source keys; four German HTML pages; German store/IAP draft; glossary and allowlist.
Preserved: rules, five completed games, history/demo access, local-only persistence,
EULA/privacy facts, URLs and page dates; no public upload or publication.
Commands/results: `python3 Scripts/verify-localizations.py --locale de` exit 0 (334 keys = 330 Watch + 4 launcher, four pages, store draft, glossary); `make static` exit 0. First run found an IAP description one character over the limit; shortened it and reran both checks successfully. `git diff --check` exit 0. English catalog entries compared structurally with the base and unchanged.
Reports: `/private/tmp/padel-de-static.log` (local static output); coordinator integration report pending; no xcresult bundle was generated.
Runtime: `make fast`, simulator flows, localized captures, small-screen/max-text layout,
spoken VoiceOver and real-Watch checks NOT performed in this language task: coordinator
explicitly reserved build/simulator slots and will schedule them after translation.
Screenshot image URLs reserve `/images/de/`; coordinator supplies the six captures.
Remaining: coordinator full editorial audit, runtime/visual checks, integration gate.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- First server → Erster Aufschläger
- Second server → Zweiter Aufschläger
- Next server → Nächster Aufschläger
- Opened the tie-break → Erster Aufschläger im Tie-Break

Runtime context refinement: the external legal-page heading is «Webseite», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading distinguishes Partie (whole game) from Spiel (tennis game), clarifies the web address and explains technical recovery in plain language. This is coordinator editorial review, not an invited native-speaker review.
