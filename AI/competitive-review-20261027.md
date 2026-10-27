# Padel Score — differentiation review, 2026-10-27

Status: research and proposal, NOT an approved product contract or implementation milestone. No App Review reply or resubmission sent. Existing draft remains on hold.

## Decision

Prepare a substantively improved version without making Apple's clarification a prerequisite for design work. A short clarification in the existing review thread can run alongside that work, but it is not a new submission and is not sent by this research task. Ask which specific binary, metadata or concept elements caused 4.3(a); do not assume the answer will name a competitor or guarantee acceptance of a proposed feature. Apple explicitly permits correspondence before resubmission: https://developer.apple.com/distribute/app-review/ .

The initial proposal of a point timeline and serving assistant is insufficient as a differentiation claim: multiple competitors already advertise those capabilities. Independent development is distinct from differentiation. Apple's exact allegation remains unspecified; public similarity does not identify the app used in Apple's comparison.

## Method and limits

Checked public developer websites, manuals and current App Store descriptions on 2026-10-27, alongside this repository's product contract and scoring/correction/history code. These are declared features, not hands-on verification. No competitor binaries installed, no comparative usability or reliability scores assigned. Not mentioned means unknown, never absent. Listings can differ by version and change. This is a bounded competitive set, not proof of worldwide uniqueness. No competitor code or visual assets copied.

## Direct and adjacent comparison

