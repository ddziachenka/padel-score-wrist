import Foundation

extension CorrectionProblem {
    /// What the editor says at the values that have to agree: the conflict, and how to settle it.
    var message: LocalizedStringResource {
        switch self {
        case .deuceRuleMissing:
            LocalizedStringResource("Choose what happens at 40–40.", comment: "Setup and corrections: shown at the 40–40 rule while none is chosen. The score 40–40 is kept on one line with word joiners around the dash.")
        case .totalRalliesMissing:
            LocalizedStringResource("Choose the total rallies.", comment: "Setup and corrections: shown at Total rallies while none is chosen.")
        case .ralliesPerServerMissing:
            LocalizedStringResource("Choose the rallies per server.", comment: "Setup and corrections: shown at Rallies per server while none is chosen.")
        case .advantageForBoth:
            LocalizedStringResource("Only one team can have the advantage.", comment: "Correction: both teams' points were set to AD.")
        case .advantageWithoutForty:
            LocalizedStringResource("AD is only possible against 40.", comment: "Correction: one team's points were set to AD while the other team's are not 40. AD is a team's advantage at 40–40.")
        case .advantageUnderGoldenPoint:
            LocalizedStringResource("Advantage isn’t used with Golden point. Change the rule or correct the score.", comment: "Correction: a team has AD while the 40–40 rule is Golden point, which plays no advantage.")
        case .deuceStageMissing:
            LocalizedStringResource("Choose which 40–40 it is.", comment: "Correction under One advantage: the score is 40–40, and whether it is the first or the second 40–40 is still to be chosen. The score 40–40 is kept on one line with word joiners around the dash.")
        case .tieBreakDecided:
            LocalizedStringResource("These points already win the tie-break. Correct them, or add the set under Sets.", comment: "Correction: the tie-break points chosen would already have decided the tie-break and its set.")
        case .gamesFinishSet:
            LocalizedStringResource("These games already win the set. Correct them, or add the set under Sets.", comment: "Correction: the current set's games chosen would already have decided the set.")
        case .completedSetInvalid(let index):
            LocalizedStringResource("Set \(index + 1) isn’t a finished set.", comment: "Correction: a completed set's games are not a score that ends a set. Argument: the set's number.")
        case .pointsExceedTotal:
            LocalizedStringResource("More rallies have been played than the total. Increase the total or correct the score.", comment: "Correction of an americano round: the two teams' points add up to more than the total rallies.")
        case .rallyInBlockOutsideBlock:
            LocalizedStringResource("Choose a rally position within the new service block.", comment: "Correction of an americano round: the next rally's place in the block is beyond the new rallies per server.")
        case .servingUnchecked:
            LocalizedStringResource("Check who serves next before saving.", comment: "Correction: a change made who serves next uncertain, so it has to be checked on the Serving screen.")
        case .unplayable:
            LocalizedStringResource("These values can’t be played together. Check the score and serving.", comment: "Correction: the values cannot be saved for a reason not shown at a single value.")
        }
    }
}

extension EditedPoint {
    /// The point as shown: 0, 15, 30, 40 or AD.
    var label: String {
        gamePoint?.label ?? String(localized: "AD", comment: "A team's advantage at 40–40, shown in place of its points. VoiceOver reads it as Advantage.")
    }

    /// The point as VoiceOver says it; AD is said as Advantage.
    var spoken: String {
        gamePoint?.label ?? String(localized: "Advantage", comment: "Rule at 40–40: win by two points, without limit. Also how VoiceOver says AD, a team's advantage.")
    }
}
