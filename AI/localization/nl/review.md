# Dutch localization — nl / nl-NL

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.
Language branch: `localization/nl`; own worktree `/private/tmp/padel-l10n-nl`.

## Glossary and register

| Concept | Dutch choice | Usage |
| --- | --- | --- |
| match | match / wedstrijd | Match is the named sets-based format; wedstrijd is the neutral whole-game term, including an Americano round. |
| game within a set | game, games | Never translate this scoring unit as wedstrijd. |
| set | set, sets | Conventional Dutch padel terminology. |
| rally | rally, rally’s | One played point; an Americano total counts both teams together. |
| server | serveerder | The player who serves; not a computer server. |
| serving / service order | service / servicevolgorde | A block is servicebeurt. |
| advantage | voordeel | One advantage: Eenmaal voordeel; one cycle, then a deciding point at second deuce. |
| Golden point | Golden point | Established padel rule name; accompanying copy explains the deciding point. |
| US / THEM | WIJ / ZIJ | Spoken sentences use ons team, het andere team, wij and zij as grammar requires. |
| You / Partner | Jij / Partner | Familiar singular je/jij throughout; no formal u. |
| Undo | Maak ongedaan | Action verb; saved undo records are actiegeschiedenis. |
| History | Geschiedenis | Whole completed-game archive, free for everyone. |
| Smart Stack | slimme stapel | Dutch platform wording. |
| About / Access / Support | Info / Toegang / Hulp | Identical wording in app navigation, site instructions and store copy. |

Applied design:ux-copy principles: clear, concise, consistent, useful, human.
Short action labels use familiar verbs. Error messages explain the failure and next
step without blaming the player. Full offline legal paragraphs preserve the source
facts and dates. Product and developer names, email and Apple EULA URLs are intact.

## Full editorial second reading

Read all 330 Watch entries, all four Launcher entries, the complete four web pages,
and every store field, then compared against the English meaning. The second pass
checked complete Dutch sentences, consistent navigation and team names, tense,
service terminology, and repeated purchase/deletion statements.

Corrections made during the second reading:

- `Game voor WIJ` / `Game voor ZIJ` became `Game voor ons` / `Game voor hen`.
  The initial literal labels were ungrammatical in a Dutch phrase.
- `geschiedenis van ongedaan gemaakte acties` became `actiegeschiedenis` in
  the app and website. The former wrongly suggested only already-reversed actions.
- `Gegevens wissen behoudt de teller` became `Ook na het wissen van
  wedstrijdgegevens blijft de teller bewaard` in the access explanation. This reads
  naturally and preserves the distinction between deleting games and the counter.
- `block` is expressed as `servicebeurt`, with full explanatory text for the
  next rally’s position, avoiding an unexplained literal technical noun.
- Team-result prose uses `Ons team heeft gewonnen` and `Het andere team heeft
  gewonnen`, not literal possessive constructions. Manual Match completion never
  claims an overall winner.

The two substitution messages retain argNum, integer format and one/other forms:
`1 van 1 rally gespeeld.`, `2 van 4 rally’s gespeeld.`, and `1 rally in totaal`
versus `32 rally’s in totaal`. Values 0, 1, 2, 4, 5, 11, 21, 22, 25, 101 and 999
use singular only for 1 and other for the remaining integers in Dutch.

`unchanged.json` explicitly justifies every identical catalog value, including
Dutch loanwords and conventional scoring terms; no generic English fallback is used.

## Validation and handoff

- `python3 Scripts/verify-localizations.py --locale nl`: PASS, exit 0; 334 catalog keys, four pages, store drafts and glossary checked.
- `make static`: PASS, exit 0; six launcher tests passed. Optional SwiftLint, SwiftFormat and ShellCheck are disabled in the repository configuration and reported skipped. Logs: `.artifacts/localization-nl/locale.log` and `.artifacts/localization-nl/static.log`.
- Initial static attempt started before the review document existed and failed the missing-review assertion; after adding this required document, the complete check passed. This was an incomplete work state, not a baseline failure.
- All original English entries preserved; the 31 previously uncatalogued source
  strings are added with exact English keys/values and Dutch translations.
- `make fast` NOT RUN: coordinator reserved the build slots and explicitly schedules
  it after translation. No Simulator commands were issued in this language task.
- Runtime layouts, maximum Dynamic Type, interactive journeys, VoiceOver audio and
  the six Dutch real-app screenshots remain pending coordinator validation.
- No xcresult bundles were produced in this task. No claim of runtime verification,
  independent review, invited native-speaker review or release approval is made.
- No store upload, App Review submission, website publication, shared-infrastructure
  change or unrelated-language edit was performed.

Handoff state: translation and editorial self-review ready; runtime verification
and coordinator editorial audit remain outstanding. Final commit SHA is recorded in
the agent’s delivery, because embedding a commit’s own SHA would be self-referential.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Examples of corrections after the language agent’s own review:

- Opened the tie-break → Eerste serveerder tiebreak
- Earlier save restored → Eerdere versie hersteld
- No lifetime purchase was found for this Apple Account. → Geen aankoop voor levenslange toegang gevonden voor dit Apple Account.
- Game → Wedstrijd

Runtime context refinement: the external legal-page heading is «Webpagina», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.
