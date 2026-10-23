# Swedish localization — language-agent self-review

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.
Worktree: `/private/tmp/padel-l10n-sv`, branch `localization/sv`.
Scope: all 330 Watch keys (including 31 newly extracted English source keys), four launcher keys, four complete web pages, Swedish App Store and lifetime-purchase draft. English catalog values are preserved; newly extracted keys contain exact English sources.

## Glossary and register

| Meaning | Swedish |
| --- | --- |
| Match format / whole match | Match / match |
| Game within a set | game (plural game, definite gamet/gamen) |
| App game session / allowance | spel / gratisspel |
| Americano round | Americano-omgång / omgång |
| Set | set |
| Rally | boll (a played point, never a stroke) |
| Server | servare; “Servar: …” in an announcement |
| Serving order | serveordning |
| Service block | serveserie |
| Advantage | Fördel |
| One advantage cycle | En fördel; at the second 40–40, next point decides |
| Deuce selector | Första 40–40 / Andra 40–40 |
| Golden point | Golden point, conventional Swedish padel terminology |
| Tiebreak | tiebreak |
| Our/their teams | VI / DE on scoreboard, oss/dem after “till”, vårt/deras lag in sentences |
| Players | Du, Medspelare, Motståndare 1, Motståndare 2 |
| Undo | Ångra |
| History | Historik |
| Smart Stack | Smart trave |
| Lifetime unlock | permanent åtkomst / Lås upp för alltid |

Direct, calm Swedish with “du”, familiar action verbs, no promotional exaggeration. Distinguish game within a set from an app game session and distinguish the combined Americano total from a per-player target. Keep AD and product names unchanged. Explicit unchanged-key reasons are in unchanged.json.

## Second reading and corrections

Read all translated catalog values in screen-flow order, then the complete four pages and all store fields as Swedish prose; cross-checked against source facts, placeholders and navigation labels. This is the language agent's self-review, not the coordinator's editorial audit or a native-speaker certification.

Concrete corrections after the second reading:
- “Första lika” / “Andra lika” → “Första 40–40” / “Andra 40–40”: immediately understandable labels rather than awkward literal nouns.
- “Vilken boll … ska serva” → “Vilken boll i serveserien nästa servare står inför”: avoids describing a rally as a physical ball to serve.
- “Rätta dem” for completed-set game counts → “Rätta antalet”: makes the corrective action unambiguous.
- “Fem gratisspel avslutade” → “Fem gratisspel är avslutade”: natural complete status sentence.
- Used “spel” for the app allowance and “game” for a scoring unit throughout; the demo ends after one game, not a whole match.
- Recast “non-consumable” on the terms page as “Köpet förbrukas inte”, and retained the one-payment/no-subscription meaning.

## Grammar and content checks

Both parameterized rally messages retain named substitutions, correct argument positions and Swedish one/other forms. The categories cover 0/2/4/5/11/21/22/25/101/999 as other, 1 as one. Reading examples: “1 av 1 boll spelad”, “2 av 5 bollar spelade”, “1 boll totalt, 1 per servare”, “999 bollar totalt, 5 per servare”. Numbers and dates remain system-owned in the app. Swedish website wording localizes the literal US price while preserving its value: 4,99 USD. Apple prices in-app remain StoreKit-owned.

The website preserves all source privacy/retention/purchase limitations, EULA and contact URLs, dates, 90-day support retention, local-only storage, no transfers/sync/backup service, and the absence of a guaranteed support response time. All alt text and navigation are Swedish. Six image paths point to coordinator-owned future captures at `/images/sv/`.

## Validation and handoff

- `python3 Scripts/verify-localizations.py --locale sv`: exit 0; 334 catalog keys, four pages, store drafts and glossary checked.
- `make static`: exit 0; static verification PASSED, including six launcher tests (six passed). Log: `/private/tmp/padel-sv-static.log`. No Xcode result bundle was produced by these static checks. Optional swiftlint, swiftformat and shellcheck were not enabled by repository configuration.
- `make fast`, simulator flows, localized screenshots, minimum-screen/maximum-text inspection and real-Watch VoiceOver: NOT RUN by this agent; coordinator explicitly owns the queued runtime/build checks. No runtime pass is claimed.
- Integration, final cross-language navigation and coordinator full editorial audit remain pending.
- No upload, publication or App Review submission performed.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Första servaren i tiebreak
- First server → Första servaren
- Second server → Andra servaren
- No lifetime purchase was found for this Apple Account. → Inget köp för permanent åtkomst hittades för det här Apple-kontot.
- Game → Spel

Runtime context refinement: the external legal-page heading is «Webbsida», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading removes plural-person ambiguity from the service-order heading, uses permanent access consistently and clarifies technical privacy wording. This is coordinator editorial review, not an invited native-speaker review.

## Coordinator final visual validation

Original language-agent execution notes above remain historical. Coordinator completed the shared runtime review after integration: six original 44-mm store images and thirteen bounded 40-mm normal/maximum-text images for this locale were individually inspected. Product source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`, final candidate `b6cbb53163027283e8466b97b0f35e67b8ae62f4`; QA source `43a2d7460d21d785fed6dc193f8aab2d094a2398` differs only by added test probes under App. QA batch exit 0, 24/24 tests, zero failed/skipped/expected; all 156 images reviewed across the twelve locales. Full metric copy, team names, serving player numbers and editor rows remain readable. Evidence and original hashes: `../evidence/final-40mm.md`, `../visual-review.md`, and store manifests. Final combined integration/runtime verdict is recorded separately in `../HANDOFF.md`; no provisional run is a pass. Real spoken VoiceOver remains unverified until required Watch evidence is recorded.

Coordinator executed `make fast` on the original language commit `ae20e0790b93401fd58bc654d9cfbbc82ec35930`: exit 0; 472 passed, 0 failed/skipped/expected, every test in that original scheme. Exact worktree/device/report/bundle and log provenance: `../evidence/fast-sv.md`. This does not replace the complete final combined integration gate.

Final shared candidate `8dd50d72b04689da93bfaed2599eb28bd26e3591`: full integration exit 0, 510 definitions / 884 invocations, no failed/skipped/expected. This locale’s creation, journeys and six demonstration screens all passed. Complete context audit and corrected Danish acceptance: `../evidence/final-context.md`, `../evidence/danish-banner-correction.md`; exact report `../evidence/integration-final.md`.
