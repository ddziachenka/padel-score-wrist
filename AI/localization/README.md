# Localization — owner-approved plan, 2026-10-23

11 languages / 12 added locales; English remains the source language. The owner
approved localization before M10 and local App Store drafts, overriding the generic
prompt's timing and metadata exclusions. See the appended owner exception in WORKFLOW.

## Agent contract

One language task; own worktree only. Read AGENTS, WORKFLOW, PROJECT_STATUS, PRODUCT,
DESIGN and the existing English Web pages. Preserve product behavior and all English
strings. Use design:ux-copy principles: clear, concise, consistent, useful, human.

Translate every key in both String Catalogs, including all long offline legal and
support paragraphs and VoiceOver. Preserve format argument types and substitution
structure. Russian plurals: one/few/many/other; Spanish, French, Italian and Portuguese:
one/many/other; others one/other. Rewrite each entire sentence naturally; do not
assemble grammar from fragments. Match is a match, game within a set is a game,
rally is one point played. One advantage permits one advantage cycle, then golden
point at the second deuce. Americano total is BOTH teams' combined points, not a
per-team target. Match finishes manually, with no automatic overall winner.
Five completed games free, then lifetime purchase. History and demo stay free.
Deleting data preserves the free-game count and purchase. No health/fitness tracking,
accounts, sync, export, analytics or server-side game storage. No added promises.

Create AI/localization/<Locale>/:
- unchanged.json: object mapping each legitimately identical English key to a reason.
  Only proper names and conventional scoring/platform terms justify a match; review
  each one explicitly. Translate short UI text too, unless it is truly idiomatic.
- app-store.json: object keyed by store locale(s) in Config/localizations.json. Each
  value contains name (unchanged brand, <=30), subtitle (<=30), promotionalText
  (<=170), description (<=4000), keywords (<=100 UTF-8 bytes), iapName (<=30),
  iapDescription (<=55). Descriptions must faithfully cover actual features and
  limitations from AI/app-store-listing.md. No What's New for the first release.
- review.md: language glossary (match/game/set/rally/server/advantage and team labels),
  style/register, concrete examples corrected on second reading, validation commands,
  results, and any checks NOT performed. Never claim runtime checks not executed.

Copy and translate all four Web/public English pages under Web/public/<lowercase-locale>/.
Keep semantic HTML, product identity, email, privacy facts, Apple EULA URL and dates.
Use lang=<Locale>, localized canonical URLs, root /styles.css, local navigation URLs,
/images/<lowercase-locale>/ for six localized captures (coordinator will supply them).
Translate alt attributes, descriptions, titles and visible text. Coordinator generates
final cross-language alternate links and language navigation after integration.

Run python3 Scripts/verify-localizations.py --locale <Locale> and make static.
Do not run builds concurrently with another agent: request the coordinator's build
slot; each worktree needs its own managed simulator via make simulator-setup and
make simulator-context. The coordinator can schedule those after translation. Commit
translated content and report the full SHA, base SHA, files, glossary, commands and
remaining validation. Do not merge, publish, upload or submit. Do not change shared
infrastructure or test behavior. Shared file conflicts are resolved by coordinator.
