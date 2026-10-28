# M23 Builder self-review

Baseline `86e6bcc978814398e5607edcdd9936ac557a92ec`, primary checkout/main.
Builder self-review, not independent audit or release approval.

## Behavior and ownership

The default zero start remains unchanged. Current-score setup shares the original
rules/access selection, then the existing pure score drafts and editors. It covers
completed sets/current games, every deuce stage, tie-break score/turn/opening pair,
and Americano score/target/block/current server. No synthetic earlier rally or
format conversion is generated. Only a valid continuable format can reach Review
and Start; domain validation independently checks the request. The normal atomic
session store owns saving/retry, fresh identity and completion accounting.

One typed known-score checkpoint and empty Undo history define the starting
boundary. Later rallies/corrections use existing replay; earlier detail is labelled
unknown in current and archived journals. Finish/Undo/re-finish counts that same
GameID once. Prior archive, recent settings and usage change only on saved commands.
The unreleased schema-3 journal gains one reason; shipped schema-1/2 migration and
repository recovery/newer-version handling are unchanged.

NewGameFlow owns the in-memory editor, not LiveScore. Typed route callbacks reuse
set/block editors in both navigation stacks without mixing their route types.
Back keeps entry; Cancel discards it without touching disk; cold launch restores
saved state only. Rules edited after returning to setup preserve scores and
revalidate conflicts. Explicit From zero clears the alternative entry. Saving or
a failed save locks the score draft; retry preserves request/game identity.

## Craftsmanship

Native wrapped graphite/lime rows, existing number controls and service order are
sufficient. Review leads with the score, then rules/deuce/serving and the unknown
history/Undo explanation. It shows every completed set and explicit service context;
there is no declared overall Match winner. Current-score serving uses Next server
and After them headings. Errors belong to their fields, and a completed round is
explained as unable to start. Access is owned by the visible Review, preventing
multiple underlying screens from presenting the same sheet. No bespoke image,
continuous animation or new gesture earns its place. No new performance-sensitive
list or replay path is introduced; existing history/correction coverage still runs.

All seven added strings have translations in the existing thirteen locales.
Unchanged localization verification and full native audit categories run; largest
text/background/cancellation and minimum-watchOS interaction are exercised. M25
owns fresh hardware, VoiceOver and all-locale six-domain evidence; those are not
claimed from Simulator. The live scoring surface remains unchanged.

## Corrections and evidence

Development errors and their corrections are retained in development.md, including
the initial checkpoint UI query using the wrong accessibility role. Every original
assertion remains; the new query now opens the correct Button and verifies the
exact title in detail. Self-review additionally corrected completed-round copy,
review hierarchy, duplicate Access presentation, Cancel ownership and rule changes
silently clearing score entry. Targeted final-source checks and clean full-gate
results are recorded in runtime.md and milestone-verification.md after execution.
No test, audit category, parser or required suite is weakened; no inherited waiver
or unproved pre-existing failure is used. No additional scanner is configured
beyond static; existing optional analyzers are disabled by product configuration.

Final-source watchOS10 validation passed16/16 definitions/20 invocations,
including the added setup-rule preservation regression and all four UI cases.
Final captures were inspected; no blocking finding remains known. Runtime details
are in runtime.md. The full clean-SHA milestone gate remains required.
