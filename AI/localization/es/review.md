# Spanish localization — es

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.
Branch: `localization/es`; isolated worktree `/private/tmp/padel-l10n-es`.

## Scope and register

330 Watch keys (299 original plus 31 missing About/legal keys identified by source
inspection), 4 Launcher keys, four complete website pages, and local `es-ES` and
`es-MX` App Store and lifetime-IAP drafts. English remains unchanged. No publication.

Direct, friendly singular tú; short action verbs, no marketing exaggeration. Shared
app/site Spanish avoids vosotros and regional court vocabulary. The two store
variants use distinct local discovery keywords and promotional text. Proper names,
privacy facts, purchase limitations and dates remain faithful to English.

## Glossary

| Meaning | Spanish |
| --- | --- |
| Entire saved game/session, including an Americano round | partida |
| Match format | Partido |
| Game within a set | juego |
| Set | set / sets |
| Rally | punto (one rally played awards one point) |
| Server | sacador; al saque in the compact live display |
| Service block | turno de saque |
| Advantage | ventaja |
| One advantage | Una ventaja |
| Golden point | Punto de oro |
| First / second deuce | Primer / Segundo 40–40 |
| US / THEM | NOSOTROS / ELLOS |
| Partner / opponents | compañero / rivales |
| Undo / History | Deshacer / Historial |
| Smart Stack | Grupo inteligente |

`AD`, `Demo`, `Americano`, `Set`, `Sets`, `Tie-break` and product identities are
idiomatic conventional terms; every identical entry is justified in unchanged.json.
Americano's total is explicitly both teams' combined points. Match ends manually;
copy does not invent an overall winner. Free completed sessions are partidas,
never juegos, to avoid confusing the five-game allowance with games inside a set.

## Second reading and concrete corrections

Read every Spanish catalog entry in isolation, then compared all source sentences
and parameters. Read all four Spanish HTML pages and store drafts end to end.

- `Game` was initially `Juego`; its code comment identifies the session menu title,
  so corrected to `Partida`, reserving juego for the unit within a set.
- Replaced awkward `Primer iguales` / `Segundo iguales` with `Primer 40–40` /
  `Segundo 40–40`, and matched their explanation. These stay meaningful in correction.
- Corrected `Opened the tie-break` from `Primer sacador del tie-break` to
  `Inició el tie-break`: the source comment identifies a pair-selection heading,
  not an individual player.
- Replaced literal `un único pago de por vida` with `Una única compra da acceso
  de por vida`, so the lifetime describes access rather than a payment.
- Changed winner/lead labels to concise `Ganamos`, `Ganaron`, `Vamos ganando`,
  `Van ganando`. Corrected the opponents' winner tense from present to past.
- Preserved no-break spaces in the free-game count and word joiners in 40–40.
- Used punto throughout Americano because each rally is precisely one played point;
  explicitly distinguished it from juego, set and partida.
- Long legal copy retains 90-day support retention, exceptions, local storage,
  no sync/recovery, purchase preservation and possible loss on reinstallation.

## Validation and handoff

Commands and final results are appended below after execution. Runtime checks are
pending coordinator scheduling. No `make fast`, simulator setup/launch, Dynamic
Type layout, VoiceOver audio or real-Watch checks were performed by this language
agent. The six localized screenshot paths are prepared in HTML; captures and their
provenance are the coordinator's pending work. No claim of an external native
speaker review or independent release audit is made.

- `python3 Scripts/verify-localizations.py --locale es`: exit 0; 334 catalog keys,
  four pages, two store drafts and glossary validated.
- `make static`: exit 0; report `/private/tmp/padel-es-static.log`; template,
  configuration, site, catalog, launcher (6 tests) and milestone checks pass.
  Optional swiftlint, swiftformat and shellcheck are not enabled in this project.
- Source comparison: all original English localization structures preserved;
  all 31 compiler-extracted missing About keys added with exact English source.
- `git diff --check`: exit 0.

The first exploratory validator/static invocation identified missing allowlist
reasons for the conventional `Set` labels; both were explicitly reviewed and added,
then the commands were rerun successfully. No checks were weakened.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Second reading retained the language agent’s phrasing; context and layout checks remain separate.

Runtime context refinement: the external legal-page heading is «Página web», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading clarified the tie-break opener, removed the government-policy calque política pública, and attached lifetime to access rather than payment. Padel paddle is pala. This is coordinator editorial review, not an invited native-speaker review.

## Coordinator final visual validation

Original language-agent execution notes above remain historical. Coordinator completed the shared runtime review after integration: six original 44-mm store images and thirteen bounded 40-mm normal/maximum-text images for this locale were individually inspected. Product source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`, final candidate `b6cbb53163027283e8466b97b0f35e67b8ae62f4`; QA source `43a2d7460d21d785fed6dc193f8aab2d094a2398` differs only by added test probes under App. QA batch exit 0, 24/24 tests, zero failed/skipped/expected; all 156 images reviewed across the twelve locales. Full metric copy, team names, serving player numbers and editor rows remain readable. Evidence and original hashes: `../evidence/final-40mm.md`, `../visual-review.md`, and store manifests. Final combined integration/runtime verdict is recorded separately in `../HANDOFF.md`; no provisional run is a pass. Real spoken VoiceOver remains unverified until required Watch evidence is recorded.

Coordinator executed `make fast` on the original language commit `a3b6161e7b05a2391aaa86b7584a64dd316a5537`: exit 0; 472 passed, 0 failed/skipped/expected, every test in that original scheme. Exact worktree/device/report/bundle and log provenance: `../evidence/fast-es.md`. This does not replace the complete final combined integration gate.