| Product / primary source | Publicly described capabilities relevant to us | Implication |
| --- | --- | --- |
| [PadelWrist](https://apps.apple.com/ca/app/padelwrist-padel-score/id6799725420) | Watch scoring, Undo, offline scoring, Standard/Fixed Points, Advantage/Golden/Star/Silver, serving/end-change assistant, Play Again, history, insights, sharing; no own account required | Rules, offline mode, serving assistance and rematch are not enough individually. Version 1.9 includes Play Again. |
| [PadelCounter](https://padelcounter.com/) | Watch scoring, Undo, Americano, Golden/Star, server and side-change guidance, point timeline, serve/return/momentum, live browser scoreboard | A timeline, Americano and serving display already overlap heavily. |
| [Padel Score Keeper manual](https://www.padelscorekeeper.be/user-manual.html) | Advantage/Golden/Silver/Star; Silver is one advantage cycle then deciding point. Undo, service correction, resume, point-progression graphs, optional serving direction and insights | Our One advantage is not a new rule. General score recovery and service changes are already established features. |
| [VMSPadel Watch manual](https://vmspadel.com/watch-app/) | Serving player and position, Undo/change serve, key-point indicators, interrupted-match recovery, Watch history, configurable rules and Quick matches | Next-server prompts, resume and key-point indicators should not be pitched as unique. |
| [Padelistics](https://padelistics.com/) | Match/tournament records, point/shot logging, winners/errors, statistics, Watch companion | Generic post-match statistics is an occupied direction with larger scope. |
| [Start Padel](https://startpadel.app/) | Match/Watch scoring, Americano, debrief, training/coaching, contextual rules referee with FIP citations, local data without own account | Generic coaching, rules help and privacy positioning are not open territory. |
| [Scorepion Americano](https://scorepion.co/americano) | Organiser and participant modes, fixed total rallies, draws, individual standings, Watch scoring, four-player service blocks | Even a personal Americano evening journal has a close public analogue. Tournament scope also conflicts with current PD-02. |
| [Bandeja](https://padelscoreboard.app/) | Local Watch/phone scoring, no account/ads/tracking, Undo, pause/resume, configurable rules and history | Privacy, offline and simplicity remain useful qualities but cannot alone substantiate uniqueness. |
| [Padelly](https://getpadelly.com/apple-watch-padel-scoring/) | Undo restores score and serving even across game/set/tie-break, local Watch state after every action | Our full-state Undo is valuable but not an exclusive capability. |
| [TapScore](https://tapscore.net/) | Watch scoring plus optional Watch-triggered rolling video clips on iPhone; history and match analysis | Video offers a distinct workflow but adds camera/microphone/phone-on-court scope; not recommended for this focused app. |

The previously recorded name collision [Padel Score, Amit Green](https://apps.apple.com/gb/app/padel-score/id6755762234) is described primarily as player matching, social features and rankings. It is not the best functional Watch comparator merely because of its name. PadelWrist is a closer functional/name neighbour, but there is no evidence Apple compared us with it.

## Current product, from local evidence

The app already has three deuce options, independent offline Watch scoring, Americano total-rally limits and serving blocks, full-state sequential Undo, validated current-state score/rule/service correction, local finished results, Play again and iPhone demos. Sources: AI/PRODUCT.md, Domain/Session.swift, Domain/SessionCommand.swift, Features/Correction/GameEditorScreen.swift, Features/Result/HistoryView.swift.

Current correction replaces the complete current situation; it does not edit a past rally and replay subsequent events. The current-game Undo chain holds before-snapshots and change kinds. Finished archive entries deliberately contain no Undo chain. A persistent replayable event history therefore needs a deliberate data model and migration, not just a new list screen.

## Recommended differentiation hypothesis: guided correction during play

Position around recovering from an entry mistake discovered later, without re-entering all subsequent points. This builds on the owner's original need to correct all game data while retaining a small, independent Watch app.

Concrete demonstration:
1. Record several rallies. Discover a rally three entries ago was awarded to the wrong team.
2. Open the current game's rally journal, select that rally and change its winner (or explicitly identify a duplicate/missing recorded rally).
3. Preview the resulting score and next server alongside the old situation, with the later recorded rally winners retained where replay remains valid.
4. If a game/set boundary or service confirmation becomes ambiguous, ask for the missing decision. Never silently pretend to know who actually served or invent unrecorded rallies.
5. Apply the correction together, retain an audit entry, and allow undo of the correction as one action.

Public sources reviewed describe Undo, timelines and state editing, but do not explicitly document this complete selective edit + replay + impact preview + ambiguity handling workflow. This is a research hypothesis, not a verified absence across competitors. Before implementation commitment, hands-on inspect correction/history in the closest available products (PadelWrist, PadelCounter, Padel Score Keeper) if access permits; do not purchase subscriptions without spending authorization. If an equivalent workflow is present, reassess the proposal.

Related bounded addition: a guided Start from current score flow. Existing state editing partly covers this already, so the benefit must be the complete validated onboarding route, explicit unknown earlier points and service confirmation—not a claim that entering a score is novel. Exclude this if it weakens the focus or adds unnecessary scope.

Make the differentiating journey visible in the iPhone demo: a seeded mistaken rally and before/after correction exercise using the same engine. Keep real match scoring on Watch; no new account, backend, Health, tournament or sync requirement. This requires owner approval to change the existing demo contract.

## Scope and acceptance before another submission

Product decision still needed for selective historical correction and the revised demo. Do not start coding based only on this research. Once selected, record the exact contract and milestone(s), then implement through the primary-branch workflow. Suggested first scope: current game's recent rally correction, preview, safe conflict resolution, undo, persistence and an iPhone exercise. Full archive analytics and social features are out of scope.

Validate wrong-team/duplicate/missing entries; game/set/tie-break crossings; new-set service decisions; Americano last rally/draw/serving blocks; existing manual corrections; cancel/undo; crash/relaunch persistence; legacy data migration; free-game accounting without duplicate counts; localized large-text controls on Watch and phone. Old M18 evidence cannot verify new source inputs. Preserve old owner exceptions without expanding them to new failures.

Revisit visual identity and store presentation after the useful workflow is defined. Distinguish the experience on the first screenshots and demonstrate it in review notes/video. A new palette, icon or name is not a substitute for utility and no rename is approved here. Do not remove iPad as a remedy for 4.3: Apple did not cite iPad support as the issue.

## Suggested review communication, not sent

Request specific binary/metadata/concept elements behind the finding while preparing meaningful product changes. Do not promise acceptance or claim unique features absent from competitors. If revising the older message, time-qualify the owner's statement: the initial product was developed independently for personal use; competitor research was subsequently performed after the rejection. Do not send the old unqualified “did not study competing apps” sentence as though no research has now occurred.

## Recommendation to owner

Start preparing the improved version now, with the focused correction workflow as the leading hypothesis; do not wait idle for Apple. Clarification is complementary risk reduction, not a prerequisite or guaranteed roadmap. Submit only after the chosen changes are implemented, verified and clearly demonstrated. No search can guarantee acceptance or absolute uniqueness.
