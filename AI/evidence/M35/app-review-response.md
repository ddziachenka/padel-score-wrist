Hello App Review Team,

I am resubmitting Padel Score — Wrist 1.0 (8) for reassessment of the Guideline 4.3(a) concern originally raised for build 1.0 (2). I withdrew build 1.0 (7) before review to add next-serve-side guidance and complete its verification. Build 8 includes that addition alongside gesture scoring for either team, selective correction of past rallies, and a guided known-score start.

1. Next-serve side beside the server. R and L describe where to serve the NEXT rally, from the server's viewpoint facing the net. Match derives the side from the current score, including deuce, advantage and tie-breaks. At a deciding golden point it shows L/R and “Receivers’ choice”, rather than predicting the receivers' decision. Americano follows the explicitly documented convention of starting each server's block on R and alternating within that block, including odd-length blocks. Undo and correction previews recalculate the side from the restored score and service state. VoiceOver speaks the full side name. The indicator is hidden after Finish and while a new set awaits serving confirmation.

To reproduce this quickly: on Watch, About → Try the scoreboard starts at 40–30 with L. Award THEM to reach 40–40: L/R and Receivers’ choice appear. Undo restores L. On iPhone, Demo → Match shows the same sequence; Demo → Americano starts at 10–10 with R, changes to L after one point and returns to R at the next server's block. The attached four-page guide illustrates the new behavior.

2. Gesture scoring for either team. On a compatible Watch with watchOS 11 or later, enable optional Double Tap input for the game. One series of two thumb/index contacts proposes US; after “Pending: US” appears, a second series selects THEM and a third cancels. The fixed five-second deadline saves one uncancelled rally. Leaving the score or lowering the wrist cancels pending input. Separate practice teaches this sequence without affecting a real game; the iPhone guide explicitly simulates it.

3. Correct an earlier mistake without discarding later recorded winners. In Menu → Journal, select a rally after the latest checkpoint and change its winner, remove a duplicate or insert a missing rally. Compare Before/After score and serving, resolve any serving ambiguity, then apply. One Undo restores the entire correction.

4. Start from the score the players agree on. The guided known-score start supports Match and Americano with explicit serving information. Unknown earlier rallies are not invented. The current-score editor remains available, and Match has no preset set limit: players can continue sets and finish when their court booking ends.

These workflows grew from playing recreational padel in Batumi about four to six times a month: keeping track of serving position, resolving score disagreements, discovering entry mistakes late and playing until a booking ends. Real games run independently on Apple Watch. The iPhone companion provides interactive examples and optional purchase/restore. No sign-in is required. Five completed real games are free, followed by one lifetime non-consumable purchase; there is no subscription.

I compared existing padel scorekeepers when defining these requirements. The app-specific workflows were implemented incrementally for this product; I am not claiming that the general idea of a padel scoreboard or L/R labels is exclusive. Source history and the original planning discussion provide supplementary provenance:
https://github.com/ddziachenka/padel-score-wrist
https://chatgpt.com/s/cx_6ae79dbd0bf88191b49d1e670d468457

The discussion is historical; the guide and Review Notes describe build 8. The repository also includes a reusable development-workflow scaffold, distinct from the app implementation.

Please reassess the updated Watch experience. If a concern remains about a particular binary component, asset, metadata element or workflow, could you identify it so I can address it precisely?

Thank you,
Dzmitry Dziachenka
