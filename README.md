# Padel Score — Wrist

An independent Apple Watch scorekeeper for recreational padel, with an iPhone
companion for interactive practice and lifetime purchase/restore.

## Made for real games

- Optional gesture scoring for either team on compatible Apple Watch hardware
  with watchOS 11 or later. Each Double Tap series is two thumb/index contacts.
  One series proposes US; after Pending: US appears, a second selects THEM.
  A third cancels. The fixed five-second window starts at the first series.
- Correct the agreed current score or edit an earlier recorded rally, keeping later
  winners in order. Preview score and serving consequences before applying.
- Play Match without a fixed set limit, or track your own Americano round.
- Start from a known score, undo corrections, resume play and browse local history.
- Five completed games free, then one lifetime non-consumable purchase. No subscription.

Real games and journals stay on Watch. The iPhone gesture guide is an explicit
simulation; it does not control a real game. No account, analytics or cloud sync.
Minimum platforms: watchOS 10 and iOS 17; ordinary touch scoring remains available.

## Build and verification

Open `App/PadelScore.xcodeproj` in Xcode. Shared schemes: `PadelScore` (Watch)
and `PadelScorePhone` (companion). Signing requires your own development team.
Use `make help` for the maintained local commands. The repository uses managed,
checkout-specific simulators; read `AI/WORKFLOW.md` before running device tools.
`make static` checks repository invariants; `make fast` is the development loop.
Full milestone and release gates record the exact source commit and native results.
GitHub hosts source/history; a push is not a verification result.

## Architecture

SwiftUI screens use deterministic Match/Americano scoring engines. `SessionStore`
applies validated commands and publishes changes after a successful local save.
A versioned Codable file, atomic replacement and a previous-copy backup protect
the score and correction journal. StoreKit 2 supplies the verified lifetime
entitlement. Practice and iPhone demos use disposable memory-only models, separate
from real games and free-game usage.

## Product and development history

Product decisions: [PRODUCT](AI/PRODUCT.md), [architecture](AI/ARCHITECTURE.md),
[design](AI/DESIGN.md), [current status](AI/PROJECT_STATUS.md).
The app-specific scoring engines, correction journal and interaction flows were
built incrementally for this product with AI assistance. The repository also
contains a reusable development-workflow scaffold, not a purchased scorekeeper app.
Its original guide is preserved in [workflow template guide](AI/workflow-template-guide.md).

[Early product discussion](https://chatgpt.com/s/cx_6ae79dbd0bf88191b49d1e670d468457)
records the original requirements; it is historical and does not describe every
feature or platform in the current build. Source history supports provenance,
not a claim of worldwide exclusivity or App Review approval.

[Support and privacy](https://padel-score-wrist.pages.dev/).
