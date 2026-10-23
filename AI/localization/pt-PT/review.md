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

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading distinguishes the next selected player from the opposing team in After them, clarifies serving sequences and the web privacy policy, and attaches lifetime to access rather than the purchase itself. This is coordinator editorial review, not an invited native-speaker review.

## Coordinator final visual validation

Original language-agent execution notes above remain historical. Coordinator completed the shared runtime review after integration: six original 44-mm store images and thirteen bounded 40-mm normal/maximum-text images for this locale were individually inspected. Product source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`, final candidate `b6cbb53163027283e8466b97b0f35e67b8ae62f4`; QA source `43a2d7460d21d785fed6dc193f8aab2d094a2398` differs only by added test probes under App. QA batch exit 0, 24/24 tests, zero failed/skipped/expected; all 156 images reviewed across the twelve locales. Full metric copy, team names, serving player numbers and editor rows remain readable. Evidence and original hashes: `../evidence/final-40mm.md`, `../visual-review.md`, and store manifests. Final combined integration/runtime verdict is recorded separately in `../HANDOFF.md`; no provisional run is a pass. Real spoken VoiceOver remains unverified until required Watch evidence is recorded.

Coordinator executed `make fast` on the original language commit `f32092741356f46c29337a4fdc39b232bdccadc3`: exit 0; 472 passed, 0 failed/skipped/expected, every test in that original scheme. Exact worktree/device/report/bundle and log provenance: `../evidence/fast-pt-pt.md`. This does not replace the complete final combined integration gate.

Final shared candidate `8dd50d72b04689da93bfaed2599eb28bd26e3591`: full integration exit 0, 510 definitions / 884 invocations, no failed/skipped/expected. This locale’s creation, journeys and six demonstration screens all passed. Complete context audit and corrected Danish acceptance: `../evidence/final-context.md`, `../evidence/danish-banner-correction.md`; exact report `../evidence/integration-final.md`.
