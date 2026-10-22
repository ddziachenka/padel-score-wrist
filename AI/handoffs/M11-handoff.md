# M11 handoff — Purchase, Result and Play Again

**Policy status:** current

## Milestone

`M11` — Purchase, Result and Play Again; status `DONE`.

## Summary

First Builder session of the owner's 2026-10-22 purchase-appeal plan. It saved the plan
as [AI/purchase-appeal-plan.md](../purchase-appeal-plan.md), carried its decisions into
PRODUCT (PD-11…PD-17, offer wording, free/paid rows, data and deletion, A5/A8, N5/N9,
change log), DESIGN (IA, journeys J5–J8, S10/S12, S15–S19, paywall order, M11 paragraph,
prohibited patterns) and ARCHITECTURE (Play again rule, `AccessOffer`, the approved
M12–M14 boundaries, storage version 2 for M13), appended PLANNED milestones M11–M15 and
recorded the owner exception that runs them before the blocked M10. M10 keeps its
M00–M09 dependencies because `project-status.sh validate` requires Final Product Polish
to depend on exactly every earlier-numbered milestone; its contract now carries the
M11–M15 DONE precondition as an acceptance criterion and an exception section. No
validator was changed. Then it implemented and verified M11 only:

- Access (S12) leads with `Keep your focus on the game`, `Unlimited Match & Americano
  scoring.` and the free-game state, then `Unlock forever` with `Product.displayPrice`
  and `One payment. No subscription.` right under it (also under `Checking purchase…`,
  `Loading price…` or `Purchase unavailable right now.` + Retry), then the status
  message and purchase/restore progress, `Restore purchases`, `Your current game and
  last result stay available, even without a purchase.`, Terms, Privacy and Close.
  `Unlimited games`, `Match and Americano. One purchase, no recurring payments.` and
  `One-time purchase` are gone; a lost free-game count no longer repeats the
  current-game sentence on Access. Entry points are unchanged; nothing is offered after
  a result. `AccessOffer` derives every state from the single entitlement owner.
- A match result leads with its sets: `US` / `THEM` column names, each finished set as
  "ours — `Set N` — theirs" in constant columns (a fixed-width name column between
  them), a secondary `Sets won` line only once a set is finished, then the set it
  stopped in as its own `Set N · Incomplete` block with `Games` and `Points` or
  `Tie-break`. With no finished set the block leads with large numbers; a match without
  points says `No points played.`; no `0–0 Sets` and never a winner. Rounds keep their
  points tiles, Win/Draw or `Ended early` with the leader, and `N of M rallies played.`
  `✓ Saved` follows the score. Finish (S9), the result and Last result share the
  structure, and the VoiceOver sentence after correcting a result leads the same way.
- `Play again` is the primary action on the current finished result; `New game` is
  secondary; Resume and Edit result are unchanged. It opens Setup of the same format in
  the result's stack with that result's rules and serving order (saved corrections
  included) and the player who served its first recorded point, under `Same rules and
  serving as your last game. Check who serves first.` Back saves nothing. Start uses the
  existing `.start` command and access check; after five games the existing Access sheet
  opens, Close keeps the draft and the result, and a purchase starts nothing.

Choices made in-session (reversible, recorded here): the proposed first server is the
player who served the result's first recorded point, so a server corrected before the
first point is honoured and a game without points offers its standing server; the
status message sits directly under the purchase line (above Restore) so the outcome of a
tap is visible without scrolling on 40 mm; `Free games left: 5 of 5` keeps `5 of 5`
together with no-break spaces.

## Changed files

- `AI/purchase-appeal-plan.md` — the owner's plan, saved without changing its decisions.
- `AI/PRODUCT.md`, `AI/DESIGN.md`, `AI/ARCHITECTURE.md`, `AI/DEVELOPMENT_PLAN.md` —
  approved decisions, M11 implementation contract, M12–M15 boundaries, exception.
- `AI/milestones/M11…M15-*.md` — new sequential milestones; `M10-final-product-polish.md`
  — M11–M15 precondition and exception section, dependencies unchanged.
- `AI/PROJECT_STATUS.md`, this handoff — current milestone and evidence.
- `App/PadelScoreWatch/Domain/GameSetup.swift` — `GameRecord.setupToPlayAgain`.
- `App/PadelScoreWatch/Features/Access/AccessOffer.swift` (new), `AccessView.swift` —
  presentation model and the approved paywall order.
- `App/PadelScoreWatch/Features/Result/ResultSummary.swift`, `ResultSummaryView.swift`,
  `ResultView.swift` — sets-led match result, round result, Saved after the score,
  Play again.
- `App/PadelScoreWatch/Features/NewGame/SetupDraft.swift`, `NewGameFlow.swift`,
  `SetupView.swift`; `Features/Game/LiveScoreView.swift` — draft origin, `playAgain()`,
  Play again caption, Setup in the result's stack.
- `App/PadelScoreWatch/Features/Game/ScoreAnnouncement.swift` — corrected-result sentence.
- `App/PadelScoreWatch/Localizable.xcstrings` — 11 new English entries, 4 retired, free
  games value with no-break spaces.
- `App/PadelScoreWatch/App/UITestStore.swift` — Debug-only seeds `matchFinishedFirstSet`
  and `matchFinishedSets`.
- `App/PadelScore.xcodeproj/project.pbxproj` — new app source in the shipping and
  StoreKit host targets (host parity verified) and four new test files.
- Tests listed below.

## Validation

