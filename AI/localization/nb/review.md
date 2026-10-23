# Norwegian Bokmål localization — translator self-review

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.
Branch: `localization/nb`. Scope: nb only; English preserved, including 31 newly catalogued English sources.

## Glossary and register

| Meaning | Bokmål |
| --- | --- |
| Complete match / Match format | kamp / Kamp |
| Generic game session | spill |
| Game inside a set | game (plural game) |
| Set | sett |
| Rally | ballveksling |
| Server / serving / service order | server / serve / serverekkefølge |
| Advantage / one advantage | fordel / én fordel |
| Golden point / tie-break | Golden point / tie-break |
| You / Partner | Du / Medspiller |
| Opponent 1 / Opponent 2 | Motstander 1 / Motstander 2 |
| US / THEM | VI / DE |
| Undo / undoable actions | Angre / handlinger som kan angres |
| History / latest result | Historikk / nyeste resultat |
| Lifetime access | varig tilgang |
| Smart Stack / watch face | Smart stabel / urskive |

Direct, calm Bokmål using du. Buttons start with a verb. Errors explain the outcome
without blaming the user. Full VoiceOver sentences use “vi”, “de”, “oss” and “dem”
as grammar requires; the visible team labels stay VI and DE. Match and game are not
conflated. “Spill” is the generic session, so the free allowance covers either format.

## Second reading and corrections

Read all 334 catalog entries, including every long legal/support source and plural
variant, and all four complete website pages and the store/IAP draft. Re-read the
Norwegian prose by surface, then compared its meaning with English. This is the
language agent's editorial self-review, not an independent or invited native review.
The coordinator's final editorial audit remains separate.

Concrete corrections made during the second reading:

- “Game til VI” → “VI vant gamet” (and DE): natural Norwegian instead of a literal
  rendering of “Game to US”. Spoken announcements use “Game til oss/dem”.
- “Første server i tie-break” → “Servet først i tie-break”: the heading identifies
  who served first; it never announces that a tie-break just started.
- “Undo history” → “handlinger som kan angres” throughout privacy/support/deletion:
  these are available undo steps, not a list of previously undone actions.
- “Andre gang det står likt ved 40–40” → “Andre gang det står 40–40”: removed
  redundant phrasing while retaining the second-deuce deciding-point rule.
- “erstatter … med” → “bytter ut … med” in the replacement explanation to avoid
  repeating the button label “Erstatt spillet” and the same verb in one sentence.
- The Americano rule says both teams' points count toward one shared total.
  Nothing suggests a separate target per team or tournament standings.
- “Lifetime” is rendered as “varig tilgang” and explained as one payment without
  recurring charges, avoiding an unnatural English loanword or a subscription claim.

No new promises about accounts, backup, recovery, deletion, refunds or purchases.
Brand, email, URLs and policy dates retained. On-Watch dates are 21 October;
website source dates are 23 October, each kept as supplied.

## Validation and handoff

- `make help`: exit 0; inspected authoritative command list.
- `python3 Scripts/verify-localizations.py --locale nb`: initial exit 1 while this
  review file had not yet been written; final run and outcome recorded below.
- `make static`: final outcome recorded below.
- 330 Watch keys and 4 Launcher keys translated, with one/other forms on both
  pluralized messages and unchanged format parameter types.
- Four full pages under `/nb/`, root stylesheet, localized canonical URLs, local
  navigation, translated metadata/alt text, six `/images/nb/` capture references.
- Local `no` App Store and IAP drafts only. No upload or publication.
- Screenshots are references awaiting coordinator-generated real-app captures.
  No image text was edited or fabricated.
- `make fast`, simulator UI/layout/Dynamic Type, actual VoiceOver and real-Watch
  checks were NOT run by this agent: coordinator serializes the build/device queue.
  Number samples 0, 1, 2, 4, 5, 11, 21, 22, 25, 101, 999 were reviewed linguistically;
  runtime plural rendering still requires coordinator validation.
- No milestone or release readiness status changed. Integration and full editorial
  audit belong to the coordinator; real-Watch evidence remains required by M10.

### Final local results

- `python3 Scripts/verify-localizations.py --locale nb`: **exit 0**, 334 keys,
  four pages and store drafts validated. Log: `/private/tmp/padel-nb-localization.log`.
- `make static`: **exit 0**, repository static verification passed, including
  6 launcher tests (0 failures). Log: `/private/tmp/padel-nb-static.log`.
- `git diff --check`: **exit 0**. All 299 original English localization nodes
  compared structurally with the base commit and remain unchanged.
- Optional swiftlint, swiftformat and shellcheck checks were not enabled and were
  reported as skipped by the repository. No xcresult bundle was generated.
- Commit identity is reported to the coordinator immediately after committing;
  this committed report describes that translation commit's content.


## Coordinator editorial pass — 23 October 2026

Read all 330 Watch entries (including plural variants), four launcher entries, four full web pages and all store fields. Reviewed first for natural phrasing, then for scoring, purchase and privacy meaning. This is the coordinator’s editorial review, not an independent or invited native-speaker certification. Runtime layout and capture evidence is recorded separately in the integration handoff.

Second reading retained the language agent’s phrasing; context and layout checks remain separate.

Runtime context refinement: the external legal-page heading is «Nettside», the natural word for a web page, rather than a literal “public page”. The URL and privacy meaning are unchanged.

## Coordinator blind reading — final pass

Read all 330 Watch messages (including every plural form), all four launcher messages, all four complete web pages and every store field without English source text. Then checked changes against the source meaning and repeated the affected passages. Blind reading clarified the website/privacy references and technical deletion limitations; service order already uses the unambiguous Server deretter. This is coordinator editorial review, not an invited native-speaker review.
