# European Portuguese — editorial review and handoff

Base: 809aa64036c4027d7aba141e889e90d97669e9e6.
Scope: 330 Watch keys (299 existing plus 31 extracted missing English source entries), 4 launcher keys, four complete HTML pages, local App Store/IAP draft. No upload or publication.

## Glossary and style

- match / app-level game: partida; game inside a set: jogo; set: set, sets.
- rally: ponto disputado (ponto in short labels); server: jogador ao serviço, quem serve; never servidor.
- advantage: vantagem; deuce: igualdade; golden point: ponto de ouro; one advantage: uma vantagem.
- our/their team: a nossa equipa / a equipa adversária; score buttons: NÓS / ELES; You: Eu.
- Undo: Anular; Save: Guardar; Settings: Definições; Watch face: Mostrador; Smart Stack: Pilha inteligente.
- Polite direct imperatives, no repeated pronouns. European spelling and vocabulary: ecrã, ligação, câmara, contactos, subscrição, programador. Brand and conventional scoring names retain their accepted forms.

## Second reading

Read all catalog translations and website paragraphs separately from the source, then compared their meanings against English. Rechecked the purchase and deletion clauses, combined Americano total, manual finish, history restrictions and the one-game demo.

Corrections made on the second reading:
- Shortened “Pontos por serviço” to “Pontos por jogador” to clarify a per-player block without suggesting a single serve.
- Kept “partida” for the entire session and “jogo” for each game of a set, including demo ending after one jogo.
- Used “O próximo ponto decide o jogo” instead of a literal “o próximo ponto ganha”.
- Removed a doubled article at the Cloudflare privacy-policy link and reread text spanning inline links.
- Read the singular/plural substitutions as complete utterances: “1 de 1 ponto disputado”, “2 de 2 pontos disputados”; one/many/other use Portuguese grammar and preserve argument types.

## Validation

- `python3 Scripts/verify-localizations.py --locale pt-PT`: PASS, exit 0; 334 catalog keys, four pages, store draft, glossary.
- `make static`: PASS, exit 0; all required static checks passed, launcher verifier ran 6 tests. Optional swiftlint/swiftformat/shellcheck disabled by repository configuration. Existing English screenshot provenance passed; localized captures are still pending.
- Runtime/layout, `make fast`, simulator, six screenshots, Dynamic Type and actual VoiceOver speech: NOT RUN here, coordinator explicitly reserved build capacity and owns scheduling these checks. No runtime quality claim or release-readiness claim.
- Editorial pass is the translating agent's self-review, not a native-speaker certification or the coordinator's later full audit.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Primeiro a servir no tie-break
- Unlimited Match & Americano scoring. → Partidas e Americano sem limites.
- Rallies per server → Pontos por turno de serviço
- Game → Partida

Runtime context refinement: the external legal-page heading is «Página web», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.
