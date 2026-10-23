# French localization — fr / fr-FR

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.

## Coverage and register

330 Watch keys (299 original plus all 31 omitted About/legal/support resources),
4 launcher keys, four public HTML pages and one `fr-FR` App Store/IAP draft.
The original English translations and source keys are preserved. English entries
for newly discovered resources exactly match the existing Swift source.

French uses a concise, neutral, helpful voice and vous. Action labels use
infinitives; instructions use direct, polite imperatives. Legal pages remain
precise while breaking long English sentences into readable French sentences.
The product brand, developer identity, email, URLs, Apple EULA and original dates
remain intact. All six image references point to `/images/fr/`; captures are
pending the coordinator's simulator schedule.

## Glossary

| Concept | French | Context |
| --- | --- | --- |
| generic game/session | partie | Includes Match and Americano; five free sessions are five parties |
| match | match / Match | Match for the named format; never a single jeu |
| game within a set | jeu | Demo ends after one jeu |
| set | set | Familiar French padel/tennis usage |
| rally | point / point joué | One exchange ending in one scored point; clearer and shorter than échange in counters |
| server | serveur | Person serving, not software infrastructure |
| serving | au service | Next server = prochain serveur |
| advantage | avantage / AV | French scoring abbreviation |
| one advantage | un seul avantage | A second deuce makes the next point decisive |
| golden point | point décisif | Distinct from jeu décisif |
| tie-break | jeu décisif | Distinct from the single point at deuce |
| Americano round | manche Americano | Total counts both teams' points together |
| Us / Them | NOUS / EUX | VoiceOver uses sentence case and full sentences |
| partner | partenaire | Consistent throughout serving setup |
| opponents | adversaires | Adversaire 1 / Adversaire 2 |
| Smart Stack | pile intelligente | French platform wording |
| undo | Annuler | Hint explicitly says it removes the last point |

## Full editorial second reading

Read all 330 Watch translations, all 4 launcher translations, all four French
pages and the entire store draft, first as French copy then against the source.
Concrete edits made after the initial translation:

- Replaced literal « Gardez votre concentration sur le jeu » with « Restez dans le
  jeu », a short, natural headline retaining the intended focus-on-play message.
- Used « points » for Americano rally counters rather than bulky « échanges »;
  retained explicit « pour les deux équipes réunies » and the sum-of-both-teams
  explanation to avoid implying a per-team target.
- Used « jeu décisif » for tie-break and « point décisif » for Golden point;
  avoided translating both as a generic decisive event.
- Rewrote « Opened the tie-break » as « Premier serveur du jeu décisif », because
  this is a serving-position control, not an instruction to open a screen.
- Reworked replacement-format explanations to name the button and the consequence
  clearly rather than mechanically mirroring the English subject.
- Changed « Actions d’annulation » to « actions annulables » in storage/legal
  explanations, which describes the retained Undo history naturally.
- Translated « AD » to French « AV » and kept whole VoiceOver result sentences.
- Shortened the next-service-block hint while keeping its exact meaning.
- Rechecked purchase wording: five completed parties; no recurring payment;
  StoreKit local price; current game/history/demo accessible without buying;
  deleting data preserves count and purchase; pending purchase does not unlock.

`unchanged.json` explicitly explains every identical source/target string. Matches
are conventional French sports/interface words, number/title patterns or brands.

## Validation

- `python3 Scripts/verify-localizations.py --locale fr`: exit 0; 334 catalog keys, four pages, store draft and glossary passed.
- `make static`: exit 0; static verification PASSED; six launcher unit tests passed. Optional swiftlint/swiftformat/shellcheck are disabled by repository configuration.
- `make simulator-setup` and `make simulator-context`: exit 0; own Watch SE 40mm simulator `BA44AE8B-5A0B-4BD3-AC9B-9A863A822994`, watchOS 26.1.
- `make fast`: launching after content commit in assigned build slot; result PENDING. Coordinator monitors the asynchronous process and records actual evidence.
- Simulator interaction, smallest-screen/maximum-text layout, VoiceOver runtime,
  purchase runtime and six screenshots: NOT RUN; coordinator schedules these on
  the committed language candidate with its managed simulator.
- Real-Watch speech and hardware validation: NOT RUN; required for M10 readiness.

This is the language agent's self-review. No claim of external native-speaker
review, independent release approval, publication or upload is made.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- At 40–40, the next point wins the game. → À 40⁠–⁠40, le point suivant décide du jeu.
- The next point wins the game. → Le prochain point décide du jeu.
- US won → NOUS avons gagné
- THEM won → EUX ont gagné
