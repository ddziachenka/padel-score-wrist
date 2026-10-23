# Italian localization — self-review

Base: 809aa64036c4027d7aba141e889e90d97669e9e6. Branch: localization/it.

## Glossary and register

Informal singular imperative, concise and neutral. Match = Incontro (format); a real
saved game = partita; game within a set = game; set = set; rally = punto (the point
played, not the game); server = battitore; serving = battuta; advantage = vantaggio;
Golden point = punto de oro; One advantage = un solo vantaggio; round = turno.
Teams: NOI / LORO; player roles: Tu, Compagno, Avversario 1, Avversario 2.
Apple platform label: Raccolta smart. Product name and Apple Account remain unchanged.

The Americano total always combines both teams’ points. Incontro has no fixed set
limit or automatically declared overall winner. The five-free-game allowance counts
partite, never individual game. Purchases use a single permanent unlock, with no
subscription. Privacy, deletion and restore terms follow the source facts.

## Complete second reading

Read all 330 Watch keys, four Launcher keys, four website pages and the complete store
draft in Italian, then compared their meaning against the English source and product
contract. Added 31 source entries extracted from AboutView, including all previously
uncatalogued offline legal/support headings and paragraphs. Source English is exact.

Concrete editorial decisions/corrections:
- Replaced a literal “server” with battitore throughout; avoided the computing meaning.
- Used “punti per battitore” and “Per entrambe le squadre insieme” for a readable and
  unambiguous Americano setup; points are the rallies counted in that format.
- “Second deuce” becomes “Seconda parità”, with the next-point rule explicitly retained.
- Changed the AD spoken label from plural “Vantaggi” to singular “Vantaggio”.
- Changed winner badges from present-tense “NOI vinciamo” / “LORO vincono” to
  “NOI abbiamo vinto” / “LORO hanno vinto”.
- Kept game/set distinct from partita in the five-free-games purchase terms and demo.
- Used “non azzera il conteggio” instead of a literal “mantiene il contatore” on the site.
- Kept the source legal dates (21 October offline, 23 October website) unchanged.

Plural substitutions include one/many/other, using punto/punti and preserving %arg.
For 0, 2, 4, 5, 11, 21, 22, 25, 101 and 999 the form is punti; for 1 it is punto.
Italian many (million counts) also uses punti. Brand/platform/scoring matches are
individually explained in unchanged.json; no ordinary English prose is left.

## Validation and remaining evidence

- `python3 Scripts/verify-localizations.py --locale it`: exit 0; 334 keys (330 Watch + 4 Launcher), four pages, store draft and glossary.
- `make static`: exit 0; repository, site, locale structure and launcher checks passed; launcher tests 6/6. Optional swiftlint, swiftformat and shellcheck are disabled in project configuration and were reported skipped. No result bundle produced by these static checks.
- make fast: NOT RUN yet; coordinator schedules one build at a time on the committed SHA.
- Simulator/UI layout, full accessibility size, six screenshots, actual spoken VoiceOver
  and real-Watch checks: NOT RUN in this text session. No runtime quality claim is made.
- Coordinator editorial audit and integration gate remain required.
- No App Store upload, site publication or App Review submission performed.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Primo battitore del tie-break
- Unlimited Match & Americano scoring. → Incontri e Americano senza limiti.
- Game → Partita

Runtime context refinement: the external legal-page heading is «Pagina web», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading removed partite di Incontro, clarified the web address and made best-effort support/forensic recovery language plain while retaining the same limits. This is coordinator editorial review, not an invited native-speaker review.

Terminology cross-check (23 October 2026): current [Apple Italian account guidance](https://support.apple.com/it-it/105023) uses Apple Account, so that name is retained. [Apple Watch guidance](https://support.apple.com/it-it/guide/watch/-apdb93ea3872/watchos) confirms Raccolta smart.

## Coordinator final visual validation

Original language-agent execution notes above remain historical. Coordinator completed the shared runtime review after integration: six original 44-mm store images and thirteen bounded 40-mm normal/maximum-text images for this locale were individually inspected. Product source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`, final candidate `b6cbb53163027283e8466b97b0f35e67b8ae62f4`; QA source `43a2d7460d21d785fed6dc193f8aab2d094a2398` differs only by added test probes under App. QA batch exit 0, 24/24 tests, zero failed/skipped/expected; all 156 images reviewed across the twelve locales. Full metric copy, team names, serving player numbers and editor rows remain readable. Evidence and original hashes: `../evidence/final-40mm.md`, `../visual-review.md`, and store manifests. Final combined integration/runtime verdict is recorded separately in `../HANDOFF.md`; no provisional run is a pass. Real spoken VoiceOver remains unverified until required Watch evidence is recorded.

Coordinator executed `make fast` on the original language commit `d87c2c08d8046c2941af4dc7f355748ffbfb278a`: exit 0; 472 passed, 0 failed/skipped/expected, every test in that original scheme. Exact worktree/device/report/bundle and log provenance: `../evidence/fast-it.md`. This does not replace the complete final combined integration gate.
