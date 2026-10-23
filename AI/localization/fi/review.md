# Finnish (fi) — translation and self-review

Base: 809aa64036c4027d7aba141e889e90d97669e9e6. Language branch: localization/fi.

## Glossary and register

- Match = Ottelu (format); match = ottelu in prose. Game within a set = peli.
- A generic session/game = peli; an Americano round = kierros. A set = erä.
- Rally = pallo; points = pisteet. Total rallies = Palloja yhteensä, both teams combined.
- Server = syöttäjä; service order = syöttöjärjestys; service block = syöttövuoro.
- Advantage = Etu; One advantage = Yksi etu; Golden point = Ratkaiseva piste.
- Deuce = tasatilanne (40–40); tie-break is the established loan term.
- Team labels: ME / HE; Sinä, Pari, Vastustaja 1, Vastustaja 2.
- Access = Käyttöoikeus; lifetime unlock = pysyvä käyttöoikeus; Restore purchases = Palauta ostot.
- Smart Stack = älykäs pino; watch face = kellotaulu; Quick launch = Pikakäynnistys.

Use natural standard Finnish, direct imperatives and readable full sentences. No formal
second person, sales exaggeration or word-for-word English syntax. Screen labels are
short; VoiceOver uses complete Finnish sentences with appropriate cases. Branding stays
unchanged. Platform proper names and conventional scoreboard terms are explicitly listed
in unchanged.json.

## Second reading and corrections

Read all 330 Watch strings, four Launcher strings, all four complete HTML pages,
and the store/IAP draft again for meaning, fluency, consistent terms and format tokens.

- Rephrased the landing page's "pelataan erät, tie-breakit ja ... sääntö" to
  "pelaa erät sekä tie-breakit valitsemallasi tasatilannesäännöllä": a rule is followed,
  not played as an item in the list.
- Changed "Rajaton pistelasku Ottelussa ja Americanossa" to "Rajaton Ottelu- ja
  Americano-pistelasku" for a concise, consistent format label.
- Changed "Joukkueesi syöttää tämän erän ensin" to "Joukkueesi aloittaa tämän erän
  syötöt"; made the same correction for opponents. The team starts the serving order,
  rather than serving a whole set.
- Replaced the ambiguous progress phrase "1 / 2 pallosta pelattu" with
  "Pelattu 1, yhteensä 2 palloa", which reads clearly in VoiceOver too.
- Kept set games distinct from full matches and Americano rounds; a demo ends after
  one peli, not an ottelu. The second deuce remains the deciding-point trigger.
- Used "ostojen palauttaminen" consistently, separating restoration from refund (hyvitys).
- Legal/support paragraphs retain retention dates, conditional 90-day retention,
  Apple payment handling, local storage limitations and no recovery promise.

The two plural substitutions include one/other. Finnish numeric partitives are used:
"Yhteensä 1 pallo" and "Yhteensä 2 palloa"; the progress announcement uses
"Pelattu 1, yhteensä 2 palloa" to avoid case problems with the first number. Parameter numbers and types are preserved.

## Validation and limits

- `python3 Scripts/verify-localizations.py --locale fi` — exit 0; 334 keys,
  four pages, store/IAP limits, declared unchanged terms and glossary checked.
- `make static` — exit 0; includes six Python launcher tests, zero failures.
  Optional swiftlint/swiftformat/shellcheck are not configured and were reported skipped.
- `git diff --check` — exit 0.
- Additional source preservation assertions — exit 0; all 299 original English Watch
  entries and four Launcher entries compare identically as parsed data to base.
  Added the exact 31 source strings supplied by the coordinator.
- Plural examples read for 0, 1, 2, 4, 5, 11, 21, 22, 25, 101 and 999.
- Reports in this worktree: `.artifacts/localization-fi/catalog.log` and
  `.artifacts/localization-fi/static.log` (ignored local evidence). Exact resulting
  language commit SHA is supplied in the task handoff; the integration candidate
  still requires its own verification.

Runtime validation, make fast, Simulator inspection, six localized
captures, smallest-watch layout, maximum text size and actual VoiceOver on hardware are
NOT performed in this language task. The coordinator queues builds and runtime checks.
This is translator self-review, not the coordinator's separate editorial pass or native
human certification. No upload, publication, App Review submission or release readiness.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Tie-breakin ensimmäinen syöttäjä

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading removes plural-person ambiguity from the service-order heading and attaches permanence to access rather than the purchase transaction. This is coordinator editorial review, not an invited native-speaker review.

Terminology cross-check (23 October 2026): [Apple Finnish watchOS guidance](https://support.apple.com/fi-fi/123002) confirms älykäs pino and its native inflections; retained.
