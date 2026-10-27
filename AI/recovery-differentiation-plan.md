# Recovery and differentiation plan — M19–M26

**Status:** approved for implementation, 2026-10-27
**Owner decision:** “Implement the proposed plan.” The preceding choices were selective correction + start from a known score, corrections within the current game, retained read-only journals, and fixing the two contrast failures before new functionality.

The product focus is recovering an accurate score without losing later recorded rallies. This is a differentiation hypothesis supported by [competitive research](competitive-review-20261027.md), not proof of global uniqueness or a guarantee of App Review acceptance. Independent initial development and later competitor research are separate facts.

## Sequence and boundaries

| Milestone | Deliverable | Dependency |
| --- | --- | --- |
| M19 | Fix the two native small-iPhone contrast failures | M18 |
| M20 | Typed rally journal, checkpoints, compatible persistence and archived journals | M19 |
| M21 | Selective change/delete/insert, replay and atomic preview/apply | M20 |
| M22 | Watch journal, correction journey and read-only archived detail | M21 |
| M23 | Start Match or Americano from a known current score | M22 |
| M24 | Interactive iPhone correction and mid-game-start examples | M23 |
| M25 | Six-domain experience revalidation and review materials | M24 |
| M26 | Exact-candidate Release Readiness Revalidation | M25 |

One Builder session completes one milestone. Each runs its full `make milestone ID=Mxx`; M26 additionally runs the unchanged exact-SHA release gate. The M18 consolidation and contrast exceptions are historical and do not apply to this work. No failed required check becomes a pass by owner acceptance carried from the old build.

Current game means the active game or latest editable completed result before another game starts. Selective corrections can cross game and set boundaries, but cannot cross the last manual score/rules/format replacement or migration/start checkpoint. Earlier available entries remain readable. Change a winner, delete a duplicate, or insert a missing rally; keep later recorded winners in order. Preview score, service and completion consequences. If serving at a changed set boundary is ambiguous, require explicit confirmation. Never invent a player or drop events silently. An Americano correction that completes the rally budget before remaining entries is blocked with an explanation.

A correction applies atomically to the same session revision and event IDs as the preview. Cancel, stale preview and storage failure leave the original unchanged. One Undo reverses the whole correction, including journal, score, service and finish state; usage accounting retains its existing once-per-game behavior. No arbitrary journal truncation.

Start-from-score is an alternative to zero in existing Match/Americano setup. Validate rules, completed sets, current games/points/deuce stage and explicit service, or Americano points/N/B/block position. Confirm a summary and create a normal game ID through the existing access policy. Unknown earlier rallies stay unknown; Undo stops at the starting checkpoint. Only a continuable state can start; completing the game is counted once as before.

New completed games retain their detailed journal for read-only viewing. Legacy archives retain compact results with a truthful unavailable-detail state. Migration preserves current score, sequential Undo, settings, entitlement behavior and usage ledger without reconstructing fictional rallies. iPhone demos are isolated in memory and share domain logic; real scoring remains on independent Watch.

## Verification and decision gates

Before M21 implementation, perform a bounded hands-on check of the closest available competitor's correction flow; record exact app/version/date and evidence. If the full proposed flow already matches, bring the product direction back to the owner. If inaccessible, mark unknown rather than absent; do not buy a subscription without spending authorization.

Tests cover all edit operations, each deuce mode, tie-break and game/set boundaries, service clarifications, checkpoints, stale previews, repeated corrections, cancellation/Undo, Americano draw/partial blocks/overflow, migration/recovery/write failures, long journals, free-game accounting and demo isolation. M25 owns new physical-device and six-domain evidence, all supported locales, VoiceOver, large text, minimum OS and current runtime coverage. Required unavailable coverage blocks its owning gate; historical exceptions are not new evidence.

M25 prepares honest screenshots, a short real Watch video and reproducible Review Notes. M26 binds evidence to the new source and binary, preserves the old M18 evidence, and updates the launch-monitor candidate/build guard before any publication-dependent work. The previous ASC reply remains unsent/on hold; clarification is complementary, not a prerequisite for implementation. App Review submission is a separate owner decision. No automatic reply, upload, resubmission, price or Promotional Text change occurs in this plan-registration session.

## Non-goals

No rename, new bundle ID, iPad change, real-match iPhone sync, new scoring formats, tournament organizer, accounts, cloud, HealthKit or monetization change. Five free completed games, the existing lifetime purchase and neutral 14-locale Promotional Text remain. Historical M00–M18 completion and raw failures are retained.