| Field | Evidence |
| --- | --- |
| Baseline | `2f9d1e1d94c0ef1394bc43f7ac82de8ae57ca11d`, clean main (the plan's researched HEAD) |
| Verified SHA | `060aa2a25a677d73618ac6300a8caf024903f388`, clean `REVIEW` commit on `main` in `/Users/Shared/D/ios/padel-score` |
| Exact command | `make -C /Users/Shared/D/ios/padel-score milestone ID=M11` (the Makefile runs `./Scripts/verify-milestone.sh M11` in the primary checkout) |
| Exit code | **0** — `PASSED milestone verification`; static, Debug build and full shared scheme passed |
| Timestamp | Gate 2026-10-22T12:44:36Z–13:30:17Z; test bundle 2026-10-22T12:45:02.652Z–13:30:08.944Z |
| Report | `.artifacts/milestone/M11/20261022T124436Z-2597/report.md` (primary checkout) |
| Result bundle | `.artifacts/milestone/M11/20261022T124436Z-2597/milestone.xcresult` |
| Counts | **423 total, 423 passed, 0 failed, 0 skipped, 0 expected failures**: 354 unit/policy + 5 StoreKit + 64 UI (`xcresulttool`) |
| Environment | Xcode 27.1 (27A9275); managed Apple Watch SE 40 mm (2nd generation), watchOS 26.1 (23S36); UDID A7CBB23C-F823-4850-BE4B-CAD76922DD08 |

Before the gate, in the worktree (development feedback, not evidence): hosted unit run
354/354 passed; targeted UI run of the changed suites 26/26 passed (19 UI + 7 seed unit
tests), then the two Access tests 2/2 after the last copy fix; `make static` exit 0;
`./Scripts/project-status.sh validate` exit 0; `python3 Scripts/verify-storekit-host.py`
passed. No additional problem scanner is configured (SwiftLint, SwiftFormat and
ShellCheck are disabled in Config).

Runtime check on the managed 40 mm simulator with the session's Simulator control tool
under the checkout lease: match result after one set (6–4, then 3–2 30–15), several sets
with a tie-break in progress, a first set in progress, `No points played.`, an Americano
round ended early, Play again → Setup → Back → result, five-games Play again → Start →
Access sheet → ✕ keeps the draft, Access from About, largest standard text (XXXL) and
Increase Contrast (block outline). It found and fixed three defects (below).

## Tests

- `PlayAgainTests` (new, 12): the domain rule for both formats, corrected rules and
  order, undo of a correction versus the remembered settings, first server after a
  pre-point correction and without points, a match corrected into a round; the flow
  saves nothing before Start, Back discards, Start plays 0–0 in one revision with the
  result kept for viewing, edited values win, only the current finished result plays
  again; at the limit Start is refused with the draft kept, unlocking starts nothing,
  Close then Start works.
- `AccessOfferTests` (new, 11): checking, exact StoreKit price passthrough, loading,
  no product / offline / failed with Retry clearing it, cancelled, pending, purchase and
  restore under way, restored and nothing to restore, unlocked, revoked, unverified,
  free-game classification and every message's words.
- `ResultSummaryTests` (+ several sets; `setsWon` is nil before a finished set),
  `ScoreAnnouncementTests` (incomplete-set and no-points sentences), `SetupDraftTests`
  (play-again origin round trip; unoffered totals wait to be chosen), `UITestStoreTests`
  (new seeds), `FinishResumeTests` (round points).
- UI: `PlayAgainUITests` (new, 4: match, corrected rules, round, five-game limit);
  `AccessUITests` + paywall order and retired copy; `FinishResumeUITests` + sets-led
  layout and order, and no 0–0 headline where it used to be asserted;
  `AccessibilityUITests` + audits of the tie-break result, Play again setup and
  first-set result.

Self-review (Builder self-review, not an independent review) of the full
baseline-to-tip diff found and corrected: the `THEM` column name truncated to `TH…` on
40 mm (now kept whole over its column without moving the columns); `Free games left: 5 of
5` breaking between the numbers on New game after the shared caption inset (no-break
spaces); the paywall title block 4 pt out of line with the captions; and, before the
first run, a tautological revision assertion and a wrong expected serving order in new
tests. Existing assertions changed only where the approved behavior changed (the match
headline), each replaced by a stronger check of the new behavior.

## Known issues

- Workflow deviation, as in M01–M07: the session ran in the Claude app worktree
  `.claude/worktrees/padel-score-wrist-purchase-856e0b` (branch
  `claude/padel-score-wrist-purchase-856e0b`) because a session hook blocks edits in the
  primary checkout. Every commit was made on that branch from main's tip and
  fast-forwarded (`git merge --ff-only`) into `main` of the primary checkout, so the SHAs
  are identical; the gate, static, validate and continuity ran on `main` there.
- Not checked on real hardware or on the watchOS 10 runtime in this milestone; the
  purchase owner, StoreKit adapter and storage are unchanged. M10 owns the remaining
  physical and minimum-OS evidence; its blockers are unchanged.
- In UI tests the local StoreKit price is not always loaded, so the order test accepts the
  price button or `Purchase unavailable right now.` in that place; price formatting stays
  covered by the StoreKit tests.
- Site, App Store text and on-watch legal copy were not changed: the purchase terms they
  state still match. M15 owns the store and site materials.
- `.artifacts/` evidence is local and ignored; the continuity commit does not back it up.
  Nothing was pushed, published or submitted.

## Next step

M12 — Scoreboard Demo, in a new Builder session. M10 resumes only after M11–M15 are DONE.
