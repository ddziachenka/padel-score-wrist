# Brazilian Portuguese — editorial review and handoff

Base: 809aa64036c4027d7aba141e889e90d97669e9e6.
Scope: 330 Watch keys (299 existing plus 31 missing extracted English entries), 4 launcher keys, four complete translated HTML pages, local App Store/IAP draft. Own locale worktree, separate from pt-PT.

## Glossary and style

- match / app-level game: partida; game inside a set: game, games; set: set, sets.
- rally: ponto disputado (ponto in short labels); server: sacador / quem saca; serve: saque.
- advantage: vantagem; deuce: igualdade; golden point: ponto de ouro; one advantage: uma vantagem.
- our/their team: nossa equipe / equipe adversária; score buttons: NÓS / ELES; You: Eu.
- Undo: Desfazer; Save: Salvar; Settings: Ajustes; Watch face: Mostrador; Smart Stack: Conjunto Inteligente.
- Natural Brazilian imperatives; app is masculine. Brazilian forms: tela, conexão, câmera, contatos, senha, assinatura, desenvolvedor, placar, quadra. No servidor, jogo for a game inside a set, or European ecrã/subscrição.

## Second reading

Read all 334 target values and all four website pages without the English source, then compared meanings with English. Reviewed all variable forms as complete sentences. One/many/other remain grammatically consistent, including 0/1/2/4/5/11/21/22/25/101/999.

Concrete corrections during this pass:
- Rewrote “Toque sem levantar o dedo” as “Mantenha o dedo na tela” and “rode” as “gire”.
- Changed all inside-set games and demo length to game/games; entire sessions remain partidas.
- Changed guardar/anular/serviço/mostrador labels to Salvar/Desfazer/saque/Mostrador consistently across app, site, and store copy.
- Corrected gender agreement after regional vocabulary changes: os ajustes salvos, os backups, essa tela está aberta, ao Conjunto Inteligente.
- Kept legal/support “serviço” separate from scoring “saque”; corrected inline-link clauses after rereading rendered text order.
- Rewrote the recovered-save error as two short sentences and clarified the purchase pending screen can be closed.

## Validation

- `python3 Scripts/verify-localizations.py --locale pt-BR`: PASS, exit 0; 334 keys, four pages, store draft and glossary.
- `make static`: PASS, exit 0; required checks passed, 6 launcher tests. Optional swiftlint/swiftformat/shellcheck disabled by repository configuration. Existing English screenshots passed provenance; localized screenshots remain pending.
- Runtime/layout, `make fast`, simulator, six screenshots, Dynamic Type and actual VoiceOver speech: NOT RUN here; coordinator explicitly reserved build capacity and owns scheduling these required checks. No runtime or release-readiness claim.
- This is the language agent's self-review, not certification by a native speaker or the coordinator's subsequent editorial audit.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Primeiro a sacar no tie-break
- Unlimited Match & Americano scoring. → Partidas e Americano sem limites.
- Game → Partida

Coordinator numeric correction: added an explicit zero form, giving «0 pontos» while retaining «1 ponto». Verified with xcstringstool compilation and Foundation for every requested numeric value; added an installed-bundle regression check.

Runtime context refinement: the external legal-page heading is «Página na web», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.
