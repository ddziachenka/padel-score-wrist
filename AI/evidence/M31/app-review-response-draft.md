# App Review response — prepared, NOT SENT

Use only after M26 readiness and the full M30 gate, after validating/selecting
build1.0(7) and publishing the matching source history. Replace build identity if
ASC requires a different build. Attach the current illustrated review guide.
No video or measured gesture-recognition claim is made.

## Response

Hello App Review Team,

Thank you for explaining the Guideline 4.3(a) concern with Padel Score — Wrist 1.0 (2). I have substantially expanded the app since that review. For this resubmission, version 1.0 (7) provides the following concrete workflows on Apple Watch:

1. Gesture scoring for either team. On a compatible Watch with watchOS 11 or later, players can enable an optional Double Tap input for each game. A series consists of two thumb/index contacts. One series proposes our point; after “Pending: US” appears, a second series selects the opponents. A third cancels. The app previews the choice before saving one rally at a fixed five-second deadline. Leaving the score or lowering the wrist cancels the pending entry. A separate practice flow teaches the sequence without affecting a real game.

2. Correct a mistake discovered several rallies later. In Menu → Journal, select an earlier recorded rally and change its winner, remove a duplicate, or insert a missing rally. Later recorded winners remain in order. Before applying, compare the resulting score and serving state; resolve any serving ambiguity explicitly. One Undo restores the entire correction. This supports recovery when the latest-action Undo alone would require undoing subsequent correctly recorded points.

3. Resume from the score the players agree on. The current-score editor and guided known-score start support Match and Americano with explicit serving information. Unknown earlier rallies are not invented. Match has no preset set limit: players can continue sets and finish when their court booking ends.

These decisions grew from playing recreational padel in Batumi about four to six times a month: resolving score disagreements, discovering entry mistakes late, and playing until the end of a court booking. The first five completed games are free, followed by one lifetime non-consumable purchase without a subscription.

The attached guide and Review Notes give short, reproducible routes through these features. Real games run independently on Apple Watch. The iPhone companion provides interactive examples; its gesture guide is explicitly a simulation. No sign-in is required.

The updated icon, screenshots and metadata now make these workflows easier to identify. I compared existing padel scorekeepers when defining these requirements. The app-specific scoring and correction workflows were implemented incrementally for this product. Source history and the original planning discussion are available as supplementary provenance:
https://github.com/ddziachenka/padel-score-wrist
https://chatgpt.com/s/cx_6ae79dbd0bf88191b49d1e670d468457

The discussion is historical; the attached guide describes this build. The repository also includes a reusable development-workflow scaffold, distinct from the app implementation.

Please reassess the updated Watch experience. If a concern remains about a particular binary component, asset, metadata element or workflow, could you identify it so I can address it precisely?

Thank you,
Dzmitry Dziachenka
